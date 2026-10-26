#!/usr/bin/env bash
# PreToolUse guard for Bash: the rules that were prose ("destructive operations require explicit
# user confirmation", "user reviews before deploy") become a check the harness runs on every
# command. Exit 2 blocks the call and shows the reason to the agent; exit 0 lets it through.
#
# An operation in the GUARDED list is allowed only when a fresh approval file exists:
#   scripts/approve.sh deploy        → .claude/approvals/deploy.ok, valid for 15 minutes
# Categories: deploy (releases, remote compose, remote ssh), migrate (schema changes outside the
# local stack), destroy (data loss: drop, truncate, rm -rf, volume removal, force push, reset --hard).
set -u
INPUT=$(cat)
CMD=$(printf '%s' "$INPUT" | python3 -c 'import json,sys; d=json.load(sys.stdin); print((d.get("tool_input") or {}).get("command",""))' 2>/dev/null)
[ -z "$CMD" ] && exit 0
ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
MAX_AGE=900   # seconds an approval stays valid

fresh() {  # fresh <category>
  local f="$ROOT/.claude/approvals/$1.ok"
  [ -f "$f" ] || return 1
  local age=$(( $(date +%s) - $(stat -f %m "$f" 2>/dev/null || stat -c %Y "$f") ))
  [ "$age" -le "$MAX_AGE" ]
}
block() { printf 'BLOCKED by .claude/hooks/guard.sh: %s\nRun: scripts/approve.sh %s   (valid 15 min, one category per approval)\n' "$1" "$2" >&2; exit 2; }

# destroy: data or history loss
if printf '%s' "$CMD" | grep -qiE '(^|[;&| ])(rm -rf|git push[^|]* (--force|-f)\b|git reset --hard|git clean -[a-z]*f|docker (volume rm|system prune|compose down[^|]* (-v|--volumes))|(mysql|psql|artisan)[^|]*\b(drop|truncate) |artisan (migrate:fresh|migrate:reset|db:wipe))'; then
  fresh destroy || block "destructive command: $CMD" destroy
fi
# migrate: schema changes anywhere except the local stack (local = no --env/host flag and APP_ENV unset or local)
if printf '%s' "$CMD" | grep -qiE 'artisan migrate(\b|:)' && ! printf '%s' "$CMD" | grep -qiE 'migrate:status|--pretend|--env=local'; then
  if printf '%s' "$CMD" | grep -qiE 'env=(prod|production|stag|staging)|ssh |--host|APP_ENV=(prod|production|stag|staging)'; then
    fresh migrate || block "schema change on a non-local environment: $CMD" migrate
  fi
fi
# deploy: anything that reaches a server or publishes an image
if printf '%s' "$CMD" | grep -qiE '(^|[;&| ])(make (deploy|release|build-release)|ssh [^|]*(deploy|compose|docker)|docker (push|compose -H|context use)|kubectl (apply|rollout)|helm (upgrade|install)|ansible-playbook|terraform apply)'; then
  fresh deploy || block "deployment command: $CMD" deploy
fi
exit 0

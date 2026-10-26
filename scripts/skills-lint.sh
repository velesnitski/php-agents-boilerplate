#!/usr/bin/env bash
# Lint the agent configuration so that what the files promise is what the harness can do:
#   - every SKILL.md has name, description and version in its frontmatter
#   - every agent has name, description, model, tools and maxTurns
#   - tools named in `allowed-tools` and agent `tools` exist (built-ins or MCP servers from .mcp.json)
#   - skills.lock lists every skill with its version (so a prompt change is a visible diff)
# Usage: scripts/skills-lint.sh [--write-lock]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
BUILTIN="Read Write Edit MultiEdit Glob Grep Bash Agent WebFetch WebSearch TodoWrite NotebookEdit Task"
MCP=""; [ -f .mcp.json ] && MCP=$(sed -n 's/^\s*"\([a-zA-Z0-9_-]*\)": *{/\1/p' .mcp.json | tr '\n' ' ')
fail=0; lock=""
front() { awk 'NR==1 && $0!="---"{exit} NR>1 && $0=="---"{exit} NR>1{print}' "$1"; }
for f in .claude/skills/*/SKILL.md; do
  fm=$(front "$f"); name=$(printf '%s\n' "$fm" | sed -n 's/^name: *//p'); ver=$(printf '%s\n' "$fm" | sed -n 's/^version: *//p')
  [ -n "$name" ] && printf '%s\n' "$fm" | grep -q '^description:' || { echo "FAIL $f: name/description missing"; fail=1; }
  [ -n "$ver" ] || { echo "FAIL $f: version missing"; fail=1; }
  for t in $(printf '%s\n' "$fm" | sed -n 's/^allowed-tools: *//p' | tr ',' ' '); do
    base="${t%%(*}"; base="${base%%:*}"
    case " $BUILTIN " in *" $base "*) continue;; esac
    case "$base" in mcp__*) srv=$(printf '%s' "$base" | cut -d_ -f3); case " $MCP " in *" $srv "*) continue;; esac; echo "FAIL $f: allowed-tools names MCP server '$srv' which .mcp.json does not define"; fail=1;; *) echo "FAIL $f: unknown tool '$t'"; fail=1;; esac
  done
  lock="$lock$name $ver"$'\n'
done
for f in .claude/agents/*.md; do
  fm=$(front "$f")
  for k in name description model tools maxTurns; do printf '%s\n' "$fm" | grep -q "^$k:" || { echo "FAIL $f: $k missing"; fail=1; }; done
done
if [ "${1:-}" = "--write-lock" ]; then printf '%s' "$lock" | sort > skills.lock; echo "skills.lock written";
elif [ -f skills.lock ]; then diff <(printf '%s' "$lock" | sort) skills.lock >/dev/null || { echo "FAIL skills.lock is stale: run scripts/skills-lint.sh --write-lock and commit it"; fail=1; }
else echo "FAIL skills.lock missing: run scripts/skills-lint.sh --write-lock"; fail=1; fi
[ "$fail" = 0 ] && echo "skills-lint: ok" || exit 1

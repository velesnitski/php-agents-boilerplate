#!/usr/bin/env bash
# Record a human approval for one guarded category: deploy | migrate | destroy.
# Writes .claude/approvals/<category>.ok with the approver and the proposal it approves; the guard
# hook accepts it for 15 minutes, then the agent has to ask again. Approvals are local and
# gitignored, so an approval never travels with a commit.
# Usage: scripts/approve.sh deploy [path/to/proposal.md]
set -euo pipefail
CAT="${1:-}"; PROPOSAL="${2:-}"
case "$CAT" in deploy|migrate|destroy) ;; *) echo "usage: scripts/approve.sh deploy|migrate|destroy [proposal.md]"; exit 1 ;; esac
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; mkdir -p "$ROOT/.claude/approvals"
if [ -n "$PROPOSAL" ]; then
  [ -f "$PROPOSAL" ] || { echo "proposal not found: $PROPOSAL"; exit 1; }
  echo "--- proposal: $PROPOSAL"; sed -n '1,40p' "$PROPOSAL"; echo "---"
fi
printf 'Approve %s for the next 15 minutes? [y/N] ' "$CAT"; read -r ans
[ "$ans" = "y" ] || { echo "not approved"; exit 1; }
{ echo "category: $CAT"; echo "by: $(git config user.name 2>/dev/null || whoami)"; echo "at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"; [ -n "$PROPOSAL" ] && echo "proposal: $PROPOSAL (sha256 $(shasum -a 256 "$PROPOSAL" | cut -c1-16))"; } > "$ROOT/.claude/approvals/$CAT.ok"
echo "approved: $CAT (expires in 15 min)"

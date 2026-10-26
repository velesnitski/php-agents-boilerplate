#!/usr/bin/env bash
# PostToolUse formatter for Edit|Write: runs Laravel Pint on the PHP file that was just written,
# so style never reaches a pull request and no agent spends turns on it. Silent when Pint is
# not installed or the file is not PHP.
set -u
INPUT=$(cat)
FILE=$(printf '%s' "$INPUT" | python3 -c 'import json,sys; d=json.load(sys.stdin); print((d.get("tool_input") or {}).get("file_path",""))' 2>/dev/null)
case "$FILE" in *.php) ;; *) exit 0 ;; esac
ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
if [ -x "$ROOT/vendor/bin/pint" ]; then
  "$ROOT/vendor/bin/pint" --quiet "$FILE" >/dev/null 2>&1 || true
fi
exit 0

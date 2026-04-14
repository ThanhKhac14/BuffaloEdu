#!/bin/bash
# BuffaloEdu — Session End Hook
set -euo pipefail

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.sessionId // "unknown"' 2>/dev/null || echo "unknown")
LOG_DIR="${LOG_DIR:-logs/copilot}"
mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/session-$(date +%Y%m%d).log"

echo "SESSION END   : $(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> "$LOG"
echo "Session ID    : $SESSION_ID" >> "$LOG"

CHANGED=$(git diff --name-only HEAD 2>/dev/null || echo "")
STAGED=$(git diff --cached --name-only 2>/dev/null || echo "")
ALL=$(echo "$CHANGED"$'\n'"$STAGED" | sort -u | grep -v '^$' || true)

if [ -n "$ALL" ]; then
  echo "Files changed :" >> "$LOG"
  echo "$ALL" | sed 's/^/  - /' >> "$LOG"
else
  echo "Files changed : none" >> "$LOG"
fi
echo "────────────────────────────────────────" >> "$LOG"
exit 0

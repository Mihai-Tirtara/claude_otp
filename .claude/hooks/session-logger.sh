#!/bin/bash
# .claude/hooks/session-logger.sh
# Lightweight post-tool logger for tracking tool usage per session
# Replaces the broken tsc-cache tool tracker

set -e

LOG_DIR="$CLAUDE_PROJECT_DIR/.claude/logs"
mkdir -p "$LOG_DIR"

DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M:%S)

# Read tool info from stdin
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown"' 2>/dev/null)

# Skip if jq failed
if [[ "$TOOL_NAME" == "unknown" ]]; then
  exit 0
fi

# Extract detail based on tool type
case "$TOOL_NAME" in
  Bash)
    DETAIL=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null | head -1 | cut -c1-120)
    ;;
  Skill)
    DETAIL=$(echo "$INPUT" | jq -r '.tool_input.skill // ""' 2>/dev/null)
    ;;
  Glob|Grep)
    DETAIL=$(echo "$INPUT" | jq -r '.tool_input.pattern // ""' 2>/dev/null)
    ;;
  *)
    DETAIL=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""' 2>/dev/null)
    ;;
esac

# Log format: TIME|TOOL|DETAIL
echo "$TIME|$TOOL_NAME|$DETAIL" >> "$LOG_DIR/tools-$DATE.log"

exit 0


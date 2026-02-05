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
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""' 2>/dev/null)

# Skip if jq failed
if [[ "$TOOL_NAME" == "unknown" ]] && [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# Log format: TIME|TOOL|FILE (file is optional)
if [[ -n "$FILE_PATH" ]]; then
  echo "$TIME|$TOOL_NAME|$FILE_PATH" >> "$LOG_DIR/tools-$DATE.log"
else
  echo "$TIME|$TOOL_NAME|" >> "$LOG_DIR/tools-$DATE.log"
fi

exit 0

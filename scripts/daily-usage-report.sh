#!/bin/bash
# daily-usage-report.sh
# Run via cron: 0 0 * * * /path/to/daily-usage-report.sh
# Aggregates tool usage from session logger and generates a report

set -e

# CONFIGURE THESE
PROJECT_DIR="${1:-/path/to/otp}"
LOG_DIR="$PROJECT_DIR/.claude/logs"
REPORT_DIR="$LOG_DIR/reports"

mkdir -p "$REPORT_DIR"

YESTERDAY=$(date -d "yesterday" +%Y-%m-%d 2>/dev/null || date -v-1d +%Y-%m-%d)
TOOL_LOG="$LOG_DIR/tools-$YESTERDAY.log"

if [[ ! -f "$TOOL_LOG" ]]; then
  echo "No tool log for $YESTERDAY"
  exit 0
fi

TOTAL_CALLS=$(wc -l < "$TOOL_LOG")
FIRST_CALL=$(head -1 "$TOOL_LOG" | cut -d'|' -f1)
LAST_CALL=$(tail -1 "$TOOL_LOG" | cut -d'|' -f1)

# Tool breakdown
TOOL_BREAKDOWN=$(cut -d'|' -f2 "$TOOL_LOG" | sort | uniq -c | sort -rn)

# Files most touched
FILE_BREAKDOWN=$(cut -d'|' -f3 "$TOOL_LOG" | grep -v '^$' | sort | uniq -c | sort -rn | head -10)

# Read vs Write ratio
READ_COUNT=$(cut -d'|' -f2 "$TOOL_LOG" | grep -cE '^(Read|View|Grep|Glob)$' || echo 0)
WRITE_COUNT=$(cut -d'|' -f2 "$TOOL_LOG" | grep -cE '^(Edit|MultiEdit|Write)$' || echo 0)

cat > "$REPORT_DIR/report-$YESTERDAY.md" << EOF
# Usage Report: $YESTERDAY

- **Total tool calls**: $TOTAL_CALLS
- **Session window**: $FIRST_CALL — $LAST_CALL
- **Read calls**: $READ_COUNT | **Write calls**: $WRITE_COUNT

## Tool Breakdown
\`\`\`
$TOOL_BREAKDOWN
\`\`\`

## Most Touched Files (top 10)
\`\`\`
$FILE_BREAKDOWN
\`\`\`
EOF

echo "Report written to $REPORT_DIR/report-$YESTERDAY.md"

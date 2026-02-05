#!/bin/bash
# archive-worklogs.sh
# Run via cron: 0 0 * * 0 /path/to/archive-worklogs.sh (weekly)
# Moves worklogs older than 7 days to archive

set -e

PROJECT_DIR="${1:-/path/to/otp}"
WORKLOG_DIR="$PROJECT_DIR/.claude/worklogs"
ARCHIVE_DIR="$WORKLOG_DIR/archive"

mkdir -p "$ARCHIVE_DIR"

COUNT=$(find "$WORKLOG_DIR" -maxdepth 1 -name "*.md" -mtime +7 | wc -l)

if [[ "$COUNT" -gt 0 ]]; then
  find "$WORKLOG_DIR" -maxdepth 1 -name "*.md" -mtime +7 -exec mv {} "$ARCHIVE_DIR/" \;
  echo "Archived $COUNT worklogs to $ARCHIVE_DIR"
else
  echo "No worklogs to archive"
fi

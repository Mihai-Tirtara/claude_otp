---
name: session-log
description: Log session summary for tracking and improvement
---

Gather session info:
```bash
BRANCH=$(git branch --show-current)
COMMIT_COUNT=$(git log master..HEAD --oneline 2>/dev/null | wc -l)
FILES_CHANGED=$(git diff --stat master..HEAD 2>/dev/null | tail -1)
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M)
```

Find the active worklog in `.claude/worklogs/` (most recently modified).

Create or append to `.claude/logs/sessions.md`:

```markdown
## $DATE $TIME — $BRANCH
- **Issue**: [from worklog filename]
- **Commits**: $COMMIT_COUNT
- **Changes**: $FILES_CHANGED
- **Status**: [completed / in-progress / blocked]
- **Notes**: [1 line — what was accomplished or what's blocking]
```

Rules:
- Append, never overwrite
- Keep each entry to exactly these fields
- If no worklog found, still log the git stats
- Don't add commentary or suggestions

---
name: fetch-issue
description: Fetch a YouTrack issue and create the worklog file
argument-hint: "OTP-1234"
---

Fetch issue $ARGUMENTS from YouTrack:

```bash
curl -s -H "Authorization: Bearer $YOUTRACK_TOKEN" \
  "https://one-touch-pipeline.myjetbrains.com/issues/$ARGUMENTS?fields=idReadable,summary,description,customFields(name,value(name))" 
```

From the response, extract:
- **Title**: `summary` field
- **What happens?**: `description` field (trim to essentials — drop boilerplate)
- **What should happen?**: `acceptance criteria` field (trim to essentials — drop boilerplate)
- **To-DO**: if present in description, extract them

Create the file `.claude/worklogs/$ARGUMENTS-worklog.md` using this exact template:

```markdown
# $ARGUMENTS: [title from YouTrack]

## Issue
[2-5 lines description. What needs to happen, acceptance criteria and TO-DO in list format. No copy-paste of entire description.]

## Approach
[Leave empty — filled by /plan]

## Tasks
[Leave empty — filled by /plan]

## Progress
[Leave empty — updated during implementation]

## Review Notes
[Leave empty — filled by /review]
```

Rules:
- If curl fails, tell me and suggest checking $YOUTRACK_TOKEN
- Do NOT add implementation speculation
- Do NOT read any codebase files yet
- Keep the Issue section under 5 lines
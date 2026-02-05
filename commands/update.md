---
name: update
description: Update worklog progress based on actual git changes
argument-hint: "OTP-1234 (or leave empty to auto-detect)"
---

Find the worklog:
- If $ARGUMENTS is provided, read `.claude/worklogs/$ARGUMENTS-worklog.md`
- Otherwise, find the most recently modified file in `.claude/worklogs/`

Run:
```bash
git diff --stat master..HEAD
```

Compare the changed files against the Tasks section in the worklog.

Update the worklog:

**## Tasks** — Check off completed items:
```
- [x] Modify X in FooService.groovy ✅
- [ ] Add test in FooServiceSpec.groovy (in progress)
- [ ] Update GSP template
```

**## Progress** — Append a brief status line:
```
**[date]**: Completed FooService changes. Tests next.
```

Rules:
- Do NOT regenerate the entire worklog
- Only update Tasks checkboxes and append to Progress
- Do NOT read the full diff — `--stat` is enough
- If new tasks were discovered during implementation, add them to Tasks
- Keep Progress entries to one line each

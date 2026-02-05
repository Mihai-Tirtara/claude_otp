---
name: plan
description: Create implementation plan from the worklog
argument-hint: "OTP-1234 (or leave empty to auto-detect)"
---

Find the worklog:
- If $ARGUMENTS is provided, read `.claude/worklogs/$ARGUMENTS-worklog.md`
- Otherwise, find the most recently modified file in `.claude/worklogs/`

Enter plan mode. Use grep and find to understand the codebase. Do NOT read entire files unless under 100 lines.

Investigate:
1. Which files need to change — use `grep -rn` and `find` to locate them
2. What the minimal change set is — fewest files touched
3. What tests are needed — check existing test patterns with `find src/test -name "*Spec.groovy" | head -20`

Update the worklog:

**## Approach** — Fill in with under 50 words. No code. Just the strategy.

**## Tasks** — Fill in as checkbox items:
```
- [ ] Modify X in grails-app/services/FooService.groovy
- [ ] Add test in src/test/groovy/FooServiceSpec.groovy
- [ ] Update GSP template grails-app/views/foo/index.gsp
```

Rules:
- Each task = one file or one logical change
- Include the file path in each task
- Do NOT write any implementation code
- Do NOT generate code snippets or pseudo-code
- If a Brainstorm section exists, use the selected approach

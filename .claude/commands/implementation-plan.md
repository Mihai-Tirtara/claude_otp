1---
name: plan
description: Create implementation plan 
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

Write the plan to `.claude/worklogs/$ARGUMENTS-worklog.md` with these sections:

**## Context** — Summarize the problem being solved. What's broken or missing, and why this change is needed. Keep it concise (2-4 sentences).

**## Approach** — The high-level strategy. No code, just describe the approach in plain language.

**## Changes** — Checkbox items, one per file or logical change. Each item has the file path as header and nested bullet points describing the specific modifications:
```
- [ ] `grails-app/services/de/dkfz/tbi/otp/ngsdata/FooService.groovy`
  - Add new method `doSomething(Project project)`:
    - Case A → behavior X
    - Case B → behavior Y
  - Modify `existingMethod()` to accept new parameter

- [ ] `src/test/groovy/de/dkfz/tbi/otp/ngsdata/FooServiceSpec.groovy`
  - Add test cases for `doSomething`: case A, case B, edge case C
  - Update existing test to pass new parameter
```

**## Verification** — List the specific commands to verify the changes:
```
- Run unit tests: `./gradlew test --tests "*FooServiceSpec*"`
- Run integration tests: `./gradlew integrationTest --tests "*FooServiceIntegrationSpec*"`
- Run CodeNarc: `./devScripts/codenarc-changed-files.sh`
```

Rules:
- Each checkbox = one file or one logical change
- Include the full file path in each checkbox
- Nested bullets describe *what* changes, not *how* (no code snippets)
- Do NOT write any implementation code or pseudo-code
- If a Brainstorm section exists, use the selected approach
- Include relevant tables or matrices if they clarify requirements (e.g. permission matrices, state transitions)

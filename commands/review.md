---
name: review
description: Self-review changes before creating a merge request
argument-hint: "OTP-1234 (or leave empty to auto-detect)"
---

Find the worklog:
- If $ARGUMENTS is provided, read `.claude/worklogs/$ARGUMENTS-worklog.md`
- Otherwise, find the most recently modified file in `.claude/worklogs/`

Run:
```bash
git diff --stat master..HEAD
git diff master..HEAD
```

Review the diff against these criteria:

1. **Scope check**: Does every changed file relate to a task in the worklog? Flag anything that doesn't.
2. **OTP coding guidelines**: Check the coding-guidelines skill if not already loaded.
3. **Groovy conventions**: No Java-style getters when Groovy property access works. Closures over anonymous classes. GString where appropriate.
4. **Test coverage**: Is there a Spec for every new service method or controller action?
5. **CodeNarc**: Run `./devsScripts/codenarc-changed-files.sh` and report results.
6. **GSP changes**: Check for XSS (unescaped `${}`), missing `<g:message>` for i18n.
7. **Domain changes**: If domain classes changed, is there a migration?

For each issue found, output:
```
🔴 MUST-FIX | grails-app/services/FooService.groovy:42 | Missing null check on barService call
🟡 SHOULD-FIX | src/test/groovy/FooSpec.groovy:15 | Test only covers happy path
🟢 NITPICK | grails-app/views/foo/index.gsp:8 | Could use <g:message> for this string
```

Append all findings to the worklog under `## Review Notes`.

If no issues found, write "Review passed — no issues found" in Review Notes.

Rules:
- Use grep to check specific lines, don't re-read entire files you already saw
- Be strict on 🔴, generous on 🟢
- Don't flag style issues that CodeNarc already catches

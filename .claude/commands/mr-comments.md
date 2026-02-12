---
name: mr-comments
description: Fetch and rank GitLab MR comments by severity
argument-hint: "MR_NUMBER (e.g., 123)"
---

Fetch comments for merge request $ARGUMENTS:

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "https://gitlab.com/api/v4/projects/one-touch-pipeline/otp/merge_requests/$ARGUMENTS/notes?per_page=100"
```

Filter the response:
- Remove system-generated notes (`"system": true`)
- Remove resolved threads

For each comment, determine severity:
- 🔴 **MUST-FIX**: Bug, logic error, security issue, missing test, breaking change
- 🟡 **SHOULD-FIX**: Code style violation, naming issue, missing edge case, unclear code
- 🟢 **NITPICK**: Formatting, minor suggestion, alternative approach that's not clearly better

Output grouped by severity:

```
## 🔴 Must Fix (2)
1. [Author] Line 42 of FooService.groovy — "Null pointer if bar is empty"
2. [Author] Line 15 of FooSpec.groovy — "This test doesn't assert anything"

## 🟡 Should Fix (1)
1. [Author] Line 8 of index.gsp — "Use g:message for i18n"

## 🟢 Nitpicks (1)
1. [Author] Line 3 of FooService.groovy — "Consider renaming to processBar"
```

Then ask: "Which items do you want me to address? (all / must-fix only / specific numbers)"

Rules:
- If curl fails, check $GITLAB_TOKEN
- If no comments found, say "No open comments on MR $ARGUMENTS"
- Don't start fixing anything until I confirm which items to address

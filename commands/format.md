---
name: format
description: Format changed files
---

Get list of changed files:
```bash
git diff --name-only master..HEAD | grep -E '\.(groovy|gsp|gradle)$'
```

For Groovy files, check formatting against project conventions.
For GSP files, check indentation consistency.

Report what would change. Ask before applying.

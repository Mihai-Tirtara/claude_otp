---
name: lint
description: Run CodeNarc linting on the project
---

Run:
```bash
./devScrips/codenarc-changed-files.sh 2>&1
```

If violations are found:
- List each violation with file, line, rule name, and message
- Group by severity (priority 1 = error, 2 = warning, 3 = info)
- Ask before fixing: "Found X violations. Fix them?"

If clean, say "CodeNarc passed — no violations."

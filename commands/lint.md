---
name: lint
description: Run CodeNarc and ESLint linting on the project
---

## Groovy (CodeNarc)

Run:
```bash
./devScrips/codenarc-changed-files.sh 2>&1
```

If violations are found:
- List each violation with file, line, rule name, and message
- Group by severity (priority 1 = error, 2 = warning, 3 = info)
- Ask before fixing: "Found X violations. Fix them?"

If clean, say "CodeNarc passed — no violations."

## JavaScript (ESLint)

Run:
```bash
./gradlew eslint 2>&1
```

If violations are found:
- List each violation with file, line, rule name, and message
- Ask before fixing: "Found X violations. Fix them?"

If clean, say "ESLint passed — no violations."

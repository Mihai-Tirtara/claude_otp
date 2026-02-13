---
name: warn-lint-after-changes
enabled: true
event: file
conditions:
  - field: file_path
    operator: regex_match
    pattern: \.(groovy|js|gsp)$
action: warn
---

**Reminder: Run linting after code changes!**

You just modified a Groovy or JavaScript file. Before finishing, run the `/lint` command to check for violations:

- **Groovy** (CodeNarc): `./devScripts/codenarc-changed-files.sh 2>&1`
- **JavaScript** (ESLint): `./gradlew eslint 2>&1`

Do NOT skip this step — CodeNarc and ESLint must pass before finishing.

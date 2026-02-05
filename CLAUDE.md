**IMPORTANT**: DO NOT UNDER ANY CIRCUMSTANCE MAKE CODE MODIFICATION WITHOUT ASKING FOR USER PERMISSION.

## Stack
Grails 6 / Groovy 3 / Spock tests / Gradle / CodeNarc / GitLab / YouTrack

## File Reading Rules
- NEVER read an entire file unless it's under 50 lines or explicitly asked
- Use `grep -n` or `rg` to find relevant sections first
- For Grails services: grep for method name before reading the file
- For GSP templates: grep for the specific tag/section/div
- For domain classes: grep for the field or constraint name
- For controllers: grep for the action name
- Prefer `head -n` / `tail -n` to read specific line ranges after grepping

## Code Style
- Follow existing patterns in the file being edited
- Groovy over Java idioms (use `def`, closures, GString)
- CodeNarc must pass — run `./devScripts/codenarc-changed-files.sh` before finishing
- Spock specifications for all tests

## Planning & Documentation
- All worklogs go in `.claude/worklogs/`
- One file per issue: `OTP-XXXX-worklog.md`
- No speculative code snippets.
- Tasks = concrete file-level actions
- 
## Key Directories
- `grails-app/controllers/` — Controllers
- `grails-app/services/` — Business logic
- `grails-app/domain/` — Domain classes
- `grails-app/views/` — GSP templates
- `src/test/groovy/` — Spock tests
- `src/test-helper/groovy/` — Test utilities
- `migrations/` — Database migrations
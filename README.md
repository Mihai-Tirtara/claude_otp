# Claude Code project configuration for the OTP (One Touch Pipeline) bioinformatics platform — Grails 6 / Groovy 3 / Spock.

## Root Files

### `CLAUDE.md`
Project instructions loaded into every Claude Code session. Defines the tech stack (Grails 6, Groovy 3, Spock, Gradle, CodeNarc, GitLab, YouTrack), enforces file-reading rules to avoid loading entire files, mandates CodeNarc compliance, and maps the key directories of the parent OTP codebase.

### `settings.json`
Claude Code project settings. Grants blanket permissions for Edit, Write, MultiEdit, NotebookEdit, and Bash tools. Registers two hooks: `skill-router.sh` on `UserPromptSubmit` (pre-prompt skill suggestions) and `session-logger.sh` on `PostToolUse` (tool usage tracking).

### `settings.local.json`
Local plugin configuration. Enables three official Claude plugins: `code-review`, `claude-md-management`, and `hookify`.

## `commands/`
Slash command definitions that Claude Code expands into structured prompts when invoked.

### `archive-logs.md`
Runs the `archive-worklogs.sh` script to move stale worklogs and tool logs into an archive directory.

### `brainstorm.md`
Generates 2–3 distinct solution approaches for a YouTrack issue. Reads the active worklog, explores the relevant codebase area, and appends a `## Brainstorm` section with named approaches, each having a one-line "How" and a "Tradeoff" summary.

### `daily-report.md`
Runs the `daily-usage-report.sh` script to aggregate the previous day's tool usage into a markdown report.

### `fetch-issue.md`
Fetches a YouTrack issue via the REST API, extracts title/description/acceptance criteria, and scaffolds a new worklog file at `.claude/worklogs/OTP-XXXX-worklog.md` with empty sections for Approach, Tasks, Progress, and Review Notes.

### `format.md`
Lists Groovy, GSP, and Gradle files changed since `master`, checks formatting against project conventions, and reports what would change before applying any modifications.

### `implementation-plan.md`
Duplicate of `plan.md`. Creates a structured implementation plan from a worklog: enters plan mode, investigates affected files via grep/find, and writes Context, Approach, Changes (file-level checkboxes), and Verification sections to the worklog.

### `lint.md`
Runs CodeNarc (`codenarc-changed-files.sh`) and ESLint (`./gradlew eslint`) against the project. Groups violations by severity and asks for confirmation before applying fixes.

### `mr-comments.md`
Fetches GitLab merge request comments via the API, filters out system notes and resolved threads, classifies each comment as MUST-FIX / SHOULD-FIX / NITPICK, and presents them grouped by severity for selective resolution.


### `review.md`
Self-review command that diffs `master..HEAD`, checks scope alignment with the worklog, validates Groovy conventions, test coverage, CodeNarc compliance, GSP XSS safety, i18n usage, and migration presence. Outputs findings as severity-tagged items and appends them to the worklog under `## Review Notes`.

### `session-log.md`
Captures end-of-session metadata (branch, commit count, files changed, status) and appends a structured entry to `.claude/logs/sessions.md` for historical tracking.

### `update.md`
Compares `git diff --stat master..HEAD` against the worklog's task list, checks off completed items, and appends a one-line progress entry with the current date.

## `hooks/`
Shell scripts triggered by Claude Code lifecycle events.

### `skill-router.sh`
Pre-prompt hook fired on `UserPromptSubmit`. Parses the user's prompt for keywords (implement, test, review, lint, GSP, etc.) and suggests relevant skill resource files to load. Logs each suggestion to `.claude/logs/tools-DATE.log`.


### `session-logger.sh`
Post-tool-use hook fired after every tool invocation. Extracts the tool name and a context-dependent detail (command for Bash, pattern for Grep/Glob, file path for others) and appends a timestamped line to `.claude/logs/tools-DATE.log`.

### `hookify.lint-after-changes.local.md`
Hookify plugin rule that triggers a warning whenever a `.groovy`, `.js`, or `.gsp` file is modified, reminding the user to run CodeNarc and ESLint before finishing.

## `scripts/`
Standalone shell scripts intended for manual or cron-based execution.

### `archive-worklogs.sh`
Moves worklog markdown files older than 7 days from `.claude/worklogs/` into an `archive/` subdirectory. Designed for weekly cron execution.

### `daily-usage-report.sh`
Aggregates the previous day's tool log into a markdown report containing total call count, session time window, read/write ratio, tool breakdown, and the top 10 most-touched files. Writes the report to `.claude/logs/reports/`.

## `skills/`
Skill definitions and domain knowledge resources that Claude Code loads contextually.

### `SKILL.md`
Main skill document for OTP development. Covers MVC architecture (controllers, services, domains, GSP views), GORM query preferences, Spring Security annotations, Spock testing patterns, workflow orchestration (OtpWorkflow, WorkflowStep, Jobs), CodeNarc/ESLint rules, common imports, anti-patterns, and reference services. Acts as the entry point that links to the four resource guides.


### `coding-guidelines/resources/`
Detailed reference guides loaded on demand by the skill router.

#### `coding_style_guide.md`
Documents CodeNarc and ESLint configuration. Lists links to CodeNarc rule index, custom OTP rules, and the active ruleset. Covers Gradle tasks for running and auto-fixing lint violations and IntelliJ ESLint plugin setup.

#### `testing_guide.md`
Comprehensive Spock testing reference. Covers naming conventions (Spec vs IntegrationSpec), test structure ordering, unit and integration test examples, mock/stub/spy usage with interaction syntax, data-driven testing, domain constraint testing, Cypress E2E setup, performance optimization strategies, and legacy mocking approaches to avoid.

#### `review_guide.md`
Seven-step code review checklist: understand the issue, review code changes for logic errors and readability, verify unit/integration tests and coverage, validate database migrations, test GUI functionality as a non-admin user, check CodeNarc compliance, and verify documentation.

#### `UI_development_guide.md`
UI development standards for OTP. Covers Bootstrap 4.6 layout system (application vs deprecated main), dependency versions (jQuery, DataTables, Select2), custom CSS guidelines (global vs local styles, LESS usage), Bootstrap Icons integration, and message handling patterns (flash messages vs JavaScript toast notifications via `$.otp.toaster`).

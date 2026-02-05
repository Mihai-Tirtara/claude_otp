---
name: brainstorm
description: Generate 2-3 solution approaches for the current issue
argument-hint: "OTP-1234 (or leave empty to auto-detect from worklogs)"
---

Find the worklog:
- If $ARGUMENTS is provided, read `.claude/worklogs/$ARGUMENTS-worklog.md`
- Otherwise, find the most recently modified file in `.claude/worklogs/`

Read the worklog's Issue section.

Use grep/find to understand the relevant area of the codebase. Do NOT read entire files.

Generate 2-3 distinct approaches. For each:

**[Approach name]** (3-5 words)
- **How**: 1-2 sentences
- **Tradeoff**: 1 sentence — what you gain vs what it costs

Append these to the worklog under a new `## Brainstorm` section (insert before `## Approach`).

Then ask me: "Which approach do you want to go with?"

Rules:
- No code snippets
- No implementation details beyond the "How" sentence
- Approaches must be genuinely different, not variations of the same thing
- If the issue is straightforward (single file change, obvious fix), say so and skip brainstorming

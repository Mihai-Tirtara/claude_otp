You are analyzing git diff changes to update project planning documents for task: TASK_NAME

**IMPORTANT**: The git diff represents the final state of implementation, anything written in the planning documents that does not reflect that can be safely removed.

## Your Task
Review the git diff and update the planning documents to reflect:
1. **Completed work**: Mark tasks as done, update progress indicators
2. **New implementations**: Document new files, functions, or components created
3. **Changes to existing code**: Note modifications to planned implementations
4. **New dependencies or decisions**: Add any new libraries, tools, or architectural decisions

## Git Diff Statistics:
\$(git diff --stat BASE_BRANCH...CURRENT_BRANCH)

## Current Planning Documents

### 1. Plan Document (TASK_NAME-plan.md)
\`\`\`markdown
\$(cat dev/active/TASK_NAME/TASK_NAME-plan.md)
\`\`\`

### 2. Context Document (TASK_NAME-context.md)
\`\`\`markdown
\$(cat dev/active/TASK_NAME/TASK_NAME-context.md)
\`\`\`

### 3. Tasks Document (TASK_NAME-tasks.md)
\`\`\`markdown
\$(cat dev/active/TASK_NAME/TASK_NAME-tasks.md)
\`\`\`

## Git Diff
\`\`\`diff
\$(git diff BASE_BRANCH...CURRENT_BRANCH)
\`\`\`

## Instructions
Carefully analyze the git diff and update each of the three planning documents.

**For the Plan Document:**
- Mark completed sections with appropriate indicators
- Update implementation details to match what was actually done

**For the Context Document:**
- Add all new files created (with their purpose)
- Update the list of key files if files were modified
- Document any new dependencies or libraries added
- Add new architectural decisions or design choices made
- Update any changed APIs or interfaces

**For the Tasks Document:**
- Mark completed tasks as done: \`- [x] Task name\`
- Add any new tasks discovered during implementation

**IMPORTANT**: Provide the COMPLETE updated content for each file, not just the changes.


Format your response EXACTLY as follows:

---PLAN-DOCUMENT-START---
[complete updated markdown content for plan document]
---PLAN-DOCUMENT-END---

---CONTEXT-DOCUMENT-START---
[complete updated markdown content for context document]
---CONTEXT-DOCUMENT-END---

---TASKS-DOCUMENT-START---
[complete updated markdown content for tasks document]
---TASKS-DOCUMENT-END---
"
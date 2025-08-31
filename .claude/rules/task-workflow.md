# Task Workflow Rules

Essential rules for code changes and task management in the main interactive thread.

## Core Principle: Task-First Development

> **Never make code modifications in the main interactive thread without creating a task first.**

Every code change must follow the structured workflow: specification → task → implementation.

## Main Thread Rules

### 1. No Direct Code Changes
- **Never** modify files directly in the main interactive thread
- **Never** create new files without explicit user approval
- **Always** create a task in `.doh/epics/{epic}/` before implementing

### 2. Exceptions - Explicit User Commands
Direct modifications are allowed ONLY when user explicitly indicates immediate action:

**Direct modification phrases:**
- "Modify X now" -> OK
- "Edit this file directly" -> OK
- "Make this change immediately" -> OK
- "Fix this right now" -> OK
- "Update this file" -> Ambiguaous: ask
- "Change this line to..." -> Ambiguous: ask
- "Add this to the file" -> Ambiguous: ask
- "Quick fix" -> ambigus ask
- "Just modify..." -> Ambiguous: ask
- "Simply change..." -> Ambiguous: ask

**Task avoidance indicators:**
- "Don't create a task for this"
- "No need for a task"
- "Skip the task creation"
- "Direct edit only"
- Any phrase showing urgency or immediacy without mentioning tasks

### 3. When in Doubt - Ask
If unclear whether to proceed with modifications:
```
Should I:
1. Create a task for this change first?
2. Modify the file immediately?
```

## User Interruptions

### 4. Task Description Update Rule - CRITICAL
**BEFORE** reacting to any user course correction or interruption:

1. **STOP** current work immediately
2. **UPDATE TASK STATUS** using helper commands (NO manual frontmatter editing):
   - Use `/doh:task-reopen <task_number>` for local tasks
   - Use `/doh:issue-reopen <task_number>` for GitHub-synced tasks
   - **NEVER** manually edit frontmatter status fields
3. **UPDATE TASK DESCRIPTION** - This is absolutely mandatory
   - Modify the task .md file to reflect the new direction
   - Update acceptance criteria to match new requirements
   - Document the course correction and reasoning
4. **THEN** acknowledge and proceed with the work

### 5. Pause on Interruptions
When user interrupts an ongoing task with corrections/clarifications:

1. **STOP** current work immediately
2. **UPDATE THE TASK DESCRIPTION** before doing anything else
3. **ACKNOWLEDGE** the interruption
4. **ASK** clarifying questions:
   - "Should I modify the current approach?"
   - "Do you want me to restart this task?"
   - "Should I create a new task for this change?"
5. **WAIT** for explicit direction before continuing

### 6. Interruption Response Template
```
⏸️ Pausing current work on [task/operation].

First, reopening task using helper command:
Using `/doh:task-reopen <task_number>` (or `/doh:issue-reopen <task_number>` if GitHub-synced)

Now updating task description to reflect this course correction:
Updating [task-file.md] with new requirements and acceptance criteria...

[After updating task description]

I understand you want to [summarize user's input].

Before I continue, please clarify:
- Should I modify the current approach?
- Do you want me to create a separate task for this?
- Should I restart or continue from where I left off?
```

## Agent vs Main Thread

### 7. Agent Autonomy
- **Agents** (via Task tool) have more autonomy for code changes
- **Agents** can modify files within their defined scope
- **Main thread** must follow task-first workflow

### 8. Task Creation Process
When code changes are needed:

1. **Analyze** what needs to be done
2. **Create** appropriate task in `.doh/epics/{epic}/`
3. **Ask** user to confirm task approach
4. **Launch** agent via Task tool OR get explicit approval for direct changes

## Examples

### ✅ Correct Approach
```
User: "Fix the bug in authentication"
Assistant: "I've identified the authentication issue. Should I:
1. Create a task in the current epic for this bug fix?
2. Create a new task file for this specific fix?

The fix involves modifying src/auth.js and adding validation."
```

### ❌ Incorrect Approach
```
User: "Fix the bug in authentication"
Assistant: [immediately modifies files without asking]
```

### ✅ Handling Interruptions
```
User: "Actually, also handle the session timeout case"
Assistant: "⏸️ Pausing current authentication fix.

I understand you want me to also handle session timeout.

Should I:
1. Expand the current task to include session timeout?
2. Create a separate task for session timeout handling?
3. Modify the current implementation approach?"
```

## Task Completion and Closure

### 8. Automatic Task Closure
When an agent completes work that fulfills a task's acceptance criteria:

1. **Agent** should **automatically close** the task
2. **Agent** should identify which task file corresponds to the completed work
3. **Agent** should use appropriate helper command:
   - `/doh:task-close <task_number>` for local tasks
   - `/doh:issue-close <task_number>` for GitHub-synced tasks
4. **Main thread** should also close tasks when work is complete
5. **NEVER** manually edit frontmatter for status changes

### 9. Task Closure Protocol
```
🎯 Task [number] is complete based on delivered work:
- [List of acceptance criteria met]
- [Files created/modified]

Closing task with `/doh:task-close [number]` (or `/doh:issue-close [number]` if GitHub-synced)
```

### 10. Agent Responsibility
**Agents must:**
- Track which tasks they are working on
- Monitor their own progress against acceptance criteria  
- Proactively suggest task closure when work is complete
- Help maintain accurate task status across the project

**Main thread should:**
- Accept agent suggestions for task closure
- Use suggested `/doh:issue-close` commands  
- Maintain oversight but rely on agent proactivity

## Implementation Notes

- Use TodoWrite tool to track task creation process
- Reference task files when launching agents
- Maintain audit trail of all decisions
- Keep main thread clean and strategic
- **Agents should proactively manage task lifecycle**

## Remember

The main interactive thread is for **planning and coordination**, not implementation. Let agents handle the code changes within well-defined task boundaries **and proactively manage task completion**.
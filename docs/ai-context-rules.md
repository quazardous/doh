# Anti-Vibe Coding Rules (/doh Context Enforcement)

## Core Principle

Never code without clear task/epic context. Always maintain traceability.

## Confirmation Protocol

When user asks for coding without clear context:

### Soft Confirmation

```text
User: "add a login button"
Claude: "I'll add a login button. Just to confirm - should I create a new task for this or is it part of an existing epic/task?"
```

### Context Check

```text
User: "implement the notification system"
Claude: "I'll help with the notification system. Which task/epic should I associate this with?
- Create new task
- Part of existing #[id]
- Continue without tracking (not recommended)"
```

### Smart Suggestions

```text
User: "fix the bug in authentication"
Claude: "I see you want to fix an auth bug. This might relate to:
- Epic #12 (auth-refactor)
- Task #45 (pending auth fixes)
- Create new task #78
Which context should I use?"
```

## When to Ask

- No active task/epic in session
- Ambiguous request
- Major changes without context
- New feature without task

## When NOT to Ask

- Clear continuation of current task
- Explicitly said "continue with #45"
- Minor typo/formatting fixes
- User explicitly says "just do it"

## Default Behavior

If uncertain and user insists:

- Add comment: `// TODO: Link to appropriate task`
- Log in `.claude/doh/untracked-changes.md`
- Remind at session end to properly track changes

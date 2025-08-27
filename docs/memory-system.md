# Memory Structure - Persistent Context

## Hierarchical Memory Organization

```
.doh/memory/                    # Project persistent memory (versioned)
├── active-session.json         # Current working context
├── project/                    # Global project memory
│   ├── conventions.md         # Project-wide coding conventions
│   ├── architecture.md        # Overall architecture decisions
│   ├── tech-stack.md         # Technology choices & reasons
│   └── patterns.md           # Recurring patterns identified
│
└── epics/                     # Epic-specific memory
    ├── notification-system/   # Epic-specific context
    │   ├── decisions.md      # Decisions made for this epic
    │   ├── context.md        # Business context & goals
    │   ├── learnings.md      # What worked/didn't work
    │   └── code-map.json     # Files touched, patterns used
    │
    └── user-dashboard/
        ├── decisions.md
        ├── context.md
        └── learnings.md
```

**Note**: Memory is now stored in `.doh/memory/` (versioned in Git) instead of `.claude/doh/memory/`. This enables:

- **Collaborative memory**: Shared across all team members
- **Worktree propagation**: Memory automatically available in Git worktrees
- **Version control**: Track memory evolution with Git history

## Memory Inheritance

**Hierarchy:**

```
Project Memory (global)
    ↓
Epic Memory (scoped)
    ↓
Feature Memory (if needed)
    ↓
Task Context (ephemeral)
```

## Example Memory Files

### project/conventions.md

```markdown
# Project Conventions (learned)

- Always use TypeScript for new files
- WebSocket handlers go in src/services/ws/
- Use existing notification queue (don't create new)
- Bootstrap 4 components only (no v5 migration yet)
- Commits must reference task ID
```

### epics/notification-system/decisions.md

```markdown
# Epic #12 Decisions

- Use Socket.io over raw WebSockets (decided #45)
- Redis for message queue (decided #46)
- Batch notifications every 5s for performance (#47)
- No push notifications in v1 (descoped #48)
```

### epics/notification-system/code-map.json

```json
{
  "epic_id": 12,
  "files_created": ["src/services/ws/handler.ts", "src/services/notification-queue.ts"],
  "files_modified": ["src/controllers/NotificationController.php", "assets/js/notifications.js"],
  "patterns_used": ["singleton_websocket", "redis_queue", "event_emitter"]
}
```

## Active Session Tracking

### active-session.json

```json
{
  "current_epic": 12,
  "current_task": 45,
  "working_directory": "/home/user/project",
  "branch": "feature/notification-#12",
  "memory_loaded": ["project/conventions.md", "epics/notification-system/decisions.md"],
  "session_started": "2024-01-20T10:00:00Z"
}
```

## Memory Loading Rules

1. **On epic focus** (`/doh:epic 12`):
   - Load all project/\* memories
   - Load specific epic memories
   - Load related epic memories if referenced

2. **On task work**:
   - Inherit epic memory
   - Check for similar completed tasks
   - Load relevant code patterns

3. **Memory updates**:
   - Auto-save new patterns discovered
   - Record decisions when made
   - Update after task completion

## Integration with Agent Context Protocol

The memory system integrates with the [Agent Context Protocol](agent-context-protocol.md) to provide autonomous agents
with complete context:

- **Context Bundle Loading**: Agents receive relevant memory files in their startup bundle
- **Memory Updates**: Agents can enrich project/epic memory during execution
- **Session Tracking**: Agent sessions are tracked in memory system
- **Learning Persistence**: Agent discoveries are preserved for future use

## Benefits

- **No repeated mistakes**: Remember what didn't work
- **Consistent decisions**: Apply previous choices
- **Faster onboarding**: Context is preserved
- **Smart suggestions**: Based on project patterns
- **Epic isolation**: Different epics can have different approaches
- **Autonomous Context**: Agents get complete context from memory system

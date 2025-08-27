# Agent Context Protocol

## Overview

The /doh system provides autonomous agents with structured context through a standardized protocol. This ensures agents
have complete project understanding while maintaining proper isolation and traceability.

## Context Bundle Format

### Initial Agent Context Bundle

When an agent is launched via `/doh:agent`, it receives a standardized context bundle:

```json
{
  "agent_session": {
    "id": "agent-{timestamp}-{task_id}",
    "created_at": "2024-08-27T10:00:00Z",
    "worktree_path": "../mrtroove-worktree-task-websocket-handler",
    "branch": "task/websocket-handler",
    "target": {
      "type": "task",
      "id": "45",
      "title": "WebSocket handler implementation",
      "description": "Implement real-time WebSocket handler for notifications",
      "status": "assigned_to_agent"
    }
  },
  "hierarchy": {
    "project": {
      "name": "MrTroove",
      "language": "fr",
      "working_directory": "/home/david/Private/dev/projects/mrtroove"
    },
    "epic": {
      "id": "12",
      "title": "Real-time Notification System",
      "path": ".doh/epics/notification-system/epic12.md"
    },
    "parent_feature": null,
    "dependencies": ["!23", "!67"]
  },
  "memory": {
    "project_conventions": {
      "path": ".doh/memory/project/conventions.md",
      "key_points": [
        "Always use TypeScript for new files",
        "WebSocket handlers go in src/services/ws/",
        "Use existing notification queue"
      ]
    },
    "epic_decisions": {
      "path": ".doh/memory/epics/notification-system/decisions.md",
      "key_decisions": ["Use Socket.io over raw WebSockets", "Redis for message queue", "Batch notifications every 5s"]
    },
    "patterns": {
      "path": ".doh/memory/epics/notification-system/code-map.json",
      "used_patterns": ["singleton_websocket", "redis_queue", "event_emitter"]
    }
  },
  "codebase_context": {
    "tech_stack": ["Symfony", "JavaScript", "TypeScript", "Bootstrap 4"],
    "build_system": "Webpack Encore",
    "test_commands": ["make front-develop-build", "php bin/console doctrine:migrations:migrate"],
    "relevant_files": ["src/services/notification/", "assets/js/notifications.js", "config/packages/messenger.yaml"]
  }
}
```

## Agent Memory Protocol

### 1. Context Loading on Agent Start

```bash
# Agent initialization sequence
1. Create worktree: `{project}-worktree-{type}-{name}`
2. Load project-index.json for target item
3. Build context bundle with hierarchy resolution
4. Load relevant memory files (project + epic)
5. Initialize agent-specific session tracking
```

### 2. Memory Access During Execution

**Read Operations:**

- Agent can read all project and epic memory
- Access to related tasks/features for pattern recognition
- Full codebase context through CLAUDE.md integration

**Update Operations:**

- Agent updates `.doh/memory/active-session.json` with progress
- Creates/updates epic-specific learnings and decisions
- Records new patterns discovered during implementation

### 3. Session State Management

**Agent Session File** (`.doh/memory/agent-sessions/{agent_id}.json`):

```json
{
  "agent_id": "agent-20240827-task45",
  "status": "active",
  "started_at": "2024-08-27T10:00:00Z",
  "target": { "type": "task", "id": "45" },
  "worktree": "../mrtroove-worktree-task-websocket-handler",
  "progress": {
    "phase": "implementation",
    "completed_subtasks": ["analysis", "design"],
    "current_focus": "coding",
    "files_modified": ["src/services/ws/handler.ts"]
  },
  "memory_updates": [
    {
      "file": ".doh/memory/epics/notification-system/learnings.md",
      "type": "pattern_discovered",
      "content": "Socket.io connection pooling improves performance"
    }
  ]
}
```

## Context Inheritance Rules

### 1. Hierarchical Context Loading

```text
Project Memory (always loaded)
    ↓
Epic Memory (if task belongs to epic)
    ↓
Feature Memory (if task belongs to feature)
    ↓
Related Tasks Memory (dependencies)
```

### 2. Context Scoping

- **Global Context**: Project conventions, architecture decisions
- **Epic Context**: Epic-specific decisions, patterns, learnings
- **Task Context**: Task-specific requirements, dependencies
- **Agent Context**: Agent session state, progress tracking

### 3. Conflict Resolution

- Epic-specific decisions override project defaults
- Agent updates are isolated to agent session until completion
- Memory conflicts are resolved through timestamp precedence

## Agent Communication Protocol

### 1. Status Updates

Agent periodically updates its session state:

```json
{
  "timestamp": "2024-08-27T10:30:00Z",
  "status": "in_progress",
  "progress": 0.6,
  "current_activity": "Implementing WebSocket authentication",
  "blockers": [],
  "discoveries": ["Existing auth middleware can be reused for WebSocket connections"]
}
```

### 2. Memory Enrichment

Agent contributes back to project memory:

```json
{
  "type": "pattern_learned",
  "epic": "notification-system",
  "pattern": {
    "name": "websocket_auth_middleware",
    "description": "Reuse HTTP auth middleware for WebSocket connections",
    "files": ["src/services/ws/auth.ts"],
    "reusable": true
  }
}
```

### 3. Completion Handoff

When agent completes its task:

```json
{
  "agent_id": "agent-20240827-task45",
  "status": "completed",
  "deliverables": {
    "files_created": ["src/services/ws/handler.ts", "tests/ws/handler.test.ts"],
    "files_modified": ["src/controllers/NotificationController.php"],
    "commits": ["[#45] Implement WebSocket handler with auth"],
    "tests_passing": true
  },
  "memory_contributions": [
    "Added websocket_auth_middleware pattern to epic memory",
    "Updated project conventions with WebSocket testing patterns"
  ],
  "next_actions": ["Merge worktree back to main branch", "Update task status to completed", "Archive agent session"]
}
```

## Integration with /doh Commands

### 1. Agent Launch (`/doh:agent #45`)

```bash
1. Parse target (task #45)
2. Build context bundle from project-index.json
3. Create isolated worktree
4. Initialize agent with full context
5. Start autonomous execution
```

### 2. Context Updates During Execution

- Agent reads memory files as needed
- Updates session state continuously
- Enriches project/epic memory with learnings
- Maintains traceability through commit references

### 3. Agent Monitoring

- Human developers can check agent progress via session files
- Agent status visible in project-index.json
- Worktree isolation prevents conflicts with main development

## Benefits

### For Autonomous Agents

- **Complete Context**: Full project understanding from start
- **Isolated Execution**: No conflicts with human development
- **Memory Access**: Learn from previous implementations
- **Pattern Recognition**: Reuse existing solutions

### For Project Teams

- **Traceability**: Complete audit trail of agent decisions
- **Knowledge Preservation**: Agent learnings enrich project memory
- **Parallel Development**: Agents work in isolation
- **Quality Consistency**: Agents follow established conventions

### For /doh System

- **Scalability**: Multiple agents can work simultaneously
- **Learning**: System gets smarter with each agent execution
- **Integration**: Seamless with existing /doh workflows
- **Evolution**: Agent contributions improve future development

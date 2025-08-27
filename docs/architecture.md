# Architecture & Structure

## New Organization - System vs Project Separation

### 🆕 Structure

```text
.doh/                            # 📁 PROJECT CONTENT (versioned in Git)
├── project-index.json           # Unified index (replaces .cache)
├── prds/
│   └── prd{id}.md              # Project PRDs
├── epics/
│   ├── maintenance-general/     # Default Epic #0
│   │   └── epic0.md            # "Maintenance & General Tasks"
│   └── {epic-name}/            # Epic folders
│       └── epic{id}.md         # Epic definition
├── features/
│   └── {feature-name}/         # Feature folders
│       └── feature{id}.md      # Feature definition
├── tasks/
│   └── task{id}.md             # Centralized tasks
└── memory/                      # Project persistent memory
    ├── active-session.json      # Current session
    ├── project/                 # Global conventions
    │   ├── conventions.md      # Code standards
    │   └── architecture.md     # Architecture decisions
    └── epics/                   # Epic-specific memory
        └── {epic-name}/         # Epic-specific context

.claude/doh/                     # 📚 DOH SYSTEM (specs & templates)
├── README.md                    # Main documentation
├── TODO.md                      # System evolutions (moved to project root)
├── docs/                        # Detailed documentation
├── templates/                   # MD templates
├── commands/README.md           # Commands documentation
└── ai-context-rules.md          # AI context rules

.claude/commands/doh/            # ⚙️ IMPLEMENTATION (actual commands)
├── init.md                      # /doh:init
├── quick.md                     # /doh:quick
├── prd.md, epic.md, task.md    # Brainstorming
└── agent.md                     # /doh:agent
```

### ⚠️ Key Point: `.doh/` is Versioned

**IMPORTANT**: The `.doh/` folder is part of the Git repository and is therefore:

- ✅ **Versioned**: Complete traceability of PRDs, epics, tasks
- ✅ **Collaborative**: Shared among all developers
- ✅ **In worktrees**: Automatically present via Git
- ✅ **Mergeable**: Conflicts are handled by Git like code

## Folder Naming Convention

- **Epic folders**: Use descriptive names (e.g., `notification-system/`)
- **Feature folders**: Nested under epic, descriptive names (e.g., `email-notifications/`)
- **Files**: Always use local ID format (without ! in filename):
    - `prd{id}.md` for PRDs (!4 → prd4.md)
    - `epic{id}.md` for Epics (!0 → epic0.md, !2 → epic2.md)
    - `feature{id}.md` for Features (!5 → feature5.md)
    - `task{id}.md` for Tasks (!1 → task1.md, !3 → task3.md)
    - **Single global counter**: Epic #0, Task #1, Epic #2, Task #3...

### MD Headers with Synchronization

Each file contains a standardized header with sync state:

```markdown
# Task !123: WebSocket handler implementation

**Status**: Synced (or Local only / Modified) **Created**: 2024-08-27T11:00:00Z **Last Sync**: 2024-08-27T10:00:00Z  
**GitHub Issue**: https://github.com/user/repo/issues/456

## Description

[Task content...]
```

## ID System & Synchronization

### Dual ID System

The system uses a **dual ID system** to support synchronization with GitHub/GitLab:

#### ID Format

- **`!123`** → Local ID only (not yet synchronized)
- **`!123→#456`** → Local ID mapped to GitHub issue #456
- **`!123*→#456`** → Local ID modified since last sync (dirty)
- **`#456`** → GitHub issue imported (remote only)

#### Synchronization States

- **Local Only**: `!123` (dirty: timestamp, synced: null)
- **Synced Clean**: `!123→#456` (dirty: null, synced: timestamp)
- **Synced Dirty**: `!123*→#456` (dirty > synced timestamps)
- **Remote Only**: `#456` (imported from GitHub)

### Unified Index (`project-index.json`)

Replaces the old `.cache` + `.sync` system with a central file that manages:

- **IDs and metadata**: Types, titles, file paths
- **Hierarchy**: Parents, children, dependencies
- **Synchronization**: Local→remote mapping, dirty/synced states
- **Performance**: Dependency graph for fast updates

```json
{
  "metadata": {
    "version": "1.0.0",
    "project_name": "MrTroove",
    "language": "fr"
  },
  "counters": {
    "next_id": 4 // Global unique ID for all types (epic #0, task #1, epic #2, task #3...)
  },
  "items": {
    "!123": {
      "type": "task",
      "title": "WebSocket handler",
      "parent": "!45",
      "dependencies": ["!67"],
      "dirty": "2024-08-27T12:00:00Z",
      "synced": "2024-08-27T10:00:00Z",
      "remote_id": "#456",
      "remote_url": "https://github.com/user/repo/issues/456"
    }
  },
  "dependency_graph": {
    "!67": ["!123", "!124"]
  }
}
```

## Workflow & Traceability

Complete traceability chain:

```text
PRD → Epic → [Feature] → Task → Code → Commit → PR
```

### Note

Feature level is optional - tasks can be created directly from epics

1. **Brainstorming** → PRD (capture all ideas)
2. **PRD** → Epic(s) (major objectives)
3. **Epic** → Task(s) OR Feature(s) (direct tasks or logical grouping)
4. **Feature** → Task(s) (if features are used)
5. **Task** → Code (implementation with references)

## Traceability Standards

Every line of code must be linked to an issue:

- Code comments: `// #123: Implementation details`
- Commit messages: `[#123] Description of change`
- Pull Requests: Reference all completed issues
- File headers: Track which issues modified the file

Example:

```javascript
// #45: Add user notification system
// #67: Refactor for performance
function notifyUser(message) {
  // #45: Core notification logic
  ...
}
```

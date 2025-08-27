# DOH Project Structure

This directory contains the DOH (DevOps Organization Helper) project structure for task and epic management.

## Directory Structure

```text
.doh/
├── project-index.json          # Unified index and metadata
├── epics/quick/epic0.md        # Default Epic #0 for quick tasks
├── memory/                     # Persistent memory system
│   ├── project/               # Project-level patterns and decisions
│   ├── epics/                 # Epic-specific context and memory
│   └── agent-sessions/        # Agent session data
├── .gitignore                 # DOH-specific gitignore patterns
└── README.md                  # This file
```

## Getting Started

1. **Quick Task Creation**: Use `/doh:quick "task description"` to create tasks in Epic #0
2. **Epic Management**: Use `/doh:epic` for epic creation and management
3. **Agent Sessions**: Use `/doh:agent` for autonomous development workflows

## Key Concepts

- **Epic #0**: Default epic for quick tasks that don't need dedicated epics
- **Hierarchical Memory**: Context preserved at project, epic, and session levels
- **Unified Index**: Single source of truth in `project-index.json`
- **ID System**: Local IDs (!123) with optional GitHub sync (#456)

## Maintenance

- The DOH system is self-maintaining
- Use `/doh:init --health-check` for integrity validation
- Memory updates happen automatically during agent sessions

---

## Creation Notes

This structure was created from the DOH skeleton template

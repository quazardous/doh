# DOH Project Structure

This directory contains the DOH (DevOps Organization Helper) project structure for task and epic management.

## Directory Structure

```text
.doh/
├── project-index.json          # Unified index and metadata
├── config.ini                  # DOH configuration
├── epics/                      # Epic definitions and tracking
│   └── quick/epic0.md         # Default Epic #0 for quick tasks
├── analysis/                   # Generated analysis reports
│   ├── README.md              # Analysis documentation
│   ├── codebase-analysis.md   # Main codebase analysis report
│   ├── epic-suggestions.md    # DOH organization recommendations
│   ├── patterns-detected.md   # Architectural patterns analysis
│   └── team-insights.md       # Team collaboration insights
├── memory/                     # Persistent memory system
│   ├── project/               # Project-level context and decisions
│   │   ├── architectural-decisions.md
│   │   └── project-patterns.md
│   ├── epics/                 # Epic-specific memory and tracking
│   │   └── epic-{ID}/         # Individual epic contexts
│   └── agent-sessions/        # Development session artifacts
├── .gitignore                  # DOH-specific gitignore patterns
└── README.md                  # This file
```

## Getting Started

1. **Quick Task Creation**: Use `/doh:quick "task description"` to create tasks in Epic #0
2. **Epic Management**: Use `/doh:epic` for epic creation and management
3. **Agent Sessions**: Use `/doh:agent` for autonomous development workflows

## Key Concepts

- **Epic #0**: Default epic for quick tasks that don't need dedicated epics
- **Human-Readable Analysis**: Markdown reports optimized for developer consumption
- **Unified Index**: Single source of truth in `project-index.json`
- **Flat Structure**: Simple file organization for easy navigation
- **ID System**: Local IDs (!123) with optional GitHub sync (#456)

## Analysis System

The DOH analysis system uses **convention over configuration**:

### Templates
- Analysis templates: `.claude/doh/templates/analysis/`
- Core templates: `.claude/doh/templates/` (epic, task, feature, etc.)

### Generated Reports
- **`analysis/`**: All analysis reports generated here
- **`memory/project/`**: Project context and decisions
- **`memory/epics/`**: Epic-specific context and progress

### Conventions
- Templates in `templates/analysis/` → Reports in `analysis/`
- No configuration needed - uses standard filenames and locations

## Maintenance

- The DOH system is self-maintaining
- Use `/doh:init --health-check` for integrity validation
- Analysis reports generated when running `/doh:analyze`

---

## Creation Notes

This structure was created from the DOH skeleton template

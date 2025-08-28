# /doh System - Usage Guide for Claude

---
**Generated**: 2025-08-27T12:00:00Z  
**DOH Runtime Version**: 1.3.0 (Stable)  
**Status**: Production Ready for Project Usage  
**Feature Set**: Agent Context Protocol, Worktree Automation, Memory Updates, Skeleton Implementation, Centralized Dependencies

---

## Overview

The **/doh** system provides complete task traceability with the hierarchical workflow:

```
PRD → Epic → [Feature] → Task → Code
```

**Philosophy**: *"DOH!" - Context is obvious... once you have it.*

## Main Index

**`.doh/project-index.json`** - Single source of truth
```json
{
  "metadata": {
    "project_name": "your-project",
    "doh_version": "1.3.0",
    "schema_version": "1.0"
  },
  "items": {
    "tasks": {},
    "features": {},
    "epics": {
      "0": { "title": "Epic #0 - General Tasks", "file_path": "epics/quick/epic0.md" }
    },
    "prds": {}
  },
  "dependency_graph": {},
  "counters": { "next_task_id": 1 }
}
```

## Essential Commands

### Quick Creation
```bash
/doh:quick "description"  # Smart creation based on complexity
```
- **Simple** → Task in Epic #0
- **Complex** → Questions + Dedicated epic suggested

### Project Setup
```bash
/doh:init              # Initialize DOH system (uses skeleton)
/doh:init --health-check  # Validate project integrity
```

### Brainstorming
```bash
/doh:task [id]     # Explore a task
/doh:epic [id]     # Explore an epic  
/doh:feature [id]  # Explore a feature
/doh:prd [id]      # Explore a PRD
```

### Decomposition
```bash
/doh:prd-epics [prd_id]         # PRD → Epics
/doh:epic-tasks [epic_id]       # Epic → Tasks
/doh:epic-features [epic_id]    # Epic → Features
/doh:feature-tasks [feature_id] # Feature → Tasks
```

### Dependencies
```bash
/doh:dependency add 123 67     # Task 123 depends on Task 67
/doh:dependency list 123       # Show dependencies for item 123
/doh:dependency graph          # View full dependency graph
/doh:dependency validate       # Check for circular dependencies
```

### Task Intelligence
```bash
/doh:next [query]                    # AI-powered task recommendations
/doh:next "what should I work on?"   # Natural language queries
/doh:next --context=quick           # Filter by context (quick/docs/features/testing)
/doh:next --cache-only              # Ultra-fast mode from memory
```

### Pipeline Automation
```bash
/doh:changelog          # Update CHANGELOG.md with completed DOH tasks
/doh:lint              # Intelligent project linting with DOH validation
/doh:commit [task_id]  # Complete commit pipeline with task linking
```

### Autonomous Execution
```bash
/doh:agent [task_id]  # Launch agent with isolated worktree + full context
```

## Epic #0 - General Tasks

**ID**: `!0` - Default epic always available  
**Location**: `.doh/epics/quick/epic0.md`

### Auto Categories
- 🐛 **Bug** - Quick fixes
- ⚡ **Perf** - Spot optimizations
- 🔧 **Maintenance** - Refactoring, cleanup
- 📝 **Doc** - Documentation, comments

### Auto-graduation
**Threshold**: 6+ similar tasks → Dedicated epic suggested

## Mandatory Code Traceability

### In Code
```javascript
// DOH #123: Change description
function example() {
  // DOH #456: Feature-specific logic
}
```

### In Commits
```bash
git commit -m "[DOH #123] Description of change"
```

### In PRs
```markdown
## Completed Tasks
- [DOH #123] Authentication refactor
- [DOH #456] Performance optimization
```

## Dual ID System

| Type | Format | Example | Usage |
|------|--------|---------|-------|
| **Local** | `!123` | `!42` | Stable /doh internal ID |
| **GitHub** | `#456` | `#789` | ID after synchronization |

**Synchronization states**:
- `dirty`: Local change not synchronized
- `synced`: Synchronized with GitHub/GitLab

## File Structure

```
.doh/                      # Versioned in Git (created from skeleton)
├── project-index.json     # Unified index (source of truth)
├── .gitignore            # DOH-specific patterns
├── README.md             # Project DOH documentation
├── prds/                 # Product Requirements
├── epics/                # Organized epics
│   └── quick/
│       └── epic0.md      # Epic #0 ready to use
├── features/             # Optional depending on project
├── tasks/                # Task files
└── memory/               # Persistent memory system
    ├── project/          # Project-level patterns
    ├── epics/            # Epic-specific context
    └── agent-sessions/   # Agent session data
```

## Memory System

**Hierarchical Context**: Project → Epic → Agent Session

### Memory Storage
- **Project Memory**: Patterns, decisions, coding standards
- **Epic Memory**: Epic-specific context and learnings
- **Agent Sessions**: Persistent session data with memory updates

### Agent Memory Updates
```json
{
  "session_id": "agent-task-123",
  "memory_updates": {
    "patterns_discovered": ["API pagination pattern"],
    "decisions_made": ["Using JWT for auth"],
    "learnings": ["Database migration strategy"]
  }
}
```

### Task Intelligence Memory
**Location**: `.doh/memory/NEXT.md` - AI memory for intelligent task recommendations

- **Smart Prioritization**: Analyzes task dependencies, epic phases, and team workload
- **Natural Language Queries**: Pre-computed results for common queries
- **Pattern Learning**: Adapts to project and team working patterns
- **Performance Modes**: Standard analysis or ultra-fast memory-only responses

```bash
# Memory automatically maintained by /doh:next
# Manual refresh when needed:
/doh:next --refresh
```

## Workflow Types

### 1. Quick Hotfix
```bash
/doh:quick "fix typo in menu"
# → Task !123 created in Epic #0
# → Immediate development
```

### 2. Complex Feature
```bash
/doh:quick "implement user authentication"
# → Questions: OAuth? 2FA? Sessions?
# → Epic suggested with decomposition
```

### 3. Parallel Development
```bash
/doh:agent !123
# → Worktree `../project-worktree-task-123`
# → Full context bundle with memory
# → Autonomous agent develops
# → Memory enrichment during development
```

## Agent Context Protocol

**Complete JSON Context Bundles** for autonomous agents:

```json
{
  "task": { "id": "123", "title": "...", "description": "..." },
  "epic": { "id": "45", "context": "..." },
  "project_memory": { "patterns": [], "decisions": [] },
  "epic_memory": { "context": "...", "related_tasks": [] },
  "dependencies": { "depends_on": ["67"], "blocks": ["89"] },
  "codebase_context": { "relevant_files": [], "architecture": "..." }
}
```

## GitHub Synchronization

```bash
/doh:sync-github  # Bidirectional issues ↔ tasks
```

**Automatic headers**:
```markdown
# Task: Authentication Refactor
**DOH**: !123 | **GitHub**: [#456](https://github.com/user/repo/issues/456)
**Status**: In Progress | **Synced**: 2025-08-27T10:00:00Z
```

## Natural Language Support

```bash
# Equivalents
/doh:quick "create epic for user dashboard"
"I need an epic for the user dashboard feature"
"Let's create a new epic about dashboard"
```

## Critical Rules

1. **ALL modifications = /doh issue** (no orphan commits)
2. **Complete traceability** in code, commits, PRs
3. **Epic #0** for quick/maintenance tasks
4. **Worktrees** for isolated development
5. **project-index.json** = single source of truth
6. **Dependencies** tracked and validated
7. **Memory enrichment** during agent sessions

## Required Project Configuration

In `.claude/CLAUDE.md`:
```markdown
## Project Management System
This project uses the **/doh** system for complete task management.

📖 **DOH Documentation**: See `.claude/doh/inclaude.md`

### DOH Rules
- ALL modifications linked to /doh issue
- Comments: `// DOH #123: Description`
- Commits: `[DOH #123] Description`
```

## Performance Notes

- **project-index.json**: Loaded in memory at startup
- **Skeleton deployment**: Consistent initialization via `/doh:init`
- **Worktrees**: Complete isolation with memory context
- **Epic #0**: Avoids unnecessary epic creation
- **Memory system**: Persistent context across sessions
- **Dependency validation**: Prevents circular dependencies
- **Auto-sync**: GitHub sync can be automated

---

*For /doh internal architecture: see README.md*  
*For /doh system development: see docs/*
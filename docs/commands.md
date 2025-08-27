# Commands & Usage

## Commands & Natural Language

### Brainstorming Commands

- `/doh:prd [id]` - Brainstorm on a PRD (loads/creates prd{id}.md)
- `/doh:epic [id]` - Brainstorm on an epic (loads/creates epic{id}.md)
- `/doh:feature [id]` - Brainstorm on a feature (loads/creates feature{id}.md)
- `/doh:task [id]` - Brainstorm on a task (loads/creates task{id}.md)

### Decomposition Commands

- `/doh:prd-epics [prd_id]` - Analyze PRD and create epics with folder/epic{id}.md structure
- `/doh:epic-tasks [epic_id]` - Analyze epic and create tasks as task{id}.md files
- `/doh:epic-features [epic_id]` - Analyze epic and create features with folder/feature{id}.md structure
- `/doh:feature-tasks [feature_id]` - Analyze feature and create tasks as task{id}.md files

### Analysis Commands

These commands analyze the parent item and suggest child items to create or update

### Everything Else: Natural Language

The system understands natural language for all operations:

**Creating items:**

- "create a PRD for notification system improvements"
- "add an epic for user dashboard to PRD #1"
- "new task: implement WebSocket handler for #12"

**Viewing & listing:**

- "show me all PRDs"
- "what's in epic notification-system?"
- "list pending tasks for #12"
- "show the status of #45"

**Organizing & splitting:**

- "split PRD #1 into epics"
- "break down epic #2 into tasks"
- "suggest features for notification epic"

**Working & completing:**

- "work on #123"
- "close task #123"
- "mark #45 as blocked"
- "link #123 to src/services/websocket.ts:45"

The system maintains the folder structure and files automatically based on natural language interactions.

## Architecture Agent (v2.0)

### Unified Agents

The system uses **2 optimized agents** (consolidation from 10 → 2 agents):

- **`doh-project-agent`**: Complete DOH project management
    - Intelligent complexity analysis (`/doh:quick`)
    - Brainstorming and hierarchical decomposition
    - Epic #0 system for quick tasks
    - Clarifying questions and recommendations

- **`autonomous-execution-agent`**: Autonomous code execution
    - Isolated worktrees per epic/feature
    - Full-stack autonomous development
    - DOH traceability maintained
    - Collaborative mode when needed

## Specialized Commands vs Implementation

### ⚠️ IMPORTANT: Specification vs Implementation Distinction

**This document documents the SPECIFICATIONS of the /doh system.**

- **📋 Specifications**: `./docs/` (this documentation)
- **⚙️ Implementation**: `.claude/commands/doh/` (actual AI assistant commands)

**⚠️ ACTION REQUIRED: The evolutions documented here must be implemented in `.claude/commands/doh/`** (see ./TODO.md for
tracking)

### How to Use This Documentation

1. **Specifications**: This doc = vision and planned evolutions
2. **Implementation**: Commands described here must be coded in `.claude/commands/doh/*.md`
3. **Testing**: Verify that commands actually work with AI assistant
4. **Maintenance**: Maintain consistency between specification and implementation

### Express Commands (In Development)

#### `/doh:quick [description]`

**Status**: Specified, to implement in `.claude/commands/doh/quick.md`

Quick creation with intelligent analysis:

- Natural language typing: "hotfix typo", "bug mobile", "refactor auth"
- Clarifying questions if scope vague
- Phase vs promotion recommendations
- Auto-assignment Epic #0 with categorization

#### Epic #0 System

**Status**: Concept defined, to implement

Default epic "Maintenance & General Tasks":

- Container for tasks that don't need dedicated epic
- Auto-categorization (🐛 Bug, ⚡ Performance, 🔧 Maintenance, 📝 Doc)
- Intelligent graduation to dedicated epics when appropriate

### Traditional Commands (Implemented)

#### Brainstorming Commands

- **`/doh:prd [id]`** - Brainstorm on a PRD (loads/creates prd{id}.md)
- **`/doh:epic [id]`** - Brainstorm on an epic (loads/creates epic{id}.md)
- **`/doh:feature [id]`** - Brainstorm on a feature (loads/creates feature{id}.md)
- **`/doh:task [id]`** - Brainstorm on a task (loads/creates task{id}.md)

#### Decomposition Commands

- **`/doh:prd-epics [prd_id]`** - Analyze PRD and create epics with folder structure
- **`/doh:epic-tasks [epic_id]`** - Analyze epic and create direct tasks
- **`/doh:epic-features [epic_id]`** - Analyze epic and create features with folders
- **`/doh:feature-tasks [feature_id]`** - Analyze feature and create implementable tasks

#### Agent Commands

- **`/doh:agent [description or #id]`** - Assign task/epic to autonomous agent
    - Creates isolated worktree (`epic/{name}` or `feature/{name}`)
    - Autonomous implementation with DOH traceability
    - Supports parallel execution on different epics/features
    - **Context Protocol**: Full context bundle with project memory (see
    [Agent Context Protocol](agent-context-protocol.md))

## Natural Language Support

The system understands natural language for all daily operations:

**Creating elements**:

- "create a PRD for notification improvements"
- "add user dashboard epic to PRD #1"
- "new task: implement WebSocket handler for #12"

**Viewing and listing**:

- "show me all PRDs"
- "what's in the notification-system epic?"
- "list pending tasks for #12"

**Organization and management**:

- "split PRD #1 into epics"
- "break down epic #2 into tasks"
- "mark #45 as blocked"
- "link #123 to src/services/websocket.ts:45"

## Usage Guidelines: Commands vs Natural Language

**Use commands for**:

- Focused brainstorming sessions
- Systematic decomposition (PRD→Epics, Epic→Features)
- Autonomous agent work
- Quick creation with `/doh:quick`

**Use natural language for**:

- Creating individual elements
- Status updates
- Viewing and consultation
- Dependency management
- General work direction

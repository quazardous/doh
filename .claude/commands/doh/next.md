# /doh:next - AI-Powered Task Analysis & Recommendation Engine

Intelligent task prioritization system that analyzes DOH task dependencies, project context, and priorities to suggest optimal next tasks with natural language interaction support.

## Usage

```bash
/doh:next [query] [--context=focus] [--format=output] [--limit=N] [--refresh] [--cache-only] [--no-cache]
```

## Parameters

- `query`: (Optional) Natural language query about what to work on (e.g., "what can I do that's high impact", "show me documentation tasks", "what's ready to start")
- `--context=focus`: Filter by development context
  - `docs` - Documentation and writing tasks
  - `build` - Build system and architecture
  - `testing` - Testing and QA tasks
  - `features` - Core functionality development
  - `quick` - Tasks that can be completed in <2 hours
  - `blocked` - Show what's currently blocking other tasks
- `--format=output`: Output format
  - `brief` - Concise task list (default)
  - `detailed` - Full analysis with reasoning
  - `plan` - Step-by-step implementation plan
- `--limit=N`: Maximum number of tasks to suggest (default: 3-5)
- `--refresh`: Force cache refresh (ignore existing .doh/memory/NEXT.md)
- `--cache-only`: Extreme speed mode - read directly from memory file without re-computation
- `--no-cache`: Ignore memory file entirely - fresh analysis without reading or updating

## Smart Memory System

The command uses `.doh/memory/NEXT.md` as intelligent memory with DOH task awareness and pre-computed queries:

### Memory Architecture

```
.doh/memory/
├── NEXT.md              # AI memory for task recommendations
├── patterns.md          # Learned project patterns
├── preferences.md       # User preference tracking
└── optimization.md      # AI optimization log
```

- **Project-specific intelligence**: Tracks current project context and DOH task structure
- **Epic awareness**: Integrates .doh/epics/ for strategic context
- **Pre-computed queries**: Common searches like "epic 1", "quick wins", "high priority" pre-calculated
- **Smart context matching**: Natural language queries instantly mapped to stored results
- **Auto-update**: Memory refreshed on task status changes and completions
- **Extreme speed**: `--cache-only` reads memory directly with zero re-computation overhead

## AI Analysis Engine

The command performs comprehensive intelligent analysis optimized for DOH task structure:

### 1. DOH Task Structure Analysis

- **Parses .doh/tasks/ folder** for individual task JSON files and status
- **Epic integration**: Analyzes .doh/epics/ for strategic relationships
- **Feature correlation**: Maps tasks to .doh/features/ for context
- **Dependency resolution**: Uses DOH depends_on field structure
- **Priority parsing**: Leverages explicit P0-P3 priority fields

### 2. Dependency & Blocking Analysis

- **Identifies blockers**: Tasks marked as dependencies in depends_on arrays
- **Maps ready tasks**: Tasks with all dependencies completed
- **Calculates impact**: How many other tasks depend on this one
- **Epic phase awareness**: Considers epic phases and milestone dependencies
- **Agent workload**: Analyzes assigned_to for workload distribution

### 3. Natural Language Processing

- **Intent recognition**: Understands queries like "what should I work on next?"
- **Context matching**: Maps natural language to DOH tags and categories
- **Smart filtering**: Interprets phrases like "high priority", "quick wins", "epic 1 work"
- **Conversational responses**: Provides explanations with DOH context

### 4. Intelligent Prioritization Algorithm

**Priority Score Calculation**:

```
Priority Score = DOH Priority × Dependency Weight × Context Relevance × Epic Impact × Agent Load
```

**Factors**:

- **DOH Priority**: Explicit P0 (4.0), P1 (3.0), P2 (2.0), P3 (1.0) from task JSON
- **Dependency Weight**: 2.0 if no blockers, 0.5 if dependencies remain, 0.1 if blocked
- **Context Relevance**: 2.0 if matches user context/query, 1.0 baseline, 0.5 if mismatched
- **Epic Impact**: 2.0 if critical path, 1.5 if milestone task, 1.0 baseline
- **Agent Load**: 1.5 if assigned to available agent, 1.0 if unassigned, 0.7 if overloaded agent

## DOH Task Structure Integration

### Task File Format (.doh/tasks/DOH-123.json)

```json
{
  "id": "DOH-123",
  "title": "Implement user authentication",
  "status": "in_progress",
  "priority": "P1",
  "effort_points": 5,
  "depends_on": ["DOH-122", "DOH-118"],
  "epic_id": "EPIC-001",
  "assigned_to": "agent-backend",
  "tags": ["auth", "security", "backend"],
  "description": "Add JWT-based authentication system",
  "acceptance_criteria": [
    "User can login with email/password",
    "JWT tokens expire after 24 hours",
    "Password reset functionality works"
  ],
  "created_date": "2025-08-27",
  "due_date": "2025-08-30"
}
```

### Epic Integration (.doh/epics/EPIC-001.json)

```json
{
  "id": "EPIC-001",
  "title": "User Management System",
  "status": "in_progress",
  "phases": [
    {
      "phase": 1,
      "title": "Authentication Core",
      "tasks": ["DOH-123", "DOH-124"],
      "status": "completed"
    },
    {
      "phase": 2,
      "title": "Authorization Framework",
      "tasks": ["DOH-125", "DOH-126"],
      "status": "in_progress"
    }
  ]
}
```

## Natural Language Query Examples

### Task Discovery Queries

```bash
/doh:next "what should I work on?"
# AI Response: Analyzes DOH tasks, shows highest priority unblocked tasks

/doh:next "show me some quick wins"
# AI Response: Filters tasks with effort_points <= 2 and no dependencies

/doh:next "what documentation needs attention?"
# AI Response: Finds tasks tagged with "docs" or containing documentation keywords
```

### Epic and Strategic Queries

```bash
/doh:next "what's next for epic 1?"
# AI Response: Shows EPIC-001 tasks in current phase, identifies blockers

/doh:next "what's blocking our authentication work?"
# AI Response: Analyzes auth-tagged tasks and their dependency chains

/doh:next "show me backend agent tasks"
# AI Response: Filters tasks assigned to agent-backend, considers workload
```

### Context-Aware Queries

```bash
/doh:next "I have 2 hours, what should I tackle?"
# AI Response: Suggests tasks with effort_points matching available time

/doh:next "what can I do while waiting for the API design?"
# AI Response: Identifies parallel work not blocked by API dependencies

/doh:next "show me high priority items I can start immediately"
# AI Response: P0/P1 tasks with no dependencies, ready to begin
```

## Smart Response Formats

### Brief Format (Default)

```
🎯 Next Recommended Tasks (3 of 12 total)

1. **DOH-125** - Implement role-based permissions (P1, Epic 1)
   ├── 🟢 Ready to start (DOH-123 ✅, DOH-124 ✅)
   ├── ⏱️  Estimated: 3 story points
   ├── 👤 Assigned: agent-backend
   └── 🎯 Impact: Unblocks DOH-126, DOH-127 (Phase 2 completion)

2. **DOH-141** - Update API documentation (P2, Quick win)
   ├── 🟢 Ready to start (no dependencies)
   ├── ⏱️  Estimated: 1 story point
   ├── 🏷️  Tags: docs, api
   └── 🎯 Impact: Improves developer onboarding

3. **DOH-156** - Optimize database queries (P1, Performance)
   ├── 🟡 Waiting for DOH-155 (database schema review)
   ├── ⏱️  Estimated: 4 story points
   ├── 👤 Assigned: agent-backend
   └── 🎯 Impact: Critical performance milestone
```

### Detailed Format

```
🧠 AI Analysis: DOH Task Prioritization Report

## Epic Progress Overview
✅ **EPIC-001**: User Management (Phase 1 complete, Phase 2: 60%)
🟡 **EPIC-002**: API Framework (Phase 1: 40%, blocked on DOH-155)
🟢 **EPIC-003**: UI Components (Phase 1: ready to start)

## Dependency Analysis
✅ **Ready to Start**: 8 tasks with no blockers
🟡 **Waiting**: 5 tasks with pending dependencies  
🔴 **Blocked**: 2 tasks with incomplete critical dependencies

## Top Recommendation: DOH-125 (Score: 9.2/10)

**Task**: Implement role-based permissions
**Epic**: EPIC-001 User Management System (Phase 2)
**Priority**: P1 🔴
**Agent**: agent-backend

**Why This Task:**
- ✅ **Ready to start**: Dependencies DOH-123, DOH-124 completed
- 🎯 **Epic critical path**: Required for Phase 2 completion
- ⚡ **High impact**: Unblocks 2 other tasks (DOH-126, DOH-127)
- 🏃 **Momentum**: Builds on recent authentication work
- 👤 **Agent availability**: backend agent has capacity

**Implementation Context:**
- Depends on completed JWT auth system (DOH-123)
- Requires user model from DOH-124
- Will enable advanced user features in Phase 3
- Estimated 3 story points based on acceptance criteria
```

## Memory-Based Performance Optimization

### Execution Modes

#### Standard Mode (Default)
1. **Read Previous Memory**: Load existing .doh/memory/NEXT.md for context
2. **Analyze Current State**: Scan .doh/ structure for changes
3. **Incremental Update**: Update analysis based on task/epic changes
4. **Generate Recommendations**: Create prioritized suggestions
5. **Update Memory**: Refresh memory with current analysis
6. **Return Results**: Provide recommendations with fresh insights

#### Memory-Only Mode (`--cache-only`)
1. **Direct Read**: Load .doh/memory/NEXT.md immediately
2. **Extract Recommendations**: Parse stored recommendations
3. **Format Output**: Apply requested format
4. **Instant Return**: Sub-100ms response from memory
5. **Skip Analysis**: No file scanning, no memory refresh

#### No-Cache Mode (`--no-cache`)
1. **Skip Memory**: Ignore .doh/memory/NEXT.md completely
2. **Fresh Analysis**: Scan .doh/ structure from scratch
3. **Pure Computation**: Generate recommendations from current state only
4. **No Memory Updates**: Don't update memory file
5. **Clean State**: Useful for testing or corrupted memory

### Performance Characteristics

| Mode | Response Time | Accuracy | Use Case |
|------|---------------|----------|-----------|
| Standard | 1-3 seconds | Current | Normal workflow, up-to-date recommendations |
| Memory-Only | <100ms | Last update | Quick checks, rapid workflow, scripting |
| Refresh | 3-5 seconds | Perfect | Major changes, memory reset, fresh start |
| No-Cache | 2-4 seconds | Perfect | Testing, debugging, clean analysis |

## Integration with DOH Workflow

### With Other /doh Commands

- **Post-completion hook**: Auto-suggest next task after `/doh:commit`
- **Memory refresh**: `/doh:commit` and `/doh:changelog` auto-update memory
- **Epic coordination**: Integrates with `/doh:epic` status updates
- **Agent awareness**: Considers `/doh:agent` assignments in recommendations

### Project Context Learning

- **Task patterns**: Learns from completed task sequences
- **Epic preferences**: Adapts to team's epic prioritization patterns
- **Agent specialization**: Recognizes agent expertise areas
- **Time estimation**: Improves effort predictions based on completion history

## Example Usage Scenarios

```bash
# Basic recommendation
/doh:next
# Returns: Top 5 DOH tasks based on priority, dependencies, and context

# Epic-focused work
/doh:next "show me epic 1 phase 2 tasks"
# Analyzes EPIC-001 Phase 2, shows ready and blocked tasks

# Agent-specific work
/doh:next "what can agent-frontend work on?"
# Filters by assigned_to, considers frontend-tagged tasks

# Quick wins during blocked time
/doh:next "quick tasks while waiting for API review"
# Shows low effort_points tasks not dependent on API work

# Memory-only ultra-fast mode
/doh:next --cache-only --context=testing
# Sub-100ms response from .doh/memory/NEXT.md
```

## Configuration

### .doh/config.ini Integration

```ini
[ai]
next_cache_ttl = 300        ; Memory cache TTL in seconds
next_auto_refresh = true    ; Auto-refresh on task changes
next_default_limit = 5      ; Default recommendation count
next_memory_enabled = true  ; Enable smart memory system
next_agent_awareness = true ; Consider agent assignments
next_epic_priority = high   ; Weight epic tasks higher
```

## Success Criteria

- [ ] **Natural language works** for common DOH operations
- [ ] **DOH structure integration** correctly parses tasks and epics
- [ ] **Dependency analysis** resolves depends_on relationships accurately
- [ ] **Epic awareness** provides strategic context in recommendations
- [ ] **Agent coordination** considers workload and specialization
- [ ] **Memory persistence** maintains intelligence across sessions
- [ ] **Performance modes** function correctly with expected response times

## AI-Driven Features

- **Learning**: Adapts to project patterns and team preferences
- **Context awareness**: Understands current epic phases and milestones
- **Workload balancing**: Distributes recommendations across agents
- **Strategic alignment**: Prioritizes epic critical path items
- **Continuous optimization**: Improves recommendations based on completion patterns

This command transforms DOH task management from static lists into an intelligent, conversational recommendation system that understands your project's epic structure, task dependencies, and team dynamics to provide contextually aware suggestions for optimal productivity.
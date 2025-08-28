# DOH Internal Development Guide

**Target**: Patterns for developing the /doh system itself  
**Audience**: Claude & developers working on /doh internals

## Documentation Pattern Boundaries

### Internal vs Runtime Documentation Separation

**Critical**: Maintain clear separation between DOH internal development patterns and user-facing runtime documentation.

#### Internal Development Documentation (CAN have T/E numbers, TODO.md refs)

- **TODO.md** - DOH system development roadmap with T### task numbers
- **DEVELOPMENT.md** - This file, internal DOH development guide
- **TODOARCHIVED.md** - Completed DOH system tasks archive
- **CHANGELOG.md** - DOH system release history with T### references
- **VERSION.md** - DOH system version tracking
- **analysis/\*.md** - DOH system design and analysis documents

#### User-Facing Documentation (NO internal patterns)

- **README.md** - User introduction, how to install/use DOH
- **WORKFLOW.md** - How to use /doh commands in projects
- **docs/\*.md** - DOH usage documentation for end users
- **.claude/commands/doh/\*.md** - Runtime command documentation
- **.claude/doh/templates/\*.md** - Templates for user projects

#### Mixed-Purpose Documentation (Careful separation required)

- **CONTRIBUTING.md** - For external contributors
    - ✅ CAN mention TODO.md exists for tracking
    - ❌ Should NOT reference specific T### numbers
    - ✅ Should explain contribution workflow

### Documentation Review Checklist

When creating or reviewing documentation, verify:

**For User-Facing Docs**:

- [ ] No references to TODO.md task numbers (T###, E###)
- [ ] No references to /doh-sys commands (internal use only)
- [ ] No mentions of DOH system internal development workflows
- [ ] Examples use `.doh/` structure, NOT `.claude/doh/` internals
- [ ] Focus on runtime /doh commands that users actually run

**For Internal Dev Docs**:

- [ ] Clearly marked as internal development documentation
- [ ] T### and E### references are acceptable
- [ ] TODO.md workflow documentation is appropriate
- [ ] /doh-sys commands can be documented

**For Mixed-Purpose Docs**:

- [ ] External contributors understand the scope
- [ ] No specific internal task numbers exposed
- [ ] General development process explained without internal details

## Core Development Patterns for /doh System

### 📖 Lexicon - Project Types

#### Host Project (e.g., user-dashboard, e-commerce-api)

- **Definition**: The actual software project that uses /doh for task management
- **Structure**: Has `.doh/` folder with epics, tasks, features for the project's development
- **Purpose**: Business software development (web app, API, mobile app, etc.)
- **Examples**: user-dashboard (admin interface), e-commerce-api, mobile-app

#### DOH System (meta-project)

- **Definition**: The /doh project management system itself
- **Structure**: Currently `.claude/doh/` with commands, docs, and TODO.md (now in project root)
- **Purpose**: Developing the project management system tools
- **Challenge**: Cannot use `.doh/` structure as it's designed for host projects
- **Current State**: Bootstrap phase with manual tracking

#### Meta-Development

- **Definition**: Using project management principles to develop the project management system
- **Goal**: /doh system eventually manages its own development
- **Architecture Problem**: Needs separate structure from host project's `.doh/`

### 🎯 Meta-Development Philosophy

**Problem**: Developing a project management system requires its own project management  
**Architecture Challenge**: `.doh/` structure is designed for **host projects** (e.g., web applications), not /doh
system development  
**Current Solution**: Manual tracking in `./TODO.md` during bootstrap phase  
**Future Solution**: Dedicated meta-development structure for /doh system development

#### Terminology Clarification

- **Host Project**: The actual project using /doh system (e.g., user-dashboard, e-commerce-api)
- **DOH System**: The /doh project management system itself (meta-project)
- **Meta-Development**: Developing /doh system using project management principles

#### Self-Hosting Pattern (Architecture Problem)

```text
CURRENT: ./TODO.md → Manual tracking (Bootstrap phase)
PROBLEM: .doh/ is for HOST PROJECT, not DOH SYSTEM development
         .doh/epics/doh-system-dev/ ← This mixes host project + meta-development

FUTURE SOLUTION ANALYSIS:
Option A: Separate meta-development repository with own .doh/
  ✅ Clean separation, reuses existing /doh commands as-is
  ✅ KISS principle maintained
  ❌ Development split across repositories

Option B: .claude/doh/.meta-doh/ structure + meta-mode in commands
  ✅ Everything in one place
  ❌ VIOLATES KISS - adds if/else complexity to ALL /doh commands
  ❌ Heavy maintenance burden, code bloat

Option C: Current approach - ./TODO.md during bootstrap
  ✅ Simple, pragmatic, works for current development phase
  ✅ No code complexity added
  ✅ Can transition to Option A when /doh system stabilizes

RECOMMENDATION: Continue with Option C, transition to Option A later
```

### 🔄 DOH Development Workflow Pattern

#### Claude-Centric Development (Current Reality)

```bash
# CURRENT Pattern: Claude develops /doh using ./TODO.md
1. Analyze ./TODO.md for 🚩 NEXT flagged items
2. Implement features manually in .claude/commands/doh/ files
3. Update CHANGELOG.md with 1:1 TODO mapping
4. Mark TODO item as ✅ COMPLETED in ./TODO.md

# FUTURE Pattern: Claude develops /doh using /doh
1. Analyze ./TODO.md for 🚩 NEXT flagged items
2. Use /doh:quick to create task from TODO item
3. Use /doh:agent to implement feature autonomously
4. Update CHANGELOG.md with 1:1 TODO mapping
5. Mark TODO item as ✅ COMPLETED
```

#### Feature Implementation Pattern

```bash
# CURRENT Pattern: Manual /doh feature development
1. Edit ./TODO.md to add feature requirement
2. Implement in .claude/commands/doh/ files manually
3. Test integration with existing /doh commands
4. Update CHANGELOG.md with TODO reference
5. Mark TODO as ✅ COMPLETED

# FUTURE Pattern: Separate meta-development repo (Option A)
# In doh-system-development/ repository:
/doh:quick "implement memory structure in .doh/memory/"
→ Task created for DOH system development
→ /doh:agent #123 in meta-development context
→ Agent implements /doh system features
→ Integration tests verify /doh functionality
→ CHANGELOG updated in doh-system repo
```

#### Self-Validation Pattern

```bash
# /doh validates its own development
- Use /doh:agent for complex implementations
- Test /doh features with /doh workflows
- Document /doh patterns using /doh traceability
- Track /doh development with /doh metrics
```

### 🏗️ DOH Architecture Development Patterns

#### System Extension Pattern

```bash
# Adding new /doh functionality
1. Define in ./TODO.md with clear deliverable
2. Create command specification in .claude/commands/doh/
3. Implement core functions with integration points
4. Add to inclaude.md if user-facing
5. Create integration tests in command file
6. Export functions for agent use if needed
```

#### Command Development Pattern

````markdown
# Template for new /doh commands

## Description

Purpose and scope of command

## Implementation

```bash
# Main command function
command_main() {
  # Parameter parsing
  # Context loading (hierarchy, memory, codebase)
  # Core logic implementation
  # Agent integration hooks
  # Error handling and validation
}

# Helper functions
load_context_for_command() { ... }
validate_command_input() { ... }
export_functions_for_agents() { ... }
```
````

## Integration

- Links to other /doh commands
- Agent environment setup
- Memory update protocols

## Tests

- Unit test scenarios
- Integration test workflows

````text

#### Memory Pattern Development
```bash
# Pattern for /doh memory system extensions
1. Define memory structure in docs/memory-system.md
2. Create folder structure in .doh/memory/
3. Implement loading functions (load_*_context)
4. Add agent enrichment functions (update_*_memory)
5. Create session tracking for persistence
6. Test memory persistence across worktree operations
````

### 💾 DOH Data Pattern Development

#### Index Management Pattern

```json
// .doh/index.json structure pattern
{
  "metadata": {
    "version": "X.Y.Z",
    "project_name": "detected-or-configured",
    "last_updated": "timestamp"
  },
  "items": {
    "!123": {
      "type": "task|epic|feature|prd",
      "title": "Human readable",
      "description": "Detailed description",
      "status": "pending|in_progress|completed",
      "github_id": "#456",
      "sync_state": "dirty|synced",
      "dependencies": ["!124", "!125"],
      "epic_id": "!12",
      "created_at": "timestamp",
      "updated_at": "timestamp"
    }
  },
  "dependency_graph": {
    "!123": ["!124", "!125"]
  }
}
```

#### Dual ID Management Pattern

```bash
# Pattern for managing !123 ↔ #456 mapping
manage_dual_ids() {
  local internal_id="!${1}"      # Stable internal ID
  local github_id="#${2}"        # GitHub issue ID
  local sync_state="${3:-dirty}" # dirty|synced

  # Update index.json with mapping
  # Track sync state and timestamps
  # Handle ID conflicts and resolution
}
```

### 🌳 DOH Worktree Development Patterns

#### Agent Worktree Creation Pattern

```bash
# Pattern for creating agent development environment
setup_doh_dev_worktree() {
  local feature_name="$1"        # e.g., "memory-structure"
  local agent_id="$2"            # Agent session ID

  # Create worktree: ../doh-worktree-feature-${feature_name}
  # Symlink .claude for AI context access
  # Generate complete DOH context bundle
  # Initialize agent development environment
  # Create feature-specific memory context
}
```

#### DOH Self-Development Context Pattern

```json
// Context bundle for /doh system development
{
  "agent_session": {
    "id": "doh-dev-agent-timestamp",
    "target": {
      "type": "task",
      "id": "memory-structure-implementation",
      "description": "Implement .doh/memory/ folder structure"
    }
  },
  "hierarchy": {
    "project": {
      "name": "/doh System",
      "type": "meta-development",
      "self_hosting": true
    },
    "epic": {
      "id": "doh-system-infrastructure",
      "focus": "core system development"
    }
  },
  "memory": {
    "development_patterns": {
      "path": "./DEVELOPMENT.md",
      "patterns": ["self-hosting", "meta-development", "claude-centric"]
    },
    "implementation_decisions": {
      "version_strategy": "runtime vs dev separation",
      "documentation_strategy": "three-tier system"
    }
  },
  "codebase_context": {
    "tech_stack": ["Bash", "Markdown", "JSON"],
    "development_tools": ["AI Assistant", "Git Worktree"],
    "target_systems": ["Claude", "Git", "Shell"]
  }
}
```

### 🧪 DOH Testing Development Patterns

#### Self-Testing Pattern

```bash
# /doh tests itself using its own systems
test_doh_with_doh() {
  # Create test project with /doh:init
  # Use /doh:quick to create test tasks
  # Use /doh:agent to implement test features
  # Verify /doh workflows function correctly
  # Validate memory persistence and agent context
}
```

#### Bootstrap Testing Pattern

```bash
# Pattern for testing /doh features during development
bootstrap_doh_test() {
  # Minimal /doh setup for testing new features
  # Test new command in isolation
  # Test integration with existing /doh commands
  # Test agent compatibility with new features
}
```

### 📚 DOH Documentation Development Patterns

#### Documentation Coherence Pattern

```bash
# Ensure documentation stays coherent across development
maintain_doc_coherence() {
  # inclaude.md ← User-facing features only
  # README.md ← Navigation and overview
  # docs/ ← Technical specifications
  # ./TODO.md ← Development roadmap
  # CHANGELOG.md ← Completed features with TODO mapping
}
```

#### Meta-Documentation Pattern

```markdown
# Pattern for documenting /doh development

1. Document patterns as they emerge
2. Capture decisions in VERSION.md and CHANGELOG.md
3. Update DEVELOPMENT.md with new development patterns
4. Maintain examples of successful implementations
5. Create templates for common development tasks
```

### 🔧 DOH Utility Development Patterns

#### Context Loading Development Pattern

```bash
# Pattern for extending context loading capabilities
extend_context_loading() {
  # Add new context type (e.g., dependency context)
  # Create load_dependency_context() function
  # Integrate into main context bundle generation
  # Test context availability in agent environment
  # Document context structure and usage
}
```

#### Agent Function Export Pattern

```bash
# Pattern for making functions available to agents
export_for_agents() {
  # Define function for agent use
  export -f new_agent_function

  # Set environment variables for agent access
  export DOH_NEW_FEATURE="enabled"

  # Document agent API in command files
  # Test agent access in worktree environment
}
```

### 📋 DOH Development Structure Pattern

#### Three-Tier Documentation Strategy

```text
1. inclaude.md     → Runtime usage (Claude/end-users)
2. README.md       → General overview + navigation
3. docs/           → Technical specifications
```

#### Version Documentation Pattern

```text
- Runtime Version (inclaude.md): Stable features only
- Dev Version (./TODO.md): Work in progress + roadmap
- CHANGELOG.md: 1:1 mapping with TODO completions
- VERSION.md: Central version management
```

### 🔄 Version Management Pattern

#### Semantic Versioning Strategy

```text
Runtime:     1.3.0 (Stable)
Development: 1.4.0-dev (Current work)
Next:        1.4.0 (When dev stabilizes)
```

#### Release Flow Pattern

```text
Feature Development → ./TODO.md item
Feature Completion → CHANGELOG.md entry
Features Stabilized → Runtime version bump
Documentation Updated → inclaude.md refresh
```

#### ⚠️ CRITICAL: inclaude.md Generation Version Bump Workflow

**When generating/updating inclaude.md, ALWAYS bump versions in ALL relevant files:**

```bash
# 1. VERSION.md - Update runtime version and feature matrix
# Change Runtime version from 1.2.0 → 1.3.0
# Update feature statuses to "Production Ready"

# 2. ./TODO.md - Update runtime version in header
**Runtime Version**: 1.2.0 (Stable) → 1.3.0 (Stable)

# 3. README.md - Update version references if present
# Check for version numbers and update consistently

# 4. inclaude.md - Update header with new version
**DOH Runtime Version**: 1.2.0 (Stable) → 1.3.0 (Stable)

# 5. All DEVELOPMENT.md, docs/ files - Update version references
# Ensure consistency across all documentation

# 6. Any skeleton templates - Update version in templates
# project-index.json template should reflect current version
```

**Version Bump Checklist:**

- [ ] VERSION.md runtime version updated
- [ ] VERSION.md feature matrix updated (Dev → Production Ready)
- [ ] ./TODO.md header runtime version updated
- [ ] README.md version references updated
- [ ] inclaude.md header version updated
- [ ] All docs/ files version consistency checked
- [ ] Skeleton template versions updated
- [ ] CHANGELOG.md entry with version bump record

**Rule**: Never generate inclaude.md without completing full version bump workflow!

### 🏗️ Architecture Development Pattern

#### Separation of Concerns

```text
.claude/doh/
├── inclaude.md           # Runtime reference (2KB, optimized)
├── README.md             # Navigation + overview
├── TODO.md               # Development roadmap (in project root)
├── CHANGELOG.md          # Completed features
├── VERSION.md            # Version management
└── docs/
    ├── DEVELOPMENT.md    # This file - internal dev patterns
    ├── architecture.md   # System architecture
    ├── commands.md       # Command specifications
    └── *.md             # Other technical specs
```

#### Command Development Pattern

```text
.claude/commands/doh/
├── agent.md              # Complete implementation with functions
├── quick.md              # Specification only
├── init.md               # Implementation
└── *.md                 # Other commands

Pattern: Each command.md contains:
1. Description & Usage
2. Implementation (bash functions)
3. Integration points
4. Test scenarios
```

### 💾 Memory System Development Pattern

#### Hierarchical Memory Architecture

```text
.doh/memory/
├── project/              # Global project memory
│   ├── conventions.md   # Coding standards discovered
│   ├── patterns.md      # Code patterns identified
│   └── architecture.md  # Architecture decisions
├── epics/               # Epic-specific memory
│   └── [epic-name]/
│       ├── decisions.md # Epic decisions made
│       ├── learnings.md # What worked/didn't work
│       └── code-map.json # Files + patterns used
└── agent-sessions/      # Agent execution tracking
    └── [agent-id].json  # Session state + progress
```

#### Memory Update Protocol Pattern

```bash
# Agent memory enrichment pattern
update_project_memory() {
  local memory_type="$1"    # conventions|patterns|architecture
  local content="$2"        # Content to add
  local agent_id="$3"       # For traceability

  # Add to memory file with timestamp + agent tracking
  # Update agent session with contribution
}
```

### 🌳 Worktree Development Pattern

#### Isolation Strategy

```text
Main Project/
├── .claude/              # Shared Claude context
├── .doh/                 # Versioned DOH state
└── ...

Agent Worktree/
├── .claude -> ../main/.claude    # SYMLINK (shared)
├── .doh/                         # Via Git (isolated but synced)
├── .doh-agent-env.sh            # Agent environment setup
└── .doh-agent-context.json      # Agent context bundle
```

#### Worktree Lifecycle Pattern

```bash
# Complete worktree setup pattern
1. Create git worktree with branch
2. Symlink .claude for AI context access
3. Generate agent context bundle (JSON)
4. Initialize agent environment script
5. Validate complete setup
6. Launch agent with full context
```

### 🔗 Integration Development Pattern

#### Context Bundle Generation

```json
{
  "agent_session": {
    "id": "agent-timestamp-taskid",
    "worktree_path": "../project-worktree-type-name",
    "target": { "type": "task", "id": "123" }
  },
  "hierarchy": {
    "project": { "name": "", "language": "", "working_directory": "" },
    "epic": { "id": "", "title": "", "path": "" },
    "dependencies": []
  },
  "memory": {
    "project_conventions": { "path": "", "key_points": [] },
    "epic_decisions": { "path": "", "key_decisions": [] }
  },
  "codebase_context": {
    "tech_stack": [],
    "build_system": "",
    "test_commands": []
  }
}
```

#### Agent-Command Integration Pattern

```bash
# Commands export functions for agent use
export -f update_project_memory
export -f update_epic_memory
export -f record_pattern_discovery

# Agents access via environment
export DOH_AGENT_ID="${AGENT_ID}"
export DOH_AGENT_CONTEXT="/path/to/context.json"
```

### 🧪 Testing Development Pattern

#### Integration Test Structure

```bash
# Test scenarios pattern
test_simple_task_to_agent() {
  # 1. Create via /doh:quick
  # 2. Assign to agent
  # 3. Verify setup
}

# Test runner pattern
run_integration_tests() {
  # Setup test environment
  # Run all test scenarios
  # Generate test report
  # Restore original state
}
```

#### Validation Pattern

```bash
# Worktree validation pattern
validate_worktree_setup() {
  # Check directory exists
  # Check symlinks correct
  # Check agent session file
  # Check environment script
  # Return pass/fail with details
}
```

### 📝 Documentation Development Pattern

#### Markdown Standards

```markdown
# Command Structure Pattern

## Description

## Usage

## Parameters

## Examples

## Implementation (bash functions)

## Integration points

## Test scenarios
```

#### Code Comment Pattern

```bash
# DOH #123: Description of change
# Pattern: Always reference DOH issue in modifications

# Function documentation pattern
function_name() {
  local param1="$1"    # Description
  local param2="$2"    # Description

  # Implementation with clear steps
  # Error handling
  # Return values documented
}
```

### 🔄 Development Workflow Pattern

#### Feature Development Lifecycle

```text
1. Add TODO item with 🚩 NEXT flag
2. Create implementation in appropriate file
3. Test integration with existing systems
4. Update documentation (inclaude.md if user-facing)
5. Mark TODO as completed ✅
6. Add CHANGELOG entry with TODO reference
7. Update VERSION.md if needed
```

#### Version Bump Pattern

```text
Development Progress:
- Features added → Keep dev version (1.3.0-dev)
- Major milestone → Bump dev version (1.4.0-dev)
- Features stabilized → Release runtime version (1.3.0)
- Update inclaude.md → Refresh runtime documentation
```

### 🚩 Priority & Flag System

#### TODO Flag Meanings

- **🚩 NEXT** - Critical item for next development session
- **✅ COMPLETED** - Feature fully implemented and tested
- **🔄 IN PROGRESS** - Currently being worked on
- **📋 PLANNED** - Defined but not yet started
- **⚠️ BLOCKED** - Waiting on dependencies

#### Development Session Pattern

```text
1. Review ./TODO.md for 🚩 NEXT flagged items
2. Focus on highest priority infrastructure items first
3. Complete items in logical dependency order
4. Update CHANGELOG.md with completed features
5. Flag next session items before ending
```

### 🔧 Utility Development Pattern

#### Context Loading Functions

```bash
# Pattern: Modular context loading
load_hierarchy_context() { ... }
load_memory_context() { ... }
load_codebase_context() { ... }

# Usage: Called by main context bundle generation
# Error handling: Graceful fallbacks for missing data
# Caching: Avoid expensive operations
```

#### Session Management Pattern

```bash
# Agent session tracking pattern
update_agent_session_memory() {
  # Load existing session
  # Add new memory contribution
  # Update timestamps
  # Atomic file operations
}
```

### 📊 Quality Assurance Pattern

#### Code Quality Standards

- **Modularity**: Functions do one thing well
- **Documentation**: All functions have purpose/params documented
- **Error Handling**: Graceful failures with useful messages
- **Testing**: Integration tests for critical workflows
- **Traceability**: All changes reference DOH issues

#### Markdown Linting Workflow

**DOH uses automated markdown quality control** with markdownlint-cli:

**Commands**:

```bash
# Check all markdown files for issues
make lint

# Auto-fix markdown formatting issues
make lint-fix

# Show issues requiring manual attention
make lint-manual
```

**Development Workflow**:

1. **Write/Edit**: Create or modify documentation
2. **Auto-fix**: Run `make lint-fix` to correct formatting automatically
3. **Manual fixes**: Run `make lint-manual` to see issues requiring manual attention:
   - 📏 **Line length (MD013)**: Break long lines at 120 characters
   - 🔢 **List numbering (MD029)**: Fix ordered list prefixes (1, 2, 3...)
   - 📑 **Duplicate headings (MD024)**: Make headings unique in document
   - 📝 **Code blocks (MD040)**: Add language specifications
4. **Verify**: Run `make lint` to confirm all issues resolved
5. **Commit**: Pre-commit hooks automatically validate markdown quality

**Quality Standards**: See `docs/markdown-style-guide.md` for complete DOH markdown standards and configuration details.

#### Review Checklist

- [ ] Function serves single purpose
- [ ] Parameters documented with types/descriptions
- [ ] Error cases handled gracefully
- [ ] Integration points tested
- [ ] **Markdown quality**: `make lint` passes cleanly
- [ ] Documentation updated (inclaude.md if user-facing)
- [ ] CHANGELOG entry added with TODO reference
- [ ] TODO item marked completed ✅

---

## Internal Development Rules

### 🎯 Core Principles

1. **Separation of Concerns**: Runtime (inclaude.md) vs Development docs
2. **Traceability**: Every change references TODO/DOH issue
3. **Modularity**: Functions should be composable and testable
4. **Documentation**: Code should be self-documenting with minimal comments
5. **Version Discipline**: Clear distinction between dev and runtime versions

### 🛡️ Quality Gates

1. **Before Commit**: All integration tests must pass
2. **Before Runtime Release**: Features must be stable and documented
3. **Before TODO Completion**: Feature must be fully implemented and tested
4. **Before Version Bump**: CHANGELOG must be updated with all changes

### 📄 Analysis Document Policy

**Analysis documents (analysis/\*.md) are historical snapshots**:

✅ **Allowed**: Formatting/linting fixes (line lengths, spacing, markdown syntax) ❌ **Forbidden**: Semantic content
changes (project names, examples, conclusions)

**Rationale**: Analysis documents preserve the context and thinking at the time decisions were made. They serve as an
audit trail for understanding why architectural choices were made and what information was available when.

### 📈 Development Metrics

- **TODO Completion Rate**: Items marked ✅ per session
- **CHANGELOG Coverage**: 1:1 mapping with completed TODO items
- **Integration Test Pass Rate**: All scenarios must pass
- **Documentation Coverage**: User-facing features documented in inclaude.md

## TODO Management for DOH Development

📋 **TODO Management**: See `todo/README.md` for complete TODO system documentation, workflows, and guidelines.

This project uses a structured file-based TODO system rather than the /doh system it provides to other projects. Each
TODO and Epic is maintained as an individual file for better organization, version control, and collaboration.

### File Organization

- **todo/README.md**: Complete TODO management documentation and guidelines
- **todo/T###.md**: Individual TODO files (active and proposed)
- **todo/E###.md**: Epic definition files
- **todo/archive/T###.md**: Completed TODOs (archived)
- **CHANGELOG.md**: Feature releases with TODO mappings
- **VERSION.md**: Central version tracking

### Benefits of Structured System

- **Individual Files**: Each TODO/Epic in separate file for easy editing
- **Better Version Control**: Reduced merge conflicts, clear history per TODO
- **Enhanced Collaboration**: Multiple developers can work simultaneously
- **Improved Navigation**: File-based search and organization

### ID Numbering Convention

**Unified Sequence**: TODOs and Epics share the same numbering sequence.

**ID Formats**:

- **TODO Items**: T{number} (e.g., T001, T044, T045)
- **Epic Items**: E{number} (e.g., E047, E020)

**Epic Transformation Rule**: When a TODO becomes an epic, it keeps the same number:

- T020 → E020 (transforms into epic, keeps ID 020)
- New child TODOs get new IDs from the sequence

**Epic Identification**:

- Epics are marked with 🛡️ EPIC flag in the TODO list
- Epics list their component TODOs in parentheses
- Child TODOs reference their parent epic with [Epic E###]

**Single List Management**: All items (TODOs and Epics) are maintained in a single "Active TODOs" list, with epics
identified by the 🛡️ flag rather than being in a separate section.

### TODO Lifecycle Rules

- Update **Next TODO ID** in header when adding new TODO or Epic
- Add to **Active TODOs** list (single unified list for all items)
- Mark epics with 🛡️ EPIC flag and list components
- Keep descriptions concise and actionable
- Use GitHub-like format for clean diffs
- **Never move TODOs** when status changes (preserve diff history)
- Mark completed TODOs in CHANGELOG.md, not here
- Use proper version nomenclature (see Version Management below)

### Epic Management Rules

- **Creating Epics**: Can create new epic (E###) or transform existing TODO (T### → E###)
- **Epic Transformation**: When T### becomes E###, keep same number
- **Child TODOs**: Create new T### IDs for epic components
- **Epic Tracking**: Use 🛡️ flag and (Components: T###, T###) format
- **Child References**: Child TODOs use [Epic E###] to show parent
- **Single List**: Keep epics and TODOs in same Active TODOs list
- **Epic Completion**: Epic marked complete when all children complete

### Version Management for TODOs

**Three-Tier Version System** for TODO tasks (only one field present at a time):

#### Version Field Definitions

1. **Proposed Version**: `1.4.0` - Initial version suggestion at task creation
   - Set when task is first created
   - Indicates earliest possible version for consideration
   - Can be tentative or aspirational

2. **Target Version**: `1.4.0` - Mature planning commitment
   - Set when task is actively planned
   - Indicates intended delivery version
   - Subject to change based on priorities

3. **Version**: `1.4.0` - Frozen roadmap commitment
   - Set when version is locked in roadmap
   - Immutable once set (except for major replanning)
   - Can be set even if Status is "NOT PLANNED" for constraints

#### Task Lifecycle & Version Evolution

Tasks progress through version planning stages (only one version field at a time):

```markdown
# New task (Claude's initial estimation)

Status: READY + Proposed Version: 1.4.0

# Task is planned for specific version

Status: READY + Target Version: 1.4.0

# Roadmap is locked OR task becomes active

Status: IN PROGRESS + Version: 1.4.0

# Task completed

Status: COMPLETED + Version: 1.4.0 ✅
```

#### Version Evolution Examples

```markdown
# Normal evolution

T001: Proposed Version: 1.4.0 → Target Version: 1.4.0 → Version: 1.4.0 ✅

# Deferred task

T002: Proposed Version: 1.4.0 → Target Version: 1.5.0 → (still flexible)

# Version constraint (external requirement)

T003: Status: NOT PLANNED + Version: 1.5.0 (must be in this specific version)

# Fast-tracked urgent task

T004: Proposed Version: 1.4.1 → Version: 1.4.1 (directly to frozen)
```

#### Version Field Rules

- **Only one version field** per task at any time
- **Proposed Version**: For new tasks, initial planning
- **Target Version**: For planned tasks, can still change
- **Version**: For locked roadmap or active/completed tasks, immutable
- **Status independence**: Task can be NOT PLANNED but have frozen Version for constraints

### Archive Management

**TODOARCHIVED.md Rules**:

- Move TODOs completed yesterday or earlier to TODOARCHIVED.md
- Preserve complete TODO descriptions and implementation notes
- Include completion date and final status
- Maintain chronological order (newest completed first)
- Reference related TODOs and dependencies
- Keep deliverable and impact information for historical reference

**Completion Workflow**:

When a TODO is completed:

1. **Update CHANGELOG.md**: Add entry with TODO reference and completion date
2. **Update VERSION.md**: If TODO affects version, update runtime/dev versions
3. **Remove from Active TODOs**: Remove completed TODO from priority sections
4. **Archive TODO**: Move completed section to TODOARCHIVED.md, preserve TODO body for reference
5. **Update dependencies**: Mark dependent TODOs as unblocked if applicable

---

_This guide evolves with the /doh system and captures patterns learned during development._

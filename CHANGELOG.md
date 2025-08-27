# /doh System Changelog

All notable changes to the /doh system will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - Dev 1.4.0

### Added

- Version management system with runtime/dev separation
    - **STATUS**: ✅ COMPLETED 2025-08-27
- CHANGELOG.md for tracking completed features
    - **STATUS**: ✅ COMPLETED 2025-08-27
- VERSION.md for centralized version management
    - **STATUS**: ✅ COMPLETED 2025-08-27

### Completed in This Session (2025-08-27)

- **T034** - Documentation Health Check & Content Review
    - **STATUS**: ✅ COMPLETED 2025-08-27
    - **Components**: Comprehensive audit of 52 documentation files across 5 directories, analysis of 89 outdated
    architecture references, prioritized action plan with 3 implementation phases
    - **Analysis**: `analysis/T034-documentation-health-report.md`
    - **Impact**: Identified critical 1.4.0 release blockers (architecture inconsistencies), established clear roadmap for
    documentation improvements, separated urgent fixes from enhancement work
- **T033** - Restore skel/ and templates/ to .claude/doh/ runtime directory
    - **STATUS**: ✅ COMPLETED 2025-08-27
    - **Components**: Single source of truth architecture implementation, cleanup of obsolete project root files
    - **Impact**: DOH commands now have proper runtime access to skeleton and templates, eliminated controlled duplication
    strategy

- **T004** - File system structure validation
    - **STATUS**: ✅ COMPLETED 2025-08-27
- **T012** - Memory structure implementation (.doh/memory/)
    - **STATUS**: ✅ COMPLETED 2025-08-27
- **T012** - Centralized dependency management
    - **STATUS**: ✅ COMPLETED 2025-08-27
- **T001** - DOH Skeleton Implementation
    - **STATUS**: ✅ COMPLETED 2025-08-27
    - **Components**: Complete `.claude/doh/skel/` structure with project-index.json template, memory directories, Epic #0
    template, gitignore patterns, and deployment testing
    - **Impact**: Enables standardized `/doh:init` and `/doh:analyze` with consistent project initialization
- **T015** - DOH Configuration File Design
    - **STATUS**: ✅ COMPLETED 2025-08-27
    - **Components**: INI format configuration with bash compatibility, config.ini template, project-specific settings
- **T018** - Project Path Resolution Strategy
    - **STATUS**: ✅ COMPLETED 2025-08-27
    - **Components**: Comprehensive path resolution with 7-level priority fallback, UUID-based project identity,
    discovered paths cache, cross-environment compatibility (symlinks, .private, bind mounts), advanced INI parsing APIs
    (doh_config_get/bool/list/int/path), debugging mode (DOH_PATH_DEBUG=1)
    - **Impact**: Robust cross-environment DOH project detection that preserves user's preferred working directory while
    handling all common filesystem scenarios
    - **Impact**: Centralized configuration system for .doh projects with bash-friendly parsing
- **T016** - DOH Configuration Integration Validation
    - **STATUS**: ✅ COMPLETED 2025-08-27
    - **Components**: Unified lib/doh.sh library, auto-detection PROJECT_ROOT, pure bash config extraction
    - **Impact**: Configuration extraction is now pure bash routine, no AI dependency for config operations
- **T014** - DOH Data Structure Analysis for Scripting
    - **STATUS**: ✅ COMPLETED 2025-08-27
    - **Components**: Complete analysis of 22 DOH operations, bash-scriptability assessment, performance benchmarks
    - **Impact**: 18/22 operations identified as bash-scriptable with 70-80% token savings potential
- **T013** - Performance Optimization via Bash Scripts (POC)
    - **STATUS**: ✅ COMPLETED 2025-08-27
    - **Components**: get-item.sh, list-tasks.sh, project-stats.sh, unified lib/doh.sh library
    - **Impact**: 150-500x performance gains measured, 100% token savings for routine operations, POC success
- **T017** - Bash Routine Expansion Analysis
    - **STATUS**: ✅ COMPLETED 2025-08-27
    - **Components**: Complete analysis of next 5 bash routine candidates, ROI prioritization, implementation roadmap
    - **Impact**: Identified path to 85% token savings coverage with Phase 1-3 implementation plan
- **T018** - Project Path Resolution Strategy
    - **STATUS**: ✅ COMPLETED 2025-08-27
    - **Components**: Design for robust PROJECT_ROOT detection with symlinks, discovered_paths cache, .doh/uuid identity
    - **Impact**: Comprehensive strategy for cross-environment compatibility (symlinks, encrypted filesystems, mounts)
- **T025** - Move TODO.md from .claude/doh to project root
    - **STATUS**: ✅ COMPLETED 2025-08-27
    - **Components**: TODO.md relocated to project root, all internal references updated across documentation and system
    files
    - **Impact**: More accessible development tracking, conventional project structure, preparation for DOH self-hosting
- **T026** - Restructure DOH: Move non-runtime components outside .claude
    - **STATUS**: ✅ COMPLETED 2025-08-27
    - **Components**: Migrated docs/, templates/, skel/, analysis/, tests/, README.md, CHANGELOG.md, VERSION.md to project
    root; Updated all hardcoded references in CLAUDE.md, docs/commands.md, docs/doh-dev.md; Validated DOH functionality
    after restructure; Comprehensive file verification strategy designed for T029 cleanup
    - **Impact**: Clean separation between development files (project root) and runtime components (.claude/doh/scripts/),
    preparation for T022 self-hosting, improved project organization, foundation for T032 build process
- **T028** - Development Environment Setup & Automation
    - **STATUS**: ✅ COMPLETED 2025-08-27
    - **Components**: Cross-platform Makefile with intelligent package manager detection, dev-tools/ structure,
    package.json for dev dependencies, pre-commit hooks with linter integration, CONTRIBUTING.md, automatic help system
    - **Impact**: Professional development workflow, one-command setup (make dev-setup), automated quality checks,
    foundation for T024 testing framework
- **T031** - Brainstorm skel/ location for /doh:init runtime access
    - **STATUS**: ✅ COMPLETED 2025-08-27
    - **Components**: Architecture decision for controlled duplication, analysis of 5 options
    (revert/duplicate/sideload/runtime/hybrid), confirmed /doh:init functionality works with existing setup
    - **Impact**: Critical architecture decision resolved - maintain .claude/doh/skel/ as single source (no duplication),
    leads to T032 build process design

### Planned for Next Phase (1.4.0)

- **T022** - DOH System Self-Hosting Project ⚠️ UNBLOCKED
    - **STATUS**: 📋 CRITICAL PRIORITY - Foundation for distribution
    - **Purpose**: Create DOH as standalone project using DOH to manage its own development
    - **Dependencies**: T026 ✅ (restructuring completed)
- **T032** - Design DOH Runtime Build Process
    - **STATUS**: 📋 PROPOSED - Build system architecture
    - **Purpose**: Implement build process for .claude/doh/ as build directory
    - **Dependencies**: T031 ✅ (architecture decision completed)
- **T024** - Comprehensive Testing Framework Implementation
    - **STATUS**: 📋 PROPOSED - Dual CI/CD + Local system
    - **Purpose**: Zero-credential CI/CD tests + local Claude testing
    - **Dependencies**: T028 ✅ (dev environment completed)
- **T002** - Codebase reverse engineering (`/doh:analyze` command)
    - **STATUS**: 📋 PLANNED - Target Version 1.5.0
    - **Purpose**: AI-powered analysis of existing codebases to suggest Epic/PRD structure
    - **Safety**: Strong warnings for existing .doh projects, --force flag required

---

## [1.2.0] - 2025-08-27 "Agent Context Protocol"

### Added

- **Agent Context Protocol** - Complete JSON context bundles for autonomous agents
- **Memory Updates Protocol** - Interface for agents to enrich project memory during execution
- **Worktree Automation** - Automatic git worktree creation with complete environment setup
- **Agent Session Tracking** - Persistent session management in `.doh/memory/agent-sessions/`
- **Integration Testing** - Complete test scenarios for `/doh:quick` → `/doh:agent` workflow
- **Runtime Documentation** - `inclaude.md` optimized for Claude usage (2KB vs 15KB+)
- **Context Bundle Generation** - Hierarchical loading (project + epic + memory + codebase)
- **Worktree Environment Setup** - Symlinks, validation, and agent-specific scripts

### Enhanced

- `/doh:agent` command - Complete implementation with context bundle generation
- Agent-worktree integration - Isolation with `.claude` symlinks and versioned `.doh`
- Memory enrichment - Agents can contribute patterns, decisions, and learnings
- Session validation - Complete worktree setup validation and error handling

### Fixed

- Agent context loading - Now includes complete hierarchy and memory context
- Worktree isolation - Proper symlink strategy for Claude Code integration
- Documentation coherence - Separated runtime (inclaude.md) from dev docs

### Technical

- Context loading functions for hierarchy, memory, and codebase detection
- Agent environment variables and memory update functions
- Comprehensive integration test suite
- Complete worktree lifecycle management

---

## [1.1.0] - Previous "Core Infrastructure"

### Added

- **Unified Index System** - `index.json` replaces `.cache` and sync systems
- **Dual ID System** - Local (!123) and GitHub (#456) ID mapping
- **GitHub/GitLab Sync Architecture** - Bidirectional synchronization patterns
- **Standardized MD Headers** - Automatic GitHub URLs in task/epic files

### Enhanced

- `/doh:init` command - Reentrant initialization system
- `/doh:sync-github` command - Complete specification for GitHub integration
- Metadata tracking - Centralized state management through index.json

### Specified

- Conflict resolution patterns for sync operations
- Dual ID state management (dirty/synced timestamps)
- Headers format with automatic GitHub link generation

---

## [1.0.0] - Previous "2-Agent Architecture"

### Added

- **2-Agent Consolidation** - Simplified from 10 agents to 2 core agents
- **DOH Project Agent** - Intelligent task analysis and recommendations
- **Autonomous Execution Agent** - Independent task implementation
- **Epic #0 System** - Default epic for quick tasks without bureaucracy
- **Auto-categorization** - 🐛 Bug, ⚡ Perf, 🔧 Maintenance, 📝 Doc categories

### Enhanced

- CLAUDE.md documentation - Clear usage instructions
- Agent architecture - Cleaner separation of concerns
- Command structure - Unified `/doh:` command namespace

### Removed

- Legacy 10-agent architecture - Over-engineering resolved
- Scattered command structures - Consolidated into coherent system

### Fixed

- Agent coordination issues - Simplified workflow reduces conflicts
- Documentation fragmentation - Consolidated specifications

---

## [0.x] - Foundation (Historical)

### Added

- Basic DOH command structure
- Initial epic and task management
- Claude Code integration framework
- Git-based task tracking
- Template system for PRD/Epic/Task creation

### Established

- Core philosophy: "Context is obvious... once you have it"
- Hierarchical workflow: PRD → Epic → [Feature] → Task → Code
- Traceability standards: Comments and commits must reference DOH issues
- Natural language support for task creation and management

---

## Version Mapping Legend

- **[X.Y.Z]** - Runtime version (stable, in inclaude.md)
- **Dev X.Y.Z** - Development version (work in progress, in ./TODO.md)
- **[Unreleased]** - Features completed but not yet in stable runtime

## Documentation Structure

- **CHANGELOG.md** - Historical record of completed features (this file)
- **TODO.md** - Future roadmap and work in progress (Dev 1.3.0) - _Now in project root_
- **VERSION.md** - Version management and mapping between runtime/dev

## Categories

- **Added** - New features
- **Enhanced** - Improvements to existing features
- **Fixed** - Bug fixes and corrections
- **Removed** - Deprecated features removed
- **Specified** - Architecture defined but implementation pending
- **Technical** - Implementation details and internal improvements
- **In Progress** - Currently being developed

## TODO Mapping

Completed TODOs are tracked with their **T-number** (T001, T002, etc.) for clear traceability between ./TODO.md roadmap
and delivered functionality.

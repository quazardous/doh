# TODO - /doh System Evolution

**Last Updated**: 2025-08-27  
**Next TODO ID**: T049

---

## 🏷️ Tag Index

**Essential tags for TODO management:**

- `#doc` - Documentation tasks (T030)
- `#build` - Build system and architecture (T032, T022, T003)
- `#testing` - Testing and quality assurance (T024, T019, T027)
- `#features` - Core functionality and features (T020, T021, T017)
- `#think` - Brainstorming and analysis tasks (T034, T042)
- `#security` - Security analysis and defensive measures (T042)

---

## 📑 Active TODOs & Epics

**Order**: Top-down (most recently active first)

### Active Epics

- **E047** Natural Language & Performance Optimization (EPIC: T017, T020, T044, T045, T046)

### Active TODOs

- **T048** Audit & Enforce DOH Internal/Runtime Pattern Isolation (#doc, #architecture)
- **T046** Natural Language UX Integration & Deployment (#features, #optimization, #ux) [Epic E047]
- **T045** Intelligent Routing System (Bash/Claude Hybrid Execution) (#features, #optimization, #performance) [Epic
  E047]
- **T044** Natural Language DOH Command Interface & Script Optimization (#features, #think, #optimization) [Epic E047]
- **T043** DOH Security Epic Planning & Implementation Roadmap (#security, #think)
- **T042** DOH Security Analysis & Threat Modeling (#security, #think)
- **T041** Remove Claude Code attribution comments from codebase - COMPLETED
- **T040** Create /doh-sys:changelog command and factorize shared components - COMPLETED
- **T039** Create /doh-sys:lint command with intelligent auto-fix capabilities - COMPLETED
- **T038** Create DOH Pipeline Command for automated TODO/CHANGELOG/Version/Lint/Commit workflow - COMPLETED
- **T037** Clean up old project references (MrTroove, mkplan) across documentation - COMPLETED
- **T035** Documentation Navigation & Content Organization (T034 Phase 2) - COMPLETED
- **T034** Documentation Health Check & Content Review - COMPLETED
- **T032** Design DOH Runtime Build Process (active)
- **T030** Fix Critical Architecture References (T034 Phase 1) - COMPLETED
- **T027** Implement Markdown Linting System - COMPLETED
- **T022** DOH System Self-Hosting Project (foundation work)
- **T024** Comprehensive Testing Framework Implementation
- **T021** Intelligent Template System
- **T020** Enhanced Codebase Analysis Engine
- **T019** DOH System Integration Testing
- **T017** Bash Routine Expansion Analysis
- **T011** GitHub/GitLab Synchronization Implementation
- **T010** Universal Command `/doh`
- **T009** Optimized Templates
- **T008** CLAUDE.md Integration & Strategy Detection
- **T007** Automatic Epic #0 Graduation
- **T006** Intelligent Complexity Analysis
- **T005** Installation/Distribution Scripts
- **T003** Complete Architecture & Distribution System

---

## TODOs

### T001 - DOH Skeleton Implementation & Methodology Enforcement 🚩🚩

**Status**: Ready to implement  
**Priority**: CRITICAL - Blocks T002 development and methodology enforcement  
**Dependencies**: None  
**Target Version**: 1.4.0

Create standardized `.doh/` skeleton structure that enforces strict DOH project management methodology and enables
memory context for all `/doh` commands. The skeleton serves as the foundation for methodology compliance and intelligent
project context.

**Impact**: Currently `/doh:init` and `/doh:analyze` lack standard templates, causing inconsistent .doh setups and
preventing proper DOH methodology enforcement. Without skeleton structure, `/doh` commands cannot maintain memory
context or enforce disciplined project management workflow vs free-form Claude interactions.

**Core Architecture Requirements**:

**DOH Methodology Enforcement**:

- **Structural Discipline**: Enforces PRD → Epic → Feature → Task hierarchy
- **Process Compliance**: All `/doh` commands must follow DOH workflow standards
- **Traceability Mandates**: Every work item connects to business objectives
- **Memory Context**: Persistent project intelligence vs ephemeral Claude interactions
- **Workflow Guidance**: Built-in methodology coaching and compliance checking

**Memory Context Foundation**:

- **Project Persistence**: Commands build on accumulated project knowledge
- **Decision Tracking**: Memory system preserves rationale and context
- **Session Continuity**: Command interactions maintain state across time
- **Team Coordination**: Shared memory enables collaborative project management

**Tasks**:

#### Phase 1: Core Skeleton Structure (1.5h)

- [ ] **Create `.claude/doh/skel/` directory structure** with complete DOH hierarchy
- [ ] **Design `project-index.json` schema** with methodology compliance fields
    - Project metadata, epic tracking, methodology version, compliance flags
- [ ] **Create structured `.gitignore`** with DOH-specific sections and methodology protection
- [ ] **Establish memory architecture** with project/, epics/, agent-sessions/ foundations

#### Phase 2: Methodology Templates (2h)

- [ ] **Create Epic #0 template** (`epics/quick/epic0.md`) with DOH methodology guidance
- [ ] **Design task templates** with mandatory traceability and status discipline
- [ ] **Create feature templates** with epic connections and deliverable tracking
- [ ] **Build methodology documentation** embedded in skeleton structure

#### Phase 3: Memory & Context System (1.5h)

- [ ] **Design memory initialization** for project context establishment
- [ ] **Create context loading mechanisms** for `/doh` command execution
- [ ] **Build memory update protocols** for maintaining project state
- [ ] **Implement session continuity** for command interaction history

#### Phase 4: Command Integration (2h)

- [ ] **Update `/doh:init` command** to use skeleton with methodology enforcement
- [ ] **Add methodology compliance validation** to skeleton deployment
- [ ] **Create migration strategy** for existing `.doh/` projects
- [ ] **Build methodology coaching features** into command responses

#### Phase 5: Testing & Validation (1.5h)

- [ ] **Test skeleton deployment** on new projects with methodology validation
- [ ] **Validate memory context loading** across multiple command sessions
- [ ] **Test methodology enforcement** with various command scenarios
- [ ] **Verify backward compatibility** with existing DOH projects

#### Phase 6: Documentation & Integration (1h)

- [ ] **Update command documentation** to reflect methodology enforcement
- [ ] **Create skeleton usage guide** with DOH workflow examples
- [ ] **Document memory context architecture** for future development

**Methodology Compliance Features**:

**Structural Enforcement**:

- All tasks MUST belong to an epic (Epic #0 or dedicated epic)
- All epics MUST follow DOH template structure with proper documentation
- All features MUST connect to epics and contain structured task breakdown
- Project structure MUST maintain proper hierarchy and traceability

**Process Enforcement**:

- Status transitions MUST follow DOH workflow (PROPOSED → IN PROGRESS → COMPLETED)
- Task completion MUST update epic progress and memory context
- Epic graduation MUST be suggested when Epic #0 exceeds threshold
- Memory context MUST be updated with every significant project decision

**Quality Assurance**:

- Templates MUST include methodology guidance and examples
- Validation MUST check for proper DOH structure compliance
- Memory system MUST preserve decision rationale and project evolution
- Commands MUST provide methodology coaching when structure issues detected

**Performance Targets**:

- Skeleton deployment: <5 seconds for complete project initialization
- Memory context loading: <200ms for typical project state
- Methodology validation: <100ms for structure compliance checking
- Command execution: Context-aware responses within standard performance limits

**Success Criteria**:

- All `/doh` commands enforce strict methodology compliance
- Memory context provides persistent project intelligence across sessions
- Skeleton enables consistent DOH project structure across all users
- Methodology coaching guides users toward best practices automatically
- Template structure scales from personal projects to team collaboration

**Deliverable**: Complete DOH skeleton system with methodology enforcement, memory context architecture, and integrated
command foundation that transforms `/doh` commands into disciplined project management workflow vs free-form
interactions.

---

### T002 - Codebase Reverse Engineering (/doh:analyze) 🚩

**Status**: Not started  
**Priority**: High - Critical for /doh adoption on existing projects  
**Dependencies**: T001 (skeleton structure)  
**Proposed Version**: 1.5.0

Create `/doh:analyze` command that analyzes existing codebases and suggests Epic/PRD structure for teams adopting /doh
on legacy projects.

**Impact**: Enable /doh adoption without manual Epic/PRD creation. Essential for onboarding teams with existing
codebases.

**Tasks**:

- [ ] Create `/doh:analyze` command specification
- [ ] Implement static code analysis for module boundaries
- [ ] Add git log analysis for feature patterns
- [ ] Create technology stack detection
- [ ] Implement safety checks for existing .doh projects
- [ ] Add suggested structure generation
- [ ] Create comprehensive safety warnings

**Deliverable**: AI-powered codebase analysis command ready for production use.

---

### T003 - Complete Architecture & Distribution System 🚩

**Status**: Architecture scattered  
**Priority**: High - Required for /doh distribution  
**Dependencies**: T001 (skeleton)

Consolidate scattered /doh components into distributable package with installation system.

**Impact**: Currently /doh components are scattered across project making distribution impossible. Blocks /doh adoption
by other teams.

**Tasks**:

- [ ] Design distribution package structure
- [ ] Create installation script (install.sh)
- [ ] Create uninstallation script (uninstall.sh)
- [ ] Package all /doh components
- [ ] Create example projects
- [ ] Test installation on clean systems

**Deliverable**: Distributable /doh system package with bulletproof installation.

---

### T004 - File System Structure Validation 🚩

**Status**: Needs validation  
**Priority**: High - Blocking next features  
**Dependencies**: None

Validate current /doh file structure against specifications to identify inconsistencies between documented architecture
and actual implementation.

**Impact**: Inconsistencies between spec and reality could block future features and cause integration issues.

**Tasks**:

- [ ] Audit `.claude/doh/.cache` vs `index.json` transition
- [ ] Verify `.doh/memory/` folder structure implementation
- [ ] Check template vs real usage consistency
- [ ] Complete mapping of all current /doh files
- [ ] Test hierarchical memory loading system

**Deliverable**: Complete audit report with reorganization plan.

---

### T005 - Installation/Distribution Scripts 🚩

**Status**: Not started  
**Priority**: High - Required for /doh distribution  
**Dependencies**: T003 (distribution system)

Create complete install/publish/update workflow for /doh system distribution.

**Impact**: Currently no installation workflow exists, blocking /doh adoption by other teams.

**Tasks**:

- [ ] Create `/doh:install` command for new project installation
- [ ] Enhance `/doh:init` with smart detection and re-indexing
- [ ] Create `/doh:update` command for system updates
- [ ] Create backup/restore commands (`export-project`, `import-project`)
- [ ] Create `/doh:reset-project` for cleanup
- [ ] Create `/doh:publish-system` for distribution

**Deliverable**: Complete lifecycle management with 1-command installation.

---

### T011 - GitHub/GitLab Synchronization Implementation 🚩

**Status**: Specified, needs implementation  
**Priority**: High - Critical for team collaboration  
**Dependencies**: T001 (skeleton), T004 (validation)

Implement bidirectional GitHub/GitLab synchronization from existing specifications.

**Impact**: Teams need GitHub issue sync for proper collaboration and tracking.

**Tasks**:

- [ ] Implement `/doh:sync-github` command from specification
- [ ] Create automatic !123 → #456 mapping system
- [ ] Implement conflict management and resolution
- [ ] Add sync state tracking and dirty/clean timestamps
- [ ] Create sync validation and error handling
- [ ] Test with real GitHub/GitLab repositories

**Deliverable**: Production-ready bidirectional synchronization system.

---

### T012 - Centralized Dependency Management 🚩

**Status**: Partially implemented  
**Priority**: High - Core infrastructure  
**Dependencies**: None

Complete the dependency management system for task/epic relationships.

**Impact**: Dependency tracking is essential for proper project management and agent coordination.

**Tasks**:

- [ ] Enhance existing `/doh:dependency` command
- [ ] Implement dependency validation and circular detection
- [ ] Create dependency visualization tools
- [ ] Add dependency-aware scheduling for agents
- [ ] Integrate with GitHub sync for dependency links

**Deliverable**: Complete dependency management with validation and visualization.

---

### T006 - Intelligent Complexity Analysis

**Status**: Concept defined  
**Priority**: Medium - Enhances `/doh:quick`  
**Dependencies**: T001 (skeleton)

Create clarifying questions system for complex task analysis.

**Impact**: Improves task creation quality by detecting scope and complexity automatically.

**Tasks**:

- [ ] Implement simple/complex scope detection
- [ ] Create automatic clarifying questions system
- [ ] Add phasing vs upgrading recommendations
- [ ] Integrate with `/doh:quick` command

**Deliverable**: Intelligent analysis that asks smart questions for better task definition.

---

### T007 - Automatic Epic #0 Graduation

**Status**: Concept defined  
**Priority**: Medium - Improves organization  
**Dependencies**: T001 (skeleton), T006 (analysis)

Detect when Epic #0 becomes too specialized and suggest dedicated epics.

**Impact**: Prevents Epic #0 from becoming cluttered while maintaining ease of use.

**Tasks**:

- [ ] Define graduation thresholds (6+ related tasks)
- [ ] Create epic suggestion interface
- [ ] Implement automatic task migration to new epics
- [ ] Add graduation notifications and recommendations

**Deliverable**: Intelligent epic creation suggestions with automatic migration.

---

### T008 - CLAUDE.md Integration & Strategy Detection

**Status**: Concept defined  
**Priority**: Medium - Improves onboarding  
**Dependencies**: T001 (skeleton), T005 (installation)

Create flexible DOH integration levels with automatic project detection.

**Impact**: Makes /doh adoption easier with appropriate configuration per project type.

**Tasks**:

- [ ] Implement worktree strategy detection
- [ ] Create DOH levels (0-4: Minimal to Enterprise)
- [ ] Add smart auto-detection (language, project type, git remote)
- [ ] Create interactive configuration mode
- [ ] Generate appropriate CLAUDE.md sections per level

**Deliverable**: Flexible DOH configuration with intelligent project analysis.

---

### T009 - Optimized Templates

**Status**: Need identified  
**Priority**: Low - Quality improvement  
**Dependencies**: T001 (skeleton)

Create tiered templates for faster task/epic creation.

**Impact**: Current templates are too verbose, slowing down task creation.

**Tasks**:

- [ ] Create micro template (10 lines) for simple tasks
- [ ] Create mini template (30 lines) for standard tasks
- [ ] Create standard template (60 lines) for epics/features
- [ ] Integrate template selection in creation commands

**Deliverable**: Faster creation workflow with size-appropriate templates.

---

### T010 - Universal Command `/doh`

**Status**: Emerging concept  
**Priority**: Low - Future enhancement  
**Dependencies**: T006 (analysis), T002 (analyze)  
**Target Version**: 2.0.0

Create universal intelligent contextualization command.

**Impact**: Provides "it's obvious" moments - right context at right time for both humans and AI.

**Tasks**:

- [ ] Implement natural language intent recognition
- [ ] Create context-aware response system
- [ ] Add intelligent suggestions and next steps
- [ ] Integrate with all existing /doh commands

**Deliverable**: Universal command that understands intent and provides perfect context.

---

### T014 - DOH Data Structure Analysis for Scripting

**Status**: Not started  
**Priority**: Medium - Foundation for performance optimization  
**Dependencies**: None  
**Proposed Version**: 1.5.0

Analyze and document DOH data structures to identify optimal patterns for bash script automation and determine
standardization needs.

**Impact**: Current DOH data structures may not be optimized for bash parsing. Understanding the data patterns, file
formats, and access patterns will enable efficient script creation and identify potential structure improvements.

**Tasks**:

- [ ] Audit current data structures (project-index.json, MD files, memory files)
- [ ] Map all data access patterns currently requiring Claude calls
- [ ] Identify complex vs simple data extraction operations
- [ ] Document JSON schema patterns and nested structures
- [ ] Analyze file naming conventions and directory structures
- [ ] Identify inconsistencies or parsing difficulties in current formats
- [ ] Recommend data structure optimizations for bash-friendly access
- [ ] Create data access frequency analysis (which operations are most common)
- [ ] Design standardized interfaces for script-friendly data access
- [ ] Prototype key data extraction patterns with bash/jq

**Deliverable**: Comprehensive analysis document with data structure documentation, bash-scripting recommendations, and
standardized data access patterns ready for T013 implementation.

---

### T015 - DOH Configuration File Design

**Status**: Not started  
**Priority**: Medium - Foundation for flexible configuration  
**Dependencies**: None  
**Proposed Version**: 1.5.0

Design and brainstorm a configuration file system for .doh projects to standardize settings, preferences, and
project-specific behaviors.

**Impact**: Currently DOH behavior is hardcoded or scattered across multiple files. A centralized config system would
enable project-specific customization, better defaults, and easier script automation while maintaining consistency.

**Tasks**:

- [ ] Analyze current configuration patterns in DOH (index metadata, CLAUDE.md, etc.)
- [ ] Research configuration file formats (JSON, YAML, TOML, .env) and choose optimal
- [ ] Define configuration categories (project settings, script behavior, sync preferences)
- [ ] Design configuration hierarchy (global → project → local overrides)
- [ ] Specify configuration schema and validation rules
- [ ] Determine configuration file location (.doh/config.json vs .doh/doh.conf)
- [ ] Plan integration with bash scripts and Claude commands
- [ ] Design configuration management commands (get/set/list config)
- [ ] Create configuration file template for skeleton
- [ ] Document configuration options and examples

**Configuration Categories to Consider**:

- **Project Settings**: Default language, naming conventions, sync targets
- **Script Behavior**: Performance tracking, fallback preferences, logging level
- **Template Preferences**: Default templates, custom fields, auto-categorization
- **Integration Settings**: GitHub/GitLab tokens, webhook URLs, notification preferences
- **Development Preferences**: Debug mode, validation strictness, backup policies

**Deliverable**: Configuration file specification with schema, template for skeleton, and integration plan for scripts
and Claude commands.

---

### T016 - DOH Configuration Integration Validation

**Status**: Not started  
**Priority**: High - Ensure config system actually works  
**Dependencies**: T015 (configuration design)  
**Proposed Version**: 1.5.0

Verify that the configuration system (config.ini + doh-config.sh) integrates properly with existing DOH codebase and
scripts.

**Impact**: The new configuration system must work seamlessly with current DOH commands, scripts, and workflows. Need to
ensure existing functionality isn't broken and configuration is properly utilized.

**Tasks**:

- [ ] Audit existing DOH scripts/commands for hardcoded values that should use config
- [ ] Update existing bash scripts to load and use doh-config.sh library
- [ ] Integrate config loading in get-item.sh, project-stats.sh, and other utilities
- [ ] Test configuration overrides work correctly (debug_mode, performance_tracking, etc.)
- [ ] Verify config.ini is properly created by /doh:init skeleton deployment
- [ ] Test config-manager.sh get/set/list operations on real project
- [ ] Validate config parsing with edge cases (empty values, missing sections, invalid syntax)
- [ ] Check config integration with existing environment variables (DOH_DEBUG, DOH_QUIET)
- [ ] Update existing commands to respect configuration settings
- [ ] Test end-to-end workflow: init project → modify config → run scripts

**Configuration Integration Points**:

- **Script behavior**: Debug mode, quiet mode, performance tracking should work
- **Sync settings**: GitHub/GitLab config should be readable by sync commands
- **Project metadata**: Config.ini project.name should sync with project-index.json
- **Environment variables**: Config should override or complement env vars
- **Error handling**: Graceful fallback when config missing or corrupted

**Deliverable**: Fully integrated configuration system that works with all existing DOH functionality, with
comprehensive testing and validation of real-world usage.

---

### T017 - Bash Routine Expansion Analysis 🚩🚩 (EPIC Phase 1)

**Status**: COMPLETED  
**Priority**: High - Capitalize on T013 POC success  
**Dependencies**: T013 (bash scripts), T014 (data structure analysis)  
**Proposed Version**: 1.5.0  
**Epic**: E047 Natural Language & Performance Optimization

Analyze current DOH command usage patterns and identify next batch of bash routine candidates to maximize token savings
and performance gains.

**Impact**: T013 POC proved bash optimization delivers 150-500x performance gains and 100% token savings for routine
operations. Need systematic analysis to identify which additional operations should be bash-scripted next for maximum
ROI.

**Tasks**:

- [ ] Audit current Claude command usage patterns in typical DOH workflows
- [ ] Identify high-frequency operations not yet bash-optimized (search, update, validate)
- [ ] Analyze complexity vs benefit ratio for medium-priority operations from T014
- [ ] Map dependencies between operations (which scripts enable other scripts)
- [ ] Prioritize next 5-10 bash routine candidates by frequency × token savings
- [ ] Estimate development effort vs savings for each candidate
- [ ] Create implementation roadmap with quick wins vs strategic investments
- [ ] Document bash routine architecture patterns for consistent implementation
- [ ] Define testing strategy for bash routine quality assurance
- [ ] Plan integration with existing lib/doh.sh unified library

**Candidate Operations Analysis**: Based on T014 findings, analyze these operation categories:

- **Search Operations**: `search-tasks.sh`, `find-by-title.sh`, `grep-content.sh`
- **Update Operations**: `update-status.sh`, `update-metadata.sh`, `batch-update.sh`
- **Validation Operations**: `validate-structure.sh`, `check-dependencies.sh`, `lint-markdown.sh`
- **File Operations**: `list-files.sh`, `count-by-type.sh`, `recent-changes.sh`
- **Query Operations**: `epic-tasks.sh`, `status-summary.sh`, `dependency-graph.sh`

**Deliverable**: Prioritized roadmap for next wave of bash routine implementation with effort estimates, ROI
calculations, and implementation patterns for consistent script development.

---

### T019 - DOH System Integration Testing 🚩🚩

**Status**: Proposed  
**Priority**: CRITICAL - Foundation validation before T002  
**Dependencies**: T001 (skeleton), T018 (path resolution)  
**Proposed Version**: 1.4.0

Create comprehensive integration test suite to validate that all completed components work together seamlessly before
building T002 (codebase analysis).

**Impact**: With T001, T015, T016, T018 completed, we need validation that skeleton deployment, path resolution,
configuration system, and UUID generation work together across different environments.

**Tasks**:

- [ ] Create test suite for skeleton deployment in various environments
- [ ] Test path resolution across symlinks, .private, bind mounts
- [ ] Validate UUID generation and project identity system
- [ ] Test configuration system with different INI scenarios
- [ ] Create automated test runner for CI/CD compatibility
- [ ] Test cross-environment compatibility (different users, paths, filesystems)
- [ ] Validate error handling and graceful degradation
- [ ] Performance testing for path resolution in large directory trees

**Deliverable**: Battle-tested DOH foundation ready for T002 codebase analysis implementation.

---

### T020 - Enhanced Codebase Analysis Engine 🚩 (EPIC Phase 1)

**Status**: Proposed  
**Priority**: High - Builds on T002 specification  
**Dependencies**: T001 (skeleton), T018 (path resolution), T019 (integration tests), T028 (dev environment)  
**Proposed Version**: 1.5.0  
**Epic**: E047 Natural Language & Performance Optimization

Implement the `/doh:analyze` command with advanced codebase analysis capabilities beyond the original T002
specification.

**Impact**: Enable teams to adopt DOH on existing codebases with intelligent epic/task structure suggestions based on
code analysis, git history, and architectural patterns.

**Tasks**:

- [ ] Implement static code analysis for module boundaries and dependencies
- [ ] Add git log analysis for feature patterns and team workflows
- [ ] Create technology stack detection (frameworks, languages, tools)
- [ ] Build architectural pattern recognition (MVC, microservices, monolith)
- [ ] Implement team collaboration pattern analysis (PR patterns, commit frequency)
- [ ] Add complexity analysis (cyclomatic complexity, file sizes, coupling)
- [ ] Create suggested epic structure generation based on analysis
- [ ] Add safety checks and validation for existing .doh projects
- [ ] Build interactive mode for refining suggestions
- [ ] Create analysis reporting and visualization

**Enhanced Features Beyond T002**:

- **AI-Driven Insights**: Use pattern recognition for better epic suggestions
- **Team Analytics**: Analyze collaboration patterns to suggest team structure
- **Technical Debt Analysis**: Identify refactoring opportunities as potential epics
- **Performance Analysis**: Identify performance bottlenecks as optimization epics

**Deliverable**: Production-ready `/doh:analyze` command that provides intelligent codebase analysis and epic structure
recommendations for seamless DOH adoption.

---

### T021 - Intelligent Template System 🚩

**Status**: Future  
**Priority**: High - Enhances T009 with AI capabilities  
**Dependencies**: T020 (codebase analysis), T018 (path resolution)  
**Target Version**: 2.0.0

Create an intelligent template system that adapts to project context, technology stack, and team patterns discovered by
codebase analysis.

**Impact**: Replace static templates with context-aware templates that adapt to the specific project, reducing friction
and improving adoption by providing relevant, tailored content.

**Tasks**:

- [ ] Build template engine with variable substitution and conditional sections
- [ ] Create technology-specific template variants (React, Symfony, Python, etc.)
- [ ] Implement team-size aware templates (solo, small team, enterprise)
- [ ] Add complexity-aware templates (micro/mini/standard/enterprise)
- [ ] Create domain-specific templates (web app, API, CLI tool, library)
- [ ] Build template inheritance system for composition
- [ ] Add template validation and testing framework
- [ ] Create template marketplace/registry concept
- [ ] Implement template analytics (usage patterns, success rates)
- [ ] Add interactive template customization wizard

**Template Categories**:

- **Smart Micro** (≤5 lines): AI-generated based on context
- **Adaptive Mini** (≤20 lines): Technology and team-aware
- **Context Standard** (≤50 lines): Full features adapted to project
- **Enterprise Complete** (≤100 lines): Compliance and process-aware

**Deliverable**: Context-aware template system that dramatically reduces template verbosity while increasing relevance
and adoption rates.

---

### T022 - DOH System Self-Hosting Project 🚩🚩

**Status**: Proposed  
**Priority**: CRITICAL - Foundation for distribution and testing  
**Dependencies**: T013 (completed), T018 (completed), T026 (restructure)  
**Proposed Version**: 1.4.0

Create the DOH system as its own standalone project that uses DOH to manage its own development (self-hosting), with
comprehensive testing framework and proper distribution architecture.

**Impact**: DOH currently lives inside another project. Creating DOH as its own project enables proper distribution
(T003), serves as reference implementation, and provides isolated testing environment. The DOH system should "eat its
own dog food" by using DOH to manage DOH development.

**Tasks**:

- [ ] Design standalone DOH project architecture with subfolders
- [ ] Create testing framework structure (unit, integration, e2e, performance)
- [ ] Set up DOH core system folders (bin/, lib/, scripts/, tests/, docs/)
- [ ] Implement DOH installer/uninstaller scripts
- [ ] Copy and reorganize current DOH components from existing project
- [ ] Initialize DOH within DOH project (meta-initialization)
- [ ] Create DOH development epics (Core, Testing, Distribution, Documentation)
- [ ] Migrate existing TODO items to proper DOH tasks
- [ ] Set up test harness with multiple test projects
- [ ] Create CI/CD friendly test runner
- [ ] Build distribution packaging system
- [ ] Implement version management and release process

**Architecture Proposal**:

```text
doh-system/
├── .doh/             # RESERVED - Only for production DOH self-management
│   └── (initialized only when DOH is ready for production use)
├── bin/              # Executable scripts
│   ├── doh-init
│   ├── doh-admin
│   └── doh
├── lib/              # Core libraries
│   ├── doh.sh
│   ├── doh-config.sh
│   └── doh-wrappers.sh
├── scripts/          # Utility scripts
│   ├── performance/
│   ├── migration/
│   └── utilities/
├── tests/            # Comprehensive test suite
│   ├── unit/         # Unit tests
│   ├── integration/  # Integration tests
│   ├── e2e/         # End-to-end tests
│   ├── performance/ # Performance benchmarks
│   ├── fixtures/    # Test fixtures and data
│   └── projects/    # Test projects (NEVER use .doh in tests!)
│       ├── minimal/ # Minimal test project
│       │   └── test-data/ # Test data instead of .doh
│       ├── standard/ # Standard test project
│       │   └── test-data/ # Test data instead of .doh
│       └── complex/ # Complex test project
│           └── test-data/ # Test data instead of .doh
├── templates/       # DOH templates
│   ├── epics/
│   ├── tasks/
│   └── skeleton/
├── docs/            # Documentation
│   ├── api/         # API documentation
│   ├── guides/      # User guides
│   └── architecture/ # System architecture
├── install.sh       # Installation script
├── uninstall.sh     # Uninstallation script
└── Makefile         # Build/test automation
```

**Testing Framework Features**:

- **Test Projects**: Multiple preconfigured test projects in tests/projects/
- **Test Data Isolation**: Use test-data/ folders, NEVER .doh/ in tests
- **Mock DOH Structure**: Simulate DOH behavior without using .doh directory
- **Fixture Management**: Reusable test data and configurations
- **Performance Baselines**: Track performance regression
- **Cross-Environment**: Test on different shells, OS, filesystems
- **Coverage Reporting**: Measure test coverage of bash scripts
- **CI/CD Integration**: GitHub Actions, GitLab CI ready
- **Isolated Testing**: Each test runs in clean environment
- **Temporary Test Dirs**: Use /tmp for actual .doh testing when needed

**Distribution Features**:

- **Single Command Install**: `curl -sSL https://get.doh.dev | bash`
- **Package Managers**: Support for apt, yum, brew, npm
- **Portable Archive**: tar.gz with all dependencies
- **Version Management**: Semantic versioning with upgrade path
- **Dependency Checking**: Verify jq, git, bash version
- **Multi-Platform**: Linux, macOS, WSL support

**Deliverable**: Standalone DOH system project that is self-hosting, fully tested, and ready for distribution. Serves as
both the development environment for DOH and the reference implementation for DOH best practices.

---

### T024 - Comprehensive Testing Framework Implementation 🚩

**Status**: Proposed  
**Priority**: High - Foundation for reliable DOH system  
**Dependencies**: T028 (dev environment for testing automation)  
**Proposed Version**: 1.4.0

Implement comprehensive dual testing framework: zero-credential CI/CD tests + local Claude-dependent tests with
memory-safe coverage tracking.

**Impact**: Currently DOH lacks systematic testing framework. This blocks reliable development, deployment, and prevents
regression detection. A comprehensive testing system is essential for DOH production readiness.

**Tasks**:

- [ ] Implement CI/CD compatible test suite (zero credentials, zero API costs)
- [ ] Create static analysis pipeline (ShellCheck, syntax validation, JSON validation)
- [ ] Build unit test framework for bash functions and scripts
- [ ] Implement integration tests for bash-only workflows
- [ ] Create performance benchmark suite for T013 bash optimizations
- [ ] Design local testing framework for Claude-dependent functionality
- [ ] Implement mock Claude system for development testing
- [ ] Create end-to-end workflow tests with controlled Claude budget
- [ ] Build coverage registry system (guidance-only, not enforcement)
- [ ] Implement Claude-managed memory-safe coverage analysis
- [ ] Create test project fixtures and data isolation system
- [ ] Set up cross-platform testing (Linux, macOS, Windows)

**Architecture**:

```text
./tests/
├── ci/                      # Zero-credential CI/CD tests
│   ├── static/             # ShellCheck, syntax, JSON validation
│   ├── unit/               # Pure bash unit tests
│   ├── integration/        # Bash-only integration tests
│   └── performance/        # Bash optimization benchmarks
├── local/                  # Claude-dependent local tests
│   ├── claude/             # Claude integration tests
│   ├── e2e/               # End-to-end workflows
│   └── fixtures/          # Claude response mocks
├── coverage/               # Coverage tracking (guidance only)
│   ├── registry.json      # Simple coverage tracker
│   ├── memory/            # Claude analysis memory
│   └── dashboard.sh       # Coverage guidance
└── helpers/                # Test framework utilities
    ├── test-framework.sh   # Core testing functions
    ├── assertions.sh       # Test assertions
    └── claude-mock.sh      # Claude response mocking
```

**Testing Categories**:

**CI/CD Tests (Free, Automated)**:

- Static analysis and linting
- Pure bash function unit tests
- Bash script integration tests
- Performance benchmarks vs mocked operations
- Cross-platform compatibility
- JSON schema validation
- File structure integrity

**Local Tests (Paid, Developer-Controlled)**:

- Claude API integration validation
- Bash→Claude fallback mechanism testing
- End-to-end user workflow testing
- Real Claude response format validation
- Budget-controlled comprehensive scenarios

**Coverage System**:

- Simple JSON registry for tracking coverage percentages
- Claude-managed memory-safe analysis (avoids "already analyzed" redundancy)
- Guidance-only approach (no enforcement, no commit blocking)
- Coverage dashboard and suggestions
- Gap identification and test recommendations

**Benefits**:

- **95% test coverage** from free CI/CD tests
- **5% critical validation** from controlled local tests
- **Zero API costs** in CI/CD pipeline
- **No credentials required** for automated testing
- **Air-gap compatible** CI/CD system
- **Cross-platform validated** bash compatibility
- **Memory-safe coverage** tracking with Claude intelligence
- **Developer-friendly** guidance without enforcement

**Deliverable**: Complete dual testing framework with comprehensive CI/CD automation, local Claude testing capabilities,
and intelligent coverage guidance system ready for production DOH development.

---

### T027 - Implement Markdown Linting System ✅

**Status**: COMPLETED ✅ (2025-08-27)  
**Priority**: Medium - Code quality and consistency  
**Dependencies**: T026 (restructure - optional)  
**Version**: 1.4.0 **Tags**: `#quality` `#automation`

Implement a comprehensive Markdown linting system for DOH project to ensure consistent documentation quality, style, and
standards across all .md files.

**Impact**: DOH has extensive Markdown documentation (TODO.md, CHANGELOG.md, docs/, analysis/, etc.) without consistent
style enforcement. A linting system ensures professional documentation quality, catches errors, and maintains
consistency for contributors.

**Technology Decision**: ✅ **markdownlint-cli** (Node.js)

- Chosen for development toolchain (DOH System Development)
- No impact on runtime distribution (stays 100% bash + jq + awk)
- Industry standard with comprehensive rule set
- Excellent CI/CD integration for T024 testing framework

**Tasks**:

- [x] **Technology evaluation**: ✅ markdownlint-cli chosen
- [ ] **Standards definition**: Define DOH Markdown style guide and rules
- [ ] **Configuration creation**: Create linter config file with DOH-specific rules
- [ ] **Tool installation**: Set up chosen linter in project
- [ ] **Integration setup**: Add to package.json/Makefile scripts
- [ ] **CI/CD integration**: Add linting to automated testing pipeline
- [ ] **Pre-commit hooks**: Optional pre-commit markdown validation
- [ ] **Existing files audit**: Run linter on current files and fix issues
- [ ] **Documentation**: Add linting guide to development docs
- [ ] **Testing**: Validate linter catches common markdown issues

**Configuration Considerations**:

- **Line length**: 80/120 chars vs unlimited
- **Headers**: Consistent # spacing, hierarchy validation
- **Lists**: Consistent bullet style, indentation
- **Links**: Validate internal/external link formats
- **Code blocks**: Language specification requirements
- **Tables**: Formatting consistency
- **Trailing whitespace**: Remove vs allow
- **File ending**: Newline requirements

**Integration Options**:

- **Local only**: Manual `npm run lint:md` execution
- **Pre-commit**: Automatic validation before git commits
- **CI/CD**: Automated checking in testing pipeline
- **Editor integration**: VSCode/IDE real-time linting

**Benefits**:

- Consistent documentation style across all contributors
- Catch markdown syntax errors before they reach users
- Professional documentation quality for DOH distribution
- Automated quality enforcement without manual review burden
- Better readability and maintainability of documentation

**Risks & Considerations**:

- May require fixing many existing files initially
- Need balance between strict rules and contributor friction
- Technology choice affects maintenance burden
- Integration complexity with existing DOH toolchain

**Deliverable**: Production-ready Markdown linting system integrated into DOH development workflow with comprehensive
style guide and automated enforcement.

**Completion Summary**:

- ✅ **markdownlint-cli** installed and configured with DOH-specific rules
- ✅ **Makefile integration**: `make lint`, `make lint-fix`, `make lint-manual` commands operational
- ✅ **Pre-commit hooks**: Automatic markdown quality validation on git commit
- ✅ **Style guide**: Complete DOH Markdown standards documented in `docs/markdown-style-guide.md`
- ✅ **Development workflow**: Integrated linting workflow documented in `DEVELOPMENT.md`
- ✅ **Configuration**: Custom `.markdownlint.json` with 120-char line length, 4-space indentation
- ✅ **Quality enforcement**: All markdown files subject to automated quality control

**Impact**: DOH now maintains consistent, professional documentation quality with automated enforcement, reducing manual
review overhead and ensuring clean, readable documentation for distribution.

---

### T030 - Fix Single Source of Truth violations in CLAUDE.md after T026 completion

**Status**: ✅ COMPLETED  
**Priority**: HIGH - Critical for 1.4.0 release consistency  
**Dependencies**: T026 (restructuring completion ✅), T034 (analysis completed ✅)  
**Version**: 1.4.0 **Tags**: `#doc` **Analysis**: Part of `analysis/T034-documentation-health-report.md`

Fix Single Source of Truth violations in CLAUDE.md and execute critical architecture reference cleanup identified by
T034 comprehensive documentation audit. This is now a critical 1.4.0 blocker due to 89 outdated architecture references
found.

**Impact**: T034 analysis revealed critical issues beyond CLAUDE.md - 89 outdated architecture references across 15
files create user confusion and command failures. This expanded scope makes it a 1.4.0 release blocker.

**Critical Issues Identified by T034**:

1. **Architecture References (89 total across 15 files)**:
   - "skel/" references: 47 occurrences
   - "templates/" references: 31 occurrences
   - "controlled duplication": 11 occurrences
   - Files: CONTRIBUTING.md, docs/architecture.md, TODO.md, TODOARCHIVED.md, .claude/commands/doh/init.md, others

2. **Version Inconsistencies**:
   - JSON examples using "version": "1.0.0" instead of "1.4.0"
   - Mixed version references across documentation
   - Files: docs/architecture.md:112, analysis/T014-data-structure-analysis.md:39, .claude/commands/doh/agent.md:392

3. **Most Critical Files (per T034)**:
   - CONTRIBUTING.md:90 - Shows old project structure with `skel/`
   - docs/architecture.md:30,34 - References `.claude/doh/templates/`
   - .claude/commands/doh/init.md:216-217 - References old structure

4. **Impact Assessment**:
   - User confusion from inconsistent structure information
   - Command failures from references to non-existent paths
   - Maintenance burden from multiple sources of truth
   - Risk of information drift and inconsistency

**Tasks (T034 Phase 1 - Critical Architecture Cleanup)**:

**High Priority (1.4.0 Blockers)**:

- [ ] **CONTRIBUTING.md:90** - Fix project structure section showing old `skel/` structure
- [ ] **docs/architecture.md:30,34** - Remove references to `.claude/doh/templates/`
- [ ] **CLAUDE.md** - Remove outdated DOH system structure and duplicated planning sections
- [ ] **.claude/commands/doh/init.md:216-217** - Update structure references
- [ ] **Version consistency** - Update JSON examples from "1.0.0" to "1.4.0" in 3 files

**Medium Priority (Quality)**:

- [ ] **TODO.md architecture sections** - Add deprecation notices to old strategy references
- [ ] **TODOARCHIVED.md** - Add clear deprecation notices for controlled duplication strategy
- [ ] **Cross-reference audit** - Scan remaining 10 files with architecture references
- [ ] **Navigation improvements** - Add document map to README.md per T034 recommendations

**Proposed CLAUDE.md Changes**:

Replace sections with:

```markdown
## DOH System Structure

📁 **Current Structure**: See `TODO.md` T026 for complete system organization and migration status.

## Task Management

This project uses traditional TODO.md (in project root) for development tasks rather than the /doh system it provides to
other projects.

📋 **Version Management Rules**: See `TODO.md` section "TODO Management" 📁 **System Structure**: See `TODO.md` T026 for
current organization
```

**Single Source of Truth Enforcement**:

- TODO.md = Source of truth for development tasks, planning, and system structure
- CLAUDE.md = Configuration and brief references only
- No duplication of detailed information between files

**Benefits**:

- Single maintenance point for system structure
- No risk of information drift between files
- Cleaner CLAUDE.md focused on configuration
- Easier updates when structure evolves

**Deliverable**: CLAUDE.md with all Single Source of Truth violations fixed, containing only brief references to TODO.md
for detailed information, ensuring no duplication of system structure or planning details.

---

### T032 - Design DOH Runtime Build Process (.claude/doh/ as build directory)

**Status**: ACTIVE - Ready for implementation  
**Priority**: Medium - Build system architecture  
**Dependencies**: T031 (architecture decision)  
**Proposed Version**: 1.4.0

Design and implement build process for DOH runtime where `.claude/doh/` contains all runtime components.

**Impact**: Architecture updated - `.claude/doh/` now contains the single source of truth for skel/ and templates/ (no
duplication in project root). Build process focuses on inclaude.md generation from docs/ and maintaining runtime
integrity.

#### Critical Focus: Stable inclaude.md Generation Strategy

For stable version-to-version builds with clean diffs:

**inclaude.md Generation Process**:

1. **Source Analysis**: Read current inclaude.md structure and style
2. **Documentation Mining**: Extract updates from docs/commands.md, docs/architecture.md, WORKFLOW.md
3. **Template Consistency**: Maintain existing sections and formatting patterns
4. **Stable Output**: Ensure deterministic generation (no timestamps, consistent ordering)
5. **Diff Optimization**: Only modify sections that actually changed

**Key Sources for inclaude.md**:

- `docs/commands.md` - Command specifications and natural language usage
- `docs/architecture.md` - Structure, IDs, file organization
- `WORKFLOW.md` - Quick workflow examples
- `.claude/doh/scripts/` - Available runtime commands
- `.claude/commands/` - Claude command implementations and behavior
- `templates/` - Template structure information

**Generation Strategy**:

- Parse existing inclaude.md sections as stable baseline
- Identify which docs sections map to which inclaude.md sections
- Update only changed content, preserve structure and style
- Maintain 2KB optimization target for Claude performance
- Validate generated content matches expected format

**Enhanced Design Questions**:

1. What triggers builds? (version changes, manual, CI/CD)
2. How to validate runtime artifact quality?
3. Should `.claude/doh/` be git-ignored as build output?
4. How to maintain backward compatibility during builds?
5. Which components have been most useful for creating inclaude.md historically?
6. How to ensure deterministic, diff-friendly generation of inclaude.md?

**Revised Architecture Model**:

```text
# Documentation Sources (Project Root)
./docs/                    # Documentation only
./analysis/                # Analysis documents only

# Runtime & Development (.claude/doh/)
.claude/doh/
├── scripts/               # Runtime scripts (100% bash)
├── skel/                  # Skeleton files (single source)
├── templates/             # Template files (single source)
├── inclaude.md           # Generated runtime guide
└── .claude/commands/doh/ # Command implementations
```

**Simplified Build Process**:

1. **No Duplication**: skel/ and templates/ exist only in `.claude/doh/` (single source of truth)

2. **Focus on inclaude.md Generation**:
   - Generate optimized inclaude.md from docs/ sources
   - Maintain skel/ and templates/ directly in .claude/doh/
   - No copying needed for runtime functionality

3. **Build Validation**:
   - Verify inclaude.md generation quality
   - Check skel/ integrity for /doh:init
   - Validate script functionality
   - Test command implementations

4. **Clean Operations**:
   - Regenerate inclaude.md when docs change
   - Update skel/ when skeleton changes
   - No template management needed

**Integration Points**:

**Makefile Integration**:

```makefile
build:          ## Build runtime artifacts from sources
build-clean:    ## Clean build artifacts and rebuild from sources
build-check:    ## Validate build artifacts integrity
build-lint:     ## Lint generated Markdown files in build artifacts
build-test:     ## Test runtime functionality after build
clean:          ## Clean all build artifacts (skel/, templates/ in .claude/doh/)
```

**Development Workflow**:

1. Edit source files (`./skel/config.ini`, `./templates/epic_template.md`)
2. Run `make build` to sync to runtime (copy files + any generation)
3. Run `make build-lint` to lint Claude-generated Markdown (if any)
4. Test with `/doh:init` and DOH agents using built artifacts
5. Commit source files (not build artifacts)
6. Run `make clean` to remove build artifacts if needed

**Clean Process**:

```makefile
clean:  ## Clean build artifacts safely
 @echo "🧹 Cleaning DOH build artifacts..."
 @if [ -d ".claude/doh/skel" ]; then rm -rf .claude/doh/skel && echo "✅ Removed .claude/doh/skel/"; fi
 @if [ -d ".claude/doh/templates" ]; then rm -rf .claude/doh/templates && echo "✅ Removed .claude/doh/templates/"; fi
 @echo "🔒 Preserved: scripts/, inclaude.md"
```

**Clean Safety**:

- Only removes build artifacts (skel/, templates/)
- Preserves essential runtime (scripts/, inclaude.md)
- Validates source files exist before cleaning
- Can be run safely multiple times

**Build Linting Process**:

```makefile
build-lint:  ## Lint Claude-generated Markdown in build artifacts
 @echo "📝 Linting Claude-generated Markdown..."
 # Only lint files that are GENERATED by Claude during build, not copied files
 # Example: if inclaude.md is generated from templates
 @if [ -f ".claude/doh/inclaude.md" ] && [ -f ".claude/doh/.generated" ]; then \
  npx markdownlint .claude/doh/inclaude.md; fi
 @echo "✅ Generated artifacts linted"
```

**Linting Strategy**:

- **Generated files only**: Only lint Markdown that Claude creates during build process
- **Skip copied files**: Simple cp operations don't need linting (source already linted)
- **Detection mechanism**: Use marker files or timestamps to detect generated content
- **Key use case**: If inclaude.md or other files are dynamically generated from templates
- **Smart approach**: No unnecessary linting of identical copied content

**Distribution Model**:

- Package only `.claude/doh/` directory for distribution
- Source files (`./skel/`, `./docs/`) not included in end-user packages
- Self-contained runtime with all dependencies

**Tasks**:

- [ ] **Design build system architecture**: Source → Runtime artifact mapping (skel/, templates/)
- [ ] **Implement Makefile build targets**: build, build-clean, build-check, build-lint, build-test, clean
- [ ] **Add change detection**: Only build when sources change (timestamp/checksum based)
- [ ] **Create build validation**: Verify runtime artifacts integrity and completeness
- [ ] **Implement markdown linting**: Lint generated .md files in build artifacts (T027 integration)
- [ ] **Implement clean process**: Safe removal of build artifacts (.claude/doh/skel/, .claude/doh/templates/) with
      validation
- [ ] **Integration with dev workflow**: Seamless source → build → lint → test cycle
- [ ] **Update .gitignore**: Exclude build artifacts from git (if needed)
- [ ] **Distribution packaging**: Script to package runtime-only for distribution
- [ ] **Documentation**: Build process guide for contributors (build/clean/lint commands)
- [ ] **CI/CD integration**: Automated build validation in T024 testing framework
- [ ] **Performance optimization**: Fast incremental builds with smart caching

**Build System Options to Consider**:

**Option A: Make-based**:

- ✅ Universal, simple, existing Makefile integration
- ✅ Familiar to developers
- ❌ Limited change detection

**Option B: npm scripts**:

- ✅ Good change detection with tools
- ✅ Rich ecosystem
- ❌ Adds Node.js dependency to build

**Option C: Custom bash**:

- ✅ DOH-native, no external deps
- ✅ Full control
- ❌ More implementation work

**Option D: Hybrid (Make + bash utilities)**:

- ✅ Best of both worlds
- ✅ Leverages existing infrastructure
- ✅ Extensible

**Decision Criteria**:

- **Simplicity**: Easy for contributors to understand and use
- **Performance**: Fast incremental builds for development
- **Reliability**: Consistent build results across environments
- **Integration**: Works with existing T028 dev environment
- **Dependencies**: Minimal external tool requirements

**Deliverable**: Complete build system design and implementation that maintains Single Source of Truth while providing
reliable runtime artifacts for DOH distribution and testing.

---

### T033 - Restore skel/ and templates/ to .claude/doh/ runtime directory 🚩

**Status**: COMPLETED ✅  
**Priority**: Medium - Runtime functionality  
**Dependencies**: None - Direct action  
**Version**: 1.4.0 ✅ **Completed**: 2025-08-27

Restore `skel/` and `templates/` directories to `.claude/doh/` to ensure proper runtime access for DOH commands and
`/doh:init` functionality, including cleanup of obsolete/useless templates and skeleton files.

**Implementation Completed**:

✅ **Templates restored to runtime**:

- Copied `./templates/` → `.claude/doh/templates/`
- All 4 template files accessible: epic_template.md, feature_template.md, prd_template.md, task_template.md

✅ **Skeleton updated and synchronized**:

- Synced `./skel/` → `.claude/doh/skel/` with latest source files
- Fixed formatting differences from prettier auto-correction
- Removed obsolete files and updated paths

✅ **Runtime functionality validated**:

- `/doh:init` script accessible and working with skeleton files
- All skeleton files have proper permissions (644)
- DOH commands can access templates for runtime operations
- All runtime dependencies satisfied

**Final Architecture**:

```text
# Development Sources (Single Source of Truth)
./skel/           # Master skeleton files
./templates/      # Master templates
./docs/           # Master documentation

# Runtime Distribution (.claude/doh/) - 25 files total
.claude/doh/
├── scripts/      # Runtime scripts (100% bash + jq + awk)
├── skel/         # Runtime skeleton files (copy of ./skel/)
├── templates/    # Runtime templates (copy of ./templates/)
├── inclaude.md   # Generated runtime guide
└── [libs & bins] # Supporting runtime components
```

**⚠️ ARCHITECTURE DEPRECATION (2025-08-27)**: The "controlled duplication" strategy documented above was **deprecated**
and replaced with **single source of truth** approach. The project root `./skel/` and `./templates/` folders were
**removed** - they now exist **only** in `.claude/doh/` to eliminate duplication and maintenance overhead.

**Cleanup Actions Performed**:

✅ **Obsolete file cleanup**:

- Updated test-deployment.sh with correct paths
- Synchronized epic0.md formatting with source
- Removed outdated template references
- Fixed path inconsistencies in skeleton files

✅ **Template consolidation**:

- Verified all 4 templates are current and functional
- Removed any duplicate or obsolete template files
- Ensured template accessibility for DOH agents

**Validation Results**:

- [x] `/doh:init` functionality works with complete skeleton
- [x] DOH commands can access all templates
- [x] Skeleton files complete and functional
- [x] No runtime dependencies missing
- [x] File permissions preserved (644)
- [x] Useless/obsolete files removed

**Benefits Delivered**:

- **Runtime Access Fixed**: DOH commands now have complete access to skeleton and templates
- **Clean Structure**: Removed obsolete files, synchronized formatting
- **Proper Architecture**: Clear separation between development sources and runtime artifacts
- **Foundation for T032**: Ready for formal build process implementation

**Deliverable**: ✅ COMPLETED Functional runtime directory with complete, clean skel/ and templates/ access for all DOH
operations.

---

### T034 - Documentation Health Check & Content Review

**Status**: ✅ COMPLETED  
**Priority**: Medium - Comprehensive documentation audit  
**Dependencies**: None (can be done independently), T030 (cross-check coordination)  
**Version**: 1.4.0 **Tags**: `#think` **Analysis**: `analysis/T034-documentation-health-report.md`

Conduct comprehensive brainstorming and health check of all project documentation to ensure content is useful,
well-balanced, up-to-date, and eliminates redundancy or outdated information after the recent architecture changes.

**Impact**: Recent architectural changes (T026 restructuring, T033 single source strategy) may have created
documentation inconsistencies, outdated references, or gaps. A systematic review ensures all documentation serves its
purpose and guides users/developers effectively.

**Cross-Check Coordination with T030**: This task works in coordination with T030 (CLAUDE.md cleanup) to ensure
comprehensive documentation health. T034 provides the broader audit while T030 handles specific CLAUDE.md fixes. Both
tasks should be completed together for maximum effectiveness.

**Scope of Review**:

**Project Root Documentation**:

- `README.md` - Project overview and quick start
- `CHANGELOG.md` - Feature tracking and version history
- `VERSION.md` - Version management
- `WORKFLOW.md` - User workflow guide
- `CLAUDE.md` - AI/development configuration
- `DEVELOPMENT.md` - Developer guidelines
- `CONTRIBUTING.md` - Contribution guide

**Documentation Directories**:

- `docs/` - Technical documentation (12 files)
- `analysis/` - Development analysis (2 files)
- `.claude/doh/inclaude.md` - Runtime documentation

**Brainstorming Questions**:

**Content Usefulness**:

- Which documents provide immediate value to users vs developers?
- Are there documents that duplicate information?
- What gaps exist for new contributors or users?
- Which files are actually referenced/used vs ignored?

**Balance Assessment**:

- Is there too much technical detail in user-facing docs?
- Are developer docs comprehensive enough?
- Do we have the right mix of guides vs reference material?
- Are examples practical and current?

**Currency Check**:

- Which documents reference old architecture (./skel/, ./templates/)?
- Are all version references accurate (1.4.0 target)?
- Do workflow examples match current command structure?
- Are dependency lists current (Node.js versions, tool versions)?

**Structural Review**:

- Should some docs be merged or split?
- Are docs in the right directories?
- Do navigation and cross-references work?
- Is the information hierarchy logical?

**Tasks**:

#### Phase 1: Discovery & Analysis

- [ ] **Audit all documentation files**: Create inventory with purpose, target audience, last update
- [ ] **Architecture reference check**: Find all references to old structure (./skel/, controlled duplication, etc.)
- [ ] **Cross-reference validation**: Check all internal links and references between docs
- [ ] **Redundancy identification**: Map overlapping content across files
- [ ] **Gap analysis**: Identify missing documentation for key workflows

#### Phase 2: Content Assessment

- [ ] **User journey mapping**: Trace new user → productive user → contributor paths through docs
- [ ] **Developer workflow mapping**: Trace development setup → feature development → testing paths
- [ ] **Usefulness scoring**: Rate each document's value and usage frequency
- [ ] **Balance evaluation**: Assess technical depth vs accessibility for each audience
- [ ] **Currency audit**: Flag outdated examples, commands, architecture references

#### Phase 3: Structural Brainstorming

- [ ] **Consolidation opportunities**: Identify docs that should be merged
- [ ] **Split candidates**: Find overly complex docs that need splitting
- [ ] **Reorganization proposals**: Suggest better directory structure or file naming
- [ ] **Navigation improvements**: Design better cross-linking and discovery

#### Phase 4: Actionable Recommendations

- [ ] **Priority fixes**: Critical updates needed immediately
- [ ] **Content improvements**: Rewrite/update recommendations with rationale
- [ ] **Structural changes**: Reorganization plan with migration strategy
- [ ] **Maintenance strategy**: Process for keeping docs current going forward

**Specific Focus Areas**:

**Architecture Documentation**:

- Remove all references to controlled duplication strategy
- Update build process descriptions to match single-source approach
- Verify all paths and commands match current structure

**User Experience**:

- Ensure WORKFLOW.md guides match actual DOH capabilities
- Verify README quick start works with current system
- Check that examples in docs/ are functional

**Developer Experience**:

- Ensure DEVELOPMENT.md covers current toolchain (make, npm, linting)
- Verify CLAUDE.md matches current project structure
- Check that analysis/ docs are still relevant

**Version Consistency**:

- Align all version references with current 1.4.0 development
- Update tool version requirements
- Ensure CHANGELOG.md properly tracks completed work

**Quality Criteria**:

- **Usefulness**: Each doc must serve a clear purpose for its audience
- **Currency**: All examples and references must work with current system
- **Balance**: Right level of detail for intended readers
- **Discoverability**: Clear navigation and logical organization
- **Maintainability**: Easy to keep updated as system evolves

**Deliverable**: Comprehensive documentation health report with prioritized action plan for improving DOH project
documentation quality, consistency, and user experience.

---

### T035 - Documentation Navigation & Content Organization (T034 Phase 2)

**Status**: PROPOSED  
**Priority**: Medium - User experience improvements  
**Dependencies**: T030 (critical fixes first), T034 (analysis base)  
**Proposed Version**: 1.4.0 **Tags**: `#doc` **Analysis**: Part of `analysis/T034-documentation-health-report.md`

Execute T034 Phase 2 recommendations to improve documentation navigation, content organization, and user experience
after critical architecture references are fixed by T030.

**Impact**: T034 analysis identified navigation gaps and content organization issues that affect user onboarding and
developer experience. These improvements will make the documentation more discoverable and maintainable.

**Scope (T034 Phase 2 - 3 hours total)**:

**Navigation Enhancement (1-2h)**:

- [ ] **Add document map to README.md** - Central index of all documentation
- [ ] **Improve cross-references** - Better linking between workflow docs
- [ ] **Add "See also" sections** - Help users discover related information
- [ ] **Create quick reference card** - Essential commands and workflows

**Content Organization (1-2h)**:

- [ ] **Consolidate workflow documentation** - Merge similar docs or clearly differentiate
- [ ] **Archive old analysis files** - Move development analysis to separate directory
- [ ] **Create single project structure source** - Eliminate multiple structure descriptions
- [ ] **Consolidate configuration documentation** - Reduce redundancy in config docs

**Quality Improvements**:

- Better user journey from README → productive usage → contribution
- Reduced maintenance burden through content consolidation
- Clearer information hierarchy and logical organization
- Improved discoverability of key workflows and commands

**Success Metrics**:

- New users can find relevant docs in <2 clicks from README
- No duplicate information across workflow documents
- Clear separation between user-facing and development documentation
- Logical progression from basic to advanced usage patterns

**Dependencies**: T030 must complete first to ensure all architecture references are consistent before improving
navigation.

---

### T037 - Clean up old project references (MrTroove, mkplan) across documentation

**Status**: PENDING  
**Priority**: Medium - Documentation accuracy  
**Dependencies**: None  
**Version**: 1.4.0 **Tags**: `#doc`

Clean up outdated project references (MrTroove, mkplan) across all documentation files and replace with appropriate
generic examples.

**Scope**:

- [ ] Search all documentation for "MrTroove" and "mkplan" references
- [ ] Replace with generic project names or current project examples
- [ ] Update any related examples to use consistent naming
- [ ] Verify all changes maintain documentation clarity

### T038 - Create DOH Pipeline Command for automated TODO/CHANGELOG/Version/Lint/Commit workflow

**Status**: COMPLETED  
**Priority**: High - Development efficiency  
**Dependencies**: None  
**Version**: 1.4.0 **Tags**: `#tools` `#automation`

Create `/doh-sys:commit` command to automate the complete DOH development pipeline: TODO management, CHANGELOG updates,
TODOARCHIVED maintenance, version bumping, linting with auto-fixes, and commit with proper messaging.

**Impact**: Streamlines DOH development workflow, reduces manual errors, ensures consistent commit standards, and
provides intelligent auto-fix capabilities for common markdown and formatting issues.

**Components Implemented**:

- [x] **Command Structure**: `/doh-sys:commit` with comprehensive parameter support
- [x] **Pipeline Steps**: TODO → CHANGELOG → TODOARCHIVED → Version → Lint → Commit workflow
- [x] **Auto-Fix Capabilities**: Intelligent markdown formatting, line length handling, structure fixes
- [x] **Error Handling**: Progressive retry system with fallback strategies
- [x] **Integration**: Works with existing DOH version management and pre-commit hooks
- [x] **Documentation**: Complete usage guide with examples and troubleshooting

**Usage**: `/doh-sys:commit "T035 - Documentation Navigation completed" [--version-bump] [--no-lint] [--dry-run]`

### T039 - Create /doh-sys:lint command with intelligent auto-fix capabilities

**Status**: COMPLETED  
**Priority**: High - Development efficiency  
**Dependencies**: T038 (pipeline approach)  
**Version**: 1.4.0 **Tags**: `#tools` `#automation` `#quality`

Create `/doh-sys:lint` command with intelligent auto-fix capabilities using priority-based repair strategies,
progressive error handling, and smart line length wrapping.

**Impact**: Provides standalone linting with same intelligent auto-fix approach as commit pipeline, enables targeted
quality improvements, reduces manual formatting work, and maintains analysis document preservation policy.

**Components Implemented**:

- [x] **Priority-based Auto-fix**: Critical → High → Medium → Low repair strategies
- [x] **Smart Line Wrapping**: Preserves meaning while fixing length issues
- [x] **Progressive Error Handling**: Individual fixes, continues on failure, reports unfixable issues
- [x] **File Type Support**: Markdown, JSON, YAML, code files with specific linting rules
- [x] **Analysis Document Policy**: Formatting fixes only, semantic content preserved
- [x] **Performance Optimization**: Parallel processing, caching, file filtering
- [x] **Integration**: Works standalone or within /doh-sys:commit pipeline

**Usage**: `/doh-sys:lint [--fix] [--format] [--check-only] [--files=pattern] [--verbose]`

### T036 - Documentation Enhancement & Polish (T034 Phase 3)

**Status**: PROPOSED  
**Priority**: Low - Enhancement and polish  
**Dependencies**: T030 (critical fixes), T035 (navigation improvements), T034 (analysis base)  
**Proposed Version**: 1.5.0 **Tags**: `#doc` **Analysis**: Part of `analysis/T034-documentation-health-report.md`

Execute T034 Phase 3 recommendations to add advanced documentation features, examples, and polish after core issues are
resolved by T030 and T035.

**Impact**: Final phase of T034 analysis focusing on user experience enhancements and comprehensive examples that will
make DOH documentation excellent rather than just functional.

**Scope (T034 Phase 3 - 4 hours total)**:

**Examples and Guides (3-4h)**:

- [ ] **Add real-world workflow examples** - Complete scenarios for different project types
- [ ] **Create troubleshooting guide** - Common issues and solutions
- [ ] **Expand command documentation** - More detailed examples in docs/commands.md
- [ ] **Add video/GIF demonstrations** - Visual guides for key workflows
- [ ] **Create getting started tutorial** - Step-by-step first-time user experience

**Advanced Features**:

- [ ] **Interactive examples** - Copy-paste ready commands with explanations
- [ ] **Use case templates** - Pre-built examples for common scenarios
- [ ] **Performance tips** - Optimization guidance for large projects
- [ ] **Integration patterns** - How to use DOH with CI/CD, Git workflows, etc.

**Quality Improvements**:

- Rich, practical examples that work in real projects
- Comprehensive troubleshooting reducing support burden
- Professional polish matching production-ready system
- Enhanced onboarding experience for new users

**Success Metrics**:

- Users can complete first DOH workflow without asking questions
- Troubleshooting guide covers 90% of common issues
- Examples work copy-paste in real environments
- Documentation feels comprehensive and professional

**Target Version**: 1.5.0 (enhancement phase after core 1.4.0 stabilizes)

---

### T042 - DOH Security Analysis & Threat Modeling 🔒

**Status**: PROPOSED  
**Priority**: High - Foundation for secure distribution  
**Dependencies**: None (pure analysis/brainstorming task)  
**Proposed Version**: 1.4.0 **Tags**: `#security` `#think` **Analysis**: Will create
`analysis/T042-security-threat-model.md`

Conduct comprehensive security analysis and threat modeling for the DOH system to identify vulnerabilities, attack
vectors, and defensive measures before 1.4.0 release and distribution.

**Impact**: DOH system handles sensitive development workflows (git operations, file system access, command execution,
project data). A security analysis is critical before distribution to identify and mitigate potential risks, ensure
secure defaults, and establish security best practices.

**Threat Surface Analysis**:

**File System Operations**:

- DOH reads/writes `.doh/` directories with project data
- Template deployment via `/doh:init` creates files in project directories
- Bash scripts access file system with user permissions
- Path traversal risks in file operations
- Symlink attacks on `.doh/` directory access

**Command Execution**:

- Bash scripts execute with user privileges
- Git operations (commit, rebase, push) with user credentials
- Shell command injection risks in user inputs
- Environment variable access and manipulation
- Process execution and subprocess spawning

**Data Handling**:

- Project metadata storage in `.doh/project-index.json`
- Task/Epic content with potentially sensitive information
- Memory files storing project context and history
- Git history access and manipulation
- Configuration data processing

**Network Operations**:

- GitHub/GitLab API access with user tokens
- Repository synchronization with remote systems
- Webhook endpoints and external integrations
- Man-in-the-middle attack vectors
- API credential exposure risks

**AI Integration**:

- Claude API communication with project data
- Prompt injection through user inputs
- Data leakage through AI model interactions
- Context contamination between projects
- Sensitive information in AI requests

**Tasks**:

#### Phase 1: Threat Identification (2-3h)

- [ ] **Attack Surface Mapping**: Catalog all DOH system entry points, data flows, and trust boundaries
- [ ] **Threat Actor Analysis**: Identify potential attackers (malicious users, compromised systems, insider threats)
- [ ] **Attack Vector Enumeration**: Document specific attack methods for each system component
- [ ] **Asset Classification**: Identify sensitive data and critical system components requiring protection
- [ ] **Trust Boundary Analysis**: Map data flows between trusted/untrusted contexts

#### Phase 2: Vulnerability Assessment (2-3h)

- [ ] **Code Security Review**: Analyze bash scripts for injection vulnerabilities, path traversal, privilege escalation
- [ ] **Input Validation Analysis**: Examine all user input processing points for sanitization gaps
- [ ] **File System Security**: Review file permissions, directory creation, symlink handling
- [ ] **Credential Handling**: Analyze token storage, API key management, git credential access
- [ ] **Configuration Security**: Review default configurations for security misconfigurations

#### Phase 3: Risk Analysis & Prioritization (1-2h)

- [ ] **Impact Assessment**: Evaluate potential damage from successful attacks
- [ ] **Likelihood Analysis**: Assess probability of various attack scenarios
- [ ] **Risk Matrix Creation**: Prioritize security issues by impact × likelihood
- [ ] **Exploitability Analysis**: Evaluate ease of exploiting identified vulnerabilities
- [ ] **Business Impact Evaluation**: Assess risks to user projects and organizational security

#### Phase 4: Mitigation Strategy Design (2-3h)

- [ ] **Defense in Depth Strategy**: Design layered security controls
- [ ] **Secure Defaults**: Establish secure default configurations and behaviors
- [ ] **Input Sanitization**: Design comprehensive input validation and sanitization
- [ ] **Privilege Minimization**: Implement least-privilege principles
- [ ] **Monitoring & Detection**: Design security monitoring and anomaly detection
- [ ] **Incident Response**: Plan security incident response procedures

#### Phase 5: Security Architecture Recommendations (1-2h)

- [ ] **Security Controls Implementation**: Recommend specific security measures for each component
- [ ] **Security Testing Strategy**: Design security testing approach (static analysis, penetration testing)
- [ ] **Security Documentation**: Create security guidelines for users and developers
- [ ] **Compliance Considerations**: Address regulatory and organizational security requirements
- [ ] **Security Metrics**: Define security KPIs and monitoring metrics

**Brainstorming Areas**:

**Defensive Security Focus**:

- Input validation and sanitization strategies
- File system access controls and sandboxing
- Secure credential storage and handling
- API security and rate limiting
- Audit logging and monitoring
- Security configuration management
- Error handling without information disclosure

**Secure Development Practices**:

- Security code review guidelines
- Secure coding standards for bash scripts
- Security testing integration (SAST/DAST)
- Dependency security scanning
- Security-focused documentation
- Developer security training recommendations

**Deployment Security**:

- Secure distribution mechanisms
- Package integrity verification
- Installation security checks
- Update mechanism security
- Configuration security validation
- User permission requirements

**Operational Security**:

- Runtime security monitoring
- Anomaly detection for unusual behavior
- Security incident response procedures
- User security guidelines
- Security maintenance procedures
- Backup and recovery security

**Success Criteria**:

- Comprehensive threat model document created
- All major attack vectors identified and analyzed
- Risk-prioritized mitigation recommendations
- Security implementation roadmap for development
- Security testing strategy defined
- User security guidelines established

**Deliverable**: Complete security analysis document (`analysis/T042-security-threat-model.md`) with actionable security
recommendations, threat model, risk assessment, and implementation roadmap for secure DOH system deployment.

---

### T043 - DOH Security Epic Planning & Implementation Roadmap 🔒

**Status**: PROPOSED  
**Priority**: High - Follow-up to T042 security analysis  
**Dependencies**: T042 (security threat model complete)  
**Epic**: Security & Hardening  
**Proposed Version**: 1.4.1 **Tags**: `#security` `#think` **Analysis**: Will create
`analysis/T043-security-epic-plan.md`

Transform T042 security analysis into comprehensive epic planning with actionable implementation roadmap for DOH system
security hardening and defensive measures implementation.

**Impact**: T042 provides threat analysis and security recommendations. T043 converts this analysis into structured epic
planning with prioritized implementation phases, specific tasks, and measurable security objectives for systematic
security enhancement.

**Epic Scope**: Create comprehensive security hardening epic encompassing:

**Security Infrastructure Epic**:

- Input validation and sanitization framework
- Secure file system access controls
- Credential management and storage security
- API security and rate limiting implementation
- Audit logging and security monitoring
- Configuration security management

**Security Integration Epic**:

- Security testing framework (SAST/DAST integration)
- Dependency security scanning automation
- Security-focused pre-commit hooks
- Developer security tooling
- Security documentation and guidelines
- Security training and awareness

**Operational Security Epic**:

- Runtime security monitoring and alerting
- Anomaly detection and threat response
- Security incident response procedures
- Security maintenance and update procedures
- Backup and recovery security measures
- User security guidelines and best practices

**Tasks**:

#### Phase 1: Epic Architecture Design (2h)

- [ ] **Analyze T042 Findings**: Extract actionable recommendations from threat model analysis
- [ ] **Epic Decomposition**: Break down security work into logical epics with clear boundaries
- [ ] **Dependency Mapping**: Identify dependencies between security implementation phases
- [ ] **Priority Framework**: Establish risk-based prioritization for security improvements
- [ ] **Resource Planning**: Estimate effort and timeline for security implementations

#### Phase 2: Task Breakdown Structure (2-3h)

- [ ] **Security Infrastructure Tasks**: Define specific tasks for core security controls
- [ ] **Security Integration Tasks**: Plan security tooling and automation tasks
- [ ] **Operational Security Tasks**: Design security monitoring and response tasks
- [ ] **Testing & Validation Tasks**: Plan security testing and validation approach
- [ ] **Documentation Tasks**: Outline security documentation requirements

#### Phase 3: Implementation Planning (1-2h)

- [ ] **Phase Sequencing**: Order security implementation phases for maximum impact
- [ ] **Milestone Definition**: Define measurable security milestones and success criteria
- [ ] **Risk Mitigation Timeline**: Plan timeline for addressing highest-risk vulnerabilities first
- [ ] **Integration Strategy**: Plan integration with existing DOH development workflow
- [ ] **Success Metrics**: Define KPIs for measuring security improvement effectiveness

**Brainstorming Focus**:

**Epic Structure Design**:

- How to organize security work into manageable, logical epics
- Dependencies and sequencing between security implementation phases
- Resource allocation and timeline estimation for security work
- Integration with existing DOH development priorities

**Implementation Strategy**:

- Minimum viable security (MVS) approach for rapid threat mitigation
- Progressive security enhancement roadmap
- Security testing integration with development workflow
- User impact minimization during security improvements

**Success Criteria**:

- Comprehensive security epic plan created with clear implementation phases
- Risk-prioritized task breakdown with effort estimates
- Timeline and milestone plan for security implementation
- Integration strategy with existing DOH development workflow
- Measurable security objectives and success metrics defined

**Deliverable**: Detailed security epic plan (`analysis/T043-security-epic-plan.md`) with structured implementation
roadmap, prioritized task breakdown, timeline planning, and measurable security objectives for systematic DOH system
hardening.

---

## 🚀 EPIC E047: Natural Language & Performance Optimization

**Epic Scope**: Transform DOH from technical command interface to conversational, intelligent system while maximizing
performance through hybrid execution and script optimization strategies.

**Strategic Vision**: Create seamless user experience where natural language commands leverage optimized bash scripts
for performance and Claude AI for intelligence, making DOH accessible to all users while maintaining enterprise-grade
performance.

**Epic Components**: T017, T020, T044, T045, T046

**Dependencies**: T001 (Skeleton - foundation), T013 (Bash optimization - completed)

**Target Version**: 1.4.1 - 1.5.0 (multi-release epic)

### Epic Batched Work Plan

**Phase 1 - Analysis & Architecture (T017, T020)**: Foundation analysis for optimization **Phase 2 - Natural Language
Design (T044)**: Conversational interface architecture  
**Phase 3 - Hybrid Performance (T045)**: Intelligent bash/Claude routing system **Phase 4 - User Experience Integration
(T046)**: Seamless natural language deployment

### T045 - Intelligent Routing System (Bash/Claude Hybrid Execution) 🚩

**Status**: PROPOSED  
**Priority**: High - Epic Phase 3  
**Dependencies**: T017 (bash routine patterns), T044 (natural language design)  
**Target Version**: 1.5.0  
**Tags**: `#features` `#optimization` `#performance`

Implement hybrid execution system that intelligently routes DOH commands between optimized bash scripts and Claude
processing based on operation type, complexity, and available optimization potential.

**Impact**: Enable 100-500x performance improvements for data operations while maintaining Claude's natural language
capabilities for complex reasoning. Creates seamless user experience where speed optimization is invisible but dramatic.

**Core Architecture**:

**Routing Intelligence**:

- **Data Operations**: Route to bash (get-item, list-tasks, search, count, validate)
- **Language Processing**: Route to Claude (analysis, planning, complex queries)
- **Hybrid Operations**: Start with bash, escalate to Claude for complex cases
- **Fallback Strategy**: Always graceful fallback from bash to Claude on errors

**Performance Targets**:

- **Bash Operations**: 5-50ms response time for data queries
- **Claude Operations**: Normal API response time for reasoning tasks
- **Hybrid Decisions**: <10ms routing decision time
- **Fallback Latency**: <100ms additional overhead for bash→Claude fallback

**Tasks**:

#### Phase 1: Routing Engine Core (2h)

- [ ] **Design command classification system** for bash vs Claude routing
- [ ] **Implement routing decision logic** based on command patterns and complexity
- [ ] **Create routing configuration** with per-command optimization settings
- [ ] **Build routing metadata** for command capability mapping

#### Phase 2: Bash Integration Layer (2h)

- [ ] **Create bash script discovery system** for available optimizations
- [ ] **Implement bash execution wrapper** with error handling and timing
- [ ] **Build bash→Claude fallback triggers** for unsupported operations
- [ ] **Add performance monitoring** for bash operation success rates

#### Phase 3: Claude Integration Layer (1.5h)

- [ ] **Design Claude execution pathway** for complex operations
- [ ] **Implement context preservation** when falling back to Claude
- [ ] **Create Claude response optimization** for hybrid operation workflows
- [ ] **Build Claude performance tracking** for routing decision refinement

#### Phase 4: Routing Logic Implementation (2h)

- [ ] **Implement command parsing** for operation type detection
- [ ] **Create complexity analysis** for routing decisions
- [ ] **Build optimization opportunity detection** for bash routing
- [ ] **Add dynamic routing adjustment** based on performance history

#### Phase 5: Testing & Validation (1.5h)

- [ ] **Test routing accuracy** across all DOH command types
- [ ] **Validate fallback mechanisms** under various error conditions
- [ ] **Test performance improvements** for bash-routed operations
- [ ] **Verify seamless user experience** regardless of routing path

**Success Criteria**:

- 95%+ correct routing decisions for command classification
- 100-500x performance improvement for bash-routable operations
- <1% fallback failures requiring user intervention
- Transparent user experience with invisible optimization benefits

**Deliverable**: Production-ready hybrid routing system that maximizes performance while maintaining full DOH
functionality and natural language capabilities.

---

### T046 - Natural Language UX Integration & Deployment 🚩

**Status**: PROPOSED  
**Priority**: High - Epic Phase 4  
**Dependencies**: T044 (NL design), T045 (hybrid routing)  
**Target Version**: 1.5.0  
**Tags**: `#features` `#optimization` `#ux`

Deploy integrated natural language interface with hybrid performance optimization, creating seamless conversational
project management experience with invisible speed optimizations.

**Impact**: Complete transformation of DOH user experience from technical command interface to conversational assistant.
Users interact naturally while benefiting from dramatic performance improvements without technical complexity.

**Core Architecture**:

**User Experience Design**:

- **Conversational Interface**: Natural language input processing with methodology guidance
- **Invisible Optimization**: Performance benefits happen transparently without user awareness
- **Methodology Coaching**: Built-in guidance toward DOH best practices through conversation
- **Context Awareness**: Commands understand project state and user intent from conversation

**Integration Capabilities**:

- **Seamless Routing**: Users never know if bash or Claude handled their request
- **Progressive Enhancement**: Simple queries get instant responses, complex analysis takes appropriate time
- **Error Recovery**: Natural language explanations for any routing or execution failures
- **Learning Integration**: System learns user patterns and optimizes routing decisions

**Tasks**:

#### Phase 1: Interface Integration (2.5h)

- [ ] **Integrate NL parser** with hybrid routing system from T045
- [ ] **Implement conversation flow management** for multi-step DOH operations
- [ ] **Create context-aware command suggestions** based on project state and conversation
- [ ] **Build natural language error handling** with helpful recovery suggestions

#### Phase 2: User Experience Optimization (2h)

- [ ] **Design response formatting** for conversational interface consistency
- [ ] **Implement progress indication** for longer operations with transparent routing info
- [ ] **Create intelligent command completion** for common DOH workflow patterns
- [ ] **Build user preference learning** for personalized routing optimization

#### Phase 3: Methodology Integration (1.5h)

- [ ] **Integrate DOH methodology coaching** into conversational responses
- [ ] **Implement structured workflow guidance** through natural language interaction
- [ ] **Create compliance checking** with conversational feedback for methodology violations
- [ ] **Build epic/task navigation** through conversational interface

#### Phase 4: Performance Monitoring & Optimization (1.5h)

- [ ] **Implement usage analytics** for routing decision refinement
- [ ] **Create performance dashboards** for hybrid system monitoring
- [ ] **Build optimization recommendations** based on user patterns and performance data
- [ ] **Add A/B testing framework** for interface and routing improvements

#### Phase 5: Documentation & Training (1h)

- [ ] **Create user onboarding guide** for natural language DOH interface
- [ ] **Document conversation patterns** and optimal user interaction approaches
- [ ] **Build command reference** with natural language alternatives
- [ ] **Create troubleshooting guide** for hybrid system issues

**Success Criteria**:

- Natural conversation flow for 95% of DOH operations
- Invisible performance optimization with user satisfaction metrics
- Successful methodology coaching through conversational interface
- Seamless integration of technical optimization with natural language UX

**Deliverable**: Complete natural language DOH interface with integrated performance optimization, methodology coaching,
and seamless user experience that transforms project management interaction paradigm.

---

### T048 - Audit & Enforce DOH Internal/Runtime Pattern Isolation 🚩

**Status**: PROPOSED  
**Priority**: High - Prevents cross-contamination and confusion  
**Dependencies**: None  
**Target Version**: 1.4.1  
**Tags**: `#doc` `#architecture`

Audit all DOH documentation and code to ensure clear separation between DOH system internal development patterns
(TODO.md, Epic E047) and runtime `/doh` command patterns that users employ in their projects.

**Impact**: Current documentation mixes internal DOH development concepts with user-facing `/doh` runtime patterns,
creating confusion about which patterns apply where. This leads to incorrect assumptions and implementation mistakes.

**Core Issues to Address**:

**Documentation Cross-Contamination**:

- Internal DOH epic numbering (E047) appearing in `/doh` command documentation
- TODO.md patterns being referenced in user-facing `/doh` guides
- DOH system development workflows mixed with user project workflows
- Template documentation containing internal development references

**Pattern Isolation Requirements**:

- **Internal DOH Development**: TODO.md, T/E numbering, /doh-sys commands, DOH system architecture
- **Runtime /doh Commands**: .doh/ structure, user project epics/tasks, /doh command patterns
- **Clear Boundaries**: No mixing of internal patterns with user-facing documentation

**Tasks**:

#### Phase 1: Documentation Audit (1.5h)

- [ ] **Scan all `.claude/commands/doh/` files** for references to TODO.md, T/E numbering, or internal patterns
- [ ] **Review all template files** for internal DOH development references
- [ ] **Audit user-facing documentation** (README.md, WORKFLOW.md, docs/) for internal pattern leakage
- [ ] **Check command examples** for mixing internal and runtime patterns

#### Phase 2: Pattern Isolation Enforcement (2h)

- [ ] **Remove internal references** from `/doh` command documentation
- [ ] **Clean template files** of DOH system development concepts
- [ ] **Update user guides** to focus purely on runtime `/doh` usage
- [ ] **Create isolation guidelines** for future documentation

#### Phase 3: Architecture Documentation (1h)

- [ ] **Document pattern boundaries** clearly in DEVELOPMENT.md
- [ ] **Create isolation checklist** for new documentation
- [ ] **Add review guidelines** to prevent future cross-contamination
- [ ] **Update contributor guidelines** with separation requirements

#### Phase 4: Validation & Testing (1h)

- [ ] **Test user workflow documentation** without internal references
- [ ] **Validate command examples** work in real user projects
- [ ] **Verify template consistency** across all `/doh` commands
- [ ] **Check cross-reference accuracy** in all documentation

**Success Criteria**:

- Zero references to TODO.md, T/E numbering in `/doh` command documentation
- Clear distinction between DOH system development and user project patterns
- User-facing documentation focuses purely on runtime `/doh` usage
- Internal development documentation clearly marked as DOH system specific

**Deliverable**: Clean separation between DOH internal development patterns and user-facing `/doh` runtime patterns,
with clear documentation boundaries and isolation guidelines.

---

### T044 - Natural Language DOH Command Interface & Script Optimization ⚡ (EPIC Phase 2)

**Status**: PROPOSED  
**Priority**: High - Critical for user experience and T001 enhancement  
**Dependencies**: T001 (DOH Skeleton Implementation)  
**Proposed Version**: 1.4.1  
**Epic**: E047 Natural Language & Performance Optimization  
**Tags**: `#features` `#think` `#optimization` **Analysis**: Will create
`analysis/T044-natural-language-doh-interface.md`

Design and implement natural language processing capabilities for `/doh` commands while maintaining optimal script
performance through intelligent hybrid execution strategies.

**Impact**: Current DOH commands require precise syntax and parameter knowledge, creating friction for users. T001
skeleton implementation provides foundation, but T044 focuses on making DOH commands conversational and intuitive while
preserving the performance benefits of bash script optimization where possible.

**Natural Language Vision**:

**Current Experience** (Technical):

```bash
/doh:task create --title "Fix login bug" --epic=3 --priority=high --type=bug
/doh:epic create --title "Authentication System" --description="User auth overhaul"
/doh:status update task 123 --status=completed
```

**Desired Experience** (Natural):

```bash
/doh "create a high priority bug task to fix the login issue in epic 3"
/doh "make a new epic called Authentication System for user auth overhaul"
/doh "mark task 123 as completed"
/doh "what should I work on next that's ready to start?"
/doh "show me all open bugs in the authentication epic"
```

**Technical Architecture Goals**:

**Hybrid Processing Strategy**:

- **Natural Language Parser**: Claude AI processes conversational input into structured commands
- **Intent Recognition**: Identify command type (create, update, query, analyze)
- **Parameter Extraction**: Extract entities (task names, priorities, epics, statuses)
- **Script Optimization**: Use bash for data operations, Claude for language processing
- **Fallback Graceful**: Maintain current syntax support for power users

**Performance Optimization Opportunities**:

- **Command Caching**: Cache frequently used natural language patterns → script mappings
- **Batch Operations**: "create 3 tasks for the login system" → single optimized script execution
- **Context Awareness**: Remember project context to reduce parsing overhead
- **Smart Routing**: Simple commands → direct bash, complex queries → Claude processing

**Tasks**:

#### Phase 1: Natural Language Analysis & Design (3-4h)

- [ ] **Current Command Audit**: Analyze existing `/doh` commands and usage patterns
- [ ] **Natural Language Patterns**: Research common user expressions for project management
- [ ] **Intent Classification**: Design taxonomy for DOH command intentions (create, update, query, analyze)
- [ ] **Entity Recognition**: Define entities (tasks, epics, priorities, statuses, users) and extraction patterns
- [ ] **Ambiguity Resolution**: Plan strategies for handling unclear or ambiguous natural language

#### Phase 2: Hybrid Architecture Design (2-3h)

- [ ] **Processing Pipeline**: Design NL input → intent → parameters → execution flow
- [ ] **Performance Strategy**: Plan bash optimization points vs Claude processing requirements
- [ ] **Caching Strategy**: Design pattern caching for common natural language expressions
- [ ] **Context Management**: Plan project context awareness and session memory
- [ ] **Error Handling**: Design graceful degradation when NL parsing fails

#### Phase 3: Implementation Planning & Prototyping (2-3h)

- [ ] **Command Router**: Design intelligent routing between NL processing and direct execution
- [ ] **Parser Integration**: Plan Claude AI integration points for language understanding
- [ ] **Script Interface**: Design clean interface between NL parser and existing bash scripts
- [ ] **Performance Testing**: Plan benchmarking for NL vs direct command performance
- [ ] **User Experience**: Design feedback mechanisms for improving NL understanding

**Brainstorming Areas**:

**Natural Language Processing**:

- Intent recognition strategies for project management domain
- Entity extraction techniques for technical project terminology
- Context awareness across command sessions
- Ambiguity resolution through clarifying questions
- Learning from user corrections and patterns

**Performance Optimization**:

- When to use Claude AI processing vs bash scripts
- Caching strategies for common language patterns
- Batch operation optimization for multiple entity commands
- Memory usage optimization for context retention
- Response time minimization techniques

**User Experience Design**:

- Conversational flow design for complex multi-step operations
- Feedback mechanisms for command understanding accuracy
- Progressive disclosure for power users vs beginners
- Error recovery and suggestion systems
- Documentation and learning resources for natural language usage

**Integration Architecture**:

- Seamless integration with existing DOH command structure
- Backward compatibility with current precise syntax
- Extension points for future natural language capabilities
- Testing strategies for natural language processing accuracy
- Quality assurance for diverse language input patterns

**Example Natural Language Capabilities**:

**Task Management**:

- "Create a bug task to fix the search functionality"
- "Make this task high priority and assign it to the frontend epic"
- "Show me all completed tasks from last week"
- "What tasks are blocked and what's blocking them?"

**Epic/Project Planning**:

- "Start a new epic for the mobile app rewrite"
- "How many tasks are left in the authentication epic?"
- "What's the progress on the performance optimization work?"

**Workflow Queries**:

- "What should I work on next?"
- "Show me quick wins I can finish today"
- "What's ready to start that doesn't depend on other work?"
- "Give me a summary of this week's progress"

**Contextual Commands**:

- "Add three tasks for user registration: validation, database, and email confirmation"
- "Move all the CSS cleanup tasks to a new maintenance epic"
- "Mark the authentication epic as complete and archive it"

**Success Criteria**:

- Natural language processing accurately interprets 90% of common project management expressions
- Performance degradation <20% compared to direct command execution
- Seamless fallback to existing syntax when natural language parsing fails
- Context awareness improves command accuracy across conversation sessions
- User satisfaction significantly higher with natural language interface

**Performance Targets**:

- Simple NL commands (create, update): <200ms processing time
- Complex NL queries (analysis, reporting): <2s processing time
- Context retention across 50+ command session
- Cache hit rate >80% for common language patterns
- Memory footprint <50MB for context and caching

**Deliverable**: Comprehensive natural language interface design document
(`analysis/T044-natural-language-doh-interface.md`) with technical architecture, performance optimization strategies,
implementation roadmap, and user experience design for conversational DOH command interaction.

---

**Management**: See `DEVELOPMENT.md` section "TODO Management for DOH Development" for rules and workflow.  
**Archive**: Completed TODOs moved to `TODOARCHIVED.md` to keep this file focused on active work.

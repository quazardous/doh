# TODO - /doh System Evolution

**Last Updated**: 2025-08-27  
**Next TODO ID**: T033

---

## 📑 Active TODOs

### Critical Priority

- **T022** 🚩🚩 DOH System Self-Hosting Project [PROPOSED - Foundation for everything]
- **T013** 🚩🚩 Performance Optimization via Internal Bash Scripts [COMPLETED ✅]

### High Priority

- **T024** 🚩 Comprehensive Testing Framework Implementation [PROPOSED - Dual CI/CD + Local system]
- **T019** 🚩 DOH System Integration Testing [PROPOSED - Foundation validation]
- **T020** 🚩 Enhanced Codebase Analysis Engine [PROPOSED - Replaces T002 with advanced features]
- **T003** 🚩 Complete Architecture & Distribution System
- **T005** 🚩 Installation/Distribution Scripts
- **T011** 🚩 GitHub/GitLab Synchronization Implementation
- **T017** 🚩 Bash Routine Expansion Analysis [UNBLOCKED - T013 ready, T014 optional]

### Future Enhancements

- **T021** 🚩 Intelligent Template System [FUTURE - Context-aware templates for v2.0.0]

### High Priority (Proposed)

- **T022** 🚩 DOH System Self-Hosting Project [PROPOSED - Foundation for distribution and testing - UNBLOCKED]

### Medium Priority

- **T032** 🚩 Design DOH Runtime Build Process (.claude/doh/ as build directory) [PROPOSED - Build system architecture]
- **T031** 🚩 Brainstorm skel/ location for /doh:init runtime access [COMPLETED ✅ - Critical architecture decision]
- **T030** 🚩 Fix Single Source of Truth violations in CLAUDE.md after T026 completion [PROPOSED - Documentation
  cleanup]
- **T029** 🚩 Clean up migrated files from .claude/doh after T026 restructuring [PROPOSED - Cleanup task]
- **T027** 🚩 Implement Markdown Linting System [PROPOSED - Code quality and consistency]
- **T028** 🚩 Development Environment Setup & Automation [COMPLETED ✅ - Developer toolchain]
- **T006** Intelligent Complexity Analysis
- **T007** Automatic Epic #0 Graduation
- **T008** CLAUDE.md Integration & Strategy Detection

### Low Priority

- **T009** Optimized Templates
- **T010** Universal Command `/doh`

---

## TODOs

### T001 - DOH Skeleton Implementation 🚩🚩

**Status**: Ready to implement  
**Priority**: CRITICAL - Blocks T002 development  
**Dependencies**: None  
**Target Version**: 1.4.0

Create standardized `.doh/` skeleton structure for consistent project initialization. The skeleton provides a template
that both `/doh:init` and `/doh:analyze` can use.

**Impact**: Currently `/doh:init` and `/doh:analyze` lack standard templates, causing inconsistent .doh setups across
projects.

**Tasks**:

- [ ] Create `.claude/doh/skel/` directory structure
- [ ] Create `project-index.json` template with proper schema
- [ ] Create `.gitignore` with sections for DOH components
- [ ] Create empty `memory/` directories (project/, epics/, agent-sessions/)
- [ ] Create `epics/quick/epic0.md` template for Epic #0
- [ ] Update `/doh:init` command to use skeleton
- [ ] Test skeleton deployment

**Deliverable**: Complete skeleton structure ready for use by initialization commands.

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

### T013 - Performance Optimization via Internal Bash Scripts

**Status**: COMPLETED ✅  
**Priority**: Critical - Performance and cost optimization  
**Dependencies**: None (can use existing data structures)  
**Version**: 1.4.0

Create internal bash utility scripts to replace Claude AI calls for simple data extraction and file operations, reducing
token usage and improving performance.

**Impact**: Many internal operations (JSON parsing, file reading, simple data extraction) don't require Claude
intelligence. Creating bash utilities for these routine tasks can significantly reduce API costs and improve response
times.

**Tasks**:

- [ ] Audit current Claude calls to identify bash-scriptable operations
- [ ] Create `parse_project_index.sh` for JSON data extraction with error handling
- [ ] Create `list_items.sh` for simple listing operations (tasks/epics/features)
- [ ] Create `get_item_details.sh` for extracting item information from files
- [ ] Create `validate_structure.sh` for file system integrity checks
- [ ] Create `count_stats.sh` for project statistics and counters
- [ ] Implement robust error handling and validation in all bash scripts
- [ ] Create comprehensive test suite for all bash utilities (edge cases, malformed JSON, missing files)
- [ ] Implement failsafe wrapper functions with Claude AI fallback mechanism
- [ ] Add performance monitoring to measure bash vs Claude execution times
- [ ] Test bash scripts on various environments and edge cases
- [ ] Update command implementations to use bash-first with AI fallback strategy

**Deliverable**: Battle-tested internal bash utility library with comprehensive error handling and Claude AI failsafe
fallback. Scripts must be robust enough for production use, with automatic fallback to Claude when bash operations fail
or encounter unexpected scenarios.

### T017 - Bash Routine Expansion Analysis 🚩🚩

**Status**: Not started  
**Priority**: High - Capitalize on T013 POC success  
**Dependencies**: T013 (bash scripts), T014 (data structure analysis)  
**Proposed Version**: 1.5.0

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

### T018 - Project Path Resolution Strategy ✅

**Status**: COMPLETED (2025-08-27)  
**Priority**: High - Critical for cross-environment compatibility  
**Dependencies**: None  
**Version**: 1.4.0 ✅

Design and implement robust PROJECT_ROOT detection strategy that handles symlinks, encrypted filesystems, bind mounts,
and preserves Claude Code working directory preference while ensuring bash script compatibility.

**Impact**: Current path resolution causes issues with symlinks, encrypted filesystems (.private), bind mounts, and
different working directories. DOH scripts must work seamlessly whether launched from Claude Code directory or bash
command line, with predictable behavior across all common filesystem scenarios.

**Tasks**: ✅ ALL COMPLETED

- [x] Analyze common filesystem scenarios (symlinks, .private encryption, bind mounts, NFS, WSL)
- [x] Define priority hierarchy: Claude CWD > explicit PROJECT_ROOT > .doh detection > fallback
- [x] Design path canonicalization strategy that preserves user's preferred working directory
- [x] Implement robust doh_find_project_root() with comprehensive fallback logic
- [x] Add path equivalency detection for common patterns (.private, symlinks, mounts)
- [x] Create configuration option for preferred project path (config.ini: project.preferred_path)
- [x] Create .doh/uuid file generation during /doh:init (uuidgen on-the-fly)
- [x] Implement project identity validation using .doh/uuid comparison
- [x] Implement discovered_paths cache system for known equivalent project paths
- [x] Add auto-discovery mechanism that learns new path equivalents with UUID validation
- [x] Test across multiple filesystem scenarios (local, encrypted, network, containers)
- [x] Add debugging mode for path resolution troubleshooting (DOH_PATH_DEBUG=1)
- [x] Document path resolution behavior and troubleshooting guide
- [x] Update all existing bash scripts to use consistent path resolution

**Common Filesystem Scenarios to Handle**:

- **Symlinks**: `/home/user/dev/project` → `/home/user/Private/dev/project`
- **Encrypted (.private)**: `/home/user/Private/` mounted from `/home/user/.private/`
- **Bind Mounts**: `/var/www/project` → `/home/user/dev/project`
- **NFS/Network**: `/net/server/project` accessible from multiple paths
- **WSL**: Windows paths vs Linux paths, case sensitivity issues
- **Docker/Containers**: Volume mounts with different internal/external paths
- **Git Worktrees**: Multiple working directories for same repo

**Path Resolution Priority Strategy**:

1. **Claude Code Working Directory**: Preserve the directory where Claude Code was launched
2. **Explicit PROJECT_ROOT**: Honor environment variable if set by user
3. **Configuration Preference**: Use config.ini project.preferred_path if configured
4. **Automatic Detection**: Search upward for .doh directory with canonicalization
5. **Path Equivalency**: Check known equivalent paths (.private, common symlinks)
6. **Fallback Strategy**: Current directory with warning if no .doh found

**Advanced Features to Consider**:

- **Discovered Paths Cache**: Maintain `discovered_paths` registry of known equivalent paths
- **Path History**: Remember successful path resolutions in config with timestamps
- **Multiple Project Support**: Handle projects with multiple valid paths and aliases
- **Cross-Platform Compatibility**: Windows, macOS, Linux path handling
- **Performance Optimization**: Cache path resolution results to avoid repeated filesystem queries
- **Validation**: Verify .doh directory integrity at resolved path

**Discovered Paths Implementation**:

```ini
[project]
canonical_path = /home/user/Private/dev/projects/myproject
preferred_path = /home/user/dev/projects/myproject
discovered_paths = /home/user/dev/projects/myproject,/home/user/Private/dev/projects/myproject
last_discovered = 2025-08-27T12:43:00Z
```ini

**Project Identity Validation**:

- Create `.doh/uuid` file during `/doh:init` with unique UUID (generated on-the-fly)
- Validate project identity by comparing UUIDs before adding to discovered_paths
- Prevents false positives between dev/prod/backup projects with same name

**Path Resolution with Discovery**:

1. Check `discovered_paths` cache for known equivalents
2. If cache miss, perform full detection and validate project UUID
3. Only add paths with matching `.doh/uuid` to discovered_paths
4. Validate cached paths periodically (24h) and prune invalid entries
5. Auto-discover new equivalent paths when same UUID found

**Deliverable**: ✅ COMPLETED Robust path resolution system that works seamlessly across all common filesystem
scenarios, preserves user's preferred working directory, and provides clear debugging when path issues occur.

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

### T020 - Enhanced Codebase Analysis Engine 🚩

**Status**: Proposed  
**Priority**: High - Builds on T002 specification  
**Dependencies**: T001 (skeleton), T018 (path resolution), T019 (integration tests), T028 (dev environment)  
**Proposed Version**: 1.5.0

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

```markdown
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

doh-system/ ├── .doh/ # RESERVED - Only for production DOH self-management │ └── (initialized only when DOH is ready for
production use) ├── bin/ # Executable scripts │ ├── doh-init │ ├── doh-admin │ └── doh ├── lib/ # Core libraries │ ├──
doh.sh │ ├── doh-config.sh │ └── doh-wrappers.sh ├── scripts/ # Utility scripts │ ├── performance/ │ ├── migration/ │
└── utilities/ ├── tests/ # Comprehensive test suite │ ├── unit/ # Unit tests │ ├── integration/ # Integration tests │
├── e2e/ # End-to-end tests │ ├── performance/ # Performance benchmarks │ ├── fixtures/ # Test fixtures and data │ └──
projects/ # Test projects (NEVER use .doh in tests!) │ ├── minimal/ # Minimal test project │ │ └── test-data/ # Test
data instead of .doh │ ├── standard/ # Standard test project │ │ └── test-data/ # Test data instead of .doh │ └──
complex/ # Complex test project │ └── test-data/ # Test data instead of .doh ├── templates/ # DOH templates │ ├── epics/
│ ├── tasks/ │ └── skeleton/ ├── docs/ # Documentation │ ├── api/ # API documentation │ ├── guides/ # User guides │ └──
architecture/ # System architecture ├── install.sh # Installation script ├── uninstall.sh # Uninstallation script └──
Makefile # Build/test automation

```text

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

**Deliverable**:
Standalone DOH system project that is self-hosting, fully tested, and ready for distribution.
Serves as both the development environment for DOH and the reference implementation for DOH best practices.

---

### T023 - Prevent /init Auto-Trigger of /doh:init

**Status**: COMPLETED ✅ - 2025-08-27
**Priority**: High - User experience improvement
**Dependencies**: None
**Version**: 1.4.0

Ensure that `/init` command does not automatically trigger `/doh:init` without user consent.

**Solution Implemented**:
Added mandatory confirmation prompt to `/doh:init` script. Now `/doh:init` always prompts users for confirmation
before proceeding, making it cancellable even when auto-triggered by `/init`.

**Tasks**:
- [x] Review current `/init` command behavior and identify auto-trigger points
- [x] Add cancellable confirmation prompt to `doh-init.sh` script
- [x] Add `--no-confirm` option for automated scenarios
- [x] Test that `/doh:init` can be cancelled when auto-triggered
- [x] Update documentation with confirmation-based solution

**Implementation Details**:
- Added `prompt_confirmation()` function that runs before any initialization
- Users can cancel with 'N' (default) or proceed with 'y'
- Added `--no-confirm` flag for scripts that need to skip confirmation
- Maintains backward compatibility while giving users control

**Deliverable**: ✅ COMPLETED
`/doh:init` now always prompts for user confirmation, making it safely cancellable even when auto-triggered by `/init`.

---

### TXXX - Title 🚩

**Status**: Not started / In progress / Ready to implement
**Priority**: Critical / High / Medium / Low - Context explanation
**Dependencies**: TXXX, TXXX or None
**Proposed Version**: 1.4.0 (for new tasks)
**Target Version**: 1.4.0 (when confirmed)
**Version**: 1.4.0 (when active/completed)

Brief description in 1-2 sentences explaining what needs to be done and why.

**Impact**:
Why this matters, who it affects, what happens if we don't do it.

**Tasks**:
- [ ] Concrete actionable task 1
- [ ] Concrete actionable task 2
- [ ] Concrete actionable task 3

**Deliverable**:
What will be produced when this TODO is completed.
```text

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
```text

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

### T025 - Move TODO.md from .claude/doh to project root 🚩

**Status**: ✅ COMPLETED 2025-08-27  
**Priority**: Medium - DOH self-hosting preparation  
**Dependencies**: None  
**Version**: 1.4.0

Move the TODO.md file from `.claude/doh/TODO.md` to the project root directory to prepare for DOH self-hosting and make
development tasks more accessible.

**Impact**: As DOH becomes its own standalone project, development tracking should be at the root level rather than
buried in `.claude/doh/`. This aligns with conventional project structure and prepares for T022 self-hosting.

**Tasks**:

- [x] Copy `.claude/doh/TODO.md` to `./TODO.md`
- [x] Update any internal references to the TODO.md location
- [x] Update CLAUDE.md to reflect new TODO.md location
- [x] Verify no scripts depend on the old TODO.md path
- [x] Remove old `.claude/doh/TODO.md` after verification

**Benefits**:

- More accessible development tracking
- Conventional project structure
- Preparation for DOH self-hosting (T022)
- Easier for contributors to find development tasks

**Deliverable**: ✅ COMPLETED TODO.md moved to project root with all references updated and functionality preserved.

---

### T026 - Restructure DOH: Move non-runtime components outside .claude 🚩

**Status**: COMPLETED ✅ - All migration and references updated, functionality validated  
**Priority**: High - Project organization and self-hosting preparation (BLOCKS T022)  
**Dependencies**: T025 (completed)  
**Version**: 1.4.0 ✅

Restructure the DOH project by moving non-runtime components from `.claude/doh/` to project root directories for better
organization and preparation for standalone distribution.

**Impact**: Currently all DOH components are in `.claude/doh/` mixing runtime scripts with development files. Clean
separation improves project structure, makes non-runtime files more accessible, and prepares for T022 self-hosting where
DOH becomes its own standalone project.

**Migration Status Analysis**:

- ✅ `.claude/doh/docs/` → `./docs/` (MIGRATED ✅)
- ✅ `.claude/doh/templates/` → `./templates/` (MIGRATED ✅)
- ✅ `.claude/doh/skel/` → `./skel/` (MIGRATED ✅) **[Keep duplicate for runtime]**
- ✅ `.claude/doh/analysis/` → `./analysis/` (MIGRATED ✅)
- ✅ `.claude/doh/tests/` → `./tests/` (MIGRATED ✅)
- ✅ `.claude/doh/README.md` → `./README.md` (MIGRATED ✅)
- ✅ `.claude/doh/CHANGELOG.md` → `./CHANGELOG.md` (MIGRATED ✅)
- ✅ `.claude/doh/VERSION.md` → `./VERSION.md` (MIGRATED ✅)
- 🔒 `.claude/doh/scripts/` - Runtime scripts (KEEP in .claude)
- 🔒 `.claude/doh/inclaude.md` - Claude Code integration (KEEP in .claude)

**Remaining Tasks**:

- [x] Move analysis files from .claude/doh/analysis/ to ./analysis/ ✅
- [x] Move test files from .claude/doh/tests/ to ./tests/ ✅
- [x] Move README.md, CHANGELOG.md, VERSION.md to project root ✅
- [x] **Comprehensive path verification**: Check ALL files for hardcoded .claude/doh/ references to migrated components
      ✅
- [x] Update all script references to new paths for migrated components ✅
- [x] Update documentation references to new locations ✅
- [x] Update CLAUDE.md and README.md references ✅
- [x] Verify no broken internal links or imports ✅
- [x] Test DOH functionality after restructure ✅
- [x] **Complete T029 cleanup subtask**: Remove migrated directories from .claude/doh/ (except skel/ for runtime) →
      Ready for execution

**Proposed New Structure**:

```text
/quazardous/doh/
├── docs/        # Documentation (moved from .claude/doh/docs/)
├── analysis/    # Development analysis (moved from .claude/doh/analysis/)
├── skel/        # Project skeleton (moved from .claude/doh/skel/)
├── templates/   # Project templates (moved from .claude/doh/templates/)
├── tests/       # Test files (moved from .claude/doh/tests/)
└── .claude/doh/
    └── scripts/ # Runtime scripts only
```text

**Benefits**:

- Cleaner separation between runtime and development components
- More conventional project layout for distribution
- Easier access to docs/analysis without navigating .claude
- Preparation for DOH self-hosting (T022)
- Better organization for contributors and end-users

**Risks & Considerations**:

- Potential breaking changes if scripts hardcode .claude/doh/ paths
- Need thorough testing of all DOH commands after restructure
- Documentation and references must be comprehensively updated
- **Critical**: Must verify ALL file references - scripts, docs, configs, templates, etc.
- Symlinks or relative paths might break after restructure

**Deliverable**: Restructured DOH project with clean separation of runtime vs development components, all functionality
preserved, and comprehensive testing completed.

---

### T027 - Implement Markdown Linting System 🚩

**Status**: Proposed  
**Priority**: Medium - Code quality and consistency  
**Dependencies**: T026 (restructure - optional)  
**Proposed Version**: 1.4.0

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

---

### T029 - Clean up migrated files from .claude/doh after T026 restructuring 🚩

**Status**: Proposed (Child task of T026)  
**Priority**: Medium - Post-migration cleanup  
**Dependencies**: T026 (restructuring completion)  
**Proposed Version**: 1.4.0

Clean up `.claude/doh/` directory by removing successfully migrated components and empty directories after T026
restructuring is complete.

**Impact**: After T026 migration, `.claude/doh/` will contain duplicate files and empty directories that should be
removed to maintain clean project structure. This cleanup task ensures no stale files remain and validates migration
success.

**Cleanup Strategy**: Based on T026 analysis, the following directories have been migrated and should be cleaned:

- ✅ **Already migrated**: `docs/`, `templates/`, `skel/` (ready for cleanup)
- ⏳ **To be migrated then cleaned**: `analysis/`, `tests/`
- 🔒 **Keep**: `scripts/` (runtime components stay in .claude)

**Tasks**:

- [ ] **Validation phase**: Verify all migrated components work correctly at new locations
- [ ] **Reference verification**: Confirm all hardcoded `.claude/doh/` paths updated for migrated components
- [ ] **Functionality testing**: Test DOH commands to ensure no broken references to migrated files
- [ ] **File freshness check**: Compare timestamps/content between source (./file) and duplicate (.claude/doh/file) to
      determine most recent version
- [ ] **Content diff analysis**: Verify no important changes exist only in .claude/doh/ versions before deletion
- [ ] **Backup creation**: Create backup of .claude/doh/ before cleanup (safety measure)
- [ ] **Cleanup docs/**: Remove `.claude/doh/docs/` directory after confirming ./docs/ is more recent
- [ ] **Cleanup templates/**: Remove `.claude/doh/templates/` directory after confirming ./templates/ is more recent
- [ ] **Cleanup analysis/**: Remove `.claude/doh/analysis/` directory after confirming ./analysis/ is more recent
- [ ] **Cleanup tests/**: Remove `.claude/doh/tests/` directory after confirming ./tests/ is more recent
- [ ] **Cleanup root files**: Remove `.claude/doh/README.md`, `.claude/doh/CHANGELOG.md`, `.claude/doh/VERSION.md` after
      content verification
- [x] **Keep skel/ duplicate**: Preserve `.claude/doh/skel/` for runtime access (per T031 architecture decision) ✅
- [x] **Keep templates/ duplicate**: Preserve `.claude/doh/templates/` for DOH agents runtime access (same logic as
      skel/) ✅
- [ ] **Remove empty directories**: Clean up any empty subdirectories in .claude/doh/
- [ ] **Final validation**: Confirm DOH functionality after cleanup

**Safety Measures**:

- Create backup before cleanup: `cp -r .claude/doh .claude/doh.backup.$(date +%Y%m%d)`
- Test all DOH commands between each cleanup step
- Keep `.claude/doh/scripts/` untouched (runtime components)
- Validate no broken symlinks or references after cleanup
- Document any issues found during cleanup process

**File Verification Strategy**:

```bash
# Compare file modification times
if [[ ./docs/file.md -nt .claude/doh/docs/file.md ]]; then
    echo "✅ ./docs/file.md is newer - safe to remove .claude/doh/ version"
else
    echo "⚠️  .claude/doh/ version may be newer - manual review needed"
fi

# Compare file content
if diff -q ./docs/file.md .claude/doh/docs/file.md; then
    echo "✅ Files identical - safe to remove duplicate"
else
    echo "⚠️  Files differ - manual merge may be needed"
    diff ./docs/file.md .claude/doh/docs/file.md
fi
```bash

**Verification Checklist per Directory**:

- **docs/**: Compare each .md file individually
- **templates/**: Compare template files for any custom modifications
- **analysis/**: Compare analysis reports (likely identical)
- **tests/**: Compare test files and data
- **Root files**: Compare README.md, CHANGELOG.md, VERSION.md content

**Expected Final State**:

```text
.claude/doh/
├── scripts/           # Runtime scripts only (PRESERVED)
│   ├── lib/          # Bash libraries (doh.sh, doh-config.sh, etc.)
│   └── *.sh         # DOH runtime scripts (100% bash + jq + awk)
├── CHANGELOG.md      # Keep project history
├── README.md         # Keep .claude/doh specific docs
├── VERSION.md        # Keep version tracking
└── inclaude.md      # Keep Claude integration docs
```

**Note**: Any `.js` files currently in scripts/ (like `get-item.js`, `project-stats.js`) should be migrated to pure bash
equivalents as part of T013 runtime optimization. The DOH runtime must remain 100% bash + jq + awk.

**Rollback Plan**: If cleanup causes issues:

1. Restore backup: `mv .claude/doh.backup.$(date) .claude/doh`
2. Investigate broken references in T026 migration
3. Fix references and retry cleanup

**Verification Tests**:

- `/doh:init` command works correctly
- All skeleton files deploy from new `./skel/` location
- Documentation references resolve correctly
- Template files accessible from new `./templates/` location
- Analysis files accessible from new `./analysis/` location
- No broken internal links in migrated documentation

**Deliverable**: Clean `.claude/doh/` directory containing only runtime components, with all migrated files removed and
functionality preserved.

---

### T030 - Fix Single Source of Truth violations in CLAUDE.md after T026 completion 🚩

**Status**: Proposed (Child task of T026)  
**Priority**: Medium - Documentation cleanup and consistency  
**Dependencies**: T026 (restructuring completion)  
**Proposed Version**: 1.4.0

Fix Single Source of Truth violations in CLAUDE.md by removing outdated structure information and replacing with
references to TODO.md after T026 restructuring is complete.

**Impact**: CLAUDE.md currently contains outdated DOH system structure information and duplicates restructuring plans
that exist in TODO.md T026. This creates confusion and maintenance burden when information gets out of sync.

**Identified Violations**:

1. **DOH System Structure (CLAUDE.md lines 32-37)**:
   - Lists old structure with `skel/`, `templates/` in `.claude/doh/`
   - Reality: These folders already migrated to project root
   - Conflicts with current state documented in T026

2. **Restructuring Plan (CLAUDE.md lines 44-76)**:
   - Presents "proposed plan" with status "Awaiting approval"
   - Reality: Plan is confirmed in T026 with Target Version 1.4.0
   - Duplicates detailed planning that belongs in TODO.md

3. **Maintenance Burden**:
   - Two places to update when structure changes
   - Risk of information drift and inconsistency

**Tasks**:

- [ ] **Remove outdated structure section**: Delete "DOH System Structure" section in CLAUDE.md
- [ ] **Remove duplicated planning**: Delete entire "Pending Restructuring Plan" section
- [ ] **Add reference to TODO.md**: Replace removed sections with brief reference to T026
- [ ] **Update Task Management section**: Ensure references to TODO.md are current
- [ ] **Verify no other duplications**: Scan CLAUDE.md for other potential Single Source of Truth violations
- [ ] **Test documentation coherence**: Ensure CLAUDE.md flows properly after removals
- [ ] **Add enforcement principle**: Document Single Source of Truth principle in CLAUDE.md

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
```text

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

### T031 - Brainstorm skel/ location for /doh:init runtime access 🚩

**Status**: COMPLETED ✅ (Child task of T026)  
**Priority**: Medium - Critical architecture decision  
**Dependencies**: T026 (restructuring completion)  
**Version**: 1.4.0 ✅

Brainstorm and resolve the skeleton location issue for `/doh:init` runtime access after T026 restructuring moved `skel/`
outside `.claude` directory.

**Impact**: T026 moved `skel/` from `.claude/doh/skel/` to `./skel/` but `/doh:init` is a runtime command that only has
access to `.claude/doh/` directory structure. When users run `/doh:init` on new projects, the skeleton files may not be
accessible, breaking project initialization.

**Problem Analysis**:

**Current Situation After T026**:

- ✅ `skel/` moved to project root (development access improved)
- ❌ `/doh:init` runtime script expects skeleton in `.claude/doh/skel/`
- ❌ Runtime commands only have access to `.claude/doh/` directory
- ❌ Potential broken initialization for new projects

**Runtime vs Development Access**:

- **Runtime Scripts** (`.claude/doh/scripts/`): 100% bash + jq + awk, distributed with DOH
- **Development Files** (`./skel/`, `./docs/`, etc.): Not available during `/doh:init` execution
- **Distribution Challenge**: How does distributed DOH access skeleton files?

**Brainstorming Options**:

#### Option A: Revert skel/ to .claude/doh/

- ✅ Runtime access preserved
- ❌ Mixes development and runtime files again
- ❌ Goes against T026 separation principle

#### Option B: Duplicate skel/ in both locations

- ✅ Runtime access + development access
- ❌ Maintenance burden (sync two copies)
- ❌ Violates Single Source of Truth

#### Option C: Sideload/Bundle skel/ during distribution

- ✅ Clean separation maintained
- ✅ Runtime access via bundling
- ❌ Complex distribution process
- ❓ How to implement sideloading?

#### Option D: Runtime skel/ generation

- ✅ No file access needed
- ✅ Always up-to-date
- ❌ Complex implementation
- ❓ Bash-only skeleton generation

#### Option E: Hybrid approach (skel/ stays, templates/ moved)

- ✅ Runtime access for skeleton
- ✅ Development files separated
- ❌ Inconsistent separation
- ❓ Which files are truly "runtime"?

**Research Questions**:

- How does `/doh:init` currently access skeleton files?
- What other runtime commands need access to template files?
- Can skeleton files be embedded in scripts?
- Is sideloading feasible with current architecture?
- What's the distribution model for DOH runtime?

**Tasks**:

- [ ] **Analyze current /doh:init implementation**: How does it access skeleton files?
- [ ] **Test skeleton access**: Verify if `/doh:init` breaks after T026 migration
- [ ] **Research distribution model**: How will DOH be distributed to end users?
- [ ] **Evaluate sideloading options**: Can skeleton be bundled with runtime?
- [ ] **Consider embedded skeleton**: Can skeleton structure be generated by bash scripts?
- [ ] **Define runtime vs development boundary**: Which files truly need runtime access?
- [ ] **Make architecture decision**: Choose approach based on analysis
- [ ] **Implement chosen solution**: Update structure and scripts accordingly
- [ ] **Test end-to-end**: Verify `/doh:init` works in distributed environment
- [ ] **Update documentation**: Document final skeleton access architecture

**Decision Criteria**:

- **Runtime functionality**: `/doh:init` must work reliably
- **Clean separation**: Maintain development vs runtime distinction
- **Maintenance burden**: Minimize sync/duplication overhead
- **Distribution complexity**: Keep distribution process simple
- **Future scalability**: Support DOH system evolution

**ARCHITECTURE DECISION**: ✅ **Option B - Duplication Contrôlée**

**Final Decision**: Maintenir **duplication contrôlée** entre sources et runtime pour **skel/ ET templates/** :

- ✅ **Sources**: `./skel/`, `./templates/` pour développement et modification
- ✅ **Runtime**: `.claude/doh/skel/` pour `/doh:init` access, `.claude/doh/templates/` pour agents DOH
- ✅ **Build Process**: À définir dans T032 pour sync sources → runtime artifacts
- ✅ **Single Source of Truth**: `./skel/`, `./templates/` sont les sources, `.claude/doh/*` sont build artifacts

**Implementation Status**:

- [x] Confirmed `/doh:init` functionality works with current setup
- [x] Architecture decision made (Option B)
- [ ] Build process design (→ T032)
- [ ] Documentation update

**Deliverable**: ✅ COMPLETED Architecture decision finalized: Duplication contrôlée avec build process à définir.

---

### T032 - Design DOH Runtime Build Process (.claude/doh/ as build directory) 🚩

**Status**: Proposed (Related to T031 architecture decision)  
**Priority**: Medium - Build system architecture  
**Dependencies**: T031 (architecture decision)  
**Proposed Version**: 1.4.0

Design and implement build process for DOH runtime where `.claude/doh/` serves as build directory containing runtime
artifacts copied from source files.

**Impact**: T031 decision established `.claude/doh/` as runtime/build directory with controlled duplication. Need proper
build system to maintain sync between source files (`./skel/`, `./templates/`, `./docs/`) and runtime artifacts
(`.claude/doh/skel/`, etc.) while preserving Single Source of Truth principle.

**Architecture Model**:

```text
# Source Files (Development)
./skel/           # Master skeleton files
./templates/      # Master templates
./docs/           # Master documentation
./analysis/       # Master analysis

# Build Directory (Runtime Distribution)
.claude/doh/
├── scripts/      # Runtime scripts (native)
├── skel/         # Built skeleton (← copied from ./skel/)
├── templates/    # Built templates (← copied from ./templates/)
└── docs/         # Built docs (← copied from ./docs/)
```

**Build Process Requirements**:

1. **Source → Build Sync**:
   - Copy `./skel/` → `.claude/doh/skel/`
   - Copy `./templates/` → `.claude/doh/templates/`
   - Copy `./docs/` → `.claude/doh/docs/`
   - Preserve file permissions and timestamps

2. **Build Validation**:
   - Verify all runtime dependencies present
   - Validate JSON schemas and configurations
   - Check bash script syntax
   - Test runtime functionality

3. **Change Detection**:
   - Only rebuild when source files change
   - Incremental build support
   - Build artifacts versioning

4. **Clean Operations**:
   - Clean build artifacts
   - Rebuild from scratch
   - Separate development files from build

**Integration Points**:

**Makefile Integration**:

```makefile
build:          ## Build runtime artifacts from sources
build-clean:    ## Clean build artifacts and rebuild from sources
build-check:    ## Validate build artifacts integrity
build-lint:     ## Lint generated Markdown files in build artifacts
build-test:     ## Test runtime functionality after build
clean:          ## Clean all build artifacts (skel/, templates/ in .claude/doh/)
```makefile

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
```makefile

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
```makefile

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

### T028 - Development Environment Setup & Automation 🚩

**Status**: Proposed  
**Priority**: Medium - Developer toolchain infrastructure  
**Dependencies**: T027 (linting system - required for hooks), T026 (restructure - optional)  
**Target Version**: 1.4.0

Design and implement development environment setup strategy with technology decisions for build automation, dependency
management, and contributor onboarding process.

**Impact**: Currently DOH lacks standardized development tooling and installation process. Need to decide on
technologies (make vs npm scripts vs custom bash), dependency management strategy (homebrew, apt, manual), and create
streamlined contributor onboarding. This foundational decision impacts T024 testing framework and T022 self-hosting.

**Proposed Structure**:

```text
/quazardous/doh/
├── dev-tools/               # Development toolchain (NEW)
│   ├── linters/             # All linting configurations
│   │   ├── .markdownlint.json
│   │   ├── .shellcheck.rc
│   │   └── lint-runner.sh
│   ├── hooks/               # Git hooks templates
│   │   ├── pre-commit
│   │   ├── pre-push
│   │   └── install-hooks.sh
│   └── scripts/             # Development automation
│       ├── setup-dev-env.sh
│       ├── check-dependencies.sh
│       └── run-all-checks.sh
├── Makefile                 # Build automation (NEW)
└── package.json             # Dev dependencies only (NEW)
```

**Technology Decisions Required**:

**1. Build Automation**:

- **Makefile** - Standard, universal, simple
- **npm scripts** - Node.js ecosystem integration
- **Custom bash scripts** - DOH-native approach
- **Task runner** (gulp, grunt) - Overkill?

**2. Dependency Management Strategy**:

- **Homebrew** (macOS) + **apt/yum** (Linux) - Platform-specific
- **asdf** - Version manager for multiple tools
- **Manual installation** - Simple but error-prone
- **Docker dev container** - Isolated but complex
- **Nix** - Reproducible but niche

**3. Package Management**:

- **npm only** - Simple, Node.js standard
- **npm + system packages** - Hybrid approach
- **Pure system packages** - Platform-dependent
- **No package management** - Manual dependency tracking

**Tasks**:

- [x] **Technology evaluation**: ✅ Makefile chosen for build automation
- [x] **Installation strategy**: ✅ Makefile with intelligent package manager detection
- [ ] **Package management**: Implement npm + system packages hybrid approach
- [ ] **Platform support**: Implement Linux, macOS, Windows/WSL coverage
- [ ] **Directory structure**: Design dev-tools/ organization
- [ ] **Pre-commit hooks integration**: Set up hooks with linter integration (T027)
- [ ] **Makefile implementation**: Create dev-setup, lint, test, hooks-install targets
- [ ] **Developer onboarding**: Create streamlined setup process
- [ ] **Documentation**: Write contributor setup guide
- [ ] **Testing**: Validate across platforms and scenarios

**Makefile Targets** (updated with decisions):

```makefile
# Development setup
dev-setup:     # One-command dev environment (deps-install + npm + hooks)
deps-install:  # Install system dependencies (node, jq, shellcheck)
deps-check:    # Verify all dependencies present

# Quality & linting
lint:          # Run all linters (markdown, shell, etc.)
lint-fix:      # Auto-fix linting issues where possible
check:         # All quality checks (lint + test)

# Git hooks management
hooks-install: # Install pre-commit hooks with linter integration
hooks-update:  # Update git hooks
hooks-remove:  # Remove git hooks

# Testing & building
test:          # Run test suite (T024)
build:         # Prepare distribution
clean:         # Clean build artifacts
install:       # Install DOH system locally
```makefile

**Pre-commit Hooks Strategy**:

- **Linter integration**: Use T027 markdownlint + shellcheck
- **Lightweight**: Only essential checks (syntax, basic lint)
- **Symlinked**: dev-tools/hooks/ → .git/hooks/ symlinks
- **Optional**: Easy to disable for urgent commits (`--no-verify`)
- **Fast**: Sub-second execution time target
- **Makefile managed**: `make hooks-install` for setup

**Development Dependencies** (package.json):

```json
{
  "devDependencies": {
    "markdownlint-cli": "^0.x.x"
  },
  "scripts": {
    "lint:md": "markdownlint *.md docs/ analysis/",
    "dev:setup": "make dev-setup"
  }
}
```bash

**Benefits**:

- Consistent development environment for all contributors
- Automated quality checks prevent issues before commits
- Streamlined onboarding for new DOH developers
- Foundation for T024 testing framework
- Professional development workflow matching DOH quality standards

**Risks & Considerations**:

- Complexity might deter casual contributors
- Need balance between automation and flexibility
- Git hooks can be bypassed (--no-verify)
- Cross-platform compatibility (Linux, macOS, WSL)
- Integration with existing DOH bash-first philosophy

**Dependencies Philosophy Compliance**:

- ✅ DOH System Development: Uses Node.js, dev tools as needed
- ✅ DOH Runtime: Remains 100% bash + jq + awk
- ✅ Clear separation maintained

**Decision Factors**:

- **Simplicity**: Easy for contributors to understand and use
- **Cross-platform**: Works on Linux, macOS, Windows/WSL
- **DOH philosophy**: Aligns with bash-first approach
- **Maintenance**: Low overhead for DOH team
- **Industry standard**: Familiar to developers

**Examples of Setup Processes**:

```bash
# Option A: Makefile + Homebrew/apt
brew install node jq shellcheck  # macOS
make dev-setup

# Option B: npm-centric
npm install
npm run dev:setup

# Option C: Pure bash
./dev-tools/scripts/setup-dev-env.sh

# Option D: asdf
asdf install
make dev-setup
```bash

**Deliverable**: Technology decisions documented with chosen build automation, dependency management strategy, and
streamlined contributor onboarding process.

---

## TODO Managment

### Rules

- Update **Next TODO ID** in header when adding new TODO
- Add to **Active TODOs** list with appropriate priority section
- Keep descriptions concise and actionable
- Use GitHub-like format for clean diffs
- **Never move TODOs** when status changes (preserve diff history)
- Mark completed TODOs in CHANGELOG.md, not here
- Use proper version nomenclature (see Version Management below)

### Version Management

**Version Nomenclature** for TODO tasks follows task lifecycle:

1. **Proposed Version**: `1.4.0` - Initial estimation by Claude/developer at task creation
2. **Target Version**: `1.4.0` - Version confirmed when dependencies/planning are clearer
3. **Version**: `1.4.0` - Final version when roadmap is locked OR task is active/completed

**Task Lifecycle & Version Evolution**:

```markdown
# Initial estimation (Claude proposes)

Status: Proposed + Proposed Version: 1.4.0

# Validated for version (planning confirmed)

Status: Proposed + Target Version: 1.4.0

# Roadmap locked OR implementation starts

Status: Ready + Version: 1.4.0

# Active implementation

Status: In Progress + Version: 1.4.0

# Task completed

Status: Completed + Version: 1.4.0 ✅
```text

**Key Decision Points**:

- **Proposed → Target**: When task is validated for specific version
- **Target → Version**: When roadmap is finalized OR implementation begins
- **Version stays fixed**: Once set, version doesn't change (tracks completion version)

**Status + Version Combinations**:

- `Status: Proposed` + `Target Version: X.Y.Z` = **Validated for this version** ✅
- `Status: Ready` + `Version: X.Y.Z` = **Implementation ready, roadmap locked**
- `Status: In Progress` + `Version: X.Y.Z` = **Currently being implemented**
- `Status: Completed` + `Version: X.Y.Z ✅` = **Completed in this version**

### Completion Workflow

When a TODO is completed:

1. **Update CHANGELOG.md**: Add entry with TODO reference and completion date
2. **Update VERSION.md**: If TODO affects version, update runtime/dev versions
3. **Remove from Active TODOs**: Remove completed TODO from priority sections
4. **Update dependencies**: Mark dependent TODOs as unblocked if applicable
5. **Archive TODO**: Move completed section to CHANGELOG, preserve TODO body for reference

---

---

_Clean TODO list - History in CHANGELOG.md, Versions in VERSION.md_

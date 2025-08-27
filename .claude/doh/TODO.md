# TODO - /doh System Evolution

**Last Updated**: 2025-08-27  
**Next TODO ID**: T024

---

## 📑 Active TODOs

### Critical Priority  
- **T022** 🚩🚩 DOH System Self-Hosting Project [PROPOSED - Foundation for everything]
- **T013** 🚩🚩 Performance Optimization via Internal Bash Scripts [COMPLETED ✅]

### High Priority
- **T019** 🚩 DOH System Integration Testing [PROPOSED - Foundation validation]
- **T020** 🚩 Enhanced Codebase Analysis Engine [PROPOSED - Replaces T002 with advanced features]
- **T003** 🚩 Complete Architecture & Distribution System
- **T005** 🚩 Installation/Distribution Scripts
- **T011** 🚩 GitHub/GitLab Synchronization Implementation
- **T017** 🚩 Bash Routine Expansion Analysis [UNBLOCKED - T013 ready, T014 optional]

### Future Enhancements
- **T021** 🚩 Intelligent Template System [FUTURE - Context-aware templates for v2.0.0]

### Medium Priority
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
**Target Version**: 1.3.0  

Create standardized `.doh/` skeleton structure for consistent project initialization. 
The skeleton provides a template that both `/doh:init` and `/doh:analyze` can use.

**Impact**: 
Currently `/doh:init` and `/doh:analyze` lack standard templates, causing inconsistent .doh setups across projects.

**Tasks**:
- [ ] Create `.claude/doh/skel/` directory structure
- [ ] Create `project-index.json` template with proper schema
- [ ] Create `.gitignore` with sections for DOH components
- [ ] Create empty `memory/` directories (project/, epics/, agent-sessions/)
- [ ] Create `epics/quick/epic0.md` template for Epic #0
- [ ] Update `/doh:init` command to use skeleton
- [ ] Test skeleton deployment

**Deliverable**: 
Complete skeleton structure ready for use by initialization commands.

---

### T002 - Codebase Reverse Engineering (/doh:analyze) 🚩

**Status**: Not started  
**Priority**: High - Critical for /doh adoption on existing projects  
**Dependencies**: T001 (skeleton structure)  
**Target Version**: 1.4.0  

Create `/doh:analyze` command that analyzes existing codebases and suggests Epic/PRD structure for teams adopting /doh on legacy projects.

**Impact**: 
Enable /doh adoption without manual Epic/PRD creation. Essential for onboarding teams with existing codebases.

**Tasks**:
- [ ] Create `/doh:analyze` command specification
- [ ] Implement static code analysis for module boundaries
- [ ] Add git log analysis for feature patterns
- [ ] Create technology stack detection
- [ ] Implement safety checks for existing .doh projects
- [ ] Add suggested structure generation
- [ ] Create comprehensive safety warnings

**Deliverable**: 
AI-powered codebase analysis command ready for production use.

---

### T003 - Complete Architecture & Distribution System 🚩

**Status**: Architecture scattered  
**Priority**: High - Required for /doh distribution  
**Dependencies**: T001 (skeleton)  

Consolidate scattered /doh components into distributable package with installation system.

**Impact**: 
Currently /doh components are scattered across project making distribution impossible. Blocks /doh adoption by other teams.

**Tasks**:
- [ ] Design distribution package structure
- [ ] Create installation script (install.sh)
- [ ] Create uninstallation script (uninstall.sh)
- [ ] Package all /doh components
- [ ] Create example projects
- [ ] Test installation on clean systems

**Deliverable**: 
Distributable /doh system package with bulletproof installation.

---

### T004 - File System Structure Validation 🚩

**Status**: Needs validation  
**Priority**: High - Blocking next features  
**Dependencies**: None  

Validate current /doh file structure against specifications to identify inconsistencies between documented architecture and actual implementation.

**Impact**: 
Inconsistencies between spec and reality could block future features and cause integration issues.

**Tasks**:
- [ ] Audit `.claude/doh/.cache` vs `index.json` transition  
- [ ] Verify `.doh/memory/` folder structure implementation
- [ ] Check template vs real usage consistency
- [ ] Complete mapping of all current /doh files
- [ ] Test hierarchical memory loading system

**Deliverable**: 
Complete audit report with reorganization plan.

---

### T005 - Installation/Distribution Scripts 🚩

**Status**: Not started  
**Priority**: High - Required for /doh distribution  
**Dependencies**: T003 (distribution system)  

Create complete install/publish/update workflow for /doh system distribution.

**Impact**: 
Currently no installation workflow exists, blocking /doh adoption by other teams.

**Tasks**:
- [ ] Create `/doh:install` command for new project installation
- [ ] Enhance `/doh:init` with smart detection and re-indexing
- [ ] Create `/doh:update` command for system updates
- [ ] Create backup/restore commands (`export-project`, `import-project`)
- [ ] Create `/doh:reset-project` for cleanup
- [ ] Create `/doh:publish-system` for distribution

**Deliverable**: 
Complete lifecycle management with 1-command installation.

---

### T011 - GitHub/GitLab Synchronization Implementation 🚩

**Status**: Specified, needs implementation  
**Priority**: High - Critical for team collaboration  
**Dependencies**: T001 (skeleton), T004 (validation)  

Implement bidirectional GitHub/GitLab synchronization from existing specifications.

**Impact**: 
Teams need GitHub issue sync for proper collaboration and tracking.

**Tasks**:
- [ ] Implement `/doh:sync-github` command from specification
- [ ] Create automatic !123 → #456 mapping system
- [ ] Implement conflict management and resolution
- [ ] Add sync state tracking and dirty/clean timestamps
- [ ] Create sync validation and error handling
- [ ] Test with real GitHub/GitLab repositories

**Deliverable**: 
Production-ready bidirectional synchronization system.

---

### T012 - Centralized Dependency Management 🚩

**Status**: Partially implemented  
**Priority**: High - Core infrastructure  
**Dependencies**: None  

Complete the dependency management system for task/epic relationships.

**Impact**: 
Dependency tracking is essential for proper project management and agent coordination.

**Tasks**:
- [ ] Enhance existing `/doh:dependency` command
- [ ] Implement dependency validation and circular detection
- [ ] Create dependency visualization tools
- [ ] Add dependency-aware scheduling for agents
- [ ] Integrate with GitHub sync for dependency links

**Deliverable**: 
Complete dependency management with validation and visualization.

---

### T006 - Intelligent Complexity Analysis

**Status**: Concept defined  
**Priority**: Medium - Enhances `/doh:quick`  
**Dependencies**: T001 (skeleton)  

Create clarifying questions system for complex task analysis.

**Impact**: 
Improves task creation quality by detecting scope and complexity automatically.

**Tasks**:
- [ ] Implement simple/complex scope detection
- [ ] Create automatic clarifying questions system
- [ ] Add phasing vs upgrading recommendations
- [ ] Integrate with `/doh:quick` command

**Deliverable**: 
Intelligent analysis that asks smart questions for better task definition.

---

### T007 - Automatic Epic #0 Graduation

**Status**: Concept defined  
**Priority**: Medium - Improves organization  
**Dependencies**: T001 (skeleton), T006 (analysis)  

Detect when Epic #0 becomes too specialized and suggest dedicated epics.

**Impact**: 
Prevents Epic #0 from becoming cluttered while maintaining ease of use.

**Tasks**:
- [ ] Define graduation thresholds (6+ related tasks)
- [ ] Create epic suggestion interface
- [ ] Implement automatic task migration to new epics
- [ ] Add graduation notifications and recommendations

**Deliverable**: 
Intelligent epic creation suggestions with automatic migration.

---

### T008 - CLAUDE.md Integration & Strategy Detection

**Status**: Concept defined  
**Priority**: Medium - Improves onboarding  
**Dependencies**: T001 (skeleton), T005 (installation)  

Create flexible DOH integration levels with automatic project detection.

**Impact**: 
Makes /doh adoption easier with appropriate configuration per project type.

**Tasks**:
- [ ] Implement worktree strategy detection
- [ ] Create DOH levels (0-4: Minimal to Enterprise)
- [ ] Add smart auto-detection (language, project type, git remote)
- [ ] Create interactive configuration mode
- [ ] Generate appropriate CLAUDE.md sections per level

**Deliverable**: 
Flexible DOH configuration with intelligent project analysis.

---

### T009 - Optimized Templates

**Status**: Need identified  
**Priority**: Low - Quality improvement  
**Dependencies**: T001 (skeleton)  

Create tiered templates for faster task/epic creation.

**Impact**: 
Current templates are too verbose, slowing down task creation.

**Tasks**:
- [ ] Create micro template (10 lines) for simple tasks
- [ ] Create mini template (30 lines) for standard tasks
- [ ] Create standard template (60 lines) for epics/features
- [ ] Integrate template selection in creation commands

**Deliverable**: 
Faster creation workflow with size-appropriate templates.

---

### T010 - Universal Command `/doh`

**Status**: Emerging concept  
**Priority**: Low - Future enhancement  
**Dependencies**: T006 (analysis), T002 (analyze)  
**Target Version**: 2.0.0  

Create universal intelligent contextualization command.

**Impact**: 
Provides "it's obvious" moments - right context at right time for both humans and AI.

**Tasks**:
- [ ] Implement natural language intent recognition
- [ ] Create context-aware response system
- [ ] Add intelligent suggestions and next steps
- [ ] Integrate with all existing /doh commands

**Deliverable**: 
Universal command that understands intent and provides perfect context.

---

### T014 - DOH Data Structure Analysis for Scripting

**Status**: Not started  
**Priority**: Medium - Foundation for performance optimization  
**Dependencies**: None  
**Target Version**: 1.4.0  

Analyze and document DOH data structures to identify optimal patterns for bash script automation and determine standardization needs.

**Impact**: 
Current DOH data structures may not be optimized for bash parsing. Understanding the data patterns, file formats, and access patterns will enable efficient script creation and identify potential structure improvements.

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

**Deliverable**: 
Comprehensive analysis document with data structure documentation, bash-scripting recommendations, and standardized data access patterns ready for T013 implementation.

---

### T015 - DOH Configuration File Design

**Status**: Not started  
**Priority**: Medium - Foundation for flexible configuration  
**Dependencies**: None  
**Target Version**: 1.4.0  

Design and brainstorm a configuration file system for .doh projects to standardize settings, preferences, and project-specific behaviors.

**Impact**: 
Currently DOH behavior is hardcoded or scattered across multiple files. A centralized config system would enable project-specific customization, better defaults, and easier script automation while maintaining consistency.

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

**Deliverable**: 
Configuration file specification with schema, template for skeleton, and integration plan for scripts and Claude commands.

---

### T016 - DOH Configuration Integration Validation

**Status**: Not started  
**Priority**: High - Ensure config system actually works  
**Dependencies**: T015 (configuration design)  
**Target Version**: 1.4.0  

Verify that the configuration system (config.ini + doh-config.sh) integrates properly with existing DOH codebase and scripts.

**Impact**: 
The new configuration system must work seamlessly with current DOH commands, scripts, and workflows. Need to ensure existing functionality isn't broken and configuration is properly utilized.

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

**Deliverable**: 
Fully integrated configuration system that works with all existing DOH functionality, with comprehensive testing and validation of real-world usage.

---

### T013 - Performance Optimization via Internal Bash Scripts

**Status**: Ready to implement  
**Priority**: Critical - Performance and cost optimization  
**Dependencies**: None (can use existing data structures)  
**Target Version**: 1.4.0  

Create internal bash utility scripts to replace Claude AI calls for simple data extraction and file operations, reducing token usage and improving performance.

**Impact**: 
Many internal operations (JSON parsing, file reading, simple data extraction) don't require Claude intelligence. Creating bash utilities for these routine tasks can significantly reduce API costs and improve response times.

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

**Deliverable**: 
Battle-tested internal bash utility library with comprehensive error handling and Claude AI failsafe fallback. Scripts must be robust enough for production use, with automatic fallback to Claude when bash operations fail or encounter unexpected scenarios.

### T017 - Bash Routine Expansion Analysis 🚩🚩

**Status**: Not started  
**Priority**: High - Capitalize on T013 POC success  
**Dependencies**: T013 (bash scripts), T014 (data structure analysis)  
**Target Version**: 1.4.0  

Analyze current DOH command usage patterns and identify next batch of bash routine candidates to maximize token savings and performance gains.

**Impact**: 
T013 POC proved bash optimization delivers 150-500x performance gains and 100% token savings for routine operations. Need systematic analysis to identify which additional operations should be bash-scripted next for maximum ROI.

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

**Candidate Operations Analysis**:
Based on T014 findings, analyze these operation categories:
- **Search Operations**: `search-tasks.sh`, `find-by-title.sh`, `grep-content.sh`
- **Update Operations**: `update-status.sh`, `update-metadata.sh`, `batch-update.sh`
- **Validation Operations**: `validate-structure.sh`, `check-dependencies.sh`, `lint-markdown.sh`
- **File Operations**: `list-files.sh`, `count-by-type.sh`, `recent-changes.sh`
- **Query Operations**: `epic-tasks.sh`, `status-summary.sh`, `dependency-graph.sh`

**Deliverable**: 
Prioritized roadmap for next wave of bash routine implementation with effort estimates, ROI calculations, and implementation patterns for consistent script development.

### T018 - Project Path Resolution Strategy ✅

**Status**: COMPLETED (2025-08-27)  
**Priority**: High - Critical for cross-environment compatibility  
**Dependencies**: None  
**Target Version**: 1.4.0 ✅  

Design and implement robust PROJECT_ROOT detection strategy that handles symlinks, encrypted filesystems, bind mounts, and preserves Claude Code working directory preference while ensuring bash script compatibility.

**Impact**: 
Current path resolution causes issues with symlinks, encrypted filesystems (.private), bind mounts, and different working directories. DOH scripts must work seamlessly whether launched from Claude Code directory or bash command line, with predictable behavior across all common filesystem scenarios.

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
```

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

**Deliverable**: ✅ COMPLETED
Robust path resolution system that works seamlessly across all common filesystem scenarios, preserves user's preferred working directory, and provides clear debugging when path issues occur.

---

### T019 - DOH System Integration Testing 🚩🚩

**Status**: Proposed  
**Priority**: CRITICAL - Foundation validation before T002  
**Dependencies**: T001 (skeleton), T018 (path resolution)  
**Target Version**: 1.4.0  

Create comprehensive integration test suite to validate that all completed components work together seamlessly before building T002 (codebase analysis).

**Impact**: 
With T001, T015, T016, T018 completed, we need validation that skeleton deployment, path resolution, configuration system, and UUID generation work together across different environments.

**Tasks**:
- [ ] Create test suite for skeleton deployment in various environments
- [ ] Test path resolution across symlinks, .private, bind mounts
- [ ] Validate UUID generation and project identity system
- [ ] Test configuration system with different INI scenarios
- [ ] Create automated test runner for CI/CD compatibility  
- [ ] Test cross-environment compatibility (different users, paths, filesystems)
- [ ] Validate error handling and graceful degradation
- [ ] Performance testing for path resolution in large directory trees

**Deliverable**: 
Battle-tested DOH foundation ready for T002 codebase analysis implementation.

---

### T020 - Enhanced Codebase Analysis Engine 🚩

**Status**: Proposed  
**Priority**: High - Builds on T002 specification  
**Dependencies**: T001 (skeleton), T018 (path resolution), T019 (integration tests)  
**Target Version**: 1.4.0  

Implement the `/doh:analyze` command with advanced codebase analysis capabilities beyond the original T002 specification.

**Impact**: 
Enable teams to adopt DOH on existing codebases with intelligent epic/task structure suggestions based on code analysis, git history, and architectural patterns.

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

**Deliverable**: 
Production-ready `/doh:analyze` command that provides intelligent codebase analysis and epic structure recommendations for seamless DOH adoption.

---

### T021 - Intelligent Template System 🚩

**Status**: Future  
**Priority**: High - Enhances T009 with AI capabilities  
**Dependencies**: T020 (codebase analysis), T018 (path resolution)  
**Target Version**: 2.0.0  

Create an intelligent template system that adapts to project context, technology stack, and team patterns discovered by codebase analysis.

**Impact**: 
Replace static templates with context-aware templates that adapt to the specific project, reducing friction and improving adoption by providing relevant, tailored content.

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

**Deliverable**: 
Context-aware template system that dramatically reduces template verbosity while increasing relevance and adoption rates.

---

```markdown
### T022 - DOH System Self-Hosting Project 🚩🚩

**Status**: Proposed  
**Priority**: CRITICAL - Foundation for distribution and testing  
**Dependencies**: T013 (completed), T018 (completed)  
**Target Version**: 1.4.0  

Create the DOH system as its own standalone project that uses DOH to manage its own development (self-hosting), with comprehensive testing framework and proper distribution architecture.

**Impact**: 
DOH currently lives inside another project. Creating DOH as its own project enables proper distribution (T003), serves as reference implementation, and provides isolated testing environment. The DOH system should "eat its own dog food" by using DOH to manage DOH development.

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
```
doh-system/
├── .doh/                    # RESERVED - Only for production DOH self-management
│   └── (initialized only when DOH is ready for production use)
├── bin/                     # Executable scripts
│   ├── doh-init
│   ├── doh-admin
│   └── doh
├── lib/                     # Core libraries
│   ├── doh.sh
│   ├── doh-config.sh
│   └── doh-wrappers.sh
├── scripts/                 # Utility scripts
│   ├── performance/
│   ├── migration/
│   └── utilities/
├── tests/                   # Comprehensive test suite
│   ├── unit/               # Unit tests
│   ├── integration/        # Integration tests
│   ├── e2e/               # End-to-end tests
│   ├── performance/       # Performance benchmarks
│   ├── fixtures/          # Test fixtures and data
│   └── projects/          # Test projects (NEVER use .doh in tests!)
│       ├── minimal/       # Minimal test project
│       │   └── test-data/ # Test data instead of .doh
│       ├── standard/      # Standard test project
│       │   └── test-data/ # Test data instead of .doh
│       └── complex/       # Complex test project
│           └── test-data/ # Test data instead of .doh
├── templates/              # DOH templates
│   ├── epics/
│   ├── tasks/
│   └── skeleton/
├── docs/                   # Documentation
│   ├── api/               # API documentation
│   ├── guides/            # User guides
│   └── architecture/      # System architecture
├── install.sh             # Installation script
├── uninstall.sh          # Uninstallation script
└── Makefile              # Build/test automation
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

**Deliverable**: 
Standalone DOH system project that is self-hosting, fully tested, and ready for distribution. Serves as both the development environment for DOH and the reference implementation for DOH best practices.

---

### T023 - Prevent /init Auto-Trigger of /doh:init

**Status**: COMPLETED ✅ - 2025-08-27  
**Priority**: High - User experience improvement  
**Dependencies**: None  
**Target Version**: 1.4.0  

Ensure that `/init` command does not automatically trigger `/doh:init` without user consent.

**Solution Implemented**: 
Added mandatory confirmation prompt to `/doh:init` script. Now `/doh:init` always prompts users for confirmation before proceeding, making it cancellable even when auto-triggered by `/init`.

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
**Target Version**: 1.3.0 / 1.4.0 / 2.0.0 (optional)  

Brief description in 1-2 sentences explaining what needs to be done and why.

**Impact**: 
Why this matters, who it affects, what happens if we don't do it.

**Tasks**:
- [ ] Concrete actionable task 1
- [ ] Concrete actionable task 2  
- [ ] Concrete actionable task 3

**Deliverable**: 
What will be produced when this TODO is completed.
```

### Rules

- Update **Next TODO ID** in header when adding new TODO
- Add to **Active TODOs** list with appropriate priority section  
- Keep descriptions concise and actionable
- Use GitHub-like format for clean diffs
- **Never move TODOs** when status changes (preserve diff history)
- Mark completed TODOs in CHANGELOG.md, not here
- Use Target Version for release planning (optional)

### Completion Workflow

When a TODO is completed:

1. **Update CHANGELOG.md**: Add entry with TODO reference and completion date
2. **Update VERSION.md**: If TODO affects version, update runtime/dev versions
3. **Remove from Active TODOs**: Remove completed TODO from priority sections
4. **Update dependencies**: Mark dependent TODOs as unblocked if applicable
5. **Archive TODO**: Move completed section to CHANGELOG, preserve TODO body for reference

---

*Clean TODO list - History in CHANGELOG.md, Versions in VERSION.md*
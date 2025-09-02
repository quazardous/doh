---
name: data-api-sanity
description: Ensure DOH Data API libraries are self-contained with proper dependencies and commands use API functions
status: backlog
created: 2025-09-02T06:56:43Z
target_version: 0.7.0
file_version: 0.1.0
---

# PRD: data-api-sanity

## Executive Summary

Establish robust, self-contained DOH Data API libraries by ensuring each library properly sources its dependencies, refactoring core functions into a dedicated base library, and verifying that all DOH commands use API functions rather than direct file access. This initiative will eliminate runtime errors from missing dependencies and ensure consistent data access patterns across the entire codebase.

## Problem Statement

The DOH project currently has two critical issues in its data access layer:

1. **Library dependency chaos**: Libraries use functions from other libraries without sourcing them, causing runtime errors when used independently. For example:
   - `workspace.sh` calls `_find_doh_root` without sourcing `dohenv.sh`
   - Libraries assume other libraries are pre-loaded
   - No clear dependency chain or self-sufficiency

2. **Inconsistent data access**: Commands directly read files (like `cat VERSION`) instead of using API functions (`get_current_version`), leading to:
   - Duplicated logic across commands
   - Inconsistent error handling
   - Harder maintenance and refactoring
   - Breaking the abstraction layer

These issues cause frustration for developers and AI agents, increase debugging time, and make the codebase fragile and harder to maintain.

## User Stories

### Primary User: DOH Developer
**As a** DOH developer  
**I want** to source any library independently without errors  
**So that** I can use specific functions without understanding the entire dependency tree

**Acceptance Criteria:**
- Each library sources all required dependencies
- No runtime errors when sourcing a single library
- Clear documentation of what each library provides
- Libraries work in isolation for testing

### Primary User: AI Agent
**As an** AI agent executing DOH commands  
**I want** clear library loading patterns and consistent API usage  
**So that** I can reliably execute operations without trial and error

**Acceptance Criteria:**
- Single source command loads all dependencies
- Commands use API functions exclusively
- No direct file reading in command implementations
- Predictable function availability

### Primary User: Command Developer
**As a** command developer  
**I want** to use high-level API functions for all data access  
**So that** implementation details are abstracted and my commands remain stable

**Acceptance Criteria:**
- API functions for all common operations
- No need to know file locations or formats
- Consistent error handling from API
- API functions handle edge cases

## Requirements

### Functional Requirements

#### 1. Core Library Refactoring
1. **Create core library (`doh.sh` or enhance `dohenv.sh`)**:
   - Move `_find_doh_root` → `find_doh_root` (remove underscore prefix)
   - Include fundamental functions used across libraries
   - This becomes the only library without dependencies
   - All other libraries source this first

2. **Dependency resolution**:
   - Each library explicitly sources its dependencies at the top
   - Use source guards to prevent duplicate sourcing:
     ```bash
     [[ -n "$DOH_LIB_VERSION_LOADED" ]] && return 0
     DOH_LIB_VERSION_LOADED=1
     ```
   - Exception: `dohenv.sh` should NOT be sourced by other libraries

3. **Library self-sufficiency matrix**:
   ```
   Library             Must Source
   --------           ------------
   dohenv.sh          (none - base library)
   numbering.sh       dohenv.sh
   frontmatter.sh     (none - standalone)
   workspace.sh       dohenv.sh
   version.sh         dohenv.sh, frontmatter.sh
   registers.sh       dohenv.sh, workspace.sh
   file-cache.sh      dohenv.sh, workspace.sh, registers.sh
   graph-cache.sh     dohenv.sh, workspace.sh, numbering.sh, frontmatter.sh
   ```

#### 2. Command API Compliance Audit

**Each command must use API functions instead of direct file access:**

1. **Version access**:
   - ❌ `cat VERSION`
   - ✅ `get_current_version`

2. **Frontmatter reading**:
   - ❌ `grep "^status:" file.md`
   - ✅ `get_frontmatter_field "file.md" "status"`

3. **Epic/task discovery**:
   - ❌ `ls .doh/epics/*/`
   - ✅ `list_epics` or appropriate API function

4. **Registry access**:
   - ❌ Direct JSON parsing of registers.json
   - ✅ Registry API functions

**Commands to audit** (each becomes a subtask):
- `/doh:epic-new`
- `/doh:epic-refresh`
- `/doh:task-new`
- `/doh:task-reopen`
- `/doh:version-status`
- `/doh:version-bump`
- `/doh:version-new`
- `/doh:version-validate`
- `/doh:prd-new`
- `/doh:prd-parse`
- All other commands in `.claude/commands/doh/`

#### 3. Documentation Updates

1. **Update CLAUDE.md**:
   - Explain new library loading patterns
   - Document how to use libraries in commands
   - Provide examples of proper API usage
   - Include troubleshooting guide

2. **Update doh-data-api.md**:
   - Document the refactored library structure
   - Update dependency tree
   - Provide migration guide for existing scripts
   - Include API function reference

3. **Command templates**:
   - Create standard template for new commands
   - Show proper library sourcing
   - Demonstrate API function usage
   - Include error handling patterns

### Non-Functional Requirements

#### Performance
- Library loading time < 50ms
- Source guards prevent redundant loading
- No performance regression in commands
- Lazy loading where appropriate

#### Reliability
- All libraries work in isolation
- No hidden dependencies
- Graceful error messages for missing functions
- Backward compatibility maintained

#### Maintainability
- Clear dependency documentation
- Single source of truth for each function
- Consistent naming conventions
- Automated dependency validation

#### Testing
- Each library has isolation tests
- Commands have API compliance tests
- Integration tests verify end-to-end flows
- Regression tests for refactored functions

## Success Criteria

1. **Library independence**:
   - 100% of libraries can be sourced independently
   - Zero runtime errors from missing dependencies
   - All existing tests pass after refactoring

2. **API compliance**:
   - 100% of commands use API functions
   - No direct file access in command implementations
   - Consistent error handling across commands

3. **Developer experience**:
   - 50% reduction in library loading errors
   - Clear documentation reduces support questions
   - AI agents successfully load libraries first try

4. **Code quality**:
   - Reduced code duplication
   - Clear separation of concerns
   - Improved testability

## Constraints & Assumptions

### Constraints
- Must maintain backward compatibility for external scripts
- Cannot break existing test suite
- Must work with bash 4.0+
- Changes must be incremental and testable

### Assumptions
- Developers will adapt to new patterns
- Source guards are acceptable overhead
- API functions cover all needed operations
- Refactoring can be done incrementally

## Out of Scope

- Complete rewrite of library system
- Migration to different shell or language
- Object-oriented library design
- Dynamic dependency resolution
- Library versioning system
- Performance optimization beyond current needs
- Caching mechanisms
- Async library loading

## Dependencies

### Internal Dependencies
- All DOH libraries need updates
- All DOH commands need auditing
- Test framework for validation
- Documentation system for updates

### External Dependencies
- Bash 4.0+ features
- Standard Unix tools (grep, sed, awk)
- Git for version control

## Implementation Phases

### Phase 1: Core Library Refactoring
1. Create/enhance base library with core functions
2. Rename `_find_doh_root` to `find_doh_root`
3. Add source guards to all libraries
4. Update each library to source dependencies

### Phase 2: Library Dependency Resolution
1. Analyze each library's function usage
2. Add required source statements
3. Test each library in isolation
4. Update integration tests

### Phase 3: Command API Compliance
1. Audit each command for direct file access
2. Create subtasks for non-compliant commands
3. Refactor commands to use API functions
4. Add compliance tests

### Phase 4: Documentation & Training
1. Update CLAUDE.md with new patterns
2. Update doh-data-api.md with changes
3. Create migration guide
4. Add command development templates

### Phase 5: Validation & Rollout
1. Run comprehensive test suite
2. Fix any regressions
3. Update CI/CD pipelines
4. Monitor for issues

## Risk Mitigation

1. **Breaking changes**: Incremental refactoring with tests at each step
2. **Hidden dependencies**: Comprehensive function usage analysis
3. **Performance impact**: Source guards and profiling
4. **Developer resistance**: Clear documentation and benefits
5. **Test failures**: Fix tests alongside refactoring

## Appendix: Command Audit Checklist

### Commands to Audit for API Compliance

Each command becomes a subtask to verify and fix API usage:

- [ ] `/doh:epic-new` - Check VERSION access, frontmatter operations
- [ ] `/doh:epic-refresh` - Check task discovery, status reading
- [ ] `/doh:task-new` - Check numbering, registration, frontmatter
- [ ] `/doh:task-reopen` - Check status updates, frontmatter
- [ ] `/doh:version-status` - Check VERSION file, version directory access
- [ ] `/doh:version-bump` - Check VERSION updates, git operations
- [ ] `/doh:version-new` - Check version file creation
- [ ] `/doh:version-validate` - Check version file parsing
- [ ] `/doh:prd-new` - Check VERSION reading, frontmatter
- [ ] `/doh:prd-parse` - Check PRD parsing, epic creation
- [ ] `/doh:worktree-*` commands - Check git operations
- [ ] `/doh:queue-*` commands - Check queue operations
- [ ] `/doh:epic-status` - Check epic/task discovery
- [ ] `/doh:task-list` - Check task enumeration
- [ ] All other commands in `.claude/commands/doh/`

### API Function Mapping

| Direct Access | API Function | Library |
|--------------|--------------|---------|
| `cat VERSION` | `get_current_version` | version.sh |
| `echo "x.y.z" > VERSION` | `set_current_version` | version.sh |
| `grep "^status:" file` | `get_frontmatter_field file status` | frontmatter.sh |
| `ls .doh/epics/` | `list_epics` | file-cache.sh |
| `find . -name "*.md"` | `find_file_by_number` | file-cache.sh |
| JSON parsing | Registry functions | registers.sh |
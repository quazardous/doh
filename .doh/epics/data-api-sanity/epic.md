---
name: data-api-sanity
number: 024
status: backlog
created: 2025-09-02T07:48:36Z
progress: 0%
prd: .doh/prds/data-api-sanity.md
github: [Will be updated when synced to GitHub]
target_version: 0.7.0
file_version: 0.1.0
---

# Epic: data-api-sanity

## Overview

Establish robust, self-contained DOH Data API libraries by refactoring core dependencies, ensuring proper library sourcing, and converting all commands to use API functions instead of direct file access. This epic addresses the recurring library dependency issues and inconsistent data access patterns that cause runtime errors and maintenance difficulties.

## Architecture Decisions

- **New Core Library**: Create `doh.sh` as the foundational core library
- **Breaking Change**: Move `_find_doh_root` → `find_doh_root` from `dohenv.sh` to `doh.sh`
- **Library Hierarchy**: `doh.sh` (core) → `dohenv.sh` → specialized libraries → commands
- **No-Op Library Pattern**: ALL libraries are no-op when sourced (no automatic execution), callers explicitly invoke functions
- **Function Naming Convention**: Private functions prefixed with `_{lib_name}_`, public API functions prefixed with `{lib_name}_`
- **Library Self-Sufficiency**: Each library explicitly sources its dependencies with source guards
- **API-First Approach**: All commands must use API functions instead of direct file/directory access
- **Incremental Migration**: Maintain backward compatibility while refactoring

## Technical Approach

### Core Library Refactoring
- Create new `doh.sh` as the foundational core library with essential functions
- Move `_find_doh_root` → `doh_find_root` from `dohenv.sh` to `doh.sh`
- Refactor ALL libraries to be no-op when sourced (no automatic execution or side effects)
- Update `dohenv.sh` to source `doh.sh` and provide explicit load functions
- Implement source guards to prevent duplicate loading across all libraries
- Establish clear dependency chain: `doh.sh` → `dohenv.sh` → specialized libraries → commands
- Remove hidden dependencies and make all relationships explicit

### Function Naming Standards
- **Private Functions**: Prefix with `_{lib_name}_` (e.g., `_doh_internal_helper`, `_version_validate_input`)
- **Public API Functions**: Prefix with `{lib_name}_` (e.g., `doh_find_root`, `version_get_current`, `dohenv_load`)
- **Breaking Change**: Rename `_find_doh_root` → `doh_find_root` (becomes public API with library prefix)
- Apply naming convention consistently across all libraries during refactoring

### Library Function Prefixes
- `doh.sh`: `doh_` for public, `_doh_` for private
- `dohenv.sh`: `dohenv_` for public, `_dohenv_` for private  
- `version.sh`: `version_` for public, `_version_` for private
- `frontmatter.sh`: `frontmatter_` for public, `_frontmatter_` for private
- `numbering.sh`: `numbering_` for public, `_numbering_` for private
- `workspace.sh`: `workspace_` for public, `_workspace_` for private
- `registers.sh`: `registers_` for public, `_registers_` for private
- `file-cache.sh`: `cache_` for public, `_cache_` for private
- `graph-cache.sh`: `graph_` for public, `_graph_` for private

### Library Dependency Matrix
```
Library             Must Source
--------           ------------
doh.sh             (none - core library)
dohenv.sh          doh.sh
numbering.sh       doh.sh, dohenv.sh
frontmatter.sh     (none - standalone)
workspace.sh       doh.sh, dohenv.sh
version.sh         doh.sh, dohenv.sh, frontmatter.sh
registers.sh       doh.sh, dohenv.sh, workspace.sh
file-cache.sh      doh.sh, dohenv.sh, workspace.sh, registers.sh
graph-cache.sh     doh.sh, dohenv.sh, workspace.sh, numbering.sh, frontmatter.sh
```

### Command API Compliance
- Replace direct file access (`cat VERSION`) with API functions (`version_get_current`)
- Standardize frontmatter operations through `frontmatter.sh` API (`frontmatter_get_field`)
- Use registry functions instead of direct JSON parsing (`registers_get_entry`)
- Implement consistent error handling patterns across all commands
- Commands must explicitly call initialization functions when needed (no automatic execution from sourcing)
- Follow function naming convention (use public API functions with `{lib_name}_` prefix)

## Implementation Strategy

### Phase 1: Core Foundation (Breaking Changes)
- Create new `doh.sh` core library
- Move `_find_doh_root` → `doh_find_root` from `dohenv.sh` to `doh.sh`
- Refactor ALL libraries to be no-op when sourced (remove any automatic execution)
- Update `dohenv.sh` to source `doh.sh` as dependency and provide explicit initialization functions
- Add source guards to prevent duplicate library loading
- Apply function naming convention (`_{lib_name}_` for private, `{lib_name}_` for public API)
- Update all libraries to source their dependencies explicitly
- Test each library can be sourced independently

### Phase 2: Library Self-Sufficiency
- Analyze function usage across all libraries
- Add required source statements to each library
- Implement isolation tests for each library
- Update integration tests to verify proper dependency resolution

### Phase 3: Command API Migration  
- Audit all DOH commands for direct file access patterns
- Update commands to use explicit initialization function calls when needed
- Create tasks for each non-compliant command
- Refactor commands to use public API functions exclusively (`{lib_name}_` prefix)
- Add API compliance tests for each command

#### Script Refactoring Tasks:
- **Task 041**: Status reporting scripts (status.sh, epic-status.sh, prd-status.sh)
- **Task 042**: List and search scripts (epic-list.sh, prd-list.sh, search.sh) 
- **Task 043**: Task flow scripts (next.sh, in-progress.sh, blocked.sh)
- **Task 044**: Epic management scripts (epic-show.sh, standup.sh)
- **Task 045**: Utility scripts (validate.sh, help.sh, init.sh)
- **Task 046**: Workspace and version scripts (workspace.sh, version-migrate.sh)
- **Task 047**: Create missing libraries (search.sh, workflow.sh, reporting.sh)
- **Task 048**: Create validation and migration libraries (validation.sh, migration.sh)

### Phase 4: Documentation & Tooling
- Update CLAUDE.md with new library loading patterns
- Update docs/doh-data-api.md with refactored architecture
- Create command development templates showing proper API usage
- Add troubleshooting guide for library dependency issues

## Task Breakdown Preview

High-level task categories that will be created:
- [ ] Core Library Foundation: Create `doh.sh`, refactor `dohenv.sh` to pure library, implement naming convention
- [ ] Library Dependency Resolution: Make all libraries self-sufficient
- [ ] Command API Audit: Identify all commands using direct file access
- [ ] Command Migration: Convert commands to use API functions (multiple tasks)
- [ ] Testing & Validation: Ensure all changes work correctly
- [ ] Documentation Updates: Update guides and templates
- [ ] Integration & Rollout: Deploy changes and monitor

## Dependencies

### External Dependencies
- Bash 4.0+ compatibility for source guards and array operations
- Standard Unix tools (grep, sed, awk) for text processing
- Git operations for version control integration

### Internal Dependencies
- Existing DOH library functions must be preserved during refactoring
- Test framework integration for validation
- Command system must remain functional during migration
- Documentation system for updated guides

### Prerequisite Work
- Complete analysis of current library usage patterns
- Identify all functions used across library boundaries
- Map current command file access patterns
- Establish testing baseline before changes

## Success Criteria (Technical)

### Library Independence
- 100% of libraries can be sourced independently without errors
- Zero runtime dependency failures when using individual libraries
- All existing functionality preserved after refactoring
- Source guards prevent performance impact from duplicate loading

### API Compliance
- 100% of DOH commands use API functions instead of direct file access
- Consistent error handling across all command implementations
- No grep/cat/ls operations on DOH files in command code
- All frontmatter operations use `frontmatter.sh` API

### Developer Experience
- Single source command pattern documented and working
- AI agents can reliably load libraries without trial and error
- Clear dependency documentation eliminates guesswork
- 50% reduction in library-related support issues

## Estimated Effort

### Overall Timeline
- Core foundation and breaking changes: 2-3 days
- Library self-sufficiency implementation: 2-3 days  
- Command API audit and migration: 4-6 days (many commands to update)
- Testing, documentation, and integration: 2-3 days
- **Total: 10-15 days** (justified by breaking changes scope)

### Resource Requirements
- Deep understanding of DOH library architecture
- Comprehensive testing across all DOH commands
- Coordination with ongoing development to avoid conflicts

### Critical Path Items
1. Create `doh.sh` core library and move `doh_find_root` function
2. Update `dohenv.sh` to depend on `doh.sh` 
3. Library dependency resolution and testing
4. Command API migration (largest effort)
5. Integration testing and rollout validation
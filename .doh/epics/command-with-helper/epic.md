---
name: command-with-helper
number: 001
status: backlog
created: 2025-09-04T06:17:36Z
progress: 0%
prd: .doh/prds/command-with-helper.md
github: [Will be updated when synced to GitHub]
target_version: 0.6.0
file_version: 0.1.0
---

# Epic: command-with-helper

## Overview
Transform DOH commands into thin orchestration layers by extracting complex logic into reusable helper scripts and leveraging the existing frontmatter library API for all markdown operations. This architectural refactoring will reduce command files to 1-3 lines while improving maintainability and testability.

## Architecture Decisions
- **Helper Bootstrap Pattern**: Use `helper.sh` as central dispatcher to invoke domain-specific helpers
- **Domain Organization**: Group helpers by functional domain (epic, prd, task, version, etc.) in `.claude/scripts/doh/helper/`
- **API-First Approach**: Leverage existing `api.sh` for simple operations, helpers for complex orchestration
- **Incremental Migration**: Refactor commands gradually while maintaining backwards compatibility
- **Test-Per-Helper**: Each helper gets dedicated test coverage using existing test framework

## Technical Approach

### Helper Infrastructure
- Create modular helper scripts that encapsulate complex logic
- Implement helper.sh bootstrap for unified helper invocation
- Organize helpers by domain for intuitive discovery
- Ensure helpers handle validation, error handling, and output formatting

### Command Refactoring Strategy
- Transform commands into simple orchestration layers (1-3 lines)
- Use `helper.sh <domain> <action> [args]` pattern for complex operations
- Use `api.sh <library> <function> [args]` for simple library calls
- Maintain exact command interfaces for backwards compatibility

### Frontmatter Integration
- Replace all manual frontmatter construction with library API calls
- Use `api.sh frontmatter create_markdown` for new file creation
- Use `api.sh frontmatter update_field` for single field modifications
- **NEW: Use domain-specific `*_update()` functions for multi-field updates**
- Leverage validation functions to ensure consistency

### Update Helper Functions (COMPLETED)
- ✅ `epic_update()` - Update multiple epic fields via frontmatter_update_many
- ✅ `prd_update()` - Update multiple PRD fields via frontmatter_update_many
- ✅ `task_update()` - Update multiple task fields via frontmatter_update_many  
- ✅ `version_update()` - Update multiple version fields via frontmatter_update_many
- ✅ All helper wrappers: `helper_epic_update()`, `helper_prd_update()`, etc.

### Usage Patterns (ENFORCE)
```bash
# Library API - For direct file operations
./.claude/scripts/doh/api.sh epic update /path/to/epic.md "status:completed" "progress:100%"
./.claude/scripts/doh/api.sh prd update /path/to/prd.md "status:implemented"

# Helper API - For entity-based operations
./.claude/scripts/doh/helper.sh epic update "epic-name" "status:in_progress" "priority:high"
./.claude/scripts/doh/helper.sh task update "042" "status:completed" "assignee:john"
```

## Implementation Strategy

### Phase 1: Foundation (Tasks 1-3)
- Set up helper infrastructure and bootstrap mechanism
- Create helper conventions and patterns
- Implement first helper as reference implementation

### Phase 2: Core Refactoring (Tasks 4-7)
- Refactor high-impact commands (epic, prd, task creation)
- Extract complex logic to domain helpers
- Replace manual frontmatter with API calls

### Phase 3: Completion (Tasks 8-10)
- Refactor remaining commands
- Add comprehensive test coverage
- Performance validation and optimization

## Task Breakdown Preview

High-level tasks to implement this epic (keeping under 10 total):

- [ ] **Task 1**: Create helper infrastructure and bootstrap mechanism
- [ ] **Task 2**: Implement epic domain helper with create/parse functions
- [ ] **Task 3**: Implement prd domain helper with new/parse functions
- [ ] **Task 4**: Implement task domain helper with decompose/status functions
- [ ] **Task 5**: Implement version domain helper with new/show functions
- [ ] **Task 6**: Refactor all epic-related commands to use helpers
- [ ] **Task 7**: Refactor all prd-related commands to use helpers
- [ ] **Task 8**: Refactor task and version commands to use helpers
- [ ] **Task 9**: Add test coverage for all helpers
- [ ] **Task 10**: Performance validation and documentation

## Dependencies

### Internal Dependencies
- Frontmatter library must be stable and complete
- DOH API system (`api.sh`) must support all required operations
- Test framework must support helper testing patterns
- Existing commands must have clear interfaces to preserve

### External Dependencies
- Claude Code command system for command execution
- Bash 4+ for associative arrays and modern features
- File system permissions for helper script execution

## Success Criteria (Technical)

- **Command Simplification**: All DOH commands reduced to <10 lines (target: 1-3 lines)
- **Helper Coverage**: 100% of complex logic extracted to testable helpers
- **API Adoption**: Zero manual frontmatter construction in codebase
- **Update Function Usage**: All multi-field updates use domain-specific `*_update()` functions
- **Performance**: Helper overhead <100ms per invocation
- **Test Coverage**: Each helper has comprehensive test suite
- **Backwards Compatibility**: All existing command interfaces preserved

## Update Helper Enforcement (CRITICAL)

**MANDATORY USAGE PATTERNS:**

1. **Multi-field Updates**: Always use `frontmatter_update_many()` via domain helpers
   ```bash
   # ✅ CORRECT - Use domain update functions
   epic_update "$epic_path" "status:completed" "progress:100%" "assignee:john"
   task_update "$task_path" "status:in_progress" "priority:high" "due_date:2025-10-01"
   
   # ❌ WRONG - Multiple single-field calls
   frontmatter_update_field "$path" "status" "completed"
   frontmatter_update_field "$path" "progress" "100%"
   ```

2. **Helper Integration**: All complex operations must use helper wrappers
   ```bash  
   # ✅ CORRECT - Use helper for entity-based operations
   helper_epic_update "my-epic" "status:active" "target_version:1.2.0"
   
   # ❌ WRONG - Direct file path manipulation in commands  
   epic_path="$doh_dir/epics/$epic_name/epic.md"
   epic_update "$epic_path" "status:active"
   ```

3. **API Consistency**: Use appropriate API level for the operation
   - **Library API**: When you have the file path and want direct operations
   - **Helper API**: When you have entity names and want business logic

## Estimated Effort

- **Overall Timeline**: 2-3 weeks
- **Development Effort**: 40-60 hours
- **Testing & Validation**: 20 hours
- **Critical Path**: Helper infrastructure setup (Task 1) blocks all other work
- **Parallelizable Work**: Domain helpers (Tasks 2-5) can be developed concurrently

## Tasks Created
- [ ] 002.md - Create helper infrastructure and bootstrap mechanism (parallel: false)
- [ ] 003.md - Implement epic domain helper with create/parse functions (parallel: true)
- [ ] 007.md - Implement prd domain helper with new/parse functions (parallel: true)
- [ ] 009.md - Implement task domain helper with decompose/status functions (parallel: true)
- [ ] 010.md - Implement version domain helper with new/show functions (parallel: true)
- [ ] 011.md - Add test coverage for all helpers (parallel: true)
- [ ] 012.md - Performance validation and documentation (parallel: false)
- [ ] 013.md - Refactor all epic-related commands to use helpers (parallel: false)
- [ ] 014.md - Refactor all prd-related commands to use helpers (parallel: false)
- [ ] 015.md - Refactor task and version commands to use helpers (parallel: false)

Total tasks: 10
Parallel tasks: 5
Sequential tasks: 5
Estimated total effort: 50-60 hours
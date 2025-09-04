---
name: command-with-helper
description: Refactor DOH commands to use modular helper scripts and frontmatter library for cleaner architecture
status: backlog
created: 2025-09-04T06:14:52Z
target_version: 0.6.0
file_version: 0.1.0
---

# PRD: command-with-helper

## Executive Summary

This feature introduces a new architectural pattern for DOH commands that separates command logic from implementation details. Commands will become thin orchestration layers (1-3 lines) that delegate complex operations to modular helper scripts and utilize the frontmatter library API for markdown file creation. This approach will dramatically improve maintainability, testability, and code reuse across the DOH command ecosystem.

## Problem Statement

Current DOH commands contain large bash scripts embedded directly in command files, creating several problems:
- Commands are difficult to maintain with logic mixed with orchestration
- Code duplication across commands that perform similar operations
- Testing individual components is challenging
- Frontmatter creation is manually scripted instead of using the existing library
- Commands become unreadable with complex bash logic inline

This architectural debt slows development and increases the risk of bugs when modifying commands.

## User Stories

### Developer Creating New Commands
**As a** DOH developer  
**I want to** create commands that delegate to helpers  
**So that** my commands are concise and maintainable  
**Acceptance Criteria:**
- Command file contains only orchestration logic (1-3 lines)
- Complex logic lives in testable helper scripts
- Frontmatter creation uses the library API

### Developer Maintaining Existing Commands
**As a** DOH developer  
**I want to** refactor existing commands to use helpers  
**So that** the codebase becomes more maintainable  
**Acceptance Criteria:**
- Identify commands with embedded bash scripts
- Extract logic to appropriate helper scripts
- Preserve backwards compatibility

### Developer Using Helper Scripts
**As a** DOH developer  
**I want to** easily find and use helper scripts  
**So that** I can avoid code duplication  
**Acceptance Criteria:**
- Helpers are organized by domain in `.claude/scripts/doh/helper/`
- Helper discovery through directory structure
- Clear naming conventions for helpers

## Requirements

### Functional Requirements

**Command Architecture**
- Commands must be thin orchestration layers (1-3 lines typical)
- Commands call helpers via `helper.sh` bootstrap
- Simple operations may use `api.sh` directly when appropriate
- Commands must maintain backwards compatibility

**Helper Script Organization**
- Helpers live in `.claude/scripts/doh/helper/` organized by domain
- Helper bootstrap script (`helper.sh`) manages execution
- Helpers can be shared across multiple commands
- Helpers handle complex logic, validation, and error handling

**Frontmatter Library Integration**
- All markdown file creation uses frontmatter library API
- No manual frontmatter construction in commands or helpers
- Validation through library functions
- Consistent frontmatter format across all file types

**Migration Process**
- Analyze existing commands for refactoring candidates
- Create migration tasks for each command
- Prioritize commands with largest embedded scripts
- Preserve existing command interfaces

### Non-Functional Requirements

**Performance**
- Helper execution overhead must be minimal (<100ms)
- Library API calls should be efficient
- No performance regression from current implementation

**Maintainability**
- Clear separation of concerns
- Testable helper components
- Reduced code duplication by >50%

**Developer Experience**
- Intuitive helper organization by domain
- Self-documenting command structure
- Easy helper discovery and reuse

## Success Criteria

- **Code Reduction**: Command files reduced to <10 lines average
- **Helper Adoption**: 100% of DOH commands use helper pattern
- **Library Usage**: All frontmatter creation uses library API
- **Test Coverage**: Helpers have dedicated test coverage
- **Developer Satisfaction**: Reduced time to implement new commands by 40%
- **Bug Reduction**: 30% fewer bugs in command logic

## Constraints & Assumptions

### Constraints
- Must maintain backwards compatibility with existing command interfaces
- Cannot break existing workflows or integrations
- Must work within current DOH architecture
- Performance must not degrade

### Assumptions
- Developers will adopt the helper pattern for new commands
- Existing frontmatter library is stable and complete
- Helper bootstrap mechanism can handle all use cases
- Testing framework supports helper script testing

## Out of Scope

- Changing the `/doh:` command prefix structure
- Modifying the underlying Claude Code command system
- Creating a new command framework from scratch
- Automating the entire migration (manual analysis required)
- Changing command naming conventions
- Non-DOH commands

## Dependencies

### Internal Dependencies
- Frontmatter library (`lib/frontmatter.sh`)
- DOH API system (`api.sh`)
- Helper bootstrap script (`helper.sh`)
- Test framework for helper testing

### External Dependencies
- Claude Code command system
- Bash shell environment
- File system access for helper scripts

## Implementation Tasks

Based on analysis of existing commands, the following refactoring tasks should be created:

1. **Infrastructure Setup**
   - Create helper directory structure
   - Implement helper.sh bootstrap if not exists
   - Document helper conventions

2. **High-Priority Command Refactoring** (largest scripts)
   - Epic creation commands
   - PRD parsing commands
   - Version management commands
   - Task generation commands

3. **Medium-Priority Command Refactoring**
   - Status and listing commands
   - Query and search commands
   - Update and modification commands

4. **Low-Priority Command Refactoring**
   - Simple wrapper commands
   - Display-only commands

5. **Validation & Testing**
   - Create helper test suite
   - Validate all refactored commands
   - Performance benchmarking

## Risk Mitigation

- **Risk**: Breaking existing workflows
  - **Mitigation**: Comprehensive testing, gradual rollout, backwards compatibility

- **Risk**: Developer resistance to new pattern
  - **Mitigation**: Clear documentation, demonstrate benefits, provide templates

- **Risk**: Performance degradation from indirection
  - **Mitigation**: Benchmark before/after, optimize helper bootstrap

- **Risk**: Helper sprawl and disorganization
  - **Mitigation**: Clear domain organization, naming conventions, regular audits
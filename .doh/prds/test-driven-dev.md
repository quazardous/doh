---
name: test-driven-dev
description: Establish TDD patterns and test organization for the DOH development project
status: backlog
created: 2025-09-01T07:21:16Z
file_version: 0.1.0
---

# PRD: test-driven-dev

## Executive Summary

Implement a comprehensive Test-Driven Development (TDD) pattern for the DOH project, establishing clear separation between runtime code and tests, creating reusable TDD rules documentation, and selecting an appropriate test framework. This initiative addresses the current anti-pattern of tests residing in `.claude/scripts/doh/tests` (runtime area) by establishing `./tests` as the dedicated test directory, while providing clear documentation for both DOH-specific testing and general TDD patterns reusable across projects.

## Problem Statement

Currently, the DOH project lacks a formal TDD structure and pattern documentation:

1. **Improper Test Location**: Tests are being placed in `.claude/scripts/doh/tests`, which is within the runtime execution area, violating separation of concerns
2. **No TDD Guidelines**: Lack of documented TDD patterns leads to inconsistent test creation and coverage
3. **Missing Test Framework**: No standardized test framework for bash-based testing in DOH
4. **Documentation Gap**: No clear documentation explaining how to write, organize, and run tests
5. **Reusability Issue**: No drop-in TDD rules that other projects using Claude can adopt

This creates maintenance issues, makes tests harder to discover, and prevents establishing a culture of test-first development in the DOH project.

## User Stories

### DOH Developer Story
**As a** DOH project developer  
**I want** clear TDD patterns and proper test organization  
**So that** I can write tests before implementing features and maintain high code quality

**Acceptance Criteria:**
- Tests are organized in `./tests` directory, not in runtime areas
- Clear documentation explains where to place different types of tests
- Test framework is easy to use for bash script testing
- Tests can be run with a simple command

### Claude AI Agent Story
**As a** Claude AI agent working on DOH  
**I want** explicit TDD rules and patterns  
**So that** I automatically create tests in the correct location and follow TDD practices

**Acceptance Criteria:**
- `.claude/rules/tdd.md` provides clear, unambiguous TDD rules
- Documentation is referenced in CLAUDE.md for automatic discovery
- Test creation patterns are well-defined
- Test file naming conventions are specified

### Project Adopter Story
**As a** developer adopting DOH patterns in another project  
**I want** reusable TDD documentation  
**So that** I can drop the TDD rules into my own `.claude/rules` directory

**Acceptance Criteria:**
- `./rules/tdd.md` is self-contained and project-agnostic
- Documentation works as a drop-in file for other projects
- Patterns are general enough to apply beyond DOH

## Requirements

### Functional Requirements

#### FR1: Test Directory Structure
- Create `./tests` as the root test directory
- Establish subdirectory structure mirroring source code organization:
  - `./tests/unit/` - Unit tests for individual functions
  - `./tests/integration/` - Integration tests for command workflows
  - `./tests/fixtures/` - Test data and mock files
  - `./tests/helpers/` - Shared test utilities

#### FR2: TDD Rules Documentation (`./rules/tdd.md`)
- Document universal TDD patterns applicable to any project
- Include sections on:
  - Test-first development workflow
  - Test file naming conventions (`test_*.sh` or `*_test.sh`)
  - Test organization principles
  - Red-Green-Refactor cycle
  - Test coverage expectations
- Make it drop-in ready for `.claude/rules/` in any project

#### FR3: DOH-Specific Test Documentation (`./docs/doh-tdd.md`)
- Document DOH project-specific testing requirements
- Reference (not duplicate) `./rules/tdd.md` for general patterns
- Include:
  - DOH test directory structure
  - How to test DOH commands and scripts
  - Test data management for DOH entities (PRDs, epics, tasks)
  - Integration with DOH's bash-based architecture
  - Specific test framework choice and justification

#### FR4: Test Framework Selection
- Evaluate and select appropriate bash test framework:
  - **Option 1: Bats (Bash Automated Testing System)**
    - Pros: TAP-compliant, widely adopted, good assertions
    - Cons: External dependency
  - **Option 2: shUnit2**
    - Pros: Pure bash, xUnit-style, familiar API
    - Cons: Less modern
  - **Option 3: Custom lightweight framework**
    - Pros: No dependencies, tailored to DOH needs
    - Cons: Maintenance burden
- Document installation and usage in `./docs/doh-tdd.md`

#### FR5: DEVELOPMENT.md Integration
- Add TDD section to DEVELOPMENT.md
- Reference `./docs/doh-tdd.md` for detailed testing information
- Ensure CLAUDE.md can discover testing documentation

#### FR6: Test Execution Commands
- Create `./tests/run.sh` as the main test runner
- Support running all tests or specific test suites
- Provide clear output with pass/fail indicators
- Generate coverage reports where applicable

### Non-Functional Requirements

#### NFR1: Performance
- Test suite should complete in under 30 seconds for rapid feedback
- Individual unit tests should run in under 1 second
- Support parallel test execution where possible

#### NFR2: Maintainability
- Tests should be as readable as documentation
- Clear naming conventions for immediate understanding
- Minimal boilerplate code required for new tests

#### NFR3: Compatibility
- Test framework must work on Linux and macOS
- Should not require elevated privileges
- Must work with bash 4.0+

#### NFR4: Documentation Quality
- Documentation must be clear enough for AI agents to follow
- Examples should be provided for common test scenarios
- Anti-patterns should be explicitly called out

## Success Criteria

1. **Test Migration**: All existing tests moved from `.claude/scripts/doh/tests` to `./tests`
2. **Documentation Completeness**: 
   - `./rules/tdd.md` created and validates as drop-in ready
   - `./docs/doh-tdd.md` created with DOH-specific guidance
   - DEVELOPMENT.md updated with testing section
3. **Framework Adoption**: Selected test framework installed and functional
4. **Test Coverage**: Achieve 70% code coverage for critical DOH commands
5. **Reproducibility**: Any developer can run `./tests/run.sh` successfully
6. **AI Compliance**: Claude agents automatically create tests in correct location

## Constraints & Assumptions

### Constraints
- Must maintain backward compatibility with existing DOH functionality
- Cannot introduce heavy dependencies that complicate DOH installation
- Must work within existing DOH bash-based architecture
- Documentation must be Markdown-based for consistency

### Assumptions
- Developers are familiar with basic TDD concepts
- Bash 4.0+ is available in target environments
- Git is being used for version control
- Tests will primarily be testing bash scripts and commands

## Out of Scope

- Testing for external projects using DOH (they have their own test strategies)
- GUI or web-based test runners
- Performance benchmarking framework
- Continuous Integration (CI) pipeline setup
- Test database or infrastructure provisioning
- Testing of non-bash components
- Retroactively adding tests for all existing DOH functionality (focus on new development)

## Dependencies

### External Dependencies
- Selected test framework (Bats, shUnit2, or none if custom)
- Bash 4.0+ for test execution
- Basic Unix utilities (grep, sed, awk)

### Internal Dependencies
- Existing DOH command structure must be test-friendly
- DEVELOPMENT.md must exist for documentation integration
- CLAUDE.md must be updated to reference test documentation
- `.claude/rules/` directory structure for rules documentation

## Implementation Phases

### Phase 1: Documentation and Structure (Day 1)
1. Create `./rules/tdd.md` with universal TDD patterns
2. Create `./docs/doh-tdd.md` with DOH-specific guidance
3. Update DEVELOPMENT.md with testing section
4. Create `./tests` directory structure

### Phase 2: Framework Selection and Setup (Day 1-2)
1. Evaluate test framework options
2. Implement chosen framework
3. Create `./tests/run.sh` runner script
4. Write example tests demonstrating patterns

### Phase 3: Migration and Validation (Day 2)
1. Migrate existing tests from `.claude/scripts/doh/tests`
2. Validate all tests pass in new location
3. Update any references to old test location
4. Create test templates for common scenarios

## Risk Mitigation

- **Risk**: Developers ignore TDD patterns
  - **Mitigation**: Make tests required for PR approval, provide clear benefits documentation
  
- **Risk**: Test framework adds complexity
  - **Mitigation**: Choose lightweight option, provide clear examples
  
- **Risk**: Tests become flaky or slow
  - **Mitigation**: Establish test quality guidelines, timeout limits

## Success Metrics

- Time to write first test reduced by 50%
- Test location errors eliminated (0 tests in runtime area)
- 100% of new features have accompanying tests
- Documentation reused by at least 1 other project
- All Claude-generated code includes appropriate tests
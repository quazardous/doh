---
name: test-driven-dev
number: 014
status: backlog
created: 2025-09-01T07:25:13Z
progress: 0%
prd: .doh/prds/test-driven-dev.md
github: [Will be updated when synced to GitHub]
target_version: 1.0.0
file_version: 0.1.0
---

# Epic: test-driven-dev

## Overview

Establish comprehensive TDD patterns for the DOH project by creating reusable documentation, migrating tests to proper locations, and implementing a lightweight test framework. This implementation focuses on simplicity and leveraging existing DOH patterns while establishing clear separation between runtime code and tests.

## Architecture Decisions

- **Custom Lightweight Test Framework**: Build a minimal bash test framework tailored to DOH needs rather than introducing external dependencies (Bats/shUnit2), keeping the project self-contained
- **Documentation-First Approach**: Create drop-in rule files that work for both DOH and other projects using Claude
- **Leverage Existing Patterns**: Use DOH's existing file structure patterns for test organization
- **Progressive Migration**: Move existing tests incrementally to avoid disruption
- **Simple Test Runner**: Create a straightforward `./tests/run.sh` that follows DOH command patterns

## Technical Approach

### Documentation Components
- **Generic TDD Rules** (`./rules/tdd.md`): Project-agnostic TDD patterns for any Claude project
- **DOH-Specific Guide** (`./docs/doh-tdd.md`): References generic rules, adds DOH context
- **Integration Points**: Update DEVELOPMENT.md to reference test documentation

### Test Infrastructure
- **Directory Structure**: Mirror source layout under `./tests/` with unit/integration/fixtures/helpers subdirectories
- **Test Framework**: Custom lightweight bash framework with simple assertions and TAP-like output
- **Test Runner**: Single entry point script with suite selection and parallel execution support

### Migration Strategy
- **Inventory Existing Tests**: Identify all tests in `.claude/scripts/doh/tests`
- **Gradual Migration**: Move tests one suite at a time to `./tests`
- **Update References**: Fix any hardcoded paths pointing to old test location

## Implementation Strategy

### Development Phases
1. **Documentation Creation**: Write TDD rules and DOH-specific testing guide
2. **Framework Implementation**: Build minimal test framework with essential assertions
3. **Infrastructure Setup**: Create test directory structure and runner script
4. **Test Migration**: Move existing tests to new location
5. **Integration**: Update DEVELOPMENT.md and CLAUDE.md references

### Risk Mitigation
- Keep framework minimal to avoid maintenance burden
- Provide clear migration path for existing tests
- Include extensive examples in documentation
- Test the test framework itself

### Testing Approach
- Self-testing: Test framework tests itself
- Example tests demonstrate all assertion types
- Integration tests verify runner functionality

## Task Breakdown Preview

Simplified task structure focusing on essential deliverables:

- [ ] **Task 1**: Create TDD rules documentation (`./rules/tdd.md` and `./docs/doh-tdd.md`)
- [ ] **Task 2**: Build minimal test framework with basic assertions
- [ ] **Task 3**: Create test runner script and directory structure
- [ ] **Task 4**: Migrate existing tests from runtime area
- [ ] **Task 5**: Update DEVELOPMENT.md and CLAUDE.md with test references
- [ ] **Task 6**: Write example tests demonstrating patterns

## Dependencies

### Internal Dependencies
- Existing DOH file structure patterns
- DEVELOPMENT.md for documentation integration
- CLAUDE.md for AI agent discovery
- `.claude/rules/` directory for rule files

### External Dependencies
- Bash 4.0+ (already required by DOH)
- Standard Unix utilities (grep, sed, awk)
- No additional framework dependencies

## Success Criteria (Technical)

1. **Documentation Quality**: Rules clear enough for AI agents to follow automatically
2. **Framework Simplicity**: < 200 lines of code for core test framework
3. **Performance**: Full test suite runs in < 10 seconds
4. **Migration Success**: All existing tests work in new location
5. **Zero Dependencies**: No external test framework requirements

## Estimated Effort

- **Overall timeline**: 1-2 days
- **Critical path**: Test framework implementation and migration
- **Total tasks**: 6 focused tasks
- **Complexity**: Low-Medium (leveraging existing patterns)

## Tasks Created
- [x] 015.md - Create TDD rules documentation (parallel: false) - COMPLETED
- [x] 016.md - Build minimal test framework (parallel: false) - COMPLETED
- [x] 017.md - Create test runner and directory structure (parallel: false) - COMPLETED
- [ ] 018.md - Migrate existing tests from runtime area (parallel: false)
- [ ] 019.md - Update DEVELOPMENT.md and CLAUDE.md with test references (parallel: false)
- [ ] 020.md - Write example tests demonstrating patterns (parallel: false)
- [x] 021.md - Amend doh-tdd.md for test-inspired development approach (parallel: false) - COMPLETED

Total tasks: 7
Parallel tasks: 0
Sequential tasks: 7
Estimated total effort: 13 hours
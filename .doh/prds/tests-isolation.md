---
name: tests-isolation
description: Comprehensive test isolation system ensuring all tests are no-op on current project data
status: backlog
created: 2025-09-02T15:41:30Z
target_version: 0.6.0
file_version: 0.1.0
---

# PRD: tests-isolation

## Executive Summary

Create a comprehensive test isolation system for DOH that ensures all tests are completely no-op on current project data. Tests currently pollute the actual `~/.doh` workspace with registry entries, cache files, and other artifacts, making the test suite unreliable and potentially destructive to developer workflows.

## Problem Statement

**What problem are we solving?**
- Tests are writing to the real DOH project registry (`~/.doh/projects/doh_*/registers.json`)
- Test artifacts persist after test completion, polluting development workspace
- Tests can interfere with each other due to shared state
- Developers risk corrupting their actual project data when running tests
- Test failures often mask real issues due to pre-existing test pollution

**Why is this important now?**
Current test suite shows 9/16 tests failing due to registry pollution with 200+ duplicate test entries. This makes the test suite unreliable and blocks development confidence.

## User Stories

### Primary Persona: DOH Developer

**Story 1: Safe Test Execution**
- As a DOH developer
- I want to run the test suite without fear of corrupting my project data
- So that I can confidently validate changes without backup/restore procedures

**Story 2: Clean Test Environment**
- As a DOH developer  
- I want each test to start with a clean, isolated environment
- So that test results are deterministic and not influenced by previous test runs

**Story 3: Parallel Test Development**
- As a DOH developer
- I want to write new tests without researching existing test state
- So that I can focus on test logic rather than environment setup

## Requirements

### Functional Requirements

**FR1: Universal Library Isolation**
- All DOH libraries must support environment variable overrides for data paths
- Libraries must gracefully fallback to default behavior when overrides not set
- Environment variables must follow consistent naming convention

**FR2: Test Framework Integration**
- Test framework must automatically set up isolation for all tests
- Isolation setup/teardown must be transparent to test authors
- Failed tests must not leave artifacts in isolated environments

**FR3: Research-Driven Implementation**
- Systematic audit of all DOH libraries to identify isolation points
- Documentation of environment variable override patterns
- Validation that all data-writing operations are covered

### Non-Functional Requirements

**NFR1: Zero Performance Impact**
- Environment variable checks must have negligible runtime cost
- Test isolation setup must complete in <100ms per test

**NFR2: Backward Compatibility**
- Existing tests must work without modification
- Production DOH behavior unchanged when isolation disabled
- No breaking changes to public library APIs

**NFR3: Developer Experience**
- Test authors should not need to understand isolation internals
- Clear error messages when isolation fails
- Easy debugging of test isolation issues

## Success Criteria

- [ ] 100% of tests run without writing to actual project registry
- [ ] Test suite passes consistently with clean state each run
- [ ] Zero test artifacts remain after test completion
- [ ] No performance degradation in production DOH usage
- [ ] All existing tests pass without modification

**Key Metrics:**
- Test suite reliability: Target 100% pass rate with clean environment
- Test execution time: No more than 10% increase due to isolation
- Developer confidence: Measured by adoption of test-driven development

## Implementation Strategy

### Phase 1: Research & Discovery
Create comprehensive audit of isolation requirements:

**Task: Research Candidate Functions and Variables**
- Audit all DOH libraries in `.claude/scripts/doh/lib/`
- Identify every function that reads/writes project data
- Document current data paths and file operations
- Map environment variable override points
- Analyze function naming inconsistencies
- Create isolation specification document

**Deliverables:**
- Complete inventory of data-writing functions ✅
- Environment variable naming convention ✅
- Function standardization requirements
- Risk assessment of isolation implementation

## Isolation Candidate Variables (Initial Audit)

### Primary Candidates:
1. **`DOH_GLOBAL_DIR`** - Root DOH directory (already exists, needs test override)
2. **`DOH_WORKSPACE_PROJECT_ID`** - Override project ID calculation for predictable test paths
3. **`DOH_NUMBERING_REGISTRY_DIR`** - Registry JSON files (`registers.json`, `TASKSEQ`)
4. **`DOH_FILE_CACHE_DIR`** - CSV file cache (`file_cache.csv`)
5. **`DOH_GRAPH_CACHE_DIR`** - JSON relationship cache (`graph_cache.json`) 
6. **`DOH_MESSAGE_QUEUE_DIR`** - Message queue files (`queues/$queue_name/`)

### Library Analysis:
- **workspace.sh**: Project directories, state files, locks, mapping registry
- **numbering.sh**: Registry JSON, sequence files → `~/.doh/projects/$project_id/`
- **file-cache.sh**: CSV cache → `~/.doh/projects/$project_id/file_cache.csv`
- **graph-cache.sh**: JSON cache → `~/.doh/projects/$project_id/graph_cache.json`
- **message-queue.sh**: Queue directories → `~/.doh/projects/$project_id/queues/`

### Optimization Insight:
Most libraries use pattern: `$HOME/.doh/projects/$project_id/filename`
**Simple approach**: Override `DOH_GLOBAL_DIR` + `DOH_WORKSPACE_PROJECT_ID` achieves 90% isolation.

### Phase 2: Library Enhancement
- Implement environment variable overrides in all libraries
- Standardize function naming (`workspace_get_current_project_id` pattern)
- Add library documentation for override variables

### Phase 3: Test Framework Integration
- Add automatic isolation setup/teardown to test framework
- Create isolated temporary directories for each test run
- Implement cleanup procedures with error handling

### Phase 4: Validation & Documentation
- Validate all tests run in isolation
- Create developer documentation for test isolation
- Performance testing and optimization

## Constraints & Assumptions

**Technical Constraints:**
- Must maintain bash compatibility across platforms
- Environment variable approach required (no config file dependencies)
- Cannot break existing production deployments

**Timeline Constraints:**
- Research phase should complete before implementation begins
- Full implementation needed for reliable development workflow

**Resource Constraints:**
- Single developer implementation
- Must not disrupt ongoing DOH development

## Out of Scope

- Performance optimization of test suite execution time
- Test parallelization capabilities  
- Integration with external CI systems
- Mocking of external dependencies beyond file system

## Dependencies

**Internal Dependencies:**
- All DOH libraries must be modified systematically
- Test framework requires enhancement for automatic isolation
- Function naming standardization across libraries

**External Dependencies:**
- Bash environment variable support
- Temporary directory creation capabilities (`mktemp`)
- File system permissions for test artifact cleanup

## Risk Analysis

**High Risk:**
- Incomplete isolation could still pollute project data
- Environment variable conflicts with existing tooling

**Medium Risk:**
- Performance impact from environment variable checks
- Complex cleanup logic in test framework

**Mitigation:**
- Comprehensive testing of isolation in development environment
- Staged rollout with validation at each step
- Fallback to current behavior if isolation fails

## Next Steps

1. **Immediate:** Begin research task to audit all DOH libraries
2. **Research Phase:** Create comprehensive isolation specification
3. **Implementation:** Systematic library updates with testing
4. **Validation:** Full test suite execution with isolation enabled

Ready to create implementation epic? Run: `/doh:prd-parse tests-isolation`
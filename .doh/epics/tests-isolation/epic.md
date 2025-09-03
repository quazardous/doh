---
name: tests-isolation
description: Comprehensive test isolation system ensuring all tests are no-op on current project data
status: backlog
created: 2025-09-02T15:53:24Z
target_version: 0.6.0
file_version: 0.1.0
prd: tests-isolation
---

# Epic: tests-isolation

Implement comprehensive test isolation system for DOH ensuring all tests are completely no-op on current project data.

## Problem Summary
Tests currently pollute the actual `~/.doh` workspace with registry entries, cache files, and artifacts, making the test suite unreliable and potentially destructive. Current test suite shows 9/16 tests failing due to registry pollution.

## Solution Overview
Use `DOH_GLOBAL_DIR="$(mktemp -d)"` to redirect all DOH data operations to secure temporary directories that are automatically cleaned up after tests complete.

## Key Requirements
- All tests must be no-op on current project data
- Zero performance impact on production DOH usage
- Backward compatibility with existing tests
- Automatic cleanup of test artifacts

## Implementation Strategy

### Phase 1: Research & Validation
- Verify `DOH_GLOBAL_DIR` usage consistency across all DOH libraries
- Identify any hardcoded paths that bypass `DOH_GLOBAL_DIR`
- Test isolation approach with sample tests

### Phase 2: Library Enhancement
- Fix function naming inconsistencies (`workspace_get_current_project_id` pattern)
- Add `DOH_WORKSPACE_PROJECT_ID` override for special cases
- Document environment variable usage in libraries

### Phase 3: Test Framework Integration
- Add automatic isolation setup: `DOH_GLOBAL_DIR="$(mktemp -d)"`
- Implement cleanup procedures with error handling
- Ensure transparent operation for test authors

### Phase 4: Validation
- Validate all tests run in complete isolation
- Performance testing to ensure no degradation
- Clean up existing test pollution in development environments

## Success Criteria
- [ ] 100% of tests run without writing to actual project registry
- [ ] Test suite passes consistently with clean state each run
- [ ] Zero test artifacts remain after test completion
- [ ] All existing tests pass without modification

## Linked PRD
See comprehensive requirements in: `.doh/prds/tests-isolation.md`
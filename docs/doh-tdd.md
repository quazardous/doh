# DOH Test-Inspired Development Guide
<!-- File version: 0.2.0 | Created: 2025-09-01 (Task 015) | Updated: 2025-09-01 (Task 021) -->

## Overview

This guide provides DOH-specific testing patterns and practices using a pragmatic "test-inspired" approach. While traditional TDD requires writing tests first, DOH development acknowledges that for bash scripting and exploratory coding, tests can be written during or after implementation while still maintaining high code quality and coverage.

For general TDD principles (which can be adapted for test-inspired workflows), see [../rules/tdd.md](../rules/tdd.md).

## Test-Inspired Development Philosophy

DOH embraces a flexible testing approach:

- **Exploratory Phase**: Write code to explore solutions and understand requirements
- **Stabilization Phase**: Add tests to solidify behavior and prevent regressions  
- **Enhancement Phase**: Use test-first approach for new features in stable code
- **Always**: Maintain good test coverage regardless of when tests are written

This approach recognizes that bash scripts often involve:
- File system operations that are easier to test after seeing actual behavior
- Command-line interactions that benefit from prototyping
- Integration with external tools that require experimentation

## Test-Inspired Workflows

### Workflow 1: Explore-Then-Test (Recommended for New Features)
1. **Prototype**: Write initial implementation to understand the problem
2. **Experiment**: Test manually and refine the approach
3. **Solidify**: Add comprehensive tests based on discovered behavior
4. **Refactor**: Clean up implementation with tests as safety net

### Workflow 2: Test-First (For Well-Understood Features)
1. **Specify**: Write tests that define expected behavior
2. **Implement**: Write minimal code to pass tests
3. **Refactor**: Improve implementation while keeping tests green

### Workflow 3: Retroactive Testing (For Existing Code)
1. **Analyze**: Understand current behavior through exploration
2. **Document**: Write tests that capture existing behavior
3. **Refactor**: Improve code with test coverage in place
4. **Extend**: Add new features using test-first approach

### When to Use Each Workflow
- **Explore-Then-Test**: New DOH commands, complex bash operations, file system interactions
- **Test-First**: Bug fixes, well-defined utility functions, API integrations
- **Retroactive**: Legacy code improvement, documentation of existing behavior

## Practical Test-Inspired Examples

### Example 1: New DOH Command (Explore-Then-Test)

```bash
# 1. PROTOTYPE: Start with basic implementation
create_epic_command() {
    local epic_name="$1"
    mkdir -p ".doh/epics/$epic_name"
    echo "---" > ".doh/epics/$epic_name/epic.md"
    echo "name: $epic_name" >> ".doh/epics/$epic_name/epic.md"
    echo "---" >> ".doh/epics/$epic_name/epic.md"
}

# 2. EXPERIMENT: Test manually, discover edge cases
# $ create_epic_command "test-feature"  # Works
# $ create_epic_command ""              # Should fail but doesn't
# $ create_epic_command "UPPER"         # Should normalize to lowercase

# 3. SOLIDIFY: Add tests based on discovered behavior
test_create_epic_validates_name() {
    assert_command_fails create_epic_command ""
    assert_command_fails create_epic_command "invalid name with spaces"
}

test_create_epic_normalizes_name() {
    create_epic_command "UPPER-Case"
    assert_file_contains ".doh/epics/upper-case/epic.md" "name: upper-case"
}
```

### Example 2: Bug Fix (Test-First)

```bash
# 1. SPECIFY: Write test that reproduces the bug
test_task_numbering_handles_gaps() {
    # Setup: Create tasks 001, 002, 004 (missing 003)
    register_task "001" "epic1" "path1" "task1" "epic"
    register_task "002" "epic1" "path2" "task2" "epic"  
    register_task "004" "epic1" "path4" "task4" "epic"
    
    # Act: Get next number
    local next=$(get_next_number "task")
    
    # Assert: Should be 005, not 003
    assert_equals "005" "$next" "Should skip gaps and continue sequence"
}

# 2. IMPLEMENT: Fix the numbering function
# 3. REFACTOR: Clean up implementation
```

### Example 3: Legacy Code (Retroactive Testing)

```bash
# Existing function without tests:
update_frontmatter() {
    local file="$1" key="$2" value="$3"
    sed -i "s/^$key: .*/$key: $value/" "$file"
}

# Add tests to document current behavior:
test_update_frontmatter_existing_key() {
    echo -e "---\nstatus: open\n---" > test.md
    update_frontmatter "test.md" "status" "closed"
    assert_file_contains "test.md" "status: closed"
}

test_update_frontmatter_missing_key() {
    echo -e "---\nother: value\n---" > test.md
    update_frontmatter "test.md" "status" "open"
    # Document current behavior: sed adds line even if key doesn't exist
    assert_file_contains "test.md" "status: open"
}
```

## DOH Test Framework

DOH uses a custom lightweight bash test framework designed specifically for testing bash scripts and command-line tools.

### Framework Location
- **Core Framework**: `./tests/helpers/test_framework.sh`
- **Test Runner**: `./tests/run.sh`
- **Test Suites**: `./tests/unit/` and `./tests/integration/`

## Testing DOH Components

### Testing DOH Commands

DOH commands (`/doh:*`) require special testing approaches:

```bash
# Example: Testing /doh:epic-new command
test_epic_new_creates_epic_file() {
    # Arrange: Set up test environment
    local test_dir=$(mktemp -d)
    cd "$test_dir"
    init_test_doh_project
    
    # Act: Run the command
    run_doh_command "epic-new" "test-feature"
    
    # Assert: Verify epic was created
    assert_file_exists ".doh/epics/test-feature/epic.md"
    assert_file_contains ".doh/epics/test-feature/epic.md" "name: test-feature"
    
    # Cleanup
    cd - && rm -rf "$test_dir"
}
```

### Testing Library Functions

DOH libraries in `.claude/scripts/doh/lib/` need thorough unit testing:

```bash
# Example: Testing numbering.sh functions
test_get_next_number_increments() {
    # Arrange
    source_lib "numbering.sh"
    local initial=$(get_current_number "task")
    
    # Act
    local next=$(get_next_number "task")
    
    # Assert
    assert_equals "$((initial + 1))" "$next"
}
```

### Testing File Operations

Many DOH operations involve file manipulation:

```bash
test_frontmatter_update() {
    # Arrange: Create test file with frontmatter
    local test_file=$(create_temp_file)
    cat > "$test_file" <<EOF
---
status: open
created: 2025-01-01T00:00:00Z
---
# Content
EOF
    
    # Act: Update frontmatter
    update_frontmatter "$test_file" "status" "closed"
    
    # Assert: Verify update
    assert_file_contains "$test_file" "status: closed"
    assert_file_contains "$test_file" "# Content"  # Content preserved
}
```

## DOH-Specific Test Patterns

### Workspace Testing

Testing workspace-aware operations:

```bash
test_workspace_detection() {
    # Test main branch mode
    setup_main_branch_test
    assert_equals "branch" "$(get_workspace_mode)"
    
    # Test worktree mode
    setup_worktree_test "feature-branch"
    assert_equals "worktree" "$(get_workspace_mode)"
}
```

### Epic and Task Testing

Testing epic/task lifecycle:

```bash
test_epic_task_dependency_chain() {
    # Create epic with tasks
    create_test_epic "test-epic"
    create_test_task "test-epic" "001" "depends_on: []"
    create_test_task "test-epic" "002" "depends_on: [001]"
    
    # Verify dependency chain
    assert_task_depends_on "test-epic" "002" "001"
    assert_no_circular_dependencies "test-epic"
}
```

### GitHub Integration Testing

Mock GitHub API calls for testing:

```bash
test_github_sync() {
    # Mock gh command
    mock_gh_command() {
        case "$1" in
            "issue create") echo "https://github.com/org/repo/issues/123" ;;
            *) return 1 ;;
        esac
    }
    
    # Test sync operation
    with_mock "gh" "mock_gh_command" run_epic_sync "test-epic"
    
    # Verify GitHub URL was saved
    assert_frontmatter_contains "test-epic" "github" "issues/123"
}
```

## Test Data Management

### DOH Fixtures

Standard fixtures for DOH entities:

```bash
# ./tests/fixtures/valid_prd.md
create_valid_prd_fixture() {
    cat <<'EOF'
---
name: test-feature
description: Test feature PRD
status: backlog
created: 2025-01-01T00:00:00Z
---
# PRD Content
EOF
}

# ./tests/fixtures/valid_epic.md  
create_valid_epic_fixture() {
    cat <<'EOF'
---
name: test-feature
number: 001
status: backlog
prd: .doh/prds/test-feature.md
---
# Epic Content
EOF
}
```

### Test Project Setup

Helper to create a minimal DOH project:

```bash
init_test_doh_project() {
    mkdir -p .doh/{prds,epics,quick}
    mkdir -p .claude/scripts/doh/{lib,commands}
    echo "DOH_PROJECT_ROOT=$PWD" > .doh/env
    echo "DOH_GLOBAL_DIR=$PWD/.doh/global" >> .doh/env
}
```

## Mocking DOH Components

### Mock File System

```bash
# Mock file operations for testing without disk I/O
mock_filesystem() {
    local -A virtual_files
    
    mock_write_file() {
        virtual_files["$1"]="$2"
    }
    
    mock_read_file() {
        echo "${virtual_files[$1]}"
    }
    
    # Replace real functions with mocks
    alias write_file=mock_write_file
    alias read_file=mock_read_file
}
```

### Mock Date/Time

```bash
# Consistent timestamps for testing
mock_date() {
    echo "2025-01-01T00:00:00Z"
}

with_mocked_date() {
    local original_date=$(which date)
    alias date=mock_date
    "$@"
    alias date="$original_date"
}
```

### Mock User Input

```bash
# Simulate user responses
mock_user_confirm() {
    echo "yes"
}

test_user_confirmation_required() {
    echo "yes" | run_command_requiring_confirmation
    assert_equals "0" "$?"
}
```

## Integration Testing

### Command Pipeline Testing

Test complete command workflows:

```bash
test_prd_to_epic_workflow() {
    # Create PRD
    run_doh_command "prd-new" "feature" <<EOF
Problem statement...
Requirements...
EOF
    
    # Parse to epic
    run_doh_command "prd-parse" "feature"
    
    # Decompose to tasks
    run_doh_command "epic-decompose" "feature"
    
    # Verify complete structure
    assert_file_exists ".doh/prds/feature.md"
    assert_file_exists ".doh/epics/feature/epic.md"
    assert_files_match ".doh/epics/feature/[0-9]*.md"
}
```

### Multi-Agent Testing

Test parallel agent operations:

```bash
test_parallel_agent_execution() {
    # Setup multiple work items
    create_test_tasks 5
    
    # Run parallel execution
    run_parallel_agents "work-on-tasks"
    
    # Verify all completed without conflicts
    assert_all_tasks_completed
    assert_no_merge_conflicts
}
```

## Performance Testing

### Benchmark Tests

```bash
test_performance_large_epic() {
    # Create epic with many tasks
    create_large_test_epic 100
    
    # Measure operation time
    local start=$(date +%s)
    run_doh_command "epic-status" "large-epic"
    local end=$(date +%s)
    
    # Assert performance requirement
    assert_less_than $((end - start)) 5 "Should complete in < 5 seconds"
}
```

## Test Environment Variables

DOH tests should respect these environment variables:

```bash
# Skip slow tests
DOH_TEST_SKIP_SLOW=1

# Run only specific test suites
DOH_TEST_SUITE=unit

# Enable verbose output
DOH_TEST_VERBOSE=1

# Use test fixtures directory
DOH_TEST_FIXTURES_DIR=./tests/fixtures

# Override global DOH directory for tests
DOH_TEST_GLOBAL_DIR=/tmp/doh-test
```

## Running Tests

### Run All Tests
```bash
./tests/run.sh
```

### Run Specific Suite
```bash
./tests/run.sh unit
./tests/run.sh integration
```

### Run Single Test File
```bash
./tests/run.sh ./tests/unit/test_numbering.sh
```

### Run with Coverage
```bash
./tests/run.sh --coverage
```

## Test Output Format

DOH tests use TAP (Test Anything Protocol) format:

```
TAP version 13
1..10
ok 1 - Epic creation succeeds
ok 2 - Task numbering increments
not ok 3 - GitHub sync fails without token
  ---
  message: 'Expected status 0, got 1'
  severity: fail
  file: test_github.sh
  line: 42
  ...
ok 4 - Workspace detection works
# Passed: 9/10
# Failed: 1/10
# Time: 2.341s
```

## Debugging Test Failures

### Enable Debug Mode
```bash
DOH_TEST_DEBUG=1 ./tests/run.sh failing_test.sh
```

### Preserve Test Artifacts
```bash
DOH_TEST_KEEP_TEMP=1 ./tests/run.sh
# Temp files will be preserved in /tmp/doh-test-*
```

### Run with Trace
```bash
bash -x ./tests/run.sh specific_test.sh
```

## Best Practices for DOH Tests

1. **Always clean up**: Use `trap cleanup EXIT` to ensure cleanup
2. **Isolate tests**: Each test gets its own temp directory
3. **Mock external calls**: Never make real GitHub API calls in tests
4. **Test error paths**: Verify error handling and messages
5. **Document complex tests**: Add comments for non-obvious test logic
6. **Keep tests fast**: Mock slow operations like network calls
7. **Version test data**: Include test fixtures in version control

## Common DOH Testing Utilities

### Assertion Functions
- `assert_equals`: Compare two values
- `assert_file_exists`: Check file existence  
- `assert_file_contains`: Verify file content
- `assert_command_succeeds`: Check command exit code
- `assert_frontmatter_valid`: Validate YAML frontmatter
- `assert_task_status`: Check task status field

### Helper Functions
- `create_temp_dir`: Create isolated test directory
- `source_lib`: Source DOH library file
- `run_doh_command`: Execute DOH command
- `with_mock`: Run code with mocked function
- `setup_test_project`: Initialize test DOH project

## Test Maintenance

### Adding New Test Categories
When adding new functionality:
1. Create corresponding test file in appropriate directory
2. Follow naming convention: `test_<feature>.sh`
3. Include in test suite runner
4. Document any new test patterns here

### Updating Test Fixtures
When DOH formats change:
1. Update fixtures in `./tests/fixtures/`
2. Run full test suite to catch breaks
3. Update this documentation if patterns change

## Summary

DOH embraces test-inspired development - a pragmatic approach that prioritizes test coverage and code quality over strict test-first timing. Whether you write tests before, during, or after implementation, the goal is reliable, well-tested code that supports confident refactoring and feature development.

Key principles:
- **Flexibility**: Choose the right workflow (explore-then-test, test-first, or retroactive) based on the situation
- **Coverage**: Maintain good test coverage regardless of when tests are written
- **Quality**: Use tests to ensure command reliability, file operation correctness, and workflow integrity
- **Maintainability**: Keep tests readable, fast, and focused on behavior rather than implementation

By following these patterns and using the provided utilities, you can maintain high confidence in DOH functionality while adapting your testing approach to the natural flow of bash script development.
# DOH Test Suite
<!-- File version: 0.1.0 | Created: 2025-09-01 -->

This directory contains the complete test infrastructure for the DOH project, organized to support both unit and integration testing with a lightweight bash testing framework.

## Directory Structure

```
tests/
├── run.sh              # Main test runner script
├── test_launcher.sh    # Individual test launcher (enforces framework stack)
├── unit/               # Unit tests for individual functions
├── integration/        # Integration tests for complete workflows
├── template/           # Test templates and examples
├── fixtures/           # Test data, mock files, and test fixtures
├── helpers/            # Test utilities and shared code
├── lib/                # Test runner internal functions
└── README.md           # This documentation
```

## Quick Start

### Run All Tests
```bash
./tests/run.sh
```

### Run Specific Test Suite
```bash
./tests/run.sh --suite unit           # Unit tests only
./tests/run.sh --suite integration    # Integration tests only
```

### Run Tests Matching Pattern
```bash
./tests/run.sh --pattern "framework"  # Tests with "framework" in filename
```

### Run Specific Test File
```bash
./tests/run.sh tests/unit/test_example.sh
```

## Test Organization

### Unit Tests (`tests/unit/`)
- Test individual functions and components in isolation
- Fast execution (< 1 second each)
- No external dependencies or file system modifications
- Example: `test_numbering.sh`, `test_frontmatter.sh`

### Integration Tests (`tests/integration/`)
- Test complete workflows and command interactions
- May involve temporary files and directories
- Test DOH commands end-to-end
- Example: `test_epic_workflow.sh`, `test_prd_creation.sh`

### Fixtures (`tests/fixtures/`)
- Test data files (PRDs, epics, tasks)
- Mock configurations
- Sample inputs and expected outputs
- Reusable across multiple tests

### Templates (`tests/template/`)
- `test_simple.sh` - Basic template for quick test creation
- `test_example.sh` - Comprehensive template showing all framework features
- Templates demonstrate proper test structure and patterns
- Copy and customize templates for new tests

### Helpers (`tests/helpers/`)
- `test_framework.sh` - Core testing framework
- Shared test utilities and functions
- Common setup/teardown code
- Mock implementations

## Test Templates

### Available Templates

#### `test_simple.sh` - Basic Template
A minimal template showing the essential patterns for writing tests:
- Basic setup/teardown with `_tf_setup()` and `_tf_teardown()`
- Core assertion functions
- File and command testing
- Proper test structure

**Use this template for:** Simple unit tests, quick test prototypes, learning the framework.

#### `test_example.sh` - Comprehensive Template  
A complete reference showing all available test framework functions:
- All assertion types with examples (76 different test cases)
- Advanced utility functions
- Mocking capabilities
- Edge case testing
- Integration test patterns
- Performance considerations

**Use this template for:** Complex tests, integration testing, reference documentation.

### Using Templates

1. **Copy a template:**
   ```bash
   cp tests/template/test_simple.sh tests/unit/test_my_feature.sh
   ```

2. **Customize the test:**
   ```bash
   # Edit the copied file
   vim tests/unit/test_my_feature.sh
   ```

3. **Run your test:**
   ```bash
   ./tests/run.sh tests/unit/test_my_feature.sh
   ```

## Writing Tests

### Basic Test Structure
```bash
#!/bin/bash
# Test description
# File version: 0.1.0 | Created: 2025-09-01

# Source the framework
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"

# Test functions
test_my_function() {
    # Arrange
    local input="test_value"
    
    # Act
    local result=$(my_function "$input")
    
    # Assert
    _tf_assert_equals "expected" "$result" "Function should return expected value"
}

# Prevent direct execution - tests must run through launcher
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
```

### Available Functions

#### Lifecycle Functions (Optional)
- `_tf_setup()` - Called before each test function
- `_tf_teardown()` - Called after each test function

#### Assertion Functions
- `_tf_assert_equals <expected> <actual> [message]`
- `_tf_assert_not_equals <expected> <actual> [message]`
- `_tf_assert_true <condition> [message]`
- `_tf_assert_false <condition> [message]`
- `_tf_assert_contains <haystack> <needle> [message]`
- `_tf_assert_file_exists <file> [message]`
- `_tf_assert_file_contains <file> <content> [message]`
- `_tf_assert_command_succeeds <command> [message]`
- `_tf_assert_command_fails <command> [message]`

#### Utility Functions
- `_tf_create_temp_dir` - Create temporary directory
- `_tf_create_temp_file` - Create temporary file  
- `_tf_cleanup_temp <path>` - Clean up temporary files/directories
- `_tf_with_mock <original_func> <mock_func> <command>` - Execute command with mocked function

#### Logging Functions
- `_tf_log_info <message>` - Info message (hidden with QUIET=true)
- `_tf_log_success <message>` - Success message (hidden with QUIET=true)
- `_tf_log_warn <message>` - Warning message (hidden with QUIET=true)
- `_tf_log_error <message>` - Error message (always shown, goes to stderr)
- `_tf_log_debug <message>` - Debug message (only shown with VERBOSE=true)
- `_tf_log_trace <message>` - Trace message (only shown with DOH_TEST_DEBUG=true)

### Test Naming Convention
- Test files: `test_<component>.sh`
- Test functions: `test_<description>()`
- Descriptive names that explain what is being tested

### Example Patterns

#### Testing Functions
```bash
test_my_function() {
    # Arrange
    local input="test_value"
    
    # Act  
    local result=$(my_function "$input")
    
    # Assert
    _tf_assert_equals "expected_output" "$result" "Function should transform input correctly"
}
```

#### Testing File Operations
```bash
test_file_processing() {
    local test_file=$(_tf_create_temp_file)
    echo "test data" > "$test_file"
    
    process_file "$test_file"
    
    _tf_assert_file_contains "$test_file" "processed" "File should be processed"
    _tf_cleanup_temp "$test_file"
}
```

#### Testing Commands
```bash
test_command_behavior() {
    _tf_assert_command_succeeds "my_command --valid-flag" "Should accept valid flag"
    _tf_assert_command_fails "my_command --invalid-flag" "Should reject invalid flag"
}
```

#### Using Logging Functions
```bash
test_with_logging() {
    _tf_log_info "Starting complex test operation"
    _tf_log_debug "Debug info: processing input data"
    
    # Arrange
    local result=$(complex_operation)
    
    if [[ -n "$result" ]]; then
        _tf_log_success "Operation completed successfully"
        _tf_assert_equals "expected" "$result" "Should return expected result"
    else
        _tf_log_error "Operation failed to produce result"
        _tf_assert_true "false" "Operation should not fail"
    fi
    
    _tf_log_trace "Detailed trace: operation took ${SECONDS} seconds"
}
```

### Best Practices

1. **Test Function Naming**: Always prefix with `test_`
2. **Descriptive Messages**: Use clear, specific assertion messages
3. **Clean Up**: Use `_tf_teardown()` or `_tf_cleanup_temp` for cleanup
4. **One Concept Per Test**: Keep test functions focused
5. **Test Both Success and Failure**: Include positive and negative test cases

## Running Tests

**Important:** Tests cannot be executed directly. All tests must be run through either:
- `./tests/test_launcher.sh <test_file>` - Run a single test file
- `./tests/run.sh [options] [test_files...]` - Run multiple tests with options

This enforcement ensures:
- Proper test framework initialization
- Consistent environment setup
- Correct working directory
- Proper test isolation

### Test Runner Options
```bash
./tests/run.sh [OPTIONS] [TEST_PATH...]

Options:
    -h, --help          Show help message
    -v, --verbose       Verbose output
    -q, --quiet         Quiet output (errors only)
    -p, --parallel      Run tests in parallel
    -s, --suite SUITE   Run specific suite (unit|integration)
    -t, --pattern PAT   Run tests matching pattern
    -n, --dry-run       Show what would run without executing
    --list             List available test files
    --version          Show version information
```

### Examples
```bash
# Run all tests with verbose output (shows debug messages)
./tests/run.sh --verbose

# Run tests in parallel (faster for many tests)
./tests/run.sh --parallel

# Run only framework-related tests
./tests/run.sh --pattern "framework"

# Dry run to see what would be executed
./tests/run.sh --dry-run --suite unit

# List all available test files
./tests/run.sh --list

# Run template examples to see the framework in action
./tests/run.sh tests/template/test_simple.sh
./tests/run.sh tests/template/test_example.sh

# Run with different logging levels
VERBOSE=true ./tests/run.sh tests/unit/test_logging_demo.sh    # Shows debug messages
DOH_TEST_DEBUG=true ./tests/run.sh tests/unit/test_logging_demo.sh  # Shows trace messages
QUIET=true ./tests/run.sh tests/unit/test_logging_demo.sh     # Minimal output
```

### Running Individual Tests

You can also run tests directly using the test launcher:

```bash
# Run a single test with full framework enforcement
./tests/test_launcher.sh tests/unit/test_basic_demo.sh

# This ensures:
# - Test file sources framework properly
# - Complete test stack execution
# - Proper framework validation
```

## Test Environment

### DOH Environment Variables

The `test_launcher.sh` automatically sets up environment variables for isolated testing:

- **`DOH_PROJECT_DIR`**: Points to the test's temporary `.doh/` directory, allowing DOH API functions to operate on test project data instead of the actual project's versioned data
- **`DOH_GLOBAL_DIR`**: Points to a temporary global directory for DOH workspace data, ensuring tests don't interfere with real workspace configurations and caches
- **`_TF_LAUNCHER_EXECUTION`**: Flag indicating the test is running through the launcher (used by tests to adjust paths and behavior)

**Isolation Granularity**: These variables are set **once per test file**, not per test function. All test functions within a single test file share the same isolated environment.

These variables ensure complete test isolation:
- **DOH_PROJECT_DIR**: Isolates versioned project data (PRDs, epics, tasks, config)
- **DOH_GLOBAL_DIR**: Isolates non-versioned workspace data (caches, logs, user settings)
- **Between test files**: Complete isolation with separate temp directories
- **Within test file**: Shared environment allows state accumulation across test functions

When writing tests that use DOH API functions, you don't need to manually set these variables - the launcher handles this automatically:

```bash
# DOH API functions will automatically use test directories
test_version_operations() {
    # This works correctly because DOH_PROJECT_DIR is set by test_launcher
    # Operations affect test temp directory, not actual project
    version_set_current "1.0.0"
    local result=$(version_get_current)
    _tf_assert_equals "1.0.0" "$result" "Version should be updated in test environment"
}
```

### Test Isolation Granularity

**Important:** Test isolation operates at the **test file level**, not per test function.

- **Per test file**: Each test file gets its own isolated temporary directories (`DOH_GLOBAL_DIR`, `DOH_PROJECT_DIR`)
- **Shared within file**: All test functions within a single test file share the same temporary directories and state

This means:
```bash
# File: test_example.sh
test_first_operation() {
    # Creates state: sequence = 1
    local result=$(numbering_get_next "epic")  # Gets 001
}

test_second_operation() {
    # Continues from previous state: sequence = 1
    local result=$(numbering_get_next "task")  # Gets 002, NOT 001
}
```

**For independent test functions**, use a reset helper:
```bash
# Helper to reset shared state between test functions
_tf_reset_state() {
    # Reset numbering sequence
    local taskseq_file="$(_numbering_get_taskseq_path)"
    [[ -f "$taskseq_file" ]] && echo "0" > "$taskseq_file"
    
    # Reset registry  
    local registry_file="$(_numbering_get_registry_path)"
    [[ -f "$registry_file" ]] && rm -f "$registry_file"
}

test_first_operation() {
    _tf_reset_state  # Start fresh
    local result=$(numbering_get_next "epic")  # Always gets 001
}

test_second_operation() {
    _tf_reset_state  # Start fresh  
    local result=$(numbering_get_next "epic")  # Also gets 001
}
```

This granularity:
- **Prevents pollution** between test files 
- **Allows state accumulation** within a test file when needed
- **Enables predictable test function behavior** with reset helpers

### DOH Project Setup Helper

For tests that need a minimal DOH project structure, consider creating a helper function like `_tf_create_minimal_doh_project`:

```bash
_tf_create_minimal_doh_project() {
    local project_dir="${1:-$(pwd)}"
    
    # Create DOH structure
    mkdir -p "$project_dir/.doh" "$project_dir/.git"
    echo "0.1.0" > "$project_dir/VERSION"
    
    # Create basic .doh files if needed
    cat > "$project_dir/.doh/example.md" << 'EOF'
---
file_version: 0.1.0
name: Example Task
status: open
---
# Example Task
EOF
}

_tf_setup() {
    TEST_DIR=$(_tf_create_temp_dir)
    cd "$TEST_DIR"
    _tf_create_minimal_doh_project "$TEST_DIR"
}
```

This pattern ensures tests have a consistent DOH project structure and work correctly with DOH API functions.

### Temporary Files
```bash
# Create temporary files/directories
temp_dir=$(_tf_create_temp_dir)
temp_file=$(_tf_create_temp_file)

# Always clean up in teardown
_tf_teardown() {
    _tf_cleanup_temp "$temp_dir"
    _tf_cleanup_temp "$temp_file"
}
```

### Mocking
```bash
# Mock external commands or functions
mock_date() {
    echo "2025-01-01T00:00:00Z"
}

test_with_mocked_date() {
    local result=$(_tf_with_mock date mock_date some_function_using_date)
    _tf_assert_contains "$result" "2025-01-01" "Should contain mocked date"
}
```

### Setup and Teardown
```bash
# Called before each test function
_tf_setup() {
    TEST_DIR=$(_tf_create_temp_dir)
    cd "$TEST_DIR"
}

# Called after each test function
_tf_teardown() {
    cd - >/dev/null
    _tf_cleanup_temp "$TEST_DIR"
}
```

## CI/CD Integration

The test runner is designed for continuous integration:

- **Exit codes**: 0 for success, 1 for failure
- **TAP-like output**: Machine-readable test results
- **Parallel execution**: Faster test runs with `--parallel`
- **Filtering**: Run only relevant tests with `--suite` or `--pattern`

### Example CI Configuration
```bash
# In your CI pipeline
./tests/run.sh --parallel --quiet
```

## Best Practices

1. **Keep tests fast**: Unit tests should run in < 1 second
2. **Test behavior, not implementation**: Focus on what functions do, not how
3. **Use descriptive names**: Test names should explain what is being tested
4. **Clean up resources**: Always clean up temporary files and directories
5. **Mock external dependencies**: Don't rely on network, external services
6. **Test edge cases**: Empty inputs, boundary conditions, error paths
7. **One assertion per test**: Makes failures easier to diagnose

## Troubleshooting

### Common Issues

**Tests not found**
- Ensure test files follow naming convention: `test_*.sh`
- Check file permissions (must be readable)
- Verify files are in correct directories

**Framework not loading**
- Ensure `tests/helpers/test_framework.sh` exists
- Check source path in test files: `../helpers/test_framework.sh`

**Tests failing unexpectedly**
- Run with `--verbose` to see detailed output
- Check working directory and file paths
- Verify test isolation (no interdependencies)

### Debug Mode
```bash
# Run single test with bash tracing
bash -x tests/unit/test_example.sh

# Run through test launcher
./tests/test_launcher.sh tests/unit/test_example.sh

# Enable framework debugging
DOH_TEST_DEBUG=1 ./tests/run.sh tests/unit/test_example.sh
```

## Contributing

When adding new tests:

1. Place unit tests in `tests/unit/`
2. Place integration tests in `tests/integration/`
3. Follow naming convention: `test_<component>.sh`
4. Include file version header
5. Add appropriate documentation
6. Test both success and failure paths

For more information, see:
- Template examples: `tests/template/test_simple.sh` and `tests/template/test_example.sh`
- Self-test example: `tests/unit/test_framework_self_test.sh`
- Run templates to see framework in action: `./tests/run.sh tests/template/test_example.sh --verbose`
- [DOH Test-Inspired Development Guide](../docs/doh-tdd.md)
- [General TDD Rules](../rules/tdd.md)
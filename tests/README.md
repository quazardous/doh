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

## Important: Test Launcher Requirement

**⚠️ Tests must be executed through the test launcher system and cannot be run directly.**

Test files are designed to:
- Be executed only through `./tests/run.sh` or `./tests/test_launcher.sh`
- Prevent direct execution with `_tf_direct_execution_error`
- Ensure proper test environment setup and isolation

**❌ This will NOT work:**
```bash
bash tests/unit/test_example.sh        # Direct execution blocked
./tests/unit/test_example.sh           # Direct execution blocked
```

**✅ Use these methods instead:**
```bash
./tests/run.sh                         # Run all tests
./tests/run.sh tests/unit/test_example.sh  # Run specific test
./tests/test_launcher.sh tests/unit/test_example.sh  # Individual test launcher
```

This ensures proper:
- Test isolation and cleanup
- Environment variable management
- Consistent execution context
- Framework dependency loading

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
    _tf_assert_equals "Function should return expected value" "expected" "$result"
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

**Message-First Pattern**: All assertion functions use a **message-first** parameter pattern for consistency.

- `_tf_assert_equals <message> <expected> <actual>` - Assert two values are equal
- `_tf_assert_not_equals <message> <expected> <actual>` - Assert two values are different  
- `_tf_assert_true <message> <condition>` - Assert condition is true
- `_tf_assert_false <message> <condition>` - Assert condition is false
- `_tf_assert_contains <message> <haystack> <needle>` - Assert haystack contains needle
- `_tf_assert_file_exists <message> <file>` - Assert file exists
- `_tf_assert_file_contains <message> <file> <content>` - Assert file contains content
- `_tf_assert <message> <command> [args...]` - Assert command succeeds (exit code 0)
- `_tf_assert_not <message> <command> [args...]` - Assert command fails (exit code != 0)

#### Testing Exit Codes - Best Practices

**For testing commands/functions directly:**
```bash
# ✅ CORRECT: Test command execution directly  
_tf_assert "Should succeed with valid input" my_function "valid_input"
_tf_assert_not "Should fail with invalid input" my_function "invalid_input"

# ✅ CORRECT: Test complex commands with pipes
_tf_assert "Should find pattern in data" bash -c 'echo "$data" | grep -q "pattern"'
```

**For testing stored exit codes:**
```bash  
# ✅ CORRECT: When you need to capture exit code for other reasons
local result=$(my_function "input")
local exit_code=$?
_tf_assert_equals "Function should succeed" 0 $exit_code

# ✅ CORRECT: When testing specific non-zero exit codes
my_function "bad_input"
local exit_code=$?
_tf_assert_equals "Should return specific error code" 2 $exit_code
```

**Common patterns to avoid:**
```bash
# ❌ WRONG: Using $? after command execution
my_function "input"
_tf_assert "Function should succeed" $?  # Use _tf_assert with command directly

# ❌ WRONG: Unnecessary exit code capture for simple success/failure
local result=$(my_function "input") 
local exit_code=$?
_tf_assert_equals "Function should succeed" 0 $exit_code  # Use _tf_assert instead

# ❌ WRONG: Message not first
_tf_assert_equals 0 $exit_code "Function should succeed"  # Message should be first
```

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
    _tf_assert_equals "Function should transform input correctly" "expected_output" "$result"
}
```

#### Testing File Operations
```bash
test_file_processing() {
    local test_file=$(_tf_create_temp_file)
    echo "test data" > "$test_file"
    
    process_file "$test_file"
    
    _tf_assert_file_contains "File should be processed" "$test_file" "processed"
    _tf_cleanup_temp "$test_file"
}
```

#### Testing Commands
```bash
test_command_behavior() {
    _tf_assert "Should accept valid flag" my_command --valid-flag
    _tf_assert_not "Should reject invalid flag" my_command --invalid-flag
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

### DOH Environment Variables and Path Functions

The `test_launcher.sh` automatically sets up environment variables for isolated testing. **Important: Tests should use DOH API path functions instead of accessing environment variables directly.**

#### Environment Variables (Internal Use)
- **`DOH_PROJECT_DIR`**: Points to the test's temporary `.doh/` directory, allowing DOH API functions to operate on test project data instead of the actual project's versioned data. **The directory itself does not exist initially by design**, mirroring how a fresh project starts before any DOH commands are run.
- **`DOH_GLOBAL_DIR`**: Points to a temporary global directory for DOH workspace data, ensuring tests don't interfere with real workspace configurations and caches
- **`DOH_VERSION_FILE`**: Points to `${DOH_TEST_CONTAINER_DIR}/VERSION`, isolating global version operations from the developer's real DOH global configuration. **The file itself does not exist initially by design** and is created by DOH commands as needed.
- **`_TF_LAUNCHER_EXECUTION`**: Flag indicating the test is running through the launcher (used by tests to adjust paths and behavior)

#### DOH Path Functions (MANDATORY)

**⚠️ IMPORTANT: Direct access to DOH environment variables is strongly discouraged. Always use the corresponding DOH API functions.**

**Tests MUST use DOH library path functions instead of direct environment variable access:**

```bash
# Source DOH library first
source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/doh.sh"

# ✅ CORRECT: Use DOH library path functions
local project_dir=$(doh_project_dir)    # Get DOH project directory
local global_dir=$(doh_global_dir)      # Get DOH global directory  
local version_file=$(doh_version_file)  # Get VERSION file path

# ❌ FORBIDDEN: Direct environment variable access
echo "$DOH_PROJECT_DIR"     # ❌ Use doh_project_dir() instead
echo "$DOH_GLOBAL_DIR"      # ❌ Use doh_global_dir() instead
echo "$DOH_VERSION_FILE"    # ❌ Use doh_version_file() instead
```

**Available DOH Path Functions:**
- **`doh_project_dir()`** - Returns path to DOH project directory (`.doh/`)
- **`doh_global_dir()`** - Returns path to DOH global directory (`~/.doh` or test isolation)
- **`doh_version_file()`** - Returns path to VERSION file (project root or test isolation)
- **`doh_project_root()`** - Returns path to project root directory

**Benefits of using DOH library functions:**
- **Automatic structure creation**: DOH functions create necessary directory structure on first access
- **Consistent behavior**: Same behavior in tests as in production DOH usage
- **Perfect test isolation**: Functions handle test vs production environments transparently
- **Error handling**: DOH functions provide proper error handling and validation
- **API consistency**: Unified interface across all DOH operations

**Very Limited Exceptions (Must Be Justified with Comments):**
Direct environment variable access is only acceptable in these specific cases and **MUST include a justifying comment**:

```bash
# JUSTIFIED: Environment validation test - testing DOH_PROJECT_DIR is properly set
_tf_assert "DOH_PROJECT_DIR should be set" [ -n "$DOH_PROJECT_DIR" ]

# JUSTIFIED: Debug logging - displaying environment state for diagnostic purposes  
_tf_log_debug "DOH_PROJECT_DIR: $DOH_PROJECT_DIR"

# JUSTIFIED: Test launcher validation - checking if test environment is properly set up
if [[ -n "$DOH_PROJECT_DIR" ]]; then
```

**Acceptable cases:**
- **Environment validation tests**: Tests that verify environment variables are properly set (only in `test_test_framework_env.sh`)
- **Debug logging**: Displaying environment state for diagnostic purposes (e.g., `test_launcher.sh` debug output)
- **Test launcher validation**: Checking if test environment is properly set up before proceeding
- **Framework internals**: Test launcher setup and cleanup operations

**All other usage should use the DOH API functions without exception.** This ensures proper abstraction, test isolation, and consistent behavior across all environments.

**Isolation Granularity**: These variables are set **once per test file**, not per test function. All test functions within a single test file share the same isolated environment.

These variables ensure complete test isolation:
- **DOH_PROJECT_DIR**: Isolates versioned project data (PRDs, epics, tasks, config)
- **DOH_GLOBAL_DIR**: Isolates non-versioned workspace data (caches, logs, user settings)
- **DOH_VERSION_FILE**: Isolates global version configuration from developer's personal DOH setup
- **Between test files**: Complete isolation with separate temp directories
- **Within test file**: Shared environment allows state accumulation across test functions

When writing tests that use DOH functions, the launcher handles environment setup automatically. **Use DOH library functions for consistent behavior:**

```bash
# Source DOH libraries directly in tests
source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/version.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/doh.sh"

# DOH library functions will automatically use test directories and create structure as needed
test_version_operations() {
    # DOH functions work correctly because environment is set by test_launcher
    # Operations affect test temp directory, not actual project or global config
    version_set_current "1.0.0"
    local result=$(version_get_current)
    _tf_assert_equals "Version should be updated in test environment" "1.0.0" "$result"
}

test_project_structure_access() {
    # ✅ RECOMMENDED: Use DOH library functions for path access
    local project_dir=$(doh_project_dir)
    local epic_file="$project_dir/epics/test-epic.md"
    
    # DOH functions automatically create directory structure as needed
    echo "test content" > "$epic_file"
    _tf_assert_file_exists "Epic file should be created" "$epic_file"
}

test_direct_variable_usage() {
    # ❌ AVOID: Direct variable access (use only for specific test cases)
    local project_dir="$DOH_PROJECT_DIR"  # Avoid this pattern
    
    # ✅ PREFER: DOH library function call
    local project_dir=$(doh_project_dir)
}
```

### Complete DOH Environment Isolation

The test launcher creates a fully isolated DOH environment that includes:

#### Temporary Directory Structure
```
/tmp/doh.XXXXXX/                    # Secure temporary container (DOH_TEST_CONTAINER_DIR)
├── VERSION                         # DOH_VERSION_FILE (project VERSION, copied from skeleton)
├── global_doh/                     # DOH_GLOBAL_DIR
│   ├── projects/                   # Workspace project registry (created as needed)
│   └── caches/                     # DOH caches and logs (created as needed)
└── project_doh/                    # DOH_PROJECT_DIR ≡ .doh/ (doesn't exist initially)
    ├── epics/                      # Project epics (copied from skeleton project_doh/epics/)
    ├── prds/                       # Project PRDs (copied from skeleton project_doh/prds/)
    └── versions/                   # Project versions (copied from skeleton project_doh/versions/)
```

**Direct structure mapping**: Skeleton directories now mirror the target structure exactly:
- `skeleton/VERSION` → `/tmp/doh.XXXXXX/VERSION` (DOH_VERSION_FILE)
- `skeleton/project_doh/` → `/tmp/doh.XXXXXX/project_doh/` (DOH_PROJECT_DIR)  
- `skeleton/global_doh/` → `/tmp/doh.XXXXXX/global_doh/` (optional, for DOH_GLOBAL_DIR)

#### Isolation Benefits
- **No interference**: Tests never affect developer's real DOH configuration
- **Clean slate**: Each test file starts with empty DOH environment
- **Predictable state**: No dependency on existing DOH data or configuration
- **Global operations**: Even global DOH commands operate in test environment
- **Version isolation**: Global version commands use test VERSION file, not system one

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

### DOH Project Setup in Tests

Since `DOH_PROJECT_DIR` points to a non-existent `.doh/` directory initially, tests must create the necessary DOH project structure as part of their setup. This mirrors real-world usage where DOH commands initialize project structure on first use.

#### Basic Setup Pattern

**Recommended: Use DOH library functions for automatic structure creation**

```bash
# Source DOH library first
source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/doh.sh"

_tf_setup() {
    # ✅ PREFERRED: Use DOH library function - automatically creates structure as needed
    local project_dir=$(doh_project_dir)
    
    # Create parent project with VERSION file
    local project_root="$(dirname "$project_dir")"
    echo "0.2.0" > "$project_root/VERSION"
    
    # Create test-specific data files - directory structure created automatically
    cat > "$project_dir/prds/test-prd.md" << 'EOF'
---
name: test-prd
status: backlog
file_version: 0.1.0
---
# Test PRD Content
EOF
}

# ❌ AVOID: Manual directory creation (unless testing missing directory scenarios)
_tf_setup_manual() {
    # Only use this pattern for specific test cases that need manual control
    local project_dir=$(doh_project_dir)
    mkdir -p "$project_dir/epics" "$project_dir/prds" "$project_dir/versions"
    local project_root="$(dirname "$project_dir")"
    echo "0.2.0" > "$project_root/VERSION"
}
```

#### Using DOH Fixtures Helper

For more complex setups, use the existing `doh_fixtures.sh` helper functions:

```bash
# Source the fixtures helper
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/doh_fixtures.sh"

_tf_setup() {
    # Create complete DOH project structure
    _tff_create_minimal_doh_project >/dev/null
    
    # Set up workspace environment for helper testing
    _tff_setup_workspace_for_helpers
}
```

#### Available Fixture Functions

The `doh_fixtures.sh` helper provides several pre-built project structures based on skeleton projects:

- **`_tff_create_minimal_doh_project`**: Basic DOH structure with empty directories and VERSION file (uses `minimal/` skeleton)
- **`_tff_create_helper_test_project`**: Complete setup for helper testing with sample PRDs, epics, tasks, and versions (uses `helper-test/` skeleton)
- **`_tff_create_sample_doh_project`**: DOH project with sample epics and tasks for general testing (uses `sample/` skeleton)
- **`_tff_create_version_test_project`**: Specialized for version testing with various file_version scenarios (uses `version-test/` skeleton)
- **`_tff_create_cache_test_project`**: Setup for testing cache and registry functionality (uses `cache-test/` skeleton)
- **`_tff_copy_skeleton`**: Copy any skeleton directly by name
- **`_tff_setup_workspace_for_helpers`**: Configures workspace environment and overrides for isolated helper testing

#### Skeleton Projects

All fixture functions use pre-built skeleton projects stored in `tests/fixtures/skl/`. These skeletons contain realistic DOH project structures with proper frontmatter, content, and file organization. 

**For complete skeleton architecture documentation and design principles**, see [tests/fixtures/skl/README.md](fixtures/skl/README.md).

#### Why This Design?

This approach ensures tests behave like real DOH usage:

- **Fresh project simulation**: Tests start with empty `.doh/` just like a new project
- **Automatic structure creation**: DOH API functions create directory structure as needed, matching real behavior
- **Consistent behavior**: Same initialization behavior in tests as in production DOH usage  
- **Dependency validation**: Tests verify that DOH commands properly handle missing directories when needed
- **Setup flexibility**: API handles common structure creation, tests can focus on test-specific data

**Structure Creation Philosophy:**
- **DOH library handles common cases**: Use DOH library functions that automatically create standard directory structure
- **Manual creation for edge cases**: Only manually create/omit directories when testing specific missing directory scenarios
- **Test behavior, not implementation**: Focus on testing DOH functionality rather than directory management

#### Common Setup Patterns

```bash
# For helper function tests (recommended)
_tf_setup() {
    _tff_create_helper_test_project >/dev/null
    _tff_setup_workspace_for_helpers
}

# For epic-related tests
_tf_setup() {
    _tff_create_sample_doh_project >/dev/null
    _tff_setup_workspace_for_helpers
}

# For version-related tests  
_tf_setup() {
    _tff_create_version_test_project >/dev/null
    _tff_setup_workspace_for_helpers
}

# For minimal/custom tests
_tf_setup() {
    _tff_create_minimal_doh_project >/dev/null
    _tff_setup_workspace_for_helpers
    
    # Add custom test data as needed
    local project_dir=$(doh_project_dir)
    cat > "$project_dir/prds/custom-prd.md" << 'EOF'
---
name: custom-prd
status: backlog
file_version: 0.1.0
---
# Custom PRD for specific test
EOF
}
```

#### Fixture Benefits

Using fixture functions provides several advantages:

- **Consistent test data**: All tests use the same reliable baseline data
- **Comprehensive coverage**: Fixtures include various scenarios (completed tasks, parallel tasks, different statuses)
- **Realistic content**: Sample PRDs and epics contain proper structure and content for parsing tests
- **Workspace isolation**: `_tff_setup_workspace_for_helpers` ensures proper workspace function overrides
- **Maintenance**: Changes to test data structure happen in one place

This pattern ensures tests have a consistent DOH project structure while accurately simulating real-world DOH usage patterns.

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
8. **Test files don't need executable permissions**: Test files are sourced by the test launcher, not executed directly
9. **Always use absolute file paths**: Never create files without full paths to avoid artifacts in project root

### File Path Best Practices

**❌ WRONG - Creates artifacts in project root:**
```bash
# These create files in the current directory!
frontmatter_create_markdown "content" "test data"
echo "test" > "output.txt"  
some_command "filename.md"
```

**✅ CORRECT - Use absolute paths:**
```bash
# Use test framework temp functions
local temp_file=$(_tf_create_temp_file ".md")
frontmatter_create_markdown "$temp_file" "test data"

# Or use explicit temp directories
local test_file="/tmp/test_${RANDOM}.md"
echo "test" > "$test_file"

# For DOH project testing, use proper paths
local project_file="$TEST_DIR/test_file.md"
some_command "$project_file"
```

**Key Rules:**
- Never use filenames without directory paths (`"content"`, `"output.txt"`)
- Always use `$TEST_DIR`, `/tmp/`, or `_tf_create_temp_*` functions
- Clean up temporary files in `_tf_teardown()` when needed
- Use `$(_tf_create_temp_dir)` for temporary directories

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
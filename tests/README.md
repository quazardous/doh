# DOH Test Suite
<!-- File version: 0.1.0 | Created: 2025-09-01 -->

This directory contains the complete test infrastructure for the DOH project, organized to support both unit and integration testing with a lightweight bash testing framework.

## 🎯 NEW TO TESTING? START HERE!

**See the current best practices in action:**
```bash
# Review the comprehensive template showing all current patterns
cat tests/template/test_best_patterns.sh

# Run it to see it working
./tests/run.sh tests/template/test_best_patterns.sh --verbose
```

This template demonstrates all current best practices with extensive comments explaining the WHY behind each pattern.

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

### Start with the Best Practices Template
```bash
# Review the recommended patterns and practices
cat tests/template/test_best_patterns.sh

# Copy it for your new test
cp tests/template/test_best_patterns.sh tests/unit/test_my_feature.sh
```

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

# Run the best practices template to see it in action
./tests/run.sh tests/template/test_best_patterns.sh
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
- Use isolated container temp directory (not external dependencies)
- Example: `test_numbering.sh`, `test_frontmatter.sh`
- **Follow**: `tests/template/test_best_patterns.sh` for current patterns

### Integration Tests (`tests/integration/`)
- Test complete workflows and command interactions
- Use container temp directories for isolation
- Test DOH commands end-to-end (source libraries directly, not wrappers)
- Example: `test_epic_workflow.sh`, `test_prd_creation.sh`
- **Follow**: `tests/template/test_best_patterns.sh` for current patterns

### Fixtures (`tests/fixtures/`)
- Test data files (PRDs, epics, tasks)
- Mock configurations
- Sample inputs and expected outputs
- Reusable across multiple tests

### Templates (`tests/template/`)
- **`test_best_patterns.sh`** - RECOMMENDED: Current best practices and patterns (start here!)
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

#### `test_best_patterns.sh` - RECOMMENDED Template ⭐
The current best practices template showing all modern patterns:
- Direct DOH library sourcing (NOT api.sh/helper.sh wrappers)
- Current command testing with _tf_assert/_tf_assert_not
- Container temp directory usage with _tf_test_container_tmpdir()
- Local variables only (NO global variables)
- DOH-specific patterns and fixture usage
- Manual cleanup discouraged (prevents debugging)
- Performance patterns and anti-patterns to avoid
- Extensive comments explaining WHY behind each pattern

**Use this template for:** ALL new tests, learning current patterns, best practices reference.

#### `test_simple.sh` - Legacy Basic Template
Minimal template showing older patterns (consider using test_best_patterns.sh instead):
- Basic setup/teardown structure
- Core assertion functions
- Simple file and command testing

**Use this template for:** Quick prototypes (but prefer test_best_patterns.sh for consistency).

#### `test_example.sh` - Legacy Comprehensive Template  
Complete reference showing all framework functions (consider using test_best_patterns.sh instead):
- All assertion types with examples (76 different test cases)
- Advanced utility functions and mocking capabilities
- Edge case and integration patterns

**Use this template for:** Framework reference (but prefer test_best_patterns.sh for actual tests).

### Using Templates

**RECOMMENDED: Always start with the best practices template:**

1. **Copy the best practices template:**
   ```bash
   # RECOMMENDED: Always use the current best practices template
   cp tests/template/test_best_patterns.sh tests/unit/test_my_feature.sh
   ```

2. **Customize the test:**
   ```bash
   # Edit the copied file
   vim tests/unit/test_my_feature.sh
   
   # Source the DOH libraries you need (examples already shown in template)
   # The template includes extensive comments for guidance
   ```

3. **Run your test:**
   ```bash
   ./tests/run.sh tests/unit/test_my_feature.sh
   ```

**Alternative starting points (discouraged - prefer best_patterns.sh):**
```bash
# For quick prototypes (but prefer best practices template)
cp tests/template/test_simple.sh tests/unit/test_basic_feature.sh

# For framework reference (but prefer best practices template)
cp tests/template/test_example.sh tests/unit/test_complex_feature.sh
```

## Writing Tests

### CRITICAL: Source Libraries Directly in Tests

**⚠️ IMPORTANT: Tests MUST source DOH libraries directly for performance and proper testing.**

```bash
# ✅ CORRECT: Source libraries directly in tests
source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/version.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/frontmatter.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/task.sh"

# Then call functions directly
test_version_operations() {
    _tf_assert "Should validate version" version_validate "1.2.3"
    _tf_assert_not "Should reject invalid" version_validate "invalid"
    
    local current=$(version_get_current)
    _tf_assert_equals "Should get version" "1.0.0" "$current"
}

# ❌ WRONG: Using api.sh or helper.sh in tests (slow and unnecessary)
test_bad_pattern() {
    # DON'T DO THIS IN TESTS!
    _tf_assert "Bad" ./.claude/scripts/doh/api.sh version validate "1.2.3"
    _tf_assert "Bad" ./.claude/scripts/doh/helper.sh prd list
}
```

**Why source libraries directly in tests:**
- **Performance**: 10x faster - no subprocess overhead
- **Direct testing**: Test the actual functions, not wrapper scripts
- **Better debugging**: Direct stack traces and error messages
- **Proper isolation**: Test functions in controlled environment
- **Standard practice**: All existing tests follow this pattern

**Exception**: Only use `api.sh`/`helper.sh` in tests when specifically testing those wrapper scripts themselves (e.g., `test_helper_prd.sh`).

### Basic Test Structure

**IMPORTANT: Use the best practices template as your starting point instead of this basic example:**

```bash
# RECOMMENDED: Copy and customize the best practices template
cp tests/template/test_best_patterns.sh tests/unit/test_my_feature.sh
```

**For reference, here's the essential structure (but the template has much more guidance):**
```bash
#!/bin/bash
# Test description
# File version: 0.1.0 | Created: 2025-09-01

# Source the test framework (MANDATORY)
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"

# Source DOH fixtures helper for setup
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/doh_fixtures.sh"

# Source DOH libraries directly (MANDATORY - NOT api.sh/helper.sh)
source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/doh.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/version.sh"
# Add other libraries as needed for your tests

# Setup (optional)
_tf_setup() {
    # Use fixtures for consistent test data
    _tff_create_minimal_doh_project >/dev/null
}

# Test functions (MUST be self-contained with local variables only)
test_my_function() {
    # CRITICAL: Each test declares its own local variables
    # NO global variables - tests are self-contained
    
    # Get paths when needed (DON'T store globally)
    local tmp_base=$(_tf_test_container_tmpdir)
    local doh_dir=$(doh_project_dir)
    local test_file="$tmp_base/test_data_${RANDOM}.txt"
    
    echo "data" > "$test_file"
    
    # PREFERRED: Direct function calls after sourcing libraries
    _tf_assert "Function should succeed with valid input" version_validate "1.0.0"
    _tf_assert_not "Function should fail with invalid input" version_validate "invalid"
    
    # For testing output values
    local result=$(version_get_current)
    _tf_assert_equals "Should return current version" "1.0.0" "$result"
    
    # All variables are local - container handles cleanup
}

# Teardown (optional)
_tf_teardown() {
    # NO manual cleanup - prevents debugging and is unnecessary
    # Container cleanup handles temp files automatically
    :  # No-op - just comments explaining why we don't clean up
}

# Prevent direct execution - tests must run through launcher
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
```

### Available Functions

#### Lifecycle Functions (Optional)
- `_tf_setup()` - Called before each test function (use for creating test data)
- `_tf_teardown()` - Called after each test function (NO manual cleanup recommended)

#### Assertion Functions

**Message-First Pattern**: All assertion functions use a **message-first** parameter pattern for consistency.

**🎯 Most Important for Command Testing:**
- **`_tf_assert <message> <command> [args...]`** - Assert command succeeds (exit code 0) - **USE THIS FOR TESTING COMMANDS**
- **`_tf_assert_not <message> <command> [args...]`** - Assert command fails (exit code != 0) - **USE THIS FOR TESTING EXPECTED FAILURES**

**Other Assertions:**
- `_tf_assert_equals <message> <expected> <actual>` - Assert two values are equal
- `_tf_assert_not_equals <message> <expected> <actual>` - Assert two values are different  
- `_tf_assert_true <message> <condition>` - Assert condition is true
- `_tf_assert_false <message> <condition>` - Assert condition is false
- `_tf_assert_contains <message> <haystack> <needle>` - Assert haystack contains needle
- `_tf_assert_file_exists <message> <file>` - Assert file exists
- `_tf_assert_file_contains <message> <file> <content>` - Assert file contains content

#### Testing Commands and Exit Codes - PREFERRED PATTERNS

**🎯 PRIMARY RECOMMENDATION: Use `_tf_assert` and `_tf_assert_not` for testing commands directly**

These functions are specifically designed for testing command success/failure and provide cleaner, more readable tests:

```bash
# ✅ BEST PRACTICE: Test DOH functions directly (after sourcing libraries)
# This is 10x faster than using api.sh/helper.sh wrappers
_tf_assert "Version should validate" version_validate "1.2.3"
_tf_assert_not "Should reject invalid version" version_validate "invalid"
_tf_assert "Task should be completed" task_is_completed "$task_file"
_tf_assert "Should get frontmatter field" frontmatter_get_field "$file" "status"

# ✅ BEST PRACTICE: Test with specific arguments
_tf_assert "Should increment patch version" version_increment "1.0.0" "patch"
_tf_assert_not "Should reject invalid increment" version_increment "1.0.0" "invalid"

# ✅ BEST PRACTICE: Test file operations
_tf_assert "Should create file" touch "$test_file"
_tf_assert "File should exist after creation" test -f "$test_file"
_tf_assert_not "Should fail on missing file" cat "/nonexistent/file"

# ✅ BEST PRACTICE: Test complex commands with bash -c
_tf_assert "Should find pattern in data" bash -c 'echo "$data" | grep -q "pattern"'
_tf_assert_not "Should not find missing pattern" bash -c 'echo "$data" | grep -q "missing"'

# ⚠️ EXCEPTION: Only test wrapper scripts when specifically testing them
# (e.g., in test_helper_prd.sh when testing the helper.sh interface)
_tf_assert "Helper should work" ./.claude/scripts/doh/helper.sh prd list
_tf_assert_not "Should fail without args" ./.claude/scripts/doh/helper.sh prd new

# ❌ WRONG: Using api.sh/helper.sh for testing library functions (slow!)
# _tf_assert "Bad" ./.claude/scripts/doh/api.sh version validate "1.2.3"  # 10x slower!
```

**Why `_tf_assert` and `_tf_assert_not` are preferred:**
- **Direct execution**: Tests the actual command, not a stored exit code
- **Clear intent**: Explicitly shows expected success or failure
- **Better error messages**: Framework reports which command failed
- **Cleaner code**: No need for intermediate variables or exit code capture
- **Consistent pattern**: Same approach for all command testing

**When to capture exit codes (less common):**
```bash  
# Only when you need BOTH output AND specific exit code
local result=$(my_function "input" 2>&1)
local exit_code=$?
_tf_assert_equals "Should return specific error code" 2 $exit_code
_tf_assert_contains "Should have error message" "$result" "Expected error"

# When testing exact non-zero exit codes
my_function "bad_input"
local exit_code=$?
_tf_assert_equals "Should return code 2 for missing file" 2 $exit_code
```

**Common anti-patterns to avoid:**
```bash
# ❌ WRONG: Capturing exit code when you only care about success/failure
local result=$(my_function "input")
local exit_code=$?
_tf_assert_equals "Function should succeed" 0 $exit_code  # Use _tf_assert instead!

# ❌ WRONG: Testing $? separately
my_function "input"
_tf_assert_equals "Should succeed" 0 $?  # Use _tf_assert my_function "input"

# ❌ WRONG: Verbose exit code checking
if my_function "input"; then
    _tf_assert_true "Should succeed" true
else
    _tf_assert_true "Should succeed" false
fi
# Just use: _tf_assert "Should succeed" my_function "input"

# ❌ WRONG: Message not first
_tf_assert my_function "input" "Should succeed"  # Message must be first!
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

#### Testing Functions (Self-Contained Pattern)
```bash
test_my_function() {
    # CRITICAL: All variables are local - no global dependencies
    local input="test_value"
    
    # Act
    local result=$(my_function "$input")
    
    # Assert
    _tf_assert_equals "Function should transform input correctly" "expected_output" "$result"
    
    # No cleanup needed - all variables are local
}
```

#### Testing File Operations (Container Temp Pattern)
```bash
test_file_processing() {
    # Use container's temp directory for isolation
    local tmp_base=$(_tf_test_container_tmpdir)
    local test_file="$tmp_base/test_${RANDOM}.txt"
    echo "test data" > "$test_file"
    
    process_file "$test_file"
    
    _tf_assert_file_contains "File should be processed" "$test_file" "processed"
    
    # NO manual cleanup - container handles this automatically
    # Manual cleanup prevents debugging and is unnecessary
}
```

#### Testing Commands (CURRENT BEST PATTERN)
```bash
# MANDATORY: Source DOH libraries directly at the top of your test file
source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/version.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/task.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/frontmatter.sh"

test_command_behavior() {
    # PREFERRED: Test sourced functions directly (10x faster than wrappers)
    _tf_assert "Should validate version" version_validate "1.0.0"
    _tf_assert_not "Should reject invalid" version_validate "not-a-version"
    
    # Create test files with local variables (no globals)
    local tmp_base=$(_tf_test_container_tmpdir)
    local completed_task="$tmp_base/completed.md"
    local pending_task="$tmp_base/pending.md"
    
    # Set up test data
    cat > "$completed_task" <<'EOF'
---
status: completed
---
# Task
EOF
    
    cat > "$pending_task" <<'EOF'
---
status: pending  
---
# Task
EOF
    
    # Test with prepared data
    _tf_assert "Should detect completed task" task_is_completed "$completed_task"
    _tf_assert_not "Should detect incomplete" task_is_completed "$pending_task"
    
    # Test with arguments
    _tf_assert "Should increment version" version_increment "1.0.0" "patch"
    _tf_assert_not "Should fail on invalid type" version_increment "1.0.0" "invalid"
    
    # All variables are local - no cleanup needed
}
```

#### Using Logging Functions (Self-Contained Pattern)
```bash
test_with_logging() {
    _tf_log_info "Starting complex test operation"
    _tf_log_debug "Debug info: processing input data"
    
    # All variables are local
    local input_data="test_input"
    local result=$(complex_operation "$input_data")
    
    if [[ -n "$result" ]]; then
        _tf_log_success "Operation completed successfully"
        _tf_assert_equals "Should return expected result" "expected" "$result"
    else
        _tf_log_error "Operation failed to produce result"
        _tf_assert_true "Operation should not fail" "false"
    fi
    
    _tf_log_trace "Detailed trace: operation took ${SECONDS} seconds"
    
    # No cleanup needed - all variables are local
}
```

### Best Practices

1. **Test Function Naming**: Always prefix with `test_`
2. **Descriptive Messages**: Use clear, specific assertion messages (message first!)
3. **NO Manual Cleanup**: DON'T use manual cleanup in `_tf_teardown()` - prevents debugging
4. **One Concept Per Test**: Keep test functions focused and self-contained
5. **Test Both Success and Failure**: Include positive and negative test cases
6. **Local Variables Only**: NO global variables - each test is self-contained
7. **Source Libraries Directly**: NEVER use api.sh/helper.sh wrappers in tests (10x slower)
8. **Use Container Temp**: Always use `_tf_test_container_tmpdir()` for temp files
9. **Follow Best Practices Template**: Use `tests/template/test_best_patterns.sh` as your starting point

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

# RECOMMENDED: Run the best practices template to see current patterns
./tests/run.sh tests/template/test_best_patterns.sh

# Run other template examples (legacy patterns - prefer best_patterns.sh)
./tests/run.sh tests/template/test_simple.sh     # Basic patterns
./tests/run.sh tests/template/test_example.sh    # Comprehensive reference

# Run with different logging levels
VERBOSE=true ./tests/run.sh tests/template/test_best_patterns.sh    # Shows debug messages
DOH_TEST_DEBUG=true ./tests/run.sh tests/template/test_best_patterns.sh  # Shows trace messages
QUIET=true ./tests/run.sh tests/template/test_best_patterns.sh     # Minimal output
```

### Running Individual Tests

You can also run tests directly using the test launcher:

```bash
# Run a single test with full framework enforcement
./tests/test_launcher.sh tests/unit/test_basic_demo.sh

# RECOMMENDED: Run the best practices template (shows current patterns)
./tests/test_launcher.sh tests/template/test_best_patterns.sh

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
local doh_dir=$(doh_project_dir)    # Get DOH project directory
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

When writing tests that use DOH functions, the launcher handles environment setup automatically. **ALWAYS source DOH libraries directly for testing:**

```bash
# ✅ MANDATORY: Source DOH libraries directly in tests (NOT api.sh or helper.sh)
source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/version.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/doh.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/frontmatter.sh"

# DOH library functions will automatically use test directories and create structure as needed
test_version_operations() {
    # Direct function calls - fast and proper for testing
    version_set_current "1.0.0"
    local result=$(version_get_current)
    _tf_assert_equals "Version should be updated in test environment" "1.0.0" "$result"
    
    # ❌ AVOID: Don't use wrapper scripts in tests
    # local result=$(./.claude/scripts/doh/api.sh version get_current)  # SLOW!
}

test_project_structure_access() {
    # ✅ BEST PRACTICE: Use DOH library function directly in each test
    # Don't store in global variables - call when needed
    local doh_dir=$(doh_project_dir)
    local epic_file="$doh_dir/epics/test-epic.md"
    
    # DOH functions automatically create directory structure as needed
    echo "test content" > "$epic_file"
    _tf_assert_file_exists "Epic file should be created" "$epic_file"
}

test_direct_variable_usage() {
    # ❌ AVOID: Direct variable access (use only for specific test cases)
    local doh_dir="$DOH_PROJECT_DIR"  # Avoid this pattern
    
    # ✅ PREFER: DOH library function call
    local doh_dir=$(doh_project_dir)
}
```

### Complete DOH Environment Isolation

The test launcher creates a fully isolated DOH environment that includes:

#### Temporary Directory Structure
```
/tmp/doh.XXXXXX/                    # Secure temporary container (DOH_TEST_CONTAINER_DIR)
├── VERSION                         # DOH_VERSION_FILE (project VERSION, copied from skeleton)
├── tmp/                            # Test-specific temp directory (_tf_test_container_tmpdir)
│   └── [test temp files]           # All temp files created by _tf_create_temp_* go here
├── global_doh/                     # DOH_GLOBAL_DIR
│   ├── projects/                   # Workspace project registry (created as needed)
│   └── caches/                     # DOH caches and logs (created as needed)
└── project_doh/                    # DOH_PROJECT_DIR ≡ .doh/ (doesn't exist initially)
    ├── epics/                      # Project epics (copied from skeleton project_doh/epics/)
    ├── prds/                       # Project PRDs (copied from skeleton project_doh/prds/)
    └── versions/                   # Project versions (copied from skeleton project_doh/versions/)
```

**Important Paths:**
- `DOH_TEST_CONTAINER_DIR`: The root `/tmp/doh.XXXXXX/` directory
- `_tf_test_container_tmpdir()`: Returns `${DOH_TEST_CONTAINER_DIR}/tmp/` for test temp files
- `doh_project_dir()`: Returns `${DOH_TEST_CONTAINER_DIR}/project_doh/` (uses `DOH_PROJECT_DIR`)
- `doh_global_dir()`: Returns `${DOH_TEST_CONTAINER_DIR}/global_doh/` (uses `DOH_GLOBAL_DIR`)
- `doh_version_file()`: Returns `${DOH_TEST_CONTAINER_DIR}/VERSION` for version operations (uses `DOH_VERSION_FILE`)

**Advanced Testing Note:** While the underlying environment variables (`DOH_PROJECT_DIR`, `DOH_GLOBAL_DIR`, `DOH_VERSION_FILE`) can be modified for very advanced test scenarios, **best practice is to always use the DOH library path functions** for consistency, automatic structure creation, and proper abstraction.

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
    local doh_dir=$(doh_project_dir)
    
    # Create parent project with VERSION file
    local project_root="$(dirname "$doh_dir")"
    echo "0.2.0" > "$project_root/VERSION"
    
    # Create test-specific data files - directory structure created automatically
    cat > "$doh_dir/prds/test-prd.md" << 'EOF'
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
    local doh_dir=$(doh_project_dir)
    mkdir -p "$doh_dir/epics" "$doh_dir/prds" "$doh_dir/versions"
    local project_root="$(dirname "$doh_dir")"
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
    # BEST PRACTICE: Call doh_project_dir() directly when needed
    local doh_dir=$(doh_project_dir)
    cat > "$doh_dir/prds/custom-prd.md" << 'EOF'
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

**IMPORTANT:** All temporary files must be created within the test container's isolated tmp directory using the test framework functions. Never use `/tmp` directly or create files in the project root.

```bash
# ✅ CORRECT: Use test framework functions (automatically uses container's tmp/)
temp_dir=$(_tf_create_temp_dir)              # Creates in container's tmp/
temp_file=$(_tf_create_temp_file)            # Creates in container's tmp/
temp_file=$(_tf_create_temp_file ".json")    # With specific extension

# ✅ CORRECT: For manual paths, use _tf_test_container_tmpdir()
local tmp_base=$(_tf_test_container_tmpdir)  # Get container's tmp directory
local custom_file="$tmp_base/my_test_file.txt"
echo "test data" > "$custom_file"

# ❌ WRONG: Never use /tmp directly
local bad_file="/tmp/test_file.txt"          # DON'T DO THIS!

# ❌ WRONG: Never create files without full paths
echo "data" > "output.txt"                   # Creates in unpredictable location!

# IMPORTANT: NO manual cleanup needed in _tf_teardown()!
_tf_teardown() {
    # DON'T clean up temp files - prevents debugging and is unnecessary
    # The test launcher automatically cleans the entire container
    
    # Only unset variables to prevent pollution
    unset temp_dir temp_file
    
    # ❌ WRONG: Manual cleanup interferes with debugging
    # _tf_cleanup_temp "$temp_dir"    # DON'T DO THIS!
    # rm -f "$temp_file"              # DON'T DO THIS!
}
```

**Why use container's tmp directory without manual cleanup?**
- Complete isolation between test runs
- **Automatic cleanup** when test container is destroyed
- **Debugging friendly** - files remain for inspection after test failure
- No pollution of system /tmp
- Predictable location for debugging and inspection

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

### Setup and Teardown (Current Best Practices)
```bash
# Setup: Create test data (NOT global variables)
_tf_setup() {
    # Use fixtures for consistent DOH project structure
    _tff_create_minimal_doh_project >/dev/null
    
    # Create test data in DOH structure (not temp directories)
    local doh_dir=$(doh_project_dir)
    mkdir -p "$doh_dir/epics/test-epic"
    cat > "$doh_dir/epics/test-epic/001.md" <<'EOF'
---
task_number: "001"
name: Test Task
status: completed
---
# Test Task
EOF
}

# Teardown: NO manual cleanup recommended
_tf_teardown() {
    # IMPORTANT: NO manual cleanup needed when using container's tmp directory!
    # The test launcher automatically cleans up the entire container after tests.
    # Manual cleanup can interfere with debugging - leave files for inspection.
    
    # No global variables to unset - each test uses local variables
    # This is the best practice for test isolation
    :  # No-op - just comments explaining why we don't clean up
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

**CRITICAL: Follow the patterns in `tests/template/test_best_patterns.sh` - it demonstrates all current best practices with extensive comments.**

1. **Source libraries directly**: ALWAYS source DOH libraries in tests, NEVER use api.sh/helper.sh wrappers (10x faster)
2. **Keep tests self-contained**: Use local variables ONLY, NO global variables (improves isolation and clarity)
3. **Keep tests fast**: Unit tests should run in < 1 second (direct library calls help achieve this)
4. **Test behavior, not implementation**: Focus on what functions do, not how they do it
5. **Use descriptive names**: Test names should explain what is being tested
6. **NO manual cleanup**: Container handles temp file cleanup automatically (manual cleanup prevents debugging)
7. **Mock external dependencies**: Don't rely on network, external services, or system state
8. **Test edge cases**: Empty inputs, boundary conditions, error paths
9. **One assertion per test concept**: Makes failures easier to diagnose
10. **Test files don't need executable permissions**: Test files are sourced by the test launcher, not executed directly
11. **Always use absolute file paths**: Never create files without full paths to avoid artifacts in project root
12. **Use container temp directory**: Always use `_tf_test_container_tmpdir()` for temporary files, never `/tmp` directly
13. **Call DOH path functions when needed**: Use `doh_project_dir()` in tests, don't store in globals

### Library Sourcing Rules for Tests

**MANDATORY: Source DOH libraries directly in all tests:**

```bash
# ✅ CORRECT: Source libraries at the top of test files
source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/version.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/task.sh"

# Then test functions directly
_tf_assert "Should work" version_validate "1.0.0"

# ❌ WRONG: Using wrapper scripts (except when testing the wrappers themselves)
_tf_assert "Slow!" ./.claude/scripts/doh/api.sh version validate "1.0.0"
```

**Exceptions:**
- Only use `api.sh` or `helper.sh` in tests specifically designed to test those wrapper scripts
- Examples: `test_helper_prd.sh`, `test_api_wrapper.sh`

### Test Variable Scope Best Practices

**MANDATORY: Keep all test variables local for proper isolation:**

```bash
# ✅ CORRECT: Self-contained test with local variables
test_good_example() {
    # All variables are local to this test
    local tmp_base=$(_tf_test_container_tmpdir)
    local test_file="$tmp_base/test_${RANDOM}.txt"
    local doh_dir=$(doh_project_dir)
    
    echo "test data" > "$test_file"
    _tf_assert_file_exists "File should exist" "$test_file"
}

# ❌ WRONG: Using global variables
TEST_FILE="/tmp/shared.txt"  # DON'T DO THIS!

test_bad_example() {
    echo "data" > "$TEST_FILE"  # Hidden dependency on global
    _tf_assert_file_exists "File exists" "$TEST_FILE"
}
```

**Why avoid global variables in tests:**
- **Hidden dependencies**: Tests become coupled and order-dependent
- **Reduced clarity**: Not clear what each test needs
- **Harder debugging**: State leaks between tests
- **Poor isolation**: Tests can interfere with each other
- **Maintenance issues**: Changes affect multiple tests unexpectedly

### File Path Best Practices

**❌ WRONG - Creates artifacts in project root:**
```bash
# These create files in the current directory!
frontmatter_create_markdown "content" "test data"
echo "test" > "output.txt"  
some_command "filename.md"
```

**❌ WRONG - Uses system /tmp directly:**
```bash
# Don't use /tmp directly - breaks test isolation!
local test_file="/tmp/test_${RANDOM}.md"
echo "test" > "$test_file"
```

**✅ CORRECT - Use test framework functions:**
```bash
# Use test framework temp functions (creates in container's tmp/)
local temp_file=$(_tf_create_temp_file ".md")
frontmatter_create_markdown "$temp_file" "test data"

# For custom paths, use container's tmp directory
local tmp_base=$(_tf_test_container_tmpdir)
local test_file="$tmp_base/test_${RANDOM}.md"
echo "test" > "$test_file"

# For DOH project testing, use proper paths
local doh_dir=$(doh_project_dir)
local project_file="$doh_dir/test_file.md"
some_command "$project_file"
```

**Key Rules:**
- Never use filenames without directory paths (`"content"`, `"output.txt"`)
- Never use `/tmp` directly - always use `_tf_test_container_tmpdir()` or `_tf_create_temp_*` functions
- Always use absolute paths from framework functions
- Clean up temporary files in `_tf_teardown()` if needed (though container cleanup handles this)
- Use `$(_tf_create_temp_dir)` for temporary directories (automatically in container's tmp/)

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

# DEBUGGING TIP: Inspect temp files after test failure
# Since tests don't clean up temp files, you can examine them:
# 1. Run failing test: ./tests/test_launcher.sh tests/unit/failing_test.sh
# 2. Note container path in error message: /tmp/doh.XXXXXX/
# 3. Examine files: ls -la /tmp/doh.XXXXXX/tmp/
# 4. Container auto-cleanup happens later, preserving debug files
```

## Contributing

When adding new tests:

1. Place unit tests in `tests/unit/`
2. Place integration tests in `tests/integration/`
3. Follow naming convention: `test_<component>.sh`
4. Include file version header
5. Add appropriate documentation
6. Test both success and failure paths

## Further Reading

For more information, see:

**ESSENTIAL:**
- **RECOMMENDED STARTING POINT**: Best practices template: `tests/template/test_best_patterns.sh`
- **Run to see current patterns**: `./tests/run.sh tests/template/test_best_patterns.sh --verbose`
- **Copy for new tests**: `cp tests/template/test_best_patterns.sh tests/unit/test_my_feature.sh`

**REFERENCE (legacy patterns - prefer best_patterns.sh):**
- Basic template: `tests/template/test_simple.sh` 
- Comprehensive template: `tests/template/test_example.sh`
- Self-test example: `tests/unit/test_framework_self_test.sh`

**DOCUMENTATION:**
- [DOH Test-Inspired Development Guide](../docs/doh-tdd.md)
- [General TDD Rules](../rules/tdd.md)
- [DOH Project Documentation](../README.md)

**REMEMBER**: Always start with the best practices template - it contains the most current patterns with extensive explanatory comments.
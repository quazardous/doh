#!/bin/bash
# DOH Lightweight Test Framework
# A minimal bash testing framework with TAP-like output
# File version: 0.1.0
# Created: 2025-09-01 (Task 016)

# Global test state
declare -g _TF_TEST_COUNT=0
declare -g _TF_TEST_PASSED=0
declare -g _TF_TEST_FAILED=0
declare -g _TF_TEST_CURRENT=""
# Function execution state
declare -g _TF_FUNCTION_COUNT=0
declare -g _TF_FUNCTION_PASSED=0
declare -g _TF_FUNCTION_FAILED=0

# Check VERBOSE flag - defaults to true for compatibility
_TF_VERBOSE="${VERBOSE:-true}"

# Logging functions controlled by VERBOSE flag
_tf_log() {
    if [[ "$_TF_VERBOSE" == "true" ]]; then
        echo "$@"
    fi
}

_tf_debug() {
    if [[ "$_TF_VERBOSE" == "true" ]]; then
        echo "DEBUG: $*" >&2
    fi
}


# Colors for output (only if terminal supports it)
if [[ -t 1 ]]; then
    _TF_RED='\033[0;31m'
    _TF_GREEN='\033[0;32m'
    _TF_YELLOW='\033[1;33m'
    _TF_BLUE='\033[0;34m'
    _TF_NC='\033[0m' # No Color
else
    _TF_RED=''
    _TF_GREEN=''
    _TF_YELLOW=''
    _TF_BLUE=''
    _TF_NC=''
fi

# Initialize test suite
_tf_test_suite_start() {
    local suite_name="${1:-Test Suite}"
    echo "# Starting $suite_name"  # TAP output - always show
    _TF_TEST_COUNT=0
    _TF_TEST_PASSED=0
    _TF_TEST_FAILED=0
    _TF_FUNCTION_COUNT=0
    _TF_FUNCTION_PASSED=0
    _TF_FUNCTION_FAILED=0
}

# Finalize test suite
_tf_test_suite_end() {
    # Only output TAP format if we have actual test counts
    if [[ $_TF_TEST_COUNT -gt 0 ]]; then
        echo "1..$_TF_TEST_COUNT"
        echo "# Passed: $_TF_TEST_PASSED/$_TF_TEST_COUNT"
        echo "# Failed: $_TF_TEST_FAILED/$_TF_TEST_COUNT"
        echo "# Functions: $_TF_FUNCTION_PASSED/$_TF_FUNCTION_COUNT"
        
        if [[ $_TF_TEST_FAILED -gt 0 || $_TF_FUNCTION_FAILED -gt 0 ]]; then
            echo -e "# ${_TF_RED}FAILURE${_TF_NC}: $_TF_TEST_FAILED test(s) failed, $_TF_FUNCTION_FAILED function(s) failed"
            return 1
        else
            echo -e "# ${_TF_GREEN}SUCCESS${_TF_NC}: All tests passed"
            return 0
        fi
    else
        # No tests ran
        echo "1..0"
        echo "# Passed: 0/0"
        echo "# Failed: 0/0"
        echo "# Functions: 0/0"
        echo -e "# ${_TF_GREEN}SUCCESS${_TF_NC}: All tests passed"
        return 0
    fi
}

# Internal function to report test result
_tf_test_result() {
    local status="$1"
    local description="$2"
    local diagnostic="${3:-}"
    
    ((_TF_TEST_COUNT++))
    
    if [[ "$status" == "passed" ]]; then
        ((_TF_TEST_PASSED++))
        echo -e "${_TF_GREEN}ok${_TF_NC} $_TF_TEST_COUNT - $description"
    else
        ((_TF_TEST_FAILED++))
        echo -e "${_TF_RED}not ok${_TF_NC} $_TF_TEST_COUNT - $description"
        if [[ -n "$diagnostic" ]]; then
            echo "  ---"
            echo "  message: '$diagnostic'"
            echo "  ..."
        fi
    fi
}

# Core assertion functions

# Assert that two values are equal
# @param $1 Test description message
# @param $2 Expected value
# @param $3 Actual value
_tf_assert_equals() {
    local message="$1"
    local expected="$2"
    local actual="$3"
    
    if [[ "$expected" == "$actual" ]]; then
        _tf_test_result "passed" "$message"
    else
        _tf_test_result "failed" "$message" "Expected '$expected', got '$actual'"
    fi
}

# Assert that two values are not equal
# @param $1 Test description message
# @param $2 Expected value (should be different)
# @param $3 Actual value
_tf_assert_not_equals() {
    local message="$1"
    local expected="$2"
    local actual="$3"
    
    if [[ "$expected" != "$actual" ]]; then
        _tf_test_result "passed" "$message"
    else
        _tf_test_result "failed" "$message" "Expected '$expected' to be different from '$actual'"
    fi
}

# Assert that a condition is true
# @param $1 Test description message  
# @param $2 Condition value (should be "true" or "0")
_tf_assert_true() {
    local message="$1"
    local condition="$2"
    
    if [[ "$condition" == "true" ]] || [[ "$condition" == "0" ]]; then
        _tf_test_result "passed" "$message"
    else
        _tf_test_result "failed" "$message" "Expected true, got '$condition'"
    fi
}

# Assert that a command executes successfully
# @param $1 Test description message
# @param $@ Command and arguments to execute
# @exitcode 0 If command succeeds, adds passing test
# @exitcode 0 If command fails, adds failing test but doesn't exit
_tf_assert() {
    local message="$1"
    shift
    
    if ("$@") &>/dev/null; then
        _tf_test_result "passed" "$message"
    else
        local exit_code=$?
        _tf_test_result "failed" "$message" "Command failed with exit code $exit_code: $*"
    fi
}

# Assert that a command fails to execute successfully  
# @param $1 Test description message
# @param $@ Command and arguments to execute
# @exitcode 0 If command fails, adds passing test
# @exitcode 0 If command succeeds, adds failing test but doesn't exit
_tf_assert_not() {
    local message="$1"
    shift
    
    if ! ("$@") &>/dev/null; then
        _tf_test_result "passed" "$message"
    else
        _tf_test_result "failed" "$message" "Command succeeded but was expected to fail: $*"
    fi
}

# Assert that a condition is false
# @param $1 Test description message
# @param $2 Condition value (should be "false" or not "0"/"true")
_tf_assert_false() {
    local message="$1"
    local condition="$2"
    
    if [[ "$condition" == "false" ]] || [[ "$condition" != "0" && "$condition" != "true" ]]; then
        _tf_test_result "passed" "$message"
    else
        _tf_test_result "failed" "$message" "Expected false, got '$condition'"
    fi
}

# Assert that a string contains a substring
# @param $1 Test description message
# @param $2 String to search in (haystack)
# @param $3 Substring to search for (needle)
_tf_assert_contains() {
    local message="$1"
    local haystack="$2"
    local needle="$3"
    
    if [[ "$haystack" =~ $needle ]]; then
        _tf_test_result "passed" "$message"
    else
        _tf_test_result "failed" "$message" "'$haystack' does not contain '$needle'"
    fi
}

# Assert that a string does not contain a substring
# @param $1 Test description message
# @param $2 String to search in (haystack)
# @param $3 Substring that should not be found (needle)
_tf_assert_not_contains() {
    local message="$1"
    local haystack="$2"
    local needle="$3"
    
    if [[ ! "$haystack" =~ $needle ]]; then
        _tf_test_result "passed" "$message"
    else
        _tf_test_result "failed" "$message" "'$haystack' should not contain '$needle'"
    fi
}

# Assert that a file exists
# @param $1 Test description message
# @param $2 Path to file that should exist
_tf_assert_file_exists() {
    local message="$1"
    local file="$2"
    
    if [[ -f "$file" ]]; then
        _tf_test_result "passed" "$message"
    else
        _tf_test_result "failed" "$message" "File '$file' does not exist"
    fi
}

# Assert that a file contains specific content
# @param $1 Test description message
# @param $2 Path to file to check
# @param $3 Content that should be present in the file
_tf_assert_file_contains() {
    local message="$1"
    local file="$2"
    local content="$3"
    
    if [[ ! -f "$file" ]]; then
        _tf_test_result "failed" "$message" "File '$file' does not exist"
        return
    fi
    
    if grep -q -- "$content" "$file"; then
        _tf_test_result "passed" "$message"
    else
        _tf_test_result "failed" "$message" "File '$file' does not contain '$content'"
    fi
}



# Test discovery and execution
_tf_run_test_function() {
    local test_function="$1"
    local function_start_failures=$_TF_TEST_FAILED
    
    # Setup if function exists
    if declare -f _tf_setup >/dev/null; then
        _tf_setup
    fi
    
    # Run the test
    _TF_TEST_CURRENT="$test_function"
    "$test_function"
    
    # Count this function and check if it passed
    ((_TF_FUNCTION_COUNT++))
    if [[ $_TF_TEST_FAILED -eq $function_start_failures ]]; then
        ((_TF_FUNCTION_PASSED++))
    else
        ((_TF_FUNCTION_FAILED++))
    fi
    
    # Teardown if function exists
    if declare -f _tf_teardown >/dev/null; then
        _tf_teardown
    fi
}

_tf_run_test_file() {
    local test_file="$1"
    
    if [[ ! -f "$test_file" ]]; then
        echo "Error: Test file '$test_file' not found"
        return 1
    fi
    
    # Enforce test execution through launcher
    if [[ "${_TF_LAUNCHER_EXECUTION:-}" != "true" ]]; then
        echo "Error: Tests must be run through the test launcher" >&2
        echo "Usage: ./tests/test_launcher.sh $test_file" >&2
        echo "   or: ./tests/run.sh $test_file" >&2
        return 1
    fi
    
    # Prevent recursion by setting a flag
    if [[ "${_TF_DOH_TEST_RUNNING:-}" == "true" ]]; then
        return 0
    fi
    
    export _TF_DOH_TEST_RUNNING="true"
    
    # Source the test file
    source "$test_file"
    
    # Find all test functions
    local test_functions=($(declare -F | grep "^declare -f test_" | awk '{print $3}'))
    
    if [[ ${#test_functions[@]} -eq 0 ]]; then
        echo "Warning: No test functions found in '$test_file'"
        return 0
    fi
    
    _tf_test_suite_start "$(basename "$test_file")"
    
    # Run each test function
    for test_func in "${test_functions[@]}"; do
        _tf_run_test_function "$test_func"
    done
    
    _tf_test_suite_end
    local exit_code=$?
    
    # Clear the running flag
    unset _TF_DOH_TEST_RUNNING
    
    return $exit_code
}

# Get the temporary directory within the test container
# @stdout Path to the temporary directory within the test container
# @exitcode 0 If successful
# @exitcode 1 If container directory is not available
_tf_test_container_tmpdir() {
    local container_dir=$(_tf_test_container_dir) || return 1
    local temp_dir="$container_dir/tmp"
    mkdir -p "$temp_dir" || return 1
    echo "$temp_dir"
}

# Utility functions for test setup

# Create a temporary directory in the test container
# @param $1 Pattern prefix (optional, defaults to "doh_test")
# @stdout Path to the created temporary directory
# @exitcode 0 If successful
# @exitcode 1 If container directory is not available
_tf_create_temp_dir() {
    local pattern="${1:-doh_test}_XXXXXX"
    local temp_dir=$(_tf_test_container_tmpdir) || return 1
    mktemp -d -t "$pattern" -p "$temp_dir"
}

# Create a temporary file in the test container
# @param $1 File extension (optional)
# @param $2 Pattern prefix (optional, defaults to "doh_test")
# @stdout Path to the created temporary file
# @exitcode 0 If successful
# @exitcode 1 If container directory is not available
_tf_create_temp_file() {
    local temp_dir=$(_tf_test_container_tmpdir) || return 1
    local extension="${1:-}"
    local pattern="${2:-doh_test}_XXXXXX"
    if [[ -n "$extension" ]]; then
        pattern="${pattern}${extension}"
    fi
    mktemp -t "$pattern" -p "$temp_dir"
}

# Get the DOH test container directory
# @stdout Path to the test container directory (DOH_TEST_CONTAINER_DIR)
# @exitcode 0 If successful
# @exitcode 1 If DOH_TEST_CONTAINER_DIR is not set (test not running through launcher)
_tf_test_container_dir() {
    if [[ -n "${DOH_TEST_CONTAINER_DIR:-}" ]]; then
        echo "$DOH_TEST_CONTAINER_DIR"
        return 0
    else
        echo "Error: DOH_TEST_CONTAINER_DIR not set - test must run through test launcher" >&2
        return 1
    fi
}

# Mock function support
# Replace a function with a mock implementation for the duration of a command
# @param $1 Name of the function to mock
# @param $2 Name of the mock function
# @param $@ Command to run with the mock in place
# @exitcode Exit code of the executed command
_tf_with_mock() {
    local original_func="$1"
    local mock_func="$2"
    shift 2
    
    # Save original function if it exists
    if declare -f "$original_func" >/dev/null; then
        eval "original_${original_func}() $(declare -f "$original_func" | tail -n +2)"
    fi
    
    # Replace with mock
    eval "$original_func() { $mock_func \"\$@\"; }"
    
    # Run the command
    "$@"
    local result=$?
    
    # Restore original function
    if declare -f "original_${original_func}" >/dev/null; then
        eval "$original_func() $(declare -f "original_${original_func}" | tail -n +2)"
        unset -f "original_${original_func}"
    else
        unset -f "$original_func"
    fi
    
    return $result
}

# Logging functions for test verbosity and debugging
# These respect VERBOSE and QUIET environment variables
_tf_log_info() {
    if [[ "${QUIET:-false}" != "true" ]]; then
        echo -e "${_TF_BLUE:-}[INFO]${_TF_NC:-} $*"
    fi
}

_tf_log_success() {
    if [[ "${QUIET:-false}" != "true" ]]; then
        echo -e "${_TF_GREEN:-}[SUCCESS]${_TF_NC:-} $*"
    fi
}

_tf_log_error() {
    echo -e "${_TF_RED:-}[ERROR]${_TF_NC:-} $*" >&2
}

_tf_log_warn() {
    if [[ "${QUIET:-false}" != "true" ]]; then
        echo -e "${_TF_YELLOW:-}[WARN]${_TF_NC:-} $*"
    fi
}

_tf_log_debug() {
    if [[ "${VERBOSE:-false}" == "true" ]]; then
        echo -e "${_TF_YELLOW:-}[DEBUG]${_TF_NC:-} $*" >&2
    fi
}

_tf_log_trace() {
    if [[ "${DOH_TEST_DEBUG:-false}" == "true" ]]; then
        echo -e "${_TF_YELLOW:-}[TRACE]${_TF_NC:-} $*" >&2
    fi
}

# Helper function to show error when test is directly executed
# Shows usage instructions for proper test execution
# @exitcode 1 Always exits with error code
_tf_direct_execution_error() {
    echo "Error: This test file cannot be executed directly" >&2
    echo "" >&2
    echo "Please use one of the following methods to run tests:" >&2
    echo "  ./tests/test_launcher.sh $0" >&2
    echo "  ./tests/run.sh $0" >&2
    echo "  ./tests/run.sh --suite unit" >&2
    echo "  ./tests/run.sh --pattern $(basename "$0" .sh)" >&2
    echo "" >&2
    echo "For more information, see tests/README.md" >&2
    exit 1
}

# Export functions if sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    export -f _tf_test_suite_start _tf_test_suite_end
    export -f _tf_assert_equals _tf_assert_not_equals _tf_assert_true _tf_assert_false _tf_assert _tf_assert_not
    export -f _tf_assert_contains _tf_assert_not_contains _tf_assert_file_exists _tf_assert_file_contains
    export -f _tf_run_test_function _tf_run_test_file
    export -f _tf_create_temp_dir _tf_create_temp_file _tf_test_container_dir _tf_test_container_tmpdir _tf_with_mock
    export -f _tf_log_info _tf_log_success _tf_log_error _tf_log_warn _tf_log_debug _tf_log_trace
    export -f _tf_direct_execution_error
fi
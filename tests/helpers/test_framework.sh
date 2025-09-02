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
    echo "# Starting $suite_name"
    _TF_TEST_COUNT=0
    _TF_TEST_PASSED=0
    _TF_TEST_FAILED=0
}

# Finalize test suite
_tf_test_suite_end() {
    echo "1..$_TF_TEST_COUNT"
    echo "# Passed: $_TF_TEST_PASSED/$_TF_TEST_COUNT"
    echo "# Failed: $_TF_TEST_FAILED/$_TF_TEST_COUNT"
    
    if [[ $_TF_TEST_FAILED -gt 0 ]]; then
        echo -e "# ${_TF_RED}FAILURE${_TF_NC}: $_TF_TEST_FAILED test(s) failed"
        return 1
    else
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
    
    if [[ "$status" == "ok" ]]; then
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
_tf_assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Values should be equal}"
    
    if [[ "$expected" == "$actual" ]]; then
        _tf_test_result "ok" "$message"
    else
        _tf_test_result "not ok" "$message" "Expected '$expected', got '$actual'"
    fi
}

_tf_assert_not_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Values should not be equal}"
    
    if [[ "$expected" != "$actual" ]]; then
        _tf_test_result "ok" "$message"
    else
        _tf_test_result "not ok" "$message" "Expected '$expected' to be different from '$actual'"
    fi
}

_tf_assert_true() {
    local condition="$1"
    local message="${2:-Condition should be true}"
    
    if [[ "$condition" == "true" ]] || [[ "$condition" == "0" ]]; then
        _tf_test_result "ok" "$message"
    else
        _tf_test_result "not ok" "$message" "Expected true, got '$condition'"
    fi
}

_tf_assert_false() {
    local condition="$1"
    local message="${2:-Condition should be false}"
    
    if [[ "$condition" == "false" ]] || [[ "$condition" != "0" && "$condition" != "true" ]]; then
        _tf_test_result "ok" "$message"
    else
        _tf_test_result "not ok" "$message" "Expected false, got '$condition'"
    fi
}

_tf_assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-String should contain substring}"
    
    if [[ "$haystack" =~ $needle ]]; then
        _tf_test_result "ok" "$message"
    else
        _tf_test_result "not ok" "$message" "'$haystack' does not contain '$needle'"
    fi
}

_tf_assert_file_exists() {
    local file="$1"
    local message="${2:-File should exist}"
    
    if [[ -f "$file" ]]; then
        _tf_test_result "ok" "$message"
    else
        _tf_test_result "not ok" "$message" "File '$file' does not exist"
    fi
}

_tf_assert_file_contains() {
    local file="$1"
    local content="$2"
    local message="${3:-File should contain content}"
    
    if [[ ! -f "$file" ]]; then
        _tf_test_result "not ok" "$message" "File '$file' does not exist"
        return
    fi
    
    if grep -q "$content" "$file"; then
        _tf_test_result "ok" "$message"
    else
        _tf_test_result "not ok" "$message" "File '$file' does not contain '$content'"
    fi
}

_tf_assert_command_succeeds() {
    local cmd="$1"
    local message="${2:-Command should succeed}"
    
    if (eval "$cmd") &>/dev/null; then
        _tf_test_result "ok" "$message"
    else
        local exit_code=$?
        _tf_test_result "not ok" "$message" "Command '$cmd' failed with exit code $exit_code"
    fi
}

_tf_assert_command_fails() {
    local cmd="$1"
    local message="${2:-Command should fail}"
    
    if ! (eval "$cmd") &>/dev/null; then
        _tf_test_result "ok" "$message"
    else
        _tf_test_result "not ok" "$message" "Command '$cmd' succeeded but was expected to fail"
    fi
}

# Test discovery and execution
_tf_run_test_function() {
    local test_function="$1"
    
    # Setup if function exists
    if declare -f _tf_setup >/dev/null; then
        _tf_setup
    fi
    
    # Run the test
    _TF_TEST_CURRENT="$test_function"
    "$test_function"
    
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

# Utility functions for test setup
_tf_create_temp_dir() {
    mktemp -d -t doh_test_XXXXXX
}

_tf_create_temp_file() {
    local extension="${1:-}"
    local temp_file=$(mktemp -t doh_test_XXXXXX)
    
    if [[ -n "$extension" ]]; then
        local new_file="${temp_file}${extension}"
        mv "$temp_file" "$new_file"
        echo "$new_file"
    else
        echo "$temp_file"
    fi
}

_tf_cleanup_temp() {
    local path="$1"
    if [[ -n "$path" && "$path" =~ /tmp.*doh_test ]]; then
        rm -rf "$path"
    fi
}

# Mock function support
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
    export -f _tf_assert_equals _tf_assert_not_equals _tf_assert_true _tf_assert_false
    export -f _tf_assert_contains _tf_assert_file_exists _tf_assert_file_contains
    export -f _tf_assert_command_succeeds _tf_assert_command_fails
    export -f _tf_run_test_function _tf_run_test_file
    export -f _tf_create_temp_dir _tf_create_temp_file _tf_cleanup_temp _tf_with_mock
    export -f _tf_log_info _tf_log_success _tf_log_error _tf_log_warn _tf_log_debug _tf_log_trace
    export -f _tf_direct_execution_error
fi
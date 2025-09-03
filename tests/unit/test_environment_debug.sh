#!/bin/bash
# Simple environment debug test
# File version: 0.1.0 | Created: 2025-09-02

# Source the framework
source "$(dirname "$0")/../helpers/test_framework.sh" 2>/dev/null || source "../helpers/test_framework.sh" 2>/dev/null || source "tests/helpers/test_framework.sh"

# Test environment variable visibility
test_environment_variables() {
    echo "=== ENVIRONMENT DEBUG ==="
    echo "GLOBAL_DOH_DIR: ${GLOBAL_DOH_DIR:-<not set>}"
    echo "DOH_TEST_CLEANUP_DIR: ${DOH_TEST_CLEANUP_DIR:-<not set>}"
    echo "_TF_LAUNCHER_EXECUTION: ${_TF_LAUNCHER_EXECUTION:-<not set>}"
    echo "HOME: $HOME"
    echo "PWD: $PWD"
    echo "=========================="
    
    _tf_assert_true 0 "Environment debug output shown"
}

test_doh_global_dir_set() {
    _tf_assert_not_equals "" "${GLOBAL_DOH_DIR:-}" "GLOBAL_DOH_DIR should be set"
    _tf_assert_contains "$GLOBAL_DOH_DIR" "/tmp" "GLOBAL_DOH_DIR should be a temp directory"
}

test_isolation_directory_exists() {
    # DOH libraries should create directories as needed
    # This test ensures the path is set correctly
    _tf_assert_not_equals "" "${GLOBAL_DOH_DIR:-}" "Isolation directory path should be set"
}

test_can_write_to_isolation_dir() {
    # Create the directory first (simulating what DOH libraries would do)
    mkdir -p "$GLOBAL_DOH_DIR"
    
    local test_file="$GLOBAL_DOH_DIR/test_write.txt"
    echo "test content" > "$test_file"
    _tf_assert_file_exists "$test_file" "Should be able to write to isolation directory"
    _tf_assert_file_contains "$test_file" "test content" "File should contain test content"
}

test_isolation_vs_real_doh() {
    local real_doh_dir="$HOME/.doh"
    _tf_assert_not_equals "$GLOBAL_DOH_DIR" "$real_doh_dir" "Isolation dir should not be real ~/.doh"
}

# Run tests
_tf_test_suite_start "Environment Debug Tests"

test_environment_variables
test_doh_global_dir_set
test_isolation_directory_exists
test_can_write_to_isolation_dir
test_isolation_vs_real_doh

_tf_test_suite_end
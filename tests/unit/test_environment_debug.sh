#!/bin/bash
# Simple environment debug test
# File version: 0.1.0 | Created: 2025-09-02

# Source the framework
source "$(dirname "$0")/../helpers/test_framework.sh" 2>/dev/null || source "../helpers/test_framework.sh" 2>/dev/null || source "tests/helpers/test_framework.sh"

# Test environment variable visibility
test_environment_variables() {
    _tf_log "=== ENVIRONMENT DEBUG ==="
    _tf_log "DOH_GLOBAL_DIR: ${DOH_GLOBAL_DIR:-<not set>}"
    _tf_log "DOH_TEST_CONTAINER_DIR: ${DOH_TEST_CONTAINER_DIR:-<not set>}"
    _tf_log "HOME: $HOME"
    _tf_log "PWD: $PWD"
    _tf_log "=========================="
    
    _tf_assert_true "Environment debug output shown" 0
}

test_doh_global_dir_set() {
    _tf_assert_not_equals "DOH_GLOBAL_DIR should be set" "${DOH_GLOBAL_DIR:-}" ""
    _tf_assert_contains "DOH_GLOBAL_DIR should be a temp directory" "$DOH_GLOBAL_DIR" "/tmp"
}

test_isolation_directory_exists() {
    # DOH libraries should create directories as needed
    # This test ensures the path is set correctly
    _tf_assert_not_equals "Isolation directory path should be set" "" "${DOH_GLOBAL_DIR:-}"
}

test_can_write_to_isolation_dir() {
    # Create the directory first (simulating what DOH libraries would do)
    mkdir -p "$DOH_GLOBAL_DIR"
    
    local test_file="$DOH_GLOBAL_DIR/test_write.txt"
    echo "test content" > "$test_file"
    _tf_assert_file_exists "Should be able to write to isolation directory" "$test_file"
    _tf_assert_file_contains "File should contain test content" "$test_file" "test content"
}

test_isolation_vs_real_doh() {
    local real_doh_dir="$HOME/.doh"
    _tf_assert_not_equals "Isolation dir should not be real ~/.doh" "$DOH_GLOBAL_DIR" "$real_doh_dir"
}

# Run tests
_tf_test_suite_start "Environment Debug Tests"

test_environment_variables
test_doh_global_dir_set
test_isolation_directory_exists
test_can_write_to_isolation_dir
test_isolation_vs_real_doh

_tf_test_suite_end
# Run tests if script executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi

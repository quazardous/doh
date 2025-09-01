#!/bin/bash
# Basic demonstration test for DOH test framework
# File version: 0.1.0 | Created: 2025-09-01

# Source the framework
source "$(dirname "$0")/../helpers/test_framework.sh" 2>/dev/null || source "../helpers/test_framework.sh" 2>/dev/null || source "tests/helpers/test_framework.sh"

# Simple test functions
test_basic_equality() {
    _tf_assert_equals "hello" "hello" "String equality should work"
}

test_basic_boolean() {
    _tf_assert_true "true" "Boolean true should work"
    _tf_assert_false "false" "Boolean false should work"
}

test_file_operations() {
    local temp_file=$(_tf_create_temp_file)
    echo "test content" > "$temp_file"
    
    _tf_assert_file_exists "$temp_file" "Temp file should exist"
    _tf_assert_file_contains "$temp_file" "test content" "File should contain test content"
    
    _tf_cleanup_temp "$temp_file"
}

test_command_assertions() {
    _tf_assert_command_succeeds "echo 'success'" "Echo should succeed"
    _tf_assert_command_fails "exit 1" "Exit 1 should fail"
}

# Run tests if script executed directly (not when sourced by test runner)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
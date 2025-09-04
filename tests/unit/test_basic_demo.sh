#!/bin/bash
# Basic demonstration test for DOH test framework
# File version: 0.1.0 | Created: 2025-09-01

# Source the framework
source "$(dirname "$0")/../helpers/test_framework.sh" 2>/dev/null || source "../helpers/test_framework.sh" 2>/dev/null || source "tests/helpers/test_framework.sh"

# Simple test functions
test_basic_equality() {
    _tf_assert_equals "String equality should work" "hello" "hello"
}

test_basic_boolean() {
    _tf_assert_true "Boolean true should work" true
    _tf_assert_false "Boolean false should work" false
}

test_file_operations() {
    local temp_file=$(_tf_create_temp_file)
    echo "test content" > "$temp_file"
    
    _tf_assert_file_exists "Temp file should exist" "$temp_file"
    _tf_assert_file_contains "File should contain test content" "$temp_file" "test content"
    
}

test_command_assertions() {
    _tf_assert "Echo should succeed" echo 'success'
    _tf_assert_not "Exit 1 should fail" bash -c 'exit 1'
}

# Run tests if script executed directly (not when sourced by test runner)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
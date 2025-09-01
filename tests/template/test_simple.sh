#!/bin/bash
# Simple Test Template
# Basic template for writing tests with the DOH test framework
# File version: 0.1.0 | Created: 2025-09-01

# Source the test framework (required)
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"

# Optional: Setup function (called before each test)
_tf_setup() {
    # Initialize test environment
    TEST_DATA="sample data"
    TEMP_FILE=$(_tf_create_temp_file)
    echo "test content" > "$TEMP_FILE"
}

# Optional: Teardown function (called after each test) 
_tf_teardown() {
    # Clean up test environment
    _tf_cleanup_temp "$TEMP_FILE"
    unset TEST_DATA TEMP_FILE
}

# Test functions must start with "test_"
test_basic_assertions() {
    # String equality
    _tf_assert_equals "hello" "hello" "Strings should match"
    _tf_assert_not_equals "hello" "world" "Different strings"
    
    # Boolean assertions
    _tf_assert_true "true" "Should be true"
    _tf_assert_false "false" "Should be false"
}

test_string_operations() {
    # String contains
    _tf_assert_contains "hello world" "world" "Should contain substring"
    _tf_assert_contains "$TEST_DATA" "sample" "Should contain test data"
}

test_file_operations() {
    # File assertions
    _tf_assert_file_exists "$TEMP_FILE" "Temp file should exist"
    _tf_assert_file_contains "$TEMP_FILE" "test content" "File should have content"
}

test_command_execution() {
    # Command success/failure
    _tf_assert_command_succeeds "echo 'success'" "Echo should work"
    _tf_assert_command_fails "false" "False command should fail"
}

# Required: Run tests when script executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
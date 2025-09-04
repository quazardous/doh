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
    unset TEST_DATA TEMP_FILE
}

# Test functions must start with "test_"
test_basic_assertions() {
    # String equality - message-first pattern
    _tf_assert_equals "Strings should match" "hello" "hello"
    _tf_assert_not_equals "Different strings" "world" "hello"
    
    # Boolean assertions - message-first pattern
    _tf_assert_true "Should be true" "true"
    _tf_assert_false "Should be false" "false"
}

test_string_operations() {
    # String contains - message-first pattern
    _tf_assert_contains "Should contain substring" "hello world" "world"
    _tf_assert_contains "Should contain test data" "$TEST_DATA" "sample"
}

test_file_operations() {
    # File assertions - message-first pattern
    _tf_assert_file_exists "Temp file should exist" "$TEMP_FILE"
    _tf_assert_file_contains "File should have content" "$TEMP_FILE" "test content"
}

test_command_execution() {
    # Command success/failure - message-first pattern (already correct)
    _tf_assert "Echo should work" echo 'success'
    _tf_assert_not "False command should fail" false
}

# Required: Run tests when script executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi

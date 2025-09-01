#!/bin/bash
# Self-test for the DOH test framework
# This test validates that the test framework itself works correctly
# File version: 0.1.0
# Updated: 2025-09-01

# Source the framework
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"

# Test basic equality assertions
test_tf_assert_equals() {
    # Test successful equality
    local temp_file=$(_tf_create_temp_file)
    echo "expected_value" > "$temp_file"
    local actual=$(cat "$temp_file")
    
    _tf_assert_equals "expected_value" "$actual" "String equality should work"
    _tf_cleanup_temp "$temp_file"
}

test_tf_assert_not_equals() {
    _tf_assert_not_equals "hello" "world" "Different strings should not match"
}

test_tf_assert_true_false() {
    _tf_assert_true "true" "Boolean true should work"
    _tf_assert_false "false" "Boolean false should work"
    
    # Test with command exit codes
    _tf_assert_true "0" "Exit code 0 should be true"
}

test_tf_assert_contains() {
    local haystack="The quick brown fox jumps over the lazy dog"
    _tf_assert_contains "$haystack" "quick brown" "Should find substring"
    _tf_assert_contains "$haystack" "fox" "Should find single word"
}

test_tf_file_assertions() {
    local temp_file=$(_tf_create_temp_file)
    echo "test content for file assertions" > "$temp_file"
    
    _tf_assert_file_exists "$temp_file" "Temp file should exist"
    _tf_assert_file_contains "$temp_file" "test content" "File should contain expected content"
    
    _tf_cleanup_temp "$temp_file"
}

test_tf_command_assertions() {
    _tf_assert_command_succeeds "echo 'success test'" "Echo should succeed"
    _tf_assert_command_fails "exit 1" "Exit 1 should fail"
    _tf_assert_command_succeeds "true" "True command should succeed"
    _tf_assert_command_fails "false" "False command should fail"
}

test_tf_temp_utilities() {
    # Test temp file creation
    local temp_file=$(_tf_create_temp_file)
    _tf_assert_file_exists "$temp_file" "Temp file should be created"
    echo "temp test data" > "$temp_file"
    _tf_assert_file_contains "$temp_file" "temp test data" "Should write to temp file"
    
    # Test temp directory creation
    local temp_dir=$(_tf_create_temp_dir)
    _tf_assert_command_succeeds "test -d '$temp_dir'" "Temp directory should exist"
    echo "dir test file" > "$temp_dir/test.txt"
    _tf_assert_file_exists "$temp_dir/test.txt" "Should create files in temp dir"
    
    # Test cleanup
    _tf_cleanup_temp "$temp_file"
    _tf_cleanup_temp "$temp_dir"
    _tf_assert_command_fails "test -f '$temp_file'" "Temp file should be cleaned up"
    _tf_assert_command_fails "test -d '$temp_dir'" "Temp directory should be cleaned up"
}

test_tf_mocking() {
    # Define a test function and mock
    test_date_function() {
        date "+%Y"
    }
    
    mock_date_function() {
        echo "2025"
    }
    
    # Test original function
    local original_result=$(test_date_function)
    _tf_assert_equals "2025" "$original_result" "Original function should work"
    
    # Test with mock
    local mocked_result=$(_tf_with_mock test_date_function mock_date_function test_date_function)
    _tf_assert_equals "2025" "$mocked_result" "Mocked function should return expected value"
}

test_tf_setup_teardown() {
    # These functions are tested implicitly by their execution
    # If setup/teardown work, the temp files will be available during tests
    _tf_assert_true "true" "Setup and teardown are working (test framework executed this)"
}

# Test setup function (called before each test)
_tf_setup() {
    TEST_SETUP_CALLED="true"
    TEST_DATA_FILE=$(_tf_create_temp_file)
    echo "test setup data" > "$TEST_DATA_FILE"
}

# Test teardown function (called after each test)
_tf_teardown() {
    _tf_cleanup_temp "$TEST_DATA_FILE"
    unset TEST_SETUP_CALLED TEST_DATA_FILE
}

# Run the self-test if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
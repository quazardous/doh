#!/bin/bash
# Example Test Template
# This file demonstrates all available test framework functions and patterns
# File version: 0.1.0 | Created: 2025-09-01

# Source the test framework
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"

# ============================================================================
# SETUP AND TEARDOWN (Optional)
# ============================================================================

# Called before each test function
_tf_setup() {
    echo "  [Setup] Preparing test environment..."
    
    # Create temporary test environment
    TEMP_DIR=$(_tf_create_temp_dir)
    TEMP_FILE=$(_tf_create_temp_file)
    
    # Set up test data
    echo "sample data" > "$TEMP_FILE"
    
    # Initialize test variables
    TEST_VALUE="hello world"
    TEST_NUMBER=42
}

# Called after each test function  
_tf_teardown() {
    echo "  [Teardown] Cleaning up..."
    
    # Clean up temporary files
    _tf_cleanup_temp "$TEMP_DIR"
    _tf_cleanup_temp "$TEMP_FILE"
    
    # Reset test variables
    unset TEST_VALUE TEST_NUMBER TEMP_DIR TEMP_FILE
}

# ============================================================================
# ASSERTION FUNCTIONS
# ============================================================================

test_equality_assertions() {
    # String equality
    _tf_assert_equals "expected" "expected" "Strings should match"
    _tf_assert_equals "$TEST_VALUE" "hello world" "Variable should match expected value"
    
    # Number equality  
    _tf_assert_equals "$TEST_NUMBER" "42" "Numbers should match"
    
    # Inequality
    _tf_assert_not_equals "hello" "world" "Different strings should not match"
    _tf_assert_not_equals "$TEST_NUMBER" "0" "Number should not equal zero"
}

test_boolean_assertions() {
    # Boolean true/false
    _tf_assert_true "true" "Boolean true value"
    _tf_assert_false "false" "Boolean false value"
    
    # Command exit code as boolean (0 = success = true)
    _tf_assert_true "0" "Zero exit code should be true"
    
    # Variables as booleans
    local is_enabled="true"
    local is_disabled="false"
    _tf_assert_true "$is_enabled" "Enabled flag should be true"
    _tf_assert_false "$is_disabled" "Disabled flag should be false"
}

test_string_assertions() {
    local haystack="The quick brown fox jumps over the lazy dog"
    
    # String contains substring
    _tf_assert_contains "$haystack" "quick brown" "Should contain phrase"
    _tf_assert_contains "$haystack" "fox" "Should contain single word"
    _tf_assert_contains "$TEST_VALUE" "hello" "Should contain greeting"
    
    # Regex patterns work too
    _tf_assert_contains "$haystack" "fox.*lazy" "Should match regex pattern"
}

test_file_assertions() {
    # File existence
    _tf_assert_file_exists "$TEMP_FILE" "Temp file should exist"
    _tf_assert_file_exists "/etc/passwd" "System file should exist"
    
    # File contains content
    _tf_assert_file_contains "$TEMP_FILE" "sample data" "File should contain test data"
    
    # Create additional test file
    local config_file="$TEMP_DIR/config.txt"
    cat > "$config_file" << EOF
debug=true
port=8080
host=localhost
EOF
    
    _tf_assert_file_exists "$config_file" "Config file should be created"
    _tf_assert_file_contains "$config_file" "debug=true" "Should contain debug setting"
    _tf_assert_file_contains "$config_file" "port=8080" "Should contain port setting"
}

test_command_assertions() {
    # Commands that should succeed
    _tf_assert_command_succeeds "echo 'test'" "Echo should succeed"
    _tf_assert_command_succeeds "true" "True command should succeed"
    _tf_assert_command_succeeds "test -f '$TEMP_FILE'" "Test file existence should succeed"
    _tf_assert_command_succeeds "ls /tmp" "List tmp directory should succeed"
    
    # Commands that should fail
    _tf_assert_command_fails "false" "False command should fail"
    _tf_assert_command_fails "exit 1" "Exit 1 should fail"
    _tf_assert_command_fails "test -f /nonexistent/file" "Test nonexistent file should fail"
    _tf_assert_command_fails "ls /nonexistent/directory" "List nonexistent directory should fail"
    
    # Complex commands
    _tf_assert_command_succeeds "grep 'sample' '$TEMP_FILE'" "Grep should find content"
    _tf_assert_command_fails "grep 'missing' '$TEMP_FILE'" "Grep should not find missing content"
}

# ============================================================================
# UTILITY FUNCTIONS  
# ============================================================================

test_temp_file_utilities() {
    # Create temporary files and directories
    local temp_file1=$(_tf_create_temp_file)
    local temp_file2=$(_tf_create_temp_file)
    local temp_dir1=$(_tf_create_temp_dir)
    local temp_dir2=$(_tf_create_temp_dir)
    
    # Verify they exist and are unique
    _tf_assert_file_exists "$temp_file1" "First temp file should exist"
    _tf_assert_file_exists "$temp_file2" "Second temp file should exist" 
    _tf_assert_not_equals "$temp_file1" "$temp_file2" "Temp files should be unique"
    
    # Test directories
    _tf_assert_command_succeeds "test -d '$temp_dir1'" "First temp dir should exist"
    _tf_assert_command_succeeds "test -d '$temp_dir2'" "Second temp dir should exist"
    _tf_assert_not_equals "$temp_dir1" "$temp_dir2" "Temp dirs should be unique"
    
    # Write to temp files
    echo "temp data 1" > "$temp_file1"
    echo "temp data 2" > "$temp_file2"
    echo "dir file" > "$temp_dir1/test.txt"
    
    _tf_assert_file_contains "$temp_file1" "temp data 1" "First temp file should have correct content"
    _tf_assert_file_contains "$temp_file2" "temp data 2" "Second temp file should have correct content"
    _tf_assert_file_exists "$temp_dir1/test.txt" "File in temp dir should exist"
    
    # Clean up
    _tf_cleanup_temp "$temp_file1"
    _tf_cleanup_temp "$temp_file2" 
    _tf_cleanup_temp "$temp_dir1"
    _tf_cleanup_temp "$temp_dir2"
    
    # Verify cleanup
    _tf_assert_command_fails "test -f '$temp_file1'" "First temp file should be cleaned up"
    _tf_assert_command_fails "test -f '$temp_file2'" "Second temp file should be cleaned up"
    _tf_assert_command_fails "test -d '$temp_dir1'" "First temp dir should be cleaned up"
    _tf_assert_command_fails "test -d '$temp_dir2'" "Second temp dir should be cleaned up"
}

test_mock_functionality() {
    # Define original function
    original_date_function() {
        date "$@"
    }
    
    # Define mock function
    mock_date_function() {
        echo "2025-01-01T00:00:00Z"
    }
    
    # Test original function
    local original_output=$(original_date_function -u +"%Y")
    _tf_assert_equals "$original_output" "2025" "Original function should return current year"
    
    # Test with mock
    local mocked_result
    mocked_result=$(_tf_with_mock original_date_function mock_date_function original_date_function -u +"%Y")
    _tf_assert_contains "$mocked_result" "2025-01-01T00:00:00Z" "Mocked function should return fixed date"
    
    # Verify original function is restored
    local restored_output=$(original_date_function -u +"%Y")
    _tf_assert_equals "$restored_output" "$original_output" "Original function should be restored after mock"
}

# ============================================================================
# ADVANCED TESTING PATTERNS
# ============================================================================

test_error_conditions() {
    # Test function that might fail
    risky_function() {
        local input="$1"
        if [[ "$input" == "fail" ]]; then
            return 1
        else
            echo "success: $input"
            return 0
        fi
    }
    
    # Test success case
    local result=$(risky_function "good_input")
    _tf_assert_equals "$result" "success: good_input" "Function should succeed with good input"
    _tf_assert_command_succeeds "risky_function 'good_input'" "Function should return 0 for good input"
    
    # Test failure case
    _tf_assert_command_fails "risky_function 'fail'" "Function should return 1 for fail input"
}

test_multiple_conditions() {
    # Test multiple related conditions
    local config_data="debug=true\nport=8080\nssl=false"
    local config_file="$TEMP_DIR/app_config"
    echo -e "$config_data" > "$config_file"
    
    # Verify all expected settings
    _tf_assert_file_contains "$config_file" "debug=true" "Config should enable debug"
    _tf_assert_file_contains "$config_file" "port=8080" "Config should set port"
    _tf_assert_file_contains "$config_file" "ssl=false" "Config should disable SSL"
    
    # Verify settings are not conflicting
    _tf_assert_command_succeeds "grep -q 'debug=true' '$config_file'" "Debug should be explicitly enabled"
    _tf_assert_command_fails "grep -q 'debug=false' '$config_file'" "Debug should not be disabled"
}

test_data_processing() {
    # Test data transformation
    local input_file="$TEMP_DIR/input.csv"
    local output_file="$TEMP_DIR/output.csv"
    
    # Create test data
    cat > "$input_file" << 'EOF'
name,age,city
John,25,New York
Jane,30,London
Bob,35,Paris
EOF
    
    # Process data (extract just names)
    awk -F, 'NR>1 {print $1}' "$input_file" > "$output_file"
    
    # Verify processing
    _tf_assert_file_exists "$output_file" "Output file should be created"
    _tf_assert_file_contains "$output_file" "John" "Should contain first name"
    _tf_assert_file_contains "$output_file" "Jane" "Should contain second name" 
    _tf_assert_file_contains "$output_file" "Bob" "Should contain third name"
    
    # Verify it doesn't contain headers or other columns
    _tf_assert_command_fails "grep -q 'age\\|city\\|name' '$output_file'" "Should not contain headers or other columns"
    
    # Count lines
    local line_count=$(wc -l < "$output_file")
    _tf_assert_equals "$line_count" "3" "Should have exactly 3 lines"
}

# ============================================================================
# INTEGRATION-STYLE TESTS
# ============================================================================

test_workflow_integration() {
    # Test a complete workflow
    local workspace="$TEMP_DIR/workflow_test"
    mkdir -p "$workspace/input" "$workspace/output"
    
    # Step 1: Create input
    echo "raw data" > "$workspace/input/data.txt"
    _tf_assert_file_exists "$workspace/input/data.txt" "Input file should be created"
    
    # Step 2: Process data
    tr '[:lower:]' '[:upper:]' < "$workspace/input/data.txt" > "$workspace/output/processed.txt"
    _tf_assert_file_exists "$workspace/output/processed.txt" "Processed file should be created"
    
    # Step 3: Verify transformation
    _tf_assert_file_contains "$workspace/output/processed.txt" "RAW DATA" "Data should be uppercase"
    _tf_assert_command_fails "grep -q 'raw data' '$workspace/output/processed.txt'" "Should not contain lowercase"
    
    # Step 4: Create summary
    local summary="$workspace/summary.txt"
    echo "Processed $(wc -w < "$workspace/output/processed.txt") words" > "$summary"
    _tf_assert_file_contains "$summary" "Processed 2 words" "Summary should show word count"
}

# ============================================================================
# PERFORMANCE AND EDGE CASES
# ============================================================================

test_edge_cases() {
    # Empty values
    _tf_assert_equals "" "" "Empty strings should match"
    _tf_assert_not_equals "" "non-empty" "Empty should not match non-empty"
    
    # Special characters
    local special_chars="!@#$%^&*()[]{}|\\:;\"'<>?,./"
    _tf_assert_equals "$special_chars" "!@#$%^&*()[]{}|\\:;\"'<>?,./" "Special characters should match"
    
    # Whitespace
    local spaces="   "
    local tabs="			"
    _tf_assert_not_equals "$spaces" "$tabs" "Spaces and tabs should be different"
    
    # Large content
    local large_content=$(printf 'a%.0s' {1..1000})
    _tf_assert_equals "${#large_content}" "1000" "Large content should have correct length"
    _tf_assert_contains "$large_content" "aaa" "Large content should contain pattern"
}

test_numeric_edge_cases() {
    # Zero and negative numbers
    _tf_assert_equals "0" "0" "Zero should equal zero"
    _tf_assert_equals "-1" "-1" "Negative numbers should work"
    _tf_assert_not_equals "0" "-0" "Zero and negative zero are different strings"
    
    # Large numbers (as strings)
    _tf_assert_equals "999999999" "999999999" "Large numbers should match"
    _tf_assert_not_equals "999999999" "1000000000" "Large numbers should be distinct"
}

# ============================================================================
# RUN TESTS (Required)
# ============================================================================

# This block is required for the test to run when executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
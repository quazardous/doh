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
    
    # Reset test variables
    unset TEST_VALUE TEST_NUMBER TEMP_DIR TEMP_FILE
}

# ============================================================================
# ASSERTION FUNCTIONS
# ============================================================================

test_equality_assertions() {
    # String equality
    _tf_assert_equals "expected" "Strings should match" "expected"
    _tf_assert_equals "hello world" "Variable should match expected value" "$TEST_VALUE"
    
    # Number equality  
    _tf_assert_equals "42" "Numbers should match" "$TEST_NUMBER"
    
    # Inequality
    _tf_assert_not_equals "Different strings should not match" "hello" "world"
    _tf_assert_not_equals "Number should not equal zero" "$TEST_NUMBER" "0"
}

test_boolean_assertions() {
    # Boolean true/false
    _tf_assert_true "Boolean true value" "true"
    _tf_assert_false "Boolean false value" "false"
    
    # Command exit code as boolean (0 = success = true)
    _tf_assert_true "Zero exit code should be true" "0"
    
    # Variables as booleans
    local is_enabled="true"
    local is_disabled="false"
    _tf_assert_true "Enabled flag should be true" "$is_enabled"
    _tf_assert_false "Disabled flag should be false" "$is_disabled"
}

test_string_assertions() {
    local haystack="The quick brown fox jumps over the lazy dog"
    
    # String contains substring
    _tf_assert_contains "Should contain phrase" "$haystack" "quick brown"
    _tf_assert_contains "Should contain single word" "$haystack" "fox"
    _tf_assert_contains "Should contain greeting" "$TEST_VALUE" "hello"
    
    # Regex patterns work too
    _tf_assert_contains "Should match regex pattern" "$haystack" "fox.*lazy"
}

test_file_assertions() {
    # File existence
    _tf_assert_file_exists "Temp file should exist" "$TEMP_FILE"
    _tf_assert_file_exists "System file should exist" "/etc/passwd"
    
    # File contains content
    _tf_assert_file_contains "File should contain test data" "$TEMP_FILE" "sample data"
    
    # Create additional test file
    local config_file="$TEMP_DIR/config.txt"
    cat > "$config_file" << EOF
debug=true
port=8080
host=localhost
EOF
    
    _tf_assert_file_exists "Config file should be created" "$config_file"
    _tf_assert_file_contains "Should contain debug setting" "$config_file" "debug=true"
    _tf_assert_file_contains "Should contain port setting" "$config_file" "port=8080"
}

test_command_assertions() {
    # Commands that should succeed
    _tf_assert "Echo should succeed" echo 'test'
    _tf_assert "True command should succeed" true
    _tf_assert "Test file existence should succeed" test -f '$TEMP_FILE'
    _tf_assert "List tmp directory should succeed" ls /tmp
    
    # Commands that should fail
    _tf_assert_not "False command should fail" false
    _tf_assert_not "Exit 1 should fail" exit 1
    _tf_assert_not "Test nonexistent file should fail" test -f /nonexistent/file
    _tf_assert_not "List nonexistent directory should fail" ls /nonexistent/directory
    
    # Complex commands
    _tf_assert "Grep should find content" grep 'sample' '$TEMP_FILE'
    _tf_assert_not "Grep should not find missing content" grep 'missing' "$TEMP_FILE"
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
    _tf_assert_file_exists "First temp file should exist" "$temp_file1"
    _tf_assert_file_exists "Second temp file should exist" "$temp_file2" 
    _tf_assert_not_equals "Temp files should be unique" "$temp_file1" "$temp_file2"
    
    # Test directories
    _tf_assert "First temp dir should exist" test -d '$temp_dir1'
    _tf_assert "Second temp dir should exist" test -d '$temp_dir2'
    _tf_assert_not_equals "Temp dirs should be unique" "$temp_dir1" "$temp_dir2"
    
    # Write to temp files
    echo "temp data 1" > "$temp_file1"
    echo "temp data 2" > "$temp_file2"
    echo "dir file" > "$temp_dir1/test.txt"
    
    _tf_assert_file_contains "First temp file should have correct content" "$temp_file1" "temp data 1"
    _tf_assert_file_contains "Second temp file should have correct content" "$temp_file2" "temp data 2"
    _tf_assert_file_exists "File in temp dir should exist" "$temp_dir1/test.txt"
    
    # Clean up
    
    # Verify cleanup
    _tf_assert_not "First temp file should be cleaned up" test -f "$temp_file1"
    _tf_assert_not "Second temp file should be cleaned up" test -f "$temp_file2"
    _tf_assert_not "First temp dir should be cleaned up" test -d "$temp_dir1"
    _tf_assert_not "Second temp dir should be cleaned up" test -d "$temp_dir2"
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
    _tf_assert_equals "2025" "Original function should return current year" "$original_output"
    
    # Test with mock
    local mocked_result
    mocked_result=$(_tf_with_mock original_date_function mock_date_function original_date_function -u +"%Y")
    _tf_assert_contains "Mocked function should return fixed date" "$mocked_result" "2025-01-01T00:00:00Z"
    
    # Verify original function is restored
    local restored_output=$(original_date_function -u +"%Y")
    _tf_assert_equals "$original_output" "Original function should be restored after mock" "$restored_output"
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
    _tf_assert_equals "success: good_input" "Function should succeed with good input" "$result"
    _tf_assert "Function should return 0 for good input" risky_function 'good_input'
    
    # Test failure case
    _tf_assert_not "Function should return 1 for fail input" risky_function 'fail'
}

test_multiple_conditions() {
    # Test multiple related conditions
    local config_data="debug=true\nport=8080\nssl=false"
    local config_file="$TEMP_DIR/app_config"
    echo -e "$config_data" > "$config_file"
    
    # Verify all expected settings
    _tf_assert_file_contains "Config should enable debug" "$config_file" "debug=true"
    _tf_assert_file_contains "Config should set port" "$config_file" "port=8080"
    _tf_assert_file_contains "Config should disable SSL" "$config_file" "ssl=false"
    
    # Verify settings are not conflicting
    _tf_assert "Debug should be explicitly enabled" grep -q 'debug=true' '$config_file'
    _tf_assert_not "Debug should not be disabled" grep -q 'debug=false' "$config_file"
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
    _tf_assert_file_exists "Output file should be created" "$output_file"
    _tf_assert_file_contains "Should contain first name" "$output_file" "John"
    _tf_assert_file_contains "Should contain second name" "$output_file" "Jane" 
    _tf_assert_file_contains "Should contain third name" "$output_file" "Bob"
    
    # Verify it doesn't contain headers or other columns
    _tf_assert_not "Should not contain headers or other columns" grep -q 'age\|city\|name' "$output_file"
    
    # Count lines
    local line_count=$(wc -l < "$output_file")
    _tf_assert_equals "3" "Should have exactly 3 lines" "$line_count"
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
    _tf_assert_file_exists "Input file should be created" "$workspace/input/data.txt"
    
    # Step 2: Process data
    tr '[:lower:]' '[:upper:]' < "$workspace/input/data.txt" > "$workspace/output/processed.txt"
    _tf_assert_file_exists "Processed file should be created" "$workspace/output/processed.txt"
    
    # Step 3: Verify transformation
    _tf_assert_file_contains "Data should be uppercase" "$workspace/output/processed.txt" "RAW DATA"
    _tf_assert_not "Should not contain lowercase" grep -q 'raw data' "$workspace/output/processed.txt"
    
    # Step 4: Create summary
    local summary="$workspace/summary.txt"
    echo "Processed $(wc -w < "$workspace/output/processed.txt") words" > "$summary"
    _tf_assert_file_contains "Summary should show word count" "$summary" "Processed 2 words"
}

# ============================================================================
# PERFORMANCE AND EDGE CASES
# ============================================================================

test_edge_cases() {
    # Empty values
    _tf_assert_equals "" "Empty strings should match" ""
    _tf_assert_not_equals "Empty should not match non-empty" "" "non-empty"
    
    # Special characters
    local special_chars="!@#$%^&*()[]{}|\\:;\"'<>?,./"
    _tf_assert_equals "$special_chars" "!@#$%^&*()[]{}|\\:;\"'<>?,./" "Special characters should match"
    
    # Whitespace
    local spaces="   "
    local tabs="			"
    _tf_assert_not_equals "Spaces and tabs should be different" "$spaces" "$tabs"
    
    # Large content
    local large_content=$(printf 'a%.0s' {1..1000})
    _tf_assert_equals "1000" "Large content should have correct length" "${#large_content}"
    _tf_assert_contains "Large content should contain pattern" "$large_content" "aaa"
}

test_numeric_edge_cases() {
    # Zero and negative numbers
    _tf_assert_equals "0" "Zero should equal zero" "0"
    _tf_assert_equals "-1" "Negative numbers should work" "-1"
    _tf_assert_not_equals "Zero and negative zero are different strings" "0" "-0"
    
    # Large numbers (as strings)
    _tf_assert_equals "999999999" "Large numbers should match" "999999999"
    _tf_assert_not_equals "Large numbers should be distinct" "999999999" "1000000000"
}

# ============================================================================
# RUN TESTS (Required)
# ============================================================================

# This block is required for the test to run when executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
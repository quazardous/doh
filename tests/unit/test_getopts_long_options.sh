#!/bin/bash

# Test getopts handling of long options
# This test verifies that our getopts implementation correctly handles both short and long options

# Source the test framework
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"

# Source the frontmatter library to test
source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/frontmatter.sh"

# Test helper function that mimics our frontmatter functions (old version)
_test_getopts_implementation() {
    local OPTIND opt
    local auto_number=false
    local verbose=false
    
    # Use the same getopts pattern as in frontmatter functions
    while getopts "av-:" opt; do
        case "$opt" in
            a)
                auto_number=true
                ;;
            v)
                verbose=true
                ;;
            -)
                case "$OPTARG" in
                    auto-number)
                        auto_number=true
                        ;;
                    verbose)
                        verbose=true
                        ;;
                    *)
                        echo "Error: Unknown option --$OPTARG" >&2
                        return 1
                        ;;
                esac
                ;;
            *)
                echo "Error: Unknown option -$opt" >&2
                return 1
                ;;
        esac
    done
    shift $((OPTIND-1))
    
    # Return results via echo for testing
    echo "auto_number=$auto_number verbose=$verbose remaining_args=$*"
}

# Test helper function that mimics new frontmatter functions with required values
_test_getopts_with_values() {
    local OPTIND opt
    local auto_number=""
    local verbose=false
    
    # Use the new getopts pattern with required values
    while getopts "a:v-:" opt; do
        case "$opt" in
            a)
                if [[ -z "$OPTARG" ]]; then
                    echo "Error: Option -a requires a value" >&2
                    return 1
                fi
                auto_number="$OPTARG"
                ;;
            v)
                verbose=true
                ;;
            -)
                case "$OPTARG" in
                    auto-number=*)
                        auto_number="${OPTARG#*=}"
                        if [[ -z "$auto_number" ]]; then
                            echo "Error: --auto-number requires a value" >&2
                            return 1
                        fi
                        ;;
                    auto-number)
                        echo "Error: --auto-number requires a value. Use --auto-number=<type>" >&2
                        return 1
                        ;;
                    verbose)
                        verbose=true
                        ;;
                    *)
                        echo "Error: Unknown option --$OPTARG" >&2
                        return 1
                        ;;
                esac
                ;;
            *)
                echo "Error: Unknown option -$opt" >&2
                return 1
                ;;
        esac
    done
    shift $((OPTIND-1))
    
    # Return results via echo for testing
    echo "auto_number='$auto_number' verbose=$verbose remaining_args=$*"
}

# Test case: Short option -a
test_short_option_a() {
    local result
    result=$(_test_getopts_implementation -a file.txt)
    _tf_assert_equals "Short option -a should work" "auto_number=true verbose=false remaining_args=file.txt" "$result"
}

# Test case: Long option --auto-number
test_long_option_auto_number() {
    local result
    result=$(_test_getopts_implementation --auto-number file.txt)
    _tf_assert_equals "Long option --auto-number should work" "auto_number=true verbose=false remaining_args=file.txt" "$result"
}

# Test case: Mixed short and long options
test_mixed_options() {
    local result
    result=$(_test_getopts_implementation -a --verbose file.txt arg1)
    _tf_assert_equals "Mixed options should work" "auto_number=true verbose=true remaining_args=file.txt arg1" "$result"
}

# Test case: Options after positional arguments (should not work with getopts)
test_options_after_args() {
    local result
    result=$(_test_getopts_implementation file.txt -a arg1)
    # getopts stops parsing options after first non-option argument
    _tf_assert_equals "Options after args should not be parsed" "auto_number=false verbose=false remaining_args=file.txt -a arg1" "$result"
}

# Test case: No options
test_no_options() {
    local result
    result=$(_test_getopts_implementation file.txt arg1 arg2)
    _tf_assert_equals "No options should work" "auto_number=false verbose=false remaining_args=file.txt arg1 arg2" "$result"
}

# Test case: Invalid long option
test_invalid_long_option() {
    local result
    result=$(_test_getopts_implementation --invalid file.txt 2>/dev/null)
    local exit_code=$?
    
    _tf_assert_not_equals "0" "$exit_code" "Invalid option should return non-zero exit code"
}

# Test case: Multiple short options combined
test_combined_short_options() {
    local result
    result=$(_test_getopts_implementation -av file.txt)
    _tf_assert_equals "Combined short options should work" "auto_number=true verbose=true remaining_args=file.txt" "$result"
}

# Test actual frontmatter function with -a option
test_frontmatter_with_short_option() {
    local test_file="/tmp/test_frontmatter_${RANDOM}.md"
    
    # Clean up any existing test file
    rm -f "$test_file"
    
    # Test frontmatter_create_markdown with -a option
    frontmatter_create_markdown -a task "$test_file" "Test content" "name:TestFile" "status:active"
    
    # Verify file was created
    _tf_assert_file_exists "File should be created" "$test_file"
    
    # Verify auto-number was added (should have 'number' field)
    local has_number
    has_number=$(frontmatter_get_field "$test_file" "number" 2>/dev/null)
    _tf_assert_not_equals "$has_number" "" "Auto-number should generate number field"
    
    # Clean up
    rm -f "$test_file"
}

# Test actual frontmatter function with --auto-number option
test_frontmatter_with_long_option() {
    local test_file="/tmp/test_frontmatter_long_${RANDOM}.md"
    
    # Clean up any existing test file
    rm -f "$test_file"
    
    # Test frontmatter_create_markdown with --auto-number option
    frontmatter_create_markdown --auto-number=task "$test_file" "Test content" "name:TestFile" "status:active"
    
    # Verify file was created
    _tf_assert_file_exists "File should be created" "$test_file"
    
    # Verify auto-number was added
    local has_number
    has_number=$(frontmatter_get_field "$test_file" "number" 2>/dev/null)
    _tf_assert_not_equals "$has_number" "" "Auto-number should generate number field"
    
    # Clean up
    rm -f "$test_file"
}

# New test cases for options with required values

# Test case: Short option -a with value
test_short_option_with_value() {
    local result
    result=$(_test_getopts_with_values -a epic file.txt)
    _tf_assert_equals "Short option -a with value should work" "auto_number='epic' verbose=false remaining_args=file.txt" "$result"
}

# Test case: Long option --auto-number=value
test_long_option_with_value() {
    local result
    result=$(_test_getopts_with_values --auto-number=task file.txt)
    _tf_assert_equals "Long option --auto-number=value should work" "auto_number='task' verbose=false remaining_args=file.txt" "$result"
}

# Test case: Mixed options with values
test_mixed_options_with_values() {
    local result
    result=$(_test_getopts_with_values -a prd --verbose file.txt arg1)
    _tf_assert_equals "Mixed options with values should work" "auto_number='prd' verbose=true remaining_args=file.txt arg1" "$result"
}

# Test case: -a without value should fail
test_short_option_missing_value() {
    local result
    result=$(_test_getopts_with_values -a 2>/dev/null)
    local exit_code=$?
    _tf_assert_not_equals "Missing value for -a should fail" "0" "$exit_code"
}

# Test case: --auto-number without value should fail
test_long_option_missing_value() {
    local result
    result=$(_test_getopts_with_values --auto-number 2>/dev/null)
    local exit_code=$?
    _tf_assert_not_equals "Missing value for --auto-number should fail" "0" "$exit_code"
}

# Test case: --auto-number= (empty value) should fail
test_long_option_empty_value() {
    local result
    result=$(_test_getopts_with_values --auto-number= 2>/dev/null)
    local exit_code=$?
    _tf_assert_not_equals "Empty value for --auto-number should fail" "0" "$exit_code"
}

# Test frontmatter functions with new syntax
test_frontmatter_with_required_values() {
    local test_file="/tmp/test_frontmatter_values_${RANDOM}.md"
    
    # Clean up any existing test file
    rm -f "$test_file"
    
    # Test frontmatter_create_markdown with -a epic
    frontmatter_create_markdown -a epic "$test_file" "Test content" "name:TestEpic" "status:active"
    
    # Verify file was created
    _tf_assert_file_exists "File should be created with -a epic" "$test_file"
    
    # Verify auto-number was added with epic numbering
    local has_number
    has_number=$(frontmatter_get_field "$test_file" "number" 2>/dev/null)
    _tf_assert_not_equals "Auto-number should generate epic number field" "" "$has_number"
    
    # Clean up
    rm -f "$test_file"
}

# Run all tests (old tests)
test_short_option_a
test_long_option_auto_number
test_mixed_options
test_options_after_args
test_no_options
test_invalid_long_option
test_combined_short_options
test_frontmatter_with_short_option
test_frontmatter_with_long_option

# Run new tests with required values
test_short_option_with_value
test_long_option_with_value
test_mixed_options_with_values
test_short_option_missing_value
test_long_option_missing_value
test_long_option_empty_value
test_frontmatter_with_required_values
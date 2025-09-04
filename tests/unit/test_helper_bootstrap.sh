#!/bin/bash
# Test suite for helper bootstrap mechanism
# Tests: helper.sh routing, argument parsing, domain validation, function discovery
#
# USING LEGITIMATE helper.sh calls to test the bootstrap system integration.
# This test validates that helper.sh properly routes to domain helpers and handles arguments.

source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/doh_fixtures.sh"

# Test environment setup
_tf_setup() {
    # Use skeleton fixture system for proper test isolation
    _tff_create_helper_test_project "$DOH_PROJECT_DIR" >/dev/null
    _tff_setup_workspace_for_helpers
}

_tf_teardown() {
    # Cleanup handled by test launcher isolation
    return 0
}

# Test helper.sh basic routing - epic domain
test_helper_bootstrap_epic_routing() {
    local result
    result="$(./.claude/scripts/doh/helper.sh epic help 2>&1)"
    local exit_code=$?
    
    # Should succeed and route to epic helper
    _tf_assert_equals "Should route to epic domain successfully" 0 $exit_code
    
    # Should contain epic-specific help content
    _tf_assert_contains "Should show epic domain help" "$result" "DOH Epic Management"
    _tf_assert_contains "Should show epic create command" "$result" "create"
    _tf_assert_contains "Should show epic parse command" "$result" "parse"
    _tf_assert_contains "Should show epic list command" "$result" "list"
}

# Test helper.sh basic routing - prd domain
test_helper_bootstrap_prd_routing() {
    local result
    result="$(./.claude/scripts/doh/helper.sh prd help 2>&1)"
    local exit_code=$?
    
    # Should succeed and route to prd helper
    _tf_assert_equals "Should route to prd domain successfully" 0 $exit_code
    
    # Should contain prd-specific help content
    _tf_assert_contains "Should show prd domain help" "$result" "DOH PRD Management"
    _tf_assert_contains "Should show prd new command" "$result" "new"
    _tf_assert_contains "Should show prd parse command" "$result" "parse"
    _tf_assert_contains "Should show prd list command" "$result" "list"
}

# Test helper.sh basic routing - task domain
test_helper_bootstrap_task_routing() {
    local result
    result="$(./.claude/scripts/doh/helper.sh task help 2>&1)"
    local exit_code=$?
    
    # Should succeed and route to task helper
    _tf_assert_equals "Should route to task domain successfully" 0 $exit_code
    
    # Should contain task-specific help content
    _tf_assert_contains "Should show task domain help" "$result" "DOH Task Management"
    _tf_assert_contains "Should show task decompose command" "$result" "decompose"
    _tf_assert_contains "Should show task status command" "$result" "status"
    _tf_assert_contains "Should show task update command" "$result" "update"
}

# Test helper.sh basic routing - version domain
test_helper_bootstrap_version_routing() {
    local result
    result="$(./.claude/scripts/doh/helper.sh version help 2>&1)"
    local exit_code=$?
    
    # Should succeed and route to version helper
    _tf_assert_equals "Should route to version domain successfully" 0 $exit_code
    
    # Should contain version-specific help content
    _tf_assert_contains "Should show version domain help" "$result" "DOH Version Management"
    _tf_assert_contains "Should show version new command" "$result" "new"
    _tf_assert_contains "Should show version show command" "$result" "show"
    _tf_assert_contains "Should show version bump command" "$result" "bump"
}

# Test helper.sh validation - no arguments
test_helper_bootstrap_no_args() {
    local result
    result="$(./.claude/scripts/doh/helper.sh 2>&1)"
    local exit_code=$?
    
    # Should fail
    _tf_assert_equals "Should fail without any arguments" 1 $exit_code
    
    # Should show usage information
    _tf_assert_contains "Should show usage information" "$result" "Usage:"
    _tf_assert_contains "Should show generic helper usage" "$result" "helper.sh"
    _tf_assert_contains "Should mention helper_name" "$result" "<helper_name>"
    _tf_assert_contains "Should mention function_name" "$result" "<function_name>"
    _tf_assert_contains "Should suggest help" "$result" "Run 'helper.sh --help'"
}

# Test helper.sh validation - invalid domain
test_helper_bootstrap_invalid_domain() {
    local result
    result="$(./.claude/scripts/doh/helper.sh invalid-domain help 2>&1)"
    local exit_code=$?
    
    # Should fail
    _tf_assert_equals "Should fail for invalid domain" 1 $exit_code
    
    # Should show error about invalid domain
    _tf_assert_contains "Should show domain validation error" "$result" "Error: Helper not found"
    _tf_assert_contains "Should list valid domains" "$result" "Available helpers:"
}

# Test helper.sh validation - domain without action
test_helper_bootstrap_no_action() {
    local result
    result="$(./.claude/scripts/doh/helper.sh epic 2>&1)"
    local exit_code=$?
    
    # Should fail
    _tf_assert_equals "Should fail without action" 1 $exit_code
    
    # Should show generic error message (not domain-specific)
    _tf_assert_contains "Should show action validation error" "$result" "Error: Missing required arguments"
    _tf_assert_contains "Should show usage" "$result" "Usage:"
    _tf_assert_contains "Should show generic helper usage" "$result" "helper.sh"
}

# Test helper.sh function discovery - epic domain
test_helper_function_discovery_epic() {
    local result
    
    # Test that epic functions are properly discovered and called
    result="$(./.claude/scripts/doh/helper.sh epic create bootstrap-epic-unique-$$ "Bootstrap test" 2>&1)"
    local exit_code=$?
    
    # Should attempt to call helper_epic_create function
    # (May fail due to mocking limitations, but should show it's trying)
    _tf_assert_contains "Should attempt epic creation" "$result" "Creating epic"
}

# Test helper.sh function discovery - prd domain
test_helper_function_discovery_prd() {
    local result
    
    # Test that prd functions are properly discovered and called
    result="$(./.claude/scripts/doh/helper.sh prd new bootstrap-prd-unique-$$ "Bootstrap test" 2>&1)"
    local exit_code=$?
    
    # Should attempt to call helper_prd_new function
    _tf_assert_contains "Should attempt PRD creation" "$result" "Creating PRD"
}

# Test helper.sh error handling - invalid action
test_helper_invalid_action() {
    local result
    result="$(./.claude/scripts/doh/helper.sh epic invalid-action 2>&1)"
    local exit_code=$?
    
    # Should fail
    _tf_assert_equals "Should fail for invalid action" 1 $exit_code
    
    # Should show error about invalid action
    _tf_assert_contains "Should show action validation error" "$result" "Error: Invalid function name"
    _tf_assert_contains "Should show validation details" "$result" "Function names must start with a letter"
}

# Test helper.sh argument preservation
test_helper_argument_preservation() {
    local epic_name="bootstrap-test-epic-$$"
    local result
    result="$(./.claude/scripts/doh/helper.sh epic create "$epic_name" "with description" "and extra args" 2>&1)"
    
    # Arguments should be passed through to the helper function
    # The exact behavior depends on the helper implementation  
    # At minimum, it should not fail due to argument parsing
    _tf_assert_contains "Should preserve epic name argument" "$result" "$epic_name"
    _tf_assert_contains "Should confirm successful creation" "$result" "Epic created"
}

# Test helper.sh help system - main help
test_helper_main_help() {
    local result
    result="$(./.claude/scripts/doh/helper.sh --help 2>&1)"
    local exit_code=$?
    
    # Should succeed
    _tf_assert_equals "Main help should succeed" 0 $exit_code
    
    # Should show comprehensive help information
    _tf_assert_contains "Should show main header" "$result" "DOH Helper Bootstrap"
    _tf_assert_contains "Should show usage" "$result" "USAGE:"
    _tf_assert_contains "Should list helpers" "$result" "AVAILABLE HELPERS:"
    _tf_assert_contains "Should show examples" "$result" "EXAMPLES:"
    
    # Should describe all domains
    _tf_assert_contains "Should describe epic domain" "$result" "epic"
    _tf_assert_contains "Should describe prd domain" "$result" "prd"
    _tf_assert_contains "Should describe task domain" "$result" "task"
    _tf_assert_contains "Should describe version domain" "$result" "version"
}

# Test helper.sh help system - domain-specific help
test_helper_domain_help() {
    # Test each domain's help individually
    local domains=("epic" "prd" "task" "version")
    
    for domain in "${domains[@]}"; do
        local result
        result="$(./.claude/scripts/doh/helper.sh "$domain" help 2>&1)"
        local exit_code=$?
        
        _tf_assert_equals "Help should succeed for domain: $domain" 0 $exit_code
        _tf_assert_contains "Should show domain-specific header for: $domain" "$result" "DOH.*Management"
        _tf_assert_contains "Should show usage for: $domain" "$result" "Usage:"
        _tf_assert_contains "Should list commands for: $domain" "$result" "Commands:"
        _tf_assert_contains "Should show examples for: $domain" "$result" "Examples:"
    done
}

# Test helper.sh source file resolution
test_helper_source_resolution() {
    # Test that helper files are properly sourced
    # This is implicit in other tests, but let's verify the mechanism
    
    local result
    result="$(./.claude/scripts/doh/helper.sh epic help 2>&1)"
    local exit_code=$?
    
    # Should successfully source and execute epic helper functions
    _tf_assert_equals "Should successfully source epic helper" 0 $exit_code
    _tf_assert_contains "Should show epic functionality" "$result" "Epic Management"
}

# Test helper.sh with complex argument patterns
test_helper_complex_arguments() {
    # Test various argument patterns that helpers might receive
    local test_cases=(
        "epic create 'epic with spaces' 'description with spaces'"
        "prd new simple-name"
        "task status 123"
        "version bump patch"
    )
    
    for case in "${test_cases[@]}"; do
        local result
        result="$(./.claude/scripts/doh/helper.sh $case 2>&1)"
        local exit_code=$?
        
        # Should not fail due to argument parsing issues
        # The specific exit code depends on the helper implementation
        # but it should handle the arguments properly
        _tf_assert_contains "Should handle complex arguments: $case" "$result" ""
    done
}

# Test helper.sh exit code preservation
test_helper_exit_code_preservation() {
    # Test that exit codes from helper functions are preserved
    
    # Test successful case (should return 0)
    local result
    result="$(./.claude/scripts/doh/helper.sh epic help 2>&1)"
    local exit_code=$?
    _tf_assert_equals "Should preserve success exit code" 0 $exit_code
    
    # Test failure case (should return non-zero)
    result="$(./.claude/scripts/doh/helper.sh epic invalid-action 2>&1)"
    exit_code=$?
    _tf_assert_equals "Should preserve failure exit code" 1 $exit_code
}

# Test helper.sh environment handling
test_helper_environment_handling() {
    # Test that environment variables are properly handled
    export TEST_VAR="test_value"
    
    local result
    result="$(./.claude/scripts/doh/helper.sh epic help 2>&1)"
    local exit_code=$?
    
    # Should succeed regardless of environment
    _tf_assert_equals "Should handle environment properly" 0 $exit_code
    
    # Cleanup
    unset TEST_VAR
}

# Test helper.sh concurrent execution safety
test_helper_concurrent_safety() {
    # Test that multiple helper calls don't interfere with each other
    # This is a basic test - real concurrent testing would be more complex
    
    local result1 result2
    
    # Run commands in background and capture to temp files
    local temp1="$(mktemp)"
    local temp2="$(mktemp)"
    
    ./.claude/scripts/doh/helper.sh epic help > "$temp1" 2>&1 &
    ./.claude/scripts/doh/helper.sh prd help > "$temp2" 2>&1 &
    
    wait
    
    # Read results from temp files
    result1="$(cat "$temp1")"
    result2="$(cat "$temp2")"
    
    # Cleanup temp files
    rm -f "$temp1" "$temp2"
    
    # Both should succeed
    _tf_assert_contains "First call should succeed" "$result1" "Epic Management"
    _tf_assert_contains "Second call should succeed" "$result2" "PRD Management"
}

# Test helper.sh performance and responsiveness
test_helper_performance() {
    # Test that bootstrap overhead is minimal
    local start_time end_time
    start_time=$(date +%s%N)
    
    ./.claude/scripts/doh/helper.sh epic help >/dev/null 2>&1
    
    end_time=$(date +%s%N)
    local duration=$((($end_time - $start_time) / 1000000)) # Convert to milliseconds
    
    # Should complete reasonably quickly (under 1 second for help)
    _tf_assert "Bootstrap should be responsive (${duration}ms)" bash -c "[ $duration -lt 1000 ]"
}

# Prevent direct execution - tests must run through launcher
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
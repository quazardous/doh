#!/bin/bash
# Test suite for PRD helper functions
# Tests: helper prd commands via helper.sh
#
# USING LEGITIMATE helper.sh calls to test PRD helper integration.
# This test validates that PRD helper functions work through the helper.sh bootstrap.

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

# Test PRD help
test_helper_prd_help() {
    local result
    result="$(./.claude/scripts/doh/helper.sh prd help 2>&1)"
    local exit_code=$?
    
    # Should succeed
    _tf_assert_equals "PRD help should succeed" 0 $exit_code
    
    # Should contain expected help sections
    _tf_assert_contains "Should have header" "$result" "DOH PRD Management"
    _tf_assert_contains "Should have usage" "$result" "Usage:"
    _tf_assert_contains "Should list commands" "$result" "Commands:"
    _tf_assert_contains "Should include new command" "$result" "new"
    _tf_assert_contains "Should include parse command" "$result" "parse"
    _tf_assert_contains "Should include list command" "$result" "list"
    _tf_assert_contains "Should have examples" "$result" "Examples:"
}

# Test PRD list
test_helper_prd_list() {
    local result
    result="$(./.claude/scripts/doh/helper.sh prd list 2>&1)"
    local exit_code=$?
    
    # Should succeed
    _tf_assert_equals "PRD list should succeed" 0 $exit_code
    
    # Should show PRDs (from skeleton)
    _tf_assert_contains "Should show PRD information" "$result" "PRD"
}

# Test PRD new validation - no name
test_helper_prd_new_validation() {
    local result
    result="$(./.claude/scripts/doh/helper.sh prd new 2>&1)"
    local exit_code=$?
    
    # Should fail without PRD name
    _tf_assert_equals "Should fail without PRD name" 1 $exit_code
    
    # Should show validation error
    _tf_assert_contains "Should show validation error" "$result" "Error:"
}

# Prevent direct execution - tests must run through launcher
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
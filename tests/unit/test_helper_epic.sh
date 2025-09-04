#!/bin/bash
# Test suite for epic helper functions
# Tests: helper epic commands via helper.sh
#
# USING LEGITIMATE helper.sh calls to test epic helper integration.
# This test validates that epic helper functions work through the helper.sh bootstrap.

source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/doh_fixtures.sh"

# Test environment setup
_tf_setup() {
    # Use skeleton fixture system for proper test isolation
    _tff_create_helper_test_project >/dev/null
    _tff_setup_workspace_for_helpers
}

_tf_teardown() {
    # Cleanup handled by test launcher isolation
    return 0
}

# Test epic help
test_helper_epic_help() {
    local result
    result="$(./.claude/scripts/doh/helper.sh epic help 2>&1)"
    local exit_code=$?
    
    # Should succeed
    _tf_assert_equals "Epic help should succeed" 0 $exit_code
    
    # Should contain expected help sections
    _tf_assert_contains "Should have header" "$result" "DOH Epic Management"
    _tf_assert_contains "Should have usage" "$result" "Usage:"
    _tf_assert_contains "Should list commands" "$result" "Commands:"
    _tf_assert_contains "Should include create command" "$result" "create"
    _tf_assert_contains "Should include parse command" "$result" "parse"
    _tf_assert_contains "Should include list command" "$result" "list"
    _tf_assert_contains "Should have examples" "$result" "Examples:"
}

# Test epic list
test_helper_epic_list() {
    local result
    result="$(./.claude/scripts/doh/helper.sh epic list 2>&1)"
    local exit_code=$?
    
    # Should succeed
    _tf_assert_equals "Epic list should succeed" 0 $exit_code
    
    # Should show epics (from skeleton)
    _tf_assert_contains "Should show epic information" "$result" "epic"
}

# Test epic create validation - no name
test_helper_epic_create_validation() {
    local result
    result="$(./.claude/scripts/doh/helper.sh epic create 2>&1)"
    local exit_code=$?
    
    # Should fail without epic name
    _tf_assert_equals "Should fail without epic name" 1 $exit_code
    
    # Should show validation error
    _tf_assert_contains "Should show validation error" "$result" "Error:"
}

# Prevent direct execution - tests must run through launcher
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
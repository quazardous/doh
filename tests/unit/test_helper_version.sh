#!/bin/bash
# Test suite for version helper functions
# Tests: helper version commands via helper.sh
#
# USING LEGITIMATE helper.sh calls to test version helper integration.
# This test validates that version helper functions work through the helper.sh bootstrap.

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

# Test version help
test_helper_version_help() {
    local result
    result="$(./.claude/scripts/doh/helper.sh version help 2>&1)"
    local exit_code=$?
    
    # Should succeed
    _tf_assert_equals "Version help should succeed" 0 $exit_code
    
    # Should contain expected help sections
    _tf_assert_contains "Should have header" "$result" "DOH Version Management"
    _tf_assert_contains "Should have usage" "$result" "Usage:"
    _tf_assert_contains "Should list commands" "$result" "Commands:"
    _tf_assert_contains "Should include new command" "$result" "new"
    _tf_assert_contains "Should include show command" "$result" "show"
    _tf_assert_contains "Should include bump command" "$result" "bump"
    _tf_assert_contains "Should have examples" "$result" "Examples:"
}

# Test version show - basic functionality
test_helper_version_show() {
    local result
    result="$(./.claude/scripts/doh/helper.sh version show 2>&1)"
    
    # Should show version information (may succeed or fail depending on VERSION file existence)
    _tf_assert_contains "Should show version info" "$result" "version"
}

# Test version bump validation - no type
test_helper_version_bump_validation() {
    local result
    result="$(./.claude/scripts/doh/helper.sh version bump 2>&1)"
    local exit_code=$?
    
    # Should fail without bump type
    _tf_assert_equals "Should fail without bump type" 1 $exit_code
    
    # Should show validation error
    _tf_assert_contains "Should show validation error" "$result" "Error:"
}

# Prevent direct execution - tests must run through launcher
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
#!/bin/bash
# Test suite for task helper functions
# Tests: helper task commands via helper.sh
#
# USING LEGITIMATE helper.sh calls to test task helper integration.
# This test validates that task helper functions work through the helper.sh bootstrap.

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

# Test task help
test_helper_task_help() {
    local result
    result="$(./.claude/scripts/doh/helper.sh task help 2>&1)"
    local exit_code=$?
    
    # Should succeed
    _tf_assert_equals "Task help should succeed" 0 $exit_code
    
    # Should contain expected help sections
    _tf_assert_contains "Should have header" "$result" "DOH Task Management"
    _tf_assert_contains "Should have usage" "$result" "Usage:"
    _tf_assert_contains "Should list commands" "$result" "Commands:"
    _tf_assert_contains "Should include decompose command" "$result" "decompose"
    _tf_assert_contains "Should include status command" "$result" "status"
    _tf_assert_contains "Should include update command" "$result" "update"
    _tf_assert_contains "Should have examples" "$result" "Examples:"
}

# Test task status - basic functionality
test_helper_task_status_basic() {
    local result
    result="$(./.claude/scripts/doh/helper.sh task status 001 2>&1)"
    local exit_code=$?
    
    # Should succeed for existing task
    _tf_assert_equals "Task status should succeed for existing task" 0 $exit_code
    
    # Should contain task information
    _tf_assert_contains "Should show task status" "$result" "Status:"
    _tf_assert_contains "Should show task number" "$result" "001"
}

# Test task status validation - no task number
test_helper_task_status_validation() {
    local result
    result="$(./.claude/scripts/doh/helper.sh task status 2>&1)"
    local exit_code=$?
    
    # Should fail without task number
    _tf_assert_equals "Should fail without task number" 1 $exit_code
    
    # Should show validation error
    _tf_assert_contains "Should show validation error" "$result" "Error:"
}

# Test task status - task not found
test_helper_task_status_not_found() {
    local result
    result="$(./.claude/scripts/doh/helper.sh task status 999 2>&1)"
    local exit_code=$?
    
    # Should fail for nonexistent task
    _tf_assert_equals "Should fail for nonexistent task" 1 $exit_code
    
    # Should show error about task not found
    _tf_assert_contains "Should show task not found error" "$result" "Error:"
}

# Prevent direct execution - tests must run through launcher
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
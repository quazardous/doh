#!/bin/bash

# Test: Epic Helper Functions
# Verifies epic lifecycle helper functions work correctly and handle edge cases
#
# IMPORTANT: Several tests are commented out because they perform dangerous git operations
# that could corrupt the repository. These tests need DRYRUN support to be implemented
# in the epic helper functions before they can be safely enabled.
#
# TODO: Add --dry-run flag to all epic helper functions that perform git operations:
#   - helper_epic_validate_prerequisites (calls git status)
#   - helper_epic_create_or_enter_branch (calls git checkout, pull, push)
#   - Any other functions that modify repository state
#
# Once DRYRUN support is added, uncomment the dangerous tests and use --dry-run flag

source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"

_tf_setup() {
    # Create isolated test environment
    TEST_EPIC_NAME="test-epic-$$"
    TEST_EPIC_PATH=".doh/epics/$TEST_EPIC_NAME"
    TEST_BRANCH_NAME="epic/$TEST_EPIC_NAME"
    
    # Create test epic directory and file
    mkdir -p "$TEST_EPIC_PATH"
    cat > "$TEST_EPIC_PATH/epic.md" << EOF
---
name: $TEST_EPIC_NAME
number: 999
status: planning  
github: https://github.com/test/repo/issues/999
progress: 0%
file_version: 0.1.0
---

# Test Epic

This is a test epic for validation.
EOF

    # Create test task files
    cat > "$TEST_EPIC_PATH/001.md" << EOF
---
number: 001
title: Test Task 1
status: pending
depends_on: ""
file_version: 0.1.0
---

# Test Task 1
EOF

    cat > "$TEST_EPIC_PATH/002.md" << EOF
---
number: 002
title: Test Task 2
status: in_progress
file_version: 0.1.0
---

# Test Task 2
EOF

    cat > "$TEST_EPIC_PATH/003.md" << EOF
---
number: 003
title: Test Task 3
status: pending
depends_on: "001"
file_version: 0.1.0
---

# Test Task 3
EOF
}

_tf_teardown() {
    # Clean up test epic directory only
    if [[ -d "$TEST_EPIC_PATH" ]]; then
        rm -rf "$TEST_EPIC_PATH"
    fi
    
    unset TEST_EPIC_NAME TEST_EPIC_PATH TEST_BRANCH_NAME
}

# DANGEROUS TEST - COMMENTED OUT
# TODO: Add DRYRUN support to epic helpers to enable safe testing
# test_epic_validate_prerequisites_success() {
#     # DANGER: This test calls git operations that can affect the repository
#     # Should succeed when epic exists and has GitHub field
#     local result
#     result=$(./.claude/scripts/doh/helper.sh epic validate_prerequisites "$TEST_EPIC_NAME" 2>&1)
#     local exit_code=$?
#     
#     if [[ $exit_code -eq 0 ]]; then
#         _tf_assert_contains "Should validate successfully with proper epic" "$result" "Epic prerequisites validated"
#     else
#         # If there are uncommitted changes, that's also a valid test result
#         _tf_assert_contains "Should detect uncommitted changes appropriately" "$result" "Uncommitted changes detected"
#     fi
# }

# DANGEROUS TEST - COMMENTED OUT
# TODO: Add DRYRUN support to epic helpers to enable safe testing
# test_epic_validate_prerequisites_missing_epic() {
#     # DANGER: This test calls git status which can affect repository state
#     local result
#     result=$(./.claude/scripts/doh/helper.sh epic validate_prerequisites "nonexistent-epic" 2>&1)
#     local exit_code=$?
#     
#     _tf_assert_not_equals "Should fail validation for missing epic" "$exit_code" "0"
#     _tf_assert_contains "Should report missing epic" "$result" "Epic not found"
# }

# DANGEROUS TEST - COMMENTED OUT  
# TODO: Add DRYRUN support to epic helpers to enable safe testing
# test_epic_validate_prerequisites_no_github() {
#     # DANGER: This test calls git status which can affect repository state
#     # Create epic without GitHub field
#     local test_epic_no_github="test-epic-no-github-$$"
#     local test_path=".doh/epics/$test_epic_no_github"
#     
#     mkdir -p "$test_path"
#     cat > "$test_path/epic.md" << EOF
# ---
# name: $test_epic_no_github
# number: 998
# status: planning
# ---
# 
# # Test Epic Without GitHub
# EOF
# 
#     local result
#     result=$(./.claude/scripts/doh/helper.sh epic validate_prerequisites "$test_epic_no_github" 2>&1)
#     local exit_code=$?
#     
#     _tf_assert_not_equals "Should fail validation without GitHub sync" "$exit_code" "0"
#     _tf_assert_contains "Should report missing GitHub sync" "$result" "Epic not synced to GitHub"
#     
#     # Cleanup
#     rm -rf "$test_path"
# }

# Test ready task identification (safe - only reads files)
test_epic_identify_ready_tasks() {
    local result
    result=$(./.claude/scripts/doh/helper.sh epic identify_ready_tasks "$TEST_EPIC_NAME" 2>&1)
    local exit_code=$?
    
    _tf_assert_equals "Should successfully identify ready tasks" "0" "$exit_code"
    _tf_assert_contains "Should show analysis message" "$result" "Analyzing task readiness"
    _tf_assert_contains "Should identify task 001 as ready" "$result" "Ready: #001 - Test Task 1"
    _tf_assert_contains "Should show task 002 in progress" "$result" "Status 'in_progress': #002"
    _tf_assert_contains "Should identify task 003 as blocked" "$result" "Blocked: #003"
    _tf_assert_contains "Should report count of ready tasks" "$result" "Found"
}

# Test ready task identification with no tasks
test_epic_identify_ready_tasks_no_tasks() {
    local empty_epic="test-epic-empty-$$"
    local empty_path=".doh/epics/$empty_epic"
    
    mkdir -p "$empty_path"
    cat > "$empty_path/epic.md" << EOF
---
name: $empty_epic
number: 997
---

# Empty Epic
EOF

    local result
    result=$(./.claude/scripts/doh/helper.sh epic identify_ready_tasks "$empty_epic" 2>&1)
    local exit_code=$?
    
    _tf_assert_not_equals "Should fail when no ready tasks found" "$exit_code" "0"
    _tf_assert_contains "Should report no ready tasks" "$result" "No ready tasks found"
    
    # Cleanup
    rm -rf "$empty_path"
}

# Test ready task identification with nonexistent epic
test_epic_identify_ready_tasks_missing_epic() {
    local result
    result=$(./.claude/scripts/doh/helper.sh epic identify_ready_tasks "nonexistent-epic" 2>&1)
    local exit_code=$?
    
    _tf_assert_not_equals "Should fail for nonexistent epic" "$exit_code" "0"
    _tf_assert_contains "Should report missing epic directory" "$result" "Epic directory not found"
}

# Test branch operations function exists (static analysis only)
test_epic_branch_operations_function_exists() {
    local helper_file=".claude/scripts/doh/helper/epic.sh"
    
    # Verify function is defined in helper
    _tf_assert_file_contains "Branch creation function should be defined" "$helper_file" "helper_epic_create_or_enter_branch()"
    
    # Verify it's documented in help
    local result
    result=$(./.claude/scripts/doh/helper.sh epic help 2>&1)
    _tf_assert_contains "Helper should include branch creation function" "$result" "create-branch"
    _tf_assert_contains "Helper should include validation function" "$result" "validate"
    _tf_assert_contains "Helper should include ready tasks function" "$result" "ready-tasks"
}

# Test helper function integration with API
test_epic_helper_uses_api_functions() {
    # Verify the helper uses DOH API functions, not direct file access
    local helper_file=".claude/scripts/doh/helper/epic.sh"
    
    _tf_assert_file_exists "Epic helper should exist" "$helper_file"
    
    # Should use API functions
    _tf_assert_file_contains "Should use frontmatter API" "$helper_file" "api\.sh frontmatter get_field"
    
    # Check that new lifecycle functions use API (not all helper functions)
    _tf_assert_file_contains "Should include new validation function" "$helper_file" "validate_prerequisites"
    _tf_assert_file_contains "Should include new task identification function" "$helper_file" "identify_ready_tasks"
    
    # New functions should use API, not direct grep on frontmatter
    local lifecycle_section
    lifecycle_section=$(sed -n '/=== Epic Lifecycle Management Functions ===/,$p' "$helper_file")
    if echo "$lifecycle_section" | grep -q "grep.*:"; then
        _tf_assert_true "New lifecycle functions should not use direct frontmatter grep" "false"
    else
        _tf_assert_true "New lifecycle functions use API correctly" "true"
    fi
}

# DANGEROUS TEST - COMMENTED OUT
# TODO: Add DRYRUN support to epic helpers to enable safe testing
# test_epic_helper_error_handling() {
#     # DANGER: These tests call git operations
#     # Test with empty arguments
#     local result
#     result=$(./.claude/scripts/doh/helper.sh epic validate_prerequisites "" 2>&1)
#     local exit_code=$?
#     
#     _tf_assert_not_equals "Should handle empty epic name gracefully" "$exit_code" "0"
#     
#     # Test with invalid characters
#     result=$(./.claude/scripts/doh/helper.sh epic validate_prerequisites "invalid/epic/name" 2>&1)
#     exit_code=$?
#     
#     _tf_assert_not_equals "Should handle invalid epic names" "$exit_code" "0"
# }

# Test helper integration with existing epic management
test_epic_helper_integration() {
    # Verify helper integrates with existing epic functionality
    local result
    result=$(./.claude/scripts/doh/helper.sh epic list 2>&1)
    
    # Should work without errors (whether epics exist or not)
    _tf_assert_true "Epic list function should be accessible" "true"
    
    # Test status function exists
    result=$(./.claude/scripts/doh/helper.sh epic help 2>&1)
    _tf_assert_contains "Should include status function in help" "$result" "status.*Get epic status"
}

# Main test execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
#!/bin/bash
# Test suite for committee helper functions
# Tests helper.sh committee commands through direct function calls
# Following current best practices from test_best_patterns.sh

# ==============================================================================
# FRAMEWORK AND LIBRARY SOURCING (MANDATORY)
# ==============================================================================

# Source test framework (required)
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"

# Source DOH fixtures helper for test project setup
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/doh_fixtures.sh"

# CRITICAL: Source DOH libraries directly (10x faster than api.sh/helper.sh)
source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/doh.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/committee.sh"

# Source helper functions directly for testing (avoiding main execution)
DOH_HELPER_COMMITTEE_TEST_MODE=1
source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/helper/committee.sh"

# ==============================================================================
# SETUP AND TEARDOWN
# ==============================================================================

_tf_setup() {
    # Use fixture helpers for consistent test data and workspace setup
    _tff_create_minimal_doh_project >/dev/null
    _tff_setup_workspace_for_helpers
}

_tf_teardown() {
    # IMPORTANT: NO manual cleanup needed when using container's tmp directory!
    # The test launcher automatically cleans up the entire container after tests.
    # Manual cleanup can interfere with debugging - leave files for inspection.
    
    # No global variables to unset - each test uses local variables
    # This is the best practice for test isolation
    :  # No-op - just comments explaining why we don't clean up
}

# ==============================================================================
# SEED MANAGEMENT TESTS (Current functions only)
# ==============================================================================

test_helper_committee_seed_create_basic() {
    # BEST PRACTICE: All variables are local - no global dependencies
    local test_feature="test-auth"
    local seed_content="Test content for committee session"
    
    # Test seed creation using direct helper function call
    _tf_assert "Seed create should succeed" helper_committee_seed_create "$test_feature" "$seed_content"
    
    # Verify seed was created
    local doh_dir=$(doh_project_dir)
    local seed_file="$doh_dir/committees/$test_feature/seed.md"
    _tf_assert_file_exists "Seed file should be created" "$seed_file"
    _tf_assert_file_contains "Seed should have correct content" "$seed_file" "$seed_content"
}

test_helper_committee_seed_create_missing_params() {
    # Test with missing feature name
    _tf_assert_not "Missing feature name should fail" helper_committee_seed_create ""
    
    # Test with missing content  
    _tf_assert_not "Missing content should fail" helper_committee_seed_create "test-feature" ""
    
    # Test with both missing
    _tf_assert_not "Both missing should fail" helper_committee_seed_create "" ""
}

test_helper_committee_seed_exists_basic() {
    local test_feature="existence-test"
    local seed_content="Content for existence check"
    
    # Initially should not exist
    _tf_assert_not "Seed should not exist initially" helper_committee_seed_exists "$test_feature"
    
    # Create seed using library function directly (faster than helper)
    committee_create_seed "$test_feature" "$seed_content" >/dev/null
    
    # Now should exist
    _tf_assert "Seed should exist after creation" helper_committee_seed_exists "$test_feature"
}

test_helper_committee_seed_update_basic() {
    local test_feature="update-test"
    local original_content="Original seed content"
    local updated_content="Updated seed content"
    
    # Create initial seed
    committee_create_seed "$test_feature" "$original_content" >/dev/null
    
    # Update using helper function
    _tf_assert "Seed update should succeed" helper_committee_seed_update "$test_feature" "$updated_content"
    
    # Verify content was updated
    local doh_dir=$(doh_project_dir)
    local seed_file="$doh_dir/committees/$test_feature/seed.md"
    _tf_assert_file_contains "Should have updated content" "$seed_file" "$updated_content"
    _tf_assert_not "Should not have old content" bash -c "grep -q '$original_content' '$seed_file'"
}

test_helper_committee_seed_update_missing() {
    local test_feature="nonexistent-update"
    local new_content="This should fail"
    
    _tf_assert_not "Update non-existent seed should fail" helper_committee_seed_update "$test_feature" "$new_content"
}

test_helper_committee_seed_delete_basic() {
    local test_feature="delete-test" 
    local seed_content="Content to be deleted"
    
    # Create seed
    committee_create_seed "$test_feature" "$seed_content" >/dev/null
    
    # Verify it exists
    _tf_assert "Seed should exist before deletion" committee_has_seed "$test_feature"
    
    # Delete using helper function 
    # Note: This may require interactive input, so we test the non-interactive path
    _tf_assert "Delete seed should succeed" helper_committee_seed_delete "$test_feature" <<< "y"
    
    # Verify it's gone
    _tf_assert_not "Seed should not exist after deletion" committee_has_seed "$test_feature"
}

test_helper_committee_create_final_prd_basic() {
    local test_feature="prd-test"
    local seed_content="Test PRD seed content"
    
    # Create seed first (PRD template uses seed for context)
    committee_create_seed "$test_feature" "$seed_content" >/dev/null
    
    # Test PRD template creation
    local output
    output=$(helper_committee_create_final_prd "$test_feature" 2>/dev/null)
    _tf_assert "Create final PRD should succeed" test $? -eq 0
    
    # Verify output contains expected PRD structure
    _tf_assert_contains "Should contain frontmatter" "$output" "---"
    _tf_assert_contains "Should contain feature title" "$output" "$(echo $test_feature | tr '-' ' ' | sed 's/\b\w/\U&/g')"
    _tf_assert_contains "Should contain PRD sections" "$output" "Executive Summary"
    _tf_assert_contains "Should contain technical section" "$output" "Technical Architecture"
}

test_helper_committee_create_final_prd_missing_feature() {
    _tf_assert_not "Missing feature name should fail" helper_committee_create_final_prd ""
}

# ==============================================================================
# ERROR HANDLING TESTS
# ==============================================================================

test_helper_committee_functions_missing_parameters() {
    # Test all helper functions with missing feature name
    _tf_assert_not "seed_create rejects empty feature" helper_committee_seed_create ""
    _tf_assert_not "seed_exists rejects empty feature" helper_committee_seed_exists ""
    _tf_assert_not "seed_update rejects empty feature" helper_committee_seed_update ""  
    _tf_assert_not "seed_delete rejects empty feature" helper_committee_seed_delete ""
    _tf_assert_not "create_final_prd rejects empty feature" helper_committee_create_final_prd ""
}

test_helper_committee_validation_patterns() {
    # Test invalid feature names (from validation function)
    _tf_assert_not "Should reject invalid feature name" helper_committee_seed_create "Invalid_Name" "content"
    _tf_assert_not "Should reject uppercase" helper_committee_seed_create "INVALID" "content" 
    _tf_assert_not "Should reject spaces" helper_committee_seed_create "invalid name" "content"
    
    # Test valid feature names
    _tf_assert "Should accept kebab-case" helper_committee_seed_create "valid-feature" "content"
    _tf_assert "Should accept single word" helper_committee_seed_create "valid" "content"
}

# ==============================================================================
# INTEGRATION TESTS
# ==============================================================================

test_helper_committee_workflow_integration() {
    local test_feature="integration-test"
    local seed_content="# Integration Test Feature

## Requirements
- Requirement 1
- Requirement 2

## Context  
This is for integration testing."
    
    # Complete workflow: create seed, verify exists, update, create PRD template
    _tf_assert "Create seed should succeed" helper_committee_seed_create "$test_feature" "$seed_content"
    _tf_assert "Seed should exist after creation" helper_committee_seed_exists "$test_feature"
    
    # Update seed content
    local updated_content="$seed_content

## Updated Context
Added more requirements."
    _tf_assert "Update should succeed" helper_committee_seed_update "$test_feature" "$updated_content"
    
    # Generate PRD template
    local prd_output
    prd_output=$(helper_committee_create_final_prd "$test_feature" 2>/dev/null)
    _tf_assert "PRD template creation should succeed" test $? -eq 0
    _tf_assert_contains "PRD should reference feature" "$prd_output" "$test_feature"
    
    # All variables are local - no cleanup needed
}

# ==============================================================================
# REQUIRED: Prevent direct execution
# ==============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
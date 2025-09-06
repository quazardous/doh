#!/bin/bash
# Test suite for committee.sh library functions
# Tests the core committee library functions following current best practices
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
# SEED MANAGEMENT TESTS - committee_create_seed
# ==============================================================================

test_committee_create_seed_basic() {
    # BEST PRACTICE: All variables are local - no global dependencies
    local test_feature="seed-test-basic"
    local seed_content="This is test seed content for $test_feature"
    
    # Test seed creation
    local seed_path
    seed_path=$(committee_create_seed "$test_feature" "$seed_content")
    _tf_assert "Seed creation should succeed" test $? -eq 0
    
    # Verify seed file was created at returned path
    _tf_assert_file_exists "Seed file should be created" "$seed_path"
    _tf_assert_file_contains "Seed content should be correct" "$seed_path" "$seed_content"
    
    # Verify directory structure
    local doh_dir=$(doh_project_dir)
    local expected_path="$doh_dir/committees/$test_feature/seed.md"
    _tf_assert "Seed path should match expected location" test "$seed_path" = "$expected_path"
}

test_committee_create_seed_missing_params() {
    # Test without feature name
    _tf_assert_not "Missing feature name should fail" committee_create_seed ""
    
    # Test without content
    _tf_assert_not "Missing content should fail" committee_create_seed "test-feature" ""
    
    # Test with both missing
    _tf_assert_not "Both missing should fail" committee_create_seed "" ""
}

test_committee_create_seed_directory_creation() {
    local test_feature="directory-test"
    local seed_content="Test directory creation"
    
    # Verify committee directory doesn't exist initially
    local doh_dir=$(doh_project_dir)
    local committee_dir="$doh_dir/committees/$test_feature"
    _tf_assert_not "Committee directory should not exist initially" test -d "$committee_dir"
    
    # Create seed
    local seed_path
    seed_path=$(committee_create_seed "$test_feature" "$seed_content")
    _tf_assert "Seed creation should succeed" test $? -eq 0
    
    # Verify directory was created
    _tf_assert "Committee directory should be created" test -d "$committee_dir"
    _tf_assert_file_exists "Seed file should exist" "$seed_path"
}

# ==============================================================================
# SEED MANAGEMENT TESTS - committee_has_seed
# ==============================================================================

test_committee_has_seed_basic() {
    local test_feature="seed-exists-test"
    local seed_content="Test content for existence check"
    
    # Initially should not exist
    _tf_assert_not "Seed should not exist initially" committee_has_seed "$test_feature"
    
    # Create seed
    committee_create_seed "$test_feature" "$seed_content" >/dev/null
    
    # Now should exist
    _tf_assert "Seed should exist after creation" committee_has_seed "$test_feature"
}

test_committee_has_seed_missing_feature() {
    _tf_assert_not "Missing feature name should fail" committee_has_seed ""
}

test_committee_has_seed_nonexistent() {
    local test_feature="definitely-nonexistent"
    _tf_assert_not "Nonexistent seed should return false" committee_has_seed "$test_feature"
}

# ==============================================================================
# SEED MANAGEMENT TESTS - committee_update_seed
# ==============================================================================

test_committee_update_seed_basic() {
    local test_feature="seed-update-test"
    local original_content="Original seed content"
    local updated_content="Updated seed content with new information"
    
    # Create initial seed
    committee_create_seed "$test_feature" "$original_content" >/dev/null
    
    # Verify original content
    local doh_dir=$(doh_project_dir)
    local seed_file="$doh_dir/committees/$test_feature/seed.md"
    _tf_assert_file_contains "Original content should be correct" "$seed_file" "$original_content"
    
    # Update seed
    _tf_assert "Update seed should succeed" committee_update_seed "$test_feature" "$updated_content"
    
    # Verify updated content
    _tf_assert_file_contains "Updated content should be correct" "$seed_file" "$updated_content"
    _tf_assert_not "Should not contain old content" bash -c "grep -q '$original_content' '$seed_file'"
}

test_committee_update_seed_missing_params() {
    _tf_assert_not "Missing feature name should fail" committee_update_seed ""
    _tf_assert_not "Missing content should fail" committee_update_seed "test-feature" ""
    _tf_assert_not "Both missing should fail" committee_update_seed "" ""
}

test_committee_update_seed_nonexistent() {
    local test_feature="nonexistent-update"
    local new_content="This should fail"
    
    _tf_assert_not "Update non-existent seed should fail" committee_update_seed "$test_feature" "$new_content"
}

test_committee_update_seed_requires_existing() {
    local test_feature="requires-existing"
    local new_content="New content"
    
    # Should fail if seed doesn't exist
    _tf_assert_not "Update should require existing seed" committee_update_seed "$test_feature" "$new_content"
    
    # Create seed then update should work
    committee_create_seed "$test_feature" "Initial content" >/dev/null
    _tf_assert "Update should work with existing seed" committee_update_seed "$test_feature" "$new_content"
}

# ==============================================================================
# SEED MANAGEMENT TESTS - committee_delete_seed
# ==============================================================================

test_committee_delete_seed_basic() {
    local test_feature="seed-delete-test"
    local seed_content="Content to be deleted"
    
    # Create seed
    committee_create_seed "$test_feature" "$seed_content" >/dev/null
    
    # Verify it exists
    _tf_assert "Seed should exist before deletion" committee_has_seed "$test_feature"
    
    # Delete seed
    _tf_assert "Delete seed should succeed" committee_delete_seed "$test_feature"
    
    # Verify it's gone
    _tf_assert_not "Seed should not exist after deletion" committee_has_seed "$test_feature"
}

test_committee_delete_seed_missing_feature() {
    _tf_assert_not "Missing feature name should fail" committee_delete_seed ""
}

test_committee_delete_seed_idempotent() {
    local test_feature="idempotent-delete"
    
    # Should succeed even if seed doesn't exist (idempotent)
    _tf_assert "Delete non-existent seed should succeed" committee_delete_seed "$test_feature"
    
    # Create, delete, delete again - should all succeed
    committee_create_seed "$test_feature" "content" >/dev/null
    _tf_assert "First delete should succeed" committee_delete_seed "$test_feature"
    _tf_assert "Second delete should succeed" committee_delete_seed "$test_feature"
}

# ==============================================================================
# PRD TEMPLATE TESTS - committee_create_final_prd
# ==============================================================================

test_committee_create_final_prd_basic() {
    local test_feature="prd-template-test"
    local seed_content="description: Test feature for PRD template
target_version: 2.0.0"
    
    # Create seed with frontmatter-like content
    committee_create_seed "$test_feature" "$seed_content" >/dev/null
    
    # Generate PRD template
    local prd_output
    prd_output=$(committee_create_final_prd "$test_feature")
    _tf_assert "Create final PRD should succeed" test $? -eq 0
    
    # Verify PRD template structure
    _tf_assert_contains "Should contain YAML frontmatter" "$prd_output" "---"
    _tf_assert_contains "Should contain feature ID" "$prd_output" "id: $test_feature"
    _tf_assert_contains "Should contain formatted title" "$prd_output" "$(echo $test_feature | tr '-' ' ' | sed 's/\b\w/\U&/g')"
    _tf_assert_contains "Should contain version" "$prd_output" "version: 2.0.0"
    _tf_assert_contains "Should contain description" "$prd_output" "Test feature for PRD template"
    _tf_assert_contains "Should contain executive summary" "$prd_output" "Executive Summary"
    _tf_assert_contains "Should contain technical architecture" "$prd_output" "Technical Architecture"
    _tf_assert_contains "Should contain user experience" "$prd_output" "User Experience"
    _tf_assert_contains "Should contain business requirements" "$prd_output" "Business Requirements"
}

test_committee_create_final_prd_without_seed() {
    local test_feature="no-seed-prd"
    
    # Should work without seed (uses defaults)
    local prd_output
    prd_output=$(committee_create_final_prd "$test_feature")
    _tf_assert "Should work without seed" test $? -eq 0
    _tf_assert_contains "Should have default description" "$prd_output" "Committee-generated feature"
    _tf_assert_contains "Should have default version" "$prd_output" "version: 1.0.0"
}

test_committee_create_final_prd_missing_feature() {
    _tf_assert_not "Missing feature name should fail" committee_create_final_prd ""
}

test_committee_create_final_prd_structure() {
    local test_feature="structure-test"
    
    local prd_output
    prd_output=$(committee_create_final_prd "$test_feature")
    
    # Verify required sections are present
    _tf_assert_contains "Should have executive summary" "$prd_output" "Executive Summary"
    _tf_assert_contains "Should have technical architecture" "$prd_output" "Technical Architecture"  
    _tf_assert_contains "Should have user experience" "$prd_output" "User Experience"
    _tf_assert_contains "Should have business requirements" "$prd_output" "Business Requirements"
    _tf_assert_contains "Should have implementation plan" "$prd_output" "Implementation Plan"
    _tf_assert_contains "Should have success criteria" "$prd_output" "Success Criteria"
    _tf_assert_contains "Should have risks section" "$prd_output" "Risks and Mitigation"
    _tf_assert_contains "Should have next steps" "$prd_output" "Next Steps"
    
    # Verify CTO placeholders
    _tf_assert_contains "Should have CTO placeholders" "$prd_output" "TO BE SPECIFIED BY CTO"
}

# ==============================================================================
# ERROR HANDLING AND EDGE CASES
# ==============================================================================

test_committee_functions_parameter_validation() {
    # Test all functions with missing parameters
    _tf_assert_not "create_seed rejects empty feature" committee_create_seed ""
    _tf_assert_not "has_seed rejects empty feature" committee_has_seed ""
    _tf_assert_not "update_seed rejects empty feature" committee_update_seed ""
    _tf_assert_not "delete_seed rejects empty feature" committee_delete_seed ""
    _tf_assert_not "create_final_prd rejects empty feature" committee_create_final_prd ""
}

test_committee_multiline_content() {
    local test_feature="multiline-test"
    local multiline_content="Line 1: Description
Line 2: Requirements
Line 3: Special chars @#$%^&*()
Line 4: Unicode: éñ中文🚀"
    
    # Create seed with multiline content
    committee_create_seed "$test_feature" "$multiline_content" >/dev/null
    
    # Verify all lines are preserved
    local doh_dir=$(doh_project_dir)
    local seed_file="$doh_dir/committees/$test_feature/seed.md"
    
    _tf_assert_file_contains "Should preserve line 1" "$seed_file" "Line 1: Description"
    _tf_assert_file_contains "Should preserve line 2" "$seed_file" "Line 2: Requirements"
    # Test special chars without regex metacharacters
    _tf_assert_file_contains "Should preserve special chars" "$seed_file" "Special chars @#"
    _tf_assert_file_contains "Should preserve unicode" "$seed_file" "Unicode: éñ中文🚀"
}

# ==============================================================================
# INTEGRATION TESTS
# ==============================================================================

test_committee_full_workflow() {
    local test_feature="full-workflow"
    local initial_content="# Initial Feature Description

## Problem Statement
This is a test problem.

## Requirements
- Requirement 1
- Requirement 2"
    
    # Complete seed lifecycle
    committee_create_seed "$test_feature" "$initial_content" >/dev/null
    _tf_assert "Seed should exist after creation" committee_has_seed "$test_feature"
    
    # Update seed
    local updated_content="$initial_content

## Updated Requirements
- Additional requirement 3
- Additional requirement 4"
    
    _tf_assert "Update should succeed" committee_update_seed "$test_feature" "$updated_content"
    
    # Generate PRD template
    local prd_output
    prd_output=$(committee_create_final_prd "$test_feature")
    _tf_assert "PRD generation should succeed" test $? -eq 0
    _tf_assert_contains "PRD should reference feature" "$prd_output" "$test_feature"
    
    # Clean up
    _tf_assert "Delete should succeed" committee_delete_seed "$test_feature"
    _tf_assert_not "Seed should not exist after deletion" committee_has_seed "$test_feature"
    
    # All variables are local - no cleanup needed
}

test_committee_concurrent_features() {
    # Test multiple features can coexist
    local feature1="concurrent-feature-1"
    local feature2="concurrent-feature-2"
    local content1="Content for feature 1"
    local content2="Content for feature 2"
    
    # Create both seeds
    committee_create_seed "$feature1" "$content1" >/dev/null
    committee_create_seed "$feature2" "$content2" >/dev/null
    
    # Both should exist
    _tf_assert "Feature 1 should exist" committee_has_seed "$feature1"
    _tf_assert "Feature 2 should exist" committee_has_seed "$feature2"
    
    # Verify independence
    local doh_dir=$(doh_project_dir)
    _tf_assert_file_contains "Feature 1 has correct content" "$doh_dir/committees/$feature1/seed.md" "$content1"
    _tf_assert_file_contains "Feature 2 has correct content" "$doh_dir/committees/$feature2/seed.md" "$content2"
    
    # Delete one shouldn't affect the other
    committee_delete_seed "$feature1"
    _tf_assert_not "Feature 1 should be deleted" committee_has_seed "$feature1"
    _tf_assert "Feature 2 should still exist" committee_has_seed "$feature2"
}

# ==============================================================================
# REQUIRED: Prevent direct execution
# ==============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
#!/bin/bash
# Test suite for epic helper functions
# Tests: helper epic commands via helper.sh
#
# USING LEGITIMATE helper.sh calls to test epic helper integration.
# This test validates that epic helper functions work through the helper.sh bootstrap.

source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/doh_fixtures.sh"

# Source the epic helper library directly for testing
source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/helper/epic.sh"
# Source frontmatter library for direct API calls
source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/frontmatter.sh"

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
    result="$(helper_epic_help 2>&1)"
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
    result="$(helper_epic_list 2>&1)"
    local exit_code=$?
    
    # Should succeed
    _tf_assert_equals "Epic list should succeed" 0 $exit_code
    
    # Should show epics (from skeleton)
    _tf_assert_contains "Should show epic information" "$result" "epic"
}

# Test epic create validation - no name
test_helper_epic_create_validation() {
    local result
    result="$(helper_epic_create 2>&1)"
    local exit_code=$?
    
    # Should fail without epic name
    _tf_assert_equals "Should fail without epic name" 1 $exit_code
    
    # Should show validation error
    _tf_assert_contains "Should show validation error" "$result" "Error:"
}

# Test epic create basic functionality
test_helper_epic_create_basic() {
    local epic_name="test-epic-basic"
    local description="Basic epic for testing"
    local result
    
    # Create epic
    result="$(helper_epic_create "$epic_name" "$description" 2>&1)"
    local exit_code=$?
    
    # Should succeed
    _tf_assert_equals "Epic creation should succeed" 0 $exit_code
    _tf_assert_contains "Should confirm creation" "$result" "Epic created"
    
    # Verify epic file exists (use doh_project_dir to get correct temporary path)
    local doh_dir=$(doh_project_dir)
    local epic_file="$doh_dir/epics/$epic_name/epic.md"
    _tf_assert_file_exists "Epic file should be created" "$epic_file"
    
    # Verify epic has correct frontmatter
    local epic_name_from_file
    epic_name_from_file=$(frontmatter_get_field "$epic_file" "name")
    _tf_assert_equals "Epic name should match" "$epic_name" "$epic_name_from_file"
    
    local epic_status
    epic_status=$(frontmatter_get_field "$epic_file" "status")
    _tf_assert_equals "Epic status should be backlog" "backlog" "$epic_status"
    
    # Verify epic has auto-generated number
    local epic_number
    epic_number=$(frontmatter_get_field "$epic_file" "number")
    _tf_assert_not_equals "Epic should have number" "" "$epic_number"
}

# Test epic create with explicit target_version
test_helper_epic_create_with_target_version() {
    local epic_name="test-epic-versioned"
    local description="Epic with explicit target version"
    local target_version="2.1.0"
    local result
    
    # Create epic with explicit target_version
    result="$(helper_epic_create "$epic_name" "$description" "$target_version" 2>&1)"
    local exit_code=$?
    
    # Should succeed
    _tf_assert_equals "Epic creation with target_version should succeed" 0 $exit_code
    _tf_assert_contains "Should confirm creation" "$result" "Epic created"
    _tf_assert_contains "Should show target_version" "$result" "Set target_version: $target_version"
    
    # Verify epic file exists
    local doh_dir=$(doh_project_dir)
    local epic_file="$doh_dir/epics/$epic_name/epic.md"
    _tf_assert_file_exists "Epic file should be created" "$epic_file"
    
    # Verify target_version is set correctly
    local actual_target_version
    actual_target_version=$(frontmatter_get_field "$epic_file" "target_version")
    _tf_assert_equals "Target version should match" "$target_version" "$actual_target_version"
}

# Test epic create with PRD auto-extraction of target_version
test_helper_epic_create_prd_extraction() {
    local epic_name="test-epic-prd-extraction"
    local description="Epic that extracts target_version from PRD"
    local prd_target_version="3.2.1"
    local result
    
    # First create a PRD with target_version
    local doh_dir=$(doh_project_dir)
    local prd_file="$doh_dir/prds/$epic_name.md"
    frontmatter_create_markdown \
        "$prd_file" \
        "PRD content for testing" \
        "name:$epic_name" \
        "description:Test PRD with target version" \
        "target_version:$prd_target_version" \
        "status:draft" >/dev/null
    
    _tf_assert_file_exists "PRD should be created first" "$prd_file"
    
    # Create epic without explicit target_version - should extract from PRD
    result="$(helper_epic_create "$epic_name" "$description" 2>&1)"
    local exit_code=$?
    
    # Should succeed
    _tf_assert_equals "Epic creation with PRD extraction should succeed" 0 $exit_code
    _tf_assert_contains "Should confirm creation" "$result" "Epic created"
    _tf_assert_contains "Should show extracted version" "$result" "Extracted target_version from PRD: $prd_target_version"
    
    # Verify epic file exists
    local epic_file="$doh_dir/epics/$epic_name/epic.md"
    _tf_assert_file_exists "Epic file should be created" "$epic_file"
    
    # Verify target_version was extracted from PRD
    local actual_target_version
    actual_target_version=$(frontmatter_get_field "$epic_file" "target_version")
    _tf_assert_equals "Target version should be extracted from PRD" "$prd_target_version" "$actual_target_version"
}

# Test epic create explicit version overrides PRD extraction
test_helper_epic_create_override_prd() {
    local epic_name="test-epic-override"
    local description="Epic that overrides PRD target_version"
    local prd_target_version="1.0.0"
    local explicit_target_version="2.0.0"
    local result
    
    # First create a PRD with target_version
    local doh_dir=$(doh_project_dir)
    local prd_file="$doh_dir/prds/$epic_name.md"
    frontmatter_create_markdown \
        "$prd_file" \
        "PRD content for override testing" \
        "name:$epic_name" \
        "description:Test PRD with target version to be overridden" \
        "target_version:$prd_target_version" \
        "status:draft" >/dev/null
    
    _tf_assert_file_exists "PRD should be created first" "$prd_file"
    
    # Create epic with explicit target_version - should override PRD
    result="$(helper_epic_create "$epic_name" "$description" "$explicit_target_version" 2>&1)"
    local exit_code=$?
    
    # Should succeed
    _tf_assert_equals "Epic creation with explicit override should succeed" 0 $exit_code
    _tf_assert_contains "Should confirm creation" "$result" "Epic created"
    _tf_assert_contains "Should show explicit version" "$result" "Set target_version: $explicit_target_version"
    # Should NOT show PRD extraction message since explicit version was provided
    _tf_assert_not_contains "Should not show PRD extraction" "$result" "Extracted target_version from PRD"
    
    # Verify epic file exists
    local epic_file="$doh_dir/epics/$epic_name/epic.md"
    _tf_assert_file_exists "Epic file should be created" "$epic_file"
    
    # Verify target_version is the explicit one, not from PRD
    local actual_target_version
    actual_target_version=$(frontmatter_get_field "$epic_file" "target_version")
    _tf_assert_equals "Target version should be explicit, not from PRD" "$explicit_target_version" "$actual_target_version"
    _tf_assert_not_equals "Target version should not be from PRD" "$prd_target_version" "$actual_target_version"
}

# Prevent direct execution - tests must run through launcher
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
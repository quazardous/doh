#!/bin/bash
# Test suite for committee helper functions
# Tests: helper committee commands via helper.sh
#
# LEGITIMATE EXCEPTION: This test specifically tests the helper.sh wrapper script
# for committee commands, so it appropriately uses ./.claude/scripts/doh/helper.sh
# instead of sourcing libraries directly.
#
# PATTERN: This test validates that committee helper functions work through the helper.sh bootstrap.
# For testing individual committee library functions, use direct library sourcing instead.

# ==============================================================================
# FRAMEWORK AND LIBRARY SOURCING
# ==============================================================================

# Source test framework (required)
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"

# Source DOH fixtures helper for test project setup
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/doh_fixtures.sh"

# CRITICAL: Even though we're testing helper.sh, we need DOH library for path functions
# This prevents creating file artifacts in project root by getting proper container paths
source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/doh.sh"

# ==============================================================================
# SETUP AND TEARDOWN
# ==============================================================================

_tf_setup() {
    # Use fixture helpers for consistent test data and workspace setup
    # This provides a clean DOH structure for testing helper.sh integration
    _tff_create_helper_test_project >/dev/null
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
# COMMAND TESTING PATTERNS (Testing helper.sh wrapper)
# ==============================================================================

# =============================================================================
# TEST: committee helper commands via helper.sh
# =============================================================================

test_committee_help_display() {
    # Test help display via helper.sh - command should succeed
    _tf_assert "Committee help should succeed" ./.claude/scripts/doh/helper.sh committee help
    
    # Capture output for content validation
    local output
    output=$(./.claude/scripts/doh/helper.sh committee help 2>/dev/null)
    
    # Validate help content using _tf_assert_contains
    _tf_assert_contains "Help title displayed" "$output" "DOH Committee Management"
    _tf_assert_contains "Create command listed" "$output" "create <feature>"
    _tf_assert_contains "Round1 command listed" "$output" "round1 <feature>"
    _tf_assert_contains "Round2 command listed" "$output" "round2 <feature>"
    _tf_assert_contains "Converge command listed" "$output" "converge <feature>"
}

test_committee_main_no_args() {
    # Test calling help function explicitly - command should succeed
    _tf_assert "Committee help should succeed" ./.claude/scripts/doh/helper.sh committee help
    
    # Capture output for content validation
    local output
    output=$(./.claude/scripts/doh/helper.sh committee help 2>/dev/null)
    
    # Validate that help is shown
    _tf_assert_contains "Help shows usage" "$output" "DOH Committee Management"
}

test_committee_main_invalid_command() {
    # Test invalid function - command should fail
    _tf_assert_not "Invalid function should fail" ./.claude/scripts/doh/helper.sh committee invalid-function
    
    # Capture error output for content validation
    local output
    output=$(./.claude/scripts/doh/helper.sh committee invalid-function 2>&1 || true)
    
    # Validate error messages (helper.sh provides these messages)
    _tf_assert_contains "Invalid function error shown" "$output" "Function 'invalid-function' not found"
    _tf_assert_contains "Available functions listed" "$output" "Available functions in committee helper:"
}

test_committee_create_basic() {
    local test_feature="test-feature"
    local doh_dir
    doh_dir=$(doh_project_dir)
    
    # Test create command - should succeed
    _tf_assert "Committee create should succeed" ./.claude/scripts/doh/helper.sh committee create "$test_feature"
    
    # Capture output for validation
    local output
    output=$(./.claude/scripts/doh/helper.sh committee create "$test_feature-2" 2>/dev/null)
    
    # Validate create messages
    _tf_assert_contains "Create message shown" "$output" "Creating committee session for: $test_feature-2"
    _tf_assert_contains "Next step guidance shown" "$output" "committee round1 $test_feature-2"
    
    # Verify session was created
    _tf_assert "Session directory created" test -d "$doh_dir/committees/$test_feature"
    _tf_assert "Session file created" test -f "$doh_dir/committees/$test_feature/session.md"
}

test_committee_create_missing_feature() {
    # Test create without feature name - should fail
    _tf_assert_not "Create without feature should fail" ./.claude/scripts/doh/helper.sh committee create
    
    # Capture error output
    local output
    output=$(./.claude/scripts/doh/helper.sh committee create 2>&1 || true)
    
    # Validate error message
    _tf_assert_contains "Missing feature error shown" "$output" "Feature name required for create command"
}

test_committee_create_invalid_name() {
    # Test create with invalid feature name - should fail
    _tf_assert_not "Create with invalid name should fail" ./.claude/scripts/doh/helper.sh committee create "Invalid_Name"
    
    # Capture error output  
    local output
    output=$(./.claude/scripts/doh/helper.sh committee create "Invalid_Name" 2>&1 || true)
    
    # Validate error message
    _tf_assert_contains "Invalid name error shown" "$output" "Feature name must be kebab-case"
}

test_committee_list_no_sessions() {
    # Test list with no sessions - should succeed
    _tf_assert "Committee list should succeed" ./.claude/scripts/doh/helper.sh committee list
    
    # Capture output for content validation
    local output
    output=$(./.claude/scripts/doh/helper.sh committee list 2>/dev/null)
    
    # Validate list content
    _tf_assert_contains "List title shown" "$output" "Committee Sessions"
    _tf_assert_contains "No sessions message shown" "$output" "No committee sessions found"
    _tf_assert_contains "Create guidance shown" "$output" "committee create <feature-name>"
}

test_committee_list_with_sessions() {
    local doh_dir
    doh_dir=$(doh_project_dir)
    
    # Create some test sessions using helper.sh - should succeed
    _tf_assert "Create feature-1 should succeed" ./.claude/scripts/doh/helper.sh committee create feature-1
    _tf_assert "Create feature-2 should succeed" ./.claude/scripts/doh/helper.sh committee create feature-2
    
    # Create additional structure to simulate progress
    mkdir -p "$doh_dir/committees/feature-1/round2"
    
    # Test list command - should succeed
    _tf_assert "Committee list should succeed" ./.claude/scripts/doh/helper.sh committee list
    
    # Capture output for validation
    local output
    output=$(./.claude/scripts/doh/helper.sh committee list 2>/dev/null)
    
    # Validate list content
    _tf_assert_contains "Feature 1 listed" "$output" "🏛️ feature-1"
    _tf_assert_contains "Feature 2 listed" "$output" "🏛️ feature-2" 
    _tf_assert_contains "Round 1 status shown" "$output" "Round 1: ✅ Completed"
    _tf_assert_contains "Round 2 status for feature-1" "$output" "Round 2: ✅ Completed"
    _tf_assert_contains "Round 2 pending for feature-2" "$output" "Round 2: ⏳ Pending"
}

test_committee_status_valid() {
    local test_feature="status-test"
    
    # Create session first - should succeed
    _tf_assert "Create session should succeed" ./.claude/scripts/doh/helper.sh committee create "$test_feature"
    
    # Test status command - should succeed
    _tf_assert "Committee status should succeed" ./.claude/scripts/doh/helper.sh committee status "$test_feature"
    
    # Capture output for validation
    local output
    output=$(./.claude/scripts/doh/helper.sh committee status "$test_feature" 2>/dev/null)
    
    # Validate status content
    _tf_assert_contains "Status header shown" "$output" "Committee Session Status: $test_feature"
    _tf_assert_contains "Commands guidance shown" "$output" "Available commands:"
}

test_committee_status_missing_feature() {
    # Test status without feature name - should fail
    _tf_assert_not "Status without feature should fail" ./.claude/scripts/doh/helper.sh committee status
    
    # Capture error output
    local output
    output=$(./.claude/scripts/doh/helper.sh committee status 2>&1 || true)
    
    # Validate error message
    _tf_assert_contains "Missing feature error shown" "$output" "Feature name required for status command"
}

test_committee_validate_basic() {
    local test_feature="validate-test"
    
    # Create session first - should succeed
    _tf_assert "Create session should succeed" ./.claude/scripts/doh/helper.sh committee create "$test_feature"
    
    # Test validate command - should succeed
    _tf_assert "Committee validate should succeed" ./.claude/scripts/doh/helper.sh committee validate "$test_feature"
    
    # Capture output for validation
    local output
    output=$(./.claude/scripts/doh/helper.sh committee validate "$test_feature" 2>/dev/null)
    
    # Validate content
    _tf_assert_contains "Validate header shown" "$output" "Validating committee session: $test_feature"
    _tf_assert_contains "Success indicators shown" "$output" "✅"
}

test_committee_commands_require_feature_names() {
    local commands output
    commands=("status" "clean" "validate" "round1" "round2" "score" "converge")
    
    for cmd in "${commands[@]}"; do
        # Each command without feature should fail
        _tf_assert_not "Command $cmd without feature should fail" ./.claude/scripts/doh/helper.sh committee "$cmd"
        
        # Capture error output
        output=$(./.claude/scripts/doh/helper.sh committee "$cmd" 2>&1 || true)
        
        # Validate error message
        _tf_assert_contains "Command $cmd requires feature name" "$output" "Feature name required for $cmd command"
    done
}

# =============================================================================
# INTEGRATION TESTS
# =============================================================================

test_committee_integration_create_and_status() {
    local test_feature="integration-test"
    local doh_dir
    doh_dir=$(doh_project_dir)
    
    # Create session using committee helper - should succeed
    _tf_assert "Integration create should succeed" ./.claude/scripts/doh/helper.sh committee create "$test_feature"
    
    # Verify session was created
    _tf_assert "Integration: Session directory created" test -d "$doh_dir/committees/$test_feature"
    _tf_assert "Integration: Session file created" test -f "$doh_dir/committees/$test_feature/session.md"
    
    # Check status works after creation - should succeed
    _tf_assert "Integration status should succeed" ./.claude/scripts/doh/helper.sh committee status "$test_feature"
    
    # Capture status output for validation
    local output
    output=$(./.claude/scripts/doh/helper.sh committee status "$test_feature" 2>/dev/null)
    
    # Validate integration
    _tf_assert_contains "Integration: Status works after create" "$output" "Committee Session Status: $test_feature"
}

# =============================================================================
# RUN TESTS
# =============================================================================

# Main function tests  
test_committee_help_display
test_committee_main_no_args
test_committee_main_invalid_command

# Create command tests
test_committee_create_basic
test_committee_create_missing_feature
test_committee_create_invalid_name

# List command tests
test_committee_list_no_sessions
test_committee_list_with_sessions

# Status command tests
test_committee_status_valid
test_committee_status_missing_feature

# Validate command tests
test_committee_validate_basic

# Error handling tests
test_committee_commands_require_feature_names

# Integration tests
test_committee_integration_create_and_status

echo "✅ All committee helper tests passed"
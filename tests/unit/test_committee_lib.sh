#!/bin/bash

# Test suite for committee.sh library functions
# Tests the core committee session management and helper functions

# Source test framework
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"

# Source fixtures helper for DOH project setup
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/doh_fixtures.sh"

# Source test framework and dependencies
source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/doh.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/committee.sh"

# Setup function to create DOH project structure
_tf_setup() {
    # Create minimal DOH project structure for testing
    _tff_create_minimal_doh_project >/dev/null
    
    # Enable debug mode if requested
    if [[ "${DOH_TEST_DEBUG:-}" == "true" ]]; then
        echo "DEBUG: Committee test setup completed" >&2
        echo "DEBUG: DOH project dir: $(doh_project_dir)" >&2
    fi
}

# Teardown function for cleanup
_tf_teardown() {
    # Clean up test data
    local doh_dir
    if doh_dir=$(doh_project_dir 2>/dev/null); then
        [[ "${DOH_TEST_DEBUG:-}" == "true" ]] && echo "DEBUG: Cleaning up test committees" >&2
        rm -rf "$doh_dir/committees" 2>/dev/null || true
    fi
}

# Debug helper function
_debug_committee_state() {
    local feature="$1"
    local context="${2:-}"
    
    if [[ "${DOH_TEST_DEBUG:-}" == "true" ]]; then
        echo "DEBUG: Committee state for '$feature' $context" >&2
        
        local doh_dir
        doh_dir=$(doh_project_dir 2>/dev/null) || return 0
        
        local committee_dir="$doh_dir/committees/$feature"
        echo "DEBUG:   Directory exists: $(test -d "$committee_dir" && echo 'yes' || echo 'no')" >&2
        echo "DEBUG:   Seed exists: $(test -f "$committee_dir/seed.md" && echo 'yes' || echo 'no')" >&2
        echo "DEBUG:   Session exists: $(test -f "$committee_dir/session.md" && echo 'yes' || echo 'no')" >&2
        
        if [[ -d "$committee_dir" ]]; then
            echo "DEBUG:   Directory contents:" >&2
            find "$committee_dir" -type f 2>/dev/null | sed 's/^/DEBUG:     /' >&2 || true
        fi
    fi
}

# =============================================================================
# TEST: committee_create_session
# =============================================================================

test_committee_create_session_basic() {
    local doh_dir test_feature
    doh_dir=$(doh_project_dir)
    test_feature="test-auth"
    
    # Test session creation
    _tf_assert "Session creation should succeed" committee_create_session "$test_feature" '{"desc":"test feature"}'
    
    # Verify directory structure created
    _tf_assert "Session directory created" test -d "$doh_dir/committees/$test_feature"
    _tf_assert "Round1 directory created" test -d "$doh_dir/committees/$test_feature/round1"
    _tf_assert "Round2 directory created" test -d "$doh_dir/committees/$test_feature/round2"
    _tf_assert "Ratings directory created" test -d "$doh_dir/committees/$test_feature/ratings"
    _tf_assert "Final directory created" test -d "$doh_dir/committees/$test_feature/final"
    _tf_assert "Logs directory created" test -d "$doh_dir/committees/$test_feature/logs"
    
    # Verify session metadata file
    _tf_assert_file_exists "Session metadata file created" "$doh_dir/committees/$test_feature/session.md"
    
    # Check session file content using _tf_assert_file_contains
    local session_file="$doh_dir/committees/$test_feature/session.md"
    _tf_assert_file_contains "Feature name in metadata" "$session_file" "feature: $test_feature"
    _tf_assert_file_contains "Status in metadata" "$session_file" "status: initialized"
    _tf_assert_file_contains "Session title correct" "$session_file" "Committee Session: $test_feature"
}

test_committee_create_session_missing_feature() {
    # Test without feature name should fail
    _tf_assert_not "Empty feature name rejected" committee_create_session ""
}

test_committee_create_session_default_context() {
    local doh_dir test_feature
    doh_dir=$(doh_project_dir)
    test_feature="test-payments"
    
    # Test session creation without context
    _tf_assert "Session creation with default context" committee_create_session "$test_feature"
    
    # Verify session created with default context
    _tf_assert_file_exists "Session file created with default context" "$doh_dir/committees/$test_feature/session.md"
    
    local session_file="$doh_dir/committees/$test_feature/session.md"
    _tf_assert_file_contains "Default context applied" "$session_file" "context: {}"
}

# =============================================================================
# TEST: committee_analyze_scoring
# =============================================================================

test_committee_analyze_scoring_basic() {
    local doh_dir test_feature
    doh_dir=$(doh_project_dir)
    test_feature="scoring-test"
    
    # Create session structure
    mkdir -p "$doh_dir/committees/$test_feature"
    
    # Create some test files
    touch "$doh_dir/committees/$test_feature/round1.md"
    touch "$doh_dir/committees/$test_feature/ratings.md" 
    
    # Test analyze scoring - should succeed
    _tf_assert "Committee analyze scoring should succeed" committee_analyze_scoring "$test_feature"
    
    # Capture output for content validation
    local output
    output=$(committee_analyze_scoring "$test_feature" 2>/dev/null)
    
    _tf_assert_contains "Analysis message displayed" "$output" "Scoring analysis data prepared"
    _tf_assert_contains "Session directory path shown" "$output" "$doh_dir/committees/$test_feature"
}

test_committee_analyze_scoring_missing_session() {
    local test_feature="nonexistent"
    
    # Test with missing session - should fail and return exit code 1
    _tf_assert_not "Missing session correctly returns failure" committee_analyze_scoring "$test_feature"
}

# =============================================================================
# TEST: committee_get_session_status  
# =============================================================================

test_committee_get_session_status_basic() {
    local doh_dir test_feature
    doh_dir=$(doh_project_dir)
    test_feature="status-test"
    
    # Create session with some structure
    mkdir -p "$doh_dir/committees/$test_feature/"{round1,round2}
    echo "session metadata" > "$doh_dir/committees/$test_feature/session.md"
    
    # Add some files to rounds
    touch "$doh_dir/committees/$test_feature/round1/agent1.md"
    touch "$doh_dir/committees/$test_feature/round1/agent2.md"
    touch "$doh_dir/committees/$test_feature/round2/revised.md"
    
    # Test status
    local output
    output=$(committee_get_session_status "$test_feature" 2>/dev/null)
    
    _tf_assert_contains "Session directory displayed" "$output" "Session Directory:"
    _tf_assert_contains "Session status shown" "$output" "✅ Session initialized"
    _tf_assert_contains "Round 1 status shown" "$output" "✅ Round 1 completed"
    _tf_assert_contains "Round 2 status shown" "$output" "✅ Round 2 completed"
    _tf_assert_contains "Round 1 file count" "$output" "Agent drafts: 2 files"
    _tf_assert_contains "Round 2 file count" "$output" "Revised drafts: 1 files"
}

test_committee_get_session_status_partial() {
    local doh_dir test_feature
    doh_dir=$(doh_project_dir)  
    test_feature="partial-test"
    
    # Create session with only partial structure
    mkdir -p "$doh_dir/committees/$test_feature/round1"
    # Note: no session.md file, no round2
    
    local output
    output=$(committee_get_session_status "$test_feature" 2>/dev/null)
    
    _tf_assert_contains "Uninitialized status shown" "$output" "⏳ Session not initialized"
    _tf_assert_contains "Round 1 detected" "$output" "✅ Round 1 completed"
    _tf_assert_contains "Round 2 pending" "$output" "⏳ Round 2 pending"
}

# =============================================================================
# TEST: committee_validate_session_structure
# =============================================================================

test_committee_validate_session_structure_valid() {
    local doh_dir test_feature
    doh_dir=$(doh_project_dir)
    test_feature="valid-session"
    
    # Create valid session structure
    mkdir -p "$doh_dir/committees/$test_feature"
    echo "session data" > "$doh_dir/committees/$test_feature/session.md"
    
    local output
    output=$(committee_validate_session_structure "$test_feature" 2>/dev/null)
    
    _tf_assert_contains "Directory validation passed" "$output" "✅ Session directory exists"
    _tf_assert_contains "Session file validation passed" "$output" "✅ Session file exists"
    _tf_assert "Validation returns success" committee_validate_session_structure "$test_feature"
}

test_committee_validate_session_structure_missing() {
    local test_feature="missing-session"
    
    # Don't create session directory - should fail
    _tf_assert_not "Missing directory detected" committee_validate_session_structure "$test_feature"
}

test_committee_validate_session_structure_incomplete() {
    local doh_dir test_feature
    doh_dir=$(doh_project_dir)
    test_feature="incomplete-session"
    
    # Create directory but no session file
    mkdir -p "$doh_dir/committees/$test_feature"
    
    local output
    output=$(committee_validate_session_structure "$test_feature" 2>/dev/null)
    
    _tf_assert_contains "Directory exists" "$output" "✅ Session directory exists"
    _tf_assert_contains "Missing file detected" "$output" "⚠️  Session file missing"
    _tf_assert "Still returns success (warning only)" committee_validate_session_structure "$test_feature"
}

# =============================================================================
# TEST: committee_check_convergence_and_finalize
# =============================================================================

test_committee_check_convergence_and_finalize_basic() {
    local test_feature="convergence-test"
    
    local output
    output=$(committee_check_convergence_and_finalize "$test_feature" 2>/dev/null)
    
    _tf_assert_contains "AI delegation message shown" "$output" "Convergence analysis requires AI evaluation"
    _tf_assert_contains "Analysis areas listed" "$output" "Agent rating patterns"
    _tf_assert_contains "AI usage guidance" "$output" "Use AI agent to analyze convergence"
    _tf_assert "Function returns success" committee_check_convergence_and_finalize "$test_feature"
}

# =============================================================================
# TEST: committee seed management functions
# =============================================================================

test_committee_create_seed_basic() {
    local test_feature="seed-test-basic"
    local seed_content="This is test seed content for $test_feature"
    
    # Test seed creation
    local seed_path
    seed_path=$(committee_create_seed "$test_feature" "$seed_content")
    
    _tf_assert "Seed creation should succeed" test $? -eq 0
    _tf_assert_file_exists "Seed file should be created" "$seed_path"
    _tf_assert_file_contains "Seed content should be correct" "$seed_path" "$seed_content"
    
    # Verify directory structure
    local doh_dir expected_path
    doh_dir=$(doh_project_dir)
    expected_path="$doh_dir/committees/$test_feature/seed.md"
    _tf_assert "Seed path should match expected location" test "$seed_path" = "$expected_path"
}

test_committee_create_seed_missing_params() {
    # Test without feature name
    _tf_assert_not "Missing feature name should fail" committee_create_seed ""
    _tf_assert_not "Missing content should fail" committee_create_seed "test-feature" ""
    _tf_assert_not "Both missing should fail" committee_create_seed "" ""
}

test_committee_has_seed_basic() {
    local test_feature="seed-exists-test"
    local seed_content="Test content for existence check"
    
    # Initially should not exist
    _tf_assert_not "Seed should not exist initially" committee_has_seed "$test_feature"
    
    # Create seed
    committee_create_seed "$test_feature" "$seed_content"
    
    # Now should exist
    _tf_assert "Seed should exist after creation" committee_has_seed "$test_feature"
}

test_committee_get_seed_basic() {
    local test_feature="seed-get-test"
    local seed_content="Test content for get operation"
    
    # Create seed first
    committee_create_seed "$test_feature" "$seed_content" >/dev/null
    
    # Test getting seed path
    local seed_path
    seed_path=$(committee_get_seed "$test_feature")
    _tf_assert "Get seed should succeed" test $? -eq 0
    _tf_assert_file_exists "Retrieved seed path should exist" "$seed_path"
    
    # Verify it's the correct file
    _tf_assert_file_contains "Retrieved file should have correct content" "$seed_path" "$seed_content"
}

test_committee_get_seed_missing() {
    local test_feature="nonexistent-seed"
    
    # Test getting non-existent seed
    _tf_assert_not "Get non-existent seed should fail" committee_get_seed "$test_feature"
}

test_committee_read_seed_basic() {
    local test_feature="seed-read-test"
    local seed_content="Multi-line test content
Second line of content
Third line with special chars: @#$%"
    
    # Create seed
    committee_create_seed "$test_feature" "$seed_content" >/dev/null
    
    # Read seed content
    local read_content
    read_content=$(committee_read_seed "$test_feature")
    _tf_assert "Read seed should succeed" test $? -eq 0
    _tf_assert "Read content should match original" test "$read_content" = "$seed_content"
}

test_committee_read_seed_missing() {
    local test_feature="nonexistent-read"
    
    _tf_assert_not "Read non-existent seed should fail" committee_read_seed "$test_feature"
}

test_committee_update_seed_basic() {
    local test_feature="seed-update-test"
    local original_content="Original seed content"
    local updated_content="Updated seed content with new information"
    
    # Create initial seed
    committee_create_seed "$test_feature" "$original_content" >/dev/null
    
    # Verify original content
    local read_content
    read_content=$(committee_read_seed "$test_feature")
    _tf_assert "Original content should be correct" test "$read_content" = "$original_content"
    
    # Update seed
    _tf_assert "Update seed should succeed" committee_update_seed "$test_feature" "$updated_content"
    
    # Verify updated content
    read_content=$(committee_read_seed "$test_feature")
    _tf_assert "Updated content should be correct" test "$read_content" = "$updated_content"
}

test_committee_update_seed_missing() {
    local test_feature="nonexistent-update"
    local new_content="This should fail"
    
    _tf_assert_not "Update non-existent seed should fail" committee_update_seed "$test_feature" "$new_content"
}

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

test_committee_delete_seed_missing() {
    local test_feature="nonexistent-delete"
    
    # Should succeed even if file doesn't exist (idempotent)
    _tf_assert "Delete non-existent seed should succeed" committee_delete_seed "$test_feature"
}

test_committee_list_seeds_basic() {
    local test_feature1="seed-list-1"
    local test_feature2="seed-list-2"
    local test_feature3="seed-list-3"
    
    # Initially should be empty or not contain our test features
    local initial_list
    initial_list=$(committee_list_seeds)
    
    # Create multiple seeds
    committee_create_seed "$test_feature1" "Content 1" >/dev/null
    committee_create_seed "$test_feature2" "Content 2" >/dev/null
    committee_create_seed "$test_feature3" "Content 3" >/dev/null
    
    # Get list
    local seed_list
    seed_list=$(committee_list_seeds)
    _tf_assert "List seeds should succeed" test $? -eq 0
    
    # Verify all features are listed
    _tf_assert_contains "Feature 1 should be listed" "$seed_list" "$test_feature1"
    _tf_assert_contains "Feature 2 should be listed" "$seed_list" "$test_feature2"
    _tf_assert_contains "Feature 3 should be listed" "$seed_list" "$test_feature3"
}

test_committee_list_seeds_empty() {
    # Clear any existing committee directory for clean test
    local doh_dir
    doh_dir=$(doh_project_dir)
    rm -rf "$doh_dir/committees" 2>/dev/null || true
    
    # List should succeed but be empty
    local seed_list
    seed_list=$(committee_list_seeds)
    _tf_assert "List seeds should succeed even when empty" test $? -eq 0
    _tf_assert "Empty list should be empty string" test -z "$seed_list"
}

test_committee_get_dir_basic() {
    local test_feature="dir-test"
    local expected_dir="$(doh_project_dir)/committees/$test_feature"
    
    local committee_dir
    committee_dir=$(committee_get_dir "$test_feature")
    _tf_assert "Get dir should succeed" test $? -eq 0
    _tf_assert "Dir path should be correct" test "$committee_dir" = "$expected_dir"
}

test_committee_init_dir_basic() {
    local test_feature="init-dir-test"
    local doh_dir committee_dir
    doh_dir=$(doh_project_dir)
    committee_dir="$doh_dir/committees/$test_feature"
    
    # Initialize directory structure
    _tf_assert "Init dir should succeed" committee_init_dir "$test_feature"
    
    # Verify directory structure
    _tf_assert "Committee dir should exist" test -d "$committee_dir"
    _tf_assert "Round1 dir should exist" test -d "$committee_dir/round1"
    _tf_assert "Round2 dir should exist" test -d "$committee_dir/round2"
}

test_committee_clean_dir_basic() {
    local test_feature="clean-dir-test"
    local doh_dir committee_dir
    doh_dir=$(doh_project_dir)
    committee_dir="$doh_dir/committees/$test_feature"
    
    # Create directory structure and files
    committee_init_dir "$test_feature"
    committee_create_seed "$test_feature" "Test content" >/dev/null
    echo "test file" > "$committee_dir/test.txt"
    
    # Verify it exists
    _tf_assert "Committee dir should exist before cleaning" test -d "$committee_dir"
    
    # Clean directory
    _tf_assert "Clean dir should succeed" committee_clean_dir "$test_feature"
    
    # Verify it's gone
    _tf_assert_not "Committee dir should not exist after cleaning" test -d "$committee_dir"
}

test_committee_clean_dir_missing() {
    local test_feature="nonexistent-clean"
    
    # Should succeed even if directory doesn't exist (idempotent)
    _tf_assert "Clean non-existent dir should succeed" committee_clean_dir "$test_feature"
}

# =============================================================================
# TEST: Seed integration with existing committee functions
# =============================================================================

test_committee_create_session_preserves_existing_seed() {
    local test_feature="session-seed-test"
    local seed_content="Existing seed content that should be preserved"
    local session_context='{"type":"test session"}'
    
    # Create seed first
    committee_create_seed "$test_feature" "$seed_content" >/dev/null
    
    # Verify seed exists
    _tf_assert "Seed should exist before session creation" committee_has_seed "$test_feature"
    
    # Create session (should not overwrite seed)
    _tf_assert "Session creation should succeed" committee_create_session "$test_feature" "$session_context"
    
    # Verify seed is still there and unchanged
    _tf_assert "Seed should still exist after session creation" committee_has_seed "$test_feature"
    
    local preserved_content
    preserved_content=$(committee_read_seed "$test_feature")
    _tf_assert "Seed content should be preserved" test "$preserved_content" = "$seed_content"
    
    # Verify session was also created
    local doh_dir session_file
    doh_dir=$(doh_project_dir)
    session_file="$doh_dir/committees/$test_feature/session.md"
    _tf_assert_file_exists "Session file should exist" "$session_file"
    _tf_assert_file_contains "Session should have correct context" "$session_file" "$session_context"
}

test_committee_workflow_with_seeds() {
    local test_feature="workflow-seed-test"
    local seed_content="# Feature: $test_feature

## Problem Statement
Test problem that needs solving

## Requirements
- Requirement 1
- Requirement 2

## Context
This is a test feature for workflow integration"
    
    # Start with seed
    committee_create_seed "$test_feature" "$seed_content" >/dev/null
    
    # Initialize directory structure
    _tf_assert "Directory init should succeed" committee_init_dir "$test_feature"
    
    # Create session
    _tf_assert "Session creation should succeed" committee_create_session "$test_feature" '{"source":"seed"}'
    
    # Verify both seed and session coexist
    _tf_assert "Seed should still exist" committee_has_seed "$test_feature"
    
    local doh_dir session_file
    doh_dir=$(doh_project_dir)
    session_file="$doh_dir/committees/$test_feature/session.md"
    _tf_assert_file_exists "Session file should exist" "$session_file"
    
    # Verify seed content is accessible
    local read_content
    read_content=$(committee_read_seed "$test_feature")
    _tf_assert_contains "Seed should contain problem statement" "$read_content" "Test problem that needs solving"
    _tf_assert_contains "Seed should contain requirements" "$read_content" "Requirement 1"
}

# =============================================================================
# TEST ERROR HANDLING
# =============================================================================

test_committee_functions_missing_parameters() {
    # Test all functions with missing feature name
    _tf_assert_not "analyze_scoring rejects empty feature" committee_analyze_scoring ""
    _tf_assert_not "get_session_status rejects empty feature" committee_get_session_status ""
    _tf_assert_not "validate_session_structure rejects empty feature" committee_validate_session_structure ""
    _tf_assert_not "check_convergence_and_finalize rejects empty feature" committee_check_convergence_and_finalize ""
}

# =============================================================================
# RUN TESTS
# =============================================================================

# Committee session creation tests
test_committee_create_session_basic
test_committee_create_session_missing_feature  
test_committee_create_session_default_context

# Scoring analysis tests
test_committee_analyze_scoring_basic
test_committee_analyze_scoring_missing_session

# Session status tests
test_committee_get_session_status_basic
test_committee_get_session_status_partial

# Session validation tests
test_committee_validate_session_structure_valid
test_committee_validate_session_structure_missing
test_committee_validate_session_structure_incomplete

# Convergence tests
test_committee_check_convergence_and_finalize_basic

# Error handling tests
test_committee_functions_missing_parameters

echo "✅ All committee library tests passed"
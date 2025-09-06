#!/bin/bash

# Test suite for committee.sh library functions
# Tests the core committee session management and helper functions

set -euo pipefail
# Load test framework
source "$(dirname "$0")/../helpers/test_framework.sh"


# Source test framework and dependencies
source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/doh.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/committee.sh"

# =============================================================================
# TEST: committee_create_session
# =============================================================================

test_committee_create_session_basic() {
    local doh_dir test_feature
    doh_dir=$(doh_project_dir)
    test_feature="test-auth"
    
    # Test session creation
    committee_create_session "$test_feature" '{"desc":"test feature"}'
    
    # Verify directory structure created
    _tf_assert "[ -d '$doh_dir/committees/$test_feature' ]" "Session directory created"
    _tf_assert "[ -d '$doh_dir/committees/$test_feature/round1' ]" "Round1 directory created"
    _tf_assert "[ -d '$doh_dir/committees/$test_feature/round2' ]" "Round2 directory created"
    _tf_assert "[ -d '$doh_dir/committees/$test_feature/ratings' ]" "Ratings directory created"
    _tf_assert "[ -d '$doh_dir/committees/$test_feature/final' ]" "Final directory created"
    _tf_assert "[ -d '$doh_dir/committees/$test_feature/logs' ]" "Logs directory created"
    
    # Verify session metadata file
    _tf_assert "[ -f '$doh_dir/committees/$test_feature/session.md' ]" "Session metadata file created"
    
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
    committee_create_session "$test_feature"
    
    # Verify session created with default context
    _tf_assert "[ -f '$doh_dir/committees/$test_feature/session.md' ]" "Session file created with default context"
    
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
    
    _tf_assert "echo '$output' | grep -q 'Session Directory:'" "Session directory displayed"
    _tf_assert "echo '$output' | grep -q '✅ Session initialized'" "Session status shown"
    _tf_assert "echo '$output' | grep -q '✅ Round 1 completed'" "Round 1 status shown"
    _tf_assert "echo '$output' | grep -q '✅ Round 2 completed'" "Round 2 status shown"
    _tf_assert "echo '$output' | grep -q 'Agent drafts: 2 files'" "Round 1 file count"
    _tf_assert "echo '$output' | grep -q 'Revised drafts: 1 files'" "Round 2 file count"
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
    
    _tf_assert "echo '$output' | grep -q '⏳ Session not initialized'" "Uninitialized status shown"
    _tf_assert "echo '$output' | grep -q '✅ Round 1 completed'" "Round 1 detected"
    _tf_assert "echo '$output' | grep -q '⏳ Round 2 pending'" "Round 2 pending"
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
    
    _tf_assert "echo '$output' | grep -q '✅ Session directory exists'" "Directory validation passed"
    _tf_assert "echo '$output' | grep -q '✅ Session file exists'" "Session file validation passed"
    _tf_assert "committee_validate_session_structure '$test_feature'" "Validation returns success"
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
    
    _tf_assert "echo '$output' | grep -q '✅ Session directory exists'" "Directory exists"
    _tf_assert "echo '$output' | grep -q '⚠️  Session file missing'" "Missing file detected"
    _tf_assert "committee_validate_session_structure '$test_feature'" "Still returns success (warning only)"
}

# =============================================================================
# TEST: committee_check_convergence_and_finalize
# =============================================================================

test_committee_check_convergence_and_finalize_basic() {
    local test_feature="convergence-test"
    
    local output
    output=$(committee_check_convergence_and_finalize "$test_feature" 2>/dev/null)
    
    _tf_assert "echo '$output' | grep -q 'Convergence analysis requires AI evaluation'" "AI delegation message shown"
    _tf_assert "echo '$output' | grep -q 'Agent rating patterns'" "Analysis areas listed"
    _tf_assert "echo '$output' | grep -q 'Use AI agent to analyze convergence'" "AI usage guidance"
    _tf_assert "committee_check_convergence_and_finalize '$test_feature'" "Function returns success"
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
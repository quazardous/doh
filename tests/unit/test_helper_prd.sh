#!/bin/bash
# Test suite for PRD helper functions
# Tests: helper prd commands via helper.sh
#
# LEGITIMATE EXCEPTION: This test specifically tests the helper.sh wrapper script
# for PRD commands, so it appropriately uses ./.claude/scripts/doh/helper.sh
# instead of sourcing libraries directly.
#
# PATTERN: This test validates that PRD helper functions work through the helper.sh bootstrap.
# For testing individual PRD library functions, use direct library sourcing instead.

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

# IMPORTANT: Each test should be self-contained with local variables
# Avoid global variables - they create hidden dependencies between tests
# and make tests harder to understand and maintain

test_helper_prd_help() {
    # BEST PRACTICE: Test the helper.sh command directly with _tf_assert
    # This validates the wrapper script integration, not the underlying library
    _tf_assert "PRD help should succeed" ./.claude/scripts/doh/helper.sh prd help
    
    # Capture output for content validation
    local result
    result="$(./.claude/scripts/doh/helper.sh prd help 2>&1)"
    
    # Should contain expected help sections
    _tf_assert_contains "Should have header" "$result" "DOH PRD Management"
    _tf_assert_contains "Should have usage" "$result" "Usage:"
    _tf_assert_contains "Should list commands" "$result" "Commands:"
    _tf_assert_contains "Should include new command" "$result" "new"
    _tf_assert_contains "Should include parse command" "$result" "parse"
    _tf_assert_contains "Should include list command" "$result" "list"
    _tf_assert_contains "Should have examples" "$result" "Examples:"
}

test_helper_prd_list_empty() {
    # BEST PRACTICE: Each test is self-contained with all variables local
    # No dependency on global state or other tests
    
    # CRITICAL: Use DOH library function to get proper container path
    # This prevents creating artifacts in project root
    local doh_dir
    doh_dir=$(doh_project_dir)
    local prd_dir="$doh_dir/prds"
    
    # Clean and recreate PRD directory for this specific test
    rm -rf "$prd_dir"
    mkdir -p "$prd_dir"
    
    # PREFERRED: Direct command testing with _tf_assert
    _tf_assert "PRD list should succeed with empty directory" ./.claude/scripts/doh/helper.sh prd list
    
    # Capture output for content validation
    local result
    result="$(./.claude/scripts/doh/helper.sh prd list 2>&1)"
    _tf_assert_contains "Should show no PRDs message" "$result" "No PRDs found"
    
    # All variables are local - no cleanup needed
}

# Example of self-contained test with all local variables
test_helper_prd_list() {
    # BEST PRACTICE: Each test declares its own local variables
    # No dependency on global state or other tests
    
    # CRITICAL: Get proper DOH container path to prevent artifacts
    local doh_dir
    doh_dir=$(doh_project_dir)
    local prd_dir="$doh_dir/prds"
    
    # Clean and recreate PRD directory for this specific test
    rm -rf "$prd_dir"
    mkdir -p "$prd_dir"
    
    # Create test-specific PRD files with comprehensive scenarios
    local backlog_file="$prd_dir/test-backlog.md"
    cat > "$backlog_file" <<'EOF'
---
name: test-backlog
status: backlog
description: Test backlog PRD
---
# Test Backlog PRD
EOF
    
    local progress_file="$prd_dir/test-progress.md"
    cat > "$progress_file" <<'EOF'
---
name: test-progress
status: in-progress
description: Test in-progress PRD
---
# Test In-Progress PRD
EOF
    
    local implemented_file="$prd_dir/test-implemented.md"
    cat > "$implemented_file" <<'EOF'
---
name: test-implemented
status: implemented
description: Test implemented PRD
---
# Test Implemented PRD
EOF
    
    local draft_file="$prd_dir/test-draft.md"
    cat > "$draft_file" <<'EOF'
---
name: test-draft
status: draft
description: Test draft PRD
---
# Test Draft PRD
EOF
    
    # PREFERRED: Direct command testing with _tf_assert
    _tf_assert "PRD list should succeed" ./.claude/scripts/doh/helper.sh prd list
    
    # Capture output for content validation
    local result
    result="$(./.claude/scripts/doh/helper.sh prd list 2>&1)"
    
    # Check structure elements
    _tf_assert_contains "Should show PRD header" "$result" "📋 PRD List"
    _tf_assert_contains "Should show backlog section" "$result" "🔍 Backlog PRDs:"
    _tf_assert_contains "Should show in-progress section" "$result" "🔄 In-Progress PRDs:"
    _tf_assert_contains "Should show implemented section" "$result" "✅ Implemented PRDs:"
    _tf_assert_contains "Should show summary" "$result" "📊 PRD Summary"
    
    # Check PRDs are in correct sections
    _tf_assert_contains "Should list backlog PRD" "$result" "test-backlog.md - Test backlog PRD"
    _tf_assert_contains "Should list draft PRD as backlog" "$result" "test-draft.md - Test draft PRD"
    _tf_assert_contains "Should list in-progress PRD" "$result" "test-progress.md - Test in-progress PRD"
    _tf_assert_contains "Should list implemented PRD" "$result" "test-implemented.md - Test implemented PRD"
    
    # Check counts are accurate
    _tf_assert_contains "Should show total count" "$result" "Total PRDs: 4"
    _tf_assert_contains "Should show backlog count" "$result" "Backlog: 2"
    _tf_assert_contains "Should show in-progress count" "$result" "In-Progress: 1"
    _tf_assert_contains "Should show implemented count" "$result" "Implemented: 1"
    
    # All variables are local - no cleanup needed, no global pollution
}

test_helper_prd_list_no_description() {
    # BEST PRACTICE: Test edge cases with self-contained setup
    # CRITICAL: Use proper DOH container path to prevent artifacts
    local doh_dir
    doh_dir=$(doh_project_dir)
    local prd_dir="$doh_dir/prds"
    
    # Clean and recreate PRD directory
    rm -rf "$prd_dir"
    mkdir -p "$prd_dir"
    
    # Create PRD without description field (edge case)
    local no_desc_file="$prd_dir/test-no-desc.md"
    cat > "$no_desc_file" <<'EOF'
---
name: test-no-desc
status: backlog
---
# Test No Description
EOF
    
    # PREFERRED: Test command success directly
    _tf_assert "PRD list should succeed with missing description" ./.claude/scripts/doh/helper.sh prd list
    
    # Validate edge case handling
    local result
    result="$(./.claude/scripts/doh/helper.sh prd list 2>&1)"
    _tf_assert_contains "Should show no description placeholder" "$result" "test-no-desc.md - No description"
    
    # All variables are local - no cleanup needed
}

test_helper_prd_new_validation() {
    # BEST PRACTICE: Test expected failures with _tf_assert_not
    # This is cleaner than manual exit code checking
    _tf_assert_not "Should fail without PRD name" ./.claude/scripts/doh/helper.sh prd new
    
    # Validate error message content
    local result
    result="$(./.claude/scripts/doh/helper.sh prd new 2>&1)"
    _tf_assert_contains "Should show validation error" "$result" "Error:"
    
    # All variables are local - no cleanup needed
}

# ==============================================================================
# REQUIRED: Prevent direct execution
# ==============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
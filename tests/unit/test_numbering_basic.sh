#!/bin/bash
# Unit tests for DOH numbering library - Basic registry operations
# File version: 0.1.0 | Created: 2025-09-02

# Source the framework and helpers
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/doh_fixtures.sh"

# Source the library being tested
LIB_DIR="$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib"
source "$LIB_DIR/numbering.sh"

# Test environment setup
_tf_setup() {
    # Use DOH_PROJECT_DIR from test launcher (already set)
    # Create minimal DOH project structure in the isolated project directory
    _tff_create_minimal_doh_project >/dev/null
    
    # Set project name for workspace functions
    local project_dir=$(doh_project_dir)
    local project_name="test_project_$(basename "$project_dir")"
    export TEST_PROJECT_NAME="$project_name"
    
    # Override get_current_project_id for testing
    workspace_get_current_project_id() {
        echo "$TEST_PROJECT_NAME"
    }
}

_tf_teardown() {
    # Cleanup test environment
    unset TEST_PROJECT_NAME
    unset -f workspace_get_current_project_id
    # DOH_PROJECT_DIR cleanup is handled by test launcher
}

# Registry Creation Tests
test_registry_file_creation() {
    local registry_file
    registry_file="$(_numbering_ensure_registry)"
    
    _tf_assert_file_exists "Registry file should be created" "$registry_file"
}

test_taskseq_file_creation() {
    _numbering_ensure_registry  # Make sure registry exists first
    local taskseq_file
    taskseq_file="$(_numbering_get_taskseq_path)"
    
    _tf_assert_file_exists "TASKSEQ file should be created" "$taskseq_file"
}

test_initial_taskseq_value() {
    _numbering_ensure_registry
    local initial_seq
    initial_seq="$(numbering_get_current)"
    
    _tf_assert_equals "Initial sequence should be 0" "0" "$initial_seq"
}

test_registry_structure_validation() {
    local registry_file
    registry_file="$(_numbering_ensure_registry)"
    
    _tf_assert "Registry structure should be valid" _numbering_validate_registry_structure "$registry_file"
}

# Registry Statistics Tests
test_registry_statistics() {
    _numbering_ensure_registry
    local stats
    stats="$(numbering_get_stats)"
    
    _tf_assert_contains "Statistics should include sequence" "$stats" "Current Sequence:"
    _tf_assert_contains "Statistics should include epic count" "$stats" "Epics:"
    _tf_assert_contains "Statistics should include task count" "$stats" "Tasks:"
}

# Run tests if script executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
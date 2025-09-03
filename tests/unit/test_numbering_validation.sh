#!/bin/bash
# Unit tests for DOH numbering library - Validation and error handling
# File version: 0.1.0 | Created: 2025-09-02

# Source the framework and helpers
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/doh_fixtures.sh"

# Source the library being tested
LIB_DIR="$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib"
source "$LIB_DIR/numbering.sh"

# Test environment setup
_tf_setup() {
    # Use DOH_PROJECT_DIR from test launcher
    _tff_create_minimal_doh_project "$DOH_PROJECT_DIR" >/dev/null
    
    # Set project name for workspace functions
    local project_name="test_project_$(basename "$DOH_PROJECT_DIR")"
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
}

# Validation Tests  
test_valid_number_validation() {
    _numbering_ensure_registry
    
    _tf_assert "Should accept valid number" numbering_validate '999' 'epic'
}

test_negative_number_rejection() {
    _numbering_ensure_registry
    
    _tf_assert_not "Should reject negative number" numbering_validate '-1' 'epic'
}

test_used_number_rejection() {
    _numbering_ensure_registry
    local epic_number
    epic_number="$(numbering_get_next "epic")"
    
    numbering_register_epic "$epic_number" ".doh/epics/test-epic/epic.md" "test-epic"
    
    _tf_assert_not "Should reject already used number" numbering_validate "$epic_number" 'task'
}

test_quick_number_protection() {
    _numbering_ensure_registry
    
    _tf_assert_not "Should protect QUICK reserved number" numbering_validate '000' 'epic'
}

# Run tests if script executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
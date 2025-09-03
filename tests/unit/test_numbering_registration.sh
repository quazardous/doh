#!/bin/bash
# Unit tests for DOH numbering library - Registration operations
# File version: 0.1.0 | Created: 2025-09-02

# Source the framework and helpers
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/doh_fixtures.sh"

# Source the library being tested
LIB_DIR="$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib"
source "$LIB_DIR/numbering.sh"

# Test environment setup
_tf_setup() {
    # Use PROJECT_DOH_DIR from test launcher
    _tff_create_minimal_doh_project "$PROJECT_DOH_DIR" >/dev/null
    
    # Set project name for workspace functions
    local project_name="test_project_$(basename "$PROJECT_DOH_DIR")"
    export TEST_PROJECT_NAME="$project_name"
    
    # Override get_current_project_id for testing
    get_current_project_id() {
        echo "$TEST_PROJECT_NAME"
    }
}

_tf_teardown() {
    # Cleanup test environment
    unset TEST_PROJECT_NAME
    unset -f get_current_project_id
}

# Registration Tests
test_epic_registration() {
    _numbering_ensure_registry
    local epic_number
    epic_number="$(numbering_get_next "epic")"
    
    _tf_assert_command_succeeds "numbering_register_epic '$epic_number' '.doh/epics/test-epic/epic.md' 'test-epic'" "Epic registration should succeed"
}

test_task_registration() {
    local epic_number task_number
    epic_number="$(numbering_get_next "epic")"
    task_number="$(numbering_get_next "task")"
    
    numbering_register_epic "$epic_number" ".doh/epics/test-epic/epic.md" "test-epic"
    
    _tf_assert_command_succeeds "numbering_register_task '$task_number' '$epic_number' '.doh/epics/test-epic/$task_number.md' 'test-task' 'test-epic'" "Task registration should succeed"
}

test_duplicate_number_rejection() {
    local epic_number
    epic_number="$(numbering_get_next "epic")"
    
    # Register first epic
    numbering_register_epic "$epic_number" ".doh/epics/test-epic/epic.md" "test-epic"
    
    # Try to register duplicate
    _tf_assert_command_fails "numbering_register_epic '$epic_number' '.doh/epics/duplicate/epic.md' 'duplicate'" "Should reject duplicate number"
}

test_numbering_find_by_number() {
    local epic_number
    epic_number="$(numbering_get_next "epic")"
    
    numbering_register_epic "$epic_number" ".doh/epics/test-epic/epic.md" "test-epic"
    
    local found_epic
    found_epic="$(numbering_find_by_number "$epic_number")"
    
    _tf_assert_contains "$found_epic" "test-epic" "Should find registered epic"
}

# Run tests if script executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
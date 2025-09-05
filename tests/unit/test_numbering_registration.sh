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
    # Use DOH_PROJECT_DIR from test launcher
    _tff_create_minimal_doh_project >/dev/null
    
    # Set project name for workspace functions
    local project_name="test_project_$(basename "$DOH_PROJECT_DIR")"
    export TEST_PROJECT_NAME="$project_name"
    
    # Override doh_project_id for testing
    doh_project_id() {
        echo "$TEST_PROJECT_NAME"
    }
}

_tf_teardown() {
    # Cleanup test environment
    unset TEST_PROJECT_NAME
    unset -f doh_project_id
}

# Helper to reset numbering sequence and registry
_tf_reset_numbering() {
    local taskseq_file="$(_numbering_get_taskseq_path)"
    if [[ -f "$taskseq_file" ]]; then
        echo "0" > "$taskseq_file"
    fi
    
    # Also reset the registry
    local registry_file="$(_numbering_get_registry_path)"
    if [[ -f "$registry_file" ]]; then
        rm -f "$registry_file"
    fi
}

# Registration Tests
test_epic_registration() {
    _tf_reset_numbering
    _numbering_ensure_registry
    local epic_number
    epic_number="$(numbering_get_next "epic")"
    
    _tf_assert "Epic registration should succeed" numbering_register_epic "$epic_number" '.doh/epics/test-epic/epic.md' 'test-epic'
}

test_task_registration() {
    _tf_reset_numbering
    local epic_number task_number
    epic_number="$(numbering_get_next "epic")"
    task_number="$(numbering_get_next "task")"
    
    numbering_register_epic "$epic_number" ".doh/epics/test-epic/epic.md" "test-epic"
    
    _tf_assert "Task registration should succeed" numbering_register_task "$task_number" "$epic_number" ".doh/epics/test-epic/$task_number.md" 'test-task' 'test-epic'
}

test_duplicate_number_rejection() {
    _tf_reset_numbering
    local epic_number
    epic_number="$(numbering_get_next "epic")"
    
    # Register first epic
    numbering_register_epic "$epic_number" ".doh/epics/test-epic/epic.md" "test-epic"
    
    # Try to register duplicate
    _tf_assert_not "Should reject duplicate number" numbering_register_epic "$epic_number" '.doh/epics/duplicate/epic.md' 'duplicate'
}

test_numbering_find_by_number() {
    _tf_reset_numbering
    local epic_number
    epic_number="$(numbering_get_next "epic")"
    
    numbering_register_epic "$epic_number" ".doh/epics/test-epic/epic.md" "test-epic"
    
    local found_epic
    found_epic="$(numbering_find_by_number "$epic_number")"
    
    _tf_assert_contains "Should find registered epic" "$found_epic" "test-epic"
}

# Run tests if script executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
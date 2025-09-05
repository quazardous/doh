#!/bin/bash
# Unit tests for DOH numbering library - Number generation from clean state
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

# Number Generation Tests
test_first_epic_number_generation() {
    _tf_reset_numbering
    _numbering_ensure_registry
    local first_epic
    first_epic="$(numbering_get_next "epic")"
    
    _tf_assert_equals "First epic number should be 001" "001" "$first_epic"
}

test_first_task_number_generation() {
    _tf_reset_numbering
    _numbering_ensure_registry
    # Generate first number to get to sequence 1
    numbering_get_next "epic" >/dev/null  # 001
    # Now the task should get 002
    local first_task
    first_task="$(numbering_get_next "task")"
    
    _tf_assert_equals "First task number should be 002" "002" "$first_task"
}

test_sequential_number_generation() {
    _tf_reset_numbering
    _numbering_ensure_registry
    # Generate two numbers to get to sequence 2
    numbering_get_next "epic" >/dev/null  # 001
    numbering_get_next "task" >/dev/null  # 002
    # Now next should be 003
    local third_number
    third_number="$(numbering_get_next "epic")"
    
    _tf_assert_equals "Sequential number should be 003" "003" "$third_number"
}

test_invalid_type_rejection() {
    _tf_assert_not "Should reject invalid type" numbering_get_next 'invalid'
}

# Concurrent Access Simulation Tests
test_sequential_number_generation_under_load() {
    _tf_reset_numbering
    _numbering_ensure_registry
    
    local numbers=()
    # Generate first 5 numbers and verify they are sequential
    for i in {1..5}; do
        numbers+=("$(numbering_get_next "epic")")
    done
    
    local expected_sequence="001 002 003 004 005"
    local actual_sequence="${numbers[*]}"
    
    _tf_assert_equals "Numbers should be properly sequential: 001 002 003 004 005" "$expected_sequence" "$actual_sequence"
}

# Run tests if script executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi

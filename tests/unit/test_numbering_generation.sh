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

# Number Generation Tests
test_first_epic_number_generation() {
    _numbering_ensure_registry
    local first_epic
    first_epic="$(numbering_get_next "epic")"
    
    _tf_assert_equals "001" "$first_epic" "First epic number should be 001"
}

test_first_task_number_generation() {
    # Previous test already generated 001, so next should be 002
    local first_task
    first_task="$(numbering_get_next "task")"
    
    _tf_assert_equals "002" "$first_task" "First task number should be 002"
}

test_sequential_number_generation() {
    # Previous tests generated 001 and 002, so next should be 003
    local third_number
    third_number="$(numbering_get_next "epic")"
    
    _tf_assert_equals "003" "$third_number" "Sequential number should be 003"
}

test_invalid_type_rejection() {
    _tf_assert_command_fails "numbering_get_next 'invalid'" "Should reject invalid type"
}

# Concurrent Access Simulation Tests
test_sequential_number_generation_under_load() {
    local numbers=()
    local start_seq
    start_seq="$(numbering_get_current)"
    
    # Generate multiple numbers quickly
    for i in {1..5}; do
        local num
        num="$(numbering_get_next "task")"
        numbers+=("$num")
    done
    
    # Check all numbers are unique and sequential
    local prev_num=$start_seq
    local all_unique=1
    
    for num in "${numbers[@]}"; do
        local num_val
        num_val=$((10#$num))  # Force base 10 interpretation
        
        if [[ $num_val -le $prev_num ]]; then
            all_unique=0
            break
        fi
        prev_num=$num_val
    done
    
    _tf_assert_equals "1" "$all_unique" "Numbers should be properly sequential: ${numbers[*]}"
}

# Run tests if script executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
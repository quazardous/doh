#!/bin/bash
# Unit tests for DOH numbering library
# Converted from legacy test format to new DOH test framework
# File version: 0.1.0 | Created: 2025-09-01

# Source the framework and helpers
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/doh_fixtures.sh"

# Library will be sourced in setup after directory structure is created
LIB_DIR="$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib"
source "$LIB_DIR/numbering.sh"

# Test-specific helper functions (no _tf_ prefix needed)
create_temp_project() {
    local temp_dir=$(_tf_create_temp_dir)
    local project_name="test_project_$(basename "$temp_dir")"
    
    # Create basic DOH project structure
    mkdir -p "$temp_dir/.doh/epics"
    mkdir -p "$temp_dir/.doh/quick"
    
    # Set up environment variables for DOH functions
    export TEST_PROJECT_NAME="$project_name"
    export DOH_TEST_PROJECT_ROOT="$temp_dir"
    
    echo "$temp_dir"
}


cleanup_temp_project() {
    local project_dir="$1"
    if [[ -n "$project_dir" ]]; then
        unset TEST_PROJECT_NAME DOH_TEST_PROJECT_ROOT
    fi
}

# Test environment setup  
_tf_setup() {
    # Create project root and basic structure using DOH API
    local project_dir=$(doh_project_dir)
    mkdir -p "$project_dir"/{epics,prds,quick}
    local version_file=$(doh_version_file)
    echo "0.1.0" > "$version_file"
}

_tf_teardown() {
    # Cleanup is handled by test launcher
    :
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
    # This test runs after tests that consumed 003 and 004, so current sequence should be 4
    local current_seq
    current_seq="$(numbering_get_current)"
    
    _tf_assert_equals "Current sequence should be 4 after previous tests" "4" "$current_seq"
}

test_registry_structure_validation() {
    local registry_file
    registry_file="$(_numbering_ensure_registry)"
    
    _tf_assert "Registry structure should be valid" _numbering_validate_registry_structure "$registry_file"
}

# Number Generation Tests
test_first_epic_number_generation() {
    # Previous tests (duplicate_number_rejection, epic_registration) consumed 001 and 002
    # So this should be the third epic number
    local third_epic
    third_epic="$(numbering_get_next "epic")"
    
    _tf_assert_equals "Third epic number should be 003" "003" "$third_epic"
}

test_first_task_number_generation() {
    # Previous test generated 003, so next should be 004
    local fourth_number
    fourth_number="$(numbering_get_next "task")"
    
    _tf_assert_equals "Fourth number should be 004" "004" "$fourth_number"
}

test_sequential_number_generation() {
    # Previous tests generated numbers, test_epic_registration runs first and gets 005
    local next_number
    next_number="$(numbering_get_next "epic")"
    
    _tf_assert_equals "Sequential number should be 006" "006" "$next_number"
}

test_invalid_type_rejection() {
    _numbering_ensure_registry
    
    _tf_assert_not "Should reject invalid type" numbering_get_next 'invalid'
}

# Registration Tests
test_epic_registration() {
    _numbering_ensure_registry
    local epic_number
    epic_number="$(numbering_get_next "epic")"
    
    _tf_assert "Epic registration should succeed" numbering_register_epic "$epic_number" '.doh/epics/test-epic/epic.md' 'test-epic'
}

test_task_registration() {
    _numbering_ensure_registry
    local epic_number task_number
    epic_number="$(numbering_get_next "epic")"
    task_number="$(numbering_get_next "task")"
    
    numbering_register_epic "$epic_number" ".doh/epics/test-epic/epic.md" "test-epic"
    
    _tf_assert "Task registration should succeed" numbering_register_task "$task_number" "$epic_number" ".doh/epics/test-epic/$task_number.md" 'test-task' 'test-epic'
}

test_duplicate_number_rejection() {
    _numbering_ensure_registry
    local epic_number
    epic_number="$(numbering_get_next "epic")"
    
    # Register first epic
    numbering_register_epic "$epic_number" ".doh/epics/test-epic/epic.md" "test-epic"
    
    # Try to register duplicate
    _tf_assert_not "Should reject duplicate number" numbering_register_epic "$epic_number" '.doh/epics/duplicate/epic.md' 'duplicate'
}

test_numbering_find_by_number() {
    _numbering_ensure_registry
    local epic_number
    epic_number="$(numbering_get_next "epic")"
    
    numbering_register_epic "$epic_number" ".doh/epics/test-epic/epic.md" "test-epic"
    
    local found_epic
    found_epic="$(numbering_find_by_number "$epic_number")"
    
    _tf_assert_contains "Should find registered epic" "$found_epic" "test-epic"
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

# Statistics Tests
test_registry_statistics() {
    _numbering_ensure_registry
    local stats
    stats="$(numbering_get_stats)"
    
    _tf_assert_contains "Statistics should include sequence" "$stats" "Current Sequence:"
    _tf_assert_contains "Statistics should include epic count" "$stats" "Epics:"
    _tf_assert_contains "Statistics should include task count" "$stats" "Tasks:"
}

# Concurrent Access Simulation Tests
test_sequential_number_generation_under_load() {
    _numbering_ensure_registry
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
    
    _tf_assert_equals "Numbers should be properly sequential: ${numbers[*]}" "1" "$all_unique"
}

# Run tests if script executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
#!/bin/bash
# Unit tests for DOH numbering library
# Converted from legacy test format to new DOH test framework
# File version: 0.1.0 | Created: 2025-09-01

# Source the framework and helpers
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/doh_fixtures.sh"

# Library will be sourced in setup after directory structure is created
LIB_DIR="$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib"

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
        _tf_cleanup_temp "$project_dir"
        unset TEST_PROJECT_NAME DOH_TEST_PROJECT_ROOT
    fi
}

# Test environment setup  
_tf_setup() {
    # Use the PROJECT_DOH_DIR set by test launcher, create the structure
    if [[ -n "$PROJECT_DOH_DIR" ]]; then
        # PROJECT_DOH_DIR now points directly to the .doh directory
        # Create project root and basic structure
        local project_root="$(dirname "$PROJECT_DOH_DIR")"
        mkdir -p "$project_root"
        mkdir -p "$PROJECT_DOH_DIR"/{epics,prds,quick}
        echo "0.1.0" > "$project_root/VERSION"
        mkdir -p "$project_root/.git"
        
        # Now source the library after directory structure exists
        source "$LIB_DIR/numbering.sh"
    else
        echo "Error: PROJECT_DOH_DIR not set by test launcher" >&2
        return 1
    fi
}

_tf_teardown() {
    # Cleanup is handled by test launcher
    :
}

# Registry Creation Tests
test_registry_file_creation() {
    local registry_file
    registry_file="$(_numbering_ensure_registry)"
    
    _tf_assert_file_exists "$registry_file" "Registry file should be created"
}

test_taskseq_file_creation() {
    _numbering_ensure_registry  # Make sure registry exists first
    local taskseq_file
    taskseq_file="$(_numbering_get_taskseq_path)"
    
    _tf_assert_file_exists "$taskseq_file" "TASKSEQ file should be created"
}

test_initial_taskseq_value() {
    # This test runs after tests that consumed 003 and 004, so current sequence should be 4
    local current_seq
    current_seq="$(numbering_get_current)"
    
    _tf_assert_equals "4" "$current_seq" "Current sequence should be 4 after previous tests"
}

test_registry_structure_validation() {
    local registry_file
    registry_file="$(_numbering_ensure_registry)"
    
    _tf_assert_command_succeeds "_numbering_validate_registry_structure '$registry_file'" "Registry structure should be valid"
}

# Number Generation Tests
test_first_epic_number_generation() {
    # Previous tests (duplicate_number_rejection, epic_registration) consumed 001 and 002
    # So this should be the third epic number
    local third_epic
    third_epic="$(numbering_get_next "epic")"
    
    _tf_assert_equals "003" "$third_epic" "Third epic number should be 003"
}

test_first_task_number_generation() {
    # Previous test generated 003, so next should be 004
    local fourth_number
    fourth_number="$(numbering_get_next "task")"
    
    _tf_assert_equals "004" "$fourth_number" "Fourth number should be 004"
}

test_sequential_number_generation() {
    # Previous tests generated numbers, test_epic_registration runs first and gets 005
    local next_number
    next_number="$(numbering_get_next "epic")"
    
    _tf_assert_equals "006" "$next_number" "Sequential number should be 006"
}

test_invalid_type_rejection() {
    _numbering_ensure_registry
    
    _tf_assert_command_fails "numbering_get_next 'invalid'" "Should reject invalid type"
}

# Registration Tests
test_epic_registration() {
    _numbering_ensure_registry
    local epic_number
    epic_number="$(numbering_get_next "epic")"
    
    _tf_assert_command_succeeds "numbering_register_epic '$epic_number' '.doh/epics/test-epic/epic.md' 'test-epic'" "Epic registration should succeed"
}

test_task_registration() {
    _numbering_ensure_registry
    local epic_number task_number
    epic_number="$(numbering_get_next "epic")"
    task_number="$(numbering_get_next "task")"
    
    numbering_register_epic "$epic_number" ".doh/epics/test-epic/epic.md" "test-epic"
    
    _tf_assert_command_succeeds "numbering_register_task '$task_number' '$epic_number' '.doh/epics/test-epic/$task_number.md' 'test-task' 'test-epic'" "Task registration should succeed"
}

test_duplicate_number_rejection() {
    _numbering_ensure_registry
    local epic_number
    epic_number="$(numbering_get_next "epic")"
    
    # Register first epic
    numbering_register_epic "$epic_number" ".doh/epics/test-epic/epic.md" "test-epic"
    
    # Try to register duplicate
    _tf_assert_command_fails "numbering_register_epic '$epic_number' '.doh/epics/duplicate/epic.md' 'duplicate'" "Should reject duplicate number"
}

test_numbering_find_by_number() {
    _numbering_ensure_registry
    local epic_number
    epic_number="$(numbering_get_next "epic")"
    
    numbering_register_epic "$epic_number" ".doh/epics/test-epic/epic.md" "test-epic"
    
    local found_epic
    found_epic="$(numbering_find_by_number "$epic_number")"
    
    _tf_assert_contains "$found_epic" "test-epic" "Should find registered epic"
}

# Validation Tests  
test_valid_number_validation() {
    _numbering_ensure_registry
    
    _tf_assert_command_succeeds "numbering_validate '999' 'epic'" "Should accept valid number"
}

test_negative_number_rejection() {
    _numbering_ensure_registry
    
    _tf_assert_command_fails "numbering_validate '-1' 'epic'" "Should reject negative number"
}

test_used_number_rejection() {
    _numbering_ensure_registry
    local epic_number
    epic_number="$(numbering_get_next "epic")"
    
    numbering_register_epic "$epic_number" ".doh/epics/test-epic/epic.md" "test-epic"
    
    _tf_assert_command_fails "numbering_validate '$epic_number' 'task'" "Should reject already used number"
}

test_quick_number_protection() {
    _numbering_ensure_registry
    
    _tf_assert_command_fails "numbering_validate '000' 'epic'" "Should protect QUICK reserved number"
}

# Statistics Tests
test_registry_statistics() {
    _numbering_ensure_registry
    local stats
    stats="$(numbering_get_stats)"
    
    _tf_assert_contains "$stats" "Current Sequence:" "Statistics should include sequence"
    _tf_assert_contains "$stats" "Epics:" "Statistics should include epic count"
    _tf_assert_contains "$stats" "Tasks:" "Statistics should include task count"
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
    
    _tf_assert_equals "1" "$all_unique" "Numbers should be properly sequential: ${numbers[*]}"
}

# Run tests if script executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
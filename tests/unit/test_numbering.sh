#!/bin/bash
# Unit tests for DOH numbering library
# Converted from legacy test format to new DOH test framework
# File version: 0.1.0 | Created: 2025-09-01

# Source the framework and helpers
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/tf.sh"

# Source the library being tested
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
        _tf_cleanup_temp "$project_dir"
        unset TEST_PROJECT_NAME DOH_TEST_PROJECT_ROOT
    fi
}

# Test environment setup
_tf_setup() {
    # Create a temporary test project using helper
    local temp_dir=$(_tf_create_temp_dir)
    local project_name="test_project_$(basename "$temp_dir")"
    
    # Create basic DOH project structure
    mkdir -p "$temp_dir/.doh/epics"
    mkdir -p "$temp_dir/.doh/quick"
    
    # Set up environment variables for DOH functions
    export TEST_PROJECT_NAME="$project_name"
    export DOH_TEST_PROJECT_ROOT="$temp_dir"
    export TEST_TEMP_DIR="$temp_dir"
    
    # Override get_current_project_id for testing
    get_current_project_id() {
        echo "$TEST_PROJECT_NAME"
    }
}

_tf_teardown() {
    # Cleanup test environment using helper
    cleanup_temp_project "$TEST_TEMP_DIR"
}

# Registry Creation Tests
test_registry_file_creation() {
    local registry_file
    registry_file="$(ensure_registry)"
    
    _tf_assert_file_exists "$registry_file" "Registry file should be created"
}

test_taskseq_file_creation() {
    ensure_registry  # Make sure registry exists first
    local taskseq_file
    taskseq_file="$(get_taskseq_path)"
    
    _tf_assert_file_exists "$taskseq_file" "TASKSEQ file should be created"
}

test_initial_taskseq_value() {
    ensure_registry
    local initial_seq
    initial_seq="$(get_current_sequence)"
    
    _tf_assert_equals "0" "$initial_seq" "Initial sequence should be 0"
}

test_registry_structure_validation() {
    local registry_file
    registry_file="$(ensure_registry)"
    
    _tf_assert_command_succeeds "validate_registry_structure '$registry_file'" "Registry structure should be valid"
}

# Number Generation Tests
test_first_epic_number_generation() {
    ensure_registry
    local first_epic
    first_epic="$(get_next_number "epic")"
    
    _tf_assert_equals "001" "$first_epic" "First epic number should be 001"
}

test_first_task_number_generation() {
    ensure_registry
    # Generate epic first to advance sequence
    get_next_number "epic" >/dev/null
    
    local first_task
    first_task="$(get_next_number "task")"
    
    _tf_assert_equals "002" "$first_task" "First task number should be 002"
}

test_sequential_number_generation() {
    ensure_registry
    # Generate two numbers to set up sequence
    get_next_number "epic" >/dev/null
    get_next_number "task" >/dev/null
    
    local second_epic
    second_epic="$(get_next_number "epic")"
    
    _tf_assert_equals "003" "$second_epic" "Sequential number should be 003"
}

test_invalid_type_rejection() {
    ensure_registry
    
    _tf_assert_command_fails "get_next_number 'invalid'" "Should reject invalid type"
}

# Registration Tests
test_epic_registration() {
    ensure_registry
    local epic_number
    epic_number="$(get_next_number "epic")"
    
    _tf_assert_command_succeeds "register_epic '$epic_number' '.doh/epics/test-epic/epic.md' 'test-epic'" "Epic registration should succeed"
}

test_task_registration() {
    ensure_registry
    local epic_number task_number
    epic_number="$(get_next_number "epic")"
    task_number="$(get_next_number "task")"
    
    register_epic "$epic_number" ".doh/epics/test-epic/epic.md" "test-epic"
    
    _tf_assert_command_succeeds "register_task '$task_number' '$epic_number' '.doh/epics/test-epic/$task_number.md' 'test-task' 'test-epic'" "Task registration should succeed"
}

test_duplicate_number_rejection() {
    ensure_registry
    local epic_number
    epic_number="$(get_next_number "epic")"
    
    # Register first epic
    register_epic "$epic_number" ".doh/epics/test-epic/epic.md" "test-epic"
    
    # Try to register duplicate
    _tf_assert_command_fails "register_epic '$epic_number' '.doh/epics/duplicate/epic.md' 'duplicate'" "Should reject duplicate number"
}

test_find_by_number() {
    ensure_registry
    local epic_number
    epic_number="$(get_next_number "epic")"
    
    register_epic "$epic_number" ".doh/epics/test-epic/epic.md" "test-epic"
    
    local found_epic
    found_epic="$(find_by_number "$epic_number")"
    
    _tf_assert_contains "$found_epic" "test-epic" "Should find registered epic"
}

# Validation Tests  
test_valid_number_validation() {
    ensure_registry
    
    _tf_assert_command_succeeds "validate_number '999' 'epic'" "Should accept valid number"
}

test_negative_number_rejection() {
    ensure_registry
    
    _tf_assert_command_fails "validate_number '-1' 'epic'" "Should reject negative number"
}

test_used_number_rejection() {
    ensure_registry
    local epic_number
    epic_number="$(get_next_number "epic")"
    
    register_epic "$epic_number" ".doh/epics/test-epic/epic.md" "test-epic"
    
    _tf_assert_command_fails "validate_number '$epic_number' 'task'" "Should reject already used number"
}

test_quick_number_protection() {
    ensure_registry
    
    _tf_assert_command_fails "validate_number '000' 'epic'" "Should protect QUICK reserved number"
}

# Statistics Tests
test_registry_statistics() {
    ensure_registry
    local stats
    stats="$(get_registry_stats)"
    
    _tf_assert_contains "$stats" "Current Sequence:" "Statistics should include sequence"
    _tf_assert_contains "$stats" "Epics:" "Statistics should include epic count"
    _tf_assert_contains "$stats" "Tasks:" "Statistics should include task count"
}

# Concurrent Access Simulation Tests
test_sequential_number_generation_under_load() {
    ensure_registry
    local numbers=()
    local start_seq
    start_seq="$(get_current_sequence)"
    
    # Generate multiple numbers quickly
    for i in {1..5}; do
        local num
        num="$(get_next_number "task")"
        numbers+=("$num")
    done
    
    # Check all numbers are unique and sequential
    local prev_num=$start_seq
    local all_unique=1
    
    for num in "${numbers[@]}"; do
        local num_val
        num_val=$(printf "%d" "$num")
        
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
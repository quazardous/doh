#!/bin/bash

# Unit tests for numbering library
# Usage: ./numbering-test.sh

set -e

# Source the library
LIB_DIR="$(dirname "$0")/../lib"
source "$LIB_DIR/numbering.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test helper functions
print_test_header() {
    echo -e "\n${YELLOW}=== $1 ===${NC}"
}

print_test() {
    echo -n "  Testing: $1 ... "
    ((TESTS_RUN++))
}

pass_test() {
    echo -e "${GREEN}PASS${NC}"
    ((TESTS_PASSED++))
}

fail_test() {
    echo -e "${RED}FAIL${NC}"
    if [[ -n "$1" ]]; then
        echo -e "    ${RED}Error: $1${NC}"
    fi
    ((TESTS_FAILED++))
}

# Cleanup function
cleanup_test_env() {
    local test_project_id="test_$(date +%s)_$$"
    local test_dir="$HOME/.doh/projects/$test_project_id"
    
    if [[ -d "$test_dir" ]]; then
        rm -rf "$test_dir"
    fi
}

# Setup test environment
setup_test_env() {
    # Create a temporary test project
    export DOH_TEST_PROJECT_ID="test_$(date +%s)_$$"
    export DOH_TEST_DIR="$HOME/.doh/projects/$DOH_TEST_PROJECT_ID"
    
    # Override get_current_project_id for testing
    get_current_project_id() {
        echo "$DOH_TEST_PROJECT_ID"
    }
    
    mkdir -p "$DOH_TEST_DIR"
    echo "Test environment setup: $DOH_TEST_DIR"
}

# Test basic registry creation
test_registry_creation() {
    print_test_header "Registry Creation Tests"
    
    print_test "Registry file creation"
    local registry_file
    registry_file="$(ensure_registry)"
    
    if [[ -f "$registry_file" ]]; then
        pass_test
    else
        fail_test "Registry file not created"
        return
    fi
    
    print_test "TASKSEQ file creation"
    local taskseq_file
    taskseq_file="$(get_taskseq_path)"
    
    if [[ -f "$taskseq_file" ]]; then
        pass_test
    else
        fail_test "TASKSEQ file not created"
        return
    fi
    
    print_test "Initial TASKSEQ value"
    local initial_seq
    initial_seq="$(get_current_sequence)"
    
    if [[ "$initial_seq" == "0" ]]; then
        pass_test
    else
        fail_test "Expected initial sequence 0, got: $initial_seq"
    fi
    
    print_test "Registry structure validation"
    if validate_registry_structure "$registry_file"; then
        pass_test
    else
        fail_test "Registry structure validation failed"
    fi
}

# Test number generation
test_number_generation() {
    print_test_header "Number Generation Tests"
    
    print_test "First epic number generation"
    local first_epic
    first_epic="$(get_next_number "epic")"
    
    if [[ "$first_epic" == "001" ]]; then
        pass_test
    else
        fail_test "Expected 001, got: $first_epic"
    fi
    
    print_test "First task number generation"
    local first_task
    first_task="$(get_next_number "task")"
    
    if [[ "$first_task" == "002" ]]; then
        pass_test
    else
        fail_test "Expected 002, got: $first_task"
    fi
    
    print_test "Sequential number generation"
    local second_epic
    second_epic="$(get_next_number "epic")"
    
    if [[ "$second_epic" == "003" ]]; then
        pass_test
    else
        fail_test "Expected 003, got: $second_epic"
    fi
    
    print_test "Invalid type rejection"
    local invalid_result
    invalid_result="$(get_next_number "invalid" 2>&1)"
    
    if [[ $? -ne 0 && "$invalid_result" == *"Invalid type"* ]]; then
        pass_test
    else
        fail_test "Should reject invalid type"
    fi
}

# Test registration functions
test_registration() {
    print_test_header "Registration Tests"
    
    print_test "Epic registration"
    if register_epic "004" ".doh/epics/test-epic/epic.md" "test-epic"; then
        pass_test
    else
        fail_test "Epic registration failed"
    fi
    
    print_test "Task registration"
    if register_task "005" "004" ".doh/epics/test-epic/005.md" "test-task" "test-epic"; then
        pass_test
    else
        fail_test "Task registration failed"
    fi
    
    print_test "Duplicate number rejection"
    if ! register_epic "004" ".doh/epics/duplicate/epic.md" "duplicate" 2>/dev/null; then
        pass_test
    else
        fail_test "Should reject duplicate number"
    fi
    
    print_test "Find by number"
    local found_epic
    found_epic="$(find_by_number "004")"
    
    if [[ "$found_epic" == *"test-epic"* ]]; then
        pass_test
    else
        fail_test "Could not find registered epic"
    fi
}

# Test validation functions
test_validation() {
    print_test_header "Validation Tests"
    
    print_test "Valid number validation"
    if validate_number "999" "epic"; then
        pass_test
    else
        fail_test "Should accept valid number"
    fi
    
    print_test "Negative number rejection"
    if ! validate_number "-1" "epic" 2>/dev/null; then
        pass_test
    else
        fail_test "Should reject negative number"
    fi
    
    print_test "Used number rejection"
    if ! validate_number "004" "task" 2>/dev/null; then
        pass_test
    else
        fail_test "Should reject already used number"
    fi
    
    print_test "QUICK number protection"
    if ! validate_number "000" "epic" 2>/dev/null; then
        pass_test
    else
        fail_test "Should protect QUICK reserved number"
    fi
}

# Test statistics
test_statistics() {
    print_test_header "Statistics Tests"
    
    print_test "Registry statistics"
    local stats
    stats="$(get_registry_stats)"
    
    if [[ "$stats" == *"Current Sequence:"* && "$stats" == *"Epics:"* && "$stats" == *"Tasks:"* ]]; then
        pass_test
    else
        fail_test "Statistics format incorrect"
    fi
}

# Test concurrent access simulation
test_concurrent_access() {
    print_test_header "Concurrent Access Tests"
    
    print_test "Sequential number generation under simulated load"
    local numbers=()
    
    # Generate multiple numbers quickly
    for i in {1..10}; do
        local num
        num="$(get_next_number "task")"
        numbers+=("$num")
    done
    
    # Check all numbers are unique and sequential
    local prev_num=5  # Last number from previous tests
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
    
    if [[ $all_unique -eq 1 ]]; then
        pass_test
    else
        fail_test "Numbers not properly sequential: ${numbers[*]}"
    fi
}

# Main test execution
main() {
    echo "DOH Numbering Library Test Suite"
    echo "================================"
    
    # Setup
    setup_test_env
    trap cleanup_test_env EXIT
    
    # Run all tests
    test_registry_creation
    test_number_generation
    test_registration
    test_validation
    test_statistics
    test_concurrent_access
    
    # Print results
    echo -e "\n${YELLOW}Test Results:${NC}"
    echo "  Total: $TESTS_RUN"
    echo -e "  ${GREEN}Passed: $TESTS_PASSED${NC}"
    
    if [[ $TESTS_FAILED -gt 0 ]]; then
        echo -e "  ${RED}Failed: $TESTS_FAILED${NC}"
        exit 1
    else
        echo -e "  ${RED}Failed: $TESTS_FAILED${NC}"
        echo -e "\n${GREEN}All tests passed!${NC}"
        exit 0
    fi
}

# Run tests
main "$@"
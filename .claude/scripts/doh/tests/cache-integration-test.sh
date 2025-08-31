#!/bin/bash

# Integration tests for file cache and graph cache systems
# Usage: ./cache-integration-test.sh

set -e

# Source the libraries
LIB_DIR="$(dirname "$0")/../lib"
source "$LIB_DIR/file-cache.sh"
source "$LIB_DIR/graph-cache.sh"

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

# Setup test environment
setup_test_env() {
    export DOH_TEST_PROJECT_ID="cache_test_$(date +%s)_$$"
    export DOH_TEST_DIR="$HOME/.doh/projects/$DOH_TEST_PROJECT_ID"
    export DOH_TEST_PROJECT_ROOT="/tmp/doh_test_project_$$"
    
    # Override functions for testing
    get_current_project_id() {
        echo "$DOH_TEST_PROJECT_ID"
    }
    
    _find_doh_root() {
        echo "$DOH_TEST_PROJECT_ROOT"
    }
    
    # Create test project structure
    mkdir -p "$DOH_TEST_DIR"
    mkdir -p "$DOH_TEST_PROJECT_ROOT/.doh/epics/user-auth"
    mkdir -p "$DOH_TEST_PROJECT_ROOT/.doh/epics/billing"
    mkdir -p "$DOH_TEST_PROJECT_ROOT/.doh/quick"
    
    # Create test files with frontmatter
    
    # QUICK epic
    cat > "$DOH_TEST_PROJECT_ROOT/.doh/quick/manifest.md" << 'EOF'
---
name: QUICK
number: 000
status: active
---
# QUICK Tasks
EOF
    
    # User auth epic
    cat > "$DOH_TEST_PROJECT_ROOT/.doh/epics/user-auth/epic.md" << 'EOF'
---
name: user-auth
number: 001
status: active
---
# User Authentication Epic
EOF
    
    # User auth tasks
    cat > "$DOH_TEST_PROJECT_ROOT/.doh/epics/user-auth/002.md" << 'EOF'
---
name: Login implementation
number: 002
parent: 001
epic: user-auth
status: open
---
# Login Implementation Task
EOF
    
    cat > "$DOH_TEST_PROJECT_ROOT/.doh/epics/user-auth/003.md" << 'EOF'
---
name: Password reset
number: 003
parent: 001
epic: user-auth
status: open
---
# Password Reset Task
EOF
    
    # Billing epic
    cat > "$DOH_TEST_PROJECT_ROOT/.doh/epics/billing/epic.md" << 'EOF'
---
name: billing
number: 004
status: active
---
# Billing Epic
EOF
    
    # Billing task with dependency
    cat > "$DOH_TEST_PROJECT_ROOT/.doh/epics/billing/005.md" << 'EOF'
---
name: Payment processing
number: 005
parent: 004
epic: billing
depends_on: [002]
status: open
---
# Payment Processing Task
EOF
    
    echo "Test environment setup complete: $DOH_TEST_PROJECT_ROOT"
}

# Cleanup test environment
cleanup_test_env() {
    if [[ -d "$DOH_TEST_DIR" ]]; then
        rm -rf "$DOH_TEST_DIR"
    fi
    if [[ -d "$DOH_TEST_PROJECT_ROOT" ]]; then
        rm -rf "$DOH_TEST_PROJECT_ROOT"
    fi
}

# Test file cache operations
test_file_cache() {
    print_test_header "File Cache Tests"
    
    print_test "File cache creation"
    local cache_file
    cache_file="$(ensure_file_cache)"
    
    if [[ -f "$cache_file" ]]; then
        pass_test
    else
        fail_test "Cache file not created"
        return
    fi
    
    print_test "Cache rebuild from filesystem"
    if rebuild_file_cache; then
        pass_test
    else
        fail_test "Cache rebuild failed"
        return
    fi
    
    print_test "Find file by number - epic"
    local found_file
    found_file="$(find_file_by_number "001")"
    
    if [[ "$found_file" == ".doh/epics/user-auth/epic.md" ]]; then
        pass_test
    else
        fail_test "Expected .doh/epics/user-auth/epic.md, got: $found_file"
    fi
    
    print_test "Find file by number - task"
    found_file="$(find_file_by_number "002")"
    
    if [[ "$found_file" == ".doh/epics/user-auth/002.md" ]]; then
        pass_test
    else
        fail_test "Expected .doh/epics/user-auth/002.md, got: $found_file"
    fi
    
    print_test "Find file by number with epic filter"
    found_file="$(find_file_by_number "002" "user-auth")"
    
    if [[ "$found_file" == ".doh/epics/user-auth/002.md" ]]; then
        pass_test
    else
        fail_test "Epic filter failed"
    fi
    
    print_test "List epic files"
    local epic_files
    epic_files="$(list_epic_files "user-auth")"
    
    if [[ "$epic_files" == *"001"* && "$epic_files" == *"002"* && "$epic_files" == *"003"* ]]; then
        pass_test
    else
        fail_test "Epic file listing incomplete: $epic_files"
    fi
    
    print_test "Duplicate detection (should be clean)"
    if detect_duplicates; then
        pass_test
    else
        fail_test "False duplicate detection"
    fi
}

# Test graph cache operations
test_graph_cache() {
    print_test_header "Graph Cache Tests"
    
    print_test "Graph cache creation"
    local cache_file
    cache_file="$(ensure_graph_cache)"
    
    if [[ -f "$cache_file" ]]; then
        pass_test
    else
        fail_test "Graph cache file not created"
        return
    fi
    
    print_test "Graph cache rebuild from filesystem"
    if rebuild_graph_cache; then
        pass_test
    else
        fail_test "Graph cache rebuild failed"
        return
    fi
    
    print_test "Get parent relationship"
    local parent
    parent="$(get_parent "002")"
    
    if [[ "$parent" == "001" ]]; then
        pass_test
    else
        fail_test "Expected parent 001, got: $parent"
    fi
    
    print_test "Get epic relationship"
    local epic
    epic="$(get_epic "002")"
    
    if [[ "$epic" == "user-auth" ]]; then
        pass_test
    else
        fail_test "Expected epic user-auth, got: $epic"
    fi
    
    print_test "Get children of epic"
    local children
    children="$(get_children "001")"
    
    if [[ "$children" == *"002"* && "$children" == *"003"* ]]; then
        pass_test
    else
        fail_test "Children lookup failed: $children"
    fi
    
    print_test "Get epic items"
    local epic_items
    epic_items="$(get_epic_items "user-auth")"
    
    if [[ "$epic_items" == *"002"* && "$epic_items" == *"003"* ]]; then
        pass_test
    else
        fail_test "Epic items lookup failed: $epic_items"
    fi
    
    print_test "Graph cache validation"
    if validate_graph_cache; then
        pass_test
    else
        fail_test "Graph cache validation failed"
    fi
}

# Test cache integration and consistency
test_cache_integration() {
    print_test_header "Cache Integration Tests"
    
    print_test "Add new item to both caches"
    
    # Add to file cache
    add_to_file_cache "999" "task" ".doh/epics/user-auth/999.md" "test-task" "user-auth"
    
    # Add to graph cache
    add_relationship "999" "001" "user-auth"
    
    # Verify in both caches
    local found_file found_parent
    found_file="$(find_file_by_number "999")"
    found_parent="$(get_parent "999")"
    
    if [[ "$found_file" == ".doh/epics/user-auth/999.md" && "$found_parent" == "001" ]]; then
        pass_test
    else
        fail_test "Cache integration failed: file=$found_file, parent=$found_parent"
    fi
    
    print_test "Remove item from both caches"
    
    # Remove from caches
    remove_from_file_cache "999" ".doh/epics/user-auth/999.md"
    remove_relationship "999"
    
    # Verify removal
    if ! find_file_by_number "999" >/dev/null 2>&1 && ! get_parent "999" >/dev/null 2>&1; then
        pass_test
    else
        fail_test "Cache item removal failed"
    fi
    
    print_test "Cross-reference epic items"
    
    # Get items from both caches for user-auth epic
    local file_cache_items graph_cache_items
    file_cache_items="$(list_epic_files "user-auth" | cut -d',' -f1 | sort -n)"
    graph_cache_items="$(get_epic_items "user-auth" | sort -n)"
    
    if [[ "$file_cache_items" == *"002"* && "$graph_cache_items" == *"002"* ]]; then
        pass_test
    else
        fail_test "Cross-reference failed: file_cache=($file_cache_items), graph_cache=($graph_cache_items)"
    fi
}

# Test duplicate handling
test_duplicate_handling() {
    print_test_header "Duplicate Handling Tests"
    
    print_test "Create duplicate number scenario"
    
    # Add duplicate manually to file cache
    echo "002,task,.doh/epics/billing/002.md,duplicate-task,billing" >> "$(ensure_file_cache)"
    
    # Test duplicate detection
    if ! detect_duplicates >/dev/null 2>&1; then
        pass_test
    else
        fail_test "Should detect duplicates"
    fi
    
    print_test "Handle duplicate resolution"
    local found_file
    found_file="$(find_file_by_number "002")"
    
    # Should find the valid file (the one that actually exists)
    if [[ "$found_file" == ".doh/epics/user-auth/002.md" ]]; then
        pass_test
    else
        fail_test "Duplicate resolution failed: $found_file"
    fi
}

# Test self-healing
test_self_healing() {
    print_test_header "Self-Healing Tests"
    
    print_test "File cache self-healing"
    
    # Corrupt the file cache
    echo "invalid,data,in,cache,file" >> "$(ensure_file_cache)"
    
    # Should heal automatically
    if heal_file_discovery_cache >/dev/null 2>&1; then
        fail_test "File discovery cache doesn't exist anymore"
    else
        pass_test
    fi
    
    print_test "Graph cache self-healing"
    
    # Should heal automatically
    if heal_graph_cache; then
        pass_test
    else
        fail_test "Graph cache healing failed"
    fi
}

# Test performance (basic)
test_performance() {
    print_test_header "Basic Performance Tests"
    
    print_test "File lookup performance"
    
    # Time multiple lookups
    local start_time end_time
    start_time=$(date +%s%N)
    
    for i in {1..100}; do
        find_file_by_number "001" >/dev/null 2>&1
    done
    
    end_time=$(date +%s%N)
    local duration_ms=$(( (end_time - start_time) / 1000000 ))
    
    # Should be fast (less than 1000ms for 100 lookups)
    if [[ $duration_ms -lt 1000 ]]; then
        pass_test
    else
        fail_test "Lookups too slow: ${duration_ms}ms for 100 lookups"
    fi
    
    print_test "Graph relationship performance"
    
    start_time=$(date +%s%N)
    
    for i in {1..100}; do
        get_parent "002" >/dev/null 2>&1
    done
    
    end_time=$(date +%s%N)
    duration_ms=$(( (end_time - start_time) / 1000000 ))
    
    if [[ $duration_ms -lt 1000 ]]; then
        pass_test
    else
        fail_test "Graph lookups too slow: ${duration_ms}ms for 100 lookups"
    fi
}

# Main test execution
main() {
    echo "DOH Cache Systems Integration Test Suite"
    echo "======================================="
    
    # Setup
    setup_test_env
    trap cleanup_test_env EXIT
    
    # Run all tests
    test_file_cache
    test_graph_cache
    test_cache_integration
    test_duplicate_handling
    test_self_healing
    test_performance
    
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
        
        # Show final statistics
        echo -e "\n${YELLOW}Cache Statistics:${NC}"
        get_file_cache_stats
        echo ""
        get_graph_cache_stats
        
        exit 0
    fi
}

# Run tests
main "$@"
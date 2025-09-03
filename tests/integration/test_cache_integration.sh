#!/bin/bash
# Integration tests for DOH file cache and graph cache systems
# Updated to use actual library APIs
# File version: 0.1.0 | Created: 2025-09-01

# Source the framework
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"

# Source the libraries being tested
LIB_DIR="$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib"
source "$LIB_DIR/file-cache.sh"
source "$LIB_DIR/graph-cache.sh"
source "$LIB_DIR/frontmatter.sh"

# Test environment setup
_tf_setup() {
    export DOH_TEST_PROJECT_ID="cache_test_$(date +%s)_$$"
    export DOH_TEST_DIR="$HOME/.doh/projects/$DOH_TEST_PROJECT_ID"
    export DOH_TEST_PROJECT_ROOT="$(_tf_create_temp_dir)"
    
    # Override functions for testing
    workspace_get_current_project_id() {
        echo "$DOH_TEST_PROJECT_ID"
    }
    
    doh_project_dir() {
        echo "$DOH_TEST_PROJECT_ROOT/.doh"
    }
    
    # Create test project structure
    mkdir -p "$DOH_TEST_DIR"
    mkdir -p "$DOH_TEST_PROJECT_ROOT/.doh/epics/user-auth"
    mkdir -p "$DOH_TEST_PROJECT_ROOT/.doh/epics/billing"
    mkdir -p "$DOH_TEST_PROJECT_ROOT/.doh/quick"
    
    # Create test files with frontmatter
    cat > "$DOH_TEST_PROJECT_ROOT/.doh/quick/manifest.md" << 'EOF'
---
name: QUICK
number: 000
status: active
---
# QUICK Tasks
EOF
    
    cat > "$DOH_TEST_PROJECT_ROOT/.doh/epics/user-auth/epic.md" << 'EOF'
---
name: user-auth
number: 001
status: active
---
# User Authentication Epic
EOF
    
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

    cat > "$DOH_TEST_PROJECT_ROOT/.doh/epics/billing/epic.md" << 'EOF'
---
name: billing
number: 003
status: completed
---
# Billing Epic
EOF
}

_tf_teardown() {
    # Cleanup test environment
    if [[ -n "$DOH_TEST_DIR" && "$DOH_TEST_DIR" =~ cache_test_ ]]; then
        rm -rf "$DOH_TEST_DIR"
    fi
    if [[ -n "$DOH_TEST_PROJECT_ROOT" ]]; then
        _tf_cleanup_temp "$DOH_TEST_PROJECT_ROOT"
    fi
}

# File Cache Tests
test_file_cache_initialization() {
    ensure_file_cache
    local cache_file
    cache_file="$(get_file_cache_path)"
    
    _tf_assert_file_exists "$cache_file" "File cache should be initialized"
}

test_file_cache_add_entry() {
    ensure_file_cache
    
    # Add entry using the correct API
    add_to_file_cache "001" "epic" ".doh/epics/user-auth/epic.md" "user-auth" ""
    
    local cache_file
    cache_file="$(get_file_cache_path)"
    
    _tf_assert_file_contains "$cache_file" "user-auth" "Cache should contain epic name"
    _tf_assert_file_contains "$cache_file" "001" "Cache should contain epic number"
}

test_file_cache_find_entry() {
    ensure_file_cache
    
    # Add entry
    add_to_file_cache "001" "epic" ".doh/epics/user-auth/epic.md" "user-auth" ""
    
    # Find entry by number (returns path)
    local found_path
    found_path="$(find_file_by_number "001")"
    
    _tf_assert_contains "$found_path" ".doh/epics/user-auth/epic.md" "Should find cached entry by number"
}

test_file_cache_remove_entry() {
    ensure_file_cache
    
    # Add entry
    add_to_file_cache "001" "epic" ".doh/epics/user-auth/epic.md" "user-auth" ""
    
    # Remove entry
    remove_from_file_cache "001" ".doh/epics/user-auth/epic.md"
    
    local cache_file
    cache_file="$(get_file_cache_path)"
    
    # Should not contain the removed entry
    _tf_assert_command_fails "grep -q '001.*user-auth' '$cache_file'" "Entry should be removed from cache"
}

test_file_cache_statistics() {
    ensure_file_cache
    
    # Add some entries
    add_to_file_cache "001" "epic" ".doh/epics/user-auth/epic.md" "user-auth" ""
    add_to_file_cache "002" "task" ".doh/epics/user-auth/002.md" "login-task" "user-auth"
    
    local stats
    stats="$(get_file_cache_stats)"
    
    _tf_assert_contains "$stats" "File Cache Statistics" "Should show cache statistics"
}

# Graph Cache Tests
test_graph_cache_initialization() {
    _graph_cache_ensure_cache
    local graph_file
    graph_file="$(_graph_cache_get_cache_path)"
    
    _tf_assert_file_exists "$graph_file" "Graph cache should be initialized"
}

test_graph_cache_relationship_storage() {
    _graph_cache_ensure_cache
    
    add_relationship "002" "001" "user-auth"
    
    local graph_file
    graph_file="$(_graph_cache_get_cache_path)"
    
    _tf_assert_file_contains "$graph_file" "002" "Graph should contain task number"
    _tf_assert_file_contains "$graph_file" "001" "Graph should contain parent epic"
    _tf_assert_file_contains "$graph_file" "user-auth" "Graph should contain epic name"
}

test_graph_cache_parent_lookup() {
    _graph_cache_ensure_cache
    
    add_relationship "002" "001" "user-auth"
    
    local parent
    parent="$(get_parent "002")"
    
    _tf_assert_equals "001" "$parent" "Should retrieve cached parent relationship"
}

test_graph_cache_children_lookup() {
    _graph_cache_ensure_cache
    
    add_relationship "002" "001" "user-auth"
    add_relationship "004" "001" "user-auth"
    
    local children
    children="$(get_children "001")"
    
    _tf_assert_contains "$children" "002" "Should find child task 002"
    _tf_assert_contains "$children" "004" "Should find child task 004"
}

test_graph_cache_epic_lookup() {
    _graph_cache_ensure_cache
    
    add_relationship "002" "001" "user-auth"
    
    local epic
    epic="$(get_epic "002")"
    
    _tf_assert_equals "user-auth" "$epic" "Should retrieve cached epic relationship"
}

# Integration Tests
test_cache_integration_file_and_graph() {
    # Test that file cache and graph cache work together
    ensure_file_cache
    _graph_cache_ensure_cache
    
    # Add entries to both caches
    add_to_file_cache "002" "task" ".doh/epics/user-auth/002.md" "login-task" "user-auth"
    add_relationship "002" "001" "user-auth"
    
    # Verify both caches contain the data
    local found_path parent epic
    found_path="$(find_file_by_number "002")"
    parent="$(get_parent "002")"
    epic="$(get_epic "002")"
    
    _tf_assert_contains "$found_path" ".doh/epics/user-auth/002.md" "File cache should contain task path"
    _tf_assert_equals "001" "$parent" "Graph cache should contain parent relationship"
    _tf_assert_equals "user-auth" "$epic" "Graph cache should contain epic relationship"
}

test_cache_performance_batch_operations() {
    ensure_file_cache
    _graph_cache_ensure_cache
    
    # Batch add multiple entries
    local start_time end_time
    start_time=$(date +%s)
    
    add_to_file_cache "001" "epic" ".doh/epics/user-auth/epic.md" "user-auth" ""
    add_to_file_cache "002" "task" ".doh/epics/user-auth/002.md" "login-task" "user-auth"
    add_to_file_cache "003" "epic" ".doh/epics/billing/epic.md" "billing" ""
    add_to_file_cache "000" "epic" ".doh/quick/manifest.md" "QUICK" ""
    
    add_relationship "002" "001" "user-auth"
    add_relationship "001" "000" "QUICK"
    add_relationship "003" "000" "QUICK"
    
    end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Should complete quickly (under 5 seconds for this small set)
    _tf_assert_command_succeeds "test $duration -lt 5" "Batch cache operations should complete quickly"
}

test_cache_consistency_remove_operations() {
    ensure_file_cache
    _graph_cache_ensure_cache
    
    # Add entries
    add_to_file_cache "002" "task" ".doh/epics/user-auth/002.md" "login-task" "user-auth"
    add_relationship "002" "001" "user-auth"
    
    # Verify they exist
    local found_path parent
    found_path="$(find_file_by_number "002")"
    parent="$(get_parent "002")"
    
    _tf_assert_contains "$found_path" ".doh/epics/user-auth/002.md" "Should be cached initially"
    _tf_assert_equals "001" "$parent" "Parent should be cached initially"
    
    # Remove entries
    remove_from_file_cache "002" ".doh/epics/user-auth/002.md"
    remove_relationship "002"
    
    # Verify they're removed
    found_path="$(find_file_by_number "002" 2>/dev/null || echo "")"
    parent="$(get_parent "002" 2>/dev/null || echo "")"
    
    _tf_assert_equals "" "$found_path" "File cache should be cleared after removal"
    _tf_assert_equals "" "$parent" "Graph cache should be cleared after removal"
}

# Cache Statistics Tests
test_cache_combined_statistics() {
    ensure_file_cache
    _graph_cache_ensure_cache
    
    # Add some entries to both caches
    add_to_file_cache "001" "epic" ".doh/epics/user-auth/epic.md" "user-auth" ""
    add_to_file_cache "002" "task" ".doh/epics/user-auth/002.md" "login-task" "user-auth"
    add_relationship "002" "001" "user-auth"
    
    # Check individual cache statistics
    local file_stats graph_stats
    file_stats="$(get_file_cache_stats)"
    graph_stats="$(get_graph_cache_stats)"
    
    _tf_assert_contains "$file_stats" "File Cache Statistics" "Should show file cache statistics"
    _tf_assert_contains "$graph_stats" "Graph Cache Statistics" "Should show graph cache statistics"
}

# Run tests if script executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
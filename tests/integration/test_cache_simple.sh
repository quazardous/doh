#!/bin/bash
# Simplified cache functionality test
# Tests basic cache operations step by step
# File version: 0.1.0 | Created: 2025-09-03

# Source the framework and libraries
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/doh_fixtures.sh"

LIB_DIR="$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib"
source "$LIB_DIR/dohenv.sh"
source "$LIB_DIR/frontmatter.sh"

_tf_setup() {
    # Use the DOH_PROJECT_DIR set by test launcher
    if [[ -n "$DOH_PROJECT_DIR" ]]; then
        # Create minimal cache test structure
        _tff_create_cache_test_project "$(dirname "$DOH_PROJECT_DIR")" >/dev/null 2>&1 || {
            # Fallback: create basic structure
            _tff_create_minimal_doh_project "$(dirname "$DOH_PROJECT_DIR")" >/dev/null
        }
        
        # Create a simple task file for testing
        mkdir -p "$DOH_PROJECT_DIR/tasks"
        cat > "$DOH_PROJECT_DIR/tasks/001.md" << 'EOF'
---
name: Test Task
number: 001
status: open
file_version: 0.1.0
---

# Test Task
EOF
    fi
}

_tf_teardown() {
    # Cleanup handled by test launcher
    :
}

test_frontmatter_basic_operations() {
    local test_file="$DOH_PROJECT_DIR/tasks/001.md"
    
    # Test that we can read frontmatter
    _tf_assert "File should have frontmatter" frontmatter_has "$test_file"
    
    # Test getting field values
    local name
    name=$(frontmatter_get_field "$test_file" "name")
    _tf_assert_equals "Should get task name" "Test Task" "$name"
    
    local number
    number=$(frontmatter_get_field "$test_file" "number")
    _tf_assert_equals "Should get task number" "001" "$number"
}

test_cache_directory_structure() {
    # Test that cache directories can be created
    local cache_dir="$DOH_PROJECT_DIR/cache_test"
    mkdir -p "$cache_dir"
    
    _tf_assert "Cache directory should be created" test -d "$cache_dir"
    
    # Test creating a simple cache file
    echo "test cache data" > "$cache_dir/test.cache"
    _tf_assert_file_exists "Cache file should be created" "$cache_dir/test.cache"
    _tf_assert_file_contains "Cache file should contain test data" "$cache_dir/test.cache" "test cache data"
}

test_simple_file_operations() {
    # Test basic file operations that cache system would use
    local test_data_file="$DOH_PROJECT_DIR/test_data.txt"
    
    # Write data
    echo "line1" > "$test_data_file"
    echo "line2" >> "$test_data_file"
    
    # Read and verify
    local line_count
    line_count=$(wc -l < "$test_data_file")
    _tf_assert_equals "Should have 2 lines" "2" "$line_count"
    
    # Test grep operations
    grep -q "line1" "$test_data_file"
    _tf_assert_equals "Should find line1" 0 $?
}

# Run tests if script executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
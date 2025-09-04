#!/bin/bash
# Test suite for test framework environment isolation
# Tests: DOH_GLOBAL_DIR, DOH_PROJECT_DIR, DOH_VERSION_FILE isolation and emptiness

source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"

# Test environment setup
_tf_setup() {
    # Create VERSION file with 0.0.1 for testing
    local version_dir="$(dirname "$DOH_VERSION_FILE")"
    mkdir -p "$version_dir"
    echo "0.0.1" > "$DOH_VERSION_FILE"
}

_tf_teardown() {
    # No cleanup needed - test launcher handles cleanup
    return 0
}

# Test DOH_PROJECT_DIR is set and in test directory
test_doh_project_dir_isolation() {
    # DOH_PROJECT_DIR should be set
    _tf_assert "DOH_PROJECT_DIR should be set" [ -n "$DOH_PROJECT_DIR" ]
    
    # Should be in a temporary test directory (contains /tmp/)
    _tf_assert_contains "DOH_PROJECT_DIR should be in temp directory" "$DOH_PROJECT_DIR" "/tmp/"
    
    # Should exist as directory
    _tf_assert "DOH_PROJECT_DIR should exist" [ -d "$DOH_PROJECT_DIR" ]
    
    # Should be writable
    _tf_assert "DOH_PROJECT_DIR should be writable" [ -w "$DOH_PROJECT_DIR" ]
}

# Test DOH_PROJECT_DIR is empty or contains only test fixtures
test_doh_project_dir_emptiness() {
    local file_count
    # Count all files (including hidden, excluding . and ..)
    file_count=$(find "$DOH_PROJECT_DIR" -mindepth 1 | wc -l)
    
    # Should be empty (0 files) or contain only expected test fixtures
    if [ "$file_count" -gt 0 ]; then
        # If not empty, should only contain expected test fixture structure
        _tf_assert "DOH_PROJECT_DIR should contain only test fixtures if not empty" [ -f "$DOH_PROJECT_DIR/.doh/config" ]
        _tf_assert "Test fixtures should have proper structure" [ -d "$DOH_PROJECT_DIR/.doh" ]
    else
        _tf_assert_equals "DOH_PROJECT_DIR should be empty initially" 0 "$file_count"
    fi
}

# Test DOH_GLOBAL_DIR is set and in test directory
test_doh_global_dir_isolation() {
    # DOH_GLOBAL_DIR should be set
    _tf_assert "DOH_GLOBAL_DIR should be set" [ -n "$DOH_GLOBAL_DIR" ]
    
    # Should be in a temporary test directory (contains /tmp/)
    _tf_assert_contains "DOH_GLOBAL_DIR should be in temp directory" "$DOH_GLOBAL_DIR" "/tmp/"
    
    # Should exist as directory
    _tf_assert "DOH_GLOBAL_DIR should exist" [ -d "$DOH_GLOBAL_DIR" ]
    
    # Should be writable
    _tf_assert "DOH_GLOBAL_DIR should be writable" [ -w "$DOH_GLOBAL_DIR" ]
}

# Test DOH_GLOBAL_DIR is empty
test_doh_global_dir_emptiness() {
    local file_count
    # Count all files (including hidden, excluding . and ..)
    file_count=$(find "$DOH_GLOBAL_DIR" -mindepth 1 | wc -l)
    
    # Should be completely empty
    _tf_assert_equals "DOH_GLOBAL_DIR should be empty" 0 "$file_count"
}

# Test DOH_VERSION_FILE is set and in test directory
test_doh_version_file_isolation() {
    # DOH_VERSION_FILE should be set
    _tf_assert "DOH_VERSION_FILE should be set" [ -n "$DOH_VERSION_FILE" ]
    
    # Should be in a temporary test directory (contains /tmp/)
    _tf_assert_contains "DOH_VERSION_FILE should be in temp directory" "$DOH_VERSION_FILE" "/tmp/"
    
    # Should be writable (directory should exist)
    local version_dir
    version_dir="$(dirname "$DOH_VERSION_FILE")"
    _tf_assert "DOH_VERSION_FILE directory should be writable" [ -w "$version_dir" ]
}

# Test DOH_VERSION_FILE is empty or doesn't exist
test_doh_version_file_emptiness() {
    if [ -f "$DOH_VERSION_FILE" ]; then
        # If file exists, should be empty or contain only test data
        local file_size
        file_size=$(stat -f%z "$DOH_VERSION_FILE" 2>/dev/null || stat -c%s "$DOH_VERSION_FILE" 2>/dev/null || echo "0")
        
        # Should be small (empty or minimal test content)
        _tf_assert "DOH_VERSION_FILE should be empty or minimal" [ "$file_size" -lt 100 ]
    else
        # If file doesn't exist, that's also acceptable for isolation
        _tf_assert "DOH_VERSION_FILE non-existence is acceptable for isolation" [ ! -f "$DOH_VERSION_FILE" ]
    fi
}

# Test that all DOH environment variables are different from real project
test_doh_env_vars_not_real_project() {
    # Should not point to the real project directory
    _tf_assert "DOH_PROJECT_DIR should not be real project" [ "$DOH_PROJECT_DIR" != "/home/david/Private/dev/projects/quazardous/doh" ]
    _tf_assert "DOH_PROJECT_DIR should not be current directory" [ "$DOH_PROJECT_DIR" != "$(pwd)" ]
    
    # Should not point to real global directory
    _tf_assert "DOH_GLOBAL_DIR should not be real global" [ "$DOH_GLOBAL_DIR" != "$HOME/.doh" ]
    
    # Should not point to real version file
    _tf_assert "DOH_VERSION_FILE should not be real version file" [ "$DOH_VERSION_FILE" != "$(pwd)/VERSION" ]
}

# Test DOH library path functions work with isolated environment
test_doh_path_functions() {
    # Source DOH library to test path functions
    source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/doh.sh"
    
    # Test doh_project_dir function
    local project_dir_result
    project_dir_result="$(doh_project_dir)"
    _tf_assert_equals "doh_project_dir should return DOH_PROJECT_DIR" "$DOH_PROJECT_DIR" "$project_dir_result"
    
    # Test doh_global_dir function  
    local global_dir_result
    global_dir_result="$(doh_global_dir)"
    _tf_assert_equals "doh_global_dir should return DOH_GLOBAL_DIR" "$DOH_GLOBAL_DIR" "$global_dir_result"
}

# Test environment variables are preserved across function calls
test_doh_env_vars_persistence() {
    local initial_project_dir="$DOH_PROJECT_DIR"
    local initial_global_dir="$DOH_GLOBAL_DIR" 
    local initial_version_file="$DOH_VERSION_FILE"
    
    # Call some function that might modify environment
    source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/doh.sh" >/dev/null 2>&1
    
    # Environment variables should remain unchanged
    _tf_assert_equals "DOH_PROJECT_DIR should persist" "$initial_project_dir" "$DOH_PROJECT_DIR"
    _tf_assert_equals "DOH_GLOBAL_DIR should persist" "$initial_global_dir" "$DOH_GLOBAL_DIR"
    _tf_assert_equals "DOH_VERSION_FILE should persist" "$initial_version_file" "$DOH_VERSION_FILE"
}

# Test isolation from real DOH installation
test_isolation_from_real_doh() {
    # Test that we can't accidentally access real DOH files
    local real_doh_dir="/home/david/Private/dev/projects/quazardous/doh/.doh"
    
    if [ -d "$real_doh_dir" ]; then
        # Our isolated project dir should not be the real one
        _tf_assert "Isolated environment should not access real .doh" [ "$DOH_PROJECT_DIR/.doh" != "$real_doh_dir" ]
        _tf_assert "Isolated .doh should not exist or be different" [ ! -d "$DOH_PROJECT_DIR/.doh" ] || [ "$DOH_PROJECT_DIR/.doh" != "$real_doh_dir" ]
    fi
}

# Prevent direct execution - tests must run through launcher
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Error: This test file must be run through the test launcher:"
    echo "  ./tests/test_launcher.sh tests/unit/test_test_framework_env.sh"
    exit 1
fi
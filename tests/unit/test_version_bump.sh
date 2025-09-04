#!/bin/bash

# DOH Version Bump Test Suite
# Tests the comprehensive version bump workflow functionality

# Load test framework
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"

# Source DOH version library directly for better performance
source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/version.sh"

# Use proper DOH API function names directly - no wrapper functions

_tf_setup() {
    # Use standard DOH test setup
    source "$(dirname "${BASH_SOURCE[0]}")/../helpers/doh_fixtures.sh"
    _tff_create_minimal_doh_project
    
    local doh_dir=$(doh_project_dir)
    local version_file=$(doh_version_file)
    
    # Create the DOH directory first!
    mkdir -p "$doh_dir"
    
    # Initialize git and set version using DOH functions
    mkdir -p "$(dirname "$doh_dir")/.git"
    echo "0.1.0" > "$version_file"
    
    # Create a test DOH file with frontmatter
    cat > "$doh_dir/test.md" << 'EOF'
---
file_version: 0.1.0
name: Test File
status: open
---

# Test File
This is a test file for version bump testing.
EOF
    
    # Create another test file  
    cat > "$doh_dir/another.md" << 'EOF'
---
name: Another Test
file_version: 0.1.0
type: task
---

# Another Test
Another test file.
EOF
}

_tf_teardown() {
    # Environment cleanup is handled by test launcher
    return 0
}

test_version_get_current() {
    local version
    version=$(version_get_current)
    local exit_code=$?
    
    _tf_assert_equals "version_get_current should succeed" 0 $exit_code
    _tf_assert_equals "Current version should be 0.1.0" "0.1.0" "$version"
}

test_increment_version_patch() {
    local result
    result=$(version_increment "0.1.0" "patch")
    
    _tf_assert_equals "Patch increment should work" "0.1.1" "$result"
}

test_increment_version_minor() {
    local result
    result=$(version_increment "0.1.0" "minor")
    
    _tf_assert_equals "Minor increment should work" "0.2.0" "$result"
}

test_increment_version_major() {
    local result
    result=$(version_increment "0.1.0" "major")
    
    _tf_assert_equals "Major increment should work" "1.0.0" "$result"
}

test_increment_version_invalid() {
    local result
    result=$(version_increment "0.1.0" "invalid" 2>/dev/null)
    local exit_code=$?
    
    _tf_assert_equals "Invalid increment level should fail" 1 $exit_code
}

test_version_set_current() {
    version_set_current "0.2.0" > /dev/null
    local exit_code=$?
    
    _tf_assert_equals "version_set_current should succeed" 0 $exit_code
    
    local new_version
    local version_file=$(doh_version_file)
    new_version=$(cat "$version_file")
    _tf_assert_equals "VERSION file should be updated" "0.2.0" "$new_version"
}

test_version_bump_current() {
    local new_version
    new_version=$(version_bump_current "patch")
    local exit_code=$?
    
    _tf_assert_equals "version_bump_current should succeed" 0 $exit_code
    _tf_assert_equals "New version should be 0.1.1" "0.1.1" "$new_version"
    
    local file_version
    local version_file=$(doh_version_file)
    file_version=$(cat "$version_file")
    _tf_assert_equals "VERSION file should contain new version" "0.1.1" "$file_version"
}

test_get_file_version() {
    local doh_dir=$(doh_project_dir)
    
    local version
    version=$(version_get_file "$doh_dir/test.md")
    local exit_code=$?
    
    _tf_assert_equals "version_get_file should succeed" 0 $exit_code
    _tf_assert_equals "File version should be 0.1.0" "0.1.0" "$version"
}

test_set_file_version() {
    local doh_dir=$(doh_project_dir)
    
    version_set_file "$doh_dir/test.md" "0.2.0" > /dev/null
    local exit_code=$?
    
    _tf_assert_equals "version_set_file should succeed" 0 $exit_code
    
    local new_version
    new_version=$(version_get_file "$doh_dir/test.md")
    _tf_assert_equals "File version should be updated to 0.2.0" "0.2.0" "$new_version"
}

test_bump_file_version() {
    local doh_dir=$(doh_project_dir)
    
    local new_version
    new_version=$(version_bump_file "$doh_dir/another.md" "minor")
    local exit_code=$?
    
    _tf_assert_equals "version_bump_file should succeed" 0 $exit_code
    _tf_assert_equals "New file version should be 0.2.0" "0.2.0" "$new_version"
    
    local file_version
    file_version=$(version_get_file "$doh_dir/another.md")
    _tf_assert_equals "File should contain new version" "0.2.0" "$file_version"
}

test_validate_version() {
    version_validate "1.0.0"
    _tf_assert_equals "1.0.0" 0 $?
    version_validate "0.1.0"
    _tf_assert_equals "0.1.0" 0 $?
    version_validate "10.20.30"
    _tf_assert_equals "10.20.30" 0 $?
    version_validate "1.0.0-alpha"
    _tf_assert_equals "1.0.0-alpha" 0 $?
    version_validate "1.0.0+build.1"
    _tf_assert_equals "1.0.0+build.1" 0 $?
    
    _tf_assert_not "Invalid semver should fail" version_validate "1.0"
    _tf_assert_not "Version with prefix should fail" version_validate "v1.0.0"
    _tf_assert_not "Four-part version should fail" version_validate "1.0.0.0"
    _tf_assert_not "Empty version should fail" version_validate ""
}

test_compare_versions() {
    version_compare "1.0.0" "1.0.0"
    _tf_assert_equals "1.0.0" 0 $?
    
    version_compare "2.0.0" "1.0.0"
    _tf_assert_equals "Greater version should return 1" 1 $?
    
    version_compare "1.0.0" "2.0.0"
    _tf_assert_equals "Lesser version should return 2" 2 $?
}

test_find_files_missing_version() {
    local doh_dir=$(doh_project_dir)
    
    # Create file without frontmatter
    cat > "$doh_dir/no_frontmatter.md" << 'EOF'
# File without frontmatter
This file has no frontmatter.
EOF
    
    # Create file with frontmatter but no version
    cat > "$doh_dir/no_version.md" << 'EOF'
---
name: No Version File
status: open
---

# No Version File
This file has frontmatter but no version.
EOF
    
    local missing_files
    missing_files=$(version_find_files_without_file_version "$doh_dir")
    
    # Should find the file with frontmatter but no version
    echo "$missing_files" | grep -q "no_version.md"
    _tf_assert_equals "Should find files missing version field" 0 $?
    
    # Should not find files without frontmatter
    echo "$missing_files" | grep -q "no_frontmatter.md"
    _tf_assert_equals "Should not find files without frontmatter" 1 $?
}

# Version bump workflow integration test
test_version_bump_workflow() {
    echo "🧪 Testing complete version bump workflow..."
    
    local doh_dir=$(doh_project_dir)
    local version_file=$(doh_version_file)
    
    # Initial state check
    local initial_version
    initial_version=$(version_get_current)
    _tf_assert_equals "Initial version should be 0.1.0" "0.1.0" "$initial_version"
    
    # Bump project version
    local new_version
    new_version=$(version_bump_current "patch")
    _tf_assert_equals "Should bump to 0.1.1" "0.1.1" "$new_version"
    
    # Verify VERSION file is updated
    local file_content
    file_content=$(cat "$version_file")
    _tf_assert_equals "VERSION file should contain new version" "0.1.1" "$file_content"
    
    # Update file versions to match
    version_set_file "$doh_dir/test.md" "$new_version" > /dev/null
    version_set_file "$doh_dir/another.md" "$new_version" > /dev/null
    
    # Verify file versions are updated
    local test_file_version
    test_file_version=$(version_get_file "$doh_dir/test.md")
    _tf_assert_equals "Test file version should be updated" "$new_version" "$test_file_version"
    
    local another_file_version
    another_file_version=$(version_get_file "$doh_dir/another.md")
    _tf_assert_equals "Another file version should be updated" "$new_version" "$another_file_version"
}

# Run tests if script executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
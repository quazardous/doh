#!/bin/bash

# DOH Version Bump Test Suite
# Tests the comprehensive version bump workflow functionality

# Load test framework
if [[ -n "${_TF_LAUNCHER_EXECUTION:-}" ]]; then
    # Running through test launcher from project root
    source "tests/helpers/test_framework.sh"
else
    # Running directly from test directory
    source "$(dirname "$0")/../helpers/test_framework.sh"
fi

# Get the project root directory for API calls
if [[ -n "${_TF_LAUNCHER_EXECUTION:-}" ]]; then
    # Running through test launcher from project root
    DOH_API_PATH="$(pwd)/.claude/scripts/doh/api.sh"
else
    # Running directly from test directory - find project root
    DOH_API_PATH="$(cd "$(dirname "$0")/../.." && pwd)/.claude/scripts/doh/api.sh"
fi

# Use DOH API for version functions
version_validate() {
    "$DOH_API_PATH" version validate "$@"
}
version_compare() {
    "$DOH_API_PATH" version compare "$@"  
}
version_increment() {
    "$DOH_API_PATH" version increment "$@"
}
version_get_current() {
    "$DOH_API_PATH" version get_current "$@"
}
version_get_file() {
    "$DOH_API_PATH" version get_file "$@"
}
version_set_file() {
    "$DOH_API_PATH" version set_file "$@"
}
version_set_project() {
    "$DOH_API_PATH" version set_project "$@"
}
version_find_missing_files() {
    "$DOH_API_PATH" version find_missing_files "$@"
}
version_bump_file() {
    "$DOH_API_PATH" version bump_file "$@"
}
version_bump_project() {
    "$DOH_API_PATH" version bump_project "$@"
}

# Use proper DOH API function names directly - no wrapper functions

_tf_setup() {
    # Create temporary test environment
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR"
    
    # Initialize basic DOH structure
    mkdir -p .doh .git
    echo "0.1.0" > VERSION
    
    # Create a test DOH file with frontmatter
    cat > .doh/test.md << 'EOF'
---
file_version: 0.1.0
name: Test File
status: open
---

# Test File
This is a test file for version bump testing.
EOF
    
    # Create another test file
    cat > .doh/another.md << 'EOF'
---
name: Another Test
file_version: 0.1.0
type: task
---

# Another Test
Another test file.
EOF
    
    cd - > /dev/null
}

_tf_teardown() {
    # Cleanup test directory
    if [[ -n "$TEST_DIR" && -d "$TEST_DIR" ]]; then
        rm -rf "$TEST_DIR"
    fi
}

test_version_get_current() {
    cd "$TEST_DIR"
    
    local version
    version=$(version_get_current)
    local exit_code=$?
    
    _tf_assert_equals 0 $exit_code "version_get_current should succeed"
    _tf_assert_equals "0.1.0" "$version" "Current version should be 0.1.0"
    
    cd - > /dev/null
}

test_increment_version_patch() {
    local result
    result=$(version_increment "0.1.0" "patch")
    
    _tf_assert_equals "0.1.1" "$result" "Patch increment should work"
}

test_increment_version_minor() {
    local result
    result=$(version_increment "0.1.0" "minor")
    
    _tf_assert_equals "0.2.0" "$result" "Minor increment should work"
}

test_increment_version_major() {
    local result
    result=$(version_increment "0.1.0" "major")
    
    _tf_assert_equals "1.0.0" "$result" "Major increment should work"
}

test_increment_version_invalid() {
    local result
    result=$(version_increment "0.1.0" "invalid" 2>/dev/null)
    local exit_code=$?
    
    _tf_assert_equals 1 $exit_code "Invalid increment level should fail"
}

test_set_project_version() {
    cd "$TEST_DIR"
    
    version_set_project "0.2.0" > /dev/null
    local exit_code=$?
    
    _tf_assert_equals 0 $exit_code "version_set_project should succeed"
    
    local new_version
    new_version=$(cat VERSION)
    _tf_assert_equals "0.2.0" "$new_version" "VERSION file should be updated"
    
    cd - > /dev/null
}

test_version_bump_project() {
    cd "$TEST_DIR"
    
    local new_version
    new_version=$(version_bump_project "patch")
    local exit_code=$?
    
    _tf_assert_equals 0 $exit_code "version_bump_project should succeed"
    _tf_assert_equals "0.1.1" "$new_version" "New version should be 0.1.1"
    
    local file_version
    file_version=$(cat VERSION)
    _tf_assert_equals "0.1.1" "$file_version" "VERSION file should contain new version"
    
    cd - > /dev/null
}

test_get_file_version() {
    cd "$TEST_DIR"
    
    local version
    version=$(version_get_file ".doh/test.md")
    local exit_code=$?
    
    _tf_assert_equals 0 $exit_code "version_get_file should succeed"
    _tf_assert_equals "0.1.0" "$version" "File version should be 0.1.0"
    
    cd - > /dev/null
}

test_set_file_version() {
    cd "$TEST_DIR"
    
    version_set_file ".doh/test.md" "0.2.0" > /dev/null
    local exit_code=$?
    
    _tf_assert_equals 0 $exit_code "version_set_file should succeed"
    
    local new_version
    new_version=$(version_get_file ".doh/test.md")
    _tf_assert_equals "0.2.0" "$new_version" "File version should be updated to 0.2.0"
    
    cd - > /dev/null
}

test_bump_file_version() {
    cd "$TEST_DIR"
    
    local new_version
    new_version=$(version_bump_file ".doh/another.md" "minor")
    local exit_code=$?
    
    _tf_assert_equals 0 $exit_code "version_bump_file should succeed"
    _tf_assert_equals "0.2.0" "$new_version" "New file version should be 0.2.0"
    
    local file_version
    file_version=$(version_get_file ".doh/another.md")
    _tf_assert_equals "0.2.0" "$file_version" "File should contain new version"
    
    cd - > /dev/null
}

test_validate_version() {
    version_validate "1.0.0"
    _tf_assert_equals 0 $? "1.0.0"
    version_validate "0.1.0"
    _tf_assert_equals 0 $? "0.1.0"
    version_validate "10.20.30"
    _tf_assert_equals 0 $? "10.20.30"
    version_validate "1.0.0-alpha"
    _tf_assert_equals 0 $? "1.0.0-alpha"
    version_validate "1.0.0+build.1"
    _tf_assert_equals 0 $? "1.0.0+build.1"
    
    _tf_assert_command_fails version_validate "1.0" "Invalid semver should fail"
    _tf_assert_command_fails version_validate "v1.0.0" "Version with prefix should fail"
    _tf_assert_command_fails version_validate "1.0.0.0" "Four-part version should fail"
    _tf_assert_command_fails version_validate "" "Empty version should fail"
}

test_compare_versions() {
    version_compare "1.0.0" "1.0.0"
    _tf_assert_equals 0 $? "1.0.0"
    
    version_compare "2.0.0" "1.0.0"
    _tf_assert_equals 1 $? "Greater version should return 1"
    
    version_compare "1.0.0" "2.0.0"
    _tf_assert_equals 2 $? "Lesser version should return 2"
}

test_find_files_missing_version() {
    cd "$TEST_DIR"
    
    # Create file without frontmatter
    cat > .doh/no_frontmatter.md << 'EOF'
# File without frontmatter
This file has no frontmatter.
EOF
    
    # Create file with frontmatter but no version
    cat > .doh/no_version.md << 'EOF'
---
name: No Version File
status: open
---

# No Version File
This file has frontmatter but no version.
EOF
    
    local missing_files
    missing_files=$(version_find_missing_files .)
    
    # Should find the file with frontmatter but no version
    echo "$missing_files" | grep -q "no_version.md"
    _tf_assert_equals 0 $? "Should find files missing version field"
    
    # Should not find files without frontmatter
    echo "$missing_files" | grep -q "no_frontmatter.md"
    _tf_assert_equals 1 $? "Should not find files without frontmatter"
    
    cd - > /dev/null
}

# Version bump workflow integration test
test_version_bump_workflow() {
    cd "$TEST_DIR"
    
    echo "🧪 Testing complete version bump workflow..."
    
    # Initial state check
    local initial_version
    initial_version=$(version_get_current)
    _tf_assert_equals "0.1.0" "$initial_version" "Initial version should be 0.1.0"
    
    # Bump project version
    local new_version
    new_version=$(version_bump_project "patch")
    _tf_assert_equals "0.1.1" "$new_version" "Should bump to 0.1.1"
    
    # Verify VERSION file is updated
    local file_content
    file_content=$(cat VERSION)
    _tf_assert_equals "0.1.1" "$file_content" "VERSION file should contain new version"
    
    # Update file versions to match
    version_set_file ".doh/test.md" "$new_version" > /dev/null
    version_set_file ".doh/another.md" "$new_version" > /dev/null
    
    # Verify file versions are updated
    local test_file_version
    test_file_version=$(version_get_file ".doh/test.md")
    _tf_assert_equals "$new_version" "$test_file_version" "Test file version should be updated"
    
    local another_file_version
    another_file_version=$(version_get_file ".doh/another.md")
    _tf_assert_equals "$new_version" "$another_file_version" "Another file version should be updated"
    
    cd - > /dev/null
}

# Run all tests
_tf_run_tests
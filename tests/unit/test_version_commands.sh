#!/bin/bash

# DOH Version Commands Test Suite  
# Tests version management commands and their integration

# Load test framework
if [[ -n "${_TF_LAUNCHER_EXECUTION:-}" ]]; then
    # Running through test launcher from project root
    source "tests/helpers/test_framework.sh"
else
    # Running directly from test directory
    source "$(dirname "$0")/../helpers/test_framework.sh"
fi

# Load version management libraries
source ".claude/scripts/doh/lib/dohenv.sh"
source ".claude/scripts/doh/lib/version.sh"
source ".claude/scripts/doh/lib/frontmatter.sh"

# Export functions for use in test assertions
export -f find_version_inconsistencies list_versions

_tf_setup() {
    # Create temporary test environment
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR"
    
    # Initialize basic DOH structure
    mkdir -p .doh/{versions,epics,tasks} .git
    echo "0.1.0" > VERSION
    
    # Create version files
    cat > .doh/versions/0.1.0.md << 'EOF'
---
version: 0.1.0
type: initial
created: 2025-09-01T10:00:00Z
---

# Version 0.1.0 - Initial Release

Initial version of the project.
EOF
    
    # Create test epic with version
    cat > .doh/epics/001.md << 'EOF'
---
name: test-epic
number: 001
status: open
file_version: 0.1.0
target_version: 0.2.0
---

# Test Epic
Test epic for version testing.
EOF
    
    # Create test task with version
    cat > .doh/epics/002.md << 'EOF'
---
name: test-task
number: 002
epic: test-epic
status: open
file_version: 0.1.0
target_version: 0.2.0
---

# Test Task
Test task for version testing.
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
    _tf_assert_equals "0.1.0" "$version" "Should return current version"
    
    cd - > /dev/null
}

test_version_set_project() {
    cd "$TEST_DIR"
    
    version_set_project "0.2.0" > /dev/null
    local exit_code=$?
    
    _tf_assert_equals 0 $exit_code "version_set_project should succeed"
    
    local new_version
    new_version=$(cat VERSION)
    _tf_assert_equals "0.2.0" "$new_version" "VERSION file should be updated"
    
    cd - > /dev/null
}

test_bump_project_version_patch() {
    cd "$TEST_DIR"
    
    local new_version
    new_version=$(bump_project_version "patch")
    local exit_code=$?
    
    _tf_assert_equals 0 $exit_code "bump_project_version patch should succeed"
    _tf_assert_equals "0.1.1" "$new_version" "Should increment patch version"
    
    local file_version
    file_version=$(cat VERSION)
    _tf_assert_equals "0.1.1" "$file_version" "VERSION file should contain new version"
    
    cd - > /dev/null
}

test_bump_project_version_minor() {
    cd "$TEST_DIR"
    
    local new_version
    new_version=$(bump_project_version "minor")
    local exit_code=$?
    
    _tf_assert_equals 0 $exit_code "bump_project_version minor should succeed"
    _tf_assert_equals "0.2.0" "$new_version" "Should increment minor version"
    
    cd - > /dev/null
}

test_bump_project_version_major() {
    cd "$TEST_DIR"
    
    local new_version
    new_version=$(bump_project_version "major")
    local exit_code=$?
    
    _tf_assert_equals 0 $exit_code "bump_project_version major should succeed"
    _tf_assert_equals "1.0.0" "$new_version" "Should increment major version"
    
    cd - > /dev/null
}

test_version_find_missing_files() {
    cd "$TEST_DIR"
    
    # Create file without version
    cat > .doh/epics/no_version.md << 'EOF'
---
name: No Version
status: open
---

# No Version File
EOF
    
    # Create file without frontmatter
    cat > .doh/epics/no_frontmatter.md << 'EOF'
# No Frontmatter File
This file has no frontmatter.
EOF
    
    local missing_files
    missing_files=$(version_find_missing_files .doh/epics)
    
    # Should find the file with frontmatter but no version
    echo "$missing_files" | grep -q "no_version.md"
    _tf_assert_equals 0 $? "Should find files with frontmatter but no version"
    
    # Should not find files without frontmatter
    echo "$missing_files" | grep -q "no_frontmatter.md"
    _tf_assert_equals 1 $? "Should not report files without frontmatter"
    
    cd - > /dev/null
}

test_version_file_operations() {
    cd "$TEST_DIR"
    
    # Test getting file version
    local version
    version=$(get_file_version ".doh/epics/001.md")
    _tf_assert_equals "0.1.0" "$version" "Should get file version from frontmatter"
    
    # Test setting file version
    set_file_version ".doh/epics/001.md" "0.3.0" > /dev/null
    local exit_code=$?
    _tf_assert_equals 0 $exit_code "Should set file version successfully"
    
    # Verify version was set
    local new_version
    new_version=$(get_file_version ".doh/epics/001.md")
    _tf_assert_equals "0.3.0" "$new_version" "File version should be updated"
    
    cd - > /dev/null
}

test_version_file_bump() {
    cd "$TEST_DIR"
    
    # Test bumping file version
    local new_version
    new_version=$(bump_file_version ".doh/epics/002.md" "minor")
    local exit_code=$?
    
    _tf_assert_equals 0 $exit_code "Should bump file version successfully"
    _tf_assert_equals "0.2.0" "$new_version" "Should return new version"
    
    # Verify file was updated
    local file_version
    file_version=$(get_file_version ".doh/epics/002.md")
    _tf_assert_equals "0.2.0" "$file_version" "File should contain new version"
    
    cd - > /dev/null
}

test_version_consistency_check() {
    cd "$TEST_DIR"
    
    # Set inconsistent versions
    version_set_project "0.3.0" > /dev/null
    set_file_version ".doh/epics/001.md" "0.1.0" > /dev/null
    set_file_version ".doh/epics/002.md" "0.2.0" > /dev/null
    
    # Check for version inconsistencies
    local inconsistent_files
    inconsistent_files=$(find_version_inconsistencies)
    
    # Should find files with versions different from project version
    echo "$inconsistent_files" | grep -q "001.md"
    _tf_assert_equals 0 $? "Should find files with outdated versions"
    
    echo "$inconsistent_files" | grep -q "002.md"
    _tf_assert_equals 0 $? "Should find all inconsistent files"
    
    cd - > /dev/null
}

test_version_list_operations() {
    cd "$TEST_DIR"
    
    # Create additional version files
    cat > .doh/versions/0.2.0.md << 'EOF'
---
version: 0.2.0
type: minor
created: 2025-09-01T11:00:00Z
---

# Version 0.2.0 - Feature Release
EOF
    
    # Test listing versions
    local versions
    versions=$(list_versions)
    
    echo "$versions" | grep -q "0.1.0"
    _tf_assert_equals 0 $? "Should list existing version 0.1.0"
    
    echo "$versions" | grep -q "0.2.0"
    _tf_assert_equals 0 $? "Should list existing version 0.2.0"
    
    cd - > /dev/null
}

# Run all tests
_tf_run_tests
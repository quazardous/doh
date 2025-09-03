#!/bin/bash

# DOH Version Commands Test Suite  
# Tests version management commands and their integration

# Source the framework and helpers
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/doh_fixtures.sh"

# Source the libraries being tested
LIB_DIR="$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib"
source "$LIB_DIR/dohenv.sh"
source "$LIB_DIR/version.sh"
source "$LIB_DIR/frontmatter.sh"

_tf_setup() {
    # Use the DOH_PROJECT_DIR set by test launcher, just create the structure
    if [[ -n "$DOH_PROJECT_DIR" ]]; then
        # Create the project structure using fixture
        _tff_create_version_test_project "$(dirname "$DOH_PROJECT_DIR")"
        
        # Add additional files for version commands testing
        mkdir -p "$DOH_PROJECT_DIR/versions"
        
        # Create version files
        cat > "$DOH_PROJECT_DIR/versions/0.1.0.md" << 'EOF'
---
version: 0.1.0
type: initial
created: 2025-09-01T10:00:00Z
---

# Version 0.1.0 - Initial Release

Initial version of the project.
EOF

    cat > "$DOH_PROJECT_DIR/versions/0.2.0.md" << 'EOF'
---
version: 0.2.0
type: minor
created: 2025-09-02T10:00:00Z
---

# Version 0.2.0 - Minor Release

Minor version update.
EOF
}

_tf_teardown() {
    # Cleanup is handled by test launcher
    :
}

test_version_get_current() {
    cd "$(dirname "$DOH_PROJECT_DIR")"
    
    local version
    version=$(version_get_current)
    local exit_code=$?
    
    _tf_assert_equals 0 $exit_code "version_get_current should succeed"
    _tf_assert_equals "0.1.0" "$version" "Should return current version"
    
    cd - > /dev/null
}

test_version_set_current() {
    cd "$(dirname "$DOH_PROJECT_DIR")"
    
    version_set_current "0.2.0" > /dev/null
    local exit_code=$?
    
    _tf_assert_equals 0 $exit_code "version_set_current should succeed"
    
    local new_version
    new_version=$(cat VERSION)
    _tf_assert_equals "0.2.0" "$new_version" "VERSION file should be updated"
    
    cd - > /dev/null
}

test_version_bump_current_patch() {
    cd "$(dirname "$DOH_PROJECT_DIR")"
    
    local new_version
    new_version=$(version_bump_current "patch")
    local exit_code=$?
    
    _tf_assert_equals 0 $exit_code "version_bump_current patch should succeed"
    _tf_assert_equals "0.1.1" "$new_version" "Should increment patch version"
    
    local file_version
    file_version=$(cat VERSION)
    _tf_assert_equals "0.1.1" "$file_version" "VERSION file should contain new version"
    
    cd - > /dev/null
}

test_version_bump_current_minor() {
    cd "$(dirname "$DOH_PROJECT_DIR")"
    
    local new_version
    new_version=$(version_bump_current "minor")
    local exit_code=$?
    
    _tf_assert_equals 0 $exit_code "version_bump_current minor should succeed"
    _tf_assert_equals "0.2.0" "$new_version" "Should increment minor version"
    
    cd - > /dev/null
}

test_version_bump_current_major() {
    cd "$(dirname "$DOH_PROJECT_DIR")"
    
    local new_version
    new_version=$(version_bump_current "major")
    local exit_code=$?
    
    _tf_assert_equals 0 $exit_code "version_bump_current major should succeed"
    _tf_assert_equals "1.0.0" "$new_version" "Should increment major version"
    
    cd - > /dev/null
}

test_version_find_files_without_file_version() {
    cd "$(dirname "$DOH_PROJECT_DIR")"
    
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
    missing_files=$(version_find_files_without_file_version .doh/epics)
    
    # Should find the file with frontmatter but no version
    echo "$missing_files" | grep -q "no_version.md"
    _tf_assert_equals 0 $? "Should find files with frontmatter but no version"
    
    # Should not find files without frontmatter
    echo "$missing_files" | grep -q "no_frontmatter.md"
    _tf_assert_equals 1 $? "Should not report files without frontmatter"
    
    cd - > /dev/null
}

test_version_file_operations() {
    cd "$(dirname "$DOH_PROJECT_DIR")"
    
    # Test getting file version
    local version
    version=$(version_get_file ".doh/epics/001.md")
    _tf_assert_equals "0.1.0" "$version" "Should get file version from frontmatter"
    
    # Test setting file version
    version_set_file ".doh/epics/001.md" "0.3.0" > /dev/null
    local exit_code=$?
    _tf_assert_equals 0 $exit_code "Should set file version successfully"
    
    # Verify version was set
    local new_version
    new_version=$(version_get_file ".doh/epics/001.md")
    _tf_assert_equals "0.3.0" "$new_version" "File version should be updated"
    
    cd - > /dev/null
}

test_version_file_bump() {
    cd "$(dirname "$DOH_PROJECT_DIR")"
    
    # Test bumping file version
    local new_version
    new_version=$(version_bump_file ".doh/epics/002.md" "minor")
    local exit_code=$?
    
    _tf_assert_equals 0 $exit_code "Should bump file version successfully"
    _tf_assert_equals "0.2.0" "$new_version" "Should return new version"
    
    # Verify file was updated
    local file_version
    file_version=$(version_get_file ".doh/epics/002.md")
    _tf_assert_equals "0.2.0" "$file_version" "File should contain new version"
    
    cd - > /dev/null
}

test_version_consistency_check() {
    cd "$(dirname "$DOH_PROJECT_DIR")"
    
    # Set inconsistent versions
    version_set_current "0.3.0" > /dev/null
    version_set_file ".doh/epics/001.md" "0.1.0" > /dev/null
    version_set_file ".doh/epics/002.md" "0.2.0" > /dev/null
    
    # Check for version inconsistencies
    local inconsistent_files
    inconsistent_files=$(version_find_inconsistencies)
    
    # Should find files with versions different from project version
    echo "$inconsistent_files" | grep -q "001.md"
    _tf_assert_equals 0 $? "Should find files with outdated versions"
    
    echo "$inconsistent_files" | grep -q "002.md"
    _tf_assert_equals 0 $? "Should find all inconsistent files"
    
    cd - > /dev/null
}

test_version_list_operations() {
    cd "$(dirname "$DOH_PROJECT_DIR")"
    
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
    versions=$(version_list)
    
    echo "$versions" | grep -q "0.1.0"
    _tf_assert_equals 0 $? "Should list existing version 0.1.0"
    
    echo "$versions" | grep -q "0.2.0"
    _tf_assert_equals 0 $? "Should list existing version 0.2.0"
    
    cd - > /dev/null
}

# Tests are run by the test launcher
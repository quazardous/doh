#!/bin/bash
# Simplified version commands test
# Tests core version commands step by step
# File version: 0.1.0 | Created: 2025-09-03

# Source the framework and libraries
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/doh_fixtures.sh"

LIB_DIR="$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib"
source "$LIB_DIR/dohenv.sh"
source "$LIB_DIR/version.sh"
source "$LIB_DIR/frontmatter.sh"

_tf_setup() {
    # Use the DOH_PROJECT_DIR set by test launcher
    if [[ -n "$DOH_PROJECT_DIR" ]]; then
        # Create minimal project structure
        _tff_create_minimal_doh_project >/dev/null
        
        # Ensure VERSION file exists with 0.1.0
        local version_file=$(doh_version_file)
        echo "0.1.0" > "$version_file"
        
        # Create a simple test file with frontmatter
        mkdir -p "$DOH_PROJECT_DIR"
        cat > "$DOH_PROJECT_DIR/test_file.md" << 'EOF'
---
name: Test File
file_version: 0.1.0
---

# Test File
EOF
    fi
}

_tf_teardown() {
    # Cleanup handled by test launcher
    :
}

test_version_validate_basic() {
    # Test that version validation works
    _tf_assert "Valid version should pass validation" version_validate "1.0.0"
    _tf_assert_not "Invalid version should fail validation" version_validate "invalid"
}

test_version_get_current_basic() {
    cd "$(dirname "$DOH_PROJECT_DIR")"
    
    # Test getting current version (just check that it works, not specific version)
    local version
    version=$(version_get_current)
    local exit_code=$?
    
    _tf_assert_equals "Should get current version successfully" 0 $exit_code
    _tf_assert_not_equals "Should return a valid version" "" "$version"
    
    cd - >/dev/null
}

test_frontmatter_get_version() {
    # Test getting file version from frontmatter
    local file_version
    file_version=$(frontmatter_get_field "$DOH_PROJECT_DIR/test_file.md" "file_version")
    
    _tf_assert_equals "Should get file version from frontmatter" "0.1.0" "$file_version"
}

test_version_comparison() {
    # Test version comparison (returns -1, 0, 1 for less, equal, greater)
    local result
    result=$(version_compare "1.0.0" "2.0.0")
    _tf_assert_equals "1.0.0 should be less than 2.0.0" "-1" "$result"
    
    result=$(version_compare "2.0.0" "1.0.0")  
    _tf_assert_equals "2.0.0 should be greater than 1.0.0" "1" "$result"
    
    result=$(version_compare "1.0.0" "1.0.0")
    _tf_assert_equals "1.0.0 should equal 1.0.0" "0" "$result"
}

# Run tests if script executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
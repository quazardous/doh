#!/bin/bash

# Test frontmatter_update_many function
# File version: 0.2.2 | Created: 2025-09-03

# Test framework setup
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/doh_fixtures.sh"

_tf_setup() {
    # Use skeleton fixture system for proper test isolation
    _tff_create_helper_test_project "$DOH_PROJECT_DIR" >/dev/null
    _tff_setup_workspace_for_helpers
    
    # Source DOH libraries after environment is set up
    source .claude/scripts/doh/lib/frontmatter.sh
    source .claude/scripts/doh/lib/version.sh
    
    # Create test files in the test environment
    TEST_FILE="test.md"
    TEST_FILE_NO_FM="no_frontmatter.md"
    
    # Create test file with basic frontmatter
    cat > "$TEST_FILE" << 'EOF'
---
title: Test Document
status: pending
priority: medium
---

# Test Content

This is a test document.
EOF

    # Create test file without frontmatter
    cat > "$TEST_FILE_NO_FM" << 'EOF'
# Test Content

This is a test document without frontmatter.
EOF
}

_tf_teardown() {
    # Cleanup handled by test launcher isolation
    return 0
}

test_update_many_basic_functionality() {
    
    # Test updating multiple fields
    _tf_assert "frontmatter_update_many should succeed" frontmatter_update_many "$TEST_FILE" "status:completed" "priority:high"
    
    # Verify updates
    local status priority
    status=$(frontmatter_get_field "$TEST_FILE" "status")
    priority=$(frontmatter_get_field "$TEST_FILE" "priority")
    
    _tf_assert_equals "Status should be updated to completed" "completed" "$status"
    _tf_assert_equals "Priority should be updated to high" "high" "$priority"
}

test_update_many_auto_file_version_injection() {
    
    # Update fields without providing file_version
    _tf_assert "frontmatter_update_many should succeed" frontmatter_update_many "$TEST_FILE" "status:in_progress"
    
    # Verify file_version was auto-injected with current version
    local file_version current_version
    file_version=$(frontmatter_get_field "$TEST_FILE" "file_version")
    current_version=$(version_get_current)
    
    _tf_assert_equals "file_version should be auto-injected with current version" "$current_version" "$file_version"
    
    # Verify the other field was updated
    local status
    status=$(frontmatter_get_field "$TEST_FILE" "status")
    _tf_assert_equals "Status should be updated" "in_progress" "$status"
}

test_update_many_explicit_file_version() {
    
    # Update with explicit file_version
    _tf_assert "frontmatter_update_many should succeed" frontmatter_update_many "$TEST_FILE" "file_version:1.0.0" "status:done"
    
    # Verify explicit file_version is used
    local file_version status
    file_version=$(frontmatter_get_field "$TEST_FILE" "file_version")
    status=$(frontmatter_get_field "$TEST_FILE" "status")
    
    _tf_assert_equals "Explicit file_version should be used" "1.0.0" "$file_version"
    _tf_assert_equals "Status should be updated" "done" "$status"
}

test_update_many_invalid_file() {
    
    # Try to update non-existent file
    _tf_assert_not "Should fail for non-existent file" frontmatter_update_many "/non/existent/file.md" "status:test" 2>/dev/null
}

test_update_many_invalid_format() {
    
    # Try with invalid format (missing colon)
    _tf_assert_not "Should fail for invalid field:value format" frontmatter_update_many "$TEST_FILE" "invalid_format" 2>/dev/null
    
    # Try with invalid format (equals instead of colon)
    _tf_assert_not "Should fail for field=value format" frontmatter_update_many "$TEST_FILE" "field=value" 2>/dev/null
}

test_update_many_no_frontmatter() {
    
    # Should succeed and add frontmatter to file without it
    _tf_assert "Should succeed and add frontmatter" frontmatter_update_many "$TEST_FILE_NO_FM" "status:test"
    
    # Verify frontmatter was added
    local status
    status=$(frontmatter_get_field "$TEST_FILE_NO_FM" "status")
    _tf_assert_equals "Status should be set" "test" "$status"
}

test_update_many_complex_values() {
    
    # Update with complex values
    _tf_assert "Should handle complex values" frontmatter_update_many "$TEST_FILE" "title:My Complex Title with Spaces" "description:Value with: colons and, commas"
    
    # Verify complex values
    local title description
    title=$(frontmatter_get_field "$TEST_FILE" "title")
    description=$(frontmatter_get_field "$TEST_FILE" "description")
    
    _tf_assert_equals "Complex title should be preserved" "My Complex Title with Spaces" "$title"
    _tf_assert_equals "Complex description should be preserved" "Value with: colons and, commas" "$description"
}

test_update_many_empty_values() {
    
    # Update with empty value
    _tf_assert "Should handle empty values" frontmatter_update_many "$TEST_FILE" "empty_field:" "normal_field:normal_value"
    
    # Verify empty value
    local empty_field normal_field
    empty_field=$(frontmatter_get_field "$TEST_FILE" "empty_field")
    normal_field=$(frontmatter_get_field "$TEST_FILE" "normal_field")
    
    _tf_assert_equals "Empty field should be empty" "" "$empty_field"
    _tf_assert_equals "Normal field should have value" "normal_value" "$normal_field"
}

test_update_many_file_version_detection() {
    
    # Test with file_version in middle of arguments
    _tf_assert "Should work with file_version in middle" frontmatter_update_many "$TEST_FILE" "status:test" "file_version:2.0.0" "priority:low"
    
    local file_version
    file_version=$(frontmatter_get_field "$TEST_FILE" "file_version")
    _tf_assert_equals "Should use explicit file_version" "2.0.0" "$file_version"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
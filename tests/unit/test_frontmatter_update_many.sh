#!/bin/bash

# Test frontmatter_update_many function
# File version: 0.2.2 | Created: 2025-09-03

# Test framework setup
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"

_tf_setup() {
    # Create temporary directory for test files
    TEST_DIR=$(mktemp -d)
    TEST_FILE="$TEST_DIR/test.md"
    TEST_FILE_NO_FM="$TEST_DIR/no_frontmatter.md"
    
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
    # Clean up temporary files
    rm -rf "$TEST_DIR"
}

test_update_many_basic_functionality() {
    _tf_desc "Test basic functionality with multiple field updates"
    
    # Test updating multiple fields
    ./.claude/scripts/doh/api.sh frontmatter update_many "$TEST_FILE" "status:completed" "priority:high"
    _tf_assert_success "frontmatter_update_many should succeed"
    
    # Verify updates
    local status priority
    status=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_FILE" "status")
    priority=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_FILE" "priority")
    
    _tf_assert_equals "Status should be updated to completed" "completed" "$status"
    _tf_assert_equals "Priority should be updated to high" "high" "$priority"
}

test_update_many_auto_file_version_injection() {
    _tf_desc "Test automatic file_version injection when not provided"
    
    # Update fields without providing file_version
    ./.claude/scripts/doh/api.sh frontmatter update_many "$TEST_FILE" "status:in_progress"
    _tf_assert_success "frontmatter_update_many should succeed"
    
    # Verify file_version was auto-injected with current version
    local file_version current_version
    file_version=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_FILE" "file_version")
    current_version=$(./.claude/scripts/doh/api.sh version get_current)
    
    _tf_assert_equals "file_version should be auto-injected with current version" "$current_version" "$file_version"
    
    # Verify the other field was updated
    local status
    status=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_FILE" "status")
    _tf_assert_equals "Status should be updated" "in_progress" "$status"
}

test_update_many_explicit_file_version() {
    _tf_desc "Test explicit file_version override"
    
    # Update with explicit file_version
    ./.claude/scripts/doh/api.sh frontmatter update_many "$TEST_FILE" "file_version:1.0.0" "status:done"
    _tf_assert_success "frontmatter_update_many should succeed"
    
    # Verify explicit file_version is used
    local file_version status
    file_version=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_FILE" "file_version")
    status=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_FILE" "status")
    
    _tf_assert_equals "Explicit file_version should be used" "1.0.0" "$file_version"
    _tf_assert_equals "Status should be updated" "done" "$status"
}

test_update_many_invalid_file() {
    _tf_desc "Test error handling for non-existent file"
    
    # Try to update non-existent file
    ./.claude/scripts/doh/api.sh frontmatter update_many "/non/existent/file.md" "status:test" 2>/dev/null
    _tf_assert_failure "Should fail for non-existent file"
}

test_update_many_invalid_format() {
    _tf_desc "Test error handling for invalid field:value format"
    
    # Try with invalid format (missing colon)
    ./.claude/scripts/doh/api.sh frontmatter update_many "$TEST_FILE" "invalid_format" 2>/dev/null
    _tf_assert_failure "Should fail for invalid field:value format"
    
    # Try with invalid format (equals instead of colon)
    ./.claude/scripts/doh/api.sh frontmatter update_many "$TEST_FILE" "field=value" 2>/dev/null
    _tf_assert_failure "Should fail for field=value format"
}

test_update_many_no_frontmatter() {
    _tf_desc "Test error handling for file without frontmatter"
    
    # Try to update file without frontmatter
    ./.claude/scripts/doh/api.sh frontmatter update_many "$TEST_FILE_NO_FM" "status:test" 2>/dev/null
    _tf_assert_failure "Should fail for file without frontmatter"
}

test_update_many_complex_values() {
    _tf_desc "Test updating with complex values containing spaces and special chars"
    
    # Update with complex values
    ./.claude/scripts/doh/api.sh frontmatter update_many "$TEST_FILE" "title:My Complex Title with Spaces" "description:Value with: colons and, commas"
    _tf_assert_success "Should handle complex values"
    
    # Verify complex values
    local title description
    title=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_FILE" "title")
    description=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_FILE" "description")
    
    _tf_assert_equals "Complex title should be preserved" "My Complex Title with Spaces" "$title"
    _tf_assert_equals "Complex description should be preserved" "Value with: colons and, commas" "$description"
}

test_update_many_empty_values() {
    _tf_desc "Test updating with empty values"
    
    # Update with empty value
    ./.claude/scripts/doh/api.sh frontmatter update_many "$TEST_FILE" "empty_field:" "normal_field:normal_value"
    _tf_assert_success "Should handle empty values"
    
    # Verify empty value
    local empty_field normal_field
    empty_field=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_FILE" "empty_field")
    normal_field=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_FILE" "normal_field")
    
    _tf_assert_equals "Empty field should be empty" "" "$empty_field"
    _tf_assert_equals "Normal field should have value" "normal_value" "$normal_field"
}

test_update_many_file_version_detection() {
    _tf_desc "Test file_version detection in various positions"
    
    # Test with file_version in middle of arguments
    ./.claude/scripts/doh/api.sh frontmatter update_many "$TEST_FILE" "status:test" "file_version:2.0.0" "priority:low"
    _tf_assert_success "Should work with file_version in middle"
    
    local file_version
    file_version=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_FILE" "file_version")
    _tf_assert_equals "Should use explicit file_version" "2.0.0" "$file_version"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
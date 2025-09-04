#!/bin/bash

# Test enhanced frontmatter_update_many function with auto-injection features
# File version: 0.2.2 | Created: 2025-09-03

# Test framework setup
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/doh_fixtures.sh"

_tf_setup() {
    # Use skeleton fixture system for proper test isolation
    _tff_create_helper_test_project >/dev/null
    _tff_setup_workspace_for_helpers
    
    # Source DOH libraries after environment is set up
    source .claude/scripts/doh/lib/frontmatter.sh
    source .claude/scripts/doh/lib/version.sh
    
    # Create test files in the test environment
    TEST_DIR="."
    TEST_FILE="test.md"
    TEST_NEW_FILE="new.md"
    TEST_EXISTING_FILE="existing.md"
    
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

    # Create test file with existing created field
    cat > "$TEST_EXISTING_FILE" << 'EOF'
---
title: Existing Document
created: 2025-01-01T10:00:00Z
status: old
---

# Existing Content
EOF
}

_tf_teardown() {
    # Cleanup handled by test launcher isolation
    return 0
}

test_create_new_file() {
    
    # Create empty file first (command's responsibility)
    touch "$TEST_NEW_FILE"
    
    # Initialize frontmatter with basic fields and capture output
    local frontmatter_output
    frontmatter_output=$(frontmatter_update_many "$TEST_NEW_FILE" "name:New Task" "status:backlog")
    _tf_assert "Should initialize frontmatter successfully"
    
    # Verify frontmatter is output to stdout
    _tf_assert_not_equals "Should output frontmatter to stdout" "" "$frontmatter_output"
    
    # Verify file exists and has content
    _tf_assert_file_exists "New file should be created" "$TEST_NEW_FILE"
    
    # Verify auto-injected fields
    local file_version created updated name status
    file_version=$(frontmatter_get_field "$TEST_NEW_FILE" "file_version")
    created=$(frontmatter_get_field "$TEST_NEW_FILE" "created")
    updated=$(frontmatter_get_field "$TEST_NEW_FILE" "updated")
    name=$(frontmatter_get_field "$TEST_NEW_FILE" "name")
    status=$(frontmatter_get_field "$TEST_NEW_FILE" "status")
    
    # Get current version for comparison
    local current_version
    current_version=$(version_get_current)
    
    _tf_assert_equals "file_version should be auto-injected with current version" "$current_version" "$file_version"
    _tf_assert_not_equals "created should be auto-injected" "" "$created"
    _tf_assert_not_equals "updated should be auto-injected" "" "$updated"
    _tf_assert_equals "name should be set correctly" "New Task" "$name"
    _tf_assert_equals "status should be set correctly" "backlog" "$status"
    
    # Verify no temp placeholder (legacy cleanup should handle any remnants)
    local temp_value
    temp_value=$(frontmatter_get_field "$TEST_NEW_FILE" "temp")
    _tf_assert_equals "temp placeholder should not exist" "" "$temp_value"
}

test_auto_number_flag() {
    
    # Create empty file first
    touch "$TEST_DIR/numbered.md"
    
    # Initialize with auto-number flag
    frontmatter_update_many "$TEST_DIR/numbered.md" --auto-number "name:Numbered Task" "status:backlog"
    _tf_assert "Should initialize file with auto-number"
    
    # Verify number field is present
    local number
    number=$(frontmatter_get_field "$TEST_DIR/numbered.md" "number")
    _tf_assert_not_equals "number should be auto-generated" "" "$number"
}

test_preserve_existing_created() {
    
    local original_created
    original_created=$(frontmatter_get_field "$TEST_EXISTING_FILE" "created")
    
    # Update file without providing created
    frontmatter_update_many "$TEST_EXISTING_FILE" "status:updated" "priority:high"
    _tf_assert "Should update existing file"
    
    # Verify created timestamp is preserved
    local preserved_created
    preserved_created=$(frontmatter_get_field "$TEST_EXISTING_FILE" "created")
    _tf_assert_equals "created timestamp should be preserved" "$original_created" "$preserved_created"
    
    # Verify other fields are updated
    local status priority
    status=$(frontmatter_get_field "$TEST_EXISTING_FILE" "status")
    priority=$(frontmatter_get_field "$TEST_EXISTING_FILE" "priority")
    _tf_assert_equals "status should be updated" "updated" "$status"
    _tf_assert_equals "priority should be set" "high" "$priority"
}

test_always_update_updated() {
    
    # First update
    frontmatter_update_many "$TEST_FILE" "status:first_update"
    local first_updated
    first_updated=$(frontmatter_get_field "$TEST_FILE" "updated")
    
    # Small delay to ensure different timestamp
    sleep 1
    
    # Second update
    frontmatter_update_many "$TEST_FILE" "status:second_update"
    local second_updated
    second_updated=$(frontmatter_get_field "$TEST_FILE" "updated")
    
    _tf_assert_not_equals "updated timestamp should change on each update" "$first_updated" "$second_updated"
}

test_explicit_override_auto_fields() {
    
    # Create empty file first
    touch "$TEST_DIR/override.md"
    
    # Initialize with explicit auto-field values
    frontmatter_update_many "$TEST_DIR/override.md" \
        "file_version:1.0.0" \
        "created:2025-01-01T12:00:00Z" \
        "updated:2025-01-01T12:00:00Z" \
        "name:Override Test"
    _tf_assert "Should initialize file with explicit values"
    
    # Verify explicit values are used
    local file_version created updated
    file_version=$(frontmatter_get_field "$TEST_DIR/override.md" "file_version")
    created=$(frontmatter_get_field "$TEST_DIR/override.md" "created")
    updated=$(frontmatter_get_field "$TEST_DIR/override.md" "updated")
    
    _tf_assert_equals "Explicit file_version should be used" "1.0.0" "$file_version"
    _tf_assert_equals "Explicit created should be used" "2025-01-01T12:00:00Z" "$created"
    _tf_assert_equals "Explicit updated should be used" "2025-01-01T12:00:00Z" "$updated"
}

test_file_not_exists_error() {
    
    # Try to update non-existent file
    frontmatter_update_many "/non/existent/file.md" "status:test" 2>/dev/null
    _tf_assert_failure "Should fail for non-existent file"
}

test_auto_number_with_explicit_number() {
    
    # Create empty file first
    touch "$TEST_DIR/explicit_number.md"
    
    # Initialize with explicit number and auto-number flag
    frontmatter_update_many "$TEST_DIR/explicit_number.md" \
        --auto-number \
        "number:999" \
        "name:Explicit Number Task"
    _tf_assert "Should handle explicit number with auto-number flag"
    
    # Verify explicit number is used
    local number
    number=$(frontmatter_get_field "$TEST_DIR/explicit_number.md" "number")
    _tf_assert_equals "Explicit number should be used even with --auto-number flag" "999" "$number"
}

test_complex_field_values_with_auto_injection() {
    
    # Create empty file first
    touch "$TEST_DIR/complex.md"
    
    # Initialize with complex values
    frontmatter_update_many "$TEST_DIR/complex.md" \
        "name:Task with: Complex Values" \
        "description:This has spaces, commas, and: colons" \
        "tags:tag1,tag2,tag3"
    _tf_assert "Should handle complex values with auto-injection"
    
    # Verify complex values and auto-injection
    local name description tags file_version
    name=$(frontmatter_get_field "$TEST_DIR/complex.md" "name")
    description=$(frontmatter_get_field "$TEST_DIR/complex.md" "description")
    tags=$(frontmatter_get_field "$TEST_DIR/complex.md" "tags")
    file_version=$(frontmatter_get_field "$TEST_DIR/complex.md" "file_version")
    
    _tf_assert_equals "Complex name should be preserved" "Task with: Complex Values" "$name"
    _tf_assert_equals "Complex description should be preserved" "This has spaces, commas, and: colons" "$description"
    _tf_assert_equals "Tags should be preserved" "tag1,tag2,tag3" "$tags"
    _tf_assert_not_equals "file_version should be auto-injected" "" "$file_version"
}

test_file_without_frontmatter() {
    
    local no_fm_file="$TEST_DIR/no_frontmatter.md"
    
    # Create file without frontmatter
    cat > "$no_fm_file" << 'EOF'
# Simple Markdown File

This file has no frontmatter initially.
EOF
    
    # Add frontmatter to existing file
    frontmatter_update_many "$no_fm_file" "name:Added Frontmatter"
    _tf_assert "Should add frontmatter to file without it"
    
    # Verify frontmatter was added
    local name
    name=$(frontmatter_get_field "$no_fm_file" "name")
    _tf_assert_equals "Frontmatter should be added" "Added Frontmatter" "$name"
    
    # Verify original content is preserved
    if ! grep -q "This file has no frontmatter initially" "$no_fm_file"; then
        _tf_fail "Original content should be preserved"
    fi
}

test_frontmatter_assert_function() {
    
    local test_file="$TEST_DIR/assert_test.md"
    
    # Create file without frontmatter
    cat > "$test_file" << 'EOF'
# Test File

Content without frontmatter.
EOF
    
    # Test frontmatter_assert (should use file creation time)
    frontmatter_assert "$test_file"
    _tf_assert "Should add frontmatter with file creation time"
    
    # Verify frontmatter was added
    _tf_assert "File should now have frontmatter" frontmatter_has "$test_file"
    
    # Verify created timestamp was added
    local created_value
    created_value=$(frontmatter_get_field "$test_file" "created")
    _tf_assert_not_equals "created timestamp should be added" "" "$created_value"
    
    # Verify no temp placeholder (not needed with created field)
    local temp_value
    temp_value=$(frontmatter_get_field "$test_file" "temp")
    _tf_assert_equals "temp placeholder should not be added when created field exists" "" "$temp_value"
    
    # Test calling assert again (should be idempotent)
    frontmatter_assert "$test_file"
    _tf_assert "Should be idempotent - no error on existing frontmatter"
    
    # Verify content is preserved
    if ! grep -q "Content without frontmatter" "$test_file"; then
        _tf_fail "Original content should be preserved"
    fi
}

test_frontmatter_assert_with_explicit_date() {
    
    local test_file="$TEST_DIR/assert_explicit.md"
    local explicit_date="2025-01-01T12:00:00Z"
    
    # Create file without frontmatter
    cat > "$test_file" << 'EOF'
# Test File with Explicit Date

Content without frontmatter.
EOF
    
    # Test frontmatter_assert with explicit date
    frontmatter_assert "$test_file" "$explicit_date"
    _tf_assert "Should add frontmatter with explicit date"
    
    # Verify created timestamp uses explicit date
    local created_value
    created_value=$(frontmatter_get_field "$test_file" "created")
    _tf_assert_equals "Should use explicit created date" "$explicit_date" "$created_value"
    
    # Verify no temp placeholder (not needed with created field)
    local temp_value
    temp_value=$(frontmatter_get_field "$test_file" "temp")
    _tf_assert_equals "temp placeholder should not be added when created field exists" "" "$temp_value"
}

test_empty_values_with_auto_injection() {
    
    # Create empty file first
    touch "$TEST_DIR/empty.md"
    
    # Initialize with empty values
    frontmatter_update_many "$TEST_DIR/empty.md" \
        "name:Non-empty Task" \
        "description:" \
        "notes:"
    _tf_assert "Should handle empty values with auto-injection"
    
    # Verify empty and auto-injected fields
    local name description notes file_version
    name=$(frontmatter_get_field "$TEST_DIR/empty.md" "name")
    description=$(frontmatter_get_field "$TEST_DIR/empty.md" "description")
    notes=$(frontmatter_get_field "$TEST_DIR/empty.md" "notes")
    file_version=$(frontmatter_get_field "$TEST_DIR/empty.md" "file_version")
    
    _tf_assert_equals "Name should be set" "Non-empty Task" "$name"
    _tf_assert_equals "Description should be empty" "" "$description"
    _tf_assert_equals "Notes should be empty" "" "$notes"
    _tf_assert_not_equals "file_version should be auto-injected" "" "$file_version"
}

test_mixed_flags_and_fields() {
    
    # Create empty file first
    touch "$TEST_DIR/mixed.md"
    
    # Initialize with flag in middle of arguments
    frontmatter_update_many "$TEST_DIR/mixed.md" \
        "name:Mixed Args" \
        --auto-number \
        "status:backlog" \
        "priority:medium"
    _tf_assert "Should handle mixed flags and fields"
    
    # Verify all fields are set correctly
    local name status priority number
    name=$(frontmatter_get_field "$TEST_DIR/mixed.md" "name")
    status=$(frontmatter_get_field "$TEST_DIR/mixed.md" "status")
    priority=$(frontmatter_get_field "$TEST_DIR/mixed.md" "priority")
    number=$(frontmatter_get_field "$TEST_DIR/mixed.md" "number")
    
    _tf_assert_equals "Name should be set" "Mixed Args" "$name"
    _tf_assert_equals "Status should be set" "backlog" "$status"
    _tf_assert_equals "Priority should be set" "medium" "$priority"
    _tf_assert_not_equals "Number should be auto-generated" "" "$number"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
#!/bin/bash

# Test enhanced frontmatter_update_many function with auto-injection features
# File version: 0.2.2 | Created: 2025-09-03

# Test framework setup
source "$(dirname "$0")/../helpers/test_framework.sh" 2>/dev/null || source "../helpers/test_framework.sh" 2>/dev/null || source "tests/helpers/test_framework.sh"

# Source DOH libraries
source .claude/scripts/doh/lib/frontmatter.sh

_tf_setup() {
    # Create temporary directory for test files
    TEST_DIR=$(mktemp -d)
    TEST_FILE="$TEST_DIR/test.md"
    TEST_NEW_FILE="$TEST_DIR/new.md"
    TEST_EXISTING_FILE="$TEST_DIR/existing.md"
    
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
    # Clean up temporary files
    rm -rf "$TEST_DIR"
}

test_create_new_file() {
    _tf_desc "Test initializing frontmatter for new file"
    
    # Create empty file first (command's responsibility)
    touch "$TEST_NEW_FILE"
    
    # Initialize frontmatter with basic fields and capture output
    local frontmatter_output
    frontmatter_output=$(./.claude/scripts/doh/api.sh frontmatter update_many "$TEST_NEW_FILE" "name:New Task" "status:backlog")
    _tf_assert_success "Should initialize frontmatter successfully"
    
    # Verify frontmatter is output to stdout
    _tf_assert_not_empty "$frontmatter_output" "Should output frontmatter to stdout"
    
    # Verify file exists and has content
    _tf_assert_file_exists "New file should be created" "$TEST_NEW_FILE"
    
    # Verify auto-injected fields
    local file_version created updated name status
    file_version=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_NEW_FILE" "file_version")
    created=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_NEW_FILE" "created")
    updated=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_NEW_FILE" "updated")
    name=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_NEW_FILE" "name")
    status=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_NEW_FILE" "status")
    
    # Get current version for comparison
    local current_version
    current_version=$(./.claude/scripts/doh/api.sh version get_current)
    
    _tf_assert_equals "file_version should be auto-injected with current version" "$current_version" "$file_version"
    _tf_assert_not_empty "$created" "created should be auto-injected"
    _tf_assert_not_empty "$updated" "updated should be auto-injected"
    _tf_assert_equals "name should be set correctly" "New Task" "$name"
    _tf_assert_equals "status should be set correctly" "backlog" "$status"
    
    # Verify no temp placeholder (legacy cleanup should handle any remnants)
    local temp_value
    temp_value=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_NEW_FILE" "temp")
    _tf_assert_empty "$temp_value" "temp placeholder should not exist"
}

test_auto_number_flag() {
    _tf_desc "Test --auto-number flag functionality"
    
    # Create empty file first
    touch "$TEST_DIR/numbered.md"
    
    # Initialize with auto-number flag
    ./.claude/scripts/doh/api.sh frontmatter update_many "$TEST_DIR/numbered.md" --auto-number "name:Numbered Task" "status:backlog"
    _tf_assert_success "Should initialize file with auto-number"
    
    # Verify number field is present
    local number
    number=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_DIR/numbered.md" "number")
    _tf_assert_not_empty "$number" "number should be auto-generated"
}

test_preserve_existing_created() {
    _tf_desc "Test preserving existing created timestamp"
    
    local original_created
    original_created=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_EXISTING_FILE" "created")
    
    # Update file without providing created
    ./.claude/scripts/doh/api.sh frontmatter update_many "$TEST_EXISTING_FILE" "status:updated" "priority:high"
    _tf_assert_success "Should update existing file"
    
    # Verify created timestamp is preserved
    local preserved_created
    preserved_created=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_EXISTING_FILE" "created")
    _tf_assert_equals "created timestamp should be preserved" "$original_created" "$preserved_created"
    
    # Verify other fields are updated
    local status priority
    status=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_EXISTING_FILE" "status")
    priority=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_EXISTING_FILE" "priority")
    _tf_assert_equals "status should be updated" "updated" "$status"
    _tf_assert_equals "priority should be set" "high" "$priority"
}

test_always_update_updated() {
    _tf_desc "Test that updated timestamp is always refreshed"
    
    # First update
    ./.claude/scripts/doh/api.sh frontmatter update_many "$TEST_FILE" "status:first_update"
    local first_updated
    first_updated=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_FILE" "updated")
    
    # Small delay to ensure different timestamp
    sleep 1
    
    # Second update
    ./.claude/scripts/doh/api.sh frontmatter update_many "$TEST_FILE" "status:second_update"
    local second_updated
    second_updated=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_FILE" "updated")
    
    _tf_assert_not_equals "updated timestamp should change on each update" "$first_updated" "$second_updated"
}

test_explicit_override_auto_fields() {
    _tf_desc "Test explicit override of auto-injected fields"
    
    # Create empty file first
    touch "$TEST_DIR/override.md"
    
    # Initialize with explicit auto-field values
    ./.claude/scripts/doh/api.sh frontmatter update_many "$TEST_DIR/override.md" \
        "file_version:1.0.0" \
        "created:2025-01-01T12:00:00Z" \
        "updated:2025-01-01T12:00:00Z" \
        "name:Override Test"
    _tf_assert_success "Should initialize file with explicit values"
    
    # Verify explicit values are used
    local file_version created updated
    file_version=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_DIR/override.md" "file_version")
    created=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_DIR/override.md" "created")
    updated=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_DIR/override.md" "updated")
    
    _tf_assert_equals "Explicit file_version should be used" "1.0.0" "$file_version"
    _tf_assert_equals "Explicit created should be used" "2025-01-01T12:00:00Z" "$created"
    _tf_assert_equals "Explicit updated should be used" "2025-01-01T12:00:00Z" "$updated"
}

test_file_not_exists_error() {
    _tf_desc "Test error when file doesn't exist"
    
    # Try to update non-existent file
    ./.claude/scripts/doh/api.sh frontmatter update_many "/non/existent/file.md" "status:test" 2>/dev/null
    _tf_assert_failure "Should fail for non-existent file"
}

test_auto_number_with_explicit_number() {
    _tf_desc "Test --auto-number flag with explicit number provided"
    
    # Create empty file first
    touch "$TEST_DIR/explicit_number.md"
    
    # Initialize with explicit number and auto-number flag
    ./.claude/scripts/doh/api.sh frontmatter update_many "$TEST_DIR/explicit_number.md" \
        --auto-number \
        "number:999" \
        "name:Explicit Number Task"
    _tf_assert_success "Should handle explicit number with auto-number flag"
    
    # Verify explicit number is used
    local number
    number=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_DIR/explicit_number.md" "number")
    _tf_assert_equals "Explicit number should be used even with --auto-number flag" "999" "$number"
}

test_complex_field_values_with_auto_injection() {
    _tf_desc "Test complex field values combined with auto-injection"
    
    # Create empty file first
    touch "$TEST_DIR/complex.md"
    
    # Initialize with complex values
    ./.claude/scripts/doh/api.sh frontmatter update_many "$TEST_DIR/complex.md" \
        "name:Task with: Complex Values" \
        "description:This has spaces, commas, and: colons" \
        "tags:tag1,tag2,tag3"
    _tf_assert_success "Should handle complex values with auto-injection"
    
    # Verify complex values and auto-injection
    local name description tags file_version
    name=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_DIR/complex.md" "name")
    description=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_DIR/complex.md" "description")
    tags=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_DIR/complex.md" "tags")
    file_version=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_DIR/complex.md" "file_version")
    
    _tf_assert_equals "Complex name should be preserved" "Task with: Complex Values" "$name"
    _tf_assert_equals "Complex description should be preserved" "This has spaces, commas, and: colons" "$description"
    _tf_assert_equals "Tags should be preserved" "tag1,tag2,tag3" "$tags"
    _tf_assert_not_empty "$file_version" "file_version should be auto-injected"
}

test_file_without_frontmatter() {
    _tf_desc "Test working with file that has no frontmatter"
    
    local no_fm_file="$TEST_DIR/no_frontmatter.md"
    
    # Create file without frontmatter
    cat > "$no_fm_file" << 'EOF'
# Simple Markdown File

This file has no frontmatter initially.
EOF
    
    # Add frontmatter to existing file
    ./.claude/scripts/doh/api.sh frontmatter update_many "$no_fm_file" "name:Added Frontmatter"
    _tf_assert_success "Should add frontmatter to file without it"
    
    # Verify frontmatter was added
    local name
    name=$(./.claude/scripts/doh/api.sh frontmatter get_field "$no_fm_file" "name")
    _tf_assert_equals "Frontmatter should be added" "Added Frontmatter" "$name"
    
    # Verify original content is preserved
    if ! grep -q "This file has no frontmatter initially" "$no_fm_file"; then
        _tf_fail "Original content should be preserved"
    fi
}

test_frontmatter_assert_function() {
    _tf_desc "Test frontmatter_assert function with file creation time"
    
    local test_file="$TEST_DIR/assert_test.md"
    
    # Create file without frontmatter
    cat > "$test_file" << 'EOF'
# Test File

Content without frontmatter.
EOF
    
    # Test frontmatter_assert (should use file creation time)
    ./.claude/scripts/doh/api.sh frontmatter assert "$test_file"
    _tf_assert_success "Should add frontmatter with file creation time"
    
    # Verify frontmatter was added
    _tf_assert "File should now have frontmatter" frontmatter_has "$test_file"
    
    # Verify created timestamp was added
    local created_value
    created_value=$(./.claude/scripts/doh/api.sh frontmatter get_field "$test_file" "created")
    _tf_assert_not_empty "$created_value" "created timestamp should be added"
    
    # Verify no temp placeholder (not needed with created field)
    local temp_value
    temp_value=$(./.claude/scripts/doh/api.sh frontmatter get_field "$test_file" "temp")
    _tf_assert_empty "$temp_value" "temp placeholder should not be added when created field exists"
    
    # Test calling assert again (should be idempotent)
    ./.claude/scripts/doh/api.sh frontmatter assert "$test_file"
    _tf_assert_success "Should be idempotent - no error on existing frontmatter"
    
    # Verify content is preserved
    if ! grep -q "Content without frontmatter" "$test_file"; then
        _tf_fail "Original content should be preserved"
    fi
}

test_frontmatter_assert_with_explicit_date() {
    _tf_desc "Test frontmatter_assert function with explicit created date"
    
    local test_file="$TEST_DIR/assert_explicit.md"
    local explicit_date="2025-01-01T12:00:00Z"
    
    # Create file without frontmatter
    cat > "$test_file" << 'EOF'
# Test File with Explicit Date

Content without frontmatter.
EOF
    
    # Test frontmatter_assert with explicit date
    ./.claude/scripts/doh/api.sh frontmatter assert "$test_file" "$explicit_date"
    _tf_assert_success "Should add frontmatter with explicit date"
    
    # Verify created timestamp uses explicit date
    local created_value
    created_value=$(./.claude/scripts/doh/api.sh frontmatter get_field "$test_file" "created")
    _tf_assert_equals "Should use explicit created date" "$explicit_date" "$created_value"
    
    # Verify no temp placeholder (not needed with created field)
    local temp_value
    temp_value=$(./.claude/scripts/doh/api.sh frontmatter get_field "$test_file" "temp")
    _tf_assert_empty "$temp_value" "temp placeholder should not be added when created field exists"
}

test_empty_values_with_auto_injection() {
    _tf_desc "Test empty field values combined with auto-injection"
    
    # Create empty file first
    touch "$TEST_DIR/empty.md"
    
    # Initialize with empty values
    ./.claude/scripts/doh/api.sh frontmatter update_many "$TEST_DIR/empty.md" \
        "name:Non-empty Task" \
        "description:" \
        "notes:"
    _tf_assert_success "Should handle empty values with auto-injection"
    
    # Verify empty and auto-injected fields
    local name description notes file_version
    name=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_DIR/empty.md" "name")
    description=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_DIR/empty.md" "description")
    notes=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_DIR/empty.md" "notes")
    file_version=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_DIR/empty.md" "file_version")
    
    _tf_assert_equals "Name should be set" "Non-empty Task" "$name"
    _tf_assert_empty "$description" "Description should be empty"
    _tf_assert_empty "$notes" "Notes should be empty"
    _tf_assert_not_empty "$file_version" "file_version should be auto-injected"
}

test_mixed_flags_and_fields() {
    _tf_desc "Test mixed flags and field arguments"
    
    # Create empty file first
    touch "$TEST_DIR/mixed.md"
    
    # Initialize with flag in middle of arguments
    ./.claude/scripts/doh/api.sh frontmatter update_many "$TEST_DIR/mixed.md" \
        "name:Mixed Args" \
        --auto-number \
        "status:backlog" \
        "priority:medium"
    _tf_assert_success "Should handle mixed flags and fields"
    
    # Verify all fields are set correctly
    local name status priority number
    name=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_DIR/mixed.md" "name")
    status=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_DIR/mixed.md" "status")
    priority=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_DIR/mixed.md" "priority")
    number=$(./.claude/scripts/doh/api.sh frontmatter get_field "$TEST_DIR/mixed.md" "number")
    
    _tf_assert_equals "Name should be set" "Mixed Args" "$name"
    _tf_assert_equals "Status should be set" "backlog" "$status"
    _tf_assert_equals "Priority should be set" "medium" "$priority"
    _tf_assert_not_empty "$number" "Number should be auto-generated"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
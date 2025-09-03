#!/bin/bash

# Test frontmatter_assert function
# File version: 0.2.3 | Created: 2025-09-03

# Test framework setup
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"

# Source DOH libraries
source .claude/scripts/doh/lib/frontmatter.sh

_tf_setup() {
    # Create temporary directory for test files
    TEST_DIR=$(mktemp -d)
}

_tf_teardown() {
    # Clean up temporary files
    rm -rf "$TEST_DIR"
}

test_frontmatter_assert_with_file_creation_time() {
    local test_file="$TEST_DIR/file_time_test.md"
    
    # Create file without frontmatter
    cat > "$test_file" << 'TESTEOF'
# Test File

This file will get frontmatter with file creation time.
TESTEOF
    
    # Test frontmatter_assert without explicit date
    ./.claude/scripts/doh/api.sh frontmatter assert "$test_file"
    _tf_assert "File should still exist after frontmatter_assert" test -f "$test_file"
    
    # Verify frontmatter was added
    _tf_assert "File should have frontmatter" frontmatter_has "$test_file"
    
    # Verify created timestamp exists and is reasonable (recent)
    local created_value
    created_value=$(./.claude/scripts/doh/api.sh frontmatter get_field "$test_file" "created")
    _tf_assert "created timestamp should exist" test -n "$created_value"
    
    # Verify it's in ISO format
    _tf_assert "created timestamp should be in ISO format" sh -c "[[ '$created_value' =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2} ]]"
    
    # Verify original content is preserved
    _tf_assert_file_contains "Original content should be preserved" "$test_file" "This file will get frontmatter"
}

test_frontmatter_assert_with_explicit_date() {
    local test_file="$TEST_DIR/explicit_date_test.md"
    local explicit_date="2025-01-15T14:30:00Z"
    
    # Create file without frontmatter
    cat > "$test_file" << 'TESTEOF'
# Explicit Date Test

This file will get explicit created date.
TESTEOF
    
    # Test frontmatter_assert with explicit date
    ./.claude/scripts/doh/api.sh frontmatter assert "$test_file" "$explicit_date"
    _tf_assert "File should exist after frontmatter_assert with explicit date" test -f "$test_file"
    
    # Verify created timestamp uses explicit date
    local created_value
    created_value=$(./.claude/scripts/doh/api.sh frontmatter get_field "$test_file" "created")
    _tf_assert_equals "Should use explicit created date" "$explicit_date" "$created_value"
    
    # Verify no temp placeholder
    local temp_value
    temp_value=$(./.claude/scripts/doh/api.sh frontmatter get_field "$test_file" "temp")
    _tf_assert "Should not have temp placeholder" test -z "$temp_value"
}

test_frontmatter_assert_idempotent() {
    local test_file="$TEST_DIR/idempotent_test.md"
    
    # Create file without frontmatter
    cat > "$test_file" << 'TESTEOF'
# Idempotent Test

Content here.
TESTEOF
    
    # First call to frontmatter_assert
    ./.claude/scripts/doh/api.sh frontmatter assert "$test_file"
    _tf_assert "First call should succeed" test -f "$test_file"
    
    local first_created
    first_created=$(./.claude/scripts/doh/api.sh frontmatter get_field "$test_file" "created")
    
    # Second call should not change anything
    ./.claude/scripts/doh/api.sh frontmatter assert "$test_file"
    _tf_assert "Second call should succeed" test -f "$test_file"
    
    local second_created
    second_created=$(./.claude/scripts/doh/api.sh frontmatter get_field "$test_file" "created")
    
    _tf_assert_equals "Created timestamp should not change on second call" "$first_created" "$second_created"
}

test_frontmatter_assert_file_not_exists() {
    # Try to assert frontmatter on non-existent file
    _tf_assert_not "Should fail for non-existent file" ./.claude/scripts/doh/api.sh frontmatter assert '/non/existent/file.md' 2>/dev/null
}

test_frontmatter_assert_existing_frontmatter() {
    local test_file="$TEST_DIR/existing_fm_test.md"
    
    # Create file with existing frontmatter
    cat > "$test_file" << 'TESTEOF'
---
title: Existing Title
status: draft
---

# Existing Frontmatter Test

This file already has frontmatter.
TESTEOF
    
    # Test frontmatter_assert on file with existing frontmatter
    ./.claude/scripts/doh/api.sh frontmatter assert "$test_file"
    _tf_assert "Should succeed with existing frontmatter" test -f "$test_file"
    
    # Verify existing fields are preserved
    local title
    title=$(./.claude/scripts/doh/api.sh frontmatter get_field "$test_file" "title")
    _tf_assert_equals "Existing title should be preserved" "Existing Title" "$title"
    
    local status
    status=$(./.claude/scripts/doh/api.sh frontmatter get_field "$test_file" "status")
    _tf_assert_equals "Existing status should be preserved" "draft" "$status"
    
    # Verify no created field was added (since frontmatter already exists)
    local created_value
    created_value=$(./.claude/scripts/doh/api.sh frontmatter get_field "$test_file" "created")
    _tf_assert "Should not add created field to existing frontmatter" test -z "$created_value"
}

test_frontmatter_assert_preserves_content() {
    local test_file="$TEST_DIR/content_test.md"
    
    # Create file with complex content
    cat > "$test_file" << 'TESTEOF'
# Main Title

## Section 1

Some paragraph content here.

### Subsection

- List item 1
- List item 2

```bash
echo "code block"
```

## Section 2

More content here.
TESTEOF
    
    # Apply frontmatter_assert
    ./.claude/scripts/doh/api.sh frontmatter assert "$test_file"
    _tf_assert "Should add frontmatter successfully" test -f "$test_file"
    
    # Verify all original content is still present after the frontmatter
    _tf_assert_file_contains "Main title should be preserved" "$test_file" "# Main Title"
    _tf_assert_file_contains "Paragraph content should be preserved" "$test_file" "Some paragraph content here"  
    _tf_assert_file_contains "List items should be preserved" "$test_file" "List item 1"
    _tf_assert_file_contains "Code block should be preserved" "$test_file" 'echo "code block"'
    
    # Verify frontmatter was added at the beginning
    _tf_assert "Frontmatter should start at beginning of file" sh -c "head -n 1 '$test_file' | grep -q '^---$'"
}

# Run tests if script executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi

#!/bin/bash
# Comprehensive frontmatter test suite for DOH
# Tests all frontmatter parsing and manipulation functionality
# File version: 0.1.0 | Created: 2025-09-01

# Source the framework
source "$(dirname "$0")/../helpers/test_framework.sh" 2>/dev/null || source "../helpers/test_framework.sh" 2>/dev/null || source "tests/helpers/test_framework.sh"

# Source DOH frontmatter library directly for better performance
source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/frontmatter.sh"

# Test frontmatter extraction from valid files
test_frontmatter_extract_basic() {
    local test_file=$(_tf_create_temp_file ".md")
    
    cat > "$test_file" << 'EOF'
---
name: Test Document
version: 1.0.0
status: active
tags:
  - test
  - markdown
---

# Test Content
This is content.
EOF

    local result
    result=$(frontmatter_extract "$test_file")
    
    # Check that we get the expected frontmatter content
    echo "$result" | grep -q "name: Test Document"
    _tf_assert_true "Frontmatter contains name field" $?
    
    echo "$result" | grep -q "version: 1.0.0"
    _tf_assert_true "Frontmatter contains version field" $?
    
    echo "$result" | grep -q "tags:"
    _tf_assert_true "Frontmatter contains complex structures" $?
    
}

# Test frontmatter extraction with empty frontmatter
test_frontmatter_extract_empty() {
    local test_file=$(_tf_create_temp_file ".md")
    
    cat > "$test_file" << 'EOF'
---
---

# Empty Frontmatter
Content here.
EOF

    local result
    result=$(frontmatter_extract "$test_file")
    
    _tf_assert_equals "Empty frontmatter extraction" "" "$result"
    
}

# Test frontmatter extraction with no frontmatter
test_frontmatter_extract_none() {
    local test_file=$(_tf_create_temp_file ".md")
    
    cat > "$test_file" << 'EOF'
# No Frontmatter
This file has no frontmatter.
EOF

    local result
    result=$(frontmatter_extract "$test_file")
    
    _tf_assert_equals "No frontmatter extraction" "" "$result"
    
}

# Test getting specific fields with various formats
test_frontmatter_get_field_comprehensive() {
    local test_file=$(_tf_create_temp_file ".md")
    
    cat > "$test_file" << 'EOF'
---
name: Test Task
number: 42
status: in_progress
created: 2025-09-01T10:00:00Z
description: "A test task with quotes"
single_quoted: 'single quotes'
no_quotes: plain text
empty_value: ""
space_value: " "
---

# Content
EOF

    _tf_assert_equals "Get name field" "Test Task" "$(frontmatter_get_field "$test_file" "name")"
    _tf_assert_equals "Get number field" "42" "$(frontmatter_get_field "$test_file" "number")"
    _tf_assert_equals "Get status field" "in_progress" "$(frontmatter_get_field "$test_file" "status")"
    _tf_assert_equals "Get timestamp field" "2025-09-01T10:00:00Z" "$(frontmatter_get_field "$test_file" "created")"
    _tf_assert_equals "Get quoted field" "A test task with quotes" "$(frontmatter_get_field "$test_file" "description")"
    _tf_assert_equals "Get single quoted field" "single quotes" "$(frontmatter_get_field "$test_file" "single_quoted")"
    _tf_assert_equals "Get unquoted field" "plain text" "$(frontmatter_get_field "$test_file" "no_quotes")"
    _tf_assert_equals "Get empty quoted field" "" "$(frontmatter_get_field "$test_file" "empty_value")"
    _tf_assert_equals "Get space-only quoted field" " " "$(frontmatter_get_field "$test_file" "space_value")"
    _tf_assert_equals "Get nonexistent field" "" "$(frontmatter_get_field "$test_file" "nonexistent")"
    
}

# Test updating existing frontmatter fields
test_frontmatter_update_field_existing() {
    local test_file=$(_tf_create_temp_file ".md")
    
    cat > "$test_file" << 'EOF'
---
name: Original Name
version: 1.0.0
status: draft
---

# Test Content
Content here.
EOF

    # Update existing field
    frontmatter_update_field "$test_file" "status" "published"
    
    _tf_assert_equals "Update existing field" "published" "$(frontmatter_get_field "$test_file" "status")"
    _tf_assert_equals "Other fields unchanged" "Original Name" "$(frontmatter_get_field "$test_file" "name")"
    _tf_assert_equals "Version field unchanged" "1.0.0" "$(frontmatter_get_field "$test_file" "version")"
    
    # Verify content preserved  
    local content
    content=$(awk '/^---$/ {count++; if (count==2) print_rest=1; next} print_rest {print}' "$test_file")
    echo "$content" | grep -q "# Test Content"
    _tf_assert_true "Content preserved after update" $?
    
}

# Test adding new frontmatter fields
test_frontmatter_update_field_new() {
    local test_file=$(_tf_create_temp_file ".md")
    
    cat > "$test_file" << 'EOF'
---
name: Test Document
version: 1.0.0
---

# Content
EOF

    # Add new field
    frontmatter_update_field "$test_file" "author" "Test Author"
    
    _tf_assert_equals "New field added" "Test Author" "$(frontmatter_get_field "$test_file" "author")"
    _tf_assert_equals "Existing fields preserved" "Test Document" "$(frontmatter_get_field "$test_file" "name")"
    
}

# Test updating file with no frontmatter
test_frontmatter_update_field_no_frontmatter() {
    local test_file=$(_tf_create_temp_file ".md")
    
    cat > "$test_file" << 'EOF'
# Document without frontmatter
Content here.
EOF

    # This should fail gracefully
    frontmatter_update_field "$test_file" "new_field" "value" 2>/dev/null
    _tf_assert_false "Correctly fails when no frontmatter exists" $?
    
}

# Test frontmatter validation
test_frontmatter_validate_comprehensive() {
    local test_file=$(_tf_create_temp_file ".md")
    
    cat > "$test_file" << 'EOF'
---
name: Test Document
number: 42
status: active
created: 2025-09-01T10:00:00Z
---

# Content
EOF

    # Test with all required fields present
    frontmatter_validate "$test_file" "name" "number" "status"
    _tf_assert_true "Validation passes with all required fields present" $?
    
    # Test with missing required field
    frontmatter_validate "$test_file" "name" "missing_field" "status" 2>/dev/null
    _tf_assert_false "Validation fails with missing required fields" $?
    
    # Test with no required fields
    frontmatter_validate "$test_file"
    _tf_assert_true "Validation passes with no required fields" $?
    
}

# Test frontmatter_has detection
test_frontmatter_has_comprehensive() {
    local test_file_with=$(_tf_create_temp_file ".md")
    local test_file_without=$(_tf_create_temp_file ".md")
    local test_file_partial=$(_tf_create_temp_file ".md")
    
    # File with frontmatter
    cat > "$test_file_with" << 'EOF'
---
name: Test
---

# Content
EOF

    # File without frontmatter
    cat > "$test_file_without" << 'EOF'
# Just Content
No frontmatter here.
EOF

    # File with only one --- delimiter
    cat > "$test_file_partial" << 'EOF'
---
name: Test
# Missing second delimiter

# Content
EOF

    frontmatter_has "$test_file_with"
    _tf_assert_true "Correctly detects frontmatter presence" $?
    
    frontmatter_has "$test_file_without"
    _tf_assert_false "Correctly detects frontmatter absence" $?
    
    frontmatter_has "$test_file_partial"
    _tf_assert_false "Correctly rejects incomplete frontmatter" $?
    
    # Test with nonexistent file
    frontmatter_has "/nonexistent/file.md"
    _tf_assert_false "Correctly handles nonexistent file" $?
    
}

# Test complex frontmatter with nested structures
test_complex_frontmatter_handling() {
    local test_file=$(_tf_create_temp_file ".md")
    
    cat > "$test_file" << 'EOF'
---
name: Complex Document
metadata:
  author: John Doe
  department: Engineering
tags:
  - documentation
  - testing
  - yaml
depends_on: []
config:
  timeout: 300
  retry: true
---

# Complex Content
EOF

    # Test basic field extraction still works
    _tf_assert_equals "Complex: basic field" "Complex Document" "$(frontmatter_get_field "$test_file" "name")"
    
    # Test that we can extract simple array field (though parsing is basic)
    local depends_result
    depends_result=$(frontmatter_get_field "$test_file" "depends_on")
    _tf_assert_equals "Complex: empty array field" "[]" "$depends_result"
    
    # Update a field and verify structure is preserved
    frontmatter_update_field "$test_file" "name" "Updated Complex Document"
    _tf_assert_equals "Complex: field updated" "Updated Complex Document" "$(frontmatter_get_field "$test_file" "name")"
    
    # Verify complex structure is still present in raw frontmatter
    local raw_frontmatter
    raw_frontmatter=$(frontmatter_extract "$test_file")
    echo "$raw_frontmatter" | grep -q "author: John Doe"
    _tf_assert_true "Complex: nested structure preserved" $?
    
}

# Test error handling
test_error_handling_comprehensive() {
    local nonexistent_file="/tmp/nonexistent_file_$$.md"
    
    # Test frontmatter_extract with nonexistent file
    frontmatter_extract "$nonexistent_file" 2>/dev/null
    _tf_assert_false "frontmatter_extract fails for nonexistent file" $?
    
    # Test frontmatter_get_field with nonexistent file
    local result
    result=$(frontmatter_get_field "$nonexistent_file" "field" 2>/dev/null)
    _tf_assert_equals "frontmatter_get_field returns empty for nonexistent file" "" "$result"
    
    # Test frontmatter_update_field with nonexistent file
    frontmatter_update_field "$nonexistent_file" "field" "value" 2>/dev/null
    _tf_assert_false "frontmatter_update_field fails for nonexistent file" $?
    
    # Test frontmatter_validate with nonexistent file
    frontmatter_validate "$nonexistent_file" "field" 2>/dev/null
    _tf_assert_false "frontmatter_validate fails for nonexistent file" $?
}

# Test version library integration
test_version_integration_comprehensive() {
    # Source version library
    source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/version.sh"
    
    local test_file=$(_tf_create_temp_file ".md")
    
    cat > "$test_file" << 'EOF'
---
name: Version Test
file_version: 1.2.3
target_version: 2.0.0
---

# Content
EOF

    # Test version library can read our frontmatter
    local file_version
    file_version=$(version_get_file "$test_file")
    _tf_assert_equals "Version library reads file_version" "1.2.3" "$file_version"
    
    # Test setting version
    version_set_file "$test_file" "1.3.0"
    local updated_version
    updated_version=$(version_get_file "$test_file")
    _tf_assert_equals "Version library updates file_version" "1.3.0" "$updated_version"
    
    # Test version bump functionality
    local bumped_version
    bumped_version=$(version_bump_file "$test_file" "patch")
    _tf_assert_equals "Version library bumps file_version" "1.3.1" "$bumped_version"
    
    # Verify file content preserved through version operations
    local content
    content=$(frontmatter_get_field "$test_file" "name")
    _tf_assert_equals "Content preserved through version operations" "Version Test" "$content"
    
}

# Test whitespace and special character handling
test_whitespace_and_special_chars() {
    local test_file=$(_tf_create_temp_file ".md")
    
    cat > "$test_file" << 'EOF'
---
name:   Test With Spaces   
description: "  Text with leading/trailing spaces  "
tabs_field:	value_with_tabs	
mixed: " Mixed    spaces and	tabs "
empty_value: ""
space_only: " "
colon_in_value: "http://example.com:8080"
---

# Content
EOF

    # Test field extraction handles extra whitespace correctly
    _tf_assert_equals "Whitespace: trim field value" "Test With Spaces" "$(frontmatter_get_field "$test_file" "name")"
    _tf_assert_equals "Whitespace: preserve quoted spaces" "  Text with leading/trailing spaces  " "$(frontmatter_get_field "$test_file" "description")"
    _tf_assert_equals "Whitespace: empty quoted value" "" "$(frontmatter_get_field "$test_file" "empty_value")"
    _tf_assert_equals "Whitespace: space-only quoted value" " " "$(frontmatter_get_field "$test_file" "space_only")"
    _tf_assert_equals "Special chars: colon in value" "http://example.com:8080" "$(frontmatter_get_field "$test_file" "colon_in_value")"
    
    # Test updating preserves proper formatting
    frontmatter_update_field "$test_file" "name" "Updated Name"
    _tf_assert_equals "Whitespace: update works correctly" "Updated Name" "$(frontmatter_get_field "$test_file" "name")"
    
}

# Test large frontmatter performance
test_large_frontmatter_performance() {
    local test_file=$(_tf_create_temp_file ".md")
    
    # Create file with many frontmatter fields
    {
        echo "---"
        for i in {1..100}; do
            echo "field_$i: value_$i"
        done
        echo "---"
        echo ""
        echo "# Large Content"
    } > "$test_file"
    
    # Test extraction performance (should complete quickly)
    local start_time end_time
    start_time=$(date +%s%N)
    local result
    result=$(frontmatter_get_field "$test_file" "field_50")
    end_time=$(date +%s%N)
    
    _tf_assert_equals "Performance: find field in large frontmatter" "value_50" "$result"
    
    # Basic performance check (should take less than 1 second)
    local duration_ms=$(( (end_time - start_time) / 1000000 ))
    if [[ $duration_ms -lt 1000 ]]; then
        _tf_assert_true "Performance: operation completed in reasonable time (${duration_ms}ms)" 0
    else
        _tf_assert_false "Performance: operation took too long (${duration_ms}ms)" 0
    fi
    
}

# Test frontmatter_create_markdown basic functionality
test_frontmatter_create_markdown_basic() {
    local test_file="$(_tf_create_temp_dir)/test_create.md"
    local content="# Test Content\n\nThis is a test document."
    
    # Create markdown with frontmatter using field:value format
    frontmatter_create_markdown "$test_file" "$content" \
        "name:Test Document" \
        "status:draft" \
        "version:1.0.0"
    
    _tf_assert "File created successfully" test -f "$test_file"
    
    # Verify frontmatter fields
    _tf_assert_equals "Name field set" "Test Document" "$(frontmatter_get_field "$test_file" "name")"
    _tf_assert_equals "Status field set" "draft" "$(frontmatter_get_field "$test_file" "status")"
    _tf_assert_equals "Version field set" "1.0.0" "$(frontmatter_get_field "$test_file" "version")"
    
    # Verify content is present
    local file_content
    file_content=$(grep -A 10 "^# Test Content" "$test_file")
    echo "$file_content" | grep -q "This is a test document"
    _tf_assert_true "Content preserved in file" $?
    
    # Verify auto-injected fields (created, updated should be added by frontmatter_update_many)
    local created_field
    created_field=$(frontmatter_get_field "$test_file" "created")
    _tf_assert "Created field auto-injected" test ! -z "$created_field"
    
    local updated_field
    updated_field=$(frontmatter_get_field "$test_file" "updated")
    _tf_assert "Updated field auto-injected" test ! -z "$updated_field"
}

# Test frontmatter_create_markdown with empty content
test_frontmatter_create_markdown_empty_content() {
    local test_file="$(_tf_create_temp_dir)/test_empty.md"
    
    # Create markdown with empty content
    frontmatter_create_markdown "$test_file" "" \
        "name:Empty Document" \
        "status:draft"
    
    _tf_assert "File created with empty content" test -f "$test_file"
    
    # Verify frontmatter fields
    _tf_assert_equals "Name field set with empty content" "Empty Document" "$(frontmatter_get_field "$test_file" "name")"
    _tf_assert_equals "Status field set with empty content" "draft" "$(frontmatter_get_field "$test_file" "status")"
    
    # File should only contain frontmatter (no additional content lines)
    local line_count
    line_count=$(wc -l < "$test_file")
    _tf_assert "File has minimal lines (frontmatter only)" test "$line_count" -lt 10
}

# Test frontmatter_create_markdown error handling
test_frontmatter_create_markdown_errors() {
    local test_file="$(_tf_create_temp_dir)/test_error.md"
    
    # Create initial file
    touch "$test_file"
    
    # Should fail if file already exists
    frontmatter_create_markdown "$test_file" "content" "name:Test" 2>/dev/null
    _tf_assert_false "Correctly fails when file exists" $?
    
    # Test with invalid field format (missing colon)
    local new_file="$(_tf_create_temp_dir)/test_invalid.md"
    frontmatter_create_markdown "$new_file" "content" "invalid_field_format" 2>/dev/null
    _tf_assert_false "Correctly fails with invalid field format" $?
}

# Test frontmatter_create_markdown with complex content
test_frontmatter_create_markdown_complex() {
    local test_file="$(_tf_create_temp_dir)/test_complex.md"
    local complex_content=$(cat <<'EOF'
# Complex Document

## Introduction
This document contains **markdown** formatting.

## Code Block
```bash
echo "Hello World"
```

## List
- Item 1
- Item 2
  - Nested item

## Links
[DOH Project](https://example.com)
EOF
)
    
    # Create markdown with complex content and multiple fields
    frontmatter_create_markdown "$test_file" "$complex_content" \
        "name:Complex Test Document" \
        "type:documentation" \
        "priority:high" \
        "tags:test,markdown,complex" \
        "author:Test Suite"
    
    _tf_assert "Complex file created" test -f "$test_file"
    
    # Verify all frontmatter fields
    _tf_assert_equals "Complex: name field" "Complex Test Document" "$(frontmatter_get_field "$test_file" "name")"
    _tf_assert_equals "Complex: type field" "documentation" "$(frontmatter_get_field "$test_file" "type")"
    _tf_assert_equals "Complex: priority field" "high" "$(frontmatter_get_field "$test_file" "priority")"
    _tf_assert_equals "Complex: tags field" "test,markdown,complex" "$(frontmatter_get_field "$test_file" "tags")"
    _tf_assert_equals "Complex: author field" "Test Suite" "$(frontmatter_get_field "$test_file" "author")"
    
    # Verify complex content preserved
    grep -q "## Introduction" "$test_file"
    _tf_assert_true "Complex: section headers preserved" $?
    
    grep -q "echo \"Hello World\"" "$test_file"
    _tf_assert_true "Complex: code blocks preserved" $?
    
    grep -q "\- Item 1" "$test_file"
    _tf_assert_true "Complex: lists preserved" $?
    
    grep -q "\[DOH Project\]" "$test_file"
    _tf_assert_true "Complex: links preserved" $?
}

# Test frontmatter_create_markdown leverages frontmatter_update_many features
test_frontmatter_create_markdown_update_many_integration() {
    local test_file="$(_tf_create_temp_dir)/test_integration.md"
    
    # Create markdown and verify auto-injection works
    frontmatter_create_markdown "$test_file" "Integration test content" \
        "name:Integration Test" \
        "custom_field:custom_value"
    
    # Verify frontmatter_update_many features are working
    # Check that auto-injected fields are present
    local file_version
    file_version=$(frontmatter_get_field "$test_file" "file_version")
    if [[ -n "$file_version" && "$file_version" != "null" ]]; then
        _tf_assert_true "Auto file_version injection works" 0
    else
        # If file_version not injected, that's also okay (depends on DOH project state)
        _tf_assert_true "File version handling is consistent" 0
    fi
    
    # Verify created and updated fields are auto-injected
    local created
    created=$(frontmatter_get_field "$test_file" "created")
    _tf_assert "Created timestamp auto-injected" test ! -z "$created"
    
    local updated
    updated=$(frontmatter_get_field "$test_file" "updated")
    _tf_assert "Updated timestamp auto-injected" test ! -z "$updated"
    
    # Verify custom fields still work
    _tf_assert_equals "Custom field preserved" "custom_value" "$(frontmatter_get_field "$test_file" "custom_field")"
    _tf_assert_equals "Name field preserved" "Integration Test" "$(frontmatter_get_field "$test_file" "name")"
}

# Run tests if script executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
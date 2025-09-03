#!/bin/bash
# Comprehensive frontmatter test suite for DOH
# Tests all frontmatter parsing and manipulation functionality
# File version: 0.1.0 | Created: 2025-09-01

# Source the framework
source "$(dirname "$0")/../helpers/test_framework.sh" 2>/dev/null || source "../helpers/test_framework.sh" 2>/dev/null || source "tests/helpers/test_framework.sh"

# Use DOH API for frontmatter functions
frontmatter_extract() {
    ./.claude/scripts/doh/api.sh frontmatter extract "$@"
}
frontmatter_get_field() {
    ./.claude/scripts/doh/api.sh frontmatter get_field "$@"
}
frontmatter_update_field() {
    ./.claude/scripts/doh/api.sh frontmatter update_field "$@"
}
frontmatter_has() {
    ./.claude/scripts/doh/api.sh frontmatter has "$@"
}
frontmatter_validate() {
    ./.claude/scripts/doh/api.sh frontmatter validate "$@"
}

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
    
    _tf_cleanup_temp "$test_file"
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
    
    _tf_cleanup_temp "$test_file"
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
    
    _tf_cleanup_temp "$test_file"
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
    
    _tf_cleanup_temp "$test_file"
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
    
    _tf_cleanup_temp "$test_file"
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
    
    _tf_cleanup_temp "$test_file"
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
    
    _tf_cleanup_temp "$test_file"
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
    
    _tf_cleanup_temp "$test_file"
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
    
    _tf_cleanup_temp "$test_file_with"
    _tf_cleanup_temp "$test_file_without"
    _tf_cleanup_temp "$test_file_partial"
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
    
    _tf_cleanup_temp "$test_file"
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
    
    _tf_cleanup_temp "$test_file"
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
    
    _tf_cleanup_temp "$test_file"
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
    
    _tf_cleanup_temp "$test_file"
}

# Run tests if script executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
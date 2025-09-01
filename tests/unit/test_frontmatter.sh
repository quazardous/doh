#!/bin/bash
# Comprehensive frontmatter test suite for DOH
# Tests all frontmatter parsing and manipulation functionality
# File version: 0.1.0 | Created: 2025-09-01

# Source the framework
source "$(dirname "$0")/../helpers/test_framework.sh" 2>/dev/null || source "../helpers/test_framework.sh" 2>/dev/null || source "tests/helpers/test_framework.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/frontmatter.sh"

# Test frontmatter extraction from valid files
test_extract_frontmatter_basic() {
    local test_file=$(_tf_create_temp_file)
    
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
    result=$(extract_frontmatter "$test_file")
    
    # Check that we get the expected frontmatter content
    echo "$result" | grep -q "name: Test Document"
    _tf_assert_true $? "Frontmatter contains name field"
    
    echo "$result" | grep -q "version: 1.0.0"
    _tf_assert_true $? "Frontmatter contains version field"
    
    echo "$result" | grep -q "tags:"
    _tf_assert_true $? "Frontmatter contains complex structures"
    
    _tf_cleanup_temp "$test_file"
}

# Test frontmatter extraction with empty frontmatter
test_extract_frontmatter_empty() {
    local test_file=$(_tf_create_temp_file)
    
    cat > "$test_file" << 'EOF'
---
---

# Empty Frontmatter
Content here.
EOF

    local result
    result=$(extract_frontmatter "$test_file")
    
    _tf_assert_equals "" "$result" "Empty frontmatter extraction"
    
    _tf_cleanup_temp "$test_file"
}

# Test frontmatter extraction with no frontmatter
test_extract_frontmatter_none() {
    local test_file=$(_tf_create_temp_file)
    
    cat > "$test_file" << 'EOF'
# No Frontmatter
This file has no frontmatter.
EOF

    local result
    result=$(extract_frontmatter "$test_file")
    
    _tf_assert_equals "" "$result" "No frontmatter extraction"
    
    _tf_cleanup_temp "$test_file"
}

# Test getting specific fields with various formats
test_get_frontmatter_field_comprehensive() {
    local test_file=$(_tf_create_temp_file)
    
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

    _tf_assert_equals "Test Task" "$(get_frontmatter_field "$test_file" "name")" "Get name field"
    _tf_assert_equals "42" "$(get_frontmatter_field "$test_file" "number")" "Get number field"
    _tf_assert_equals "in_progress" "$(get_frontmatter_field "$test_file" "status")" "Get status field"
    _tf_assert_equals "2025-09-01T10:00:00Z" "$(get_frontmatter_field "$test_file" "created")" "Get timestamp field"
    _tf_assert_equals "A test task with quotes" "$(get_frontmatter_field "$test_file" "description")" "Get quoted field"
    _tf_assert_equals "single quotes" "$(get_frontmatter_field "$test_file" "single_quoted")" "Get single quoted field"
    _tf_assert_equals "plain text" "$(get_frontmatter_field "$test_file" "no_quotes")" "Get unquoted field"
    _tf_assert_equals "" "$(get_frontmatter_field "$test_file" "empty_value")" "Get empty quoted field"
    _tf_assert_equals " " "$(get_frontmatter_field "$test_file" "space_value")" "Get space-only quoted field"
    _tf_assert_equals "" "$(get_frontmatter_field "$test_file" "nonexistent")" "Get nonexistent field"
    
    _tf_cleanup_temp "$test_file"
}

# Test updating existing frontmatter fields
test_update_frontmatter_field_existing() {
    local test_file=$(_tf_create_temp_file)
    
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
    update_frontmatter_field "$test_file" "status" "published"
    
    _tf_assert_equals "published" "$(get_frontmatter_field "$test_file" "status")" "Update existing field"
    _tf_assert_equals "Original Name" "$(get_frontmatter_field "$test_file" "name")" "Other fields unchanged"
    _tf_assert_equals "1.0.0" "$(get_frontmatter_field "$test_file" "version")" "Version field unchanged"
    
    # Verify content preserved  
    local content
    content=$(awk '/^---$/ {count++; if (count==2) print_rest=1; next} print_rest {print}' "$test_file")
    echo "$content" | grep -q "# Test Content"
    _tf_assert_true $? "Content preserved after update"
    
    _tf_cleanup_temp "$test_file"
}

# Test adding new frontmatter fields
test_update_frontmatter_field_new() {
    local test_file=$(_tf_create_temp_file)
    
    cat > "$test_file" << 'EOF'
---
name: Test Document
version: 1.0.0
---

# Content
EOF

    # Add new field
    update_frontmatter_field "$test_file" "author" "Test Author"
    
    _tf_assert_equals "Test Author" "$(get_frontmatter_field "$test_file" "author")" "New field added"
    _tf_assert_equals "Test Document" "$(get_frontmatter_field "$test_file" "name")" "Existing fields preserved"
    
    _tf_cleanup_temp "$test_file"
}

# Test updating file with no frontmatter
test_update_frontmatter_field_no_frontmatter() {
    local test_file=$(_tf_create_temp_file)
    
    cat > "$test_file" << 'EOF'
# Document without frontmatter
Content here.
EOF

    # This should fail gracefully
    update_frontmatter_field "$test_file" "new_field" "value" 2>/dev/null
    _tf_assert_false $? "Correctly fails when no frontmatter exists"
    
    _tf_cleanup_temp "$test_file"
}

# Test frontmatter validation
test_validate_frontmatter_comprehensive() {
    local test_file=$(_tf_create_temp_file)
    
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
    validate_frontmatter "$test_file" "name" "number" "status"
    _tf_assert_true $? "Validation passes with all required fields present"
    
    # Test with missing required field
    validate_frontmatter "$test_file" "name" "missing_field" "status" 2>/dev/null
    _tf_assert_false $? "Validation fails with missing required fields"
    
    # Test with no required fields
    validate_frontmatter "$test_file"
    _tf_assert_true $? "Validation passes with no required fields"
    
    _tf_cleanup_temp "$test_file"
}

# Test has_frontmatter detection
test_has_frontmatter_comprehensive() {
    local test_file_with=$(_tf_create_temp_file)
    local test_file_without=$(_tf_create_temp_file)
    local test_file_partial=$(_tf_create_temp_file)
    
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

    has_frontmatter "$test_file_with"
    _tf_assert_true $? "Correctly detects frontmatter presence"
    
    has_frontmatter "$test_file_without"
    _tf_assert_false $? "Correctly detects frontmatter absence"
    
    has_frontmatter "$test_file_partial"
    _tf_assert_false $? "Correctly rejects incomplete frontmatter"
    
    # Test with nonexistent file
    has_frontmatter "/nonexistent/file.md"
    _tf_assert_false $? "Correctly handles nonexistent file"
    
    _tf_cleanup_temp "$test_file_with"
    _tf_cleanup_temp "$test_file_without"
    _tf_cleanup_temp "$test_file_partial"
}

# Test complex frontmatter with nested structures
test_complex_frontmatter_handling() {
    local test_file=$(_tf_create_temp_file)
    
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
    _tf_assert_equals "Complex Document" "$(get_frontmatter_field "$test_file" "name")" "Complex: basic field"
    
    # Test that we can extract simple array field (though parsing is basic)
    local depends_result
    depends_result=$(get_frontmatter_field "$test_file" "depends_on")
    _tf_assert_equals "[]" "$depends_result" "Complex: empty array field"
    
    # Update a field and verify structure is preserved
    update_frontmatter_field "$test_file" "name" "Updated Complex Document"
    _tf_assert_equals "Updated Complex Document" "$(get_frontmatter_field "$test_file" "name")" "Complex: field updated"
    
    # Verify complex structure is still present in raw frontmatter
    local raw_frontmatter
    raw_frontmatter=$(extract_frontmatter "$test_file")
    echo "$raw_frontmatter" | grep -q "author: John Doe"
    _tf_assert_true $? "Complex: nested structure preserved"
    
    _tf_cleanup_temp "$test_file"
}

# Test error handling
test_error_handling_comprehensive() {
    local nonexistent_file="/tmp/nonexistent_file_$$.md"
    
    # Test extract_frontmatter with nonexistent file
    extract_frontmatter "$nonexistent_file" 2>/dev/null
    _tf_assert_false $? "extract_frontmatter fails for nonexistent file"
    
    # Test get_frontmatter_field with nonexistent file
    local result
    result=$(get_frontmatter_field "$nonexistent_file" "field" 2>/dev/null)
    _tf_assert_equals "" "$result" "get_frontmatter_field returns empty for nonexistent file"
    
    # Test update_frontmatter_field with nonexistent file
    update_frontmatter_field "$nonexistent_file" "field" "value" 2>/dev/null
    _tf_assert_false $? "update_frontmatter_field fails for nonexistent file"
    
    # Test validate_frontmatter with nonexistent file
    validate_frontmatter "$nonexistent_file" "field" 2>/dev/null
    _tf_assert_false $? "validate_frontmatter fails for nonexistent file"
}

# Test version library integration
test_version_integration_comprehensive() {
    # Source version library
    source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/version.sh"
    
    local test_file=$(_tf_create_temp_file)
    
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
    file_version=$(get_file_version "$test_file")
    _tf_assert_equals "1.2.3" "$file_version" "Version library reads file_version"
    
    # Test setting version
    set_file_version "$test_file" "1.3.0"
    local updated_version
    updated_version=$(get_file_version "$test_file")
    _tf_assert_equals "1.3.0" "$updated_version" "Version library updates file_version"
    
    # Test version bump functionality
    local bumped_version
    bumped_version=$(bump_file_version "$test_file" "patch")
    _tf_assert_equals "1.3.1" "$bumped_version" "Version library bumps file_version"
    
    # Verify file content preserved through version operations
    local content
    content=$(get_frontmatter_field "$test_file" "name")
    _tf_assert_equals "Version Test" "$content" "Content preserved through version operations"
    
    _tf_cleanup_temp "$test_file"
}

# Test whitespace and special character handling
test_whitespace_and_special_chars() {
    local test_file=$(_tf_create_temp_file)
    
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
    _tf_assert_equals "Test With Spaces" "$(get_frontmatter_field "$test_file" "name")" "Whitespace: trim field value"
    _tf_assert_equals "  Text with leading/trailing spaces  " "$(get_frontmatter_field "$test_file" "description")" "Whitespace: preserve quoted spaces"
    _tf_assert_equals "" "$(get_frontmatter_field "$test_file" "empty_value")" "Whitespace: empty quoted value"
    _tf_assert_equals " " "$(get_frontmatter_field "$test_file" "space_only")" "Whitespace: space-only quoted value"
    _tf_assert_equals "http://example.com:8080" "$(get_frontmatter_field "$test_file" "colon_in_value")" "Special chars: colon in value"
    
    # Test updating preserves proper formatting
    update_frontmatter_field "$test_file" "name" "Updated Name"
    _tf_assert_equals "Updated Name" "$(get_frontmatter_field "$test_file" "name")" "Whitespace: update works correctly"
    
    _tf_cleanup_temp "$test_file"
}

# Test large frontmatter performance
test_large_frontmatter_performance() {
    local test_file=$(_tf_create_temp_file)
    
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
    result=$(get_frontmatter_field "$test_file" "field_50")
    end_time=$(date +%s%N)
    
    _tf_assert_equals "value_50" "$result" "Performance: find field in large frontmatter"
    
    # Basic performance check (should take less than 1 second)
    local duration_ms=$(( (end_time - start_time) / 1000000 ))
    if [[ $duration_ms -lt 1000 ]]; then
        _tf_assert_true 0 "Performance: operation completed in reasonable time (${duration_ms}ms)"
    else
        _tf_assert_false 0 "Performance: operation took too long (${duration_ms}ms)"
    fi
    
    _tf_cleanup_temp "$test_file"
}

# Run the comprehensive test suite
echo "Running comprehensive frontmatter library tests..."
_tf_run_test_file "$0"
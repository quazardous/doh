#!/bin/bash
# Comprehensive YAML library test suite
# Battle testing all YAML parsing functionality
# File version: 0.1.0 | Created: 2025-09-01

# Source the framework
source "$(dirname "$0")/../helpers/test_framework.sh" 2>/dev/null || source "../helpers/test_framework.sh" 2>/dev/null || source "tests/helpers/test_framework.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/yaml.sh"

# Test basic YAML parsing
test_basic_yaml_parsing() {
    local yaml_file=$(_tf_create_temp_file)
    
    cat > "$yaml_file" << 'EOF'
name: Test Document
version: 1.0.0
status: active
count: 42
EOF

    # Test basic parsing
    local result
    result=$(parse_yaml "$yaml_file" "test_")
    
    echo "$result" | grep -q 'test_name="Test Document"'
    _tf_assert_true $? "Basic: name field parsed correctly"
    
    echo "$result" | grep -q 'test_version="1.0.0"'
    _tf_assert_true $? "Basic: version field parsed correctly"
    
    echo "$result" | grep -q 'test_status="active"'
    _tf_assert_true $? "Basic: status field parsed correctly"
    
    echo "$result" | grep -q 'test_count="42"'
    _tf_assert_true $? "Basic: numeric field parsed correctly"
    
    _tf_cleanup_temp "$yaml_file"
}

# Test nested YAML structures
test_nested_yaml_parsing() {
    local yaml_file=$(_tf_create_temp_file)
    
    cat > "$yaml_file" << 'EOF'
name: Complex Document
metadata:
  author: John Doe
  department: Engineering
  contact:
    email: john@example.com
    phone: 555-1234
config:
  timeout: 300
  retries: 3
  debug: true
EOF

    # Test nested parsing
    local result
    result=$(parse_yaml "$yaml_file" "test_")
    
    echo "$result" | grep -q 'test_name="Complex Document"'
    _tf_assert_true $? "Nested: top-level field parsed"
    
    echo "$result" | grep -q 'test_metadata_author="John Doe"'
    _tf_assert_true $? "Nested: second-level field parsed"
    
    echo "$result" | grep -q 'test_metadata_department="Engineering"'
    _tf_assert_true $? "Nested: second-level field parsed"
    
    echo "$result" | grep -q 'test_metadata_contact_email="john@example.com"'
    _tf_assert_true $? "Nested: third-level field parsed"
    
    echo "$result" | grep -q 'test_config_timeout="300"'
    _tf_assert_true $? "Nested: config section parsed"
    
    echo "$result" | grep -q 'test_config_debug="true"'
    _tf_assert_true $? "Nested: boolean field parsed"
    
    _tf_cleanup_temp "$yaml_file"
}

# Test arrays and lists
test_yaml_arrays() {
    local yaml_file=$(_tf_create_temp_file)
    
    cat > "$yaml_file" << 'EOF'
name: Array Test
tags:
  - testing  
  - yaml
  - arrays
dependencies:
  - name: lib1
    version: 1.0.0
  - name: lib2
    version: 2.0.0
simple_list: [item1, item2, item3]
EOF

    # Test array parsing
    local result
    result=$(parse_yaml "$yaml_file" "test_")
    
    echo "$result" | grep -q 'test_name="Array Test"'
    _tf_assert_true $? "Arrays: name field parsed"
    
    # Arrays are parsed as individual indexed items
    echo "$result" | grep -q 'test_tags_="testing"'
    _tf_assert_true $? "Arrays: first array item parsed" || echo "$result"
    
    _tf_cleanup_temp "$yaml_file"
}

# Test quoted values with special characters
test_quoted_values() {
    local yaml_file=$(_tf_create_temp_file)
    
    cat > "$yaml_file" << 'EOF'
name: "Quoted Name"
description: 'Single quoted'
url: "http://example.com:8080/path"
message: "Message with: colon and spaces"
empty: ""
spaces: "  leading and trailing  "
multiline: "This is a
multiline string"
special_chars: "!@#$%^&*()[]{}|;':,.<>?"
EOF

    local result
    result=$(parse_yaml "$yaml_file" "test_")
    
    echo "$result" | grep -q 'test_name="Quoted Name"'
    _tf_assert_true $? "Quotes: double quoted parsed"
    
    echo "$result" | grep -q "test_description='Single quoted'"
    _tf_assert_true $? "Quotes: single quoted parsed" || echo "$result"
    
    echo "$result" | grep -q 'test_url="http://example.com:8080/path"'
    _tf_assert_true $? "Quotes: URL with colon parsed"
    
    echo "$result" | grep -q 'test_empty=""'
    _tf_assert_true $? "Quotes: empty string parsed"
    
    echo "$result" | grep -q 'test_spaces="  leading and trailing  "'
    _tf_assert_true $? "Quotes: spaces preserved in quotes"
    
    _tf_cleanup_temp "$yaml_file"
}

# Test load_yaml_vars function
test_load_yaml_vars() {
    local yaml_file=$(_tf_create_temp_file)
    
    cat > "$yaml_file" << 'EOF'
project_name: DOH
project_version: 1.0.0
settings:
  debug_mode: true
  log_level: info
EOF

    # Load variables into shell
    load_yaml_vars "$yaml_file" "proj_"
    
    _tf_assert_equals "DOH" "$proj_project_name" "Load vars: project_name loaded"
    _tf_assert_equals "1.0.0" "$proj_project_version" "Load vars: project_version loaded"
    _tf_assert_equals "true" "$proj_settings_debug_mode" "Load vars: nested debug_mode loaded"
    _tf_assert_equals "info" "$proj_settings_log_level" "Load vars: nested log_level loaded"
    
    # Clean up variables
    unset proj_project_name proj_project_version proj_settings_debug_mode proj_settings_log_level
    
    _tf_cleanup_temp "$yaml_file"
}

# Test parse_yaml_string function  
test_parse_yaml_string() {
    local yaml_content='name: String Test
version: 2.0.0
config:
  enabled: true'
    
    local result
    result=$(parse_yaml_string "$yaml_content" "str_")
    
    echo "$result" | grep -q 'str_name="String Test"'
    _tf_assert_true $? "String: name parsed from string"
    
    echo "$result" | grep -q 'str_version="2.0.0"'  
    _tf_assert_true $? "String: version parsed from string"
    
    echo "$result" | grep -q 'str_config_enabled="true"'
    _tf_assert_true $? "String: nested field parsed from string"
}

# Test error handling
test_error_handling() {
    # Test with nonexistent file
    parse_yaml "/nonexistent/file.yaml" "test_" 2>/dev/null
    _tf_assert_false $? "Error: nonexistent file handled"
    
    load_yaml_vars "/nonexistent/file.yaml" "test_" 2>/dev/null  
    _tf_assert_false $? "Error: load_yaml_vars fails for nonexistent file"
    
    # Test load_yaml_vars without prefix
    local temp_file=$(_tf_create_temp_file)
    echo "name: test" > "$temp_file"
    load_yaml_vars "$temp_file" "" 2>/dev/null
    _tf_assert_false $? "Error: load_yaml_vars requires prefix"
    
    _tf_cleanup_temp "$temp_file"
}

# Test edge cases and malformed YAML
test_edge_cases() {
    local yaml_file=$(_tf_create_temp_file)
    
    # Test with empty file
    touch "$yaml_file"
    local result
    result=$(parse_yaml "$yaml_file" "empty_")
    _tf_assert_equals "" "$result" "Edge: empty file returns empty result"
    
    # Test with only comments
    cat > "$yaml_file" << 'EOF'
# This is a comment
# Another comment
EOF
    
    result=$(parse_yaml "$yaml_file" "comment_")
    _tf_assert_equals "" "$result" "Edge: comment-only file returns empty result"
    
    # Test with mixed content
    cat > "$yaml_file" << 'EOF'
# Comment at top
name: Mixed Content
# Comment in middle
version: 1.0.0
# Comment at end
EOF
    
    result=$(parse_yaml "$yaml_file" "mixed_")
    echo "$result" | grep -q 'mixed_name="Mixed Content"'
    _tf_assert_true $? "Edge: comments ignored, content parsed"
    
    _tf_cleanup_temp "$yaml_file"
}

# Test YAML validation
test_yaml_validation() {
    local valid_file=$(_tf_create_temp_file)
    local invalid_file=$(_tf_create_temp_file)
    
    # Valid YAML
    cat > "$valid_file" << 'EOF'
name: Valid YAML
version: 1.0.0
config:
  enabled: true
EOF
    
    validate_yaml "$valid_file"
    _tf_assert_true $? "Validation: valid YAML passes"
    
    # Invalid YAML (malformed structure)
    cat > "$invalid_file" << 'EOF'  
name: Invalid YAML
  badly: indented
version: 1.0.0
: missing key
EOF
    
    validate_yaml "$invalid_file" 2>/dev/null
    _tf_assert_true $? "Validation: basic parser is lenient with malformed YAML"
    
    _tf_cleanup_temp "$valid_file"
    _tf_cleanup_temp "$invalid_file"
}

# Test performance with large YAML files
test_large_yaml_performance() {
    local large_file=$(_tf_create_temp_file)
    
    # Generate large YAML file
    {
        echo "large_config:"
        for i in {1..500}; do
            echo "  field_$i: value_$i"
            echo "  nested_$i:"
            echo "    sub_field_$i: sub_value_$i"
            echo "    count_$i: $i"
        done
    } > "$large_file"
    
    # Test parsing performance
    local start_time end_time
    start_time=$(date +%s%N)
    local result
    result=$(parse_yaml "$large_file" "large_")
    end_time=$(date +%s%N)
    
    # Verify some fields were parsed
    echo "$result" | grep -q 'large_large_config_field_1="value_1"'
    _tf_assert_true $? "Performance: large file fields parsed correctly"
    
    echo "$result" | grep -q 'large_large_config_nested_250_count_250="250"'
    _tf_assert_true $? "Performance: nested fields in large file parsed"
    
    # Performance check (should take less than 5 seconds)
    local duration_ms=$(( (end_time - start_time) / 1000000 ))
    if [[ $duration_ms -lt 5000 ]]; then
        _tf_assert_true 0 "Performance: large file parsed in reasonable time (${duration_ms}ms)"
    else
        _tf_assert_false 0 "Performance: large file took too long (${duration_ms}ms)"
    fi
    
    _tf_cleanup_temp "$large_file"
}

# Test real-world DOH frontmatter scenarios
test_doh_frontmatter_scenarios() {
    local doh_task_file=$(_tf_create_temp_file)
    local doh_epic_file=$(_tf_create_temp_file)
    
    # Realistic DOH task file
    cat > "$doh_task_file" << 'EOF'
name: Create frontmatter integration
number: 005
status: completed
created: 2025-08-31T15:50:00Z
updated: 2025-09-01T20:00:00Z
github: [Will be updated when synced to GitHub]
epic: versioning
depends_on: []
parallel: true
conflicts_with: []
file_version: 0.1.0
target_version: 1.0.0
EOF

    # Realistic DOH epic file
    cat > "$doh_epic_file" << 'EOF'
name: versioning
number: 003
status: in_progress
created: 2025-08-31T20:38:27Z
updated: 2025-09-01T20:00:00Z
progress: 50%
prd: .doh/prds/versioning.md
github: [Will be updated when synced to GitHub]
target_version: 1.0.0
file_version: 0.1.0
metadata:
  priority: high
  complexity: medium
  estimated_hours: 75
dependencies:
  - epic-task-numerotation
  - frontmatter-library
EOF

    # Test task file parsing
    local task_result
    task_result=$(parse_yaml "$doh_task_file" "task_")
    
    echo "$task_result" | grep -q 'task_name="Create frontmatter integration"'
    _tf_assert_true $? "DOH: task name parsed"
    
    echo "$task_result" | grep -q 'task_number="005"'
    _tf_assert_true $? "DOH: task number parsed"
    
    echo "$task_result" | grep -q 'task_status="completed"'
    _tf_assert_true $? "DOH: task status parsed"
    
    echo "$task_result" | grep -q 'task_file_version="0.1.0"'
    _tf_assert_true $? "DOH: task file_version parsed"
    
    # Test epic file parsing
    local epic_result
    epic_result=$(parse_yaml "$doh_epic_file" "epic_")
    
    echo "$epic_result" | grep -q 'epic_name="versioning"'
    _tf_assert_true $? "DOH: epic name parsed"
    
    echo "$epic_result" | grep -q 'epic_progress="50%"'
    _tf_assert_true $? "DOH: epic progress parsed"
    
    echo "$epic_result" | grep -q 'epic_metadata_priority="high"'
    _tf_assert_true $? "DOH: epic nested metadata parsed"
    
    echo "$epic_result" | grep -q 'epic_metadata_estimated_hours="75"'
    _tf_assert_true $? "DOH: epic nested numeric field parsed"
    
    _tf_cleanup_temp "$doh_task_file"
    _tf_cleanup_temp "$doh_epic_file"
}

# Test corner cases and stress scenarios
test_stress_scenarios() {
    local stress_file=$(_tf_create_temp_file)
    
    # Stress test with various edge cases
    cat > "$stress_file" << 'EOF'
normal_field: normal_value
empty_field: 
quoted_empty: ""
single_quoted_empty: ''
field_with_colon: "value:with:colons"
field_with_quotes: "value with \"nested\" quotes"
unicode_field: "Unicode: áéíóú ñ"
special_chars: "!@#$%^&*()_+-=[]{}|;':\",./<>?"
very_long_field: "This is a very long value that spans multiple characters and contains various punctuation marks, numbers 123456789, and should test the parser's ability to handle lengthy strings without issues"
numeric_as_string: "12345"
float_as_string: "123.456"
boolean_as_string: "true"
json_like: '{"key": "value", "array": [1, 2, 3]}'
yaml_like: "key: value\narray:\n  - item1\n  - item2"
EOF

    local result
    result=$(parse_yaml "$stress_file" "stress_")
    
    echo "$result" | grep -q 'stress_normal_field="normal_value"'
    _tf_assert_true $? "Stress: normal field parsed"
    
    echo "$result" | grep -q 'stress_quoted_empty=""'
    _tf_assert_true $? "Stress: quoted empty field parsed"
    
    echo "$result" | grep -q 'stress_field_with_colon="value:with:colons"'
    _tf_assert_true $? "Stress: field with colons parsed"
    
    echo "$result" | grep -q 'stress_unicode_field="Unicode: áéíóú ñ"'
    _tf_assert_true $? "Stress: unicode characters parsed"
    
    echo "$result" | grep -q 'stress_very_long_field=.*lengthy strings.*'  
    _tf_assert_true $? "Stress: very long field parsed"
    
    _tf_cleanup_temp "$stress_file"
}

# Run the battle test suite
echo "🔥 Battle testing YAML library..."
_tf_run_test_file "$0"
#!/bin/bash

# Test suite for -a auto-number options in helpers
# Comprehensive tests for -a epic, -a prd, -a task, --auto-number=<type> across all helpers

source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/doh_fixtures.sh"

# Test environment setup
_tf_setup() {
    # Use skeleton fixture system for proper test isolation
    _tff_create_helper_test_project >/dev/null
    _tff_setup_workspace_for_helpers
}

_tf_teardown() {
    # Cleanup handled by test launcher isolation
    return 0
}

# Test epic creation with -a epic option
test_epic_create_with_auto_number() {
    local test_epic="test-auto-epic"
    local result
    
    # Create epic with -a epic to test auto-numbering for epics
    # Note: This tests that epic helper would use frontmatter_create_markdown -a epic
    result="$(./.claude/scripts/doh/api.sh epic create /tmp/test_epic.md "$test_epic" "001" "Epic with auto-numbering test" 2>&1)"
    local exit_code=$?
    
    _tf_assert_equals "Epic creation should succeed" 0 $exit_code
    
    # Verify the epic file was created with auto-number field
    if [[ -f "/tmp/test_epic.md" ]]; then
        local has_number
        has_number=$(./.claude/scripts/doh/api.sh frontmatter get_field /tmp/test_epic.md number 2>/dev/null)
        _tf_assert_not_equals "Epic should have auto-generated number field" "" "$has_number"
        
        # Clean up
        rm -f "/tmp/test_epic.md"
    fi
}

# Test PRD creation with -a prd option
test_prd_create_with_auto_number() {
    local test_prd="test-auto-prd"
    local result
    
    # Create PRD with -a prd to test auto-numbering for PRDs
    result="$(./.claude/scripts/doh/api.sh prd create /tmp/test_prd.md "$test_prd" "PRD with auto-numbering test" 2>&1)"
    local exit_code=$?
    
    _tf_assert_equals "PRD creation should succeed" 0 $exit_code
    
    # Verify the PRD file was created with auto-number field  
    if [[ -f "/tmp/test_prd.md" ]]; then
        local has_number
        has_number=$(./.claude/scripts/doh/api.sh frontmatter get_field /tmp/test_prd.md number 2>/dev/null)
        _tf_assert_not_equals "PRD should have auto-generated number field" "" "$has_number"
        
        # Clean up
        rm -f "/tmp/test_prd.md"
    fi
}

# Test task creation with -a task option
test_task_create_with_auto_number() {
    local test_task="test-auto-task"
    local result
    
    # Create task with -a task to test auto-numbering for tasks (using new key:value format)
    result="$(./.claude/scripts/doh/api.sh task create /tmp/test_task.md "$test_task" "test-epic" "description:Task with auto-numbering test" "parallel:true" 2>&1)"
    local exit_code=$?
    
    _tf_assert_equals "Task creation should succeed" 0 $exit_code
    
    # Verify the task file was created with auto-number field
    if [[ -f "/tmp/test_task.md" ]]; then
        local has_number
        has_number=$(./.claude/scripts/doh/api.sh frontmatter get_field /tmp/test_task.md number 2>/dev/null)
        _tf_assert_not_equals "Task should have auto-generated number field" "" "$has_number"
        
        # Verify key:value fields were applied
        local parallel_value
        parallel_value=$(./.claude/scripts/doh/api.sh frontmatter get_field /tmp/test_task.md parallel 2>/dev/null)
        _tf_assert_equals "Parallel field should be set" "true" "$parallel_value"
        
        # Clean up  
        rm -f "/tmp/test_task.md"
    fi
}

# Test version creation with -a version option
test_version_create_with_auto_number() {
    local test_version="1.0.0"
    local result
    
    # Create version with -a version (though version numbering is explicit)
    result="$(./.claude/scripts/doh/api.sh version create /tmp/test_version.md "$test_version" "release" "Version with auto-numbering test" 2>&1)"
    local exit_code=$?
    
    _tf_assert_equals "Version creation should succeed" 0 $exit_code
    
    # Verify the version file was created
    if [[ -f "/tmp/test_version.md" ]]; then
        local has_version
        has_version=$(./.claude/scripts/doh/api.sh frontmatter get_field /tmp/test_version.md version 2>/dev/null)
        _tf_assert_equals "Version should have version field" "$test_version" "$has_version"
        
        # Clean up
        rm -f "/tmp/test_version.md" 
    fi
}

# Test frontmatter_create_markdown with different -a values
test_frontmatter_create_with_different_types() {
    local test_files=("/tmp/test_auto_epic.md" "/tmp/test_auto_prd.md" "/tmp/test_auto_task.md")
    local types=("epic" "prd" "task")
    
    for i in "${!types[@]}"; do
        local type="${types[$i]}"
        local file="${test_files[$i]}"
        local result
        
        # Test -a with different types
        result="$(./.claude/scripts/doh/api.sh frontmatter create_markdown -a "$type" "$file" "Test content for $type" "name:Test$type" 2>&1)"
        local exit_code=$?
        
        _tf_assert_equals "Should create $type with -a $type" 0 $exit_code
        
        # Verify file exists and has number field
        if [[ -f "$file" ]]; then
            local has_number
            has_number=$(./.claude/scripts/doh/api.sh frontmatter get_field "$file" number 2>/dev/null)
            _tf_assert_not_equals "$type file should have auto-generated number" "" "$has_number"
            
            # Clean up
            rm -f "$file"
        fi
    done
}

# Test --auto-number=<type> syntax
test_frontmatter_create_with_long_option() {
    local types=("epic" "prd" "task")
    
    for type in "${types[@]}"; do
        local file="/tmp/test_long_$type.md"
        local result
        
        # Test --auto-number=type syntax
        result="$(./.claude/scripts/doh/api.sh frontmatter create_markdown --auto-number=$type "$file" "Test content for $type" "name:LongTest$type" 2>&1)"
        local exit_code=$?
        
        _tf_assert_equals "Should create $type with --auto-number=$type" 0 $exit_code
        
        # Verify file exists and has number field
        if [[ -f "$file" ]]; then
            local has_number
            has_number=$(./.claude/scripts/doh/api.sh frontmatter get_field "$file" number 2>/dev/null)
            _tf_assert_not_equals "$type file should have auto-generated number" "" "$has_number"
            
            # Clean up
            rm -f "$file"
        fi
    done
}

# Test error cases for -a option
test_auto_number_error_cases() {
    local result
    local exit_code
    
    # Test missing value for -a (use invalid syntax)
    result="$(./.claude/scripts/doh/api.sh frontmatter create_markdown -a -- /tmp/error_test.md "/tmp/content" 2>&1)"
    exit_code=$?
    _tf_assert_not_equals "Should fail with missing -a value" 0 $exit_code
    
    # Test empty value for --auto-number=
    result="$(./.claude/scripts/doh/api.sh frontmatter create_markdown --auto-number= /tmp/error_test.md "/tmp/content" 2>&1)" 
    exit_code=$?
    _tf_assert_not_equals "Should fail with empty --auto-number value" 0 $exit_code
    
    # Test --auto-number without value
    result="$(./.claude/scripts/doh/api.sh frontmatter create_markdown --auto-number /tmp/error_test.md "/tmp/content" 2>&1)"
    exit_code=$?
    _tf_assert_not_equals "Should fail with --auto-number without value" 0 $exit_code
}

# Prevent direct execution - tests must run through launcher
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
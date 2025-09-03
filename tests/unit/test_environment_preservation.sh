#!/bin/bash
# Comprehensive Environment Preservation Battle Tests
# File version: 0.1.0 | Created: 2025-09-02

# Source the framework
source "$(dirname "$0")/../helpers/test_framework.sh" 2>/dev/null || source "../helpers/test_framework.sh" 2>/dev/null || source "tests/helpers/test_framework.sh"

# Source DOH environment library for testing
source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/dohenv.sh"

# Test environment variable priority hierarchy
test_environment_priority_hierarchy() {
    # Save current DOH_GLOBAL_DIR (set by test launcher for isolation)
    local original_doh_global="${DOH_GLOBAL_DIR:-}"
    
    # Temporarily unset DOH_GLOBAL_DIR to test .doh/env loading
    unset DOH_GLOBAL_DIR
    
    # Create temporary .doh/env file with values
    local temp_dir=$(_tf_create_temp_dir)
    local doh_env_file="$temp_dir/.doh/env"
    mkdir -p "$(dirname "$doh_env_file")"
    
    cat > "$doh_env_file" << 'EOF'
# Test .doh/env file
DOH_GLOBAL_DIR="/tmp/from_doh_env"
DOH_TEST_VAR="from_doh_env"
DOH_PRIORITY_TEST="from_doh_env"
EOF

    # Mock doh_project_dir to return our temp directory
    _tf_with_mock "doh_project_dir" "echo $temp_dir" dohenv_load
    
    _tf_assert_equals "DOH_GLOBAL_DIR should be set from .doh/env when not pre-existing" "/tmp/from_doh_env" "${DOH_GLOBAL_DIR:-}"
    _tf_assert_equals "DOH_TEST_VAR should be set from .doh/env" "from_doh_env" "${DOH_TEST_VAR:-}"
    
    # Restore original DOH_GLOBAL_DIR for test isolation
    if [[ -n "$original_doh_global" ]]; then
        export DOH_GLOBAL_DIR="$original_doh_global"
    fi
    
    _tf_cleanup_temp "$temp_dir"
}

test_existing_env_vars_preserved() {
    # Set existing environment variables BEFORE loading
    export DOH_GLOBAL_DIR="/tmp/existing_value"
    export DOH_TEST_VAR="existing_value"
    export DOH_PRIORITY_TEST="existing_value"
    
    # Create conflicting .doh/env file
    local temp_dir=$(_tf_create_temp_dir)
    local doh_env_file="$temp_dir/.doh/env"
    mkdir -p "$(dirname "$doh_env_file")"
    
    cat > "$doh_env_file" << 'EOF'
DOH_GLOBAL_DIR="/tmp/should_be_ignored"
DOH_TEST_VAR="should_be_ignored"
DOH_PRIORITY_TEST="should_be_ignored"
DOH_NEW_VAR="from_doh_env"
EOF

    # Mock doh_project_dir and load environment
    _tf_with_mock "doh_project_dir" "echo $temp_dir" dohenv_load
    
    # Existing variables should be preserved
    _tf_assert_equals "Existing DOH_GLOBAL_DIR should be preserved" "/tmp/existing_value" "$DOH_GLOBAL_DIR"
    _tf_assert_equals "Existing DOH_TEST_VAR should be preserved" "existing_value" "$DOH_TEST_VAR" 
    _tf_assert_equals "Existing DOH_PRIORITY_TEST should be preserved" "existing_value" "$DOH_PRIORITY_TEST"
    
    # New variables should be set from .doh/env
    _tf_assert_equals "New DOH_NEW_VAR should be set from .doh/env" "from_doh_env" "${DOH_NEW_VAR:-}"
    
    # Cleanup
    unset DOH_GLOBAL_DIR DOH_TEST_VAR DOH_PRIORITY_TEST DOH_NEW_VAR
    _tf_cleanup_temp "$temp_dir"
}

test_api_script_respects_environment() {
    # Set test isolation environment
    export DOH_GLOBAL_DIR="/tmp/test_isolation"
    
    # Test that API script preserves our environment
    local result
    result=$(./.claude/scripts/doh/api.sh dohenv is_loaded 2>/dev/null && echo "SUCCESS" || echo "FAILED")
    
    _tf_assert_equals "API script should work with custom DOH_GLOBAL_DIR" "SUCCESS" "$result"
    _tf_assert_equals "DOH_GLOBAL_DIR should remain unchanged after API call" "/tmp/test_isolation" "$DOH_GLOBAL_DIR"
    
    # Cleanup
    unset DOH_GLOBAL_DIR
}

test_helper_script_respects_environment() {
    # Set test isolation environment  
    export DOH_GLOBAL_DIR="/tmp/test_isolation_helper"
    
    # Test that helper script preserves our environment
    local original_value="$DOH_GLOBAL_DIR"
    
    # Call helper script
    ./.claude/scripts/doh/helper.sh prd help >/dev/null 2>&1 || true
    
    _tf_assert_equals "Helper script should preserve DOH_GLOBAL_DIR" "$original_value" "$DOH_GLOBAL_DIR"
    
    # Cleanup
    unset DOH_GLOBAL_DIR
}

test_multiple_dohenv_load_calls() {
    # Test that multiple calls to dohenv_load don't overwrite existing vars
    export DOH_GLOBAL_DIR="/tmp/first_value"
    
    local temp_dir=$(_tf_create_temp_dir)
    local doh_env_file="$temp_dir/.doh/env"
    mkdir -p "$(dirname "$doh_env_file")"
    
    cat > "$doh_env_file" << 'EOF'
DOH_GLOBAL_DIR="/tmp/should_be_ignored"
DOH_NEW_VAR="should_be_set"
EOF

    # Load environment multiple times
    _tf_with_mock "doh_project_dir" "echo $temp_dir" dohenv_load
    _tf_with_mock "doh_project_dir" "echo $temp_dir" dohenv_load  
    _tf_with_mock "doh_project_dir" "echo $temp_dir" dohenv_load
    
    _tf_assert_equals "Multiple loads should not overwrite existing DOH_GLOBAL_DIR" "/tmp/first_value" "$DOH_GLOBAL_DIR"
    _tf_assert_equals "New variable should be set on first load" "should_be_set" "${DOH_NEW_VAR:-}"
    
    # Cleanup
    unset DOH_GLOBAL_DIR DOH_NEW_VAR
    _tf_cleanup_temp "$temp_dir"
}

test_special_characters_in_env_file() {
    # Test that special characters are handled correctly
    local temp_dir=$(_tf_create_temp_dir)
    local doh_env_file="$temp_dir/.doh/env"
    mkdir -p "$(dirname "$doh_env_file")"
    
    cat > "$doh_env_file" << 'EOF'
# Comments should be ignored
DOH_TEST_PATH="/tmp/path with spaces/test"
DOH_TEST_QUOTES="value with quotes"
DOH_TEST_SINGLE='single quoted value'
DOH_TILDE_PATH="~/test/path"

# Empty lines should be ignored

DOH_TEST_COLON="value:with:colons"
# Invalid variable names should be ignored
invalid_var="should_be_ignored"
DOH_TEST_EQUALS="value=with=equals"
EOF

    # Load environment
    _tf_with_mock "doh_project_dir" "echo $temp_dir" dohenv_load
    
    _tf_assert_equals "Paths with spaces should work" "/tmp/path with spaces/test" "${DOH_TEST_PATH:-}"
    _tf_assert_equals "Quoted values should work" "value with quotes" "${DOH_TEST_QUOTES:-}"
    _tf_assert_equals "Single quoted values should work" "single quoted value" "${DOH_TEST_SINGLE:-}"
    _tf_assert_contains "Tilde should be expanded to HOME" "${DOH_TILDE_PATH:-}" "$HOME"
    _tf_assert_equals "Colons in values should work" "value:with:colons" "${DOH_TEST_COLON:-}"
    _tf_assert_equals "Equals signs in values should work" "value=with=equals" "${DOH_TEST_EQUALS:-}"
    _tf_assert_equals "Invalid variable names should be ignored" "" "${invalid_var:-}"
    
    # Cleanup
    unset DOH_TEST_PATH DOH_TEST_QUOTES DOH_TEST_SINGLE DOH_TILDE_PATH DOH_TEST_COLON DOH_TEST_EQUALS
    _tf_cleanup_temp "$temp_dir"
}

test_battle_test_concurrent_environments() {
    # Battle test: Multiple processes with different environments
    local temp_dir1=$(_tf_create_temp_dir)
    local temp_dir2=$(_tf_create_temp_dir)
    
    # Create different .doh/env files
    mkdir -p "$temp_dir1/.doh" "$temp_dir2/.doh"
    
    echo "DOH_TEST_VAR=project1_value" > "$temp_dir1/.doh/env"
    echo "DOH_TEST_VAR=project2_value" > "$temp_dir2/.doh/env"
    
    # Test that existing environment variables win
    (
        export DOH_TEST_VAR="process1_override"
        _tf_with_mock "doh_project_dir" "echo $temp_dir1" dohenv_load
        _tf_assert_equals "Process 1 should preserve its environment" "process1_override" "$DOH_TEST_VAR"
    )
    
    (
        export DOH_TEST_VAR="process2_override"  
        _tf_with_mock "doh_project_dir" "echo $temp_dir2" dohenv_load
        _tf_assert_equals "Process 2 should preserve its environment" "process2_override" "$DOH_TEST_VAR"
    )
    
    # Cleanup
    _tf_cleanup_temp "$temp_dir1"
    _tf_cleanup_temp "$temp_dir2"
}

test_isolation_simulation() {
    # Simulate test isolation scenario
    local original_doh_global="${DOH_GLOBAL_DIR:-}"
    
    # Simulate test framework setting isolation
    export DOH_GLOBAL_DIR="$(mktemp -d)"
    export DOH_WORKSPACE_PROJECT_ID="test_project_123"
    
    # Load DOH environment (should not overwrite our isolation)
    dohenv_load 2>/dev/null || true
    
    _tf_assert_contains "DOH_GLOBAL_DIR should remain our test directory" "$DOH_GLOBAL_DIR" "/tmp"
    _tf_assert_equals "Test project ID should be preserved" "test_project_123" "$DOH_WORKSPACE_PROJECT_ID"
    
    # Verify isolation directory exists
    _tf_assert "Isolation directory should exist" test -d "$DOH_GLOBAL_DIR"
    
    # Cleanup test isolation
    rm -rf "$DOH_GLOBAL_DIR"
    unset DOH_WORKSPACE_PROJECT_ID
    
    # Restore original if it existed
    if [[ -n "$original_doh_global" ]]; then
        export DOH_GLOBAL_DIR="$original_doh_global"
    else
        unset DOH_GLOBAL_DIR
    fi
}

# Test suite entry point
_tf_test_suite_start "Environment Preservation Battle Tests"

# Run all environment preservation tests
test_environment_priority_hierarchy
test_existing_env_vars_preserved  
test_api_script_respects_environment
test_helper_script_respects_environment
test_multiple_dohenv_load_calls
test_special_characters_in_env_file
test_battle_test_concurrent_environments
test_isolation_simulation

_tf_test_suite_end
# Run tests if script executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi

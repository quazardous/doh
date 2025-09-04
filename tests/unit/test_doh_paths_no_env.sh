#!/bin/bash

# Test: DOH path functions without environment variables
# Verifies that doh_project_dir returns doh_project_root/.doh when no env vars are set
#
# USING LEGITIMATE api.sh calls to test DOH path resolution without environment variables.
# This test validates the fallback behavior of api.sh path functions.

source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"

_tf_setup() {
    # Save any existing DOH env vars
    _saved_DOH_PROJECT_DIR="${DOH_PROJECT_DIR:-}"
    _saved_DOH_GLOBAL_DIR="${DOH_GLOBAL_DIR:-}"
    _saved_DOH_TEST_CONTAINER_DIR="${DOH_TEST_CONTAINER_DIR:-}"
    
    # Unset all DOH environment variables
    unset DOH_PROJECT_DIR
    unset DOH_GLOBAL_DIR  
    unset DOH_TEST_CONTAINER_DIR
    
    return 0
}

_tf_teardown() {
    # Restore saved env vars
    if [[ -n "$_saved_DOH_PROJECT_DIR" ]]; then
        export DOH_PROJECT_DIR="$_saved_DOH_PROJECT_DIR"
    fi
    if [[ -n "$_saved_DOH_GLOBAL_DIR" ]]; then
        export DOH_GLOBAL_DIR="$_saved_DOH_GLOBAL_DIR"
    fi
    if [[ -n "$_saved_DOH_TEST_CONTAINER_DIR" ]]; then
        export DOH_TEST_CONTAINER_DIR="$_saved_DOH_TEST_CONTAINER_DIR"
    fi
    
    return 0
}

# Test that doh_project_dir = doh_project_root/.doh without env vars
test_doh_project_dir_equals_root_plus_doh() {
    # Get doh_project_root
    local project_root
    project_root=$(./.claude/scripts/doh/api.sh doh project_root 2>&1)
    local root_exit=$?
    
    # Get doh_project_dir
    local project_dir
    project_dir=$(./.claude/scripts/doh/api.sh doh project_dir 2>&1)
    local dir_exit=$?
    
    echo "DEBUG: doh_project_root() = '$project_root' (exit: $root_exit)"
    echo "DEBUG: doh_project_dir() = '$project_dir' (exit: $dir_exit)"
    echo "DEBUG: Expected doh_project_dir = '$project_root/.doh'"
    
    _tf_assert_equals "doh_project_root should succeed" "0" "$root_exit"
    _tf_assert_equals "doh_project_dir should succeed" "0" "$dir_exit"
    
    # Verify doh_project_dir = doh_project_root/.doh
    local expected_dir="$project_root/.doh"
    _tf_assert_equals "doh_project_dir should equal doh_project_root/.doh" "$expected_dir" "$project_dir"
}

# Test that DOH env vars are actually unset
test_doh_env_vars_unset() {
    _tf_assert_equals "DOH_PROJECT_DIR should be unset" "unset" "${DOH_PROJECT_DIR:-unset}"
    _tf_assert_equals "DOH_GLOBAL_DIR should be unset" "unset" "${DOH_GLOBAL_DIR:-unset}"
    _tf_assert_equals "DOH_TEST_CONTAINER_DIR should be unset" "unset" "${DOH_TEST_CONTAINER_DIR:-unset}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
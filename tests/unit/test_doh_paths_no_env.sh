#!/bin/bash

# Test: DOH path functions without environment variables
# Verifies that doh_project_dir returns doh_project_root/.doh when no env vars are set

source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"

_tf_setup() {
    # Save any existing DOH env vars
    _saved_DOH_PROJECT_DIR="${DOH_PROJECT_DIR:-}"
    _saved_DOH_GLOBAL_DIR="${DOH_GLOBAL_DIR:-}"
    _saved_DOH_TEST_CLEANUP_DIR="${DOH_TEST_CLEANUP_DIR:-}"
    
    # Unset all DOH environment variables
    unset DOH_PROJECT_DIR
    unset DOH_GLOBAL_DIR  
    unset DOH_TEST_CLEANUP_DIR
    
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
    if [[ -n "$_saved_DOH_TEST_CLEANUP_DIR" ]]; then
        export DOH_TEST_CLEANUP_DIR="$_saved_DOH_TEST_CLEANUP_DIR"
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
    
    _tf_assert_equals "$root_exit" "0" "doh_project_root should succeed"
    _tf_assert_equals "$dir_exit" "0" "doh_project_dir should succeed"
    
    # Verify doh_project_dir = doh_project_root/.doh
    local expected_dir="$project_root/.doh"
    _tf_assert_equals "$project_dir" "$expected_dir" "doh_project_dir should equal doh_project_root/.doh"
}

# Test that DOH env vars are actually unset
test_doh_env_vars_unset() {
    _tf_assert_equals "${DOH_PROJECT_DIR:-unset}" "unset" "DOH_PROJECT_DIR should be unset"
    _tf_assert_equals "${DOH_GLOBAL_DIR:-unset}" "unset" "DOH_GLOBAL_DIR should be unset"
    _tf_assert_equals "${DOH_TEST_CLEANUP_DIR:-unset}" "unset" "DOH_TEST_CLEANUP_DIR should be unset"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_run_tests
fi
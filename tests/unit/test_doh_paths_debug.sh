#!/bin/bash

# Quick debug test for DOH path functions
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/doh_fixtures.sh"

_tf_setup() {
    _tff_create_sample_doh_project "$DOH_PROJECT_DIR" >/dev/null
    return 0
}

_tf_teardown() {
    return 0
}

test_doh_paths() {
    echo "DEBUG: DOH_PROJECT_DIR = $DOH_PROJECT_DIR"
    
    local project_dir_result
    project_dir_result=$(./.claude/scripts/doh/api.sh doh project_dir 2>&1)
    echo "DEBUG: doh_project_dir() = '$project_dir_result'"
    
    local project_root_result  
    project_root_result=$(./.claude/scripts/doh/api.sh doh project_root 2>&1)
    echo "DEBUG: doh_project_root() = '$project_root_result'"
    
    echo "DEBUG: Expected project root (parent of DOH_PROJECT_DIR) = '$(dirname "$DOH_PROJECT_DIR")'"
    
    _tf_assert_true "true" "Debug paths completed"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_run_tests
fi
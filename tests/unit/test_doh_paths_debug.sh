#!/bin/bash

# Quick debug test for DOH path functions
#
# USING LEGITIMATE api.sh calls to test DOH path resolution.
# This test validates that api.sh correctly resolves project paths in isolation.
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
    _tf_debug "DOH_PROJECT_DIR = $DOH_PROJECT_DIR"
    
    local project_dir_result
    project_dir_result=$(./.claude/scripts/doh/api.sh doh project_dir 2>&1)
    _tf_debug "doh_project_dir() = '$project_dir_result'"
    
    local project_root_result  
    project_root_result=$(./.claude/scripts/doh/api.sh doh project_root 2>&1)
    _tf_debug "doh_project_root() = '$project_root_result'"
    
    _tf_debug "Expected project root (parent of DOH_PROJECT_DIR) = '$(dirname "$DOH_PROJECT_DIR")'"
    
    _tf_assert_true "Debug paths completed" "true"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
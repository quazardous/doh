#!/bin/bash

# Source test framework (required)
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"

# Add DOH library to test if it's the problem
source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/doh.sh"

test_minimal_doh_project_dir() {
    local doh_dir
    doh_dir=$(doh_project_dir)
    echo "DOH dir: $doh_dir"
    mkdir -p "$doh_dir"
    _tf_assert "DOH project dir should exist" test -d "$doh_dir"
}

# ==============================================================================
# REQUIRED: Prevent direct execution
# ==============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
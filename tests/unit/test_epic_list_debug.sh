#!/bin/bash

# Debug Test: Epic List Helper
# Debug why epic list is not finding existing epics

source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/doh_fixtures.sh"

_tf_setup() {
    # Create sample DOH project in test environment
    _tff_create_sample_doh_project "$DOH_PROJECT_DIR" >/dev/null
    
    # Create additional sample epics for more realistic testing
    mkdir -p "$DOH_PROJECT_DIR/epics/data-api-sanity"
    cat > "$DOH_PROJECT_DIR/epics/data-api-sanity/epic.md" << 'EOF'
---
name: data-api-sanity
number: 024
status: active
created: 2025-09-02T07:48:36Z
progress: 25%
file_version: 0.1.0
---
# Epic: data-api-sanity

Test epic for debugging epic list functionality.
EOF
    
    mkdir -p "$DOH_PROJECT_DIR/epics/test-driven-dev"
    cat > "$DOH_PROJECT_DIR/epics/test-driven-dev/epic.md" << 'EOF'
---
name: test-driven-dev
number: 014
status: completed
created: 2025-09-01T07:25:13Z
progress: 100%
file_version: 0.1.0
---
# Epic: test-driven-dev

Completed test epic for debugging.
EOF

    return 0
}

_tf_teardown() {
    return 0
}

# Test that test environment was set up correctly
test_test_environment_setup() {
    # Verify we created the test epics
    _tf_assert_file_exists "data-api-sanity epic should exist" "$DOH_PROJECT_DIR/epics/data-api-sanity/epic.md"
    _tf_assert_file_exists "test-driven-dev epic should exist" "$DOH_PROJECT_DIR/epics/test-driven-dev/epic.md"
}

# Test that epic helper can parse epic metadata
test_epic_metadata_parsing() {
    # Test that grep parsing works for our test epics
    local name status progress
    name=$(grep "^name:" "$DOH_PROJECT_DIR/epics/data-api-sanity/epic.md" | head -1 | sed 's/^name: *//')
    status=$(grep "^status:" "$DOH_PROJECT_DIR/epics/data-api-sanity/epic.md" | head -1 | sed 's/^status: *//')
    progress=$(grep "^progress:" "$DOH_PROJECT_DIR/epics/data-api-sanity/epic.md" | head -1 | sed 's/^progress: *//')
    
    _tf_assert_equals "Should parse epic name correctly" "data-api-sanity" "$name"
    _tf_assert_equals "Should parse epic status correctly" "active" "$status"  
    _tf_assert_equals "Should parse epic progress correctly" "25%" "$progress"
}

# Test that epic helper finds the correct number of epics
test_epic_count() {
    local epic_count
    epic_count=$(ls -d "$DOH_PROJECT_DIR/epics"/*/ 2>/dev/null | wc -l)
    
    _tf_assert_equals "Should find exactly 2 test epics (found $epic_count)" "2" "$epic_count"
}

# Test doh_project_dir function returns test environment .doh path
test_doh_project_dir_function() {
    local result
    result=$(./.claude/scripts/doh/api.sh doh project_dir 2>&1)
    local exit_code=$?
    
    _tf_assert_equals "doh_project_dir should work (output: $result)" "0" "$exit_code"
    
    # Verify it returns the DOH_PROJECT_DIR (which IS the .doh directory in test environment)
    _tf_assert_equals "doh_project_dir should return DOH_PROJECT_DIR (.doh directory path)" "$DOH_PROJECT_DIR" "$result"
}

# Test direct epic listing (in test environment)
test_direct_epic_listing() {
    _tf_debug "DOH_PROJECT_DIR: $DOH_PROJECT_DIR"
    _tf_debug "Contents of test epics directory:"
    if [[ "$_TF_VERBOSE" == "true" ]]; then
        ls -la "$DOH_PROJECT_DIR/epics/" | head -10
    fi
    
    _tf_debug "Epic directories found in test environment:"
    for dir in "$DOH_PROJECT_DIR/epics"/*/; do
        if [[ -d "$dir" ]]; then
            echo "  - $dir"
            if [[ -f "$dir/epic.md" ]]; then
                echo "    ✓ Has epic.md"
            else
                echo "    ✗ Missing epic.md"
            fi
        fi
    done
    
    _tf_assert_true "Direct listing completed" "true"
}

# Test what helper_epic_list actually does
test_helper_epic_list_debug() {
    _tf_debug "Testing helper_epic_list function in test environment..."
    
    # Check doh_project_dir output
    local doh_root
    doh_root=$(./.claude/scripts/doh/api.sh doh project_dir 2>&1)
    local exit_code=$?
    _tf_debug "doh_project_dir returned: '$doh_root' (exit code: $exit_code)"
    
    # Check if epics directory exists from helper perspective
    local epics_dir="$doh_root/.doh/epics"
    _tf_debug "Looking for epics in: $epics_dir"
    
    if [[ -d "$epics_dir" ]]; then
        _tf_debug "Epics directory exists"
        _tf_debug "Contents:"
        ls -la "$epics_dir" | head -10
    else
        _tf_debug "Epics directory does not exist at expected path"
    fi
    
    # Verify doh_project_dir returns DOH_PROJECT_DIR (.doh directory path)
    if [[ "$doh_root" == "$DOH_PROJECT_DIR" ]]; then
        _tf_debug "✓ doh_project_dir correctly returns DOH_PROJECT_DIR (.doh directory)"
    else
        _tf_debug "✗ doh_project_dir path mismatch:"
        _tf_debug "  Expected: $DOH_PROJECT_DIR"
        _tf_debug "  Got: $doh_root"
    fi
    
    _tf_assert_true "Debug completed" "true"
}

# Test helper call with debug
test_epic_list_helper_call() {
    _tf_debug "Calling ./.claude/scripts/doh/helper.sh epic list in test environment..."
    
    local result
    result=$(./.claude/scripts/doh/helper.sh epic list 2>&1)
    local exit_code=$?
    
    _tf_debug "Helper exit code: $exit_code"
    _tf_debug "Helper output:"
    echo "$result"
    
    _tf_assert_equals "Helper should execute without errors" "0" "$exit_code"
    
    # The helper should now find the test epics we created
    if echo "$result" | grep -q "No epics directory found"; then
        _tf_debug "✗ Helper still reports no epics directory - this indicates the issue persists"
        _tf_assert_true "Helper should find test epics, not report 'no epics directory'" "false"
    else
        _tf_debug "✓ Helper found epics (or produced different output)"
        _tf_assert_true "Helper produces output other than 'no epics directory'" "true"
    fi
}

# Main test execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
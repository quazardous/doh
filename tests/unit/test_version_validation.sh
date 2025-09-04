#!/bin/bash

# DOH Version Validation Test Suite
# Tests the version validation utilities and functions

# Load test framework
if [[ -n "${_TF_LAUNCHER_EXECUTION:-}" ]]; then
    # Running through test launcher from project root
    source "tests/helpers/test_framework.sh"
else
    # Running directly from test directory
    source "$(dirname "$0")/../helpers/test_framework.sh"
fi

# Load version management libraries
source ".claude/scripts/doh/lib/dohenv.sh"
source ".claude/scripts/doh/lib/version.sh"

# Export functions for use in test assertions
export -f version_validate version_compare version_increment _version_to_number
export -f version_get_current version_get_file version_set_file version_set_current
export -f version_find_files_without_file_version version_bump_file version_bump_current

_tf_setup() {
    # Create temporary test environment
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR"
    
    # Initialize basic DOH structure
    mkdir -p .doh .git
    echo "0.1.0" > VERSION
    
    cd - > /dev/null
}

_tf_teardown() {
    # Cleanup test directory
    if [[ -n "$TEST_DIR" && -d "$TEST_DIR" ]]; then
        rm -rf "$TEST_DIR"
    fi
}

test_version_validate_valid() {
    # Test valid semantic versions
    version_validate "0.0.1"
    _tf_assert_equals "0.0.1" 0 $?
    version_validate "1.0.0"  
    _tf_assert_equals "1.0.0" 0 $?
    version_validate "10.20.30"
    _tf_assert_equals "10.20.30" 0 $?
    version_validate "1.0.0-alpha"
    _tf_assert_equals "1.0.0-alpha" 0 $?
    version_validate "1.0.0-alpha.1"
    _tf_assert_equals "1.0.0-alpha.1" 0 $?
    version_validate "1.0.0+build"
    _tf_assert_equals "1.0.0+build" 0 $?
    version_validate "1.0.0-alpha+build"
    _tf_assert_equals "1.0.0-alpha+build" 0 $?
    version_validate "2.0.0-rc.1+exp.sha.5114f85"
    _tf_assert_equals "2.0.0-rc.1+exp.sha.5114f85" 0 $?
}

test_version_validate_invalid() {
    # Test invalid versions
    _tf_assert_not "Empty version" version_validate ""
    _tf_assert_not "Single number" version_validate "1"
    _tf_assert_not "Two numbers" version_validate "1.0"
    _tf_assert_not "Four numbers" version_validate "1.0.0.0"
    _tf_assert_not "Version with prefix" version_validate "v1.0.0"
    _tf_assert_not "Trailing dash" version_validate "1.0.0-"
    _tf_assert_not "Trailing plus" version_validate "1.0.0+"
    _tf_assert_not "Leading zero" version_validate "01.0.0"
    _tf_assert_not "Leading zero in minor" version_validate "1.00.0"
    _tf_assert_not "Leading zero in patch" version_validate "1.0.00"
    _tf_assert_not "Empty pre-release" version_validate "1.0.0-"
    _tf_assert_not "Empty build metadata" version_validate "1.0.0+"
    _tf_assert_not "Non-numeric versions" version_validate "a.b.c"
}

test_version_compare() {
    # Test version comparisons
    
    # Equal versions
    version_compare "1.0.0" "1.0.0"
    _tf_assert_equals "Equal versions should return 0" 0 $?
    
    # First version greater
    version_compare "2.0.0" "1.0.0"
    _tf_assert_equals "Greater major should return 1" 1 $?
    
    version_compare "1.1.0" "1.0.0"
    _tf_assert_equals "Greater minor should return 1" 1 $?
    
    version_compare "1.0.1" "1.0.0"
    _tf_assert_equals "Greater patch should return 1" 1 $?
    
    # First version lesser
    version_compare "1.0.0" "2.0.0"
    _tf_assert_equals "Lesser major should return 2" 2 $?
    
    version_compare "1.0.0" "1.1.0"
    _tf_assert_equals "Lesser minor should return 2" 2 $?
    
    version_compare "1.0.0" "1.0.1"
    _tf_assert_equals "Lesser patch should return 2" 2 $?
}

test_version_compare_prerelease() {
    # Pre-release versions
    version_compare "1.0.0-alpha" "1.0.0"
    _tf_assert_equals "Pre-release should be less than release" 2 $?
    
    version_compare "1.0.0" "1.0.0-alpha"
    _tf_assert_equals "Release should be greater than pre-release" 1 $?
    
    version_compare "1.0.0-alpha" "1.0.0-beta"
    _tf_assert_equals "Alpha should be less than beta" 2 $?
    
    version_compare "1.0.0-alpha.1" "1.0.0-alpha.2"
    _tf_assert_equals "Alpha.1 should be less than alpha.2" 2 $?
}

test_version_increment() {
    # Test version incrementing
    local result
    
    result=$(version_increment "0.1.0" "patch")
    _tf_assert_equals "Patch increment" "0.1.1" "$result"
    
    result=$(version_increment "0.1.5" "minor")
    _tf_assert_equals "Minor increment resets patch" "0.2.0" "$result"
    
    result=$(version_increment "1.5.3" "major")
    _tf_assert_equals "Major increment resets minor and patch" "2.0.0" "$result"
    
    result=$(version_increment "1.0.0-alpha" "patch")
    _tf_assert_equals "Patch increment removes pre-release" "1.0.1" "$result"
    
    result=$(version_increment "1.0.0+build" "patch")
    _tf_assert_equals "Patch increment removes build metadata" "1.0.1" "$result"
}

test_version_increment_invalid() {
    # Test invalid increment operations
    local result
    
    result=$(version_increment "invalid" "patch" 2>/dev/null)
    _tf_assert_equals "Invalid version should fail" 1 $?
    
    result=$(version_increment "1.0.0" "invalid" 2>/dev/null)
    _tf_assert_equals "Invalid increment type should fail" 1 $?
    
    result=$(version_increment "" "patch" 2>/dev/null)
    _tf_assert_equals "Empty version should fail" 1 $?
}

test_version_precedence() {
    # Test version precedence according to semver spec
    local versions=("1.0.0-alpha" "1.0.0-alpha.1" "1.0.0-alpha.beta" "1.0.0-beta" "1.0.0-beta.2" "1.0.0-beta.11" "1.0.0-rc.1" "1.0.0")
    
    for i in $(seq 0 $((${#versions[@]} - 2))); do
        local current="${versions[i]}"
        local next="${versions[i+1]}"
        
        version_compare "$current" "$next"
        _tf_assert_equals "$current should be less than $next" 2 $?
    done
}

# Run tests if script executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
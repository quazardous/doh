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
export -f version_get_current version_get_file version_set_file version_set_project
export -f version_find_missing_files version_bump_file version_bump_project

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
    _tf_assert_equals 0 $? "0.0.1"
    version_validate "1.0.0"  
    _tf_assert_equals 0 $? "1.0.0"
    version_validate "10.20.30"
    _tf_assert_equals 0 $? "10.20.30"
    version_validate "1.0.0-alpha"
    _tf_assert_equals 0 $? "1.0.0-alpha"
    version_validate "1.0.0-alpha.1"
    _tf_assert_equals 0 $? "1.0.0-alpha.1"
    version_validate "1.0.0+build"
    _tf_assert_equals 0 $? "1.0.0+build"
    version_validate "1.0.0-alpha+build"
    _tf_assert_equals 0 $? "1.0.0-alpha+build"
    version_validate "2.0.0-rc.1+exp.sha.5114f85"
    _tf_assert_equals 0 $? "2.0.0-rc.1+exp.sha.5114f85"
}

test_version_validate_invalid() {
    # Test invalid versions
    _tf_assert_command_fails version_validate "" "Empty version"
    _tf_assert_command_fails version_validate "1" "Single number"
    _tf_assert_command_fails version_validate "1.0" "Two numbers"
    _tf_assert_command_fails version_validate "1.0.0.0" "Four numbers"
    _tf_assert_command_fails version_validate "v1.0.0" "Version with prefix"
    _tf_assert_command_fails version_validate "1.0.0-" "Trailing dash"
    _tf_assert_command_fails version_validate "1.0.0+" "Trailing plus"
    _tf_assert_command_fails version_validate "01.0.0" "Leading zero"
    _tf_assert_command_fails version_validate "1.00.0" "Leading zero in minor"
    _tf_assert_command_fails version_validate "1.0.00" "Leading zero in patch"
    _tf_assert_command_fails version_validate "1.0.0-" "Empty pre-release"
    _tf_assert_command_fails version_validate "1.0.0+" "Empty build metadata"
    _tf_assert_command_fails version_validate "a.b.c" "Non-numeric versions"
}

test_version_compare() {
    # Test version comparisons
    
    # Equal versions
    version_compare "1.0.0" "1.0.0"
    _tf_assert_equals 0 $? "Equal versions should return 0"
    
    # First version greater
    version_compare "2.0.0" "1.0.0"
    _tf_assert_equals 1 $? "Greater major should return 1"
    
    version_compare "1.1.0" "1.0.0"
    _tf_assert_equals 1 $? "Greater minor should return 1"
    
    version_compare "1.0.1" "1.0.0"
    _tf_assert_equals 1 $? "Greater patch should return 1"
    
    # First version lesser
    version_compare "1.0.0" "2.0.0"
    _tf_assert_equals 2 $? "Lesser major should return 2"
    
    version_compare "1.0.0" "1.1.0"
    _tf_assert_equals 2 $? "Lesser minor should return 2"
    
    version_compare "1.0.0" "1.0.1"
    _tf_assert_equals 2 $? "Lesser patch should return 2"
}

test_version_compare_prerelease() {
    # Pre-release versions
    version_compare "1.0.0-alpha" "1.0.0"
    _tf_assert_equals 2 $? "Pre-release should be less than release"
    
    version_compare "1.0.0" "1.0.0-alpha"
    _tf_assert_equals 1 $? "Release should be greater than pre-release"
    
    version_compare "1.0.0-alpha" "1.0.0-beta"
    _tf_assert_equals 2 $? "Alpha should be less than beta"
    
    version_compare "1.0.0-alpha.1" "1.0.0-alpha.2"
    _tf_assert_equals 2 $? "Alpha.1 should be less than alpha.2"
}

test_version_increment() {
    # Test version incrementing
    local result
    
    result=$(version_increment "0.1.0" "patch")
    _tf_assert_equals "0.1.1" "$result" "Patch increment"
    
    result=$(version_increment "0.1.5" "minor")
    _tf_assert_equals "0.2.0" "$result" "Minor increment resets patch"
    
    result=$(version_increment "1.5.3" "major")
    _tf_assert_equals "2.0.0" "$result" "Major increment resets minor and patch"
    
    result=$(version_increment "1.0.0-alpha" "patch")
    _tf_assert_equals "1.0.1" "$result" "Patch increment removes pre-release"
    
    result=$(version_increment "1.0.0+build" "patch")
    _tf_assert_equals "1.0.1" "$result" "Patch increment removes build metadata"
}

test_version_increment_invalid() {
    # Test invalid increment operations
    local result
    
    result=$(version_increment "invalid" "patch" 2>/dev/null)
    _tf_assert_equals 1 $? "Invalid version should fail"
    
    result=$(version_increment "1.0.0" "invalid" 2>/dev/null)
    _tf_assert_equals 1 $? "Invalid increment type should fail"
    
    result=$(version_increment "" "patch" 2>/dev/null)
    _tf_assert_equals 1 $? "Empty version should fail"
}

test_version_precedence() {
    # Test version precedence according to semver spec
    local versions=("1.0.0-alpha" "1.0.0-alpha.1" "1.0.0-alpha.beta" "1.0.0-beta" "1.0.0-beta.2" "1.0.0-beta.11" "1.0.0-rc.1" "1.0.0")
    
    for i in $(seq 0 $((${#versions[@]} - 2))); do
        local current="${versions[i]}"
        local next="${versions[i+1]}"
        
        version_compare "$current" "$next"
        _tf_assert_equals 2 $? "$current should be less than $next"
    done
}

# Run all tests
_tf_run_tests
#!/bin/bash
# Simplified test framework validation
# Tests core assertion functions step by step
# File version: 0.1.0 | Created: 2025-09-03

# Source the framework
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"

test_basic_equality() {
    _tf_assert_equals "Basic string equality should work" "hello" "hello"
}

test_basic_inequality() {
    _tf_assert_not_equals "Different strings should not be equal" "hello" "world"
}

test_basic_boolean() {
    _tf_assert_true "True should be true" true
    _tf_assert_false "False should be false" false
}

test_basic_contains() {
    local text="The quick brown fox"
    _tf_assert_contains "Should find word in text" "$text" "quick"
}

test_basic_commands() {
    _tf_assert "Echo command should succeed" echo "test"
    _tf_assert_not "False command should fail" false
}

# Run tests if script executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
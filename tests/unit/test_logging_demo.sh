#!/bin/bash
# Demo test showing logging functions in the DOH test framework
# File version: 0.1.0 | Created: 2025-09-01

# Source the framework
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"

test_logging_functions() {
    # Test that logging functions are available and work
    _tf_log_info "This is an info message - always shown unless QUIET=true"
    _tf_log_success "This is a success message - always shown unless QUIET=true"
    _tf_log_warn "This is a warning message - always shown unless QUIET=true"
    _tf_log_error "This is an error message - always shown (goes to stderr)"
    _tf_log_debug "This is a debug message - only shown when VERBOSE=true"
    _tf_log_trace "This is a trace message - only shown when DOH_TEST_DEBUG=true"
    
    # Test that functions exist and are callable
    _tf_assert_command_succeeds "declare -f _tf_log_info" "log_info function should exist"
    _tf_assert_command_succeeds "declare -f _tf_log_error" "log_error function should exist"
    _tf_assert_command_succeeds "declare -f _tf_log_debug" "log_debug function should exist"
    _tf_assert_command_succeeds "declare -f _tf_log_trace" "log_trace function should exist"
}

test_verbose_behavior() {
    _tf_log_debug "This debug message will only appear in verbose mode"
    _tf_assert_true "true" "Verbose logging test completed"
}

test_trace_behavior() {
    _tf_log_trace "This trace message will only appear with DOH_TEST_DEBUG=true"
    _tf_assert_true "true" "Trace logging test completed"
}

# Run the test if script executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
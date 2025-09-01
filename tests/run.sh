#!/bin/bash
# DOH Test Runner
# Main test runner for the DOH project test suite
# File version: 0.1.0
# Created: 2025-09-01

set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source internal library functions
source "$SCRIPT_DIR/lib/tf.sh"

# Default settings
VERBOSE=false
QUIET=false
PARALLEL=false
SUITE=""
PATTERN=""
COVERAGE=false
DRY_RUN=false

# Colors
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' NC=''
fi

# Colors for output (used by logging functions)

# Usage information
usage() {
    cat << EOF
DOH Test Runner

Usage: $0 [OPTIONS] [TEST_PATH...]

Options:
    -h, --help          Show this help message
    -v, --verbose       Verbose output
    -q, --quiet         Quiet output (errors only)
    -p, --parallel      Run tests in parallel
    -s, --suite SUITE   Run specific test suite (unit|integration)
    -t, --pattern PAT   Run tests matching pattern
    -c, --coverage      Generate coverage report (if available)
    -n, --dry-run       Show what would be run without executing
    --list             List available test files
    --version          Show version information

Examples:
    $0                                  # Run all tests
    $0 --suite unit                     # Run only unit tests
    $0 --pattern "test_framework"       # Run tests matching pattern
    $0 tests/unit/test_specific.sh      # Run specific test file
    $0 --parallel --verbose             # Run all tests in parallel with verbose output

Test Organization:
    tests/unit/         Unit tests for individual functions
    tests/integration/  Integration tests for workflows
    tests/fixtures/     Test data and mock files
    tests/helpers/      Shared test utilities

EOF
}

# Parse command line arguments
parse_args() {
    REMAINING_ARGS=()
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -q|--quiet)
                QUIET=true
                shift
                ;;
            -p|--parallel)
                PARALLEL=true
                shift
                ;;
            -s|--suite)
                SUITE="$2"
                shift 2
                ;;
            -t|--pattern)
                PATTERN="$2"
                shift 2
                ;;
            -c|--coverage)
                COVERAGE=true
                shift
                ;;
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            --list)
                _tf_list_tests
                exit 0
                ;;
            --version)
                echo "DOH Test Runner v0.1.0"
                exit 0
                ;;
            -*)
                _tf_log_error "Unknown option: $1"
                usage
                exit 1
                ;;
            *)
                # Remaining arguments are test files
                REMAINING_ARGS+=("$@")
                break
                ;;
        esac
    done
    
    # Validate suite option
    if ! _tf_validate_suite "$SUITE"; then
        exit 1
    fi
}

# All test execution functions are now in the library (lib/tf.sh)

# Main execution
main() {
    local start_time=$(date +%s)
    
    # Parse arguments
    parse_args "$@"
    
    # Show configuration if verbose
    if [[ "$VERBOSE" == "true" ]]; then
        _tf_log_info "Configuration:"
        _tf_log_info "  Suite: ${SUITE:-all}"
        _tf_log_info "  Pattern: ${PATTERN:-none}"
        _tf_log_info "  Parallel: $PARALLEL"
        _tf_log_info "  Verbose: $VERBOSE"
        _tf_log_info "  Dry run: $DRY_RUN"
        echo
    fi
    
    # Find test files
    local test_files
    mapfile -t test_files < <(_tf_find_test_files "${REMAINING_ARGS[@]}")
    
    if [[ ${#test_files[@]} -eq 0 ]]; then
        _tf_log_error "No test files found"
        exit 1
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        _tf_log_info "Dry run - would execute ${#test_files[@]} test files:"
        for file in "${test_files[@]}"; do
            echo "  ${file#$SCRIPT_DIR/}"
        done
        exit 0
    fi
    
    # Validate test framework exists
    if [[ ! -f "$SCRIPT_DIR/helpers/test_framework.sh" ]]; then
        _tf_log_error "Test framework not found: $SCRIPT_DIR/helpers/test_framework.sh"
        _tf_log_error "Run task 016 to create the test framework first"
        exit 1
    fi
    
    # Run tests
    local failed=0
    if [[ "$PARALLEL" == "true" && ${#test_files[@]} -gt 1 ]]; then
        _tf_run_tests_parallel "${test_files[@]}" || failed=$?
    else
        _tf_run_tests_sequential "${test_files[@]}" || failed=$?
    fi
    
    # Summary
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    local passed=$((${#test_files[@]} - failed))
    
    _tf_print_summary "${#test_files[@]}" "$passed" "$failed" "$duration"
    exit $?
}

# Run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
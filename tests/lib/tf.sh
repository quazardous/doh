#!/bin/bash
# DOH Test Framework Internal Library
# Internal functions for run.sh and test_launcher.sh
# File version: 0.1.0 | Created: 2025-09-01
# NOT TO BE SOURCED BY TESTS THEMSELVES

# Test file discovery and filtering
_tf_find_test_files() {
    local search_dirs=()
    local test_files=()
    
    # If specific files provided, use those
    if [[ $# -gt 0 ]]; then
        for file in "$@"; do
            if [[ -f "$file" ]]; then
                test_files+=("$file")
            else
                echo "Warning: Test file not found: $file" >&2
            fi
        done
    else
        # Determine search directories based on suite
        if [[ -n "${SUITE:-}" ]]; then
            search_dirs=("$SCRIPT_DIR/$SUITE")
        else
            search_dirs=("$SCRIPT_DIR/unit" "$SCRIPT_DIR/integration")
        fi
        
        # Find test files
        for dir in "${search_dirs[@]}"; do
            if [[ -d "$dir" ]]; then
                while IFS= read -r -d '' file; do
                    test_files+=("$file")
                done < <(find "$dir" -name "test_*.sh" -type f -print0 2>/dev/null)
            fi
        done
    fi
    
    # Apply pattern filter
    if [[ -n "${PATTERN:-}" ]]; then
        local filtered_files=()
        for file in "${test_files[@]}"; do
            if [[ "$file" =~ $PATTERN ]]; then
                filtered_files+=("$file")
            fi
        done
        test_files=("${filtered_files[@]}")
    fi
    
    printf '%s\n' "${test_files[@]}"
}

# Test execution management
_tf_run_single_test() {
    local test_file="$1"
    local relative_path="${test_file#$SCRIPT_DIR/}"
    
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo "Would run: $relative_path"
        return 0
    fi
    
    _tf_log_info "Running: $relative_path"
    
    # Run the test using the launcher
    local start_time=$(date +%s)
    local result=0
    
    if [[ "${VERBOSE:-false}" == "true" ]]; then
        VERBOSE=true "$SCRIPT_DIR/test_launcher.sh" "$test_file" || result=$?
    else
        # Capture only the final summary line for minimal output
        local output
        output=$(VERBOSE=false "$SCRIPT_DIR/test_launcher.sh" "$test_file" 2>/dev/null) || result=$?
        # Extract just the final test result line
        echo "$output" | tail -1
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    if [[ $result -eq 0 ]]; then
        _tf_log_success "$relative_path completed in ${duration}s"
    else
        _tf_log_error "$relative_path failed in ${duration}s"
    fi
    
    return $result
}

# Parallel test execution
_tf_run_tests_parallel() {
    local test_files=("$@")
    local pids=()
    local temp_dir=$(mktemp -d)
    
    _tf_log_info "Running ${#test_files[@]} tests in parallel"
    
    # Start all tests
    for i in "${!test_files[@]}"; do
        local test_file="${test_files[$i]}"
        local result_file="$temp_dir/result_$i"
        
        (
            if _tf_run_single_test "$test_file"; then
                echo "0" > "$result_file"
            else
                echo "1" > "$result_file"
            fi
        ) &
        
        pids+=($!)
    done
    
    # Wait for all tests to complete
    for pid in "${pids[@]}"; do
        wait "$pid"
    done
    
    # Collect results
    local failed=0
    for i in "${!test_files[@]}"; do
        local result_file="$temp_dir/result_$i"
        if [[ -f "$result_file" ]]; then
            local result=$(cat "$result_file")
            if [[ $result -ne 0 ]]; then
                ((failed++))
            fi
        else
            ((failed++))
        fi
    done
    
    # Cleanup
    rm -rf "$temp_dir"
    
    return $failed
}

# Sequential test execution
_tf_run_tests_sequential() {
    local test_files=("$@")
    local failed=0
    
    _tf_log_info "Running ${#test_files[@]} tests sequentially"
    
    for test_file in "${test_files[@]}"; do
        if ! _tf_run_single_test "$test_file"; then
            ((failed++))
        fi
    done
    
    return $failed
}

# Logging functions
_tf_log_info() {
    if [[ "${QUIET:-false}" != "true" && "${VERBOSE:-false}" == "true" ]]; then
        echo -e "${BLUE:-}[INFO]${NC:-} $*"
    fi
}

_tf_log_success() {
    if [[ "${QUIET:-false}" != "true" && "${VERBOSE:-false}" == "true" ]]; then
        echo -e "${GREEN:-}[SUCCESS]${NC:-} $*"
    fi
}

_tf_log_error() {
    echo -e "${RED:-}[ERROR]${NC:-} $*" >&2
}

_tf_log_warn() {
    if [[ "${QUIET:-false}" != "true" ]]; then
        echo -e "${YELLOW:-}[WARN]${NC:-} $*"
    fi
}

# Test listing
_tf_list_tests() {
    local test_files
    mapfile -t test_files < <(_tf_find_test_files)
    
    echo "Available test files:"
    for file in "${test_files[@]}"; do
        local relative_path="${file#$SCRIPT_DIR/}"
        echo "  $relative_path"
    done
    
    echo
    echo "Test suites:"
    echo "  unit         - Unit tests ($(find "$SCRIPT_DIR/unit" -name "test_*.sh" 2>/dev/null | wc -l) files)"
    echo "  integration  - Integration tests ($(find "$SCRIPT_DIR/integration" -name "test_*.sh" 2>/dev/null | wc -l) files)"
}

# Configuration validation
_tf_validate_suite() {
    local suite="$1"
    if [[ -n "$suite" && "$suite" != "unit" && "$suite" != "integration" ]]; then
        _tf_log_error "Invalid suite: $suite (must be 'unit' or 'integration')"
        return 1
    fi
    return 0
}

# Test summary reporting
_tf_print_summary() {
    local total="$1"
    local passed="$2"
    local failed="$3"
    local duration="$4"
    
    if [[ "${VERBOSE:-false}" == "true" ]]; then
        echo
        _tf_log_info "Test Summary:"
        _tf_log_info "  Total: $total"
        _tf_log_info "  Passed: $passed"
        _tf_log_info "  Failed: $failed"
        _tf_log_info "  Duration: ${duration}s"
        
        if [[ $failed -eq 0 ]]; then
            _tf_log_success "All tests passed!"
        else
            _tf_log_error "$failed test(s) failed"
        fi
    else
        # Compact summary for non-verbose mode
        if [[ $failed -eq 0 ]]; then
            echo "✅ $passed/$total tests passed (${duration}s)"
        else
            echo "❌ $passed/$total tests passed, $failed failed (${duration}s)"
        fi
    fi
    
    return $failed
}

# Framework help (moved from test_framework.sh to avoid being picked up as a test)
_tf_show_framework_help() {
    cat << 'EOF'
DOH Test Framework Usage:

Basic test structure:
    test_my_function() {
        # Arrange
        local input="test_value"
        
        # Act
        local result=$(my_function "$input")
        
        # Assert
        _tf_assert_equals "$result" "Function should return expected value" "expected"
    }

Available assertions:
    _tf_assert_equals <message> <expected> <actual>
    _tf_assert_not_equals <message> <expected> <actual>
    _tf_assert_true <message> <condition>
    _tf_assert_false <message> <condition>
    _tf_assert_contains <message> <haystack> <needle>
    _tf_assert_file_exists <message> <file>
    _tf_assert_file_contains <message> <file> <content>
    _tf_assert <message> <command> [args...]
    _tf_assert_not <message> <command> [args...]

Test lifecycle:
    setup()      - Called before each test
    teardown()   - Called after each test

Utilities:
    _tf_create_temp_dir      - Create temporary directory
    _tf_create_temp_file     - Create temporary file
    _tf_cleanup_temp <path>  - Clean up temporary files
    _tf_with_mock <func> <mock> <command> - Run command with mocked function

Running tests:
    source tests/helpers/test_framework.sh
    _tf_run_test_file <test_file>
    
    Or use the test runner: ./tests/run.sh
EOF
}

# Export functions if sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    export -f _tf_find_test_files _tf_run_single_test
    export -f _tf_run_tests_parallel _tf_run_tests_sequential
    export -f _tf_log_info _tf_log_success _tf_log_error _tf_log_warn
    export -f _tf_list_tests _tf_validate_suite _tf_print_summary
    export -f _tf_show_framework_help
fi
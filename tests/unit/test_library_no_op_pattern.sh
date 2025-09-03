#!/bin/bash

# Test: Library No-Op Pattern Compliance (Task 025)
# Verifies all DOH libraries follow no-op pattern and have correct dependencies

source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"

_tf_setup() {
    # Create test workspace
    TEST_LIB_DIR="$(pwd)/.claude/scripts/doh/lib"
    
    # Verify we're in DOH project root
    if [[ ! -d "$TEST_LIB_DIR" ]]; then
        echo "SETUP ERROR: DOH library directory not found: $TEST_LIB_DIR" >&2
        return 1
    fi
}

_tf_teardown() {
    unset TEST_LIB_DIR
}

# Test that all libraries can be sourced without automatic execution
test_libraries_are_no_op() {
    local lib_count=0
    local failed_libs=()
    
    for lib_file in "$TEST_LIB_DIR"/*.sh; do
        local lib_name=$(basename "$lib_file")
        lib_count=$((lib_count + 1))
        
        # Source library in subshell to capture any output
        local output
        if output=$(bash -c "source '$lib_file' 2>&1"); then
            if [[ -n "$output" ]]; then
                failed_libs+=("$lib_name:output")
            fi
        else
            failed_libs+=("$lib_name:failed")
        fi
    done
    
    _tf_assert_equals "All $lib_count libraries should be no-op when sourced. Failed: ${failed_libs[*]}" "0" "${#failed_libs[@]}"
}

# Test that all libraries have proper source guards
test_libraries_have_source_guards() {
    local missing_guards=()
    
    for lib_file in "$TEST_LIB_DIR"/*.sh; do
        local lib_name=$(basename "$lib_file")
        
        # Check for guard pattern: [[ -n "${DOH_LIB_*_LOADED:-}" ]] && return 0
        if ! grep -q '\[\[ -n "${DOH_LIB_.*_LOADED:-}" \]\] && return 0' "$lib_file"; then
            missing_guards+=("$lib_name")
        fi
    done
    
    _tf_assert_equals "All libraries should have source guards. Missing: ${missing_guards[*]}" "0" "${#missing_guards[@]}"
}

# Test core library doh.sh has no dependencies
test_doh_core_has_no_dependencies() {
    local doh_lib="$TEST_LIB_DIR/doh.sh"
    
    _tf_assert_file_exists "doh.sh should exist" "$doh_lib"
    
    # Check that doh.sh doesn't source any other DOH libraries
    local source_lines
    source_lines=$(grep "^source.*\.sh" "$doh_lib" 2>/dev/null | wc -l)
    
    _tf_assert_equals "doh.sh should have zero dependencies (foundational library)" "0" "$source_lines"
}

# Test that dohenv.sh properly sources doh.sh
test_dohenv_sources_doh() {
    local dohenv_lib="$TEST_LIB_DIR/dohenv.sh"
    
    _tf_assert_file_exists "dohenv.sh should exist" "$dohenv_lib"
    _tf_assert_file_contains "dohenv.sh should source doh.sh" "$dohenv_lib" 'source.*doh\.sh'
}

# Test that libraries only source dependencies they actually use
test_libraries_have_minimal_dependencies() {
    # queue.sh should source doh.sh (uses doh_global_dir)
    _tf_assert_file_contains "queue.sh should source doh.sh (uses doh_global_dir)" "$TEST_LIB_DIR/queue.sh" 'source.*doh\.sh'
    
    # frontmatter.sh should have minimal dependencies (standalone)
    local fm_deps
    fm_deps=$(grep "^source.*\.sh" "$TEST_LIB_DIR/frontmatter.sh" 2>/dev/null | wc -l)
    _tf_assert_equals "frontmatter.sh should be standalone (zero dependencies)" "0" "$fm_deps"
}

# Test that all libraries can be sourced in isolation  
test_libraries_can_source_independently() {
    local failed_libs=()
    
    for lib_file in "$TEST_LIB_DIR"/*.sh; do
        local lib_name=$(basename "$lib_file")
        
        # Source library in clean subshell
        if ! bash -c "source '$lib_file' >/dev/null 2>&1"; then
            failed_libs+=("$lib_name")
        fi
    done
    
    _tf_assert_equals "All libraries should source independently. Failed: ${failed_libs[*]}" "0" "${#failed_libs[@]}"
}

# Test core functions work after sourcing doh.sh
test_doh_core_functions_work() {
    # Source doh.sh and test core functions
    local test_result
    test_result=$(bash -c "
        source '$TEST_LIB_DIR/doh.sh' >/dev/null 2>&1 || exit 1
        
        # Test doh_project_root 
        root=\$(doh_project_root) || exit 1
        [[ -n \"\$root\" ]] || exit 1
        
        # Test doh_project_dir
        dir=\$(doh_project_dir) || exit 1
        [[ -n \"\$dir\" ]] || exit 1
        
        # Test doh_global_dir
        global=\$(doh_global_dir) || exit 1
        [[ -n \"\$global\" ]] || exit 1
        
        echo 'success'
    " 2>/dev/null)
    
    _tf_assert_equals "doh.sh core functions should work correctly" "success" "$test_result"
}

# Main test execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
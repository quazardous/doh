#!/bin/bash
# Best Patterns Test Template
# Demonstrates recommended patterns for DOH test framework
# Shows proper library sourcing, command testing, and test organization
#
# This template combines the simplicity of test_simple.sh with
# comprehensive examples from test_example.sh, emphasizing current best practices.
#
# KEY PRINCIPLES:
# 1. Source DOH libraries directly (never use api.sh/helper.sh in tests)
# 2. Use _tf_assert/_tf_assert_not for command testing
# 3. Create temp files in container's tmp directory only
# 4. Use DOH library functions instead of environment variables
# 5. Test behavior, not implementation details

# ==============================================================================
# FRAMEWORK AND LIBRARY SOURCING (MANDATORY)
# ==============================================================================

# Source test framework (required)
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"

# Source DOH fixtures helper for test project setup
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/doh_fixtures.sh"

# CRITICAL: Source DOH libraries directly (10x faster than api.sh/helper.sh)
# Add the libraries your tests need - these are just examples
source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/doh.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/version.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/frontmatter.sh"
# Note: task.sh may not exist in all projects - uncomment if available
# source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/task.sh"

# ==============================================================================
# SETUP AND TEARDOWN (Optional but recommended)
# ==============================================================================

_tf_setup() {
    # Tests can create isolated DOH project for testing
    # This provides a clean DOH structure for each test file
    # BEST PRACTICE: Use fixture helpers for complex setups
    # Tests setup is not mandatory, tests can be self-contained and not file focused
    _tff_create_minimal_doh_project >/dev/null
    
    # Create test data in DOH structure
    # BEST PRACTICE: Create test data here, but use local variables in tests
    # NEVER use file without specific path, it will create artifacts in project root!
    local doh_dir=$(doh_project_dir)
    mkdir -p "$doh_dir/epics/test-epic"
    cat > "$doh_dir/epics/test-epic/001.md" <<'EOF'
---
task_number: "001"
name: Test Task
status: completed
---
# Test Task
EOF
}

_tf_teardown() {
    # IMPORTANT: NO manual cleanup needed when using container's tmp directory!
    # The test launcher automatically cleans up the entire container after tests.
    # Manual cleanup can interfere with debugging - leave files for inspection.
    
    # No global variables to unset - each test uses local variables
    # This is the best practice for test isolation
    :  # No-op - just comments explaining why we don't clean up
}

# ==============================================================================
# COMMAND TESTING PATTERNS (PREFERRED)
# ==============================================================================

# IMPORTANT: Each test should be self-contained with local variables
# Avoid global variables - they create hidden dependencies between tests
# and make tests harder to understand and maintain

test_command_best_practices() {
    # BEST PRACTICE: Test DOH functions directly after sourcing libraries
    # This is 10x faster than using api.sh or helper.sh
    _tf_assert "Version should validate" version_validate "1.2.3"
    _tf_assert_not "Should reject invalid version" version_validate "not-a-version"
    
    # Test with specific arguments
    _tf_assert "Should increment patch version" version_increment "1.0.0" "patch"
    _tf_assert_not "Should reject invalid increment type" version_increment "1.0.0" "invalid"
    
    # Test task functions with test data (if task.sh is available)
    # local task_file="$TEST_DOH_DIR/epics/test-epic/001.md"
    # _tf_assert "Should detect completed task" task_is_completed "$task_file"
    
    # Test file operations
    # BEST PRACTICE: Use local variables in each test
    local tmp_base=$(_tf_test_container_tmpdir)
    local test_file="$tmp_base/test_file.txt"
    _tf_assert "Should create file" touch "$test_file"
    _tf_assert "File should exist" test -f "$test_file"
    _tf_assert_not "Should fail on missing file" cat "/nonexistent/file"
}

test_exit_code_patterns() {
    # PREFERRED: Direct command testing with _tf_assert/_tf_assert_not
    # These functions test the command directly, no need for $?
    _tf_assert "Command should succeed" echo "test"
    _tf_assert_not "Command should fail" false
    
    # EXCEPTION: Only capture exit codes when testing specific non-zero values
    # Most of the time you should use _tf_assert_not instead
    version_validate "invalid" 2>/dev/null
    local exit_code=$?
    _tf_assert_equals "Should return 1 for invalid version" 1 $exit_code
    
    # When you need both output and exit code
    local output=$(version_get_current 2>&1)
    local status=$?
    _tf_assert_equals "Should succeed" 0 $status
    _tf_assert_contains "Should contain version" "$output" "."
}

# ==============================================================================
# VALUE TESTING PATTERNS
# ==============================================================================

test_value_assertions() {
    # Test function output values
    local current_version=$(version_get_current)
    _tf_assert_not_equals "Version should not be empty" "" "$current_version"
    
    # Test frontmatter operations (demonstrates reading test data)
    # BEST PRACTICE: Use doh_project_dir() directly in each test
    local doh_dir=$(doh_project_dir)
    local test_file="$doh_dir/epics/test-epic/001.md"
    local status=$(frontmatter_get_field "$test_file" "status")
    _tf_assert_equals "Status should be completed" "completed" "$status"
    
    # String contains assertions
    _tf_assert_contains "Version should have dots" "$current_version" "."
    
    # Boolean assertions
    local is_valid="true"
    _tf_assert_true "Should be true" "$is_valid"
    _tf_assert_false "Should be false" "false"
}

# ==============================================================================
# FILE AND TEMP DIRECTORY PATTERNS
# ==============================================================================

# Example of self-contained test with all local variables
test_self_contained_example() {
    # BEST PRACTICE: Each test declares its own local variables
    # No dependency on global state or other tests
    
    # Get paths when needed
    local tmp_base=$(_tf_test_container_tmpdir)
    local doh_dir=$(doh_project_dir)
    
    # Create test-specific files
    local my_test_file="$tmp_base/my_test_${RANDOM}.txt"
    echo "test data" > "$my_test_file"
    
    # Run assertions
    _tf_assert_file_exists "Test file should exist" "$my_test_file"
    _tf_assert_file_contains "Should have test data" "$my_test_file" "test data"
    
    # Create DOH structure file
    local epic_file="$doh_dir/epics/test-epic/002.md"
    mkdir -p "$(dirname "$epic_file")"
    echo "# Epic 002" > "$epic_file"
    
    _tf_assert_file_exists "Epic file should exist" "$epic_file"
    
    # All variables are local - no cleanup needed, no global pollution
}

test_file_operations() {
    # BEST PRACTICE: Always use container's tmp directory for isolation
    # The _tf_test_container_tmpdir() function returns the isolated tmp dir
    local tmp_base=$(_tf_test_container_tmpdir)
    local test_file="$tmp_base/test_${RANDOM}.txt"
    
    # Create and test file operations
    echo "content" > "$test_file"
    _tf_assert_file_exists "File should exist" "$test_file"
    _tf_assert_file_contains "File should contain content" "$test_file" "content"
    
    # ANTI-PATTERN: Never use system /tmp directly - breaks isolation!
    # local bad_file="/tmp/test.txt"  # DON'T DO THIS
    
    # Use DOH project structure
    # BEST PRACTICE: Call doh_project_dir() when you need the path
    local doh_dir=$(doh_project_dir)
    local epic_file="$doh_dir/epics/new-epic/epic.md"
    mkdir -p "$(dirname "$epic_file")"
    cat > "$epic_file" <<'EOF'
---
name: New Epic
status: pending
---
# New Epic
EOF
    
    _tf_assert_file_exists "Epic file should exist" "$epic_file"
    _tf_assert_file_contains "Should have frontmatter" "$epic_file" "name: New Epic"
}

test_temp_utilities() {
    # Use framework temp functions (automatically in container's tmp)
    local temp_dir=$(_tf_create_temp_dir)
    local temp_file=$(_tf_create_temp_file ".json")
    
    # Verify creation
    _tf_assert "Temp dir should exist" test -d "$temp_dir"
    _tf_assert_file_exists "Temp file should exist" "$temp_file"
    
    # Use temp files
    echo '{"test": true}' > "$temp_file"
    _tf_assert_file_contains "JSON file should contain data" "$temp_file" '"test": true'
    
    # Create file in temp dir
    echo "data" > "$temp_dir/output.txt"
    _tf_assert_file_exists "File in temp dir should exist" "$temp_dir/output.txt"
    
    # NO CLEANUP needed - files remain for debugging, container handles cleanup
}

# ==============================================================================
# DOH-SPECIFIC PATTERNS
# ==============================================================================

test_doh_library_usage() {
    # Direct library function calls after sourcing
    # This tests the actual implementation, not wrapper scripts
    # Using API function ensures that no real/productive files are modified
    version_set_current "2.0.0"
    local new_version=$(version_get_current)
    _tf_assert_equals "Version should be updated" "2.0.0" "$new_version"
    
    # Test with DOH project structure
    # BEST PRACTICE: Get DOH directory when needed, not stored globally
    local doh_dir=$(doh_project_dir)
    local prd_file="$doh_dir/prds/test.md"
    mkdir -p "$(dirname "$prd_file")"
    cat > "$prd_file" <<'EOF'
---
name: test-prd
status: backlog
description: Test PRD
---
# Test PRD
EOF
    
    # Test frontmatter functions
    local prd_name=$(frontmatter_get_field "$prd_file" "name")
    _tf_assert_equals "PRD name should match" "test-prd" "$prd_name"
    
    # Update frontmatter
    frontmatter_update_field "$prd_file" "status" "in-progress"
    local new_status=$(frontmatter_get_field "$prd_file" "status")
    _tf_assert_equals "Status should be updated" "in-progress" "$new_status"
}

test_workspace_patterns() {
    # Use DOH fixture helpers for complex setups
    _tff_create_helper_test_project >/dev/null
    _tff_setup_workspace_for_helpers
    
    # Now test with the prepared workspace
    local doh_dir=$(doh_project_dir)
    _tf_assert "DOH directory should exist" test -d "$doh_dir"
    
    # Test workspace has expected structure
    _tf_assert "Should have epics directory" test -d "$doh_dir/epics"
    _tf_assert "Should have prds directory" test -d "$doh_dir/prds"
}

# ==============================================================================
# ANTI-PATTERNS TO AVOID
# ==============================================================================

test_what_not_to_do() {
    # ANTI-PATTERN 1: Using api.sh or helper.sh in tests
    # This is 10x slower and tests the wrapper, not the function
    # _tf_assert "SLOW!" ./.claude/scripts/doh/api.sh version validate "1.0.0"
    
    # ANTI-PATTERN 2: Creating files without full paths
    # This creates files in unpredictable locations!
    # echo "data" > "output.txt"  # WHERE DOES THIS GO?
    
    # ANTI-PATTERN 3: Using system /tmp directly
    # This breaks test isolation and can conflict with other tests
    # local file="/tmp/test.txt"  # NO ISOLATION!
    
    # ANTI-PATTERN 4: Testing exit codes when _tf_assert would work
    # Use _tf_assert for success/failure, not manual exit code checks
    # version_validate "1.0.0"
    # _tf_assert_equals "Bad pattern" 0 $?  # Just use: _tf_assert "msg" version_validate "1.0.0"
    
    # ANTI-PATTERN 5: Accessing environment variables directly
    # Always use DOH library functions for paths
    # echo "$DOH_PROJECT_DIR"  # Use doh_project_dir() instead!
    
    # This test just demonstrates what NOT to do
    _tf_assert_true "Anti-patterns documented" "true"
}

# ==============================================================================
# ADVANCED PATTERNS
# ==============================================================================

test_complex_scenarios() {
    # Testing with pipes - use bash -c for complex command chains
    local data="line1\nline2\nline3"
    _tf_assert "Should find pattern" bash -c "echo -e '$data' | grep -q 'line2'"
    _tf_assert_not "Should not find missing" bash -c "echo -e '$data' | grep -q 'line4'"
    
    # Testing with subshells
    _tf_assert "Subshell should work" bash -c "cd /tmp && pwd | grep -q '/tmp'"
    
    # Testing error conditions
    test_function_with_error() {
        [[ "$1" == "fail" ]] && return 1
        return 0
    }
    
    _tf_assert "Should succeed with good input" test_function_with_error "pass"
    _tf_assert_not "Should fail with bad input" test_function_with_error "fail"
}

test_performance_considerations() {
    # PERFORMANCE TIP: Direct library function calls are ~10x faster
    # This is why we always source libraries instead of using wrappers
    local start_time=$SECONDS
    for i in {1..10}; do
        version_validate "1.0.$i" >/dev/null 2>&1
    done
    local direct_time=$((SECONDS - start_time))
    
    # COMPARISON: api.sh would spawn subprocesses for each call
    # This is why we avoid it in tests:
    # - Each call spawns a new bash process
    # - Each process sources all libraries again
    # - 10x slower for no benefit in tests
    
    # Direct calls should complete almost instantly
    _tf_assert "Direct calls should be fast" test $direct_time -le 1
}

# ==============================================================================
# REQUIRED: Prevent direct execution
# ==============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
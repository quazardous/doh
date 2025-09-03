#!/bin/bash

# Integration Test: Epic Command Simplification
# Verifies that epic commands using helpers are simpler and more maintainable
#
# NOTE: This test performs static analysis only - no dangerous git operations

source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"

_tf_setup() {
    # No setup needed for static analysis
    return 0
}

_tf_teardown() {
    # No cleanup needed
    return 0
}

# Test that epic-start command uses helper functions
test_epic_start_uses_helpers() {
    local epic_start_file=".claude/commands/doh/epic-start.md"
    
    _tf_assert_file_exists "$epic_start_file" "epic-start command should exist"
    
    # Should use helper functions instead of inline bash
    _tf_assert_file_contains "$epic_start_file" "helper\.sh epic validate_prerequisites" "Should use validation helper"
    _tf_assert_file_contains "$epic_start_file" "helper\.sh epic create_or_enter_branch" "Should use branch helper"
    
    # Should have reduced complexity (less direct bash logic)
    local complex_bash_lines
    complex_bash_lines=$(grep -c "git checkout\|git pull\|git branch" "$epic_start_file" 2>/dev/null || echo "0")
    
    # Should have reduced direct git operations compared to before helpers (was ~8-10)
    if [[ $complex_bash_lines -lt 5 ]]; then
        _tf_assert_true "true" "epic-start complexity reduced through helper abstraction (found $complex_bash_lines git ops)"
    else
        _tf_assert_true "false" "epic-start should have fewer direct git operations (found $complex_bash_lines)"
    fi
}

# Test command API compliance after helper integration
test_command_still_api_compliant() {
    local epic_start_file=".claude/commands/doh/epic-start.md"
    
    # Should not reintroduce direct file access violations
    if grep -q "grep.*:" "$epic_start_file" 2>/dev/null; then
        _tf_assert_true "false" "epic-start should not have direct frontmatter grep operations"
    else
        _tf_assert_true "true" "epic-start maintains API compliance"
    fi
    
    # Should not have direct library sourcing
    if grep -q "source.*lib/.*\.sh" "$epic_start_file" 2>/dev/null; then
        _tf_assert_true "false" "epic-start should not have direct library sourcing"
    else
        _tf_assert_true "true" "epic-start uses helper system correctly"
    fi
}

# Test that helper integration improves maintainability
test_helper_integration_benefits() {
    local epic_start_file=".claude/commands/doh/epic-start.md"
    
    # Count total lines in the command
    local total_lines
    total_lines=$(wc -l < "$epic_start_file")
    
    # With helpers, core sections should be more concise (but total may include documentation)
    if [[ $total_lines -lt 300 ]]; then
        _tf_assert_true "true" "epic-start is reasonably sized with helper abstraction ($total_lines lines)"
    else
        _tf_assert_true "false" "epic-start should be more concise with helpers (currently $total_lines lines)"
    fi
    
    # Should have clear, readable helper calls
    _tf_assert_file_contains "$epic_start_file" "Validate Prerequisites" "Should have clear section headers"
}

# Test that helpers don't break existing functionality
test_helpers_preserve_functionality() {
    # Verify helper functions exist and are accessible
    local help_output
    help_output=$(./.claude/scripts/doh/helper.sh epic help 2>&1)
    
    _tf_assert_contains "$help_output" "validate.*prerequisites" "Validation function should be documented"
    _tf_assert_contains "$help_output" "create-branch" "Branch function should be documented"
    _tf_assert_contains "$help_output" "ready-tasks" "Task analysis function should be documented"
    
    # Functions should be properly named and callable
    local functions_output
    functions_output=$(./.claude/scripts/doh/helper.sh epic help 2>&1)
    _tf_assert_contains "$functions_output" "DOH Epic Management" "Should show proper help header"
}

# Main test execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_run_tests
fi
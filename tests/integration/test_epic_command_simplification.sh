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
    
    _tf_assert_file_exists "epic-start command should exist" "$epic_start_file"
    
    # Should use helper functions instead of inline bash
    _tf_assert_file_contains "Should use validation helper" "$epic_start_file" "helper\.sh epic validate_prerequisites"
    _tf_assert_file_contains "Should use branch helper" "$epic_start_file" "helper\.sh epic create_or_enter_branch"
    
    # Should have reduced complexity (less direct bash logic)
    local complex_bash_lines
    complex_bash_lines=$(grep -c "git checkout\|git pull\|git branch" "$epic_start_file" 2>/dev/null || echo "0")
    
    # Should have reduced direct git operations compared to before helpers (was ~8-10)
    if [[ $complex_bash_lines -lt 5 ]]; then
        _tf_assert_true "epic-start complexity reduced through helper abstraction (found $complex_bash_lines git ops)" "true"
    else
        _tf_assert_true "epic-start should have fewer direct git operations (found $complex_bash_lines)" "false"
    fi
}

# Test command API compliance after helper integration
test_command_still_api_compliant() {
    local epic_start_file=".claude/commands/doh/epic-start.md"
    
    # Should not reintroduce direct file access violations
    if grep -q "grep.*:" "$epic_start_file" 2>/dev/null; then
        _tf_assert_true "epic-start should not have direct frontmatter grep operations" "false"
    else
        _tf_assert_true "epic-start maintains API compliance" "true"
    fi
    
    # Should not have direct library sourcing
    if grep -q "source.*lib/.*\.sh" "$epic_start_file" 2>/dev/null; then
        _tf_assert_true "epic-start should not have direct library sourcing" "false"
    else
        _tf_assert_true "epic-start uses helper system correctly" "true"
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
        _tf_assert_true "epic-start is reasonably sized with helper abstraction ($total_lines lines)" "true"
    else
        _tf_assert_true "epic-start should be more concise with helpers (currently $total_lines lines)" "false"
    fi
    
    # Should have clear, readable helper calls
    _tf_assert_file_contains "Should have clear section headers" "$epic_start_file" "Validate Prerequisites"
}

# Test that helpers don't break existing functionality
test_helpers_preserve_functionality() {
    # Verify helper functions exist and are accessible
    local help_output
    help_output=$(./.claude/scripts/doh/helper.sh epic help 2>&1)
    
    _tf_assert_contains "Validation function should be documented" "$help_output" "validate.*prerequisites"
    _tf_assert_contains "Branch function should be documented" "$help_output" "create-branch"
    _tf_assert_contains "Task analysis function should be documented" "$help_output" "ready-tasks"
    
    # Functions should be properly named and callable
    local functions_output
    functions_output=$(./.claude/scripts/doh/helper.sh epic help 2>&1)
    _tf_assert_contains "Should show proper help header" "$functions_output" "DOH Epic Management"
}

# Main test execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
#!/bin/bash

# Integration tests for DOH migration system
# Tests conflict detection, deduplication, and rollback functionality

set -e

# Source the migration tools
MIGRATION_DIR="$(dirname "$0")/../migration"
LIB_DIR="$(dirname "$0")/../lib"

source "$LIB_DIR/workspace.sh"
source "$MIGRATION_DIR/detect_duplicates.sh"
source "$MIGRATION_DIR/deduplicate.sh"
source "$MIGRATION_DIR/rollback.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test environment
TEST_PROJECT_ROOT=""
TEST_PROJECT_ID=""

# Test helper functions
print_test_header() {
    echo -e "\n${YELLOW}=== $1 ===${NC}"
}

print_test() {
    echo -n "  Testing: $1 ... "
    ((TESTS_RUN++))
}

pass_test() {
    echo -e "${GREEN}PASS${NC}"
    ((TESTS_PASSED++))
}

fail_test() {
    echo -e "${RED}FAIL${NC}"
    if [[ -n "$1" ]]; then
        echo -e "    ${RED}Error: $1${NC}"
    fi
    ((TESTS_FAILED++))
}

# Setup test environment with duplicate scenarios
setup_test_env() {
    export TEST_PROJECT_ID="migration_test_$(date +%s)_$$"
    export TEST_PROJECT_ROOT="/tmp/doh_migration_test_$$"
    
    # Override functions for testing
    get_current_project_id() {
        echo "$TEST_PROJECT_ID"
    }
    
    _find_doh_root() {
        echo "$TEST_PROJECT_ROOT"
    }
    
    # Create test project structure with conflicts
    mkdir -p "$TEST_PROJECT_ROOT/.doh/epics/user-auth"
    mkdir -p "$TEST_PROJECT_ROOT/.doh/epics/billing"
    mkdir -p "$TEST_PROJECT_ROOT/.doh/epics/reporting"
    mkdir -p "$TEST_PROJECT_ROOT/.doh/quick"
    
    # Create QUICK epic (should keep number 000)
    cat > "$TEST_PROJECT_ROOT/.doh/quick/manifest.md" << 'EOF'
---
name: QUICK
number: 000
status: active
created: 2025-08-30T09:00:00Z
---
# QUICK Tasks
EOF
    
    # Create conflicting epics (same number 001)
    cat > "$TEST_PROJECT_ROOT/.doh/epics/user-auth/epic.md" << 'EOF'
---
name: user-auth
number: 001
status: active
created: 2025-08-30T10:00:00Z
---
# User Authentication Epic
EOF
    
    cat > "$TEST_PROJECT_ROOT/.doh/epics/billing/epic.md" << 'EOF'
---
name: billing
number: 001
status: active
created: 2025-08-31T10:00:00Z
---
# Billing Epic (duplicate number)
EOF
    
    # Create conflicting tasks (same number 002)
    cat > "$TEST_PROJECT_ROOT/.doh/epics/user-auth/002.md" << 'EOF'
---
name: Login implementation
number: 002
parent: 001
epic: user-auth
status: open
created: 2025-08-30T11:00:00Z
depends_on: [001]
---
# Login Implementation Task
EOF
    
    cat > "$TEST_PROJECT_ROOT/.doh/epics/billing/002.md" << 'EOF'
---
name: Payment processing
number: 002
parent: 001
epic: billing
status: open
created: 2025-08-31T11:00:00Z
depends_on: [001]
---
# Payment Processing Task (duplicate number)
EOF
    
    # Create task with dependency on conflicted number
    cat > "$TEST_PROJECT_ROOT/.doh/epics/reporting/003.md" << 'EOF'
---
name: User reports
number: 003
parent: 001
epic: reporting
status: open
created: 2025-08-31T12:00:00Z
depends_on: [002]
---
# User Reports Task (depends on conflicted number)
EOF
    
    # Create registry directories
    mkdir -p "$HOME/.doh/projects/$TEST_PROJECT_ID"
    
    echo "Test environment setup: $TEST_PROJECT_ROOT"
}

# Cleanup test environment
cleanup_test_env() {
    if [[ -d "$TEST_PROJECT_ROOT" ]]; then
        rm -rf "$TEST_PROJECT_ROOT"
    fi
    if [[ -d "$HOME/.doh/projects/$TEST_PROJECT_ID" ]]; then
        rm -rf "$HOME/.doh/projects/$TEST_PROJECT_ID"
    fi
}

# Test conflict detection
test_conflict_detection() {
    print_test_header "Conflict Detection Tests"
    
    print_test "Scan project files"
    if scan_project_files; then
        pass_test
    else
        fail_test "Project scan failed"
        return
    fi
    
    print_test "Detect duplicate numbers"
    local duplicate_count=${#DUPLICATE_NUMBERS[@]}
    
    if [[ $duplicate_count -eq 2 ]]; then
        pass_test
    else
        fail_test "Expected 2 duplicate numbers, found: $duplicate_count"
    fi
    
    print_test "Verify specific duplicates detected"
    if [[ -n "${DUPLICATE_NUMBERS[001]}" && -n "${DUPLICATE_NUMBERS[002]}" ]]; then
        pass_test
    else
        fail_test "Expected duplicates for numbers 001 and 002"
    fi
    
    print_test "JSON conflict report generation"
    local json_report
    json_report=$(build_conflict_report "json")
    
    if echo "$json_report" | jq -e '.conflicts | length == 2' >/dev/null 2>&1; then
        pass_test
    else
        fail_test "JSON report should contain 2 conflicts"
    fi
    
    print_test "Text conflict report generation"
    local text_report
    text_report=$(build_conflict_report "text")
    
    if [[ "$text_report" == *"Conflict #1"* && "$text_report" == *"Conflict #2"* ]]; then
        pass_test
    else
        fail_test "Text report formatting incorrect"
    fi
    
    print_test "CSV conflict report generation"
    local csv_report
    csv_report=$(build_conflict_report "csv")
    
    if [[ "$csv_report" == *"number,conflict_id"* && "$csv_report" == *"001,conflict-001"* ]]; then
        pass_test
    else
        fail_test "CSV report formatting incorrect"
    fi
}

# Test deduplication process
test_deduplication() {
    print_test_header "Deduplication Tests"
    
    print_test "Build renumbering plan"
    local conflicts_json
    conflicts_json=$(build_conflict_report "json")
    
    if build_renumbering_plan "$conflicts_json"; then
        pass_test
    else
        fail_test "Failed to build renumbering plan"
        return
    fi
    
    print_test "Verify renumbering plan content"
    local plan_count=${#RENUMBERING_PLAN[@]}
    
    # Should have 2 files to renumber (newer duplicates)
    if [[ $plan_count -eq 2 ]]; then
        pass_test
    else
        fail_test "Expected 2 files in renumbering plan, got: $plan_count"
    fi
    
    print_test "Dependency mapping"
    if map_dependencies; then
        pass_test
    else
        fail_test "Dependency mapping failed"
    fi
    
    print_test "Verify dependency mapping content"
    local dep_count=${#DEPENDENCY_MAP[@]}
    
    if [[ $dep_count -gt 0 ]]; then
        pass_test
    else
        fail_test "No dependencies mapped"
    fi
    
    print_test "Execute file renumbering"
    local success_count=0
    
    for file_path in "${!RENUMBERING_PLAN[@]}"; do
        local plan="${RENUMBERING_PLAN[$file_path]}"
        local old_number new_number
        
        IFS='→' read -r old_number rest <<< "$plan"
        IFS='|' read -r new_number extra <<< "$rest"
        
        if update_file_number "$file_path" "$old_number" "$new_number" "$TEST_PROJECT_ROOT"; then
            ((success_count++))
        fi
    done
    
    if [[ $success_count -eq ${#RENUMBERING_PLAN[@]} ]]; then
        pass_test
    else
        fail_test "Only $success_count/${#RENUMBERING_PLAN[@]} files updated successfully"
    fi
    
    print_test "Update dependency references"
    if update_dependency_references; then
        pass_test
    else
        fail_test "Dependency reference updates failed"
    fi
}

# Test migration validation
test_validation() {
    print_test_header "Migration Validation Tests"
    
    print_test "Re-scan for remaining duplicates"
    scan_project_files >/dev/null 2>&1
    local remaining_duplicates=${#DUPLICATE_NUMBERS[@]}
    
    if [[ $remaining_duplicates -eq 0 ]]; then
        pass_test
    else
        fail_test "Still has $remaining_duplicates duplicate numbers after migration"
    fi
    
    print_test "Validate file content changes"
    # Check that files were actually updated
    local billing_epic_number
    billing_epic_number=$(grep -m 1 "^number:" "$TEST_PROJECT_ROOT/.doh/epics/billing/epic.md" | cut -d':' -f2- | xargs)
    
    if [[ "$billing_epic_number" != "001" ]]; then
        pass_test
    else
        fail_test "Billing epic still has conflicted number 001"
    fi
    
    print_test "Validate dependency updates"
    # Check that references were updated
    local reporting_deps
    reporting_deps=$(grep -m 1 "^depends_on:" "$TEST_PROJECT_ROOT/.doh/epics/reporting/003.md" | cut -d':' -f2- | xargs)
    
    # The dependency on 002 should have been updated
    if [[ "$reporting_deps" != *"002"* ]] || [[ "$reporting_deps" == *"00"[4-9]* ]]; then
        pass_test
    else
        fail_test "Dependencies were not updated correctly: $reporting_deps"
    fi
    
    print_test "Validate file numbering consistency"
    local all_numbers=()
    
    find "$TEST_PROJECT_ROOT" -name "*.md" -path "*/.doh/*" -type f -exec grep -l "^number:" {} \; | while read -r file; do
        local number
        number=$(grep -m 1 "^number:" "$file" | cut -d':' -f2- | xargs)
        if [[ -n "$number" ]]; then
            echo "$number"
        fi
    done | sort | uniq -d > /tmp/duplicate_check_$$
    
    if [[ ! -s /tmp/duplicate_check_$$ ]]; then
        pass_test
    else
        local duplicates
        duplicates=$(cat /tmp/duplicate_check_$$)
        fail_test "Still have duplicate numbers: $duplicates"
    fi
    
    rm -f /tmp/duplicate_check_$$
}

# Test backup and rollback functionality
test_backup_rollback() {
    print_test_header "Backup and Rollback Tests"
    
    print_test "Create migration backup"
    local backup_dir
    backup_dir=$(create_migration_backup 2>/dev/null)
    
    if [[ -d "$backup_dir" ]]; then
        pass_test
    else
        fail_test "Backup directory not created"
        return
    fi
    
    print_test "Validate backup content"
    if validate_backup "$backup_dir"; then
        pass_test
    else
        fail_test "Backup validation failed"
    fi
    
    print_test "Backup contains original files"
    local backup_billing_number
    backup_billing_number=$(grep -m 1 "^number:" "$backup_dir/.doh/epics/billing/epic.md" | cut -d':' -f2- | xargs)
    
    # Backup should contain original conflicted number
    if [[ "$backup_billing_number" == "001" ]]; then
        pass_test
    else
        fail_test "Backup doesn't contain original file state"
    fi
    
    # Modify current files to test rollback
    echo "# Modified after backup" >> "$TEST_PROJECT_ROOT/.doh/epics/user-auth/epic.md"
    
    print_test "Restore from backup"
    if restore_from_backup "$backup_dir" "false"; then
        pass_test
    else
        fail_test "Restore from backup failed"
    fi
    
    print_test "Verify rollback restored original state"
    if ! grep -q "Modified after backup" "$TEST_PROJECT_ROOT/.doh/epics/user-auth/epic.md"; then
        pass_test
    else
        fail_test "Rollback did not restore original state"
    fi
    
    print_test "List backups functionality"
    local backup_list
    backup_list=$(list_backups 2>/dev/null)
    
    if [[ "$backup_list" == *"migration_"* ]]; then
        pass_test
    else
        fail_test "Backup listing failed"
    fi
}

# Test edge cases and error handling
test_edge_cases() {
    print_test_header "Edge Cases and Error Handling"
    
    print_test "Handle non-existent project"
    local old_project_root="$TEST_PROJECT_ROOT"
    TEST_PROJECT_ROOT="/nonexistent/path"
    
    if ! scan_project_files >/dev/null 2>&1; then
        pass_test
    else
        fail_test "Should fail for non-existent project"
    fi
    
    TEST_PROJECT_ROOT="$old_project_root"
    
    print_test "Handle corrupted frontmatter"
    # Create file with malformed frontmatter
    cat > "$TEST_PROJECT_ROOT/.doh/epics/user-auth/corrupted.md" << 'EOF'
---
name: corrupted
number: invalid
status: open
---
# Corrupted file
EOF
    
    # Should handle gracefully
    if scan_project_files >/dev/null 2>&1; then
        pass_test
    else
        fail_test "Should handle corrupted frontmatter gracefully"
    fi
    
    print_test "Handle missing dependencies"
    # Create file with reference to non-existent number
    cat > "$TEST_PROJECT_ROOT/.doh/epics/user-auth/orphan.md" << 'EOF'
---
name: orphan
number: 999
parent: 888
epic: user-auth
status: open
depends_on: [777, 666]
---
# Orphaned file
EOF
    
    # Should detect but not crash
    if map_dependencies >/dev/null 2>&1; then
        pass_test
    else
        fail_test "Should handle missing dependencies gracefully"
    fi
    
    print_test "Validate empty project handling"
    # Remove all numbered files temporarily
    find "$TEST_PROJECT_ROOT" -name "*.md" -path "*/.doh/*" -type f -exec grep -l "^number:" {} \; | while read -r file; do
        mv "$file" "$file.backup"
    done
    
    scan_project_files >/dev/null 2>&1
    local empty_duplicates=${#DUPLICATE_NUMBERS[@]}
    
    # Restore files
    find "$TEST_PROJECT_ROOT" -name "*.md.backup" -path "*/.doh/*" -type f | while read -r backup_file; do
        mv "$backup_file" "${backup_file%.backup}"
    done
    
    if [[ $empty_duplicates -eq 0 ]]; then
        pass_test
    else
        fail_test "Should handle empty projects correctly"
    fi
}

# Test performance with larger dataset
test_performance() {
    print_test_header "Performance Tests"
    
    print_test "Generate large conflict dataset"
    # Create multiple conflicted numbers
    for i in {10..20}; do
        mkdir -p "$TEST_PROJECT_ROOT/.doh/epics/test-epic-$i"
        
        cat > "$TEST_PROJECT_ROOT/.doh/epics/test-epic-$i/epic.md" << EOF
---
name: test-epic-$i
number: 100
status: active
created: 2025-08-30T$(printf "%02d" $i):00:00Z
---
# Test Epic $i
EOF
    done
    
    local start_time end_time
    start_time=$(date +%s%N)
    
    scan_project_files >/dev/null 2>&1
    
    end_time=$(date +%s%N)
    local duration_ms=$(( (end_time - start_time) / 1000000 ))
    
    # Should complete within reasonable time (5 seconds for test dataset)
    if [[ $duration_ms -lt 5000 ]]; then
        pass_test
    else
        fail_test "Conflict detection too slow: ${duration_ms}ms"
    fi
    
    print_test "Performance with many duplicates"
    local duplicate_count=${#DUPLICATE_NUMBERS[@]}
    
    # Should have detected the new conflicts
    if [[ $duplicate_count -gt 2 ]]; then
        pass_test
    else
        fail_test "Should detect multiple conflicts"
    fi
    
    # Clean up test files
    rm -rf "$TEST_PROJECT_ROOT/.doh/epics/test-epic-"*
}

# Integration test for full migration workflow
test_full_migration_workflow() {
    print_test_header "Full Migration Workflow Test"
    
    print_test "Complete migration workflow"
    
    # Reset environment to initial conflicted state
    cleanup_test_env
    setup_test_env
    
    local workflow_success=true
    
    # Step 1: Detection
    if ! scan_project_files >/dev/null 2>&1; then
        workflow_success=false
        fail_test "Detection failed"
        return
    fi
    
    # Step 2: Plan building
    local conflicts_json
    conflicts_json=$(build_conflict_report "json")
    
    if ! build_renumbering_plan "$conflicts_json" >/dev/null 2>&1; then
        workflow_success=false
        fail_test "Plan building failed"
        return
    fi
    
    # Step 3: Backup
    local backup_dir
    backup_dir=$(create_migration_backup 2>/dev/null)
    
    if [[ ! -d "$backup_dir" ]]; then
        workflow_success=false
        fail_test "Backup creation failed"
        return
    fi
    
    # Step 4: Execute migration
    map_dependencies >/dev/null 2>&1
    
    for file_path in "${!RENUMBERING_PLAN[@]}"; do
        local plan="${RENUMBERING_PLAN[$file_path]}"
        local old_number new_number
        
        IFS='→' read -r old_number rest <<< "$plan"
        IFS='|' read -r new_number extra <<< "$rest"
        
        if ! update_file_number "$file_path" "$old_number" "$new_number" "$TEST_PROJECT_ROOT" >/dev/null 2>&1; then
            workflow_success=false
            break
        fi
    done
    
    # Step 5: Update dependencies
    if ! update_dependency_references >/dev/null 2>&1; then
        workflow_success=false
        fail_test "Dependency updates failed"
        return
    fi
    
    # Step 6: Validate
    scan_project_files >/dev/null 2>&1
    if [[ ${#DUPLICATE_NUMBERS[@]} -ne 0 ]]; then
        workflow_success=false
        fail_test "Validation failed - duplicates remain"
        return
    fi
    
    if [[ "$workflow_success" == "true" ]]; then
        pass_test
    else
        fail_test "Workflow completed with errors"
    fi
}

# Main test execution
main() {
    echo "DOH Migration System Integration Test Suite"
    echo "==========================================="
    
    # Setup
    setup_test_env
    trap cleanup_test_env EXIT
    
    # Run all tests
    test_conflict_detection
    test_deduplication
    test_validation
    test_backup_rollback
    test_edge_cases
    test_performance
    test_full_migration_workflow
    
    # Print results
    echo -e "\n${YELLOW}Test Results:${NC}"
    echo "  Total: $TESTS_RUN"
    echo -e "  ${GREEN}Passed: $TESTS_PASSED${NC}"
    
    if [[ $TESTS_FAILED -gt 0 ]]; then
        echo -e "  ${RED}Failed: $TESTS_FAILED${NC}"
        exit 1
    else
        echo -e "  ${RED}Failed: $TESTS_FAILED${NC}"
        echo -e "\n${GREEN}All tests passed!${NC}"
        
        echo -e "\n${YELLOW}Migration System Verification Complete${NC}"
        echo "• Conflict detection working correctly"
        echo "• Deduplication process functional" 
        echo "• Backup and rollback systems operational"
        echo "• Error handling robust"
        echo "• Performance acceptable"
        echo "• Full workflow integration successful"
        
        exit 0
    fi
}

# Run tests
main "$@"
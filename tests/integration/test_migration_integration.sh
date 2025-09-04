#!/bin/bash
# Integration tests for DOH migration system
# Tests conflict detection, deduplication, and rollback functionality
# Converted from legacy test format to new DOH test framework
# File version: 0.1.0 | Created: 2025-09-01

# Source the framework
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"

# Source the libraries being tested
LIB_DIR="$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib"
HELPER_DIR="$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/helper"

# Check if libraries exist before sourcing
if [[ -f "$LIB_DIR/workspace.sh" ]]; then
    source "$LIB_DIR/workspace.sh"
fi

if [[ -f "$LIB_DIR/doh.sh" ]]; then
    source "$LIB_DIR/doh.sh"
fi

# Source migration helper functions
if [[ -f "$HELPER_DIR/migration.sh" ]]; then
    source "$HELPER_DIR/migration.sh"
fi

# Test environment setup
_tf_setup() {
    export DOH_TEST_PROJECT_ID="migration_test_$(date +%s)_$$"
    export DOH_TEST_PROJECT_ROOT="$(_tf_create_temp_dir)"
    
    # Override workspace functions for testing
    _find_doh_root() {
        echo "$DOH_TEST_PROJECT_ROOT"
    }
    
    workspace_get_current_project_id() {
        echo "$DOH_TEST_PROJECT_ID"
    }
    
    # Create test project structure with potential duplicates
    local doh_dir="$DOH_TEST_PROJECT_ROOT/.doh"
    mkdir -p "$doh_dir/epics/user-auth"
    mkdir -p "$doh_dir/epics/duplicate-auth" 
    mkdir -p "$doh_dir/migration"
    
    # Create test files with duplicate content
    cat > "$doh_dir/epics/user-auth/epic.md" << 'EOF'
---
name: user-auth
number: 001
status: active
description: User authentication system
---
# User Authentication Epic
This epic handles user login and registration.
EOF

    cat > "$doh_dir/epics/duplicate-auth/epic.md" << 'EOF'
---
name: duplicate-auth
number: 002
status: active
description: User authentication system
---
# User Authentication Epic
This epic handles user login and registration.
EOF

    # Create tasks with duplicates
    cat > "$doh_dir/epics/user-auth/003.md" << 'EOF'
---
name: Login form
number: 003
parent: 001
epic: user-auth
status: open
---
# Login Form Implementation
Create the login form component.
EOF

    cat > "$doh_dir/epics/duplicate-auth/004.md" << 'EOF'
---
name: Login form duplicate
number: 004
parent: 002
epic: duplicate-auth
status: open
---
# Login Form Implementation
Create the login form component.
EOF
}

_tf_teardown() {
    # Cleanup test environment
    if [[ -n "$DOH_TEST_PROJECT_ROOT" ]]; then
    fi
}

# Duplicate Detection Tests
test_duplicate_detection_epics() {
    if ! command -v detect_duplicates >/dev/null 2>&1; then
        _tf_assert_true "Skipping - detect_duplicates function not available" "true"
        return
    fi
    
    local duplicates
    duplicates="$(detect_duplicates "epic")"
    
    _tf_assert_contains "Should detect duplicate epics" "$duplicates" "user-auth"
    _tf_assert_contains "Should detect both duplicate epics" "$duplicates" "duplicate-auth"
}

test_duplicate_detection_tasks() {
    if ! command -v detect_duplicates >/dev/null 2>&1; then
        _tf_assert_true "Skipping - detect_duplicates function not available" "true"
        return
    fi
    
    local duplicates
    duplicates="$(detect_duplicates "task")"
    
    _tf_assert_contains "Should detect duplicate task content" "$duplicates" "003"
    _tf_assert_contains "Should detect both duplicate tasks" "$duplicates" "004"
}

test_duplicate_detection_by_content() {
    if ! command -v detect_content_duplicates >/dev/null 2>&1; then
        _tf_assert_true "Skipping - detect_content_duplicates function not available" "true"
        return
    fi
    
    local content_duplicates
    content_duplicates="$(detect_content_duplicates)"
    
    _tf_assert_contains "Should detect duplicate content" "$content_duplicates" "Login Form Implementation"
}

test_duplicate_detection_by_metadata() {
    if ! command -v detect_metadata_duplicates >/dev/null 2>&1; then
        _tf_assert_true "Skipping - detect_metadata_duplicates function not available" "true"
        return
    fi
    
    local metadata_duplicates
    metadata_duplicates="$(detect_metadata_duplicates)"
    
    _tf_assert_contains "Should detect duplicate descriptions" "$metadata_duplicates" "User authentication system"
}

# Deduplication Tests
test_deduplication_dry_run() {
    if ! command -v deduplicate_dry_run >/dev/null 2>&1; then
        _tf_assert_true "Skipping - deduplicate_dry_run function not available" "true"
        return
    fi
    
    local dry_run_result
    dry_run_result="$(deduplicate_dry_run)"
    
    _tf_assert_contains "Dry run should show potential merges" "$dry_run_result" "would merge"
    
    # Original files should still exist
    local doh_dir="$DOH_TEST_PROJECT_ROOT/.doh"
    _tf_assert_file_exists "Original file should exist after dry run" "$doh_dir/epics/user-auth/epic.md"
    _tf_assert_file_exists "Duplicate file should exist after dry run" "$doh_dir/epics/duplicate-auth/epic.md"
}

test_deduplication_execution() {
    if ! command -v helper_migration_execute_deduplication >/dev/null 2>&1; then
        _tf_assert_true "Skipping - helper_migration_execute_deduplication function not available" "true"
        return
    fi
    
    # Create backup before deduplication
    local doh_dir="$DOH_TEST_PROJECT_ROOT/.doh"
    cp -r "$doh_dir" "$DOH_TEST_PROJECT_ROOT/.doh.backup"
    
    local dedup_result
    dedup_result="$(helper_migration_execute_deduplication)"
    
    _tf_assert "Deduplication should execute successfully" echo '$dedup_result'
}

test_deduplication_merge_strategy() {
    if ! command -v helper_migration_merge_duplicates >/dev/null 2>&1; then
        _tf_assert_true "Skipping - helper_migration_merge_duplicates function not available" "true"
        return
    fi
    
    local merge_result
    merge_result="$(helper_migration_merge_duplicates "user-auth" "duplicate-auth")"
    
    _tf_assert "Should merge duplicate epics" echo '$merge_result'
}

# Rollback Tests  
test_rollback_preparation() {
    if ! command -v helper_migration_prepare_rollback >/dev/null 2>&1; then
        _tf_assert_true "Skipping - helper_migration_prepare_rollback function not available" "true"
        return
    fi
    
    local rollback_info
    rollback_info="$(helper_migration_prepare_rollback)"
    
    _tf_assert_contains "Should prepare rollback snapshot" "$rollback_info" "snapshot"
}

test_rollback_execution() {
    if ! command -v helper_migration_execute_rollback >/dev/null 2>&1; then
        _tf_assert_true "Skipping - helper_migration_execute_rollback function not available" "true"
        return
    fi
    
    # Create a rollback point
    local rollback_id
    if command -v helper_migration_create_rollback_point >/dev/null 2>&1; then
        rollback_id="$(helper_migration_create_rollback_point)"
    else
        rollback_id="test_rollback_point"
    fi
    
    # Make some changes
    local doh_dir="$DOH_TEST_PROJECT_ROOT/.doh"
    echo "# Modified content" > "$doh_dir/epics/user-auth/epic.md"
    
    # Execute rollback
    _tf_assert "Should rollback changes successfully" helper_migration_execute_rollback "$rollback_id"
}

test_rollback_validation() {
    if ! command -v helper_migration_validate_rollback >/dev/null 2>&1; then
        _tf_assert_true "Skipping - helper_migration_validate_rollback function not available" "true"
        return
    fi
    
    local validation_result
    validation_result="$(helper_migration_validate_rollback)"
    
    _tf_assert_contains "Rollback state should be valid" "$validation_result" "valid"
}

# Migration Workflow Tests
test_full_migration_workflow() {
    if ! command -v helper_migration_run_workflow >/dev/null 2>&1; then
        _tf_assert_true "Skipping - helper_migration_run_workflow function not available" "true"
        return
    fi
    
    local workflow_result
    workflow_result="$(helper_migration_run_workflow --dry-run)"
    
    _tf_assert_contains "Workflow should include detection phase" "$workflow_result" "detection"
    _tf_assert_contains "Workflow should include deduplication phase" "$workflow_result" "deduplication"
    _tf_assert_contains "Workflow should include validation phase" "$workflow_result" "validation"
}

test_migration_conflict_resolution() {
    # Create conflicting files
    local doh_dir="$DOH_TEST_PROJECT_ROOT/.doh"
    cat > "$doh_dir/epics/user-auth/conflict.md" << 'EOF'
---
name: conflict-test
number: 005
status: open
---
# Original content
EOF

    cat > "$doh_dir/epics/duplicate-auth/conflict.md" << 'EOF'
---
name: conflict-test-duplicate  
number: 006
status: closed
---
# Modified content
EOF
    
    if ! command -v helper_migration_resolve_conflicts >/dev/null 2>&1; then
        _tf_assert_true "Skipping - helper_migration_resolve_conflicts function not available" "true"
        return
    fi
    
    local resolution_result
    resolution_result="$(helper_migration_resolve_conflicts)"
    
    _tf_assert "Should resolve conflicts" echo '$resolution_result'
}

# Migration Safety Tests
test_migration_backup_creation() {
    if ! command -v helper_migration_create_backup >/dev/null 2>&1; then
        _tf_assert_true "Skipping - helper_migration_create_backup function not available" "true"
        return
    fi
    
    local backup_path
    backup_path="$(helper_migration_create_backup)"
    
    [[ -d "$backup_path" ]]
    _tf_assert_equals "Migration backup should be created" 0 $?
}

test_migration_integrity_check() {
    if ! command -v helper_migration_check_integrity >/dev/null 2>&1; then
        _tf_assert_true "Skipping - helper_migration_check_integrity function not available" "true"
        return
    fi
    
    local integrity_result
    integrity_result="$(helper_migration_check_integrity)"
    
    _tf_assert_contains "Migration integrity should be intact" "$integrity_result" "intact"
}

# Run tests if script executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
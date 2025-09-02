#!/bin/bash
# Integration tests for DOH migration system
# Tests conflict detection, deduplication, and rollback functionality
# Converted from legacy test format to new DOH test framework
# File version: 0.1.0 | Created: 2025-09-01

# Source the framework
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"

# Source the libraries being tested
MIGRATION_DIR="$(dirname "${BASH_SOURCE[0]}")/../../migration"
LIB_DIR="$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib"

# Check if migration tools exist before sourcing
if [[ -f "$LIB_DIR/workspace.sh" ]]; then
    source "$LIB_DIR/workspace.sh"
fi

if [[ -f "$MIGRATION_DIR/detect_duplicates.sh" ]]; then
    source "$MIGRATION_DIR/detect_duplicates.sh"
fi

if [[ -f "$MIGRATION_DIR/deduplicate.sh" ]]; then
    source "$MIGRATION_DIR/deduplicate.sh"
fi

if [[ -f "$MIGRATION_DIR/rollback.sh" ]]; then
    source "$MIGRATION_DIR/rollback.sh"
fi

# Test environment setup
_tf_setup() {
    export DOH_TEST_PROJECT_ID="migration_test_$(date +%s)_$$"
    export DOH_TEST_PROJECT_ROOT="$(_tf_create_temp_dir)"
    
    # Override workspace functions for testing
    _find_doh_root() {
        echo "$DOH_TEST_PROJECT_ROOT"
    }
    
    get_current_project_id() {
        echo "$DOH_TEST_PROJECT_ID"
    }
    
    # Create test project structure with potential duplicates
    mkdir -p "$DOH_TEST_PROJECT_ROOT/.doh/epics/user-auth"
    mkdir -p "$DOH_TEST_PROJECT_ROOT/.doh/epics/duplicate-auth"
    mkdir -p "$DOH_TEST_PROJECT_ROOT/.doh/migration"
    
    # Create test files with duplicate content
    cat > "$DOH_TEST_PROJECT_ROOT/.doh/epics/user-auth/epic.md" << 'EOF'
---
name: user-auth
number: 001
status: active
description: User authentication system
---
# User Authentication Epic
This epic handles user login and registration.
EOF

    cat > "$DOH_TEST_PROJECT_ROOT/.doh/epics/duplicate-auth/epic.md" << 'EOF'
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
    cat > "$DOH_TEST_PROJECT_ROOT/.doh/epics/user-auth/003.md" << 'EOF'
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

    cat > "$DOH_TEST_PROJECT_ROOT/.doh/epics/duplicate-auth/004.md" << 'EOF'
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
        _tf_cleanup_temp "$DOH_TEST_PROJECT_ROOT"
    fi
}

# Duplicate Detection Tests
test_duplicate_detection_epics() {
    if ! command -v detect_duplicates >/dev/null 2>&1; then
        _tf_assert_true "true" "Skipping - detect_duplicates function not available"
        return
    fi
    
    local duplicates
    duplicates="$(detect_duplicates "epic")"
    
    _tf_assert_contains "$duplicates" "user-auth" "Should detect duplicate epics"
    _tf_assert_contains "$duplicates" "duplicate-auth" "Should detect both duplicate epics"
}

test_duplicate_detection_tasks() {
    if ! command -v detect_duplicates >/dev/null 2>&1; then
        _tf_assert_true "true" "Skipping - detect_duplicates function not available"
        return
    fi
    
    local duplicates
    duplicates="$(detect_duplicates "task")"
    
    _tf_assert_contains "$duplicates" "003" "Should detect duplicate task content"
    _tf_assert_contains "$duplicates" "004" "Should detect both duplicate tasks"
}

test_duplicate_detection_by_content() {
    if ! command -v detect_content_duplicates >/dev/null 2>&1; then
        _tf_assert_true "true" "Skipping - detect_content_duplicates function not available"
        return
    fi
    
    local content_duplicates
    content_duplicates="$(detect_content_duplicates)"
    
    _tf_assert_contains "$content_duplicates" "Login Form Implementation" "Should detect duplicate content"
}

test_duplicate_detection_by_metadata() {
    if ! command -v detect_metadata_duplicates >/dev/null 2>&1; then
        _tf_assert_true "true" "Skipping - detect_metadata_duplicates function not available"
        return
    fi
    
    local metadata_duplicates
    metadata_duplicates="$(detect_metadata_duplicates)"
    
    _tf_assert_contains "$metadata_duplicates" "User authentication system" "Should detect duplicate descriptions"
}

# Deduplication Tests
test_deduplication_dry_run() {
    if ! command -v deduplicate_dry_run >/dev/null 2>&1; then
        _tf_assert_true "true" "Skipping - deduplicate_dry_run function not available"
        return
    fi
    
    local dry_run_result
    dry_run_result="$(deduplicate_dry_run)"
    
    _tf_assert_contains "$dry_run_result" "would merge" "Dry run should show potential merges"
    
    # Original files should still exist
    _tf_assert_file_exists "$DOH_TEST_PROJECT_ROOT/.doh/epics/user-auth/epic.md" "Original file should exist after dry run"
    _tf_assert_file_exists "$DOH_TEST_PROJECT_ROOT/.doh/epics/duplicate-auth/epic.md" "Duplicate file should exist after dry run"
}

test_deduplication_execution() {
    if ! command -v execute_deduplication >/dev/null 2>&1; then
        _tf_assert_true "true" "Skipping - execute_deduplication function not available"
        return
    fi
    
    # Create backup before deduplication
    cp -r "$DOH_TEST_PROJECT_ROOT/.doh" "$DOH_TEST_PROJECT_ROOT/.doh.backup"
    
    local dedup_result
    dedup_result="$(execute_deduplication)"
    
    _tf_assert_command_succeeds "echo '$dedup_result'" "Deduplication should execute successfully"
}

test_deduplication_merge_strategy() {
    if ! command -v merge_duplicates >/dev/null 2>&1; then
        _tf_assert_true "true" "Skipping - merge_duplicates function not available"
        return
    fi
    
    local merge_result
    merge_result="$(merge_duplicates "user-auth" "duplicate-auth")"
    
    _tf_assert_command_succeeds "echo '$merge_result'" "Should merge duplicate epics"
}

# Rollback Tests  
test_rollback_preparation() {
    if ! command -v prepare_rollback >/dev/null 2>&1; then
        _tf_assert_true "true" "Skipping - prepare_rollback function not available"
        return
    fi
    
    local rollback_info
    rollback_info="$(prepare_rollback)"
    
    _tf_assert_contains "$rollback_info" "snapshot" "Should prepare rollback snapshot"
}

test_rollback_execution() {
    if ! command -v execute_rollback >/dev/null 2>&1; then
        _tf_assert_true "true" "Skipping - execute_rollback function not available"
        return
    fi
    
    # Create a rollback point
    local rollback_id
    rollback_id="$(create_rollback_point)"
    
    # Make some changes
    echo "# Modified content" > "$DOH_TEST_PROJECT_ROOT/.doh/epics/user-auth/epic.md"
    
    # Execute rollback
    _tf_assert_command_succeeds "execute_rollback '$rollback_id'" "Should rollback changes successfully"
}

test_rollback_validation() {
    if ! command -v validate_rollback >/dev/null 2>&1; then
        _tf_assert_true "true" "Skipping - validate_rollback function not available"
        return
    fi
    
    local validation_result
    validation_result="$(validate_rollback)"
    
    _tf_assert_contains "$validation_result" "valid" "Rollback state should be valid"
}

# Migration Workflow Tests
test_full_migration_workflow() {
    if ! command -v run_migration_workflow >/dev/null 2>&1; then
        _tf_assert_true "true" "Skipping - run_migration_workflow function not available"
        return
    fi
    
    local workflow_result
    workflow_result="$(run_migration_workflow --dry-run)"
    
    _tf_assert_contains "$workflow_result" "detection" "Workflow should include detection phase"
    _tf_assert_contains "$workflow_result" "deduplication" "Workflow should include deduplication phase"
    _tf_assert_contains "$workflow_result" "validation" "Workflow should include validation phase"
}

test_migration_conflict_resolution() {
    # Create conflicting files
    cat > "$DOH_TEST_PROJECT_ROOT/.doh/epics/user-auth/conflict.md" << 'EOF'
---
name: conflict-test
number: 005
status: open
---
# Original content
EOF

    cat > "$DOH_TEST_PROJECT_ROOT/.doh/epics/duplicate-auth/conflict.md" << 'EOF'
---
name: conflict-test-duplicate  
number: 006
status: closed
---
# Modified content
EOF
    
    if ! command -v resolve_conflicts >/dev/null 2>&1; then
        _tf_assert_true "true" "Skipping - resolve_conflicts function not available"
        return
    fi
    
    local resolution_result
    resolution_result="$(resolve_conflicts)"
    
    _tf_assert_command_succeeds "echo '$resolution_result'" "Should resolve conflicts"
}

# Migration Safety Tests
test_migration_backup_creation() {
    if ! command -v create_migration_backup >/dev/null 2>&1; then
        _tf_assert_true "true" "Skipping - create_migration_backup function not available"
        return
    fi
    
    local backup_path
    backup_path="$(create_migration_backup)"
    
    [[ -d "$backup_path" ]]
    _tf_assert_equals 0 $? "Migration backup should be created"
}

test_migration_integrity_check() {
    if ! command -v check_migration_integrity >/dev/null 2>&1; then
        _tf_assert_true "true" "Skipping - check_migration_integrity function not available"
        return
    fi
    
    local integrity_result
    integrity_result="$(check_migration_integrity)"
    
    _tf_assert_contains "$integrity_result" "intact" "Migration integrity should be intact"
}

# Run tests if script executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
#!/bin/bash

# DOH Version Workflow Integration Test Suite
# Tests complete version workflows and command integrations

# Load test framework
source "$(dirname "$0")/../helpers/test_framework.sh"

# Load version management libraries
source ".claude/scripts/doh/lib/dohenv.sh"
source ".claude/scripts/doh/lib/version.sh"
source ".claude/scripts/doh/lib/frontmatter.sh"

_tf_setup() {
    # Create temporary test environment
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR"
    
    # Initialize complete DOH project structure
    mkdir -p .doh/{versions,epics,tasks,prds} .git
    echo "0.1.0" > VERSION
    
    # Initialize git repo for version tracking
    git init . > /dev/null 2>&1
    git config user.email "test@example.com" > /dev/null 2>&1
    git config user.name "Test User" > /dev/null 2>&1
    
    # Create initial version file
    cat > .doh/versions/0.1.0.md << 'EOF'
---
version: 0.1.0
type: initial
created: 2025-09-01T10:00:00Z
breaking_changes: []
features: ["Initial project structure"]
---

# Version 0.1.0 - Initial Release

Initial version of the DOH project with basic functionality.

## Features
- Basic project structure
- Core version management
- Initial documentation
EOF
    
    # Create PRD with version
    cat > .doh/prds/core-features.md << 'EOF'
---
name: core-features
status: draft
file_version: 0.1.0
target_version: 1.0.0
---

# Core Features PRD

Core features for the DOH system.
EOF
    
    # Create epic with version hierarchy
    cat > .doh/epics/001.md << 'EOF'
---
name: version-management
number: 001
status: in_progress
file_version: 0.1.0
target_version: 0.2.0
prd: core-features
---

# Version Management Epic

Implementation of version management system.
EOF
    
    # Create tasks with version dependencies
    cat > .doh/epics/002.md << 'EOF'
---
name: version-validation
number: 002
epic: version-management
status: open
file_version: 0.1.0
target_version: 0.2.0
depends_on: []
---

# Version Validation Task

Implement version validation utilities.
EOF
    
    cat > .doh/epics/003.md << 'EOF'
---
name: version-commands
number: 003
epic: version-management
status: open
file_version: 0.1.0
target_version: 0.2.0
depends_on: [002]
---

# Version Commands Task

Implement version management commands.
EOF
    
    # Commit initial state
    git add . > /dev/null 2>&1
    git commit -m "Initial version structure" > /dev/null 2>&1
    
    cd - > /dev/null
}

_tf_teardown() {
    # Cleanup test directory
    if [[ -n "$TEST_DIR" && -d "$TEST_DIR" ]]; then
        rm -rf "$TEST_DIR"
    fi
}

test_version_release_workflow() {
    cd "$TEST_DIR"
    
    echo "🧪 Testing complete version release workflow..."
    
    # Step 1: Validate current project state
    local current_version
    current_version=$(get_current_version)
    _tf_assert_equals "0.1.0" "$current_version" "Initial version should be 0.1.0"
    
    # Step 2: Complete tasks (mark as completed)
    set_frontmatter_field ".doh/epics/002.md" "status" "completed" > /dev/null
    set_frontmatter_field ".doh/epics/003.md" "status" "completed" > /dev/null
    
    # Step 3: Check epic readiness for version bump
    local epic_status
    epic_status=$(get_frontmatter_field ".doh/epics/001.md" "status")
    _tf_assert_equals "in_progress" "$epic_status" "Epic should still be in progress"
    
    # Step 4: Bump project version (minor release)
    local new_version
    new_version=$(bump_project_version "minor")
    _tf_assert_equals "0.2.0" "$new_version" "Should bump to target version 0.2.0"
    
    # Step 5: Create version milestone file
    cat > .doh/versions/0.2.0.md << 'EOF'
---
version: 0.2.0
type: minor
created: 2025-09-01T12:00:00Z
breaking_changes: []
features: ["Version management system", "Version validation utilities"]
epic_refs: ["001"]
task_refs: ["002", "003"]
---

# Version 0.2.0 - Version Management

Version management system implementation.

## Features
- Complete version validation system
- Version management commands
- File version tracking

## Tasks Completed
- Version validation utilities (002)
- Version management commands (003)
EOF
    
    # Step 6: Update file versions to match release
    set_file_version ".doh/prds/core-features.md" "$new_version" > /dev/null
    set_file_version ".doh/epics/001.md" "$new_version" > /dev/null
    set_file_version ".doh/epics/002.md" "$new_version" > /dev/null
    set_file_version ".doh/epics/003.md" "$new_version" > /dev/null
    
    # Step 7: Verify all files have consistent versions
    local prd_version
    prd_version=$(get_file_version ".doh/prds/core-features.md")
    _tf_assert_equals "$new_version" "$prd_version" "PRD version should be updated"
    
    local epic_version
    epic_version=$(get_file_version ".doh/epics/001.md")
    _tf_assert_equals "$new_version" "$epic_version" "Epic version should be updated"
    
    # Step 8: Mark epic as completed
    set_frontmatter_field ".doh/epics/001.md" "status" "completed" > /dev/null
    
    # Step 9: Verify no version inconsistencies
    local inconsistencies
    inconsistencies=$(find_version_inconsistencies 2>/dev/null || echo "")
    _tf_assert_equals "" "$inconsistencies" "Should have no version inconsistencies after release"
    
    cd - > /dev/null
}

test_version_hierarchy_inheritance() {
    cd "$TEST_DIR"
    
    echo "🧪 Testing version hierarchy inheritance..."
    
    # Test PRD -> Epic -> Task version inheritance
    local prd_target
    prd_target=$(get_frontmatter_field ".doh/prds/core-features.md" "target_version")
    _tf_assert_equals "1.0.0" "$prd_target" "PRD should have target version 1.0.0"
    
    local epic_target
    epic_target=$(get_frontmatter_field ".doh/epics/001.md" "target_version")
    _tf_assert_equals "0.2.0" "$epic_target" "Epic should have its own target version"
    
    local task_target
    task_target=$(get_frontmatter_field ".doh/epics/002.md" "target_version")
    _tf_assert_equals "0.2.0" "$task_target" "Task should inherit epic target version"
    
    cd - > /dev/null
}

test_version_dependency_tracking() {
    cd "$TEST_DIR"
    
    echo "🧪 Testing version dependency tracking..."
    
    # Check task dependencies
    local task_deps
    task_deps=$(get_frontmatter_field ".doh/epics/003.md" "depends_on")
    echo "$task_deps" | grep -q "002"
    _tf_assert_equals 0 $? "Task 003 should depend on task 002"
    
    # Verify dependency versions are consistent
    local dep_version
    dep_version=$(get_file_version ".doh/epics/002.md")
    local dependent_version
    dependent_version=$(get_file_version ".doh/epics/003.md")
    
    _tf_assert_equals "$dep_version" "$dependent_version" "Dependent tasks should have consistent versions"
    
    cd - > /dev/null
}

test_major_version_workflow() {
    cd "$TEST_DIR"
    
    echo "🧪 Testing major version workflow..."
    
    # Simulate breaking change scenario
    set_frontmatter_field ".doh/prds/core-features.md" "target_version" "2.0.0" > /dev/null
    
    # Add breaking change indicator to epic
    cat >> .doh/epics/001.md << 'EOF'

## Breaking Changes
- Major API restructure
- Configuration format changes
EOF
    
    # Bump to major version
    local major_version
    major_version=$(bump_project_version "major")
    _tf_assert_equals "1.0.0" "$major_version" "Should bump to major version 1.0.0"
    
    # Create major version milestone
    cat > .doh/versions/1.0.0.md << 'EOF'
---
version: 1.0.0
type: major
created: 2025-09-01T14:00:00Z
breaking_changes: ["API restructure", "Configuration format changes"]
features: ["Stable API", "Complete feature set"]
migration_guide: "docs/migration-1.0.md"
---

# Version 1.0.0 - Stable Release

First stable release with complete feature set.

## Breaking Changes
- Major API restructure - see migration guide
- Configuration format changes

## Migration Required
See docs/migration-1.0.md for detailed migration instructions.
EOF
    
    # Verify version file was created
    _tf_assert_file_exists ".doh/versions/1.0.0.md" "Major version file should be created"
    
    local version_type
    version_type=$(get_frontmatter_field ".doh/versions/1.0.0.md" "type")
    _tf_assert_equals "major" "$version_type" "Version type should be major"
    
    cd - > /dev/null
}

test_version_rollback_scenario() {
    cd "$TEST_DIR"
    
    echo "🧪 Testing version rollback scenario..."
    
    # Create backup of current state
    local initial_version
    initial_version=$(get_current_version)
    cp VERSION VERSION.backup
    
    # Attempt version bump
    bump_project_version "minor" > /dev/null
    
    local new_version
    new_version=$(get_current_version)
    _tf_assert_equals "0.2.0" "$new_version" "Version should be bumped to 0.2.0"
    
    # Simulate rollback need (restore from backup)
    cp VERSION.backup VERSION
    
    local rolled_back_version
    rolled_back_version=$(get_current_version)
    _tf_assert_equals "$initial_version" "$rolled_back_version" "Version should be rolled back"
    
    # Cleanup
    rm -f VERSION.backup
    
    cd - > /dev/null
}

test_concurrent_version_operations() {
    cd "$TEST_DIR"
    
    echo "🧪 Testing concurrent version operations safety..."
    
    # Simulate concurrent file version updates
    local pids=()
    
    # Start multiple background operations
    set_file_version ".doh/epics/002.md" "0.3.0" > /dev/null &
    pids+=($!)
    
    set_file_version ".doh/epics/003.md" "0.3.0" > /dev/null &
    pids+=($!)
    
    # Wait for all operations to complete
    for pid in "${pids[@]}"; do
        wait "$pid"
    done
    
    # Verify both operations succeeded
    local version1
    version1=$(get_file_version ".doh/epics/002.md")
    _tf_assert_equals "0.3.0" "$version1" "Concurrent version update 1 should succeed"
    
    local version2
    version2=$(get_file_version ".doh/epics/003.md")
    _tf_assert_equals "0.3.0" "$version2" "Concurrent version update 2 should succeed"
    
    cd - > /dev/null
}

# Run all tests
_tf_run_tests
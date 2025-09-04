#!/bin/bash

# DOH Version Workflow Integration Test Suite
# Tests complete version workflows and command integrations

# Load test framework
source "$(dirname "$0")/../helpers/test_framework.sh" 2>/dev/null || source "../helpers/test_framework.sh" 2>/dev/null || source "tests/helpers/test_framework.sh"

# Load version management libraries
source ".claude/scripts/doh/lib/dohenv.sh"
source ".claude/scripts/doh/lib/version.sh"
source ".claude/scripts/doh/lib/frontmatter.sh"

_tf_setup() {
    # Create temporary test environment
    TEST_DIR=$(mktemp -d)
    echo "DEBUG: TEST_DIR = $TEST_DIR"
    
    # Load fixtures
    source "$(dirname "${BASH_SOURCE[0]}")/../helpers/doh_fixtures.sh"
    
    # Set up environment to point to temp directory
    export DOH_PROJECT_DIR="$TEST_DIR/.doh"
    echo "DEBUG: DOH_PROJECT_DIR = $DOH_PROJECT_DIR"
    echo "DEBUG: Creating minimal DOH project in $TEST_DIR"
    _tff_create_minimal_doh_project
    
    # Initialize git repo and set version
    ( 
        echo "$TEST_DIR" 
        echo $DOH_VERSION_FILE
        cd "$TEST_DIR" 
        mkdir -p .git
        local version_file=$(doh_version_file)
        echo "DEBUG: version_file = '$version_file'"
        echo "DEBUG: Creating version file directory $(dirname "$version_file")"
        mkdir -p "$(dirname "$version_file")"
        echo "0.1.0" > "$version_file"
        echo "DEBUG: version_file exists? $(test -f "$version_file" && echo "YES" || echo "NO")"
        
    )
    
    # Create initial version file
    echo "DEBUG: Creating $TEST_DIR/.doh/versions/0.1.0.md"
    mkdir -p "$TEST_DIR/.doh/versions"
    echo "DEBUG: $TEST_DIR/.doh/versions directory exists? $(test -d "$TEST_DIR/.doh/versions" && echo "YES" || echo "NO")"
    cat > "$TEST_DIR/.doh/versions/0.1.0.md" << 'EOF'
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
    echo "DEBUG: Creating $TEST_DIR/.doh/prds/core-features.md"
    mkdir -p "$TEST_DIR/.doh/prds"
    echo "DEBUG: $TEST_DIR/.doh/prds directory exists? $(test -d "$TEST_DIR/.doh/prds" && echo "YES" || echo "NO")"
    cat > "$TEST_DIR/.doh/prds/core-features.md" << 'EOF'
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
    echo "DEBUG: Creating $TEST_DIR/.doh/epics/001.md"
    mkdir -p "$TEST_DIR/.doh/epics"
    echo "DEBUG: $TEST_DIR/.doh/epics directory exists? $(test -d "$TEST_DIR/.doh/epics" && echo "YES" || echo "NO")"
    cat > "$TEST_DIR/.doh/epics/001.md" << 'EOF'
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
    echo "DEBUG: Creating $TEST_DIR/.doh/epics/002.md"
    cat > "$TEST_DIR/.doh/epics/002.md" << 'EOF'
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
    
    echo "DEBUG: Creating $TEST_DIR/.doh/epics/003.md"
    cat > "$TEST_DIR/.doh/epics/003.md" << 'EOF'
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
    
}

_tf_teardown() {
    
    # Cleanup test directory
    if [[ -n "$TEST_DIR" && -d "$TEST_DIR" ]]; then
        rm -rf "$TEST_DIR"
    fi
}

test_version_release_workflow() {
    echo "🧪 Testing complete version release workflow..."
    
    # Step 1: Validate current project state
    local current_version
    current_version=$(version_get_current)
    _tf_assert_equals "Initial version should be 0.1.0" "0.1.0" "$current_version"
    
    # Step 2: Complete tasks (mark as completed)
    local doh_dir=$(doh_project_dir)
    frontmatter_update_field "$doh_dir/epics/002.md" "status" "completed" > /dev/null
    frontmatter_update_field "$doh_dir/epics/003.md" "status" "completed" > /dev/null
    
    # Step 3: Check epic readiness for version bump
    local epic_status
    epic_status=$(frontmatter_get_field "$doh_dir/epics/001.md" "status")
    _tf_assert_equals "Epic should still be in progress" "in_progress" "$epic_status"
    
    # Step 4: Bump project version (minor release)
    local new_version
    new_version=$(version_bump_current "minor")
    _tf_assert_equals "Should bump to target version 0.2.0" "0.2.0" "$new_version"
    
    # Step 5: Create version milestone file
    echo "DEBUG: Creating $TEST_DIR/.doh/versions/0.2.0.md"
    cat > "$TEST_DIR/.doh/versions/0.2.0.md" << 'EOF'
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
    version_set_file "$doh_dir/prds/core-features.md" "$new_version" > /dev/null
    version_set_file "$doh_dir/epics/001.md" "$new_version" > /dev/null
    version_set_file "$doh_dir/epics/002.md" "$new_version" > /dev/null
    version_set_file "$doh_dir/epics/003.md" "$new_version" > /dev/null
    
    # Step 7: Verify all files have consistent versions
    local prd_version
    prd_version=$(version_get_file "$doh_dir/prds/core-features.md")
    _tf_assert_equals "PRD version should be updated" "$new_version" "$prd_version"
    
    local epic_version
    epic_version=$(version_get_file "$doh_dir/epics/001.md")
    _tf_assert_equals "Epic version should be updated" "$new_version" "$epic_version"
    
    # Step 8: Mark epic as completed
    frontmatter_update_field "$doh_dir/epics/001.md" "status" "completed" > /dev/null
    
    # Step 9: Verify no version inconsistencies
    local inconsistencies
    inconsistencies=$(find_version_inconsistencies 2>/dev/null || echo "")
    _tf_assert_equals "Should have no version inconsistencies after release" "" "$inconsistencies"
}

test_version_hierarchy_inheritance() {
    echo "🧪 Testing version hierarchy inheritance..."
    
    # Test PRD -> Epic -> Task version inheritance
    local doh_dir=$(doh_project_dir)
    local prd_target
    prd_target=$(frontmatter_get_field "$doh_dir/prds/core-features.md" "target_version")
    _tf_assert_equals "PRD should have target version 1.0.0" "1.0.0" "$prd_target"
    
    local epic_target
    epic_target=$(frontmatter_get_field "$doh_dir/epics/001.md" "target_version")
    _tf_assert_equals "Epic should have its own target version" "0.2.0" "$epic_target"
    
    local task_target
    task_target=$(frontmatter_get_field "$doh_dir/epics/002.md" "target_version")
    _tf_assert_equals "Task should inherit epic target version" "0.2.0" "$task_target"
}

test_version_dependency_tracking() {
    echo "🧪 Testing version dependency tracking..."
    
    # Check task dependencies
    local doh_dir=$(doh_project_dir)
    local task_deps
    task_deps=$(frontmatter_get_field "$doh_dir/epics/003.md" "depends_on")
    echo "$task_deps" | grep -q "002"
    _tf_assert_equals "Task 003 should depend on task 002" 0 $?
    
    # Verify dependency versions are consistent
    local dep_version
    dep_version=$(version_get_file "$doh_dir/epics/002.md")
    local dependent_version
    dependent_version=$(version_get_file "$doh_dir/epics/003.md")
    
    _tf_assert_equals "Dependent tasks should have consistent versions" "$dep_version" "$dependent_version"
}

test_major_version_workflow() {
    echo "🧪 Testing major version workflow..."
    
    # Simulate breaking change scenario
    local doh_dir=$(doh_project_dir)
    frontmatter_update_field "$doh_dir/prds/core-features.md" "target_version" "2.0.0" > /dev/null
    
    # Add breaking change indicator to epic
    cat >> "$TEST_DIR/.doh/epics/001.md" << 'EOF'

## Breaking Changes
- Major API restructure
- Configuration format changes
EOF
    
    # Bump to major version
    local major_version
    major_version=$(version_bump_current "major")
    _tf_assert_equals "Should bump to major version 1.0.0" "1.0.0" "$major_version"
    
    # Create major version milestone
    echo "DEBUG: Creating $TEST_DIR/.doh/versions/1.0.0.md"
    cat > "$TEST_DIR/.doh/versions/1.0.0.md" << 'EOF'
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
    _tf_assert_file_exists "Major version file should be created" "$TEST_DIR/.doh/versions/1.0.0.md"
    
    local version_type
    version_type=$(frontmatter_get_field "$TEST_DIR/.doh/versions/1.0.0.md" "type")
    _tf_assert_equals "Version type should be major" "major" "$version_type"
}


test_concurrent_version_operations() {
    echo "🧪 Testing concurrent version operations safety..."
    
    # Simulate concurrent file version updates
    local doh_dir=$(doh_project_dir)
    local pids=()
    
    # Start multiple background operations
    version_set_file "$doh_dir/epics/002.md" "0.3.0" > /dev/null &
    pids+=($!)
    
    version_set_file "$doh_dir/epics/003.md" "0.3.0" > /dev/null &
    pids+=($!)
    
    # Wait for all operations to complete
    for pid in "${pids[@]}"; do
        wait "$pid"
    done
    
    # Verify both operations succeeded
    local version1
    version1=$(version_get_file "$doh_dir/epics/002.md")
    _tf_assert_equals "Concurrent version update 1 should succeed" "0.3.0" "$version1"
    
    local version2
    version2=$(version_get_file "$doh_dir/epics/003.md")
    _tf_assert_equals "Concurrent version update 2 should succeed" "0.3.0" "$version2"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
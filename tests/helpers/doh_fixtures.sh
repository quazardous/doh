#!/bin/bash
# DOH Test Fixtures Helper
# Provides functions to create DOH project structures for testing
# File version: 0.1.0 | Created: 2025-09-02

# Guard against multiple sourcing
[[ -n "${DOH_TEST_FIXTURES_LOADED:-}" ]] && return 0
DOH_TEST_FIXTURES_LOADED=1

# Source DOH library for path functions
source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/doh.sh"

# Copy skeleton project to test container directory
# @arg $1 string Skeleton name (minimal, helper-test, sample, version-test, cache-test)  
# @stdout Path to the container directory
# @exitcode 0 If successful
# @exitcode 1 If copy fails
_tff_copy_skeleton() {
    local skeleton_name="$1"
    
    if [[ -z "$skeleton_name" ]]; then
        echo "Error: Skeleton name required" >&2
        return 1
    fi
    
    # Use test framework function to get container directory
    local container_dir
    container_dir=$(_tf_test_container_dir) || return 1
    
    local skeleton_dir="$(dirname "${BASH_SOURCE[0]}")/../fixtures/skl/$skeleton_name"
    
    if [[ ! -d "$skeleton_dir" ]]; then
        echo "Error: Skeleton '$skeleton_name' not found at $skeleton_dir" >&2
        return 1
    fi
    
    # Copy entire skeleton structure directly
    # Now skeleton structure matches target structure:
    # skeleton/VERSION → container/VERSION
    # skeleton/project_doh/ → container/project_doh/ 
    # skeleton/global_doh/ → container/global_doh/ (if exists)
    # skeleton/.git/ → container/.git/
    cp -r "$skeleton_dir"/* "$container_dir/" || return 1
    
    echo "$container_dir"
}

# Create a minimal DOH project structure using doh_project_dir()
# @stdout Path to the container directory
# @exitcode 0 If successful
# @exitcode 1 If directory creation fails
_tff_create_minimal_doh_project() {
    # Use DOH library function to get project directory
    local doh_dir=$(doh_project_dir)
    
    # DOH_PROJECT_DIR points to the .doh directory itself
    # Container directory is the parent directory
    local container_dir="$(dirname "$doh_dir")"
    
    # Copy minimal skeleton
    _tff_copy_skeleton "minimal" "$container_dir" || return 1
    
    echo "$container_dir"
}

# Create a DOH project with sample epics and tasks using doh_project_dir()
# @stdout Path to the project directory
# @exitcode 0 If successful
# @exitcode 1 If directory creation fails
_tff_create_sample_doh_project() {
    # Use DOH library function to get project directory
    local project_dir=$(doh_project_dir)
    
    # First create the minimal structure
    _tff_create_minimal_doh_project || return 1
    
    # Add sample epic
    local epic_dir="$project_dir/epics/test-epic"
    mkdir -p "$epic_dir"
    
    # Create epic.md with frontmatter
    cat > "$epic_dir/epic.md" << 'EOF'
---
epic_number: "001"
name: Test Epic
status: in_progress
file_version: 0.1.0
---
# Test Epic

This is a test epic for unit tests.
EOF
    
    # Create a sample task
    cat > "$epic_dir/002.md" << 'EOF'
---
task_number: "002"
parent: "001"
name: Test Task
status: pending
file_version: 0.1.0
---
# Test Task

This is a test task for unit tests.
EOF
    
    echo "$project_dir"
}

# Create a DOH project for version testing using doh_project_dir()
# @stdout Path to the project directory
# @exitcode 0 If successful
# @exitcode 1 If directory creation fails
_tff_create_version_test_project() {
    # Use DOH library function to get project directory
    local project_dir=$(doh_project_dir)
    
    # Create minimal structure
    _tff_create_minimal_doh_project || return 1
    
    # Set specific version (container directory is parent of project_dir)
    local container_dir="$(dirname "$project_dir")"
    local version_file=$(doh_version_file)
    echo "0.1.0" > "$version_file"
    
    # Create files with version fields
    mkdir -p "$project_dir/epics/versioned"
    
    cat > "$project_dir/epics/versioned/001.md" << 'EOF'
---
epic_number: "001"
name: Versioned Epic
file_version: 0.1.0
target_version: 0.2.0
---
# Versioned Epic
EOF
    
    cat > "$project_dir/epics/versioned/002.md" << 'EOF'
---
task_number: "002"
parent: "001"
name: Versioned Task
file_version: 0.1.0
---
# Versioned Task
EOF
    
    # Create file without version (for testing find_missing_version)
    cat > "$project_dir/epics/versioned/003.md" << 'EOF'
---
task_number: "003"
parent: "001"
name: Unversioned Task
---
# Unversioned Task
EOF
    
    echo "$project_dir"
}

# Create a DOH project for cache testing using doh_project_dir()
# @stdout Path to the project directory
# @exitcode 0 If successful
# @exitcode 1 If directory creation fails
_tff_create_cache_test_project() {
    # Use DOH library function to get project directory
    local project_dir=$(doh_project_dir)
    
    # Create minimal structure
    _tff_create_minimal_doh_project || return 1
    
    # Create epic structure for cache testing
    mkdir -p "$project_dir/epics/user-auth"
    
    cat > "$project_dir/epics/user-auth/epic.md" << 'EOF'
---
epic_number: "001"
name: User Authentication
status: in_progress
---
# User Authentication Epic
EOF
    
    cat > "$project_dir/epics/user-auth/002.md" << 'EOF'
---
task_number: "002"
parent: "001"
epic: user-auth
name: Login Implementation
status: completed
---
# Login Implementation
EOF
    
    cat > "$project_dir/epics/user-auth/004.md" << 'EOF'
---
task_number: "004"
parent: "001"
epic: user-auth
name: Logout Implementation
status: pending
---
# Logout Implementation
EOF
    
    echo "$project_dir"
}

# Create a DOH project for helper testing (PRD, epic, etc.) using doh_project_dir()
# @stdout Path to the container directory
# @exitcode 0 If successful
# @exitcode 1 If directory creation fails
_tff_create_helper_test_project() {
    # Use DOH library function to get project directory
    local doh_dir=$(doh_project_dir)
    
    # DOH_PROJECT_DIR points to the .doh directory itself
    # Container directory is the parent directory
    local container_dir="$(dirname "$doh_dir")"
    
    # Copy helper-test skeleton
    _tff_copy_skeleton "helper-test" "$container_dir" || return 1
    
    echo "$container_dir"
}

# Create workspace environment for testing helper functions
# @arg $1 string Project name (defaults to test_project_RANDOM)
# @exitcode 0 If successful
# @exitcode 1 If setup fails
_tff_setup_workspace_for_helpers() {
    local project_name="${1:-test_project_$(basename "${DOH_PROJECT_DIR}")}"
    
    export TEST_PROJECT_NAME="$project_name"
    
    # Override workspace function for testing
    workspace_get_current_project_id() {
        echo "$TEST_PROJECT_NAME"
    }
    
    # Export the override function
    export -f workspace_get_current_project_id
    
    return 0
}

# Export functions for use in tests
export -f _tff_copy_skeleton
export -f _tff_create_minimal_doh_project
export -f _tff_create_sample_doh_project
export -f _tff_create_version_test_project
export -f _tff_create_cache_test_project
export -f _tff_create_helper_test_project
export -f _tff_setup_workspace_for_helpers
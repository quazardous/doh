#!/bin/bash
# DOH Test Fixtures Helper
# Provides functions to create DOH project structures for testing
# File version: 0.1.0 | Created: 2025-09-02

# Guard against multiple sourcing
[[ -n "${DOH_TEST_FIXTURES_LOADED:-}" ]] && return 0
DOH_TEST_FIXTURES_LOADED=1

# Create a minimal DOH project structure in the given directory
# @arg $1 string Directory where to create the .doh structure (defaults to DOH_PROJECT_DIR)
# @stdout Path to the project directory
# @exitcode 0 If successful
# @exitcode 1 If directory creation fails
_tff_create_minimal_doh_project() {
    local doh_dir="${1:-${DOH_PROJECT_DIR:-}}"
    
    if [[ -z "$doh_dir" ]]; then
        echo "Error: No DOH directory specified" >&2
        return 1
    fi
    
    # DOH_PROJECT_DIR points to the .doh directory itself
    # Project root is the parent directory
    local project_root="$(dirname "$doh_dir")"
    
    # Create basic DOH structure
    mkdir -p "$doh_dir/epics" || return 1
    mkdir -p "$doh_dir/prds" || return 1
    mkdir -p "$doh_dir/quick" || return 1
    
    # Create a minimal VERSION file in project root
    echo "0.1.0" > "$project_root/VERSION"
    
    # Create .git directory in project root to satisfy doh_project_dir requirements
    mkdir -p "$project_root/.git"
    
    echo "$project_root"
}

# Create a DOH project with sample epics and tasks
# @arg $1 string Directory where to create the .doh structure (defaults to DOH_PROJECT_DIR)
# @stdout Path to the project directory
# @exitcode 0 If successful
# @exitcode 1 If directory creation fails
_tff_create_sample_doh_project() {
    local project_dir="${1:-${DOH_PROJECT_DIR:-}}"
    
    # First create the minimal structure
    _tff_create_minimal_doh_project "$project_dir" || return 1
    
    # Add sample epic
    local epic_dir="$project_dir/.doh/epics/test-epic"
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

# Create a DOH project for version testing
# @arg $1 string Directory where to create the .doh structure (defaults to DOH_PROJECT_DIR)
# @stdout Path to the project directory
# @exitcode 0 If successful
# @exitcode 1 If directory creation fails
_tff_create_version_test_project() {
    local project_dir="${1:-${DOH_PROJECT_DIR:-}}"
    
    # Create minimal structure
    _tff_create_minimal_doh_project "$project_dir" || return 1
    
    # Set specific version
    echo "0.1.0" > "$project_dir/VERSION"
    
    # Create files with version fields
    mkdir -p "$project_dir/.doh/epics/versioned"
    
    cat > "$project_dir/.doh/epics/versioned/001.md" << 'EOF'
---
epic_number: "001"
name: Versioned Epic
file_version: 0.1.0
target_version: 0.2.0
---
# Versioned Epic
EOF
    
    cat > "$project_dir/.doh/epics/versioned/002.md" << 'EOF'
---
task_number: "002"
parent: "001"
name: Versioned Task
file_version: 0.1.0
---
# Versioned Task
EOF
    
    # Create file without version (for testing find_missing_version)
    cat > "$project_dir/.doh/epics/versioned/003.md" << 'EOF'
---
task_number: "003"
parent: "001"
name: Unversioned Task
---
# Unversioned Task
EOF
    
    echo "$project_dir"
}

# Create a DOH project for cache testing
# @arg $1 string Directory where to create the .doh structure (defaults to DOH_PROJECT_DIR)
# @stdout Path to the project directory
# @exitcode 0 If successful
# @exitcode 1 If directory creation fails
_tff_create_cache_test_project() {
    local project_dir="${1:-${DOH_PROJECT_DIR:-}}"
    
    # Create minimal structure
    _tff_create_minimal_doh_project "$project_dir" || return 1
    
    # Create epic structure for cache testing
    mkdir -p "$project_dir/.doh/epics/user-auth"
    
    cat > "$project_dir/.doh/epics/user-auth/epic.md" << 'EOF'
---
epic_number: "001"
name: User Authentication
status: in_progress
---
# User Authentication Epic
EOF
    
    cat > "$project_dir/.doh/epics/user-auth/002.md" << 'EOF'
---
task_number: "002"
parent: "001"
epic: user-auth
name: Login Implementation
status: completed
---
# Login Implementation
EOF
    
    cat > "$project_dir/.doh/epics/user-auth/004.md" << 'EOF'
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

# Export functions for use in tests
export -f _tff_create_minimal_doh_project
export -f _tff_create_sample_doh_project
export -f _tff_create_version_test_project
export -f _tff_create_cache_test_project
#!/bin/bash

# DOH Core Library
# Foundational library with zero dependencies
# Provides essential functions needed by all other DOH libraries

# Guard against multiple sourcing
[[ -n "${DOH_LIB_CORE_LOADED:-}" ]] && return 0
DOH_LIB_CORE_LOADED=1

# @description Get DOH global directory with fallback
# @public  
# @stdout DOH global directory path
# @exitcode 0 Always successful
doh_global_dir() {
    echo "${DOH_GLOBAL_DIR:-$HOME/.doh}"
}

# @description Get DOH project .doh directory path
# @public
# @stdout Path to DOH project .doh directory
# @stderr Error message if not in DOH project
# @exitcode 0 If successful
# @exitcode 1 If not in DOH project
doh_project_dir() {
    # If DOH_PROJECT_DIR is set, it should point directly to the .doh directory
    if [[ -n "${DOH_PROJECT_DIR:-}" ]]; then
        if [[ -d "$(dirname "$DOH_PROJECT_DIR")" ]]; then
            echo "$DOH_PROJECT_DIR"
            return 0
        else
            echo "❌ Error: Parent directory of DOH_PROJECT_DIR ('$DOH_PROJECT_DIR') not found" >&2
            return 1
        fi
    fi
    
    # Otherwise, default to project root/.doh without trying to be smart
    local project_root
    project_root="$(doh_project_root)"
    echo "$project_root/.doh"
}

# @description Get current project ID based on directory
# @public
# @stdout Unique project ID: basename + short hash of absolute path
# @exitcode 0 If successful
# @exitcode 1 If unable to find DOH root
doh_project_id() {
    # Allow override via environment variable
    if [[ -n "${DOH_PROJECT_ID:-}" ]]; then
        echo "$DOH_PROJECT_ID"
        return 0
    fi
    
    local project_root
    project_root="$(doh_project_root)" || return 1
    
    local project_name=$(basename "$project_root")
    local abs_path=$(realpath "$project_root")
    local path_hash=$(echo "$abs_path" | sha256sum | cut -c1-8)
    
    echo "${project_name}_${path_hash}"
}

# @description Get DOH project root (relative to library location)
# @public
# @stdout Path to DOH project root
# @stderr No error output
# @exitcode 0 Always successful
doh_project_root() {
    # Library is at .claude/scripts/doh/lib/doh.sh
    # Project root is ../../../.. from library location
    dirname "$(dirname "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")")"
}

# @description Check if we're in a valid DOH project
# @public
# @stdout No output
# @stderr Error message if not in DOH project
# @exitcode 0 If in DOH project
# @exitcode 1 If not in DOH project
doh_validate_project() {
    doh_project_root >/dev/null 2>&1
}

# @description Get DOH project root or exit with error
# @public
# @stdout Path to DOH project root
# @stderr Error message and exit if not in DOH project
# @exitcode 0 If successful
# @exitcode 1 If not in DOH project (exits)
doh_require_project() {
    local root
    root=$(doh_project_root) || exit 1
    echo "$root"
}

# @description Get the DOH version file path
# @public
# @stdout Path to VERSION file
# @stderr Error message if not in DOH project (production mode only)
# @exitcode 0 If successful
# @exitcode 1 If not in DOH project (production mode only)
doh_version_file() {
    echo "${DOH_VERSION_FILE:-$(doh_project_root)/VERSION}"
}
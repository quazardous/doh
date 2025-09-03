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
    echo "${GLOBAL_DOH_DIR:-$HOME/.doh}"
}

# @description Get DOH project .doh directory path
# @public
# @stdout Path to DOH project .doh directory
# @stderr Error message if not in DOH project
# @exitcode 0 If successful
# @exitcode 1 If not in DOH project
doh_project_dir() {
    # If PROJECT_DOH_DIR is set, it should point directly to the .doh directory
    if [[ -n "${PROJECT_DOH_DIR:-}" ]]; then
        if [[ -d "$PROJECT_DOH_DIR" ]]; then
            echo "$PROJECT_DOH_DIR"
            return 0
        else
            echo "❌ Error: PROJECT_DOH_DIR set to '$PROJECT_DOH_DIR' but directory not found" >&2
            return 1
        fi
    fi
    
    # Otherwise, search up the directory tree from current location
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/.git" && -d "$dir/.doh" ]]; then
            echo "$dir/.doh"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    echo "❌ Error: Not in a DOH project (no .doh/ directory at git repo root)" >&2
    echo "Initialize DOH project with: /doh:init" >&2
    return 1
}

# @description Get DOH project root (relative to library location)
# @public
# @stdout Path to DOH project root
# @stderr No error output
# @exitcode 0 Always successful
doh_project_root() {
    # Library is at .claude/scripts/doh/lib/doh.sh
    # Project root is ../../.. from library location
    dirname "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")"
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
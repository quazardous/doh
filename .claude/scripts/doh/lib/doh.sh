#!/bin/bash

# DOH Core Library
# Foundational library with zero dependencies
# Provides essential functions needed by all other DOH libraries

# Guard against multiple sourcing
[[ -n "${DOH_LIB_CORE_LOADED:-}" ]] && return 0
DOH_LIB_CORE_LOADED=1

# @description Find DOH project root (directory containing both .git/ and .doh/)
# @public
# @stdout Path to DOH project root
# @stderr Error message if not in DOH project
# @exitcode 0 If successful
# @exitcode 1 If not in DOH project
doh_find_root() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/.git" && -d "$dir/.doh" ]]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    echo "❌ Error: Not in a DOH project (no .doh/ directory at git repo root)" >&2
    echo "Initialize DOH project with: /doh:init" >&2
    return 1
}

# @description Check if we're in a valid DOH project
# @public
# @stdout No output
# @stderr Error message if not in DOH project
# @exitcode 0 If in DOH project
# @exitcode 1 If not in DOH project
doh_validate_project() {
    doh_find_root >/dev/null 2>&1
}

# @description Get DOH project root or exit with error
# @public
# @stdout Path to DOH project root
# @stderr Error message and exit if not in DOH project
# @exitcode 0 If successful
# @exitcode 1 If not in DOH project (exits)
doh_require_project() {
    local root
    root=$(doh_find_root) || exit 1
    echo "$root"
}
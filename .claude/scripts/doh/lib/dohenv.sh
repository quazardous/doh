#!/bin/bash

# DOH Environment Variables Loader (dotenv for DOH)
# Usage: source .claude/scripts/doh/lib/dohenv.sh
# Simply loads .doh/env if it exists and exports DOH_ variables
# IMPORTANT: should only be sourced by shell scripts (not libraries)

# Guard against multiple sourcing
if [[ -n "${DOH_ENV_LOADED:-}" ]]; then
    return 0
fi

# @description Find DOH project root (directory containing both .git/ and .doh/)
# @internal
# @stdout Path to DOH project root
# @stderr Error message if not in DOH project
# @exitcode 0 If successful
# @exitcode 1 If not in DOH project
_find_doh_root() {
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

# @description Load environment variables from .doh/env
# @internal
# @stdout No output
# @stderr Error messages if loading fails
# @exitcode 0 If successful
# @exitcode 1 If error condition
_load_doh_env() {
    local doh_root
    doh_root="$(_find_doh_root)" || return 1
    
    # Set default values
    export DOH_GLOBAL_DIR="${DOH_GLOBAL_DIR:-$HOME/.doh}"
    
    # Load custom config from .doh/env if it exists
    local env_file="$doh_root/.doh/env"
    if [[ -f "$env_file" ]]; then
        while IFS='=' read -r key value; do
            # Skip comments and empty lines
            [[ "$key" =~ ^[[:space:]]*# ]] && continue
            [[ -z "$key" ]] && continue
            
            # Only process DOH_ variables
            if [[ "$key" =~ ^DOH_[A-Z_]+$ ]]; then
                # Remove quotes if present
                value="${value%\"}"
                value="${value#\"}"
                value="${value%\'}"
                value="${value#\'}"
                
                # Expand ~ to $HOME
                if [[ "$value" =~ ^~/ ]]; then
                    value="$HOME/${value#~/}"
                fi
                
                export "$key=$value"
            fi
        done < "$env_file"
    fi
    
    # Mark environment as loaded
    export DOH_ENV_LOADED=1
}

# Initialize
_load_doh_env

# Cleanup
unset -f _load_doh_env
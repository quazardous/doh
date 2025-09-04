#!/bin/bash

# DOH Environment Variables Library
# Pure library for DOH environment management (no automatic execution)
# Usage: source .claude/scripts/doh/lib/dohenv.sh && dohenv_load

# Source core library dependency
source "$(dirname "${BASH_SOURCE[0]}")/doh.sh"

# Guard against multiple sourcing
[[ -n "${DOH_LIB_DOHENV_LOADED:-}" ]] && return 0
DOH_LIB_DOHENV_LOADED=1

# @description Load environment variables from DOH project env file
# @public
# @stdout No output
# @stderr Error messages if loading fails
# @exitcode 0 If successful  
# @exitcode 1 If error condition
# 
# Environment variable priority (highest to lowest):
# 1. Existing environment variables (export DOH_VAR=value)
# 2. {doh_dir}/env file (project-specific configuration) 
# 3. Default values (built-in fallbacks)
dohenv_load() {
    local doh_dir
    doh_dir="$(doh_project_dir)" || return 1
    
    # Load custom config from env file if it exists
    local env_file="$doh_dir/env"
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
                
                # Only set if not already defined (respect existing env vars)
                if [[ -z "${!key:-}" ]]; then
                    export "$key=$value"
                fi
            fi
        done < "$env_file"
    fi

    # DOH_GLOBAL_DIR will not be set if not defined -> we use $(doh_global_dir) that can set the default
    ## export DOH_GLOBAL_DIR="${DOH_GLOBAL_DIR:-$HOME/.doh}"
    
    # Mark environment as loaded
    export DOH_ENV_LOADED=1
}

# @description Check if DOH environment has been loaded
# @public
# @stdout No output
# @stderr No output
# @exitcode 0 If environment is loaded
# @exitcode 1 If environment is not loaded
dohenv_is_loaded() {
    [[ -n "${DOH_ENV_LOADED:-}" ]]
}

# @description Get DOH environment variable with fallback
# @public
# @arg $1 Variable name (without DOH_ prefix)
# @arg $2 Default value if variable is not set
# @stdout Variable value or default
# @stderr No output
# @exitcode 0 Always successful
dohenv_get() {
    local var_name="DOH_$1"
    local default_value="$2"
    echo "${!var_name:-$default_value}"
}

# @description Internal helper to parse env file line
# @private
# @arg $1 Line to parse
# @stdout No output
# @stderr No output
# @exitcode 0 If successful
_dohenv_parse_line() {
    local line="$1"
    # Implementation details for parsing DOH env lines
    # This would be used internally by dohenv_load
}
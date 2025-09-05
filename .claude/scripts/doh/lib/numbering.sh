#!/bin/bash

# DOH Numbering Library
# Pure library for DOH numbering system (no automatic execution)
# Provides centralized, conflict-free task and epic number generation

# Source core library dependencies
source "$(dirname "${BASH_SOURCE[0]}")/doh.sh"

# Guard against multiple sourcing
[[ -n "${DOH_LIB_NUMBERING_LOADED:-}" ]] && return 0
DOH_LIB_NUMBERING_LOADED=1

# Constants
readonly NUMBERING_VERSION="1.0.0"
readonly NUMBER_FORMAT="%.3d"
readonly LOCK_TIMEOUT=10
readonly QUICK_RESERVED_NUMBER="000"

# @description Registry structure validation
# @arg $1 string Path to the registry file to validate
# @exitcode 0 If valid
# @exitcode 1 If invalid
_numbering_validate_registry_structure() {
    local registry_file="$1"
    
    if [[ ! -f "$registry_file" ]]; then
        return 1
    fi
    
    # Check required top-level keys exist
    if ! jq -e '.file_cache' "$registry_file" >/dev/null 2>&1; then
        return 1
    fi
    
    if ! jq -e '.graph_cache' "$registry_file" >/dev/null 2>&1; then
        return 1
    fi
    
    # Check TASKSEQ file exists
    local taskseq_file="$(dirname "$registry_file")/TASKSEQ"
    if [[ ! -f "$taskseq_file" ]]; then
        return 1
    fi
    
    return 0
}

# @description Initialize empty registry structure
# @arg $1 string Path where to create the registry file
# @arg $2 string Project identifier for initialization
# @exitcode 0 On success
# @exitcode 1 On error
_numbering_create_empty_registry() {
    local registry_file="$1"
    local project_id="$2"
    
    # Create registry directory if it doesn't exist
    mkdir -p "$(dirname "$registry_file")"
    
    # Create initial registry (no global_sequence here)
    cat > "$registry_file" << EOF
{
  "file_cache": {
    "000": {
      "type": "epic",
      "path": "quick/manifest.md",
      "name": "QUICK"
    }
  },
  "graph_cache": {}
}
EOF
    
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to create registry file: $registry_file" >&2
        return 1
    fi
    
    # Initialize TASKSEQ file
    local taskseq_file="$(dirname "$registry_file")/TASKSEQ"
    echo "0" > "$taskseq_file" || {
        echo "Error: Failed to create TASKSEQ file: $taskseq_file" >&2
        return 1
    }
    
    return 0
}

# @description Get registry file path for current project
# @stdout Path to the current project's registry file
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If project ID cannot be determined
_numbering_get_registry_path() {
    local project_id
    project_id="$(doh_project_id)" || {
        echo "Error: Could not determine project ID" >&2
        return 1
    }
    
    local registry_dir="$(doh_global_dir)/projects/$project_id"
    echo "$registry_dir/registers.json"
}

# @description Ensure registry exists and is valid
# @stdout Path to the ensured registry file
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If registry cannot be created or validated
_numbering_ensure_registry() {
    local registry_file
    registry_file="$(_numbering_get_registry_path)" || return 1
    
    local project_id
    project_id="$(doh_project_id)" || return 1
    
    # Create registry if it doesn't exist
    if [[ ! -f "$registry_file" ]]; then
        _numbering_create_empty_registry "$registry_file" "$project_id" || return 1
    fi
    
    # Validate registry structure
    if ! _numbering_validate_registry_structure "$registry_file"; then
        echo "Error: Invalid registry structure in $registry_file" >&2
        return 1
    fi
    
    echo "$registry_file"
}

# @description Acquire exclusive file lock with timeout
# @arg $1 string File to lock
# @arg $2 string Optional timeout in seconds (default: LOCK_TIMEOUT)
# @stderr Error messages for timeout
# @exitcode 0 On success
# @exitcode 1 On timeout or error
_numbering_acquire_lock() {
    local lock_file="$1"
    local timeout="${2:-$LOCK_TIMEOUT}"
    
    # Ensure parent directory exists for lock file
    mkdir -p "$(dirname "$lock_file")"
    
    # Create lock file if it doesn't exist
    touch "$lock_file.lock" 2>/dev/null || {
        echo "Error: Cannot create lock file: $lock_file.lock" >&2
        return 1
    }
    
    # Try to acquire lock with timeout
    exec 200>"$lock_file.lock"
    flock -x -w "$timeout" 200 || {
        echo "Error: Could not acquire lock within ${timeout}s" >&2
        return 1
    }
    
    return 0
}

# @description Release file lock
# @exitcode 0 Always successful
_numbering_release_lock() {
    exec 200>&-
}

# @description Get TASKSEQ file path
# @stdout Path to the TASKSEQ file
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If project ID cannot be determined
_numbering_get_taskseq_path() {
    local registry_file
    registry_file="$(_numbering_get_registry_path)" || return 1
    
    echo "$(dirname "$registry_file")/TASKSEQ"
}

# @description Get next sequence number atomically
# @stdout Next sequence number
# @stderr Error messages for invalid sequence or update failures
# @exitcode 0 If successful
# @exitcode 1 If TASKSEQ file is invalid or update fails
_numbering_get_next_sequence() {
    local taskseq_file
    taskseq_file="$(_numbering_get_taskseq_path)" || return 1
    
    # Acquire lock for atomic read-increment-write
    _numbering_acquire_lock "$taskseq_file" || return 1
    
    local current_seq
    if [[ -f "$taskseq_file" ]]; then
        current_seq=$(cat "$taskseq_file" 2>/dev/null || echo "0")
    else
        current_seq="0"
    fi
    
    # Validate current sequence is a number
    if ! [[ "$current_seq" =~ ^[0-9]+$ ]]; then
        _numbering_release_lock
        echo "Error: Invalid TASKSEQ content: $current_seq" >&2
        return 1
    fi
    
    local next_seq=$((current_seq + 1))
    
    # Write new sequence
    echo "$next_seq" > "$taskseq_file" || {
        _numbering_release_lock
        echo "Error: Failed to update TASKSEQ file" >&2
        return 1
    }
    
    _numbering_release_lock
    echo "$next_seq"
}

# @description Get current sequence number (read-only)
# @stdout Current sequence number
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If project ID cannot be determined
numbering_get_current() {
    local taskseq_file
    taskseq_file="$(_numbering_get_taskseq_path)" || return 1
    
    if [[ -f "$taskseq_file" ]]; then
        cat "$taskseq_file" 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

# @description Get next available number from global sequence
# @arg $1 string Type of number ("epic" or "task")
# @stdout Zero-padded 3-digit number
# @stderr Error messages for invalid type or sequence failures
# @exitcode 0 If successful
# @exitcode 1 If invalid type or sequence generation fails
numbering_get_next() {
    local type="$1"  # "epic", "task", or "prd"
    
    if [[ "$type" != "epic" && "$type" != "task" && "$type" != "prd" ]]; then
        echo "Error: Invalid type '$type'. Must be 'epic', 'task', or 'prd'" >&2
        return 1
    fi
    
    # Simply get next sequence number - no need for complex gap management
    local next_number
    next_number="$(_numbering_get_next_sequence)" || return 1
    
    # Format as 3-digit zero-padded number
    printf "$NUMBER_FORMAT" "$next_number"
}

# @description Register epic in central registry
# @arg $1 string Epic number (3-digit format)
# @arg $2 string Relative path to epic file
# @arg $3 string Human-readable epic name
# @arg $4 string Optional JSON metadata object
# @stderr Error messages for missing parameters, lock failures, or registration errors
# @exitcode 0 On success
# @exitcode 1 On error
numbering_register_epic() {
    local number="$1"
    local path="$2" 
    local name="$3"
    local metadata="${4:-}"  # Optional JSON metadata
    
    if [[ -z "$number" || -z "$path" || -z "$name" ]]; then
        echo "Error: Missing required parameters for epic registration" >&2
        return 1
    fi
    
    local registry_file
    registry_file="$(_numbering_ensure_registry)" || return 1
    
    # Acquire lock for atomic operation
    _numbering_acquire_lock "$registry_file" || return 1
    
    # Check if number is already registered
    local existing_entry
    existing_entry=$(jq -r --arg num "$number" '.file_cache[$num]' "$registry_file")
    
    if [[ "$existing_entry" != "null" ]]; then
        _numbering_release_lock
        echo "Error: Number $number is already registered" >&2
        return 1
    fi
    
    # Register epic in file cache
    local temp_file=$(mktemp)
    local epic_data="{\"type\": \"epic\", \"path\": \"$path\", \"name\": \"$name\""
    
    # Add metadata if provided
    if [[ -n "$metadata" ]]; then
        epic_data="$epic_data, \"metadata\": $metadata"
    fi
    
    epic_data="$epic_data}"
    
    jq --arg num "$number" --argjson data "$epic_data" '.file_cache[$num] = $data' "$registry_file" > "$temp_file" && mv "$temp_file" "$registry_file"
    
    if [[ $? -ne 0 ]]; then
        _numbering_release_lock
        echo "Error: Failed to register epic $number" >&2
        return 1
    fi
    
    _numbering_release_lock
    return 0
}

# @description Register task in central registry
# @arg $1 string Task number (3-digit format)
# @arg $2 string Parent epic or task number
# @arg $3 string Relative path to task file
# @arg $4 string Human-readable task name
# @arg $5 string Optional epic name for grouping
# @arg $6 string Optional JSON metadata object
# @stderr Error messages for missing parameters, lock failures, or registration errors
# @exitcode 0 On success
# @exitcode 1 On error
numbering_register_task() {
    local number="$1"
    local parent_number="$2"  # Can be epic or task number
    local path="$3"
    local name="$4"
    local epic_name="${5:-}"
    local metadata="${6:-}"  # Optional JSON metadata
    
    if [[ -z "$number" || -z "$path" || -z "$name" ]]; then
        echo "Error: Missing required parameters for task registration" >&2
        return 1
    fi
    
    local registry_file
    registry_file="$(_numbering_ensure_registry)" || return 1
    
    # Acquire lock for atomic operation
    _numbering_acquire_lock "$registry_file" || return 1
    
    # Check if number is already registered
    local existing_entry
    existing_entry=$(jq -r --arg num "$number" '.file_cache[$num]' "$registry_file")
    
    if [[ "$existing_entry" != "null" ]]; then
        _numbering_release_lock
        echo "Error: Number $number is already registered" >&2
        return 1
    fi
    
    # Register task in file cache
    local temp_file=$(mktemp)
    local task_data="{\"type\": \"task\", \"path\": \"$path\", \"name\": \"$name\""
    
    # Add epic name if provided
    if [[ -n "$epic_name" ]]; then
        task_data="$task_data, \"epic\": \"$epic_name\""
    fi
    
    # Add metadata if provided
    if [[ -n "$metadata" ]]; then
        task_data="$task_data, \"metadata\": $metadata"
    fi
    
    task_data="$task_data}"
    
    jq --arg num "$number" --argjson data "$task_data" '.file_cache[$num] = $data' "$registry_file" > "$temp_file" && mv "$temp_file" "$registry_file"
    
    if [[ $? -ne 0 ]]; then
        _numbering_release_lock
        echo "Error: Failed to register task $number in file cache" >&2
        return 1
    fi
    
    # Register parent relationship in graph cache if parent provided
    if [[ -n "$parent_number" ]]; then
        local graph_data="{\"parent\": \"$parent_number\""
        
        if [[ -n "$epic_name" ]]; then
            graph_data="$graph_data, \"epic\": \"$epic_name\""
        fi
        
        graph_data="$graph_data}"
        
        jq --arg num "$number" --argjson data "$graph_data" '.graph_cache[$num] = $data' "$registry_file" > "$temp_file" && mv "$temp_file" "$registry_file"
        
        if [[ $? -ne 0 ]]; then
            _numbering_release_lock
            echo "Error: Failed to register task $number in graph cache" >&2
            return 1
        fi
    fi
    
    _numbering_release_lock
    return 0
}

# @description Validate number availability
# @arg $1 string Number to validate
# @arg $2 string Type of number ("epic" or "task")
# @stderr Error messages for missing parameters, already used numbers, invalid format, or reserved numbers
# @exitcode 0 If available
# @exitcode 1 If unavailable or invalid
numbering_validate() {
    local number="$1"
    local type="$2"  # "epic" or "task"
    
    if [[ -z "$number" || -z "$type" ]]; then
        echo "Error: Missing required parameters for validation" >&2
        return 1
    fi
    
    local registry_file
    registry_file="$(_numbering_ensure_registry)" || return 1
    
    # Check if number exists in registry
    local existing_entry
    existing_entry=$(jq -r --arg num "$number" '.file_cache[$num]' "$registry_file")
    
    if [[ "$existing_entry" != "null" ]]; then
        echo "Error: Number $number is already in use" >&2
        return 1
    fi
    
    # Check if number is in valid range
    local num_val
    num_val=$(printf "%d" "$number" 2>/dev/null) || {
        echo "Error: Invalid number format: $number" >&2
        return 1
    }
    
    if [[ $num_val -lt 0 ]]; then
        echo "Error: Number $number cannot be negative" >&2
        return 1
    fi
    
    # Check if trying to use reserved QUICK number
    if [[ "$number" == "$QUICK_RESERVED_NUMBER" && "$type" != "quick" ]]; then
        echo "Error: Number $QUICK_RESERVED_NUMBER is reserved for QUICK epic" >&2
        return 1
    fi
    
    return 0
}

# @description Find entry by number
# @arg $1 string Number to search for
# @stdout JSON entry data if found
# @stderr Error messages for missing number parameter
# @exitcode 0 If entry found
# @exitcode 1 If entry not found or parameter missing
numbering_find_by_number() {
    local number="$1"
    
    if [[ -z "$number" ]]; then
        echo "Error: Number parameter required" >&2
        return 1
    fi
    
    local registry_file
    registry_file="$(_numbering_ensure_registry)" || return 1
    
    local entry
    entry=$(jq -r --arg num "$number" '.file_cache[$num]' "$registry_file")
    
    if [[ "$entry" == "null" ]]; then
        return 1
    fi
    
    echo "$entry"
}

# @description Get registry statistics
# @stdout Formatted statistics string with current sequence, epic count, task count, and file paths
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If registry cannot be accessed
numbering_get_stats() {
    local registry_file
    registry_file="$(_numbering_ensure_registry)" || return 1
    
    local current_seq epic_count task_count
    current_seq="$(numbering_get_current)"
    epic_count=$(jq -r '.file_cache | to_entries | map(select(.value.type == "epic")) | length' "$registry_file")
    task_count=$(jq -r '.file_cache | to_entries | map(select(.value.type == "task")) | length' "$registry_file")
    
    cat << EOF
Registry Statistics:
  Current Sequence: $current_seq
  Epics: $epic_count
  Tasks: $task_count
  Registry File: $registry_file
  TASKSEQ File: $(_numbering_get_taskseq_path)
EOF
}


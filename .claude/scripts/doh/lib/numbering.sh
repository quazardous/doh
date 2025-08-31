#!/bin/bash

# Core numbering library for DOH project management system
# Provides centralized, conflict-free task and epic number generation

# Source required dependencies
source "$(dirname "${BASH_SOURCE[0]}")/workspace.sh"

# Constants
readonly NUMBERING_VERSION="1.0.0"
readonly NUMBER_FORMAT="%.3d"
readonly LOCK_TIMEOUT=10
readonly QUICK_RESERVED_NUMBER="000"

# Registry structure validation
validate_registry_structure() {
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

# Initialize empty registry structure
create_empty_registry() {
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
      "path": ".doh/quick/manifest.md",
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

# Get registry file path for current project
get_registry_path() {
    local project_id
    project_id="$(get_current_project_id)" || {
        echo "Error: Could not determine project ID" >&2
        return 1
    }
    
    local registry_dir="$HOME/.doh/projects/$project_id"
    echo "$registry_dir/registers.json"
}

# Ensure registry exists and is valid
ensure_registry() {
    local registry_file
    registry_file="$(get_registry_path)" || return 1
    
    local project_id
    project_id="$(get_current_project_id)" || return 1
    
    # Create registry if it doesn't exist
    if [[ ! -f "$registry_file" ]]; then
        create_empty_registry "$registry_file" "$project_id" || return 1
    fi
    
    # Validate registry structure
    if ! validate_registry_structure "$registry_file"; then
        echo "Error: Invalid registry structure in $registry_file" >&2
        return 1
    fi
    
    echo "$registry_file"
}

# Acquire exclusive file lock with timeout
acquire_lock() {
    local lock_file="$1"
    local timeout="${2:-$LOCK_TIMEOUT}"
    
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

# Release file lock
release_lock() {
    exec 200>&-
}

# Get TASKSEQ file path
get_taskseq_path() {
    local registry_file
    registry_file="$(get_registry_path)" || return 1
    
    echo "$(dirname "$registry_file")/TASKSEQ"
}

# Get next sequence number atomically
get_next_sequence() {
    local taskseq_file
    taskseq_file="$(get_taskseq_path)" || return 1
    
    # Acquire lock for atomic read-increment-write
    acquire_lock "$taskseq_file" || return 1
    
    local current_seq
    if [[ -f "$taskseq_file" ]]; then
        current_seq=$(cat "$taskseq_file" 2>/dev/null || echo "0")
    else
        current_seq="0"
    fi
    
    # Validate current sequence is a number
    if ! [[ "$current_seq" =~ ^[0-9]+$ ]]; then
        release_lock
        echo "Error: Invalid TASKSEQ content: $current_seq" >&2
        return 1
    fi
    
    local next_seq=$((current_seq + 1))
    
    # Write new sequence
    echo "$next_seq" > "$taskseq_file" || {
        release_lock
        echo "Error: Failed to update TASKSEQ file" >&2
        return 1
    }
    
    release_lock
    echo "$next_seq"
}

# Get current sequence number (read-only)
get_current_sequence() {
    local taskseq_file
    taskseq_file="$(get_taskseq_path)" || return 1
    
    if [[ -f "$taskseq_file" ]]; then
        cat "$taskseq_file" 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

# Get next available number from global sequence
get_next_number() {
    local type="$1"  # "epic" or "task"
    
    if [[ "$type" != "epic" && "$type" != "task" ]]; then
        echo "Error: Invalid type '$type'. Must be 'epic' or 'task'" >&2
        return 1
    fi
    
    # Simply get next sequence number - no need for complex gap management
    local next_number
    next_number="$(get_next_sequence)" || return 1
    
    # Format as 3-digit zero-padded number
    printf "$NUMBER_FORMAT" "$next_number"
}

# Register epic in central registry
register_epic() {
    local number="$1"
    local path="$2" 
    local name="$3"
    local metadata="$4"  # Optional JSON metadata
    
    if [[ -z "$number" || -z "$path" || -z "$name" ]]; then
        echo "Error: Missing required parameters for epic registration" >&2
        return 1
    fi
    
    local registry_file
    registry_file="$(ensure_registry)" || return 1
    
    # Acquire lock for atomic operation
    acquire_lock "$registry_file" || return 1
    
    # Check if number is already registered
    local existing_entry
    existing_entry=$(jq -r --arg num "$number" '.file_cache[$num]' "$registry_file")
    
    if [[ "$existing_entry" != "null" ]]; then
        release_lock
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
        release_lock
        echo "Error: Failed to register epic $number" >&2
        return 1
    fi
    
    release_lock
    return 0
}

# Register task in central registry
register_task() {
    local number="$1"
    local parent_number="$2"  # Can be epic or task number
    local path="$3"
    local name="$4"
    local epic_name="$5"
    local metadata="$6"  # Optional JSON metadata
    
    if [[ -z "$number" || -z "$path" || -z "$name" ]]; then
        echo "Error: Missing required parameters for task registration" >&2
        return 1
    fi
    
    local registry_file
    registry_file="$(ensure_registry)" || return 1
    
    # Acquire lock for atomic operation
    acquire_lock "$registry_file" || return 1
    
    # Check if number is already registered
    local existing_entry
    existing_entry=$(jq -r --arg num "$number" '.file_cache[$num]' "$registry_file")
    
    if [[ "$existing_entry" != "null" ]]; then
        release_lock
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
        release_lock
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
            release_lock
            echo "Error: Failed to register task $number in graph cache" >&2
            return 1
        fi
    fi
    
    release_lock
    return 0
}

# Validate number availability
validate_number() {
    local number="$1"
    local type="$2"  # "epic" or "task"
    
    if [[ -z "$number" || -z "$type" ]]; then
        echo "Error: Missing required parameters for validation" >&2
        return 1
    fi
    
    local registry_file
    registry_file="$(ensure_registry)" || return 1
    
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

# Find entry by number
find_by_number() {
    local number="$1"
    
    if [[ -z "$number" ]]; then
        echo "Error: Number parameter required" >&2
        return 1
    fi
    
    local registry_file
    registry_file="$(ensure_registry)" || return 1
    
    local entry
    entry=$(jq -r --arg num "$number" '.file_cache[$num]' "$registry_file")
    
    if [[ "$entry" == "null" ]]; then
        return 1
    fi
    
    echo "$entry"
}

# Get registry statistics
get_registry_stats() {
    local registry_file
    registry_file="$(ensure_registry)" || return 1
    
    local current_seq epic_count task_count
    current_seq="$(get_current_sequence)"
    epic_count=$(jq -r '.file_cache | to_entries | map(select(.value.type == "epic")) | length' "$registry_file")
    task_count=$(jq -r '.file_cache | to_entries | map(select(.value.type == "task")) | length' "$registry_file")
    
    cat << EOF
Registry Statistics:
  Current Sequence: $current_seq
  Epics: $epic_count
  Tasks: $task_count
  Registry File: $registry_file
  TASKSEQ File: $(get_taskseq_path)
EOF
}
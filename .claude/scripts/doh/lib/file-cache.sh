#!/bin/bash

# DOH File Cache Library
# Pure library for number-to-file cache management using CSV format (no automatic execution)
# Format: number,type,path,name,epic
# Sorted by number for fast lookups and duplicate detection

# Source core library dependencies
source "$(dirname "${BASH_SOURCE[0]}")/doh.sh"
source "$(dirname "${BASH_SOURCE[0]}")/workspace.sh"

# Guard against multiple sourcing
[[ -n "${DOH_LIB_FILE_CACHE_LOADED:-}" ]] && return 0
DOH_LIB_FILE_CACHE_LOADED=1

# Constants
readonly FILE_CACHE_LIB_VERSION="1.0.0"

# @description Get file cache path
# @stdout Path to the file cache CSV file
# @exitcode 0 If successful
# @exitcode 1 If unable to get project ID
_file_cache_get_path() {
    local project_id
    project_id="$(workspace_get_current_project_id)" || return 1
    
    echo "$(doh_global_dir)/projects/$project_id/file_cache.csv"
}

# @description Initialize empty file cache
# @arg $1 string Path to the cache file to create
# @exitcode 0 If successful
_file_cache_create_empty() {
    local cache_file="$1"
    local doh_dir
    doh_dir=$(doh_project_dir) || return 1

    mkdir -p "$(dirname "$cache_file")"
    
    # CSV header
    echo "number,type,path,name,epic" > "$cache_file"
    
    # Add QUICK epic as first entry
    echo "000,epic,$doh_dir/quick/manifest.md,QUICK," >> "$cache_file"
}

# @description Ensure file cache exists
# @stdout Path to the ensured cache file
# @exitcode 0 If successful
# @exitcode 1 If unable to get or create cache file
_file_cache_ensure() {
    local cache_file
    cache_file="$(_file_cache_get_path)" || return 1
    
    if [[ ! -f "$cache_file" ]]; then
        _file_cache_create_empty "$cache_file" || return 1
    fi
    
    echo "$cache_file"
}

# @description Find file by number (with duplicate detection)
# @public
# @arg $1 string Number to search for
# @arg $2 string Optional epic name to filter by
# @stdout CSV line with file information
# @stderr Error messages and duplicate warnings
# @exitcode 0 If successful
# @exitcode 1 If number not found or invalid parameters
# @exitcode 2 If multiple valid files found (conflict error)
file_cache_find_file_by_number() {
    local number="$1"
    local epic_name="${2:-}"  # Optional: filter by epic name
    
    if [[ -z "$number" ]]; then
        echo "Error: Number parameter required" >&2
        return 1
    fi
    
    local cache_file
    cache_file="$(_file_cache_ensure)" || return 1
    
    # Find all entries with this number (sorted, so they'll be together)
    local matches
    if [[ -n "$epic_name" ]]; then
        matches=$(grep "^$number," "$cache_file" | grep ",$epic_name$\|,$epic_name,")
    else
        matches=$(grep "^$number," "$cache_file")
    fi
    
    if [[ -z "$matches" ]]; then
        return 1
    fi
    
    local match_count
    match_count=$(echo "$matches" | wc -l)
    
    if [[ $match_count -gt 1 ]]; then
        echo "Warning: Duplicate number $number found in cache:" >&2
        echo "$matches" >&2
        
        # Try to resolve duplicates by checking which files exist
        local valid_matches=""
        local project_root
        project_root="$(doh_project_dir)" || return 1
        
        while IFS= read -r match; do
            local file_path
            file_path=$(echo "$match" | cut -d',' -f3)
            
            if [[ -f "$project_root/$file_path" ]]; then
                # Verify number in file matches
                local file_number
                file_number=$(grep -m 1 "^number:" "$project_root/$file_path" | cut -d':' -f2- | xargs)
                
                if [[ "$file_number" == "$number" ]]; then
                    if [[ -z "$valid_matches" ]]; then
                        valid_matches="$match"
                    else
                        valid_matches="$valid_matches"$'\n'"$match"
                    fi
                fi
            fi
        done <<< "$matches"
        
        if [[ -n "$valid_matches" ]]; then
            matches="$valid_matches"
            match_count=$(echo "$matches" | wc -l)
            
            if [[ $match_count -gt 1 ]]; then
                echo "ERROR: Multiple valid files found for number $number!" >&2
                echo "$matches" >&2
                return 2  # Conflict error code
            fi
        else
            echo "ERROR: No valid files found for number $number" >&2
            return 1
        fi
    fi
    
    # Return the path (3rd field)
    echo "$matches" | cut -d',' -f3
}

# @description Add entry to file cache (maintains sorted order)
# @arg $1 string File number
# @arg $2 string File type ("epic" or "task")
# @arg $3 string Relative path to file
# @arg $4 string Human-readable name
# @arg $5 string Optional epic name
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If missing required parameters or other error
file_cache_add_file() {
    local number="$1"
    local type="$2"
    local path="$3" 
    local name="$4"
    local epic="${5:-}"  # Optional
    
    if [[ -z "$number" || -z "$type" || -z "$path" || -z "$name" ]]; then
        echo "Error: Missing required parameters" >&2
        return 1
    fi
    
    local cache_file
    cache_file="$(_file_cache_ensure)" || return 1
    
    # Format the entry
    local entry="$number,$type,$path,$name,${epic:-}"
    
    # Check for existing entry
    if grep -q "^$number,$type,$path," "$cache_file"; then
        echo "Entry already exists in cache: $entry" >&2
        return 0
    fi
    
    # Add entry and re-sort by number
    {
        head -n 1 "$cache_file"  # Keep header
        tail -n +2 "$cache_file"  # Get data rows
        echo "$entry"             # Add new entry
    } | (
        read header
        echo "$header"
        sort -t',' -k1,1n  # Sort by first column (number) numerically
    ) > "$cache_file.tmp" && mv "$cache_file.tmp" "$cache_file"
}

# @description Remove entry from file cache
# @arg $1 string Number of entry to remove
# @arg $2 string Optional path to remove specific number+path combination
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If number parameter missing or other error
file_cache_remove_file() {
    local number="$1"
    local path="$2"
    
    if [[ -z "$number" ]]; then
        echo "Error: Number parameter required" >&2
        return 1
    fi
    
    local cache_file
    cache_file="$(_file_cache_ensure)" || return 1
    
    # Remove matching entries
    if [[ -n "$path" ]]; then
        # Remove specific number+path combination
        grep -v "^$number,.*,$path," "$cache_file" > "$cache_file.tmp" && mv "$cache_file.tmp" "$cache_file"
    else
        # Remove all entries with this number
        grep -v "^$number," "$cache_file" > "$cache_file.tmp" && mv "$cache_file.tmp" "$cache_file"
    fi
}

# @description Rebuild file cache from filesystem
# @stderr Progress messages
# @exitcode 0 If successful
# @exitcode 1 If unable to find project root or create cache
file_cache_rebuild() {
    local cache_file
    cache_file="$(_file_cache_ensure)" || return 1
    
    echo "Rebuilding file cache..." >&2
    
    # Create fresh cache
    _file_cache_create_empty "$cache_file"

    local doh_dir
    doh_dir=$(doh_project_dir) || return 1

    # Scan for all numbered files
    local numbered_files
    numbered_files=$(find "$doh_dir" -name "*.md" -type f -exec grep -l "^number:" {} \;)
    
    while IFS= read -r file; do
        if [[ -n "$file" && -f "$file" ]]; then
            local rel_path number name epic type
            rel_path=$(realpath --relative-to="$doh_dir" "$file")
            
            # Extract metadata from frontmatter
            number=$(grep -m 1 "^number:" "$file" | cut -d':' -f2- | xargs)
            name=$(grep -m 1 "^name:" "$file" | cut -d':' -f2- | xargs)
            
            if [[ -n "$number" && -n "$name" ]]; then
                # Determine type and epic
                if [[ "$rel_path" == *"/epic.md" ]]; then
                    type="epic"
                    epic=""
                else
                    type="task"
                    # Extract epic name from path or frontmatter
                    if grep -q "^epic:" "$file"; then
                        epic=$(grep -m 1 "^epic:" "$file" | cut -d':' -f2- | xargs)
                    else
                        # Infer from path: epics/epic-name/
                        epic=$(echo "$rel_path" | sed -n "s|^epics/\([^/]*\)/.*|\1|p")
                    fi
                fi
                
                file_cache_add_file "$number" "$type" "$rel_path" "$name" "$epic"
            fi
        fi
    done <<< "$numbered_files"
    
    echo "File cache rebuilt successfully" >&2
    return 0
}

# @description Detect and report duplicates
# @stderr Duplicate detection results and warnings
# @exitcode 0 If no duplicates found
# @exitcode 1 If duplicates found
file_cache_detect_duplicates() {
    local cache_file
    cache_file="$(_file_cache_ensure)" || return 1
    
    echo "Detecting duplicate numbers..." >&2
    
    # Find duplicate numbers (skip header)
    local duplicates
    duplicates=$(tail -n +2 "$cache_file" | cut -d',' -f1 | sort -n | uniq -d)
    
    if [[ -n "$duplicates" ]]; then
        echo "WARNING: Duplicate numbers detected!" >&2
        
        while IFS= read -r dup_number; do
            if [[ -n "$dup_number" ]]; then
                echo "  Number $dup_number:" >&2
                grep "^$dup_number," "$cache_file" | while IFS=',' read -r num type path name epic; do
                    echo "    $type: $name ($path)" >&2
                done
            fi
        done <<< "$duplicates"
        
        return 1
    else
        echo "No duplicate numbers found" >&2
        return 0
    fi
}

# @description Get file cache statistics
# @stdout Formatted statistics string
# @exitcode 0 If successful
# @exitcode 1 If unable to access cache file
file_cache_get_stats() {
    local cache_file
    cache_file="$(_file_cache_ensure)" || return 1
    
    local total_files epic_count task_count duplicate_count
    total_files=$(tail -n +2 "$cache_file" | wc -l)
    epic_count=$(tail -n +2 "$cache_file" | cut -d',' -f2 | grep -c "epic")
    task_count=$(tail -n +2 "$cache_file" | cut -d',' -f2 | grep -c "task")
    duplicate_count=$(tail -n +2 "$cache_file" | cut -d',' -f1 | sort -n | uniq -d | wc -l)
    
    cat << EOF
File Cache Statistics:
  Total Files: $total_files
  Epics: $epic_count
  Tasks: $task_count
  Duplicates: $duplicate_count
  Cache File: $cache_file
EOF
}

# @description List all files for an epic
# @arg $1 string Name of the epic to list files for
# @stdout CSV lines for epic and its tasks
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If epic name missing or cache access error
file_cache_list_epic_files() {
    local epic_name="$1"
    
    if [[ -z "$epic_name" ]]; then
        echo "Error: Epic name required" >&2
        return 1
    fi
    
    local cache_file
    cache_file="$(_file_cache_ensure)" || return 1
    
    # Find all entries for this epic (epic itself + tasks)
    {
        grep "^[0-9]*,epic,.*,$epic_name," "$cache_file" 2>/dev/null || true
        grep "^[0-9]*,task,.*,.*,$epic_name$" "$cache_file" 2>/dev/null || true
    } | sort -t',' -k1,1n
}

# Global variable to track lock file descriptor
declare -g DOH_CACHE_LOCK_FD=""

# @description Acquire exclusive lock for cache file operations using flock
# @arg $1 string Cache file path
# @stderr Error messages
# @exitcode 0 If lock acquired successfully
# @exitcode 1 If unable to acquire lock
file_cache_acquire_lock() {
    local cache_file="$1"
    
    if [[ -z "$cache_file" ]]; then
        echo "Error: Cache file path required for locking" >&2
        return 1
    fi
    
    # Create lock file path (cache_file + .lock)
    local lock_file="${cache_file}.lock"
    
    # Open lock file and get file descriptor
    exec {DOH_CACHE_LOCK_FD}>"$lock_file" || {
        echo "Error: Unable to open lock file $lock_file" >&2
        return 1
    }
    
    # Acquire exclusive lock with timeout (10 seconds)
    if ! flock -x -w 10 "$DOH_CACHE_LOCK_FD"; then
        echo "Error: Unable to acquire lock for $cache_file (timeout after 10s)" >&2
        exec {DOH_CACHE_LOCK_FD}>&-  # Close file descriptor
        DOH_CACHE_LOCK_FD=""
        return 1
    fi
    
    return 0
}

# @description Release lock for cache file operations
# @stderr Error messages
# @exitcode 0 If lock released successfully
# @exitcode 1 If no lock to release or error
file_cache_release_lock() {
    if [[ -z "$DOH_CACHE_LOCK_FD" ]]; then
        echo "Warning: No active lock to release" >&2
        return 1
    fi
    
    # Release lock and close file descriptor
    exec {DOH_CACHE_LOCK_FD}>&- || {
        echo "Warning: Error closing lock file descriptor" >&2
        DOH_CACHE_LOCK_FD=""
        return 1
    }
    
    DOH_CACHE_LOCK_FD=""
    return 0
}

# @description Generic acquire lock function (alias for file_cache_acquire_lock)
# @arg $1 string File path to lock
# @stderr Error messages
# @exitcode 0 If lock acquired successfully
# @exitcode 1 If unable to acquire lock
acquire_lock() {
    file_cache_acquire_lock "$1"
}
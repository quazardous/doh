#!/bin/bash

# Simple number-to-file cache using CSV format
# Format: number,type,path,name,epic
# Sorted by number for fast lookups and duplicate detection

# Source required dependencies
source "$(dirname "${BASH_SOURCE[0]}")/workspace.sh"

# Get file cache path
get_file_cache_path() {
    local project_id
    project_id="$(get_current_project_id)" || return 1
    
    echo "$HOME/.doh/projects/$project_id/file_cache.csv"
}

# Initialize empty file cache
create_empty_file_cache() {
    local cache_file="$1"
    
    mkdir -p "$(dirname "$cache_file")"
    
    # CSV header
    echo "number,type,path,name,epic" > "$cache_file"
    
    # Add QUICK epic as first entry
    echo "000,epic,.doh/quick/manifest.md,QUICK," >> "$cache_file"
}

# Ensure file cache exists
ensure_file_cache() {
    local cache_file
    cache_file="$(get_file_cache_path)" || return 1
    
    if [[ ! -f "$cache_file" ]]; then
        create_empty_file_cache "$cache_file" || return 1
    fi
    
    echo "$cache_file"
}

# Find file by number (with duplicate detection)
find_file_by_number() {
    local number="$1"
    local epic_name="$2"  # Optional: filter by epic name
    
    if [[ -z "$number" ]]; then
        echo "Error: Number parameter required" >&2
        return 1
    fi
    
    local cache_file
    cache_file="$(ensure_file_cache)" || return 1
    
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
        project_root="$(_find_doh_root)" || return 1
        
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

# Add entry to file cache (maintains sorted order)
add_to_file_cache() {
    local number="$1"
    local type="$2"
    local path="$3" 
    local name="$4"
    local epic="$5"  # Optional
    
    if [[ -z "$number" || -z "$type" || -z "$path" || -z "$name" ]]; then
        echo "Error: Missing required parameters" >&2
        return 1
    fi
    
    local cache_file
    cache_file="$(ensure_file_cache)" || return 1
    
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

# Remove entry from file cache
remove_from_file_cache() {
    local number="$1"
    local path="$2"
    
    if [[ -z "$number" ]]; then
        echo "Error: Number parameter required" >&2
        return 1
    fi
    
    local cache_file
    cache_file="$(ensure_file_cache)" || return 1
    
    # Remove matching entries
    if [[ -n "$path" ]]; then
        # Remove specific number+path combination
        grep -v "^$number,.*,$path," "$cache_file" > "$cache_file.tmp" && mv "$cache_file.tmp" "$cache_file"
    else
        # Remove all entries with this number
        grep -v "^$number," "$cache_file" > "$cache_file.tmp" && mv "$cache_file.tmp" "$cache_file"
    fi
}

# Rebuild file cache from filesystem
rebuild_file_cache() {
    local project_root
    project_root="$(_find_doh_root)" || return 1
    
    local cache_file
    cache_file="$(ensure_file_cache)" || return 1
    
    echo "Rebuilding file cache..." >&2
    
    # Create fresh cache
    create_empty_file_cache "$cache_file"
    
    # Scan for all numbered files
    local numbered_files
    numbered_files=$(find "$project_root" -name "*.md" -path "*/.doh/*" -type f -exec grep -l "^number:" {} \;)
    
    while IFS= read -r file; do
        if [[ -n "$file" && -f "$file" ]]; then
            local rel_path number name epic type
            rel_path=$(realpath --relative-to="$project_root" "$file")
            
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
                        # Infer from path: .doh/epics/epic-name/
                        epic=$(echo "$rel_path" | sed -n 's|^\.doh/epics/\([^/]*\)/.*|\1|p')
                    fi
                fi
                
                add_to_file_cache "$number" "$type" "$rel_path" "$name" "$epic"
            fi
        fi
    done <<< "$numbered_files"
    
    echo "File cache rebuilt successfully" >&2
    return 0
}

# Detect and report duplicates
detect_duplicates() {
    local cache_file
    cache_file="$(ensure_file_cache)" || return 1
    
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

# Get file cache statistics
get_file_cache_stats() {
    local cache_file
    cache_file="$(ensure_file_cache)" || return 1
    
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

# List all files for an epic
list_epic_files() {
    local epic_name="$1"
    
    if [[ -z "$epic_name" ]]; then
        echo "Error: Epic name required" >&2
        return 1
    fi
    
    local cache_file
    cache_file="$(ensure_file_cache)" || return 1
    
    # Find all entries for this epic (epic itself + tasks)
    {
        grep "^[0-9]*,epic,.*,$epic_name," "$cache_file" 2>/dev/null || true
        grep "^[0-9]*,task,.*,.*,$epic_name$" "$cache_file" 2>/dev/null || true
    } | sort -t',' -k1,1n
}
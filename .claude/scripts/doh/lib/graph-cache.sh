#!/bin/bash

# DOH Graph Cache Library
# Pure library for tracking parent/child relationships and dependencies (no automatic execution)
# One-way cache: stores parent relationships for fast lookup

# Source core library dependencies
source "$(dirname "${BASH_SOURCE[0]}")/doh.sh"
source "$(dirname "${BASH_SOURCE[0]}")/workspace.sh"
source "$(dirname "${BASH_SOURCE[0]}")/numbering.sh"
source "$(dirname "${BASH_SOURCE[0]}")/frontmatter.sh"
source "$(dirname "${BASH_SOURCE[0]}")/file-cache.sh"

# Guard against multiple sourcing
[[ -n "${DOH_LIB_GRAPH_CACHE_LOADED:-}" ]] && return 0
DOH_LIB_GRAPH_CACHE_LOADED=1

# Constants
readonly GRAPH_CACHE_LIB_VERSION="1.0.0"

# @description Get graph cache path
# @stdout Path to the graph cache JSON file
# @exitcode 0 If successful
# @exitcode 1 If unable to determine project ID
_graph_cache_get_cache_path() {
    local project_id
    project_id="$(workspace_get_current_project_id)" || return 1
    
    echo "$(doh_global_dir)/projects/$project_id/graph_cache.json"
}

# @description Initialize empty graph cache
# @arg $1 string Path to the cache file to create
# @exitcode 0 If successful
# @exitcode 1 If unable to create cache file
_graph_cache_create_empty_cache() {
    local cache_file="$1"
    
    mkdir -p "$(dirname "$cache_file")"
    
    cat > "$cache_file" << EOF
{
  "relationships": {},
  "versions": {},
  "last_updated": "$(date -Iseconds)",
  "version": "1.1"
}
EOF
}

# @description Ensure graph cache exists
# @stdout Path to the ensured cache file
# @stderr Warning messages if cache needs rebuilding
# @exitcode 0 If successful
# @exitcode 1 If unable to create or validate cache
_graph_cache_ensure_cache() {
    local cache_file
    cache_file="$(_graph_cache_get_cache_path)" || return 1
    
    if [[ ! -f "$cache_file" ]]; then
        _graph_cache_create_empty_cache "$cache_file" || return 1
    fi
    
    # Validate cache structure
    if ! jq -e '.relationships' "$cache_file" >/dev/null 2>&1; then
        echo "Warning: Corrupted graph cache, rebuilding..." >&2
        _graph_cache_create_empty_cache "$cache_file" || return 1
    fi
    
    echo "$cache_file"
}

# @description Add relationship to graph cache
# @arg $1 string Task/epic number
# @arg $2 string Optional parent number
# @arg $3 string Optional epic name
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If number parameter missing or cache update fails
graph_cache_add_relationship() {
    local number="${1:-}"
    local parent_number="${2:-}"  # Optional
    local epic_name="${3:-}"      # Optional
    
    if [[ -z "$number" ]]; then
        echo "Error: Number parameter required" >&2
        return 1
    fi
    
    local cache_file
    cache_file="$(_graph_cache_ensure_cache)" || return 1
    
    # Build relationship data
    local relationship="{}"
    
    if [[ -n "$parent_number" ]]; then
        relationship=$(echo "$relationship" | jq --arg parent "$parent_number" '. + {parent: $parent}')
    fi
    
    if [[ -n "$epic_name" ]]; then
        relationship=$(echo "$relationship" | jq --arg epic "$epic_name" '. + {epic: $epic}')
    fi
    
    # Only add if we have meaningful relationship data
    if [[ "$relationship" != "{}" ]]; then
        # Acquire lock for atomic update
        file_cache_acquire_lock "$cache_file" || return 1
        
        local temp_file=$(mktemp)
        jq --arg num "$number" --argjson rel "$relationship" --arg timestamp "$(date -Iseconds)" '
            .relationships[$num] = $rel |
            .last_updated = $timestamp
        ' "$cache_file" > "$temp_file" && mv "$temp_file" "$cache_file"
        
        file_cache_release_lock
    fi
    
    return 0
}

# @description Remove relationship from graph cache
# @arg $1 string Number whose relationship to remove
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If number parameter missing or cache update fails
graph_cache_remove_relationship() {
    local number="$1"
    
    if [[ -z "$number" ]]; then
        echo "Error: Number parameter required" >&2
        return 1
    fi
    
    local cache_file
    cache_file="$(_graph_cache_ensure_cache)" || return 1
    
    # Acquire lock for atomic update
    file_cache_acquire_lock "$cache_file" || return 1
    
    local temp_file=$(mktemp)
    jq --arg num "$number" --arg timestamp "$(date -Iseconds)" '
        del(.relationships[$num]) |
        .last_updated = $timestamp
    ' "$cache_file" > "$temp_file" && mv "$temp_file" "$cache_file"
    
    file_cache_release_lock
    
    return 0
}

# @description Get parent of a number
# @arg $1 string Number to find parent for
# @stdout Parent number if found
# @stderr Error messages
# @exitcode 0 If parent found
# @exitcode 1 If number parameter missing or parent not found
graph_cache_get_parent() {
    local number="$1"
    
    if [[ -z "$number" ]]; then
        echo "Error: Number parameter required" >&2
        return 1
    fi
    
    local cache_file
    cache_file="$(_graph_cache_ensure_cache)" || return 1
    
    local parent
    parent=$(jq -r --arg num "$number" '.relationships[$num].parent // empty' "$cache_file")
    
    if [[ -n "$parent" ]]; then
        echo "$parent"
        return 0
    fi
    
    return 1
}

# @description Get epic of a number
# @arg $1 string Number to find epic for
# @stdout Epic name if found
# @stderr Error messages
# @exitcode 0 If epic found
# @exitcode 1 If number parameter missing or epic not found
graph_cache_get_epic() {
    local number="$1"
    
    if [[ -z "$number" ]]; then
        echo "Error: Number parameter required" >&2
        return 1
    fi
    
    local cache_file
    cache_file="$(_graph_cache_ensure_cache)" || return 1
    
    local epic
    epic=$(jq -r --arg num "$number" '.relationships[$num].epic // empty' "$cache_file")
    
    if [[ -n "$epic" ]]; then
        echo "$epic"
        return 0
    fi
    
    return 1
}

# @description Get all children of a number (search through all relationships)
# @arg $1 string Parent number to find children for
# @stdout List of child numbers, sorted
# @stderr Error messages
# @exitcode 0 If children found
# @exitcode 1 If parent number parameter missing or no children found
graph_cache_get_children() {
    local parent_number="$1"
    
    if [[ -z "$parent_number" ]]; then
        echo "Error: Parent number parameter required" >&2
        return 1
    fi
    
    local cache_file
    cache_file="$(_graph_cache_ensure_cache)" || return 1
    
    local children
    children=$(jq -r --arg parent "$parent_number" '
        .relationships | to_entries[] | 
        select(.value.parent == $parent) | 
        .key
    ' "$cache_file")
    
    if [[ -n "$children" ]]; then
        echo "$children" | sort -n
        return 0
    fi
    
    return 1
}

# @description Get all items in an epic
# @arg $1 string Epic name to find items for
# @stdout List of numbers in the epic
# @stderr Error messages
# @exitcode 0 If items found
# @exitcode 1 If epic name parameter missing or no items found
graph_cache_get_epic_items() {
    local epic_name="$1"
    
    if [[ -z "$epic_name" ]]; then
        echo "Error: Epic name parameter required" >&2
        return 1
    fi
    
    local cache_file
    cache_file="$(_graph_cache_ensure_cache)" || return 1
    
    local items
    items=$(jq -r --arg epic "$epic_name" '
        .relationships | to_entries[] | 
        select(.value.epic == $epic) | 
        .key
    ' "$cache_file")
    
    if [[ -n "$items" ]]; then
        echo "$items" | sort -n
        return 0
    fi
    
    return 1
}

# @description Rebuild graph cache from filesystem
# @stderr Progress messages
# @exitcode 0 If successful
# @exitcode 1 If unable to find project root or create cache
graph_cache_rebuild() {
    local project_root
    project_root="$(doh_project_dir)" || return 1
    
    local cache_file
    cache_file="$(_graph_cache_ensure_cache)" || return 1
    
    echo "Rebuilding graph cache..." >&2
    
    # Create fresh cache
    _graph_cache_create_empty_cache "$cache_file"
    
    # Scan all numbered files for relationships
    local numbered_files
    numbered_files=$(find "$project_root" -name "*.md" -path "*/.doh/*" -type f -exec grep -l "^number:" {} \;)
    
    while IFS= read -r file; do
        if [[ -n "$file" && -f "$file" ]]; then
            local number="" parent_number="" epic_name=""
            
            # Extract metadata from frontmatter
            number=$(grep -m 1 "^number:" "$file" | cut -d':' -f2- | xargs)
            parent_number=$(grep -m 1 "^parent:" "$file" | cut -d':' -f2- | xargs)
            
            # Extract epic name
            if grep -q "^epic:" "$file"; then
                epic_name=$(grep -m 1 "^epic:" "$file" | cut -d':' -f2- | xargs)
            else
                # Infer from path for tasks: .doh/epics/epic-name/
                local rel_path
                rel_path=$(realpath --relative-to="$project_root" "$file")
                
                if [[ "$rel_path" == *.doh/epics/*/[0-9]*.md ]]; then
                    epic_name=$(echo "$rel_path" | sed -n 's|^\.doh/epics/\([^/]*\)/.*|\1|p')
                fi
            fi
            
            # Add relationship if we have useful data
            if [[ -n "$number" && ( -n "$parent_number" || -n "$epic_name" ) ]]; then
                graph_cache_add_relationship "$number" "$parent_number" "$epic_name"
            fi
        fi
    done <<< "$numbered_files"
    
    echo "Graph cache rebuilt successfully" >&2
    return 0
}

# @description Validate graph cache consistency
# @stderr Progress and validation messages
# @exitcode 0 If cache is consistent
# @exitcode 1 If cache has validation warnings
graph_cache_validate() {
    local cache_file
    cache_file="$(_graph_cache_ensure_cache)" || return 1
    
    local project_root
    project_root="$(doh_project_dir)" || return 1
    
    local errors=0
    
    echo "Validating graph cache..." >&2
    
    # Get all numbers in cache
    local numbers
    numbers=$(jq -r '.relationships | keys[]' "$cache_file")
    
    while IFS= read -r number; do
        if [[ -n "$number" ]]; then
            # Check if referenced parent exists
            local parent
            parent=$(jq -r --arg num "$number" '.relationships[$num].parent // empty' "$cache_file")
            
            if [[ -n "$parent" ]]; then
                # Check if parent is in cache or exists as file
                local parent_in_cache
                parent_in_cache=$(jq -r --arg p "$parent" '.relationships[$p] // empty' "$cache_file")
                
                if [[ "$parent_in_cache" == "" ]]; then
                    # Check if parent file exists
                    local parent_files
                    parent_files=$(find "$project_root" -name "*.md" -path "*/.doh/*" -type f -exec grep -l "^number:.*$parent" {} \; 2>/dev/null)
                    
                    if [[ -z "$parent_files" ]]; then
                        echo "Warning: Parent $parent for number $number not found" >&2
                        ((errors++))
                    fi
                fi
            fi
        fi
    done <<< "$numbers"
    
    if [[ $errors -eq 0 ]]; then
        echo "Graph cache is consistent" >&2
        return 0
    else
        echo "Graph cache has $errors warnings" >&2
        return 1
    fi
}

# @description Self-healing: detect and fix cache issues
# @stderr Status messages
# @exitcode 0 If cache is healthy or successfully healed
# @exitcode 1 If cache still has issues after healing
graph_cache_heal() {
    echo "Running graph cache self-healing..." >&2
    
    if graph_cache_validate; then
        echo "Graph cache is healthy" >&2
        return 0
    fi
    
    echo "Rebuilding graph cache..." >&2
    graph_cache_rebuild
    
    if graph_cache_validate; then
        echo "Graph cache healed successfully" >&2
        return 0
    else
        echo "Graph cache still has warnings after healing" >&2
        return 1
    fi
}

# @description Get graph cache statistics
# @stdout Formatted statistics string
# @exitcode 0 If successful
# @exitcode 1 If unable to access cache
graph_cache_get_stats() {
    local cache_file
    cache_file="$(_graph_cache_ensure_cache)" || return 1
    
    local total_relationships parent_count epic_count last_updated
    total_relationships=$(jq -r '.relationships | length' "$cache_file")
    parent_count=$(jq -r '[.relationships[] | select(has("parent"))] | length' "$cache_file")
    epic_count=$(jq -r '[.relationships[] | select(has("epic"))] | length' "$cache_file")
    last_updated=$(jq -r '.last_updated' "$cache_file")
    
    cat << EOF
Graph Cache Statistics:
  Total Relationships: $total_relationships
  Items with Parents: $parent_count
  Items in Epics: $epic_count
  Last Updated: $last_updated
  Cache File: $cache_file
EOF
}

# @description Print relationship tree for debugging
# @stderr Relationship tree output
# @exitcode 0 If successful
# @exitcode 1 If unable to access cache
graph_cache_print_tree() {
    local cache_file
    cache_file="$(_graph_cache_ensure_cache)" || return 1
    
    echo "Relationship Tree:" >&2
    
    # Find root items (no parent)
    local roots
    roots=$(jq -r '.relationships | to_entries[] | select(.value.parent == null or (.value | has("parent") | not)) | .key' "$cache_file" | sort -n)
    
    while IFS= read -r root; do
        if [[ -n "$root" ]]; then
            _graph_cache_print_tree_node "$root" 0
        fi
    done <<< "$roots"
}

# @description Helper function to print tree node recursively
# @internal
# @arg $1 string Current node number
# @arg $2 number Current depth level
# @stderr Tree node output with indentation
# @exitcode 0 If successful
# @exitcode 1 If unable to access cache
_graph_cache_print_tree_node() {
    local number="$1"
    local depth="$2"
    
    local cache_file
    cache_file="$(_graph_cache_ensure_cache)" || return 1
    
    # Print indentation
    local indent=""
    for ((i=0; i<depth; i++)); do
        indent="  $indent"
    done
    
    # Get epic info
    local epic
    epic=$(jq -r --arg num "$number" '.relationships[$num].epic // empty' "$cache_file")
    local epic_info=""
    if [[ -n "$epic" ]]; then
        epic_info=" [$epic]"
    fi
    
    echo "${indent}$number$epic_info" >&2
    
    # Print children
    local children
    children=$(graph_cache_get_children "$number" 2>/dev/null)
    
    while IFS= read -r child; do
        if [[ -n "$child" ]]; then
            _graph_cache_print_tree_node "$child" $((depth + 1))
        fi
    done <<< "$children"
}

# ===============================
# VERSION RELATIONSHIP FUNCTIONS
# ===============================

# @description Add or update version information in graph cache
# @arg $1 string Version (e.g., "1.0.0")
# @arg $2 string JSON string with version data (required_tasks, required_epics, etc.)
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If parameters missing or update failed
graph_cache_update_version() {
    local version="${1:-}"
    local version_data="${2:-}"
    
    if [[ -z "$version" || -z "$version_data" ]]; then
        echo "Error: Version and version data required" >&2
        return 1
    fi
    
    local cache_file
    cache_file="$(_graph_cache_ensure_cache)" || return 1
    
    # Create temporary file for atomic update
    local temp_file
    temp_file=$(mktemp)
    
    # Update version data
    local timestamp=$(date -Iseconds)
    jq --arg version "$version" --argjson data "$version_data" --arg ts "$timestamp" '
        .versions[$version] = $data |
        .last_updated = $ts
    ' "$cache_file" > "$temp_file"
    
    # Atomic replacement
    mv "$temp_file" "$cache_file"
}

# @description Get version data from graph cache
# @arg $1 string Version (e.g., "1.0.0")  
# @stdout JSON version data if found
# @stderr Error messages
# @exitcode 0 If version found
# @exitcode 1 If version parameter missing or version not found
graph_cache_get_version() {
    local version="$1"
    
    if [[ -z "$version" ]]; then
        echo "Error: Version parameter required" >&2
        return 1
    fi
    
    local cache_file
    cache_file="$(_graph_cache_ensure_cache)" || return 1
    
    local version_data
    version_data=$(jq -r --arg version "$version" '.versions[$version] // empty' "$cache_file")
    
    if [[ -n "$version_data" && "$version_data" != "null" ]]; then
        echo "$version_data"
        return 0
    fi
    
    return 1
}

# @description Get all tasks that block a version
# @arg $1 string Version (e.g., "1.0.0")
# @stdout List of task numbers, one per line
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If version parameter missing
graph_cache_get_version_blocking_tasks() {
    local version="$1"
    
    if [[ -z "$version" ]]; then
        echo "Error: Version parameter required" >&2
        return 1
    fi
    
    local version_data
    version_data=$(graph_cache_get_version "$version" 2>/dev/null)
    
    if [[ -n "$version_data" ]]; then
        echo "$version_data" | jq -r '(.required_tasks // [])[]'
    fi
}

# @description Get all versions that a task affects
# @arg $1 string Task number
# @stdout List of version numbers, one per line
# @stderr Error messages
# @exitcode 0 If task affects versions
# @exitcode 1 If task parameter missing or no versions affected
graph_cache_get_task_versions() {
    local task="$1"
    local target_version="" file_version=""
    
    if [[ -z "$task" ]]; then
        echo "Error: Task number required" >&2
        return 1
    fi
    
    # First, check if task file has target_version field
    local project_root
    project_root="$(doh_project_dir)" || return 1
    
    local task_file
    task_file=$(find "$project_root" -name "${task}.md" -type f | head -1)
    
    if [[ -f "$task_file" ]]; then
        local target_version="" file_version=""
        target_version=$(frontmatter_get_field "$task_file" "target_version")
        file_version=$(frontmatter_get_field "$task_file" "file_version")
        
        # Return both target and current file versions
        if [[ -n "$target_version" ]]; then
            echo "$target_version"
        fi
        if [[ -n "$file_version" && "$file_version" != "$target_version" ]]; then
            echo "$file_version"
        fi
    fi
    
    # Also check cache for versions that require this task
    local cache_file
    cache_file="$(_graph_cache_ensure_cache)" || return 1
    
    # Search all versions for this task
    local versions
    versions=$(jq -r --arg task "$task" '
        .versions | to_entries[] |
        select(.value.required_tasks // [] | index($task)) |
        .key
    ' "$cache_file")
    
    if [[ -n "$versions" ]]; then
        echo "$versions"
    fi
    
    # Return success if we found any versions
    [[ -n "$target_version" || -n "$versions" ]]
}

# @description Sync version data from version files to graph cache
# @stderr Status messages
# @exitcode 0 If successful
# @exitcode 1 If sync failed
graph_cache_sync_version_cache() {
    echo "Syncing version data to graph cache..." >&2
    
    local doh_root
    doh_root="$(doh_project_dir)" || {
        echo "Error: Not in a DOH project" >&2
        return 1
    }
    
    local versions_dir="$doh_root/versions"
    
    if [[ ! -d "$versions_dir" ]]; then
        echo "No versions directory found" >&2
        return 0
    fi
    
    # Process all version files - placeholder for AI command integration
    find "$versions_dir" -name "*.md" -type f | while read -r version_file; do
        local version
        version=$(basename "$version_file" .md)
        
        echo "Processing version $version..." >&2
        
        # Find tasks that target this version
        local task_list=""
        
        # Collect task numbers that match this version
        while IFS= read -r task_file; do
            if [[ -n "$task_file" ]] && frontmatter_has "$task_file"; then
                local target_version file_version task_number
                target_version=$(frontmatter_get_field "$task_file" "target_version")
                file_version=$(frontmatter_get_field "$task_file" "file_version")
                task_number=$(frontmatter_get_field "$task_file" "number")
                
                if [[ "$target_version" == "$version" || "$file_version" == "$version" ]]; then
                    if [[ -n "$task_number" ]]; then
                        if [[ -z "$task_list" ]]; then
                            task_list="\"$task_number\""
                        else
                            task_list="$task_list,\"$task_number\""
                        fi
                    fi
                fi
            fi
        done < <(find "$doh_root" -name "*.md" -type f)
        
        # Create version data with actual required tasks
        local version_data='{
            "last_synced": "'$(date -Iseconds)'",
            "source_file": "'$version_file'",
            "required_tasks": ['$task_list'],
            "completion_percentage": 0
        }'
        
        graph_cache_update_version "$version" "$version_data"
    done
    
    echo "Version cache sync completed" >&2
}

# @description Sync specific versions to graph cache (selective update)
# @arg $@ string List of version numbers to sync (e.g., "1.0.0" "2.0.0")
# @stderr Status messages
# @exitcode 0 If successful
# @exitcode 1 If sync failed
graph_cache_sync_specific_versions() {
    if [[ $# -eq 0 ]]; then
        echo "Error: No versions specified for selective sync" >&2
        return 1
    fi
    
    echo "Selective version sync for: $*" >&2
    
    local doh_root
    doh_root="$(doh_project_dir)" || {
        echo "Error: Not in a DOH project" >&2
        return 1
    }
    
    local versions_dir="$doh_root/versions"
    
    if [[ ! -d "$versions_dir" ]]; then
        echo "No versions directory found" >&2
        return 0
    fi
    
    # Process only specified versions
    for version in "$@"; do
        local version_file="$versions_dir/$version.md"
        
        if [[ -f "$version_file" ]]; then
            echo "Processing version $version..." >&2
            
            # AI commands will populate this with real data
            local version_data='{
                "last_synced": "'$(date -Iseconds)'",
                "source_file": "'$version_file'",
                "required_tasks": [],
                "completion_percentage": 0,
                "selective_update": true
            }'
            graph_cache_update_version "$version" "$version_data"
        else
            echo "Warning: Version file not found: $version_file" >&2
        fi
    done
    
    echo "Selective version sync completed" >&2
}

# @description Find versions that reference a specific task
# @arg $1 string Task number to search for
# @stdout List of version numbers that reference the task
# @stderr Status messages
# @exitcode 0 If successful
# @exitcode 1 If task parameter missing
graph_cache_find_versions_for_task() {
    local task="$1"
    
    if [[ -z "$task" ]]; then
        echo "Error: Task number required" >&2
        return 1
    fi
    
    # Find all version files that reference this task
    local project_root
    project_root="$(doh_project_dir)" || return 1
    
    local versions_dir="$project_root/versions"
    
    if [[ ! -d "$versions_dir" ]]; then
        return 0
    fi
    
    find "$versions_dir" -name "*.md" -type f | while read -r version_file; do
        if grep -q "$task" "$version_file"; then
            basename "$version_file" .md
        fi
    done
}

# @description Check if a version is ready for release
# @arg $1 string Version to check (e.g., "1.0.0")
# @stdout Status: "READY" if all tasks completed, "NOT_READY" or "PENDING" otherwise
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If version parameter missing
graph_cache_check_version_readiness() {
    local version="$1"
    
    if [[ -z "$version" ]]; then
        echo "Error: Version parameter required" >&2
        return 1
    fi
    
    # Find all task files with this version as target_version
    local project_root
    project_root="$(doh_project_dir)" || return 1
    
    # frontmatter.sh is already sourced at the top of this file
    
    local total_tasks=0
    local completed_tasks=0
    
    # Use process substitution to avoid subshell variable issues
    while IFS= read -r task_file; do
        if [[ -n "$task_file" ]] && frontmatter_has "$task_file"; then
            local target_version status
            target_version=$(frontmatter_get_field "$task_file" "target_version")
            status=$(frontmatter_get_field "$task_file" "status")
            
            if [[ "$target_version" == "$version" ]]; then
                total_tasks=$((total_tasks + 1))
                if [[ "$status" == "completed" ]]; then
                    completed_tasks=$((completed_tasks + 1))
                fi
            fi
        fi
    done < <(find "$project_root" -name "*.md" -type f)
    
    # Check readiness
    if [[ $total_tasks -eq 0 ]]; then
        echo "READY"  # No tasks required
    elif [[ $completed_tasks -eq $total_tasks ]]; then
        echo "READY"  # All tasks completed
    else
        echo "NOT_READY"  # Some tasks still pending
    fi
}

# Duplicate function removed - already renamed above as graph_cache_find_versions_for_task
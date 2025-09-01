#!/bin/bash

# Registry management utilities for DOH numbering system
# Handles JSON operations, cache management, and registry maintenance

# Source numbering library
source "$(dirname "${BASH_SOURCE[0]}")/numbering.sh"

# Cache refresh and validation functions

# @description Rebuild file cache from filesystem scan
# @stdout Progress messages during cache rebuild
# @stderr Error messages if rebuild fails
# @exitcode 0 If successful
# @exitcode 1 If error condition
rebuild_file_cache() {
    local registry_file
    registry_file="$(ensure_registry)" || return 1
    
    local project_root
    project_root="$(_find_doh_root)" || {
        echo "Error: Not in a DOH project" >&2
        return 1
    }
    
    echo "Rebuilding file cache from filesystem..." >&2
    
    # Acquire lock for atomic operation
    acquire_lock "$registry_file" || return 1
    
    # Create temporary registry with current global_sequence and graph_cache
    local temp_file=$(mktemp)
    jq '.file_cache = {}' "$registry_file" > "$temp_file"
    
    # Scan for epic files
    local epic_files
    epic_files=$(find "$project_root" -name "epic.md" -type f | sort)
    
    while IFS= read -r epic_file; do
        if [[ -n "$epic_file" ]]; then
            local rel_path epic_name epic_number
            rel_path=$(realpath --relative-to="$project_root" "$epic_file")
            
            # Extract name and number from frontmatter
            if [[ -f "$epic_file" ]]; then
                epic_name=$(grep -m 1 "^name:" "$epic_file" | cut -d':' -f2- | xargs)
                epic_number=$(grep -m 1 "^number:" "$epic_file" | cut -d':' -f2- | xargs)
                
                if [[ -n "$epic_name" && -n "$epic_number" ]]; then
                    local epic_data="{\"type\": \"epic\", \"path\": \"$rel_path\", \"name\": \"$epic_name\"}"
                    jq --arg num "$epic_number" --argjson data "$epic_data" '.file_cache[$num] = $data' "$temp_file" > "$temp_file.tmp" && mv "$temp_file.tmp" "$temp_file"
                fi
            fi
        fi
    done <<< "$epic_files"
    
    # Scan for task files  
    local task_files
    task_files=$(find "$project_root" -name "*.md" -path "*/.doh/epics/*" -not -name "epic.md" -type f | sort)
    
    while IFS= read -r task_file; do
        if [[ -n "$task_file" ]]; then
            local rel_path task_name task_number parent_number epic_name
            rel_path=$(realpath --relative-to="$project_root" "$task_file")
            
            # Extract metadata from frontmatter
            if [[ -f "$task_file" ]]; then
                task_name=$(grep -m 1 "^name:" "$task_file" | cut -d':' -f2- | xargs)
                task_number=$(grep -m 1 "^number:" "$task_file" | cut -d':' -f2- | xargs)
                parent_number=$(grep -m 1 "^parent:" "$task_file" | cut -d':' -f2- | xargs)
                
                # Extract epic name from path or frontmatter
                if grep -q "^epic:" "$task_file"; then
                    epic_name=$(grep -m 1 "^epic:" "$task_file" | cut -d':' -f2- | xargs)
                else
                    # Infer from path: .doh/epics/epic-name/
                    epic_name=$(echo "$rel_path" | sed -n 's|^\.doh/epics/\([^/]*\)/.*|\1|p')
                fi
                
                if [[ -n "$task_name" && -n "$task_number" ]]; then
                    local task_data="{\"type\": \"task\", \"path\": \"$rel_path\", \"name\": \"$task_name\""
                    
                    if [[ -n "$epic_name" ]]; then
                        task_data="$task_data, \"epic\": \"$epic_name\""
                    fi
                    
                    task_data="$task_data}"
                    
                    jq --arg num "$task_number" --argjson data "$task_data" '.file_cache[$num] = $data' "$temp_file" > "$temp_file.tmp" && mv "$temp_file.tmp" "$temp_file"
                fi
            fi
        fi
    done <<< "$task_files"
    
    # Add QUICK epic if not present
    local quick_exists
    quick_exists=$(jq -r '.file_cache["000"]' "$temp_file")
    if [[ "$quick_exists" == "null" ]]; then
        local quick_data='{"type": "epic", "path": ".doh/quick/manifest.md", "name": "QUICK"}'
        jq --argjson data "$quick_data" '.file_cache["000"] = $data' "$temp_file" > "$temp_file.tmp" && mv "$temp_file.tmp" "$temp_file"
    fi
    
    # Replace registry
    mv "$temp_file" "$registry_file"
    
    release_lock
    
    echo "File cache rebuilt successfully" >&2
    return 0
}

# @description Rebuild graph cache from file relationships
# @stdout Progress messages during cache rebuild
# @stderr Error messages if rebuild fails
# @exitcode 0 If successful
# @exitcode 1 If error condition
rebuild_graph_cache() {
    local registry_file
    registry_file="$(ensure_registry)" || return 1
    
    local project_root
    project_root="$(_find_doh_root)" || return 1
    
    echo "Rebuilding graph cache from file relationships..." >&2
    
    # Acquire lock for atomic operation
    acquire_lock "$registry_file" || return 1
    
    # Clear existing graph cache
    local temp_file=$(mktemp)
    jq '.graph_cache = {}' "$registry_file" > "$temp_file"
    
    # Scan all numbered files for parent relationships
    local numbered_files
    numbered_files=$(find "$project_root" -name "*.md" -path "*/.doh/epics/*" -type f | sort)
    
    while IFS= read -r file; do
        if [[ -n "$file" && -f "$file" ]]; then
            local file_number parent_number epic_name
            
            # Extract metadata from frontmatter
            file_number=$(grep -m 1 "^number:" "$file" | cut -d':' -f2- | xargs)
            parent_number=$(grep -m 1 "^parent:" "$file" | cut -d':' -f2- | xargs)
            
            # Extract epic name
            if grep -q "^epic:" "$file"; then
                epic_name=$(grep -m 1 "^epic:" "$file" | cut -d':' -f2- | xargs)
            else
                # Infer from path
                local rel_path
                rel_path=$(realpath --relative-to="$project_root" "$file")
                epic_name=$(echo "$rel_path" | sed -n 's|^\.doh/epics/\([^/]*\)/.*|\1|p')
            fi
            
            # Add to graph cache if has parent or epic
            if [[ -n "$file_number" && ( -n "$parent_number" || -n "$epic_name" ) ]]; then
                local graph_data="{"
                
                if [[ -n "$parent_number" ]]; then
                    graph_data="$graph_data\"parent\": \"$parent_number\""
                    
                    if [[ -n "$epic_name" ]]; then
                        graph_data="$graph_data, "
                    fi
                fi
                
                if [[ -n "$epic_name" ]]; then
                    graph_data="$graph_data\"epic\": \"$epic_name\""
                fi
                
                graph_data="$graph_data}"
                
                jq --arg num "$file_number" --argjson data "$graph_data" '.graph_cache[$num] = $data' "$temp_file" > "$temp_file.tmp" && mv "$temp_file.tmp" "$temp_file"
            fi
        fi
    done <<< "$numbered_files"
    
    # Replace registry
    mv "$temp_file" "$registry_file"
    
    release_lock
    
    echo "Graph cache rebuilt successfully" >&2
    return 0
}

# @description Validate registry consistency with filesystem
# @stdout Validation progress and results
# @stderr Error messages for inconsistencies found
# @exitcode 0 If consistent
# @exitcode 1 If issues found
validate_registry_consistency() {
    local registry_file
    registry_file="$(ensure_registry)" || return 1
    
    local project_root
    project_root="$(_find_doh_root)" || return 1
    
    local errors=0
    
    echo "Validating registry consistency..." >&2
    
    # Check that all cached files exist
    local cached_numbers
    cached_numbers=$(jq -r '.file_cache | keys[]' "$registry_file")
    
    while IFS= read -r number; do
        if [[ -n "$number" ]]; then
            local cached_path actual_path
            cached_path=$(jq -r --arg num "$number" '.file_cache[$num].path' "$registry_file")
            actual_path="$project_root/$cached_path"
            
            if [[ ! -f "$actual_path" ]]; then
                echo "Error: Cached file missing: $actual_path" >&2
                ((errors++))
            else
                # Verify number in file matches cache
                local file_number
                file_number=$(grep -m 1 "^number:" "$actual_path" | cut -d':' -f2- | xargs)
                
                if [[ "$file_number" != "$number" ]]; then
                    echo "Error: Number mismatch for $actual_path: cached=$number, file=$file_number" >&2
                    ((errors++))
                fi
            fi
        fi
    done <<< "$cached_numbers"
    
    # Check for uncached numbered files
    local numbered_files
    numbered_files=$(find "$project_root" -name "*.md" -path "*/.doh/*" -type f -exec grep -l "^number:" {} \;)
    
    while IFS= read -r file; do
        if [[ -n "$file" ]]; then
            local file_number cached_entry
            file_number=$(grep -m 1 "^number:" "$file" | cut -d':' -f2- | xargs)
            
            if [[ -n "$file_number" ]]; then
                cached_entry=$(jq -r --arg num "$file_number" '.file_cache[$num]' "$registry_file")
                
                if [[ "$cached_entry" == "null" ]]; then
                    echo "Error: Numbered file not in cache: $file (number: $file_number)" >&2
                    ((errors++))
                fi
            fi
        fi
    done <<< "$numbered_files"
    
    if [[ $errors -eq 0 ]]; then
        echo "Registry consistency check passed" >&2
        return 0
    else
        echo "Registry consistency check failed with $errors errors" >&2
        return 1
    fi
}

# @description Self-healing: detect and fix registry issues
# @stdout Progress messages during healing process
# @stderr Error messages if healing fails
# @exitcode 0 If successful
# @exitcode 1 If error condition
heal_registry() {
    local registry_file
    registry_file="$(ensure_registry)" || return 1
    
    echo "Running registry self-healing..." >&2
    
    # First validate consistency
    if validate_registry_consistency; then
        echo "Registry is consistent, no healing needed" >&2
        return 0
    fi
    
    echo "Registry inconsistencies detected, rebuilding caches..." >&2
    
    # Rebuild both caches from filesystem
    rebuild_file_cache || {
        echo "Error: Failed to rebuild file cache" >&2
        return 1
    }
    
    rebuild_graph_cache || {
        echo "Error: Failed to rebuild graph cache" >&2
        return 1
    }
    
    # Validate again
    if validate_registry_consistency; then
        echo "Registry healing completed successfully" >&2
        return 0
    else
        echo "Error: Registry healing failed" >&2
        return 1
    fi
}

# @description Update TASKSEQ to match actual usage
# @stdout Progress messages and final TASKSEQ value
# @stderr Error messages if synchronization fails
# @exitcode 0 If successful
# @exitcode 1 If error condition
sync_taskseq() {
    local registry_file
    registry_file="$(ensure_registry)" || return 1
    
    local taskseq_file
    taskseq_file="$(get_taskseq_path)" || return 1
    
    echo "Synchronizing TASKSEQ..." >&2
    
    # Get all used numbers from file cache
    local max_number
    max_number=$(jq -r '.file_cache | keys[] | tonumber' "$registry_file" | sort -n | tail -n 1)
    
    if [[ -z "$max_number" || "$max_number" == "" ]]; then
        max_number="0"
    fi
    
    # Acquire lock and update TASKSEQ
    acquire_lock "$taskseq_file" || return 1
    
    echo "$max_number" > "$taskseq_file" || {
        release_lock
        echo "Error: Failed to update TASKSEQ" >&2
        return 1
    }
    
    release_lock
    
    echo "TASKSEQ synchronized to: $max_number" >&2
    return 0
}

# @description Registry maintenance command
# @arg $1 string Maintenance action to perform (rebuild-cache|validate|heal|sync|full)
# @stdout Progress messages and results
# @stderr Error messages and usage information
# @exitcode 0 If successful
# @exitcode 1 If error condition
registry_maintenance() {
    local action="$1"
    
    case "$action" in
        "rebuild-cache")
            rebuild_file_cache && rebuild_graph_cache
            ;;
        "validate")
            validate_registry_consistency
            ;;
        "heal")
            heal_registry
            ;;
        "sync")
            sync_taskseq
            ;;
        "full")
            echo "Running full registry maintenance..." >&2
            heal_registry && sync_taskseq
            ;;
        *)
            echo "Usage: registry_maintenance {rebuild-cache|validate|heal|sync|full}" >&2
            return 1
            ;;
    esac
}
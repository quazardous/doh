#!/bin/bash

# Graph cache for tracking parent/child relationships and dependencies
# One-way cache: stores parent relationships for fast lookup

# Source required dependencies
source "$(dirname "${BASH_SOURCE[0]}")/workspace.sh"
source "$(dirname "${BASH_SOURCE[0]}")/numbering.sh"

# @description Get graph cache path
# @stdout Path to the graph cache JSON file
# @exitcode 0 If successful
# @exitcode 1 If unable to determine project ID
get_graph_cache_path() {
    local project_id
    project_id="$(get_current_project_id)" || return 1
    
    echo "$HOME/.doh/projects/$project_id/graph_cache.json"
}

# @description Initialize empty graph cache
# @arg $1 string Path to the cache file to create
# @exitcode 0 If successful
# @exitcode 1 If unable to create cache file
create_empty_graph_cache() {
    local cache_file="$1"
    
    mkdir -p "$(dirname "$cache_file")"
    
    cat > "$cache_file" << EOF
{
  "relationships": {},
  "last_updated": "$(date -Iseconds)",
  "version": "1.0"
}
EOF
}

# @description Ensure graph cache exists
# @stdout Path to the ensured cache file
# @stderr Warning messages if cache needs rebuilding
# @exitcode 0 If successful
# @exitcode 1 If unable to create or validate cache
ensure_graph_cache() {
    local cache_file
    cache_file="$(get_graph_cache_path)" || return 1
    
    if [[ ! -f "$cache_file" ]]; then
        create_empty_graph_cache "$cache_file" || return 1
    fi
    
    # Validate cache structure
    if ! jq -e '.relationships' "$cache_file" >/dev/null 2>&1; then
        echo "Warning: Corrupted graph cache, rebuilding..." >&2
        create_empty_graph_cache "$cache_file" || return 1
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
add_relationship() {
    local number="$1"
    local parent_number="$2"  # Optional
    local epic_name="$3"      # Optional
    
    if [[ -z "$number" ]]; then
        echo "Error: Number parameter required" >&2
        return 1
    fi
    
    local cache_file
    cache_file="$(ensure_graph_cache)" || return 1
    
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
        acquire_lock "$cache_file" || return 1
        
        local temp_file=$(mktemp)
        jq --arg num "$number" --argjson rel "$relationship" --arg timestamp "$(date -Iseconds)" '
            .relationships[$num] = $rel |
            .last_updated = $timestamp
        ' "$cache_file" > "$temp_file" && mv "$temp_file" "$cache_file"
        
        release_lock
    fi
    
    return 0
}

# @description Remove relationship from graph cache
# @arg $1 string Number whose relationship to remove
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If number parameter missing or cache update fails
remove_relationship() {
    local number="$1"
    
    if [[ -z "$number" ]]; then
        echo "Error: Number parameter required" >&2
        return 1
    fi
    
    local cache_file
    cache_file="$(ensure_graph_cache)" || return 1
    
    # Acquire lock for atomic update
    acquire_lock "$cache_file" || return 1
    
    local temp_file=$(mktemp)
    jq --arg num "$number" --arg timestamp "$(date -Iseconds)" '
        del(.relationships[$num]) |
        .last_updated = $timestamp
    ' "$cache_file" > "$temp_file" && mv "$temp_file" "$cache_file"
    
    release_lock
    
    return 0
}

# @description Get parent of a number
# @arg $1 string Number to find parent for
# @stdout Parent number if found
# @stderr Error messages
# @exitcode 0 If parent found
# @exitcode 1 If number parameter missing or parent not found
get_parent() {
    local number="$1"
    
    if [[ -z "$number" ]]; then
        echo "Error: Number parameter required" >&2
        return 1
    fi
    
    local cache_file
    cache_file="$(ensure_graph_cache)" || return 1
    
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
get_epic() {
    local number="$1"
    
    if [[ -z "$number" ]]; then
        echo "Error: Number parameter required" >&2
        return 1
    fi
    
    local cache_file
    cache_file="$(ensure_graph_cache)" || return 1
    
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
get_children() {
    local parent_number="$1"
    
    if [[ -z "$parent_number" ]]; then
        echo "Error: Parent number parameter required" >&2
        return 1
    fi
    
    local cache_file
    cache_file="$(ensure_graph_cache)" || return 1
    
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
get_epic_items() {
    local epic_name="$1"
    
    if [[ -z "$epic_name" ]]; then
        echo "Error: Epic name parameter required" >&2
        return 1
    fi
    
    local cache_file
    cache_file="$(ensure_graph_cache)" || return 1
    
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
rebuild_graph_cache() {
    local project_root
    project_root="$(_find_doh_root)" || return 1
    
    local cache_file
    cache_file="$(ensure_graph_cache)" || return 1
    
    echo "Rebuilding graph cache..." >&2
    
    # Create fresh cache
    create_empty_graph_cache "$cache_file"
    
    # Scan all numbered files for relationships
    local numbered_files
    numbered_files=$(find "$project_root" -name "*.md" -path "*/.doh/*" -type f -exec grep -l "^number:" {} \;)
    
    while IFS= read -r file; do
        if [[ -n "$file" && -f "$file" ]]; then
            local number parent_number epic_name
            
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
                add_relationship "$number" "$parent_number" "$epic_name"
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
validate_graph_cache() {
    local cache_file
    cache_file="$(ensure_graph_cache)" || return 1
    
    local project_root
    project_root="$(_find_doh_root)" || return 1
    
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
heal_graph_cache() {
    echo "Running graph cache self-healing..." >&2
    
    if validate_graph_cache; then
        echo "Graph cache is healthy" >&2
        return 0
    fi
    
    echo "Rebuilding graph cache..." >&2
    rebuild_graph_cache
    
    if validate_graph_cache; then
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
get_graph_cache_stats() {
    local cache_file
    cache_file="$(ensure_graph_cache)" || return 1
    
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
print_relationship_tree() {
    local cache_file
    cache_file="$(ensure_graph_cache)" || return 1
    
    echo "Relationship Tree:" >&2
    
    # Find root items (no parent)
    local roots
    roots=$(jq -r '.relationships | to_entries[] | select(.value.parent == null or (.value | has("parent") | not)) | .key' "$cache_file" | sort -n)
    
    while IFS= read -r root; do
        if [[ -n "$root" ]]; then
            _print_tree_node "$root" 0
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
_print_tree_node() {
    local number="$1"
    local depth="$2"
    
    local cache_file
    cache_file="$(ensure_graph_cache)" || return 1
    
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
    children=$(get_children "$number" 2>/dev/null)
    
    while IFS= read -r child; do
        if [[ -n "$child" ]]; then
            _print_tree_node "$child" $((depth + 1))
        fi
    done <<< "$children"
}
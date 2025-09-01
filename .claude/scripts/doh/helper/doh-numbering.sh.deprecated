#!/bin/bash

# DOH Command Integration with Numbering Library
# Helper functions for integrating numbering system with DOH commands

# Source required dependencies
LIB_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$LIB_DIR/numbering.sh"
source "$LIB_DIR/file-cache.sh" 
source "$LIB_DIR/graph-cache.sh"
source "$LIB_DIR/frontmatter.sh"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create numbered epic with integrated numbering system
# Usage: create_numbered_epic <epic_name> <epic_dir> <frontmatter_data>
create_numbered_epic() {
    local epic_name="$1"
    local epic_dir="$2"
    local frontmatter_data="$3"  # JSON object with frontmatter fields
    
    if [[ -z "$epic_name" || -z "$epic_dir" ]]; then
        echo "Error: Epic name and directory required" >&2
        return 1
    fi
    
    # Get next epic number
    local epic_number
    epic_number=$(get_next_number "epic") || {
        echo "Error: Could not allocate epic number" >&2
        return 1
    }
    
    echo -e "${BLUE}📝 Assigned epic number: $epic_number${NC}" >&2
    
    # Ensure epic directory exists
    mkdir -p "$epic_dir" || {
        echo "Error: Could not create epic directory: $epic_dir" >&2
        return 1
    }
    
    local epic_file="$epic_dir/epic.md"
    
    # Build frontmatter with number
    local base_frontmatter='{}'
    base_frontmatter=$(echo "$base_frontmatter" | jq --arg name "$epic_name" '. + {name: $name}')
    base_frontmatter=$(echo "$base_frontmatter" | jq --arg number "$epic_number" '. + {number: $number}')
    base_frontmatter=$(echo "$base_frontmatter" | jq '. + {status: "backlog"}')
    base_frontmatter=$(echo "$base_frontmatter" | jq --arg created "$(date -Iseconds)" '. + {created: $created}')
    base_frontmatter=$(echo "$base_frontmatter" | jq '. + {"progress": "0%"}')
    base_frontmatter=$(echo "$base_frontmatter" | jq '. + {github: "[Will be updated when synced to GitHub]"}')
    
    # Merge with provided frontmatter data
    if [[ -n "$frontmatter_data" ]]; then
        base_frontmatter=$(echo "$base_frontmatter" | jq --argjson extra "$frontmatter_data" '. * $extra')
    fi
    
    # Convert to YAML frontmatter
    local yaml_frontmatter
    yaml_frontmatter=$(echo "$base_frontmatter" | jq -r '
        "---\n" +
        "name: " + .name + "\n" +
        "number: " + .number + "\n" +
        "status: " + .status + "\n" +
        "created: " + .created + "\n" +
        "progress: " + .progress + "\n" +
        (if .prd then "prd: " + .prd + "\n" else "" end) +
        "github: " + .github + "\n" +
        "---"
    ')
    
    # For now, just write the frontmatter (content will be added by the calling command)
    echo "$yaml_frontmatter" > "$epic_file"
    
    # Register epic in numbering system
    local project_root
    project_root="$(_find_doh_root)" || return 1
    local rel_path
    rel_path=$(realpath --relative-to="$project_root" "$epic_file")
    
    register_epic "$epic_number" "$rel_path" "$epic_name" || {
        echo "Warning: Could not register epic in numbering system" >&2
    }
    
    # Add to file cache
    add_to_file_cache "$epic_number" "epic" "$rel_path" "$epic_name" || {
        echo "Warning: Could not add epic to file cache" >&2
    }
    
    echo -e "${GREEN}✅ Epic created with number $epic_number: $epic_file${NC}" >&2
    echo "$epic_number"
}

# Create numbered task with integrated numbering system
# Usage: create_numbered_task <task_name> <task_dir> <parent_number> <epic_name> <frontmatter_data>
create_numbered_task() {
    local task_name="$1"
    local task_dir="$2"
    local parent_number="$3"    # Optional parent number
    local epic_name="$4"        # Epic name for organization
    local frontmatter_data="$5" # JSON object with frontmatter fields
    
    if [[ -z "$task_name" || -z "$task_dir" || -z "$epic_name" ]]; then
        echo "Error: Task name, directory, and epic name required" >&2
        return 1
    fi
    
    # Get next task number
    local task_number
    task_number=$(get_next_number "task") || {
        echo "Error: Could not allocate task number" >&2
        return 1
    }
    
    echo -e "${BLUE}📝 Assigned task number: $task_number${NC}" >&2
    
    # Ensure task directory exists
    mkdir -p "$task_dir" || {
        echo "Error: Could not create task directory: $task_dir" >&2
        return 1
    }
    
    local task_file="$task_dir/${task_number}.md"
    
    # Build frontmatter with number
    local base_frontmatter='{}'
    base_frontmatter=$(echo "$base_frontmatter" | jq --arg name "$task_name" '. + {name: $name}')
    base_frontmatter=$(echo "$base_frontmatter" | jq --arg number "$task_number" '. + {number: $number}')
    base_frontmatter=$(echo "$base_frontmatter" | jq '. + {status: "open"}')
    base_frontmatter=$(echo "$base_frontmatter" | jq --arg created "$(date -Iseconds)" '. + {created: $created}')
    base_frontmatter=$(echo "$base_frontmatter" | jq --arg updated "$(date -Iseconds)" '. + {updated: $updated}')
    base_frontmatter=$(echo "$base_frontmatter" | jq '. + {github: "[Will be updated when synced to GitHub]"}')
    base_frontmatter=$(echo "$base_frontmatter" | jq --arg epic "$epic_name" '. + {epic: $epic}')
    
    # Add parent if provided
    if [[ -n "$parent_number" ]]; then
        base_frontmatter=$(echo "$base_frontmatter" | jq --arg parent "$parent_number" '. + {parent: $parent}')
    fi
    
    # Default dependency and parallel fields
    base_frontmatter=$(echo "$base_frontmatter" | jq '. + {depends_on: []}')
    base_frontmatter=$(echo "$base_frontmatter" | jq '. + {parallel: true}')
    base_frontmatter=$(echo "$base_frontmatter" | jq '. + {conflicts_with: []}')
    
    # Merge with provided frontmatter data
    if [[ -n "$frontmatter_data" ]]; then
        base_frontmatter=$(echo "$base_frontmatter" | jq --argjson extra "$frontmatter_data" '. * $extra')
    fi
    
    # Convert to YAML frontmatter
    local yaml_frontmatter
    yaml_frontmatter=$(echo "$base_frontmatter" | jq -r '
        "---\n" +
        "name: " + .name + "\n" +
        "number: " + .number + "\n" +
        "status: " + .status + "\n" +
        "created: " + .created + "\n" +
        "updated: " + .updated + "\n" +
        "github: " + .github + "\n" +
        "epic: " + .epic + "\n" +
        (if .parent then "parent: " + .parent + "\n" else "" end) +
        "depends_on: " + (.depends_on | tostring) + "\n" +
        "parallel: " + (.parallel | tostring) + "\n" +
        "conflicts_with: " + (.conflicts_with | tostring) + "\n" +
        "---"
    ')
    
    # For now, just write the frontmatter (content will be added by the calling command)  
    echo "$yaml_frontmatter" > "$task_file"
    
    # Register task in numbering system
    local project_root
    project_root="$(_find_doh_root)" || return 1
    local rel_path
    rel_path=$(realpath --relative-to="$project_root" "$task_file")
    
    register_task "$task_number" "$parent_number" "$rel_path" "$task_name" "$epic_name" || {
        echo "Warning: Could not register task in numbering system" >&2
    }
    
    # Add to file cache
    add_to_file_cache "$task_number" "task" "$rel_path" "$task_name" "$epic_name" || {
        echo "Warning: Could not add task to file cache" >&2
    }
    
    # Add to graph cache if has parent
    if [[ -n "$parent_number" ]]; then
        add_relationship "$task_number" "$parent_number" "$epic_name" || {
            echo "Warning: Could not add task relationship to graph cache" >&2
        }
    fi
    
    echo -e "${GREEN}✅ Task created with number $task_number: $task_file${NC}" >&2
    echo "$task_number"
}

# Batch create multiple tasks for epic decomposition
# Usage: batch_create_tasks <epic_name> <epic_dir> <parent_number> <tasks_json>
batch_create_tasks() {
    local epic_name="$1"
    local epic_dir="$2"
    local parent_number="$3"  # Epic number - parent for all tasks
    local tasks_json="$4"     # JSON array of task objects
    
    if [[ -z "$epic_name" || -z "$epic_dir" || -z "$tasks_json" ]]; then
        echo "Error: Epic name, directory, and tasks JSON required" >&2
        return 1
    fi
    
    echo -e "${BLUE}🔢 Creating numbered tasks for epic: $epic_name${NC}" >&2
    
    local created_tasks=()
    local task_count
    task_count=$(echo "$tasks_json" | jq -r 'length')
    
    echo -e "${BLUE}📋 Creating $task_count tasks...${NC}" >&2
    
    # Process each task
    for ((i=0; i<task_count; i++)); do
        local task_info
        task_info=$(echo "$tasks_json" | jq -r ".[$i]")
        
        local task_name task_frontmatter
        task_name=$(echo "$task_info" | jq -r '.name')
        task_frontmatter=$(echo "$task_info" | jq 'del(.name)')  # Remove name, it's handled separately
        
        if [[ -n "$task_name" ]]; then
            local task_number
            task_number=$(create_numbered_task "$task_name" "$epic_dir" "$parent_number" "$epic_name" "$task_frontmatter")
            
            if [[ -n "$task_number" ]]; then
                created_tasks+=("$task_number")
            else
                echo "Error: Failed to create task: $task_name" >&2
            fi
        fi
    done
    
    local success_count=${#created_tasks[@]}
    echo -e "${GREEN}✅ Successfully created $success_count/$task_count tasks${NC}" >&2
    
    # Return created task numbers as JSON array
    printf '%s\n' "${created_tasks[@]}" | jq -R . | jq -s .
}

# Update epic with task summary after decomposition
# Usage: update_epic_with_tasks <epic_file> <task_numbers_array>
update_epic_with_tasks() {
    local epic_file="$1"
    local task_numbers_json="$2"  # JSON array of task numbers
    
    if [[ ! -f "$epic_file" || -z "$task_numbers_json" ]]; then
        echo "Error: Epic file and task numbers required" >&2
        return 1
    fi
    
    local task_count
    task_count=$(echo "$task_numbers_json" | jq -r 'length')
    
    echo -e "${BLUE}📝 Updating epic with $task_count tasks...${NC}" >&2
    
    # Build task summary section
    local tasks_section="## Tasks Created\n"
    
    local parallel_count=0
    local sequential_count=0
    local total_effort=0
    
    # Process each task number
    while IFS= read -r task_number; do
        if [[ -n "$task_number" && "$task_number" != "null" ]]; then
            local task_file_path
            task_file_path=$(find_file_by_number "$task_number" 2>/dev/null)
            
            if [[ -n "$task_file_path" ]]; then
                local project_root
                project_root="$(_find_doh_root)" || continue
                local full_task_path="$project_root/$task_file_path"
                
                if [[ -f "$full_task_path" ]]; then
                    local task_name parallel_flag
                    task_name=$(grep -m 1 "^name:" "$full_task_path" | cut -d':' -f2- | xargs)
                    parallel_flag=$(grep -m 1 "^parallel:" "$full_task_path" | cut -d':' -f2- | xargs)
                    
                    tasks_section="${tasks_section}- [ ] ${task_number}.md - ${task_name} (parallel: ${parallel_flag})\n"
                    
                    if [[ "$parallel_flag" == "true" ]]; then
                        ((parallel_count++))
                    else
                        ((sequential_count++))
                    fi
                fi
            fi
        fi
    done <<< "$(echo "$task_numbers_json" | jq -r '.[]')"
    
    # Append summary
    tasks_section="${tasks_section}\n"
    tasks_section="${tasks_section}Total tasks: $task_count\n"
    tasks_section="${tasks_section}Parallel tasks: $parallel_count\n"
    tasks_section="${tasks_section}Sequential tasks: $sequential_count\n"
    
    # Append to epic file (before any existing content)
    local temp_file=$(mktemp)
    
    # Read current content and append tasks section
    if [[ -f "$epic_file" ]]; then
        # Add tasks section at the end of the file
        {
            cat "$epic_file"
            echo ""
            echo -e "$tasks_section"
        } > "$temp_file"
        
        mv "$temp_file" "$epic_file"
        echo -e "${GREEN}✅ Epic updated with task summary${NC}" >&2
    fi
    
    return 0
}

# Get current project numbering statistics
get_project_numbering_stats() {
    echo -e "${YELLOW}Project Numbering Statistics${NC}" >&2
    echo "============================" >&2
    
    # Registry statistics
    get_registry_stats
    
    echo "" >&2
    
    # File cache statistics  
    get_file_cache_stats
    
    echo "" >&2
    
    # Graph cache statistics
    get_graph_cache_stats
}

# Validate project numbering consistency
validate_project_numbering() {
    echo -e "${BLUE}🔍 Validating project numbering consistency...${NC}" >&2
    
    local issues=0
    
    # Validate registry consistency
    if ! validate_registry_consistency >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠ Registry consistency issues detected${NC}" >&2
        ((issues++))
    fi
    
    # Validate file cache
    if ! detect_duplicates >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠ File cache issues detected${NC}" >&2
        ((issues++))
    fi
    
    # Validate graph cache
    if ! validate_graph_cache >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠ Graph cache issues detected${NC}" >&2
        ((issues++))
    fi
    
    if [[ $issues -eq 0 ]]; then
        echo -e "${GREEN}✅ Numbering system is consistent${NC}" >&2
        return 0
    else
        echo -e "${YELLOW}⚠ Found $issues consistency issues${NC}" >&2
        echo -e "${YELLOW}Consider running migration tools to fix issues${NC}" >&2
        return 1
    fi
}

# Initialize project numbering system
init_project_numbering() {
    echo -e "${BLUE}🚀 Initializing project numbering system...${NC}" >&2
    
    # Ensure registry exists
    local registry_file
    registry_file="$(ensure_registry)" || {
        echo "Error: Could not initialize registry" >&2
        return 1
    }
    
    # Ensure caches exist  
    ensure_file_cache >/dev/null
    ensure_graph_cache >/dev/null
    
    # Rebuild caches from existing files
    rebuild_file_cache >/dev/null 2>&1
    rebuild_graph_cache >/dev/null 2>&1
    
    echo -e "${GREEN}✅ Numbering system initialized${NC}" >&2
    
    # Show statistics
    get_project_numbering_stats
    
    return 0
}
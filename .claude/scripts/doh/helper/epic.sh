#!/bin/bash

# DOH Epic Helper
# User-facing functions for epic management operations

# Source required dependencies
source "$(dirname "${BASH_SOURCE[0]}")/../lib/epic.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/frontmatter.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/numbering.sh"

# Guard against multiple sourcing
[[ -n "${DOH_HELPER_EPIC_LOADED:-}" ]] && return 0
DOH_HELPER_EPIC_LOADED=1

# @description List all epics categorized by status
# @stdout Formatted list of epics with status categorization and summary
# @stderr Error messages
# @exitcode 0 If successful
helper_epic_list() {
    echo "Getting epics..."
    echo ""
    echo ""

    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }

    if [ ! -d "$doh_dir/epics" ]; then
        echo "📁 No epics directory found. Create your first epic with: /doh:prd-parse <feature-name>"
        return 0
    fi
    
    if [ -z "$(ls -d "$doh_dir"/epics/*/ 2>/dev/null)" ]; then
        echo "📁 No epics found. Create your first epic with: /doh:prd-parse <feature-name>"
        return 0
    fi

    echo "📚 Project Epics"
    echo "================"
    echo ""

    # Initialize arrays to store epics by status
    local planning_epics="" in_progress_epics="" completed_epics=""

    # Process all epics
    for dir in "$doh_dir"/epics/*/; do
        [ -d "$dir" ] || continue
        [ -f "$dir/epic.md" ] || continue

        # Extract metadata using frontmatter if available, fallback to grep
        local name status progress github
        if command -v frontmatter_get_field >/dev/null 2>&1; then
            name=$(frontmatter_get_field "$dir/epic.md" "name" 2>/dev/null)
            status=$(frontmatter_get_field "$dir/epic.md" "status" 2>/dev/null)
            progress=$(frontmatter_get_field "$dir/epic.md" "progress" 2>/dev/null)
            github=$(frontmatter_get_field "$dir/epic.md" "github" 2>/dev/null)
        else
            # Fallback to grep
            name=$(grep "^name:" "$dir/epic.md" | head -1 | sed 's/^name: *//')
            status=$(grep "^status:" "$dir/epic.md" | head -1 | sed 's/^status: *//' | tr '[:upper:]' '[:lower:]')
            progress=$(grep "^progress:" "$dir/epic.md" | head -1 | sed 's/^progress: *//')
            github=$(grep "^github:" "$dir/epic.md" | head -1 | sed 's/^github: *//')
        fi

        # Defaults
        [ -z "$name" ] && name=$(basename "$dir")
        [ -z "$progress" ] && progress="0%"
        [ -z "$status" ] && status=""

        # Count tasks
        local task_count
        if ls "$dir"[0-9]*.md >/dev/null 2>&1; then
            task_count=$(ls "$dir"[0-9]*.md 2>/dev/null | wc -l)
        else
            task_count=0
        fi

        # Format output with GitHub issue number if available
        local entry
        if [ -n "$github" ] && echo "$github" | grep -q '/[0-9]*$'; then
            local issue_num
            issue_num=$(echo "$github" | grep -o '/[0-9]*$' | tr -d '/')
            entry="   📋 ${dir}epic.md (#$issue_num) - $progress complete ($task_count tasks)"
        else
            entry="   📋 ${dir}epic.md - $progress complete ($task_count tasks)"
        fi

        # Categorize by status (handle various status values)
        case "$status" in
            planning|draft|"")
                planning_epics="${planning_epics}${entry}\n"
                ;;
            in-progress|in_progress|active|started)
                in_progress_epics="${in_progress_epics}${entry}\n"
                ;;
            completed|complete|done|closed|finished)
                completed_epics="${completed_epics}${entry}\n"
                ;;
            *)
                # Default to planning for unknown statuses
                planning_epics="${planning_epics}${entry}\n"
                ;;
        esac
    done

    # Display categorized epics
    echo "📝 Planning:"
    if [ -n "$planning_epics" ]; then
        printf "%b" "$planning_epics" | grep -v '^$'
    else
        echo "   (none)"
    fi

    echo ""
    echo "🚀 In Progress:"
    if [ -n "$in_progress_epics" ]; then
        printf "%b" "$in_progress_epics" | grep -v '^$'
    else
        echo "   (none)"
    fi

    echo ""
    echo "✅ Completed:"
    if [ -n "$completed_epics" ]; then
        printf "%b" "$completed_epics" | grep -v '^$'
    else
        echo "   (none)"
    fi

    # Summary
    echo ""
    echo "📊 Summary"
    local total tasks
    total=$(ls -d "$doh_dir"/epics/*/ 2>/dev/null | wc -l)
    tasks=$(find "$doh_dir"/epics -name "[0-9]*.md" 2>/dev/null | wc -l)
    echo "   Total epics: $total"
    echo "   Total tasks: $tasks"

    return 0
}

# @description Show detailed epic information
# @arg $1 string Epic name (required)
# @stdout Detailed epic information and task breakdown
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If epic not found or no name provided
helper_epic_show() {
    if [ -z "$1" ]; then
        echo "Usage: epic show <epic-name>" >&2
        return 1
    fi

    # Call the library function which already provides user-friendly output
    epic_show "$@"
}

# @description Get epic status with progress and task breakdown
# @arg $1 string Epic name (required)
# @stdout Epic status report with progress bar and task counts
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If epic not found or no name provided
helper_epic_status() {
    if [ -z "$1" ]; then
        echo "Usage: epic status <epic-name>" >&2
        echo ""
        echo "Available epics:"
        helper_epic_list | grep "📋" | head -10
        return 1
    fi

    # Call the library function which already provides user-friendly output
    epic_get_status "$@"
}

# @description Get tasks from an epic by status
# @arg $1 string Epic name (required)
# @arg $2 string Optional status filter (pending|in_progress|completed|blocked)
# @stdout List of task numbers/files with status
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If epic not found or no name provided
helper_epic_tasks() {
    if [ -z "$1" ]; then
        echo "Usage: epic tasks <epic-name> [status]" >&2
        echo "Status options: pending, in_progress, completed, blocked" >&2
        return 1
    fi

    local epic_name="$1"
    local status_filter="${2:-}"

    echo "📋 Tasks in epic: $epic_name"
    if [ -n "$status_filter" ]; then
        echo "Filter: $status_filter"
    fi
    echo "=========================="
    echo ""

    # Get tasks using library function
    local tasks
    tasks=$(epic_get_tasks "$epic_name" "$status_filter" 2>/dev/null)
    
    if [ -z "$tasks" ]; then
        echo "No tasks found"
        if [ -n "$status_filter" ]; then
            echo "Try without status filter: epic tasks $epic_name"
        fi
        return 0
    fi

    # Display tasks with more user-friendly format
    local count=0
    while IFS= read -r task_num; do
        if [ -n "$task_num" ]; then
            echo "  • Task $task_num"
            ((count++))
        fi
    done <<< "$tasks"

    echo ""
    echo "Total: $count tasks"
    
    if [ -n "$status_filter" ]; then
        echo "Status: $status_filter"
    fi

    return 0
}

# @description Display epic command help
# @stdout Help information for epic commands
# @exitcode 0 Always successful
helper_epic_help() {
    echo "DOH Epic Management"
    echo "=================="
    echo ""
    echo "Usage: helper.sh epic <command> [options]"
    echo ""
    echo "Commands:"
    echo "  create <epic-name> [description]  Create a new epic"
    echo "  parse <prd-name>        Create epic from existing PRD"
    echo "  list                    List all epics categorized by status"
    echo "  show <epic-name>        Show detailed epic information"
    echo "  status <epic-name>      Get epic status with progress and tasks"
    echo "  tasks <epic-name> [status]  List tasks in epic (optional status filter)"
    echo "  validate <epic-name>    Validate epic prerequisites before starting operations"
    echo "  create-branch <epic-name>   Create or switch to epic branch"
    echo "  ready-tasks <epic-name>     Identify ready tasks for parallel execution"
    echo "  help                    Show this help message"
    echo ""
    echo "Status filters for tasks command:"
    echo "  pending     - Tasks not yet started"
    echo "  in_progress - Tasks currently being worked on"
    echo "  completed   - Finished tasks"
    echo "  blocked     - Tasks that are blocked"
    echo ""
    echo "Examples:"
    echo "  helper.sh epic create my-feature \"Feature description\""
    echo "  helper.sh epic parse my-prd-name"
    echo "  helper.sh epic list"
    echo "  helper.sh epic show data-api-sanity"
    echo "  helper.sh epic status versioning"
    echo "  helper.sh epic tasks data-api-sanity pending"
    return 0
}

# === Epic Lifecycle Management Functions ===

# @description Validate epic prerequisites before starting operations
# @public
# @arg $1 Epic name/path
# @stdout Validation messages
# @stderr Error messages for failed validations
# @exitcode 0 If all validations pass
# @exitcode 1 If validation fails
helper_epic_validate_prerequisites() {
    local epic_name="$1"
    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }
    local epic_path="$doh_dir/epics/$epic_name"
    local validation_errors=()
    
    # Check epic exists
    if [[ ! -f "$epic_path/epic.md" ]]; then
        validation_errors+=("Epic not found: $epic_path/epic.md")
    fi
    
    # Check GitHub sync
    if [[ -f "$epic_path/epic.md" ]]; then
        local github_field
        github_field=$(frontmatter_get_field "$epic_path/epic.md" "github")
        if [[ -z "$github_field" ]]; then
            validation_errors+=("Epic not synced to GitHub. Run: /doh:epic-sync $epic_name")
        fi
    fi
    
    # Check for uncommitted changes
    if [[ -n "$(git status --porcelain)" ]]; then
        validation_errors+=("Uncommitted changes detected. Please commit or stash before starting epic.")
    fi
    
    # Report results
    if [[ ${#validation_errors[@]} -gt 0 ]]; then
        echo "❌ Epic validation failed:" >&2
        printf "   - %s\n" "${validation_errors[@]}" >&2
        return 1
    fi
    
    echo "✅ Epic prerequisites validated"
    return 0
}

# @description Create or switch to epic branch with proper git operations
# @public
# @arg $1 Epic name
# @stdout Status messages
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If git operations fail
helper_epic_create_or_enter_branch() {
    local epic_name="$1"
    local branch_name="epic/$epic_name"
    
    echo "Managing epic branch: $branch_name"
    
    # Check if branch exists (local or remote)
    if git branch -a | grep -q "$branch_name"; then
        echo "Switching to existing branch: $branch_name"
        if ! git checkout "$branch_name"; then
            echo "❌ Failed to checkout branch: $branch_name" >&2
            return 1
        fi
        
        # Pull latest if tracking remote
        if git branch -vv | grep -q "origin/$branch_name"; then
            echo "Pulling latest changes..."
            git pull origin "$branch_name" || echo "⚠️ Pull failed - branch may be ahead"
        fi
    else
        echo "Creating new branch: $branch_name"
        # Ensure we're on main and up to date
        git checkout main || return 1
        git pull origin main || return 1
        
        # Create and push branch
        git checkout -b "$branch_name" || return 1
        git push -u origin "$branch_name" || return 1
    fi
    
    echo "✅ Ready on branch: $branch_name"
    return 0
}

# @description Identify ready tasks in epic based on dependencies and status
# @public
# @arg $1 Epic name
# @stdout Task readiness info
# @stderr Error messages
# @exitcode 0 If successful
helper_epic_identify_ready_tasks() {
    local epic_name="$1"
    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }
    local epic_path="$doh_dir/epics/$epic_name"
    local ready_tasks=()
    
    echo "Analyzing task readiness in epic: $epic_name"
    
    # Get all task files (using direct listing since API function doesn't exist yet)
    local task_files
    if [[ -d "$epic_path" ]]; then
        task_files=$(find "$epic_path" -name "[0-9][0-9][0-9].md" -type f 2>/dev/null || echo "")
    else
        echo "❌ Epic directory not found: $epic_path"
        return 1
    fi
    
    while IFS= read -r task_file; do
        [[ -n "$task_file" ]] || continue
        
        local task_status
        task_status=$(frontmatter_get_field "$task_file" "status")
        
        local task_number
        task_number=$(frontmatter_get_field "$task_file" "number")
        
        local task_title  
        task_title=$(frontmatter_get_field "$task_file" "title")
        
        # Check if task is ready (status=pending and no blocking dependencies)
        if [[ "$task_status" == "pending" ]]; then
            local depends_on
            depends_on=$(frontmatter_get_field "$task_file" "depends_on")
            
            # For now, simple ready check - can be enhanced with dependency resolution
            if [[ -z "$depends_on" ]]; then
                ready_tasks+=("$task_number:$task_title:$task_file")
                echo "  ✅ Ready: #$task_number - $task_title"
            else
                echo "  ⏸️ Blocked: #$task_number - $task_title (depends on: $depends_on)"
            fi
        else
            echo "  ⏭️ Status '$task_status': #$task_number - $task_title"
        fi
    done <<< "$task_files"
    
    if [[ ${#ready_tasks[@]} -eq 0 ]]; then
        echo "⚠️ No ready tasks found in epic: $epic_name"
        return 1
    fi
    
    echo "Found ${#ready_tasks[@]} ready task(s)"
    printf '%s\n' "${ready_tasks[@]}"
    return 0
}

# @description Créer un nouvel epic
# @arg $1 string Nom de l'epic
# @arg $2 string Description (optionnel)
# @arg $3 string Target version (optionnel, auto-extracted from PRD if exists)
# @stdout Chemin vers l'epic créé
# @exitcode 0 Si création réussie
# @exitcode 1 Si erreur de paramètres
helper_epic_create() {
    local epic_name="${1:-}"
    local description="${2:-}"
    local target_version="${3:-}"
    
    # Validation
    if [[ -z "$epic_name" ]]; then
        echo "Error: Epic name required" >&2
        echo "Usage: helper.sh epic create <epic-name> [description] [target_version]" >&2
        return 1
    fi
    
    # Check if epic already exists
    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }
    local epic_path="$doh_dir/epics/${epic_name}/epic.md"
    if [[ -f "$epic_path" ]]; then
        echo "Error: Epic already exists: $epic_path" >&2
        return 1
    fi
    
    # Extract target_version from PRD if not provided and PRD exists
    if [[ -z "$target_version" ]]; then
        local prd_path="$doh_dir/prds/${epic_name}.md"
        if [[ -f "$prd_path" ]]; then
            target_version="$(frontmatter_get_field "$prd_path" "target_version" 2>/dev/null || echo "")"
            if [[ -n "$target_version" ]]; then
                echo "📋 Extracted target_version from PRD: $target_version"
            fi
        fi
    fi
    
    echo "Creating epic: $epic_name"
    
    # Create epic directory
    mkdir -p "$doh_dir/epics/${epic_name}"
    
    # Generate epic content
    local epic_content
    epic_content=$(epic_create_content "$epic_name" "$description")
    
    # Build frontmatter fields
    local -a frontmatter_fields=(
        "name:$epic_name"
        "status:backlog"
        "progress:0%"
        "github:[Will be updated when synced to GitHub]"
    )
    
    # Add target_version if available
    if [[ -n "$target_version" ]]; then
        frontmatter_fields+=("target_version:$target_version")
        echo "🎯 Set target_version: $target_version"
    fi
    
    # Create epic using frontmatter_create_markdown with --auto-number=epic
    frontmatter_create_markdown --auto-number=epic "$epic_path" "$epic_content" "${frontmatter_fields[@]}"
    
    # Get the generated number for display
    local epic_number
    epic_number=$(frontmatter_get_field "$epic_path" "number")
    
    echo "✅ Epic created: $epic_path"
    echo "   Number: $epic_number"
    echo "   Status: backlog"
    if [[ -n "$target_version" ]]; then
        echo "   Target version: $target_version"
    fi
    
    return 0
}

# @description Parser un PRD vers un epic
# @arg $1 string Nom du PRD source
# @stdout Chemin vers l'epic créé
# @exitcode 0 Si parsing réussi
# @exitcode 1 Si PRD non trouvé ou erreur
helper_epic_parse() {
    local prd_name="$1"
    
    if [[ -z "$prd_name" ]]; then
        echo "Error: PRD name required" >&2
        echo "Usage: helper.sh epic parse <prd-name>" >&2
        return 1
    fi
    
    # Check if PRD exists
    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }
    local prd_path="$doh_dir/prds/${prd_name}.md"
    if [[ ! -f "$prd_path" ]]; then
        echo "Error: PRD not found: $prd_path" >&2
        echo "Available PRDs:" >&2
        if [[ -d "$doh_dir/prds" ]]; then
            ls -1 "$doh_dir/prds"/*.md 2>/dev/null | sed "s|$doh_dir/prds/||; s|.md$||" | sed 's/^/  - /' || echo "  (none)"
        fi
        return 1
    fi
    
    echo "Parsing PRD '$prd_name' to create epic..."
    
    # Extract PRD metadata
    local prd_description target_version
    prd_description="$(frontmatter_get_field "$prd_path" "description" 2>/dev/null || echo "")"
    target_version="$(frontmatter_get_field "$prd_path" "target_version" 2>/dev/null || echo "")"
    
    # Check if epic already exists
    local epic_path="$doh_dir/epics/${prd_name}/epic.md"
    if [[ -f "$epic_path" ]]; then
        echo "Warning: Epic already exists: $epic_path" >&2
        echo "Do you want to overwrite? (yes/no)" >&2
        read -r response
        if [[ "$response" != "yes" ]]; then
            echo "Epic parsing cancelled" >&2
            return 1
        fi
    fi
    
    # Create epic using the create function with target_version
    helper_epic_create "$prd_name" "$prd_description" "$target_version" || {
        echo "Error: Failed to create epic from PRD" >&2
        return 1
    }
    
    # Add PRD reference
    frontmatter_update_field "$epic_path" "prd" "$prd_path"
    
    echo "✅ Epic created from PRD: $epic_path"
    echo "   Source PRD: $prd_path"
    if [[ -n "$target_version" ]]; then
        echo "   Target version: $target_version"
    fi
    
    return 0
}

# @description Update epic fields
# @arg $1 string Epic name
# @arg $... string Field:value pairs to update
# @stdout Update status messages
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If update failed
helper_epic_update() {
    local epic_name="${1:-}"
    shift
    
    # Validation
    if [[ -z "$epic_name" ]]; then
        echo "Error: Epic name required" >&2
        echo "Usage: epic update <epic-name> field:value [field:value ...]" >&2
        return 1
    fi
    
    # Get DOH directory
    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }
    
    # Check if epic exists
    local epic_path="$doh_dir/epics/$epic_name/epic.md"
    if [[ ! -f "$epic_path" ]]; then
        echo "Error: Epic not found: $epic_name" >&2
        echo "Available epics:" >&2
        find "$doh_dir/epics" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | while read -r dir; do
            [ -d "$dir" ] && echo "  • $(basename "$dir")" >&2
        done
        return 1
    fi
    
    # Update epic fields using library function
    echo "📝 Updating epic: $epic_name"
    epic_update "$epic_path" "$@"
    local result=$?
    
    if [[ $result -eq 0 ]]; then
        echo "✅ Epic updated successfully"
        
        # Show updated fields
        for field_value in "$@"; do
            if [[ "$field_value" =~ ^([^:]+):(.*)$ ]]; then
                local field="${BASH_REMATCH[1]}"
                local value="${BASH_REMATCH[2]}"
                echo "   • $field: $value"
            fi
        done
    else
        echo "❌ Failed to update epic" >&2
    fi
    
    return $result
}

# Helpers should only be called through helper.sh bootstrap
# Direct execution is not allowed
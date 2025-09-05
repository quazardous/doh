#!/bin/bash

# DOH Epic Library
# Pure library for epic management operations (no automatic execution)

# Source core library dependencies
source "$(dirname "${BASH_SOURCE[0]}")/doh.sh"
source "$(dirname "${BASH_SOURCE[0]}")/frontmatter.sh"

# Guard against multiple sourcing
[[ -n "${DOH_LIB_EPIC_LOADED:-}" ]] && return 0
DOH_LIB_EPIC_LOADED=1

# Constants
readonly EPIC_LIB_VERSION="1.0.0"

# @description Get epic status report with progress and task breakdown
# @arg $1 string Epic name
# @stdout Formatted epic status report
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If epic not found or other errors
epic_get_status() {
    local epic_name="$1"

    # Get DOH root directory
    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in a DOH project" >&2
        return 1
    }

    echo "Getting status..."
    echo ""
    echo ""

    if [ -z "$epic_name" ]; then
        echo "❌ Please specify an epic name"
        echo "Usage: epic-status.sh <epic-name>"
        echo ""
        echo "Available epics:"
        find "$doh_dir/epics" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | while read -r dir; do
            [ -d "$dir" ] && echo "  • $(basename "$dir")"
        done
        return 1
    else
        # Show status for specific epic
        local epic_dir="$doh_dir/epics/$epic_name"
        local epic_file="$epic_dir/epic.md"

        if [ ! -f "$epic_file" ]; then
            echo "❌ Epic not found: $epic_name"
            echo ""
            echo "Available epics:"
            find "$doh_dir/epics" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | while read -r dir; do
                [ -d "$dir" ] && echo "  • $(basename "$dir")"
            done
            return 1
        fi

        echo "📚 Epic Status: $epic_name"
        echo "================================"
        echo ""

        # Extract metadata using frontmatter API
        local status progress github
        status=$(frontmatter_get_field "$epic_file" "status" 2>/dev/null)
        progress=$(frontmatter_get_field "$epic_file" "progress" 2>/dev/null)
        github=$(frontmatter_get_field "$epic_file" "github" 2>/dev/null)

        # Count tasks using frontmatter API
        local total=0 open=0 closed=0 blocked=0 in_progress=0

        # Use process substitution to avoid subshell issues
        while IFS= read -r task_file; do
            if [ -f "$task_file" ]; then
                local task_status depends_on
                task_status=$(frontmatter_get_field "$task_file" "status" 2>/dev/null)
                depends_on=$(frontmatter_get_field "$task_file" "depends_on" 2>/dev/null)

                ((total++))

                case "$task_status" in
                    "completed"|"closed")
                        ((closed++))
                        ;;
                    "in_progress")
                        ((in_progress++))
                        ;;
                    "blocked")
                        ((blocked++))
                        ;;
                    *)
                        # Check if task has unmet dependencies
                        if [ -n "$depends_on" ] && [ "$depends_on" != "null" ] && [ "$depends_on" != "" ]; then
                            ((blocked++))
                        else
                            ((open++))
                        fi
                        ;;
                esac
            fi
        done < <(find "$epic_dir" -name "[0-9]*.md" -type f 2>/dev/null)

        # Display progress bar
        if [ $total -gt 0 ]; then
            local percent filled empty
            percent=$((closed * 100 / total))
            filled=$((percent * 20 / 100))
            empty=$((20 - filled))

            echo -n "Progress: ["
            [ $filled -gt 0 ] && printf '%0.s█' $(seq 1 $filled)
            [ $empty -gt 0 ] && printf '%0.s░' $(seq 1 $empty)
            echo "] $percent%"
        else
            echo "Progress: No tasks created"
        fi

        echo ""
        echo "📊 Breakdown:"
        echo "  Total tasks: $total"
        echo "  ✅ Completed: $closed"
        echo "  🔄 In Progress: $in_progress"
        echo "  📋 Available: $open"
        echo "  ⏸️ Blocked: $blocked"

        [ -n "$status" ] && echo ""
        [ -n "$status" ] && echo "📈 Epic Status: $status"
        [ -n "$progress" ] && echo "📊 Epic Progress: $progress"
        [ -n "$github" ] && echo "🔗 GitHub: $github"
    fi

    return 0
}

# @description List all epics with their status
# @stdout List of epics with status information
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If error occurred
epic_list() {
    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }

    local epic_dir="$doh_dir/epics"
    
    if [ ! -d "$epic_dir" ]; then
        echo "No epics directory found."
        return 0
    fi

    echo "📚 Available Epics:"
    echo "=================="
    echo ""

    local count=0
    find "$epic_dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort | while read -r dir; do
        if [ -d "$dir" ]; then
            local epic_name epic_file status progress
            epic_name=$(basename "$dir")
            epic_file="$dir/epic.md"
            
            if [ -f "$epic_file" ]; then
                status=$(frontmatter_get_field "$epic_file" "status" 2>/dev/null)
                progress=$(frontmatter_get_field "$epic_file" "progress" 2>/dev/null)
                
                [ -z "$status" ] && status="unknown"
                [ -z "$progress" ] && progress="0%"
                
                echo "  • $epic_name [$status] - $progress"
            else
                echo "  • $epic_name [no epic.md]"
            fi
            ((count++))
        fi
    done
    
    echo ""
    echo "Total: $count epics"
}

# @description Show detailed epic information
# @arg $1 string Epic name
# @stdout Detailed epic information
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If epic not found
epic_show() {
    local epic_name="$1"
    
    if [ -z "$epic_name" ]; then
        echo "Usage: epic_show <epic-name>" >&2
        return 1
    fi

    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }

    local epic_file="$doh_dir/epics/$epic_name/epic.md"
    
    if [ ! -f "$epic_file" ]; then
        echo "Error: Epic not found: $epic_name" >&2
        return 1
    fi

    echo "📚 Epic: $epic_name"
    echo "==================="
    echo ""

    # Extract and display all frontmatter fields
    local status progress target_version created prd github
    status=$(frontmatter_get_field "$epic_file" "status" 2>/dev/null)
    progress=$(frontmatter_get_field "$epic_file" "progress" 2>/dev/null)
    target_version=$(frontmatter_get_field "$epic_file" "target_version" 2>/dev/null)
    created=$(frontmatter_get_field "$epic_file" "created" 2>/dev/null)
    prd=$(frontmatter_get_field "$epic_file" "prd" 2>/dev/null)
    github=$(frontmatter_get_field "$epic_file" "github" 2>/dev/null)

    [ -n "$status" ] && echo "Status: $status"
    [ -n "$progress" ] && echo "Progress: $progress"
    [ -n "$target_version" ] && echo "Target Version: $target_version"
    [ -n "$created" ] && echo "Created: $created"
    [ -n "$prd" ] && echo "PRD: $prd"
    [ -n "$github" ] && echo "GitHub: $github"

    echo ""
    echo "📋 Tasks:"
    epic_get_status "$epic_name" | tail -n +10  # Skip the header part
}

# @description Get tasks in an epic by status
# @arg $1 string Epic name
# @arg $2 string Optional status filter (pending|in_progress|completed|blocked)
# @stdout List of task numbers/files
# @stderr Error messages
# @exitcode 0 If successful
epic_get_tasks() {
    local epic_name="$1"
    local status_filter="${2:-}"
    
    if [ -z "$epic_name" ]; then
        echo "Usage: epic_get_tasks <epic-name> [status]" >&2
        return 1
    fi

    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }

    local epic_dir="$doh_dir/epics/$epic_name"
    
    if [ ! -d "$epic_dir" ]; then
        echo "Error: Epic not found: $epic_name" >&2
        return 1
    fi

    find "$epic_dir" -name "[0-9]*.md" -type f 2>/dev/null | while read -r task_file; do
        if [ -f "$task_file" ]; then
            local task_status task_number
            task_status=$(frontmatter_get_field "$task_file" "status" 2>/dev/null)
            task_number=$(frontmatter_get_field "$task_file" "number" 2>/dev/null)
            
            # Normalize status
            case "$task_status" in
                "completed"|"closed") task_status="completed" ;;
                "in_progress") task_status="in_progress" ;;
                "blocked") task_status="blocked" ;;
                *) task_status="pending" ;;
            esac

            # Output if matches filter or no filter specified
            if [ -z "$status_filter" ] || [ "$task_status" = "$status_filter" ]; then
                [ -n "$task_number" ] && echo "$task_number" || echo "$(basename "$task_file" .md)"
            fi
        fi
    done
}

# @description Create epic content with proper formatting
# @arg $1 string Epic name
# @arg $2 string Epic description (optional)
# @stdout Epic markdown content
# @exitcode 0 Always succeeds
epic_create_content() {
    local epic_name="$1"
    local description="${2:-}"
    
    local description_section=""
    if [[ -n "$description" ]]; then
        description_section="## Description
$description

"
    fi
    
    # Escape special characters for sed
    local escaped_name="${epic_name//\//\\/}"
    local escaped_desc="${description_section//\//\\/}"
    escaped_desc="${escaped_desc//$'\n'/\\n}"

    cat <<'EPIC_TEMPLATE' | sed "s/EPIC_NAME_PLACEHOLDER/$escaped_name/g" | sed "s/DESCRIPTION_SECTION_PLACEHOLDER/$escaped_desc/g"

# Epic: EPIC_NAME_PLACEHOLDER

DESCRIPTION_SECTION_PLACEHOLDER## Overview
<!-- Epic overview goes here -->

## Implementation Strategy
<!-- Implementation details go here -->

## Tasks
<!-- Tasks will be added during decomposition -->
EPIC_TEMPLATE
}

# @description Create new epic with frontmatter
# @arg $1 string Epic path
# @arg $2 string Epic name
# @arg $3 string Epic description (optional)
# @stdout Creation status messages
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If creation failed
epic_create() {
    local epic_path="$1"
    local epic_name="$2"
    local description="${3:-}"

    if [[ -z "$epic_path" || -z "$epic_name" ]]; then
        echo "Error: Missing required parameters" >&2
        echo "Usage: epic_create <path> <name> [description]" >&2
        return 1
    fi
    
    # Generate content using the content creation function
    local epic_content
    epic_content=$(epic_create_content "$epic_name" "$description")
    
    # Create epic file with frontmatter
    frontmatter_create_markdown --auto-number=epic "$epic_path" "$epic_content" \
        "name:$epic_name" \
        "status:backlog" \
        "progress:0%" \
        "github:[Will be updated when synced to GitHub]"
    
    return $?
}
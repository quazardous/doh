#!/bin/bash

# DOH PRD Library
# Pure library for PRD management operations (no automatic execution)

# Source core library dependencies
source "$(dirname "${BASH_SOURCE[0]}")/doh.sh"
source "$(dirname "${BASH_SOURCE[0]}")/frontmatter.sh"

# Guard against multiple sourcing
[[ -n "${DOH_LIB_PRD_LOADED:-}" ]] && return 0
DOH_LIB_PRD_LOADED=1

# Constants
readonly PRD_LIB_VERSION="1.0.0"


# @description Get PRD count by status
# @arg $1 string Optional status filter (backlog|in-progress|implemented)
# @stdout Count of PRDs matching status
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If error occurred
prd_get_count() {
    local status_filter="${1:-}"
    
    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }

    local prd_dir="$doh_dir/prds"
    [ ! -d "$prd_dir" ] && echo "0" && return 0

    local count=0

    while IFS= read -r file; do
        if [ -f "$file" ]; then
            local status
            status=$(frontmatter_get_field "$file" "status" 2>/dev/null)

            # Normalize status
            case "$status" in
                backlog|draft|""|"null") status="backlog" ;;
                in-progress|active|in_progress) status="in-progress" ;;
                implemented|completed|done) status="implemented" ;;
                *) status="backlog" ;;
            esac

            # Count if matches filter or no filter specified
            if [ -z "$status_filter" ] || [ "$status" = "$status_filter" ]; then
                ((count++))
            fi
        fi
    done < <(find "$prd_dir" -name "*.md" -type f 2>/dev/null)

    echo "$count"
}

# @description List PRDs by status
# @arg $1 string Optional status filter (backlog|in-progress|implemented)
# @stdout List of PRD names
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If error occurred
prd_list_by_status() {
    local status_filter="${1:-}"
    
    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }

    local prd_dir="$doh_dir/prds"
    [ ! -d "$prd_dir" ] && return 0

    while IFS= read -r file; do
        if [ -f "$file" ]; then
            local status name
            status=$(frontmatter_get_field "$file" "status" 2>/dev/null)
            name=$(frontmatter_get_field "$file" "name" 2>/dev/null)
            
            [ -z "$name" ] || [ "$name" = "null" ] && name=$(basename "$file" .md)

            # Normalize status
            case "$status" in
                backlog|draft|""|"null") status="backlog" ;;
                in-progress|active|in_progress) status="in-progress" ;;
                implemented|completed|done) status="implemented" ;;
                *) status="backlog" ;;
            esac

            # Output if matches filter or no filter specified
            if [ -z "$status_filter" ] || [ "$status" = "$status_filter" ]; then
                echo "$name"
            fi
        fi
    done < <(find "$prd_dir" -name "*.md" -type f 2>/dev/null)
}

# @description List all PRDs with their status and metadata
# @arg $1 string Optional status filter (backlog|in-progress|implemented)
# @stdout Formatted list of PRDs
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If error occurred
prd_list() {
    local status_filter="${1:-}"
    
    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }

    local prd_dir="$doh_dir/prds"
    
    if [ ! -d "$prd_dir" ]; then
        echo "No PRDs directory found."
        return 0
    fi

    echo "📄 Available PRDs:"
    echo "=================="
    echo ""

    local count=0
    find "$prd_dir" -name "*.md" -type f 2>/dev/null | sort | while read -r prd_file; do
        if [ -f "$prd_file" ]; then
            local name status created target_version
            name=$(frontmatter_get_field "$prd_file" "name" 2>/dev/null)
            status=$(frontmatter_get_field "$prd_file" "status" 2>/dev/null)
            created=$(frontmatter_get_field "$prd_file" "created" 2>/dev/null)
            target_version=$(frontmatter_get_field "$prd_file" "target_version" 2>/dev/null)
            
            [ -z "$name" ] || [ "$name" = "null" ] && name=$(basename "$prd_file" .md)
            [ -z "$status" ] || [ "$status" = "null" ] && status="backlog"
            
            # Normalize status for filtering
            case "$status" in
                backlog|draft) status="backlog" ;;
                in-progress|active|in_progress) status="in-progress" ;;
                implemented|completed|done) status="implemented" ;;
            esac

            # Apply filter if specified
            if [ -z "$status_filter" ] || [ "$status" = "$status_filter" ]; then
                local info_line="  • $name [$status]"
                [ -n "$target_version" ] && [ "$target_version" != "null" ] && info_line="$info_line - v$target_version"
                [ -n "$created" ] && [ "$created" != "null" ] && info_line="$info_line ($(date -d "$created" "+%Y-%m-%d" 2>/dev/null || echo "$created"))"
                
                echo "$info_line"
                ((count++))
            fi
        fi
    done
    
    local filter_text=""
    [ -n "$status_filter" ] && filter_text=" with status '$status_filter'"
    
    echo ""
    echo "Total: $count PRDs$filter_text"
}
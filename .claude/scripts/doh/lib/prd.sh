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

# @description Get PRD status report with distribution and recent activity
# @stdout Formatted PRD status report
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If not in DOH project or other errors
prd_get_status() {
    # Get DOH root directory
    local doh_root
    doh_root=$(doh_find_root) || {
        echo "Error: Not in a DOH project" >&2
        return 1
    }

    local prd_dir="$doh_root/.doh/prds"

    echo "📄 PRD Status Report"
    echo "===================="
    echo ""

    if [ ! -d "$prd_dir" ]; then
        echo "No PRD directory found."
        return 0
    fi

    # Count total PRDs
    local total
    total=$(find "$prd_dir" -name "*.md" -type f 2>/dev/null | wc -l)
    if [ "$total" -eq 0 ]; then
        echo "No PRDs found."
        return 0
    fi

    # Count by status using frontmatter API
    local backlog=0 in_progress=0 implemented=0

    while IFS= read -r file; do
        if [ -f "$file" ]; then
            local status
            status=$(frontmatter_get_field "$file" "status" 2>/dev/null)

            case "$status" in
                backlog|draft|""|"null") 
                    ((backlog++))
                    ;;
                in-progress|active|in_progress) 
                    ((in_progress++))
                    ;;
                implemented|completed|done) 
                    ((implemented++))
                    ;;
                *) 
                    ((backlog++))
                    ;;
            esac
        fi
    done < <(find "$prd_dir" -name "*.md" -type f 2>/dev/null)

    echo "Getting status..."
    echo ""
    echo ""

    # Display chart
    echo "📊 Distribution:"
    echo "================"
    echo ""

    if [ "$total" -gt 0 ]; then
        local backlog_bars in_progress_bars implemented_bars
        backlog_bars=$((backlog > 0 ? backlog*20/total : 0))
        in_progress_bars=$((in_progress > 0 ? in_progress*20/total : 0))
        implemented_bars=$((implemented > 0 ? implemented*20/total : 0))
        
        echo "  Backlog:     $(printf '%-3d' $backlog) [$(printf '%0.s█' $(seq 1 $backlog_bars) 2>/dev/null)]"
        echo "  In Progress: $(printf '%-3d' $in_progress) [$(printf '%0.s█' $(seq 1 $in_progress_bars) 2>/dev/null)]"
        echo "  Implemented: $(printf '%-3d' $implemented) [$(printf '%0.s█' $(seq 1 $implemented_bars) 2>/dev/null)]"
    else
        echo "  No PRDs to display"
    fi
    echo ""
    echo "  Total PRDs: $total"

    # Recent activity using frontmatter API
    echo ""
    echo "📅 Recent PRDs (last 5 modified):"
    find "$prd_dir" -name "*.md" -type f -printf '%T@ %p\n' 2>/dev/null | sort -nr | head -5 | cut -d' ' -f2- | while read -r file; do
        local name
        name=$(frontmatter_get_field "$file" "name" 2>/dev/null)
        [ -z "$name" ] || [ "$name" = "null" ] && name=$(basename "$file" .md)
        echo "  • $name"
    done

    # Suggestions
    echo ""
    echo "💡 Next Actions:"
    [ $backlog -gt 0 ] && echo "  • Parse backlog PRDs to epics: /doh:prd-parse <name>"
    [ $in_progress -gt 0 ] && echo "  • Check progress on active PRDs: /doh:epic-status <name>"
    [ $total -eq 0 ] && echo "  • Create your first PRD: /doh:prd-new <name>"

    return 0
}

# @description Get PRD count by status
# @arg $1 string Optional status filter (backlog|in-progress|implemented)
# @stdout Count of PRDs matching status
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If error occurred
prd_get_count() {
    local status_filter="${1:-}"
    
    local doh_root
    doh_root=$(doh_find_root) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }

    local prd_dir="$doh_root/.doh/prds"
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
    
    local doh_root
    doh_root=$(doh_find_root) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }

    local prd_dir="$doh_root/.doh/prds"
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
    
    local doh_root
    doh_root=$(doh_find_root) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }

    local prd_dir="$doh_root/.doh/prds"
    
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
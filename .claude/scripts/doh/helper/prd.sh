#!/bin/bash

# DOH PRD Helper
# User-facing functions for PRD (Product Requirements Document) management

# Source required dependencies
source "$(dirname "${BASH_SOURCE[0]}")/../lib/prd.sh"

# Guard against multiple sourcing
[[ -n "${DOH_HELPER_PRD_LOADED:-}" ]] && return 0
DOH_HELPER_PRD_LOADED=1

# @description List all PRDs categorized by status
# @stdout Formatted list of PRDs with status categorization and summary
# @stderr Error messages
# @exitcode 0 If successful
helper_prd_list() {
    echo "Getting PRDs..."
    echo ""
    echo ""

    local doh_root
    doh_root=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }

    # Check if PRD directory exists
    if [ ! -d "$doh_root/.doh/prds" ]; then
        echo "📁 No PRD directory found. Create your first PRD with: /doh:prd-new <feature-name>"
        return 0
    fi

    # Check for PRD files
    if ! ls "$doh_root"/.doh/prds/*.md >/dev/null 2>&1; then
        echo "📁 No PRDs found. Create your first PRD with: /doh:prd-new <feature-name>"
        return 0
    fi

    echo "📋 PRD List"
    echo "==========="
    echo ""

    # Initialize counters
    local backlog_count=0 in_progress_count=0 implemented_count=0 total_count=0

    # Display by status groups
    echo "🔍 Backlog PRDs:"
    for file in "$doh_root"/.doh/prds/*.md; do
        [ -f "$file" ] || continue
        
        # Extract metadata using frontmatter if available, fallback to grep
        local status name desc
        if command -v frontmatter_get_field >/dev/null 2>&1; then
            status=$(frontmatter_get_field "$file" "status" 2>/dev/null)
            name=$(frontmatter_get_field "$file" "name" 2>/dev/null)
            desc=$(frontmatter_get_field "$file" "description" 2>/dev/null)
        else
            # Fallback to grep
            status=$(grep "^status:" "$file" | head -1 | sed 's/^status: *//')
            name=$(grep "^name:" "$file" | head -1 | sed 's/^name: *//')
            desc=$(grep "^description:" "$file" | head -1 | sed 's/^description: *//')
        fi

        if [ "$status" = "backlog" ] || [ "$status" = "draft" ] || [ -z "$status" ]; then
            [ -z "$name" ] && name=$(basename "$file" .md)
            [ -z "$desc" ] && desc="No description"
            
            # Show relative path from doh root
            local relative_file
            relative_file=$(realpath --relative-to="$doh_root" "$file")
            echo "   📋 $relative_file - $desc"
            ((backlog_count++))
        fi
        ((total_count++))
    done
    [ $backlog_count -eq 0 ] && echo "   (none)"

    echo ""
    echo "🔄 In-Progress PRDs:"
    for file in "$doh_root"/.doh/prds/*.md; do
        [ -f "$file" ] || continue
        
        local status name desc
        if command -v frontmatter_get_field >/dev/null 2>&1; then
            status=$(frontmatter_get_field "$file" "status" 2>/dev/null)
            name=$(frontmatter_get_field "$file" "name" 2>/dev/null)
            desc=$(frontmatter_get_field "$file" "description" 2>/dev/null)
        else
            status=$(grep "^status:" "$file" | head -1 | sed 's/^status: *//')
            name=$(grep "^name:" "$file" | head -1 | sed 's/^name: *//')
            desc=$(grep "^description:" "$file" | head -1 | sed 's/^description: *//')
        fi

        if [ "$status" = "in-progress" ] || [ "$status" = "active" ]; then
            [ -z "$name" ] && name=$(basename "$file" .md)
            [ -z "$desc" ] && desc="No description"
            
            local relative_file
            relative_file=$(realpath --relative-to="$doh_root" "$file")
            echo "   📋 $relative_file - $desc"
            ((in_progress_count++))
        fi
    done
    [ $in_progress_count -eq 0 ] && echo "   (none)"

    echo ""
    echo "✅ Implemented PRDs:"
    for file in "$doh_root"/.doh/prds/*.md; do
        [ -f "$file" ] || continue
        
        local status name desc
        if command -v frontmatter_get_field >/dev/null 2>&1; then
            status=$(frontmatter_get_field "$file" "status" 2>/dev/null)
            name=$(frontmatter_get_field "$file" "name" 2>/dev/null)
            desc=$(frontmatter_get_field "$file" "description" 2>/dev/null)
        else
            status=$(grep "^status:" "$file" | head -1 | sed 's/^status: *//')
            name=$(grep "^name:" "$file" | head -1 | sed 's/^name: *//')
            desc=$(grep "^description:" "$file" | head -1 | sed 's/^description: *//')
        fi

        if [ "$status" = "implemented" ] || [ "$status" = "completed" ] || [ "$status" = "done" ]; then
            [ -z "$name" ] && name=$(basename "$file" .md)
            [ -z "$desc" ] && desc="No description"
            
            local relative_file
            relative_file=$(realpath --relative-to="$doh_root" "$file")
            echo "   📋 $relative_file - $desc"
            ((implemented_count++))
        fi
    done
    [ $implemented_count -eq 0 ] && echo "   (none)"

    # Display summary
    echo ""
    echo "📊 PRD Summary"
    echo "   Total PRDs: $total_count"
    echo "   Backlog: $backlog_count"
    echo "   In-Progress: $in_progress_count"
    echo "   Implemented: $implemented_count"

    return 0
}

# @description Show comprehensive PRD status report
# @stdout PRD status with distribution charts and implementation progress
# @stderr Error messages  
# @exitcode 0 If successful
helper_prd_status() {
    # Call the library function which already provides user-friendly output
    prd_get_status
}

# @description List PRDs by specific status
# @arg $1 string Status filter (backlog|in-progress|implemented|all)
# @stdout Filtered list of PRDs
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If invalid status provided
helper_prd_by_status() {
    local status_filter="${1:-all}"
    
    case "$status_filter" in
        backlog|in-progress|implemented|all)
            ;;
        *)
            echo "Usage: prd by-status <status>" >&2
            echo "Valid statuses: backlog, in-progress, implemented, all" >&2
            return 1
            ;;
    esac

    echo "📋 PRDs with status: $status_filter"
    echo "================================="
    echo ""

    # Use library function
    prd_list_by_status "$status_filter" | while IFS= read -r prd_info; do
        if [ -n "$prd_info" ]; then
            echo "  • $prd_info"
        fi
    done

    return 0
}

# @description Count PRDs by status or total
# @arg $1 string Optional status filter (default: total count)
# @stdout PRD count information
# @stderr Error messages
# @exitcode 0 If successful
helper_prd_count() {
    local status_filter="${1:-}"
    
    if [ -n "$status_filter" ]; then
        echo "📊 PRD Count for status: $status_filter"
        echo "=============================="
        
        local count
        count=$(prd_get_count "$status_filter" 2>/dev/null)
        
        if [ -n "$count" ]; then
            echo "Count: $count PRDs"
        else
            echo "No PRDs found with status: $status_filter"
        fi
    else
        echo "📊 Total PRD Counts"
        echo "=================="
        echo ""
        
        # Get counts for all statuses
        local total backlog in_progress implemented
        total=$(prd_get_count "all" 2>/dev/null || echo "0")
        backlog=$(prd_get_count "backlog" 2>/dev/null || echo "0")
        in_progress=$(prd_get_count "in-progress" 2>/dev/null || echo "0")  
        implemented=$(prd_get_count "implemented" 2>/dev/null || echo "0")
        
        echo "  Total: $total"
        echo "  Backlog: $backlog"
        echo "  In-Progress: $in_progress"
        echo "  Implemented: $implemented"
    fi

    return 0
}

# @description Display PRD command help
# @stdout Help information for PRD commands
# @exitcode 0 Always successful
helper_prd_help() {
    echo "DOH PRD Management"
    echo "=================="
    echo ""
    echo "Usage: helper.sh prd <command> [options]"
    echo ""
    echo "Commands:"
    echo "  new <prd-name> [description]  Create a new PRD"
    echo "  parse <prd-name>        Parse and analyze existing PRD"
    echo "  list                    List all PRDs categorized by status"
    echo "  status                  Show comprehensive PRD status report"
    echo "  by-status <status>      List PRDs filtered by specific status"
    echo "  count [status]          Count PRDs by status or show all counts"
    echo "  help                    Show this help message"
    echo ""
    echo "Status values:"
    echo "  backlog       - PRDs in backlog/draft phase"
    echo "  in-progress   - PRDs currently being implemented"
    echo "  implemented   - Completed/done PRDs"
    echo "  all           - All PRDs regardless of status"
    echo ""
    echo "Examples:"
    echo "  helper.sh prd new my-feature \"Feature description\""
    echo "  helper.sh prd parse existing-prd"
    echo "  helper.sh prd list"
    echo "  helper.sh prd status"
    echo "  helper.sh prd by-status backlog"
    echo "  helper.sh prd count implemented"
    echo "  helper.sh prd count"
    return 0
}

# @description Créer un nouveau PRD
# @arg $1 string Nom du PRD
# @arg $2 string Description (optionnel)
# @stdout Chemin vers le PRD créé
# @exitcode 0 Si création réussie
# @exitcode 1 Si erreur de paramètres
helper_prd_new() {
    local prd_name="${1:-}"
    local description="${2:-}"
    
    # Validation
    if [[ -z "$prd_name" ]]; then
        echo "Error: PRD name required" >&2
        echo "Usage: helper.sh prd new <prd-name> [description]" >&2
        return 1
    fi
    
    # Check if PRD already exists
    local prd_path=".doh/prds/${prd_name}.md"
    if [[ -f "$prd_path" ]]; then
        echo "Error: PRD already exists: $prd_path" >&2
        return 1
    fi
    
    echo "Creating PRD: $prd_name"
    
    # Create PRDs directory if it doesn't exist
    mkdir -p ".doh/prds"
    
    # Create PRD using frontmatter API
    local created_date
    created_date="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    
    # Create PRD file with frontmatter
    frontmatter_create_markdown "$prd_path" \
        "name" "$prd_name" \
        "description" "$description" \
        "status" "backlog" \
        "created" "$created_date" \
        "target_version" "1.0.0" \
        "file_version" "0.1.0"
    
    # Add PRD content template
    {
        echo ""
        echo "# PRD: $prd_name"
        echo ""
        echo "## Executive Summary"
        if [[ -n "$description" ]]; then
            echo "$description"
        else
            echo "<!-- Brief overview and value proposition -->"
        fi
        echo ""
        echo "## Problem Statement"
        echo "<!-- What problem are we solving? -->"
        echo ""
        echo "## User Stories"
        echo "<!-- Primary user personas and detailed user journeys -->"
        echo ""
        echo "## Requirements"
        echo ""
        echo "### Functional Requirements"
        echo "<!-- Core features and capabilities -->"
        echo ""
        echo "### Non-Functional Requirements"
        echo "<!-- Performance, security, scalability needs -->"
        echo ""
        echo "## Success Criteria"
        echo "<!-- Measurable outcomes and KPIs -->"
        echo ""
        echo "## Constraints & Assumptions"
        echo "<!-- Technical limitations, timeline constraints -->"
        echo ""
        echo "## Out of Scope"
        echo "<!-- What we're explicitly NOT building -->"
        echo ""
        echo "## Dependencies"
        echo "<!-- External and internal dependencies -->"
    } >> "$prd_path"
    
    echo "✅ PRD created: $prd_path"
    echo "   Status: backlog"
    echo "   Target version: 1.0.0"
    
    return 0
}

# @description Parser et analyser un PRD
# @arg $1 string Nom du PRD
# @stdout Analyse du PRD
# @exitcode 0 Si parsing réussi
# @exitcode 1 Si PRD non trouvé ou erreur
helper_prd_parse() {
    local prd_name="$1"
    
    if [[ -z "$prd_name" ]]; then
        echo "Error: PRD name required" >&2
        echo "Usage: helper.sh prd parse <prd-name>" >&2
        return 1
    fi
    
    # Check if PRD exists
    local prd_path=".doh/prds/${prd_name}.md"
    if [[ ! -f "$prd_path" ]]; then
        echo "Error: PRD not found: $prd_path" >&2
        echo "Available PRDs:" >&2
        if [[ -d ".doh/prds" ]]; then
            ls -1 .doh/prds/*.md 2>/dev/null | sed 's|.doh/prds/||; s|.md$||' | sed 's/^/  - /' || echo "  (none)"
        fi
        return 1
    fi
    
    echo "Parsing PRD: $prd_name"
    echo "========================"
    
    # Extract PRD metadata
    local description status target_version created
    description="$(frontmatter_get_field "$prd_path" "description" 2>/dev/null || echo "")"
    status="$(frontmatter_get_field "$prd_path" "status" 2>/dev/null || echo "")"
    target_version="$(frontmatter_get_field "$prd_path" "target_version" 2>/dev/null || echo "")"
    created="$(frontmatter_get_field "$prd_path" "created" 2>/dev/null || echo "")"
    
    # Display PRD summary
    echo "📋 PRD Information:"
    echo "   Name: $prd_name"
    echo "   Status: ${status:-unknown}"
    echo "   Target Version: ${target_version:-not specified}"
    echo "   Created: ${created:-unknown}"
    if [[ -n "$description" ]]; then
        echo "   Description: $description"
    fi
    
    # Analyze PRD content
    local word_count section_count
    word_count=$(wc -w < "$prd_path" 2>/dev/null || echo "0")
    section_count=$(grep -c "^## " "$prd_path" 2>/dev/null || echo "0")
    
    echo ""
    echo "📊 Content Analysis:"
    echo "   Word count: $word_count"
    echo "   Sections: $section_count"
    
    # Check for common sections
    echo ""
    echo "📝 Section Completeness:"
    local sections=("Executive Summary" "Problem Statement" "User Stories" "Requirements" "Success Criteria")
    for section in "${sections[@]}"; do
        if grep -q "## $section" "$prd_path"; then
            echo "   ✅ $section"
        else
            echo "   ❌ Missing: $section"
        fi
    done
    
    # Readiness assessment
    echo ""
    echo "🚀 Readiness Assessment:"
    if [[ "$status" == "backlog" && "$word_count" -gt 500 && "$section_count" -ge 5 ]]; then
        echo "   ✅ PRD appears ready for epic creation"
        echo "   💡 Suggestion: Run 'helper.sh epic parse $prd_name' to create epic"
    else
        echo "   ⚠️ PRD may need more development before epic creation"
        if [[ "$word_count" -lt 500 ]]; then
            echo "   - Consider adding more detail (current: $word_count words)"
        fi
        if [[ "$section_count" -lt 5 ]]; then
            echo "   - Consider adding more sections (current: $section_count)"
        fi
    fi
    
    return 0
}

# Helpers should only be called through helper.sh bootstrap
# Direct execution is not allowed
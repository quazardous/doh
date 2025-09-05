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
    local doh_dir=($(doh_project_dir)) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }
    echo "Getting PRDs..."
    echo ""
    echo ""

    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }

    # Check if PRD directory exists
    if [ ! -d "$doh_dir/prds" ]; then
        echo "📁 No PRD directory found. Create your first PRD with: /doh:prd-new <feature-name>"
        return 0
    fi

    # Check for PRD files
    if ! ls "$doh_dir"/prds/*.md >/dev/null 2>&1; then
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
    for file in "$doh_dir"/prds/*.md; do
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
            relative_file=$(realpath --relative-to="$doh_dir" "$file")
            echo "   📋 $relative_file - $desc"
            ((backlog_count++))
        fi
        ((total_count++))
    done
    [ $backlog_count -eq 0 ] && echo "   (none)"

    echo ""
    echo "🔄 In-Progress PRDs:"
    for file in "$doh_dir"/prds/*.md; do
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
            relative_file=$(realpath --relative-to="$doh_dir" "$file")
            echo "   📋 $relative_file - $desc"
            ((in_progress_count++))
        fi
    done
    [ $in_progress_count -eq 0 ] && echo "   (none)"

    echo ""
    echo "✅ Implemented PRDs:"
    for file in "$doh_dir"/prds/*.md; do
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
            relative_file=$(realpath --relative-to="$doh_dir" "$file")
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
    # Get DOH root directory
    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in a DOH project" >&2
        return 1
    }

    local prd_dir="$doh_dir/prds"

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
    cat <<EOF
DOH PRD Management
==================

Usage: helper.sh prd <command> [options]

Commands:
    new <prd-name> [description] [target_version]  Create a new PRD
    parse <prd-name>                              Parse and analyze existing PRD
    list                                          List all PRDs categorized by status
    status                                        Show comprehensive PRD status report
    by-status <status>                            List PRDs filtered by specific status
    count [status]                                Count PRDs by status or show all counts
    help                                          Show this help message

Status values:
    backlog       - PRDs in backlog/draft phase
    in-progress   - PRDs currently being implemented
    implemented   - Completed/done PRDs
    all           - All PRDs regardless of status

Examples:
    helper.sh prd new my-feature "Feature description"
    helper.sh prd new my-feature "Feature description" "2.0.0"
    helper.sh prd parse existing-prd
    helper.sh prd list
    helper.sh prd status
    helper.sh prd by-status backlog
    helper.sh prd count implemented
    helper.sh prd count
EOF
    return 0
}

# @description Créer un nouveau PRD
# @arg $1 string Nom du PRD
# @arg $2 string Description (optionnel)
# @arg $3 string Version cible (optionnel, défaut 1.0.0)
# @stdout Chemin vers le PRD créé
# @exitcode 0 Si création réussie
# @exitcode 1 Si erreur de paramètres
helper_prd_new() {
    local prd_name="${1:-}"
    local description="${2:-}"
    local target_version="${3:-}"

    # Validation
    if [[ -z "$prd_name" ]]; then
        echo "Error: PRD name required" >&2
        echo "Usage: helper.sh prd new <prd-name> [description] [target_version]" >&2
        return 1
    fi

    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }
    
    # Check if PRD already exists
    local prd_path="$doh_dir/prds/${prd_name}.md"
    if [[ -f "$prd_path" ]]; then
        echo "Error: PRD already exists: $prd_path" >&2
        return 1
    fi
    
    echo "Creating PRD: $prd_name"
    
    # Create PRDs directory if it doesn't exist
    mkdir -p "$doh_dir/prds"

    # Use centralized PRD creation function
    prd_create "$prd_path" "$prd_name" "$description" "$target_version"

    echo "✅ PRD created: $prd_path"
    echo "   Status: backlog"
    echo "   Target version: $target_version"

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

    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }

    # Check if PRD exists
    local prd_path="$doh_dir/prds/${prd_name}.md"
    if [[ ! -f "$prd_path" ]]; then
        echo "Error: PRD not found: $prd_path" >&2
        echo "Available PRDs:" >&2
        if [[ -d "$doh_dir/prds" ]]; then
            ls -1 "$doh_dir/prds"/*.md 2>/dev/null | sed "s|$doh_dir/prds/||; s|.md$||" | sed 's/^/  - /' || echo "  (none)"
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
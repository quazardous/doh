#!/bin/bash

# Duplicate number detection utility for DOH migration
# Scans project for number conflicts and builds conflict map

# Source required dependencies
LIB_DIR="$(dirname "$0")/../.claude/scripts/doh/lib"
source "$LIB_DIR/workspace.sh"
source "$LIB_DIR/dohenv.sh"
source "$LIB_DIR/numbering.sh"
source "$LIB_DIR/graph-cache.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Detection results structure
declare -A DUPLICATE_NUMBERS
declare -A NUMBER_FILES
declare -A FILE_METADATA

# Extract file metadata (frontmatter + git info)
extract_file_metadata() {
    local file="$1"
    local project_root="$2"
    
    if [[ ! -f "$file" ]]; then
        return 1
    fi
    
    local rel_path
    rel_path=$(realpath --relative-to="$project_root" "$file")
    
    # Extract frontmatter
    local number name status created epic parent
    number=$(grep -m 1 "^number:" "$file" 2>/dev/null | cut -d':' -f2- | xargs)
    name=$(grep -m 1 "^name:" "$file" 2>/dev/null | cut -d':' -f2- | xargs)
    status=$(grep -m 1 "^status:" "$file" 2>/dev/null | cut -d':' -f2- | xargs)
    created=$(grep -m 1 "^created:" "$file" 2>/dev/null | cut -d':' -f2- | xargs)
    epic=$(grep -m 1 "^epic:" "$file" 2>/dev/null | cut -d':' -f2- | xargs)
    parent=$(grep -m 1 "^parent:" "$file" 2>/dev/null | cut -d':' -f2- | xargs)
    
    # Get git creation date if frontmatter date is missing
    local git_created
    if [[ -z "$created" ]]; then
        git_created=$(cd "$project_root" && git log --follow --format=%ai --diff-filter=A -- "$rel_path" 2>/dev/null | tail -n 1)
        if [[ -z "$git_created" ]]; then
            # Fallback to file mtime
            git_created=$(stat -c %y "$file" 2>/dev/null)
        fi
    else
        git_created="$created"
    fi
    
    # Determine file type
    local file_type="task"
    if [[ "$rel_path" == *"/epic.md" ]]; then
        file_type="epic"
    elif [[ "$rel_path" == *"/manifest.md" ]]; then
        file_type="quick"
    fi
    
    # Build JSON metadata
    local metadata='{}'
    metadata=$(echo "$metadata" | jq --arg path "$rel_path" '. + {path: $path}')
    metadata=$(echo "$metadata" | jq --arg number "$number" '. + {number: $number}')
    metadata=$(echo "$metadata" | jq --arg name "$name" '. + {name: $name}')
    metadata=$(echo "$metadata" | jq --arg type "$file_type" '. + {type: $type}')
    metadata=$(echo "$metadata" | jq --arg created "$git_created" '. + {created: $created}')
    metadata=$(echo "$metadata" | jq --arg status "$status" '. + {status: $status}')
    
    if [[ -n "$epic" ]]; then
        metadata=$(echo "$metadata" | jq --arg epic "$epic" '. + {epic: $epic}')
    fi
    
    if [[ -n "$parent" ]]; then
        metadata=$(echo "$metadata" | jq --arg parent "$parent" '. + {parent: $parent}')
    fi
    
    echo "$metadata"
}

# Scan project for all numbered files
scan_project_files() {
    local project_root
    project_root="$(_find_doh_root)" || {
        echo "Error: Not in a DOH project directory" >&2
        return 1
    }
    
    echo -e "${BLUE}Scanning project for numbered files...${NC}" >&2
    
    # Clear previous results
    DUPLICATE_NUMBERS=()
    NUMBER_FILES=()
    FILE_METADATA=()
    
    local file_count=0
    local numbered_files
    
    # Find all markdown files in DOH directories with numbers
    numbered_files=$(find "$project_root" -name "*.md" -path "*/.doh/*" -type f -exec grep -l "^number:" {} \; 2>/dev/null)
    
    while IFS= read -r file; do
        if [[ -n "$file" && -f "$file" ]]; then
            local metadata
            metadata=$(extract_file_metadata "$file" "$project_root")
            
            if [[ -n "$metadata" ]]; then
                local number
                number=$(echo "$metadata" | jq -r '.number // empty')
                
                if [[ -n "$number" && "$number" != "null" ]]; then
                    # Store file metadata
                    local rel_path
                    rel_path=$(echo "$metadata" | jq -r '.path')
                    FILE_METADATA["$rel_path"]="$metadata"
                    
                    # Track files by number
                    if [[ -n "${NUMBER_FILES[$number]}" ]]; then
                        # Duplicate found!
                        NUMBER_FILES["$number"]="${NUMBER_FILES[$number]}|$rel_path"
                        DUPLICATE_NUMBERS["$number"]=1
                    else
                        NUMBER_FILES["$number"]="$rel_path"
                    fi
                    
                    ((file_count++))
                fi
            fi
        fi
    done <<< "$numbered_files"
    
    echo -e "${GREEN}Scanned $file_count numbered files${NC}" >&2
    
    # Report duplicates found
    local duplicate_count=${#DUPLICATE_NUMBERS[@]}
    if [[ $duplicate_count -gt 0 ]]; then
        echo -e "${YELLOW}Found $duplicate_count numbers with duplicates${NC}" >&2
    else
        echo -e "${GREEN}No duplicate numbers detected${NC}" >&2
    fi
    
    return 0
}

# Build conflict report
build_conflict_report() {
    local output_format="${1:-json}"  # json, text, or csv
    
    if [[ ${#DUPLICATE_NUMBERS[@]} -eq 0 ]]; then
        if [[ "$output_format" == "json" ]]; then
            echo '{"conflicts": [], "summary": {"total_files": 0, "duplicate_numbers": 0, "conflicts": 0}}'
        else
            echo "No conflicts detected."
        fi
        return 0
    fi
    
    case "$output_format" in
        "json")
            build_json_report
            ;;
        "text")
            build_text_report
            ;;
        "csv")
            build_csv_report
            ;;
        *)
            echo "Error: Invalid output format. Use: json, text, or csv" >&2
            return 1
            ;;
    esac
}

# Build JSON conflict report
build_json_report() {
    local conflicts='[]'
    local conflict_count=0
    
    for number in "${!DUPLICATE_NUMBERS[@]}"; do
        local files_list="${NUMBER_FILES[$number]}"
        IFS='|' read -ra file_paths <<< "$files_list"
        
        local conflict_id="conflict-$(printf "%03d" $((++conflict_count)))"
        local files_array='[]'
        
        # Build files array for this conflict
        for file_path in "${file_paths[@]}"; do
            if [[ -n "$file_path" && -n "${FILE_METADATA[$file_path]}" ]]; then
                local file_metadata="${FILE_METADATA[$file_path]}"
                files_array=$(echo "$files_array" | jq --argjson file "$file_metadata" '. += [$file]')
            fi
        done
        
        # Sort files by creation date (earliest first)
        files_array=$(echo "$files_array" | jq 'sort_by(.created)')
        
        # Build conflict object
        local conflict='{}'
        conflict=$(echo "$conflict" | jq --arg id "$conflict_id" '. + {id: $id}')
        conflict=$(echo "$conflict" | jq '. + {type: "duplicate_number"}')
        conflict=$(echo "$conflict" | jq --arg num "$number" '. + {number: $num}')
        conflict=$(echo "$conflict" | jq --argjson files "$files_array" '. + {files: $files}')
        conflict=$(echo "$conflict" | jq '. + {resolution: "pending"}')
        conflict=$(echo "$conflict" | jq '. + {status: "detected"}')
        conflict=$(echo "$conflict" | jq --arg ts "$(date -Iseconds)" '. + {detected_at: $ts}')
        
        # Add conflict to conflicts array
        conflicts=$(echo "$conflicts" | jq --argjson conflict "$conflict" '. += [$conflict]')
    done
    
    # Build summary
    local total_files=${#FILE_METADATA[@]}
    local duplicate_numbers=${#DUPLICATE_NUMBERS[@]}
    
    local summary='{}'
    summary=$(echo "$summary" | jq --arg total "$total_files" '. + {total_files: ($total | tonumber)}')
    summary=$(echo "$summary" | jq --arg dups "$duplicate_numbers" '. + {duplicate_numbers: ($dups | tonumber)}')
    summary=$(echo "$summary" | jq --arg conflicts "$conflict_count" '. + {conflicts: ($conflicts | tonumber)}')
    
    # Build final report
    local report='{}'
    report=$(echo "$report" | jq --argjson conflicts "$conflicts" '. + {conflicts: $conflicts}')
    report=$(echo "$report" | jq --argjson summary "$summary" '. + {summary: $summary}')
    
    echo "$report" | jq .
}

# Build text conflict report
build_text_report() {
    echo "DOH Project Duplicate Number Detection Report"
    echo "============================================="
    echo ""
    echo "Generated: $(date -Iseconds)"
    echo "Total files scanned: ${#FILE_METADATA[@]}"
    echo "Duplicate numbers found: ${#DUPLICATE_NUMBERS[@]}"
    echo ""
    
    if [[ ${#DUPLICATE_NUMBERS[@]} -eq 0 ]]; then
        echo "✓ No conflicts detected!"
        return 0
    fi
    
    echo "CONFLICTS DETECTED:"
    echo "==================="
    echo ""
    
    local conflict_num=1
    
    for number in $(printf '%s\n' "${!DUPLICATE_NUMBERS[@]}" | sort -n); do
        echo "Conflict #$conflict_num: Number $number"
        echo "---------------------------------------"
        
        local files_list="${NUMBER_FILES[$number]}"
        IFS='|' read -ra file_paths <<< "$files_list"
        
        # Sort by creation date
        local sorted_files=()
        for file_path in "${file_paths[@]}"; do
            if [[ -n "$file_path" && -n "${FILE_METADATA[$file_path]}" ]]; then
                local metadata="${FILE_METADATA[$file_path]}"
                local created
                created=$(echo "$metadata" | jq -r '.created // "unknown"')
                sorted_files+=("$created|$file_path")
            fi
        done
        
        IFS=$'\n' sorted_files=($(sort <<< "${sorted_files[*]}"))
        
        local file_num=1
        for entry in "${sorted_files[@]}"; do
            IFS='|' read -r created file_path <<< "$entry"
            local metadata="${FILE_METADATA[$file_path]}"
            local name type
            name=$(echo "$metadata" | jq -r '.name // "unnamed"')
            type=$(echo "$metadata" | jq -r '.type // "unknown"')
            
            local priority=""
            if [[ $file_num -eq 1 ]]; then
                priority=" (KEEPS NUMBER - oldest)"
            else
                priority=" (will be renumbered)"
            fi
            
            echo "  $file_num. $file_path$priority"
            echo "     Name: $name"
            echo "     Type: $type"
            echo "     Created: $created"
            echo ""
            
            ((file_num++))
        done
        
        ((conflict_num++))
        echo ""
    done
    
    echo "RESOLUTION STRATEGY:"
    echo "==================="
    echo "- Files with earliest creation date keep their original number"
    echo "- Later files will be assigned next available numbers in sequence"
    echo "- All cross-references will be updated automatically"
    echo ""
}

# Build CSV conflict report
build_csv_report() {
    echo "number,conflict_id,file_path,name,type,created,priority,action"
    
    local conflict_num=1
    
    for number in $(printf '%s\n' "${!DUPLICATE_NUMBERS[@]}" | sort -n); do
        local conflict_id="conflict-$(printf "%03d" $conflict_num)"
        local files_list="${NUMBER_FILES[$number]}"
        IFS='|' read -ra file_paths <<< "$files_list"
        
        # Sort by creation date
        local sorted_files=()
        for file_path in "${file_paths[@]}"; do
            if [[ -n "$file_path" && -n "${FILE_METADATA[$file_path]}" ]]; then
                local metadata="${FILE_METADATA[$file_path]}"
                local created
                created=$(echo "$metadata" | jq -r '.created // "unknown"')
                sorted_files+=("$created|$file_path")
            fi
        done
        
        IFS=$'\n' sorted_files=($(sort <<< "${sorted_files[*]}"))
        
        local priority_num=1
        for entry in "${sorted_files[@]}"; do
            IFS='|' read -r created file_path <<< "$entry"
            local metadata="${FILE_METADATA[$file_path]}"
            local name type
            name=$(echo "$metadata" | jq -r '.name // "unnamed"')
            type=$(echo "$metadata" | jq -r '.type // "unknown"')
            
            local priority action
            if [[ $priority_num -eq 1 ]]; then
                priority="1"
                action="keep_number"
            else
                priority="$priority_num"
                action="renumber"
            fi
            
            # Escape commas and quotes for CSV
            name=$(echo "$name" | sed 's/,/\\,/g' | sed 's/"/\\"/g')
            file_path=$(echo "$file_path" | sed 's/,/\\,/g')
            
            echo "$number,$conflict_id,$file_path,$name,$type,$created,$priority,$action"
            
            ((priority_num++))
        done
        
        ((conflict_num++))
    done
}

# Save conflict report to file
save_conflict_report() {
    local format="$1"
    local output_file="$2"
    
    if [[ -z "$output_file" ]]; then
        local project_id
        project_id="$(workspace_get_current_project_id)" || return 1
        
        local timestamp
        timestamp=$(date +"%Y%m%d_%H%M%S")
        
        case "$format" in
            "json")
                output_file="$HOME/.doh/projects/$project_id/conflict_report_${timestamp}.json"
                ;;
            "text")
                output_file="$HOME/.doh/projects/$project_id/conflict_report_${timestamp}.txt"
                ;;
            "csv")
                output_file="$HOME/.doh/projects/$project_id/conflict_report_${timestamp}.csv"
                ;;
        esac
    fi
    
    # Ensure output directory exists
    mkdir -p "$(dirname "$output_file")"
    
    build_conflict_report "$format" > "$output_file"
    echo "Conflict report saved to: $output_file" >&2
    echo "$output_file"
}

# Main detection command
main() {
    local command="${1:-detect}"
    
    case "$command" in
        "detect")
            scan_project_files || exit 1
            build_conflict_report "text"
            ;;
        "json")
            scan_project_files || exit 1
            build_conflict_report "json"
            ;;
        "csv")
            scan_project_files || exit 1
            build_conflict_report "csv"
            ;;
        "save")
            local format="${2:-json}"
            local output_file="$3"
            scan_project_files || exit 1
            save_conflict_report "$format" "$output_file"
            ;;
        "help")
            echo "DOH Duplicate Detection Utility"
            echo "=============================="
            echo ""
            echo "Usage: detect_duplicates.sh [command] [options]"
            echo ""
            echo "Commands:"
            echo "  detect        Show text report of duplicates (default)"
            echo "  json          Output JSON report"
            echo "  csv           Output CSV report"
            echo "  save <format> [file]  Save report to file"
            echo "  help          Show this help"
            echo ""
            echo "Examples:"
            echo "  ./detect_duplicates.sh"
            echo "  ./detect_duplicates.sh json | jq '.conflicts[]'"
            echo "  ./detect_duplicates.sh save json /tmp/conflicts.json"
            ;;
        *)
            echo "Error: Unknown command '$command'. Use 'help' for usage." >&2
            exit 1
            ;;
    esac
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
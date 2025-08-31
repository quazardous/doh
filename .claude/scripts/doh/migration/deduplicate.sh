#!/bin/bash

# Automated deduplication tool for DOH migration
# Resolves number conflicts using priority-based renumbering

# Source required dependencies
LIB_DIR="$(dirname "$0")/../lib"
source "$LIB_DIR/workspace.sh"
source "$LIB_DIR/numbering.sh"
source "$LIB_DIR/message-queue.sh"
source "$LIB_DIR/file-cache.sh"

MIGRATION_DIR="$(dirname "$0")"
source "$MIGRATION_DIR/detect_duplicates.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Migration state
declare -A RENUMBERING_PLAN
declare -A DEPENDENCY_MAP
declare -A UPDATED_REFERENCES

# Create backup of current state
create_migration_backup() {
    local project_root
    project_root="$(_find_doh_root)" || return 1
    
    local project_id timestamp
    project_id="$(get_current_project_id)" || return 1
    timestamp=$(date +"%Y%m%d_%H%M%S")
    
    local backup_dir="$HOME/.doh/projects/$project_id/backups/migration_$timestamp"
    
    echo -e "${BLUE}Creating migration backup...${NC}" >&2
    
    # Create backup directory
    mkdir -p "$backup_dir"
    
    # Copy all DOH files
    if [[ -d "$project_root/.doh" ]]; then
        cp -r "$project_root/.doh" "$backup_dir/"
    fi
    
    # Copy any existing registry files
    if [[ -d "$HOME/.doh/projects/$project_id" ]]; then
        cp -r "$HOME/.doh/projects/$project_id"/* "$backup_dir/" 2>/dev/null || true
    fi
    
    # Create backup metadata
    local metadata='{}'
    metadata=$(echo "$metadata" | jq --arg ts "$timestamp" '. + {timestamp: $ts}')
    metadata=$(echo "$metadata" | jq --arg pid "$project_id" '. + {project_id: $pid}')
    metadata=$(echo "$metadata" | jq --arg root "$project_root" '. + {project_root: $root}')
    metadata=$(echo "$metadata" | jq '. + {type: "migration_backup"}')
    
    echo "$metadata" | jq . > "$backup_dir/backup_metadata.json"
    
    echo -e "${GREEN}Backup created: $backup_dir${NC}" >&2
    echo "$backup_dir"
}

# Build renumbering plan from conflicts
build_renumbering_plan() {
    local conflicts_json="$1"
    
    echo -e "${BLUE}Building renumbering plan...${NC}" >&2
    
    # Clear previous plan
    RENUMBERING_PLAN=()
    
    local conflicts
    conflicts=$(echo "$conflicts_json" | jq -r '.conflicts[]')
    
    local plan_count=0
    
    while IFS= read -r conflict; do
        if [[ -n "$conflict" && "$conflict" != "null" ]]; then
            local number files_json
            number=$(echo "$conflict" | jq -r '.number')
            files_json=$(echo "$conflict" | jq -r '.files[]')
            
            local file_num=1
            while IFS= read -r file_info; do
                if [[ -n "$file_info" && "$file_info" != "null" ]]; then
                    local file_path
                    file_path=$(echo "$file_info" | jq -r '.path')
                    
                    if [[ $file_num -eq 1 ]]; then
                        # First file (oldest) keeps original number
                        echo -e "  ${GREEN}KEEP${NC}: $file_path keeps number $number" >&2
                    else
                        # Later files need renumbering
                        local new_number
                        new_number=$(get_next_number "task" 2>/dev/null || echo "")
                        
                        if [[ -n "$new_number" ]]; then
                            RENUMBERING_PLAN["$file_path"]="$number→$new_number"
                            echo -e "  ${YELLOW}RENUMBER${NC}: $file_path: $number → $new_number" >&2
                            ((plan_count++))
                        else
                            echo -e "  ${RED}ERROR${NC}: Could not allocate new number for $file_path" >&2
                            return 1
                        fi
                    fi
                    
                    ((file_num++))
                fi
            done <<< "$files_json"
        fi
    done <<< "$conflicts"
    
    echo -e "${GREEN}Renumbering plan created: $plan_count files to renumber${NC}" >&2
    return 0
}

# Map all dependencies before renumbering
map_dependencies() {
    local project_root
    project_root="$(_find_doh_root)" || return 1
    
    echo -e "${BLUE}Mapping dependencies...${NC}" >&2
    
    # Clear previous mapping
    DEPENDENCY_MAP=()
    
    local numbered_files
    numbered_files=$(find "$project_root" -name "*.md" -path "*/.doh/*" -type f)
    
    local dep_count=0
    
    while IFS= read -r file; do
        if [[ -n "$file" && -f "$file" ]]; then
            local rel_path
            rel_path=$(realpath --relative-to="$project_root" "$file")
            
            # Extract dependencies from frontmatter
            local depends_on parent
            depends_on=$(grep -m 1 "^depends_on:" "$file" 2>/dev/null | cut -d':' -f2- | xargs)
            parent=$(grep -m 1 "^parent:" "$file" 2>/dev/null | cut -d':' -f2- | xargs)
            
            # Parse depends_on array
            if [[ -n "$depends_on" ]]; then
                # Remove brackets and split by comma
                local deps
                deps=$(echo "$depends_on" | sed 's/^\[\s*//' | sed 's/\s*\]$//' | tr ',' '\n')
                
                while IFS= read -r dep; do
                    if [[ -n "$dep" ]]; then
                        dep=$(echo "$dep" | xargs)  # trim whitespace
                        DEPENDENCY_MAP["$rel_path:depends_on"]="${DEPENDENCY_MAP["$rel_path:depends_on"]} $dep"
                        ((dep_count++))
                    fi
                done <<< "$deps"
            fi
            
            # Track parent dependency
            if [[ -n "$parent" ]]; then
                DEPENDENCY_MAP["$rel_path:parent"]="$parent"
                ((dep_count++))
            fi
        fi
    done <<< "$numbered_files"
    
    echo -e "${GREEN}Mapped $dep_count dependencies${NC}" >&2
    return 0
}

# Update a single file's number and frontmatter
update_file_number() {
    local file_path="$1"
    local old_number="$2"
    local new_number="$3"
    local project_root="$4"
    
    local full_path="$project_root/$file_path"
    
    if [[ ! -f "$full_path" ]]; then
        echo "Error: File not found: $full_path" >&2
        return 1
    fi
    
    # Create temporary file for atomic update
    local temp_file="$full_path.renumber.tmp"
    
    # Update number in frontmatter
    sed "s/^number:\s*$old_number\s*$/number: $new_number/" "$full_path" > "$temp_file"
    
    # Verify the change was made
    local new_file_number
    new_file_number=$(grep -m 1 "^number:" "$temp_file" | cut -d':' -f2- | xargs)
    
    if [[ "$new_file_number" == "$new_number" ]]; then
        # Atomic replace
        mv "$temp_file" "$full_path"
        echo -e "  ${GREEN}✓${NC} Updated $file_path: $old_number → $new_number" >&2
        
        # Also rename the file if it was named after the number
        local file_name
        file_name=$(basename "$file_path")
        
        if [[ "$file_name" == "${old_number}.md" ]]; then
            local new_file_path="${file_path%/*}/${new_number}.md"
            local new_full_path="$project_root/$new_file_path"
            
            mv "$full_path" "$new_full_path"
            echo -e "  ${GREEN}✓${NC} Renamed file: $file_path → $new_file_path" >&2
            
            # Update RENUMBERING_PLAN to track file rename
            RENUMBERING_PLAN["$file_path"]="${RENUMBERING_PLAN["$file_path"]}|renamed:$new_file_path"
        fi
        
        return 0
    else
        rm -f "$temp_file"
        echo "Error: Failed to update number in $file_path" >&2
        return 1
    fi
}

# Update all dependency references
update_dependency_references() {
    local project_root
    project_root="$(_find_doh_root)" || return 1
    
    echo -e "${BLUE}Updating dependency references...${NC}" >&2
    
    # Clear previous tracking
    UPDATED_REFERENCES=()
    
    local ref_count=0
    
    # For each renumbered file, update all references to it
    for file_path in "${!RENUMBERING_PLAN[@]}"; do
        local plan="${RENUMBERING_PLAN[$file_path]}"
        local old_number new_number
        
        IFS='→' read -r old_number rest <<< "$plan"
        IFS='|' read -r new_number extra <<< "$rest"
        
        if [[ -n "$old_number" && -n "$new_number" ]]; then
            # Find all files that reference this old number
            local referencing_files
            referencing_files=$(grep -r "depends_on:.*$old_number" "$project_root/.doh" -l 2>/dev/null || true)
            referencing_files="$referencing_files"$'\n'$(grep -r "parent:\s*$old_number" "$project_root/.doh" -l 2>/dev/null || true)
            
            while IFS= read -r ref_file; do
                if [[ -n "$ref_file" && -f "$ref_file" ]]; then
                    local ref_rel_path
                    ref_rel_path=$(realpath --relative-to="$project_root" "$ref_file")
                    
                    # Create backup and update
                    local temp_file="$ref_file.depupdate.tmp"
                    
                    # Update depends_on arrays
                    sed -E "s/(depends_on:\s*\[[^\]]*)\b$old_number\b([^\]]*\])/\1$new_number\2/g" "$ref_file" | \
                    sed -E "s/(depends_on:\s*\[[^\]]*)\b$old_number,/\1$new_number,/g" | \
                    sed -E "s/(depends_on:\s*\[[^\]]*),\s*$old_number\b/\1, $new_number/g" | \
                    sed -E "s/^parent:\s*$old_number\s*$/parent: $new_number/" > "$temp_file"
                    
                    # Verify changes and apply
                    if [[ -f "$temp_file" ]]; then
                        mv "$temp_file" "$ref_file"
                        echo -e "  ${GREEN}✓${NC} Updated references in $ref_rel_path" >&2
                        UPDATED_REFERENCES["$ref_rel_path"]=1
                        ((ref_count++))
                    fi
                fi
            done <<< "$referencing_files"
        fi
    done
    
    echo -e "${GREEN}Updated $ref_count dependency references${NC}" >&2
    return 0
}

# Queue migration messages for tracking
queue_migration_messages() {
    echo -e "${BLUE}Queuing migration messages...${NC}" >&2
    
    local queue_name="migration_$(date +%Y%m%d_%H%M%S)"
    local message_count=0
    
    for file_path in "${!RENUMBERING_PLAN[@]}"; do
        local plan="${RENUMBERING_PLAN[$file_path]}"
        local old_number new_number
        
        IFS='→' read -r old_number rest <<< "$plan"
        IFS='|' read -r new_number extra <<< "$rest"
        
        if [[ -n "$old_number" && -n "$new_number" ]]; then
            # Create renumber message
            local metadata='{}'
            metadata=$(echo "$metadata" | jq --arg user "${USER:-system}" '. + {user: $user}')
            metadata=$(echo "$metadata" | jq '. + {command: "deduplicate"}')
            metadata=$(echo "$metadata" | jq --arg path "$file_path" '. + {file_path: $path}')
            
            if [[ "$extra" == *"renamed:"* ]]; then
                local new_path
                new_path=$(echo "$extra" | sed 's/.*renamed://')
                metadata=$(echo "$metadata" | jq --arg newpath "$new_path" '. + {new_file_path: $newpath}')
            fi
            
            local message
            message=$(create_renumber_message "task" "$file_path" "$old_number" "$new_number" "deduplication" "$metadata")
            
            if [[ -n "$message" ]]; then
                local message_id
                message_id=$(queue_message "$queue_name" "$message" 2>/dev/null)
                
                if [[ -n "$message_id" ]]; then
                    # Mark as successful
                    set_message_status "$queue_name" "$message_id" "$QUEUE_STATUS_OK" >/dev/null 2>&1
                    ((message_count++))
                fi
            fi
        fi
    done
    
    echo -e "${GREEN}Queued $message_count migration messages in queue: $queue_name${NC}" >&2
    echo "$queue_name"
}

# Validate migration results
validate_migration() {
    echo -e "${BLUE}Validating migration results...${NC}" >&2
    
    # Re-scan for duplicates
    scan_project_files >/dev/null 2>&1
    
    local remaining_duplicates=${#DUPLICATE_NUMBERS[@]}
    
    if [[ $remaining_duplicates -eq 0 ]]; then
        echo -e "${GREEN}✓ No duplicate numbers remaining${NC}" >&2
    else
        echo -e "${RED}✗ Still has $remaining_duplicates duplicate numbers${NC}" >&2
        return 1
    fi
    
    # Validate file cache consistency
    if rebuild_file_cache >/dev/null 2>&1; then
        echo -e "${GREEN}✓ File cache rebuilt successfully${NC}" >&2
    else
        echo -e "${RED}✗ File cache rebuild failed${NC}" >&2
        return 1
    fi
    
    # Check for broken dependencies
    local broken_deps=0
    local project_root
    project_root="$(_find_doh_root)" || return 1
    
    local numbered_files
    numbered_files=$(find "$project_root" -name "*.md" -path "*/.doh/*" -type f)
    
    while IFS= read -r file; do
        if [[ -n "$file" && -f "$file" ]]; then
            # Check if depends_on references exist
            local depends_on
            depends_on=$(grep -m 1 "^depends_on:" "$file" 2>/dev/null | cut -d':' -f2-)
            
            if [[ -n "$depends_on" ]]; then
                local deps
                deps=$(echo "$depends_on" | sed 's/^\[\s*//' | sed 's/\s*\]$//' | tr ',' '\n')
                
                while IFS= read -r dep; do
                    if [[ -n "$dep" ]]; then
                        dep=$(echo "$dep" | xargs)
                        
                        # Check if this number exists
                        if ! find_file_by_number "$dep" >/dev/null 2>&1; then
                            echo -e "${RED}✗ Broken dependency: $file references non-existent number $dep${NC}" >&2
                            ((broken_deps++))
                        fi
                    fi
                done <<< "$deps"
            fi
        fi
    done <<< "$numbered_files"
    
    if [[ $broken_deps -eq 0 ]]; then
        echo -e "${GREEN}✓ All dependencies valid${NC}" >&2
    else
        echo -e "${RED}✗ Found $broken_deps broken dependencies${NC}" >&2
        return 1
    fi
    
    return 0
}

# Generate migration report
generate_migration_report() {
    local backup_dir="$1"
    local queue_name="$2"
    
    local project_id timestamp
    project_id="$(get_current_project_id)" || return 1
    timestamp=$(date +"%Y%m%d_%H%M%S")
    
    local report_file="$HOME/.doh/projects/$project_id/migration_report_$timestamp.json"
    
    # Build report
    local report='{}'
    report=$(echo "$report" | jq --arg ts "$timestamp" '. + {timestamp: $ts}')
    report=$(echo "$report" | jq --arg pid "$project_id" '. + {project_id: $pid}')
    report=$(echo "$report" | jq '. + {type: "migration_report"}')
    report=$(echo "$report" | jq --arg backup "$backup_dir" '. + {backup_location: $backup}')
    
    if [[ -n "$queue_name" ]]; then
        report=$(echo "$report" | jq --arg queue "$queue_name" '. + {message_queue: $queue}')
    fi
    
    # Add renumbering summary
    local renumbered_files=${#RENUMBERING_PLAN[@]}
    local updated_refs=${#UPDATED_REFERENCES[@]}
    
    local summary='{}'
    summary=$(echo "$summary" | jq --arg files "$renumbered_files" '. + {files_renumbered: ($files | tonumber)}')
    summary=$(echo "$summary" | jq --arg refs "$updated_refs" '. + {references_updated: ($refs | tonumber)}')
    
    report=$(echo "$report" | jq --argjson summary "$summary" '. + {summary: $summary}')
    
    # Add detailed renumbering plan
    local plan_array='[]'
    for file_path in "${!RENUMBERING_PLAN[@]}"; do
        local plan="${RENUMBERING_PLAN[$file_path]}"
        local old_number new_number
        
        IFS='→' read -r old_number rest <<< "$plan"
        IFS='|' read -r new_number extra <<< "$rest"
        
        local plan_entry='{}'
        plan_entry=$(echo "$plan_entry" | jq --arg path "$file_path" '. + {file_path: $path}')
        plan_entry=$(echo "$plan_entry" | jq --arg old "$old_number" '. + {old_number: $old}')
        plan_entry=$(echo "$plan_entry" | jq --arg new "$new_number" '. + {new_number: $new}')
        
        if [[ "$extra" == *"renamed:"* ]]; then
            local new_path
            new_path=$(echo "$extra" | sed 's/.*renamed://')
            plan_entry=$(echo "$plan_entry" | jq --arg newpath "$new_path" '. + {new_file_path: $newpath}')
        fi
        
        plan_array=$(echo "$plan_array" | jq --argjson entry "$plan_entry" '. += [$entry]')
    done
    
    report=$(echo "$report" | jq --argjson plan "$plan_array" '. + {renumbering_plan: $plan}')
    
    # Save report
    echo "$report" | jq . > "$report_file"
    
    echo -e "${GREEN}Migration report saved: $report_file${NC}" >&2
    echo "$report_file"
}

# Main deduplication process
main() {
    local command="${1:-auto}"
    local dry_run="${2:-false}"
    
    case "$command" in
        "auto"|"automatic")
            echo "DOH Automated Deduplication"
            echo "==========================="
            echo ""
            
            if [[ "$dry_run" == "true" || "$dry_run" == "--dry-run" ]]; then
                echo -e "${YELLOW}DRY RUN MODE - No changes will be made${NC}"
                echo ""
            fi
            
            # Step 1: Detect conflicts
            echo -e "${BLUE}Step 1: Detecting conflicts...${NC}"
            scan_project_files || exit 1
            
            if [[ ${#DUPLICATE_NUMBERS[@]} -eq 0 ]]; then
                echo -e "${GREEN}No conflicts found - nothing to do!${NC}"
                exit 0
            fi
            
            echo ""
            
            # Step 2: Build JSON report
            echo -e "${BLUE}Step 2: Building conflict analysis...${NC}"
            local conflicts_json
            conflicts_json=$(build_conflict_report "json")
            
            # Step 3: Create backup (unless dry run)
            local backup_dir=""
            if [[ "$dry_run" != "true" && "$dry_run" != "--dry-run" ]]; then
                echo ""
                echo -e "${BLUE}Step 3: Creating backup...${NC}"
                backup_dir=$(create_migration_backup) || exit 1
            else
                echo ""
                echo -e "${YELLOW}Step 3: Skipping backup (dry run)${NC}"
            fi
            
            # Step 4: Build renumbering plan
            echo ""
            echo -e "${BLUE}Step 4: Building renumbering plan...${NC}"
            build_renumbering_plan "$conflicts_json" || exit 1
            
            # Step 5: Map dependencies
            echo ""
            echo -e "${BLUE}Step 5: Mapping dependencies...${NC}"
            map_dependencies || exit 1
            
            if [[ "$dry_run" == "true" || "$dry_run" == "--dry-run" ]]; then
                echo ""
                echo -e "${YELLOW}DRY RUN COMPLETE - Would have processed ${#RENUMBERING_PLAN[@]} files${NC}"
                echo ""
                echo "Renumbering plan:"
                for file_path in "${!RENUMBERING_PLAN[@]}"; do
                    echo "  $file_path: ${RENUMBERING_PLAN[$file_path]}"
                done
                exit 0
            fi
            
            # Step 6: Execute renumbering
            echo ""
            echo -e "${BLUE}Step 6: Executing renumbering...${NC}"
            local project_root
            project_root="$(_find_doh_root)" || exit 1
            
            local success_count=0
            for file_path in "${!RENUMBERING_PLAN[@]}"; do
                local plan="${RENUMBERING_PLAN[$file_path]}"
                local old_number new_number
                
                IFS='→' read -r old_number rest <<< "$plan"
                IFS='|' read -r new_number extra <<< "$rest"
                
                if update_file_number "$file_path" "$old_number" "$new_number" "$project_root"; then
                    ((success_count++))
                else
                    echo -e "${RED}Failed to update $file_path${NC}" >&2
                fi
            done
            
            echo -e "${GREEN}Successfully renumbered $success_count files${NC}"
            
            # Step 7: Update dependencies
            echo ""
            echo -e "${BLUE}Step 7: Updating dependency references...${NC}"
            update_dependency_references || exit 1
            
            # Step 8: Queue migration messages
            echo ""
            echo -e "${BLUE}Step 8: Recording migration history...${NC}"
            local queue_name
            queue_name=$(queue_migration_messages) || exit 1
            
            # Step 9: Validate results
            echo ""
            echo -e "${BLUE}Step 9: Validating migration...${NC}"
            if validate_migration; then
                echo -e "${GREEN}Migration validation successful!${NC}"
            else
                echo -e "${RED}Migration validation failed!${NC}"
                exit 1
            fi
            
            # Step 10: Generate report
            echo ""
            echo -e "${BLUE}Step 10: Generating report...${NC}"
            local report_file
            report_file=$(generate_migration_report "$backup_dir" "$queue_name")
            
            echo ""
            echo -e "${GREEN}MIGRATION COMPLETED SUCCESSFULLY!${NC}"
            echo ""
            echo "Summary:"
            echo "  Files processed: ${#RENUMBERING_PLAN[@]}"
            echo "  References updated: ${#UPDATED_REFERENCES[@]}"
            echo "  Backup location: $backup_dir"
            echo "  Migration report: $report_file"
            echo ""
            ;;
            
        "help")
            echo "DOH Deduplication Tool"
            echo "====================="
            echo ""
            echo "Usage: deduplicate.sh [command] [options]"
            echo ""
            echo "Commands:"
            echo "  auto              Run automatic deduplication (default)"
            echo "  auto --dry-run    Show what would be done without making changes"
            echo "  help              Show this help"
            echo ""
            echo "Examples:"
            echo "  ./deduplicate.sh"
            echo "  ./deduplicate.sh auto --dry-run"
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
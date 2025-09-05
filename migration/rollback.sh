#!/bin/bash

# Migration rollback utility for DOH
# Restores project state from migration backups

# Source required dependencies
LIB_DIR="$(dirname "$0")/../.claude/scripts/doh/lib"
source "$LIB_DIR/doh.sh"
source "$LIB_DIR/dohenv.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# List available backups
list_backups() {
    local project_id
    project_id="$(doh_project_id)" || return 1
    
    local backup_root="$HOME/.doh/projects/$project_id/backups"
    
    if [[ ! -d "$backup_root" ]]; then
        echo "No backups found for project: $project_id"
        return 0
    fi
    
    echo "Available Migration Backups"
    echo "=========================="
    echo ""
    
    local backup_count=0
    
    find "$backup_root" -name "migration_*" -type d | sort -r | while read -r backup_dir; do
        if [[ -f "$backup_dir/backup_metadata.json" ]]; then
            local backup_name
            backup_name=$(basename "$backup_dir")
            
            local metadata
            metadata=$(cat "$backup_dir/backup_metadata.json" 2>/dev/null)
            
            if [[ -n "$metadata" ]]; then
                local timestamp project_root
                timestamp=$(echo "$metadata" | jq -r '.timestamp // "unknown"')
                project_root=$(echo "$metadata" | jq -r '.project_root // "unknown"')
                
                echo "Backup: $backup_name"
                echo "  Created: $timestamp"
                echo "  Project: $project_root"
                echo "  Location: $backup_dir"
                echo ""
                
                ((backup_count++))
            fi
        fi
    done
    
    if [[ $backup_count -eq 0 ]]; then
        echo "No valid migration backups found"
    else
        echo "Found $backup_count backup(s)"
    fi
    
    return 0
}

# Validate backup integrity
validate_backup() {
    local backup_dir="$1"
    
    if [[ ! -d "$backup_dir" ]]; then
        echo "Error: Backup directory not found: $backup_dir" >&2
        return 1
    fi
    
    echo -e "${BLUE}Validating backup integrity...${NC}" >&2
    
    # Check for metadata file
    if [[ ! -f "$backup_dir/backup_metadata.json" ]]; then
        echo "Error: Backup metadata not found" >&2
        return 1
    fi
    
    # Validate metadata
    local metadata
    metadata=$(cat "$backup_dir/backup_metadata.json" 2>/dev/null)
    
    if [[ -z "$metadata" ]]; then
        echo "Error: Invalid backup metadata" >&2
        return 1
    fi
    
    if ! echo "$metadata" | jq -e '.timestamp and .project_id and .project_root' >/dev/null 2>&1; then
        echo "Error: Incomplete backup metadata" >&2
        return 1
    fi
    
    # Check for .doh directory backup
    if [[ ! -d "$backup_dir/.doh" ]]; then
        echo "Error: DOH files not found in backup" >&2
        return 1
    fi
    
    # Count backed up files
    local file_count
    file_count=$(find "$backup_dir/.doh" -name "*.md" -type f | wc -l)
    
    echo -e "${GREEN}Backup validation successful${NC}" >&2
    echo -e "${GREEN}Found $file_count markdown files in backup${NC}" >&2
    
    return 0
}

# Create pre-rollback backup
create_pre_rollback_backup() {
    local project_root
    project_root="$(_find_doh_root)" || return 1
    
    local project_id timestamp
    project_id="$(doh_project_id)" || return 1
    timestamp=$(date +"%Y%m%d_%H%M%S")
    
    local backup_dir="$HOME/.doh/projects/$project_id/backups/pre_rollback_$timestamp"
    
    echo -e "${BLUE}Creating pre-rollback backup...${NC}" >&2
    
    # Create backup directory
    mkdir -p "$backup_dir"
    
    # Copy current state
    if [[ -d "$project_root/.doh" ]]; then
        cp -r "$project_root/.doh" "$backup_dir/"
    fi
    
    # Copy current registry files
    if [[ -d "$HOME/.doh/projects/$project_id" ]]; then
        find "$HOME/.doh/projects/$project_id" -maxdepth 1 -name "*.json" -o -name "*.csv" -o -name "TASKSEQ" | while read -r file; do
            if [[ -f "$file" ]]; then
                cp "$file" "$backup_dir/" 2>/dev/null || true
            fi
        done
    fi
    
    # Create backup metadata
    local metadata='{}'
    metadata=$(echo "$metadata" | jq --arg ts "$timestamp" '. + {timestamp: $ts}')
    metadata=$(echo "$metadata" | jq --arg pid "$project_id" '. + {project_id: $pid}')
    metadata=$(echo "$metadata" | jq --arg root "$project_root" '. + {project_root: $root}')
    metadata=$(echo "$metadata" | jq '. + {type: "pre_rollback_backup"}')
    
    echo "$metadata" | jq . > "$backup_dir/backup_metadata.json"
    
    echo -e "${GREEN}Pre-rollback backup created: $backup_dir${NC}" >&2
    echo "$backup_dir"
}

# Restore files from backup
restore_from_backup() {
    local backup_dir="$1"
    local create_pre_backup="${2:-true}"
    
    if [[ ! -d "$backup_dir" ]]; then
        echo "Error: Backup directory not found: $backup_dir" >&2
        return 1
    fi
    
    # Validate backup first
    validate_backup "$backup_dir" || return 1
    
    # Get project root from backup metadata
    local metadata project_root
    metadata=$(cat "$backup_dir/backup_metadata.json")
    project_root=$(echo "$metadata" | jq -r '.project_root')
    
    if [[ ! -d "$project_root" ]]; then
        echo "Error: Original project root not found: $project_root" >&2
        return 1
    fi
    
    # Create pre-rollback backup
    local pre_backup_dir=""
    if [[ "$create_pre_backup" == "true" ]]; then
        pre_backup_dir=$(create_pre_rollback_backup) || return 1
    fi
    
    echo -e "${BLUE}Restoring files from backup...${NC}" >&2
    
    # Remove current .doh directory
    if [[ -d "$project_root/.doh" ]]; then
        rm -rf "$project_root/.doh"
    fi
    
    # Restore .doh directory from backup
    if [[ -d "$backup_dir/.doh" ]]; then
        cp -r "$backup_dir/.doh" "$project_root/"
        echo -e "${GREEN}✓ Restored .doh directory${NC}" >&2
    fi
    
    # Restore registry files
    local project_id registry_dir
    project_id="$(doh_project_id)" || return 1
    registry_dir="$HOME/.doh/projects/$project_id"
    
    # Clean current registry files
    if [[ -d "$registry_dir" ]]; then
        find "$registry_dir" -maxdepth 1 -name "*.json" -o -name "*.csv" -o -name "TASKSEQ" | while read -r file; do
            if [[ -f "$file" ]]; then
                rm -f "$file"
            fi
        done
    else
        mkdir -p "$registry_dir"
    fi
    
    # Restore registry files from backup
    find "$backup_dir" -maxdepth 1 -name "*.json" -o -name "*.csv" -o -name "TASKSEQ" | while read -r backup_file; do
        if [[ -f "$backup_file" ]]; then
            local filename
            filename=$(basename "$backup_file")
            cp "$backup_file" "$registry_dir/"
            echo -e "${GREEN}✓ Restored registry file: $filename${NC}" >&2
        fi
    done
    
    # Count restored files
    local restored_count
    restored_count=$(find "$project_root/.doh" -name "*.md" -type f 2>/dev/null | wc -l)
    
    echo -e "${GREEN}Rollback completed successfully${NC}" >&2
    echo -e "${GREEN}Restored $restored_count markdown files${NC}" >&2
    
    if [[ -n "$pre_backup_dir" ]]; then
        echo -e "${BLUE}Pre-rollback backup saved: $pre_backup_dir${NC}" >&2
    fi
    
    return 0
}

# Show backup details
show_backup_details() {
    local backup_dir="$1"
    
    if [[ ! -d "$backup_dir" ]]; then
        echo "Error: Backup directory not found: $backup_dir" >&2
        return 1
    fi
    
    if [[ ! -f "$backup_dir/backup_metadata.json" ]]; then
        echo "Error: Backup metadata not found" >&2
        return 1
    fi
    
    echo "Backup Details"
    echo "=============="
    echo ""
    
    local metadata
    metadata=$(cat "$backup_dir/backup_metadata.json")
    
    echo "Location: $backup_dir"
    echo "Timestamp: $(echo "$metadata" | jq -r '.timestamp')"
    echo "Project ID: $(echo "$metadata" | jq -r '.project_id')"
    echo "Project Root: $(echo "$metadata" | jq -r '.project_root')"
    echo "Type: $(echo "$metadata" | jq -r '.type')"
    echo ""
    
    # Show file statistics
    if [[ -d "$backup_dir/.doh" ]]; then
        local total_files epic_files task_files
        total_files=$(find "$backup_dir/.doh" -name "*.md" -type f | wc -l)
        epic_files=$(find "$backup_dir/.doh" -name "epic.md" -type f | wc -l)
        task_files=$((total_files - epic_files))
        
        echo "File Statistics:"
        echo "  Total files: $total_files"
        echo "  Epic files: $epic_files"  
        echo "  Task files: $task_files"
        echo ""
    fi
    
    # Show registry files
    local registry_files
    registry_files=$(find "$backup_dir" -maxdepth 1 -name "*.json" -o -name "*.csv" -o -name "TASKSEQ" | wc -l)
    
    echo "Registry files: $registry_files"
    
    return 0
}

# Interactive rollback selection
interactive_rollback() {
    echo "DOH Migration Rollback - Interactive Mode"
    echo "========================================"
    echo ""
    
    # List available backups
    local project_id
    project_id="$(doh_project_id)" || return 1
    
    local backup_root="$HOME/.doh/projects/$project_id/backups"
    
    if [[ ! -d "$backup_root" ]]; then
        echo "No backups found for project: $project_id"
        return 1
    fi
    
    echo "Available backups:"
    echo ""
    
    local backup_dirs=()
    local backup_count=0
    
    find "$backup_root" -name "migration_*" -o -name "pre_rollback_*" -type d | sort -r | while read -r backup_dir; do
        if [[ -f "$backup_dir/backup_metadata.json" ]]; then
            backup_dirs+=("$backup_dir")
            
            local backup_name
            backup_name=$(basename "$backup_dir")
            
            local metadata timestamp
            metadata=$(cat "$backup_dir/backup_metadata.json" 2>/dev/null)
            timestamp=$(echo "$metadata" | jq -r '.timestamp // "unknown"')
            
            echo "  $((++backup_count)). $backup_name ($timestamp)"
        fi
    done
    
    if [[ $backup_count -eq 0 ]]; then
        echo "No valid backups found"
        return 1
    fi
    
    echo ""
    read -p "Select backup number (1-$backup_count, or 0 to cancel): " selection
    
    if [[ "$selection" == "0" ]]; then
        echo "Rollback cancelled"
        return 0
    fi
    
    if [[ ! "$selection" =~ ^[1-9][0-9]*$ ]] || [[ $selection -gt $backup_count ]]; then
        echo "Error: Invalid selection" >&2
        return 1
    fi
    
    # Get selected backup directory
    local selected_backup
    selected_backup=$(find "$backup_root" -name "migration_*" -o -name "pre_rollback_*" -type d | sort -r | sed -n "${selection}p")
    
    if [[ ! -d "$selected_backup" ]]; then
        echo "Error: Selected backup not found" >&2
        return 1
    fi
    
    echo ""
    show_backup_details "$selected_backup"
    echo ""
    
    read -p "Proceed with rollback? [y/N] " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        restore_from_backup "$selected_backup"
    else
        echo "Rollback cancelled"
    fi
    
    return 0
}

# Main rollback command
main() {
    local command="${1:-interactive}"
    
    case "$command" in
        "list")
            list_backups
            ;;
            
        "show")
            local backup_dir="$2"
            if [[ -z "$backup_dir" ]]; then
                echo "Usage: rollback.sh show <backup_directory>" >&2
                exit 1
            fi
            show_backup_details "$backup_dir"
            ;;
            
        "restore")
            local backup_dir="$2"
            local create_pre_backup="${3:-true}"
            
            if [[ -z "$backup_dir" ]]; then
                echo "Usage: rollback.sh restore <backup_directory> [create_pre_backup]" >&2
                exit 1
            fi
            
            restore_from_backup "$backup_dir" "$create_pre_backup"
            ;;
            
        "interactive"|"")
            interactive_rollback
            ;;
            
        "help")
            echo "DOH Migration Rollback Utility"
            echo "============================="
            echo ""
            echo "Usage: rollback.sh [command] [options]"
            echo ""
            echo "Commands:"
            echo "  interactive       Interactive backup selection (default)"
            echo "  list              List available backups"
            echo "  show <backup_dir> Show backup details"
            echo "  restore <backup_dir> [no_pre_backup]"
            echo "                    Restore from specific backup"
            echo "  help              Show this help"
            echo ""
            echo "Examples:"
            echo "  ./rollback.sh"
            echo "  ./rollback.sh list"
            echo "  ./rollback.sh restore /path/to/backup"
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
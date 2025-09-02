#!/bin/bash

# Main migration orchestrator for DOH project numbering system
# Coordinates detection, deduplication, and validation processes

# Source required dependencies
LIB_DIR="$(dirname "$0")/../.claude/scripts/doh/lib"
MIGRATION_DIR="$(dirname "$0")"

source "$LIB_DIR/dohenv.sh"
source "$MIGRATION_DIR/detect_duplicates.sh"
source "$MIGRATION_DIR/deduplicate.sh"
source "$MIGRATION_DIR/rollback.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Print banner
print_banner() {
    echo -e "${BOLD}${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    DOH Migration Tool                        ║"
    echo "║              Numbering System Migration Utility             ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

# Show migration status
show_migration_status() {
    echo -e "${BOLD}Migration Status${NC}"
    echo "==============="
    echo ""
    
    # Check if in DOH project
    if ! _find_doh_root >/dev/null 2>&1; then
        echo -e "${RED}✗ Not in a DOH project directory${NC}"
        return 1
    fi
    
    local project_root
    project_root="$(_find_doh_root)"
    echo -e "${GREEN}✓ DOH project detected${NC}: $project_root"
    
    # Check for numbered files
    local numbered_files
    numbered_files=$(find "$project_root" -name "*.md" -path "*/.doh/*" -type f -exec grep -l "^number:" {} \; 2>/dev/null | wc -l)
    echo -e "${GREEN}✓ Numbered files found${NC}: $numbered_files"
    
    # Quick conflict check
    echo ""
    echo "Running quick conflict detection..."
    scan_project_files >/dev/null 2>&1
    
    local duplicate_count=${#DUPLICATE_NUMBERS[@]}
    
    if [[ $duplicate_count -eq 0 ]]; then
        echo -e "${GREEN}✓ No duplicate numbers detected${NC}"
        echo ""
        echo -e "${GREEN}Project appears to be ready for the new numbering system!${NC}"
    else
        echo -e "${YELLOW}⚠ Found $duplicate_count numbers with duplicates${NC}"
        echo ""
        echo -e "${YELLOW}Migration recommended to resolve conflicts${NC}"
        
        # Show summary of conflicts
        echo ""
        echo "Conflict Summary:"
        for number in $(printf '%s\n' "${!DUPLICATE_NUMBERS[@]}" | sort -n); do
            local files_list="${NUMBER_FILES[$number]}"
            local file_count
            file_count=$(echo "$files_list" | tr '|' '\n' | wc -l)
            echo "  Number $number: $file_count files"
        done
    fi
    
    # Check for existing backups
    local project_id
    project_id="$(get_current_project_id)" 2>/dev/null
    
    if [[ -n "$project_id" ]]; then
        local backup_root="$HOME/.doh/projects/$project_id/backups"
        
        if [[ -d "$backup_root" ]]; then
            local backup_count
            backup_count=$(find "$backup_root" -name "migration_*" -type d 2>/dev/null | wc -l)
            
            if [[ $backup_count -gt 0 ]]; then
                echo ""
                echo -e "${BLUE}ℹ Found $backup_count existing migration backups${NC}"
                echo "  Use 'migrate rollback list' to see available backups"
            fi
        fi
    fi
    
    return 0
}

# Interactive migration workflow
interactive_migration() {
    print_banner
    
    echo "Welcome to the DOH Migration Tool!"
    echo ""
    echo "This tool will help you migrate your existing DOH project"
    echo "to use the new centralized numbering system."
    echo ""
    
    # Show current status
    show_migration_status
    
    echo ""
    echo "Migration Options:"
    echo "=================="
    echo ""
    echo "1. Detect conflicts only (no changes)"
    echo "2. Run full migration (automatic deduplication)"
    echo "3. Dry run migration (show what would be done)"
    echo "4. View existing backups"
    echo "5. Rollback previous migration"
    echo "0. Exit"
    echo ""
    
    read -p "Select option (0-5): " option
    
    case "$option" in
        "1")
            echo ""
            echo -e "${BLUE}Running conflict detection...${NC}"
            echo ""
            scan_project_files || return 1
            build_conflict_report "text"
            ;;
            
        "2")
            echo ""
            echo -e "${YELLOW}WARNING: This will modify your project files!${NC}"
            echo "A backup will be created before making any changes."
            echo ""
            read -p "Continue with full migration? [y/N] " -n 1 -r
            echo
            
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo ""
                echo -e "${BLUE}Running full migration...${NC}"
                echo ""
                main "auto" "false"
            else
                echo "Migration cancelled"
            fi
            ;;
            
        "3")
            echo ""
            echo -e "${BLUE}Running dry run migration...${NC}"
            echo ""
            main "auto" "true"
            ;;
            
        "4")
            echo ""
            list_backups
            ;;
            
        "5")
            echo ""
            interactive_rollback
            ;;
            
        "0")
            echo "Exiting migration tool"
            exit 0
            ;;
            
        *)
            echo "Invalid option selected"
            exit 1
            ;;
    esac
}

# Pre-flight checks
run_preflight_checks() {
    echo -e "${BLUE}Running pre-flight checks...${NC}"
    
    local checks_passed=0
    local total_checks=5
    
    # Check 1: DOH project detection
    if _find_doh_root >/dev/null 2>&1; then
        echo -e "${GREEN}✓ DOH project detected${NC}"
        ((checks_passed++))
    else
        echo -e "${RED}✗ Not in a DOH project directory${NC}"
    fi
    
    # Check 2: Required commands
    local required_commands=("jq" "find" "grep" "sed")
    local missing_commands=0
    
    for cmd in "${required_commands[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            continue
        else
            if [[ $missing_commands -eq 0 ]]; then
                echo -e "${RED}✗ Missing required commands:${NC}"
            fi
            echo -e "${RED}    - $cmd${NC}"
            ((missing_commands++))
        fi
    done
    
    if [[ $missing_commands -eq 0 ]]; then
        echo -e "${GREEN}✓ Required commands available${NC}"
        ((checks_passed++))
    fi
    
    # Check 3: Write permissions
    local project_root
    project_root="$(_find_doh_root)" 2>/dev/null
    
    if [[ -n "$project_root" && -w "$project_root" ]]; then
        echo -e "${GREEN}✓ Project directory is writable${NC}"
        ((checks_passed++))
    else
        echo -e "${RED}✗ Project directory is not writable${NC}"
    fi
    
    # Check 4: Registry directory access
    local project_id registry_dir
    project_id="$(get_current_project_id)" 2>/dev/null
    
    if [[ -n "$project_id" ]]; then
        registry_dir="$HOME/.doh/projects/$project_id"
        
        if mkdir -p "$registry_dir" 2>/dev/null && [[ -w "$registry_dir" ]]; then
            echo -e "${GREEN}✓ Registry directory accessible${NC}"
            ((checks_passed++))
        else
            echo -e "${RED}✗ Cannot access registry directory${NC}"
        fi
    else
        echo -e "${RED}✗ Cannot determine project ID${NC}"
    fi
    
    # Check 5: Git availability (optional but recommended)
    if command -v git >/dev/null 2>&1 && git status >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Git repository detected${NC}"
        ((checks_passed++))
    else
        echo -e "${YELLOW}⚠ Git not available (recommended for backup)${NC}"
    fi
    
    echo ""
    echo "Pre-flight check results: $checks_passed/$total_checks passed"
    
    if [[ $checks_passed -lt 4 ]]; then
        echo -e "${RED}Critical issues detected - migration cannot proceed${NC}"
        return 1
    elif [[ $checks_passed -lt $total_checks ]]; then
        echo -e "${YELLOW}Some issues detected - proceed with caution${NC}"
        return 0
    else
        echo -e "${GREEN}All checks passed - ready for migration${NC}"
        return 0
    fi
}

# Show help
show_help() {
    echo "DOH Migration Tool"
    echo "=================="
    echo ""
    echo "A comprehensive tool for migrating DOH projects to the new numbering system."
    echo ""
    echo "Usage: migrate.sh [command] [options]"
    echo ""
    echo "Commands:"
    echo "  status            Show current project migration status"
    echo "  detect            Detect duplicate numbers (no changes)"
    echo "  migrate           Run full migration with deduplication"
    echo "  migrate --dry-run Run migration simulation (no changes)"
    echo "  rollback          Interactive rollback to previous backup"
    echo "  rollback list     List available backups"
    echo "  preflight         Run pre-flight checks"
    echo "  interactive       Interactive migration mode (default)"
    echo "  help              Show this help"
    echo ""
    echo "Migration Process:"
    echo "1. Pre-flight checks validate environment"
    echo "2. Conflict detection identifies duplicate numbers"
    echo "3. Backup creation preserves current state"
    echo "4. Deduplication resolves conflicts automatically"
    echo "5. Dependency tracking updates cross-references"
    echo "6. Validation ensures migration success"
    echo "7. Report generation documents changes"
    echo ""
    echo "Safety Features:"
    echo "• Automatic backup before any changes"
    echo "• Dry-run mode to preview changes"
    echo "• Complete rollback capability"
    echo "• Dependency validation"
    echo "• Migration audit trail"
    echo ""
    echo "Examples:"
    echo "  ./migrate.sh                    # Interactive mode"
    echo "  ./migrate.sh detect             # Check for conflicts"
    echo "  ./migrate.sh migrate --dry-run  # Preview migration"
    echo "  ./migrate.sh migrate            # Run full migration"
    echo "  ./migrate.sh rollback           # Restore from backup"
    echo ""
}

# Main entry point
main() {
    local command="${1:-interactive}"
    local options="$2"
    
    case "$command" in
        "status")
            print_banner
            show_migration_status
            ;;
            
        "detect")
            print_banner
            echo -e "${BLUE}Running duplicate number detection...${NC}"
            echo ""
            scan_project_files || exit 1
            build_conflict_report "text"
            ;;
            
        "migrate")
            print_banner
            
            # Run pre-flight checks first
            if ! run_preflight_checks; then
                echo ""
                echo -e "${RED}Pre-flight checks failed - migration aborted${NC}"
                exit 1
            fi
            
            echo ""
            
            if [[ "$options" == "--dry-run" ]]; then
                echo -e "${BLUE}Running migration dry run...${NC}"
            else
                echo -e "${BLUE}Running full migration...${NC}"
            fi
            
            echo ""
            
            # Call deduplication tool
            source "$MIGRATION_DIR/deduplicate.sh"
            main "auto" "$options"
            ;;
            
        "rollback")
            print_banner
            
            if [[ "$options" == "list" ]]; then
                list_backups
            else
                interactive_rollback
            fi
            ;;
            
        "preflight")
            print_banner
            run_preflight_checks
            ;;
            
        "interactive"|"")
            interactive_migration
            ;;
            
        "help"|"-h"|"--help")
            show_help
            ;;
            
        *)
            echo "Error: Unknown command '$command'" >&2
            echo "Use 'migrate.sh help' for usage information" >&2
            exit 1
            ;;
    esac
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
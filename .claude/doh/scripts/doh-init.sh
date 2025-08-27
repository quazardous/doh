#!/bin/bash
# DOH Init Script - Initialize DOH system in a project
# Usage: ./doh-init.sh [options]

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOH_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKEL_DIR="$DOH_ROOT/skel"

# Default options
FORCE=false
VERBOSE=false
NO_CONFIRM=false
PROJECT_ROOT=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Usage function
usage() {
    cat << EOF
DOH Init - Initialize DOH system in a project

Usage: $0 [options]

Options:
    --force         Force reinitialization if .doh already exists
    --verbose       Enable verbose output
    --no-confirm    Skip confirmation prompt (use with caution)
    --help          Show this help message

Examples:
    $0                          # Interactive initialization
    $0 --force                  # Force reinitialization
    $0 --verbose               # Verbose output

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --force)
            FORCE=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --no-confirm)
            NO_CONFIRM=true
            shift
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Find project root
find_project_root() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/.git" ]]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    return 1
}

# Initialize DOH system
init_doh() {
    log_info "🚀 DOH Initialization Starting..."
    
    # Find project root
    if ! PROJECT_ROOT=$(find_project_root); then
        log_error "Not in a Git repository. DOH requires a Git project."
        exit 1
    fi
    
    log_info "📁 Project root: $PROJECT_ROOT"
    
    local doh_dir="$PROJECT_ROOT/.doh"
    
    # Check if .doh already exists
    if [[ -d "$doh_dir" ]] && [[ "$FORCE" != "true" ]]; then
        log_warning ".doh directory already exists at $doh_dir"
        echo -n "Reinitialize? This will backup existing .doh directory (y/N): "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            log_info "Initialization cancelled"
            exit 0
        fi
        FORCE=true
    fi
    
    # Backup existing .doh if force mode
    if [[ -d "$doh_dir" ]] && [[ "$FORCE" == "true" ]]; then
        local backup_dir="${doh_dir}.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "📦 Backing up existing .doh to $backup_dir"
        mv "$doh_dir" "$backup_dir"
    fi
    
    # Verify skeleton exists
    if [[ ! -d "$SKEL_DIR" ]]; then
        log_error "Skeleton directory not found at $SKEL_DIR"
        exit 1
    fi
    
    log_info "📋 Copying skeleton from $SKEL_DIR to $doh_dir"
    
    # Copy skeleton structure
    cp -r "$SKEL_DIR" "$doh_dir"
    
    # Remove the test deployment script from the copied skeleton
    rm -f "$doh_dir/test-deployment.sh"
    
    # Customize project-index.json with project-specific data
    local project_name=$(basename "$PROJECT_ROOT")
    local current_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    log_info "🔧 Customizing project configuration..."
    
    # Update project-index.json with actual project data
    if command -v jq >/dev/null 2>&1; then
        jq --arg name "$project_name" \
           --arg time "$current_time" \
           '.metadata.project_name = $name | 
            .metadata.created_at = $time | 
            .metadata.updated_at = $time |
            .items.epics."0".created_at = $time |
            .items.epics."0".updated_at = $time' \
           "$doh_dir/project-index.json" > "$doh_dir/project-index.json.tmp"
        mv "$doh_dir/project-index.json.tmp" "$doh_dir/project-index.json"
    else
        log_warning "jq not found - project-index.json not customized"
    fi
    
    # Generate project UUID for identity validation
    local project_uuid
    if command -v uuidgen >/dev/null 2>&1; then
        project_uuid=$(uuidgen)
    else
        # Fallback UUID generation
        project_uuid=$(date +"%s%N" | sha256sum | cut -c1-8)-$(date +"%s%N" | sha256sum | cut -c9-12)-4$(date +"%s%N" | sha256sum | cut -c13-15)-$(date +"%s%N" | sha256sum | cut -c17-20)-$(date +"%s%N" | sha256sum | cut -c21-32)
    fi
    
    echo "$project_uuid" > "$doh_dir/uuid"
    log_info "🔑 Generated project UUID: $project_uuid"
    
    # Update config.ini with project details and paths
    if [[ -f "$doh_dir/config.ini" ]]; then
        local canonical_path="$(cd "$PROJECT_ROOT" && pwd -P)"
        sed -i "s/^name = $/name = $project_name/" "$doh_dir/config.ini"
        sed -i "s|^preferred_path = $|preferred_path = $PROJECT_ROOT|" "$doh_dir/config.ini"
        sed -i "s|^canonical_path = $|canonical_path = $canonical_path|" "$doh_dir/config.ini"
        sed -i "s|^discovered_paths = $|discovered_paths = $canonical_path|" "$doh_dir/config.ini"
        sed -i "s/^last_discovered = $/last_discovered = $current_time/" "$doh_dir/config.ini"
    fi
    
    log_success "✅ DOH system initialized successfully!"
    
    # Show completion summary
    echo ""
    log_info "📊 DOH System Summary:"
    echo "  📁 Project: $project_name"
    echo "  📂 Location: $doh_dir"
    echo "  📋 Epic #0: Ready for quick tasks"
    echo "  🧠 Memory: Project/Epic/Session levels ready"
    echo ""
    log_info "🎯 Quick Start:"
    echo "  Use '/doh:quick \"task description\"' to create your first task"
    echo "  All tasks will be added to Epic #0 automatically"
    echo ""
    log_success "🎉 DOH is ready to use!"
}

# Confirmation prompt (always shown unless --no-confirm is used)
prompt_confirmation() {
    if [[ "$NO_CONFIRM" != "true" ]]; then
        echo ""
        log_info "🤔 DOH System Initialization"
        echo "This will initialize the DOH task management system in this project."
        echo "It will create a '.doh' directory structure for managing tasks, epics, and project memory."
        echo ""
        echo -n "Do you want to proceed with DOH initialization? (y/N): "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            log_info "DOH initialization cancelled by user"
            exit 0
        fi
    fi
}

# Main execution
prompt_confirmation
init_doh
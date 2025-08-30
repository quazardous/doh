#!/bin/bash
# Prettier Plugin Manager
# Manages prettier-specific plugins with config integration

set -euo pipefail

# Configuration
PLUGINS_DIR="$(dirname "$0")/prettier"
MAIN_CONFIG=".prettierrc"
IGNORE_FILE=".prettierignore"
BACKUP_DIR="../backups"

# Ensure directories exist
mkdir -p "$PLUGINS_DIR" "$BACKUP_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[PRETTIER]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[PRETTIER]${NC} $1"
}

error() {
    echo -e "${RED}[PRETTIER]${NC} $1" >&2
}

# List all prettier plugins
list_plugins() {
    log "📋 Prettier Plugins:"
    
    if [ ! -d "$PLUGINS_DIR" ] || [ -z "$(ls -A "$PLUGINS_DIR" 2>/dev/null)" ]; then
        warn "   No plugins found in $PLUGINS_DIR"
        return
    fi
    
    for plugin_dir in "$PLUGINS_DIR"/*; do
        if [ -d "$plugin_dir" ]; then
            plugin_name=$(basename "$plugin_dir")
            status_file="$plugin_dir/STATUS"
            
            if [ -f "$status_file" ]; then
                status=$(head -n1 "$status_file")
                case "$status" in
                    "APPLIED") echo -e "   ✅ $plugin_name - ${GREEN}$status${NC}" ;;
                    "PROPOSED") echo -e "   💡 $plugin_name - ${YELLOW}$status${NC}" ;;
                    "REFUSED") echo -e "   ❌ $plugin_name - ${RED}$status${NC}" ;;
                    *) echo -e "   ⚪ $plugin_name - $status" ;;
                esac
            else
                echo -e "   ⚪ $plugin_name - ${YELLOW}Unknown${NC}"
            fi
        fi
    done
}

# Check plugin status
check_status() {
    local plugin_name="$1"
    local status_file="$PLUGINS_DIR/$plugin_name/STATUS"
    
    if [ ! -f "$status_file" ]; then
        error "Plugin '$plugin_name' not found"
        return 1
    fi
    
    local status=$(head -n1 "$status_file")
    echo "$status"
}

# Enable plugin (install configuration)
enable_plugin() {
    local plugin_name="$1"
    local plugin_dir="$PLUGINS_DIR/$plugin_name"
    local status_file="$plugin_dir/STATUS"
    local config_fragment="$plugin_dir/config-fragment.json"
    
    if [ ! -d "$plugin_dir" ]; then
        error "Plugin '$plugin_name' not found in $plugin_dir"
        return 1
    fi
    
    log "🔧 Enabling prettier plugin: $plugin_name"
    
    # Create backup if main config exists
    if [ -f "$MAIN_CONFIG" ]; then
        backup_file="$BACKUP_DIR/prettierrc.bak-$plugin_name-$(date +%Y%m%d-%H%M%S)"
        cp "$MAIN_CONFIG" "$backup_file"
        log "   📦 Backup created: $backup_file"
    fi
    
    # Merge configuration if fragment exists
    if [ -f "$config_fragment" ]; then
        if [ -f "$MAIN_CONFIG" ]; then
            # Merge configurations using jq
            temp_config=$(mktemp)
            jq -s '.[0] * .[1]' "$MAIN_CONFIG" "$config_fragment" > "$temp_config"
            mv "$temp_config" "$MAIN_CONFIG"
            log "   ⚙️  Configuration merged"
        else
            # Use fragment as main config
            cp "$config_fragment" "$MAIN_CONFIG"
            log "   ⚙️  Configuration installed"
        fi
    fi
    
    # Handle ignore patterns if they exist
    if [ -f "$plugin_dir/ignore-patterns.txt" ]; then
        if [ -f "$IGNORE_FILE" ]; then
            # Append to existing ignore file
            cat "$plugin_dir/ignore-patterns.txt" >> "$IGNORE_FILE"
        else
            # Create ignore file
            cp "$plugin_dir/ignore-patterns.txt" "$IGNORE_FILE"
        fi
        log "   🚫 Ignore patterns added"
    fi
    
    # Update status
    echo "APPLIED" > "$status_file"
    echo "Applied: $(date -Iseconds)" >> "$status_file"
    
    log "   ✅ Plugin '$plugin_name' enabled successfully"
}

# Disable plugin (remove configuration)
disable_plugin() {
    local plugin_name="$1"
    local plugin_dir="$PLUGINS_DIR/$plugin_name"
    local status_file="$plugin_dir/STATUS"
    
    if [ ! -d "$plugin_dir" ]; then
        error "Plugin '$plugin_name' not found"
        return 1
    fi
    
    log "🔧 Disabling prettier plugin: $plugin_name"
    
    # Restore from backup if available
    backup_pattern="$BACKUP_DIR/prettierrc.bak-$plugin_name-*"
    latest_backup=$(ls -t $backup_pattern 2>/dev/null | head -n1 || echo "")
    
    if [ -n "$latest_backup" ]; then
        cp "$latest_backup" "$MAIN_CONFIG"
        log "   📦 Configuration restored from backup"
    else
        warn "   ⚠️  No backup found - manual config cleanup may be needed"
    fi
    
    # Update status
    echo "REFUSED" > "$status_file"
    echo "Disabled: $(date -Iseconds)" >> "$status_file"
    
    log "   ✅ Plugin '$plugin_name' disabled successfully"
}

# Remove plugin completely
remove_plugin() {
    local plugin_name="$1"
    local plugin_dir="$PLUGINS_DIR/$plugin_name"
    
    if [ ! -d "$plugin_dir" ]; then
        error "Plugin '$plugin_name' not found"
        return 1
    fi
    
    log "🗑️  Removing prettier plugin: $plugin_name"
    
    # Disable first if applied
    local current_status=$(check_status "$plugin_name" 2>/dev/null || echo "UNKNOWN")
    if [ "$current_status" = "APPLIED" ]; then
        disable_plugin "$plugin_name"
    fi
    
    # Remove plugin directory
    rm -rf "$plugin_dir"
    log "   ✅ Plugin '$plugin_name' removed completely"
}

# Show help
show_help() {
    echo "Prettier Plugin Manager"
    echo ""
    echo "Usage: $0 [COMMAND] [PLUGIN_NAME]"
    echo ""
    echo "Commands:"
    echo "  --list                     List all prettier plugins"
    echo "  --status PLUGIN_NAME       Check plugin status"
    echo "  --enable PLUGIN_NAME       Enable plugin (PROPOSED → APPLIED)"
    echo "  --disable PLUGIN_NAME      Disable plugin (APPLIED → REFUSED)"
    echo "  --remove PLUGIN_NAME       Remove plugin completely"
    echo "  --help                     Show this help"
    echo ""
    echo "Plugin States:"
    echo "  PROPOSED  💡 Plugin suggested, awaiting approval"
    echo "  APPLIED   ✅ Plugin active in configuration"
    echo "  REFUSED   ❌ Plugin rejected or disabled"
}

# Main command processing
case "${1:-}" in
    --list)
        list_plugins
        ;;
    --status)
        if [ -z "${2:-}" ]; then
            error "Plugin name required"
            exit 1
        fi
        status=$(check_status "$2")
        log "Plugin '$2' status: $status"
        ;;
    --enable)
        if [ -z "${2:-}" ]; then
            error "Plugin name required"
            exit 1
        fi
        enable_plugin "$2"
        ;;
    --disable)
        if [ -z "${2:-}" ]; then
            error "Plugin name required"
            exit 1
        fi
        disable_plugin "$2"
        ;;
    --remove)
        if [ -z "${2:-}" ]; then
            error "Plugin name required"
            exit 1
        fi
        remove_plugin "$2"
        ;;
    --help|*)
        show_help
        ;;
esac
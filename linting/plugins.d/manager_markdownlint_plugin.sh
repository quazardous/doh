#!/bin/bash
# Markdownlint Plugin Manager
# Manages markdownlint-specific plugins with config integration

set -euo pipefail

# Configuration
PLUGINS_DIR="$(dirname "$0")/markdownlint"
MAIN_CONFIG=".markdownlint.json"
RULES_DIR=".markdownlint/rules"
BACKUP_DIR="../backups"
PLUGIN_STATUS="../plugin-status.json"

# Ensure directories exist
mkdir -p "$PLUGINS_DIR" "$RULES_DIR" "$BACKUP_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[MARKDOWNLINT]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[MARKDOWNLINT]${NC} $1"
}

error() {
    echo -e "${RED}[MARKDOWNLINT]${NC} $1" >&2
}

# List all markdownlint plugins
list_plugins() {
    log "📋 Markdownlint Plugins:"
    
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
    
    log "🔧 Enabling markdownlint plugin: $plugin_name"
    
    # Create backup if main config exists
    if [ -f "$MAIN_CONFIG" ]; then
        backup_file="$BACKUP_DIR/markdownlint.json.bak-$plugin_name-$(date +%Y%m%d-%H%M%S)"
        cp "$MAIN_CONFIG" "$backup_file"
        log "   📦 Backup created: $backup_file"
    fi
    
    # Copy custom rules if they exist
    if ls "$plugin_dir"/*.js >/dev/null 2>&1; then
        for rule_file in "$plugin_dir"/*.js; do
            rule_name=$(basename "$rule_file")
            cp "$rule_file" "$RULES_DIR/"
            log "   📋 Installed custom rule: $rule_name"
        done
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
    
    log "🔧 Disabling markdownlint plugin: $plugin_name"
    
    # Remove custom rules
    if ls "$plugin_dir"/*.js >/dev/null 2>&1; then
        for rule_file in "$plugin_dir"/*.js; do
            rule_name=$(basename "$rule_file")
            rm -f "$RULES_DIR/$rule_name"
            log "   🗑️  Removed custom rule: $rule_name"
        done
    fi
    
    # Restore from backup if available
    backup_pattern="$BACKUP_DIR/markdownlint.json.bak-$plugin_name-*"
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
    
    log "🗑️  Removing markdownlint plugin: $plugin_name"
    
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
    echo "Markdownlint Plugin Manager"
    echo ""
    echo "Usage: $0 [COMMAND] [PLUGIN_NAME]"
    echo ""
    echo "Commands:"
    echo "  --list                     List all markdownlint plugins"
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
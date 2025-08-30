#!/bin/bash
# Codespell Plugin Manager
# Manages codespell-specific plugins with dictionary and ignore integration

set -euo pipefail

# Configuration
PLUGINS_DIR="$(dirname "$0")/../../linting/plugins.d/codespell"
MAIN_CONFIG=".codespell.cfg"
DICT_FILE=".codespell-words.txt"
IGNORE_FILE=".codespell-ignore.txt"
BACKUP_DIR="../backups"

# Ensure directories exist
mkdir -p "$PLUGINS_DIR" "$BACKUP_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

log() {
    echo -e "${PURPLE}[CODESPELL]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[CODESPELL]${NC} $1"
}

error() {
    echo -e "${RED}[CODESPELL]${NC} $1" >&2
}

# List all codespell plugins
list_plugins() {
    log "📋 Codespell Plugins:"
    
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
    
    if [ ! -d "$plugin_dir" ]; then
        error "Plugin '$plugin_name' not found in $plugin_dir"
        return 1
    fi
    
    log "🔧 Enabling codespell plugin: $plugin_name"
    
    # Create backup of existing files
    for file in "$MAIN_CONFIG" "$DICT_FILE" "$IGNORE_FILE"; do
        if [ -f "$file" ]; then
            backup_file="$BACKUP_DIR/$(basename "$file").bak-$plugin_name-$(date +%Y%m%d-%H%M%S)"
            cp "$file" "$backup_file"
            log "   📦 Backup created: $backup_file"
        fi
    done
    
    # Handle custom dictionary
    if [ -f "$plugin_dir/words.txt" ]; then
        if [ -f "$DICT_FILE" ]; then
            # Append new words to existing dictionary
            cat "$plugin_dir/words.txt" >> "$DICT_FILE"
            # Remove duplicates while preserving order
            temp_file=$(mktemp)
            awk '!seen[$0]++' "$DICT_FILE" > "$temp_file"
            mv "$temp_file" "$DICT_FILE"
        else
            # Create new dictionary file
            cp "$plugin_dir/words.txt" "$DICT_FILE"
        fi
        log "   📚 Dictionary words added: $(wc -l < "$plugin_dir/words.txt") entries"
    fi
    
    # Handle ignore patterns
    if [ -f "$plugin_dir/ignore-list.txt" ]; then
        if [ -f "$IGNORE_FILE" ]; then
            # Append to existing ignore file
            cat "$plugin_dir/ignore-list.txt" >> "$IGNORE_FILE"
            # Remove duplicates
            temp_file=$(mktemp)
            sort "$IGNORE_FILE" | uniq > "$temp_file"
            mv "$temp_file" "$IGNORE_FILE"
        else
            # Create ignore file
            cp "$plugin_dir/ignore-list.txt" "$IGNORE_FILE"
        fi
        log "   🚫 Ignore patterns added: $(wc -l < "$plugin_dir/ignore-list.txt") entries"
    fi
    
    # Handle configuration
    if [ -f "$plugin_dir/config-fragment.cfg" ]; then
        if [ -f "$MAIN_CONFIG" ]; then
            # Append configuration
            echo "" >> "$MAIN_CONFIG"
            echo "# Plugin: $plugin_name" >> "$MAIN_CONFIG"
            cat "$plugin_dir/config-fragment.cfg" >> "$MAIN_CONFIG"
        else
            # Create main config
            echo "# Codespell configuration" > "$MAIN_CONFIG"
            echo "# Plugin: $plugin_name" >> "$MAIN_CONFIG"
            cat "$plugin_dir/config-fragment.cfg" >> "$MAIN_CONFIG"
        fi
        log "   ⚙️  Configuration merged"
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
    
    log "🔧 Disabling codespell plugin: $plugin_name"
    
    # Restore from backups if available
    for file_base in "$(basename "$MAIN_CONFIG")" "$(basename "$DICT_FILE")" "$(basename "$IGNORE_FILE")"; do
        backup_pattern="$BACKUP_DIR/${file_base}.bak-$plugin_name-*"
        latest_backup=$(ls -t $backup_pattern 2>/dev/null | head -n1 || echo "")
        
        if [ -n "$latest_backup" ]; then
            target_file="${latest_backup%.bak-*}"
            target_file="${target_file##*/}"
            cp "$latest_backup" "$target_file"
            log "   📦 Restored $target_file from backup"
        fi
    done
    
    # If no backups, warn about manual cleanup
    if [ -z "$(ls "$BACKUP_DIR"/*bak-$plugin_name-* 2>/dev/null || echo '')" ]; then
        warn "   ⚠️  No backups found - manual config cleanup may be needed"
        warn "       Check $DICT_FILE and $IGNORE_FILE for plugin entries"
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
    
    log "🗑️  Removing codespell plugin: $plugin_name"
    
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
    echo "Codespell Plugin Manager"
    echo ""
    echo "Usage: $0 [COMMAND] [PLUGIN_NAME]"
    echo ""
    echo "Commands:"
    echo "  --list                     List all codespell plugins"
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
    echo ""
    echo "Plugin Components:"
    echo "  words.txt           Custom dictionary entries"
    echo "  ignore-list.txt     Words/patterns to ignore"
    echo "  config-fragment.cfg Configuration options"
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
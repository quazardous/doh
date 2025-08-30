#!/bin/bash

# T107/T108: /dd:lint command wrapper with plugin support
# Handles --suggest-plugins and --list-plugins flags, delegates others to unified backend

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UNIFIED_SCRIPT="$SCRIPT_DIR/lint-files.sh"
PLUGIN_SCRIPT="$SCRIPT_DIR/plugin-proposals.sh"

# Check for plugin-related flags
case "${1:-}" in
    "--suggest-plugins")
        echo "🔍 /dd:lint --suggest-plugins"
        echo "=============================="
        exec "$PLUGIN_SCRIPT" suggest
        ;;
    "--list-plugins")
        echo "📋 /dd:lint --list-plugins"  
        echo "=========================="
        exec "$PLUGIN_SCRIPT" list
        ;;
    *)
        # Delegate all other flags to unified backend
        exec "$UNIFIED_SCRIPT" "$@"
        ;;
esac
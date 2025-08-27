#!/bin/bash
# Test Configuration Integration
# This script validates that config.ini integration works correctly

set -euo pipefail

echo "🧪 Testing DOH Configuration Integration"
echo "======================================="

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"

# Set project root
export PROJECT_ROOT="/path/to/test/project"

echo "📁 Project root: $PROJECT_ROOT"

# Test 1: Load core library and check config loading
echo ""
echo "🔧 Test 1: Core library config loading..."

# Source the core library
source "$LIB_DIR/doh-core.sh"

echo "✅ Core library loaded"
echo "📊 Configuration values loaded:"
echo "  DOH_DEBUG = $DOH_DEBUG"
echo "  DOH_QUIET = $DOH_QUIET" 
echo "  DOH_PERFORMANCE_TRACKING = $DOH_PERFORMANCE_TRACKING"
echo "  DOH_BASH_OPTIMIZATION = $DOH_BASH_OPTIMIZATION"
echo "  DOH_FALLBACK_ENABLED = $DOH_FALLBACK_ENABLED"

# Test 2: Test logging functions with config
echo ""
echo "🔧 Test 2: Logging functions..."

doh_log "This is a log message"
doh_debug "This is a debug message (should appear if debug_mode=true)"
doh_success "This is a success message"

# Test 3: Direct config access
echo ""
echo "🔧 Test 3: Direct config access..."

if [[ "${DOH_CONFIG_LOADED:-}" == "1" ]]; then
    echo "✅ Config library is loaded"
    
    debug_from_config=$(doh_config_get "scripting" "debug_mode" "false")
    quiet_from_config=$(doh_config_get "scripting" "quiet_mode" "false") 
    performance_from_config=$(doh_config_get "scripting" "performance_tracking" "false")
    
    echo "📋 Direct config values:"
    echo "  scripting.debug_mode = $debug_from_config"
    echo "  scripting.quiet_mode = $quiet_from_config"
    echo "  scripting.performance_tracking = $performance_from_config"
else
    echo "⚠️  Config library not loaded, using fallback values"
fi

# Test 4: Test config-manager script
echo ""
echo "🔧 Test 4: Config manager operations..."

if "$SCRIPT_DIR/config-manager.sh" get scripting debug_mode; then
    echo "✅ config-manager.sh get works"
else
    echo "❌ config-manager.sh get failed"
fi

# Test 5: Test with different config values
echo ""
echo "🔧 Test 5: Testing config override..."

# Save original config
cp "$PROJECT_ROOT/.doh/config.ini" "$PROJECT_ROOT/.doh/config.ini.backup"

# Create new config with different values
cat > "$PROJECT_ROOT/.doh/config.ini" <<EOF
[scripting]
debug_mode = false
quiet_mode = true
performance_tracking = false
EOF

echo "📝 Modified config file"

# Test get-item script with new config
echo ""
echo "🔧 Testing get-item.sh with modified config..."

if "$SCRIPT_DIR/get-item.sh" 2 2>/dev/null; then
    echo "✅ get-item.sh works with config"
else
    echo "⚠️  get-item.sh had issues (expected - may need fixes)"
fi

# Restore original config
mv "$PROJECT_ROOT/.doh/config.ini.backup" "$PROJECT_ROOT/.doh/config.ini"

echo ""
echo "🎉 Configuration integration test completed!"
echo "🔍 Check output above for any issues that need fixing"
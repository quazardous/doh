#!/bin/bash
# Test script for T018 path resolution system

set -e

echo "🧪 Testing T018 Path Resolution System"
echo "======================================"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOH_LIB="$SCRIPT_DIR/lib/doh.sh"

# Check if lib exists
if [[ ! -f "$DOH_LIB" ]]; then
    echo "❌ DOH library not found at: $DOH_LIB"
    exit 1
fi

echo "📚 Loading DOH library..."
source "$DOH_LIB"

# Test 1: Basic path resolution
echo ""
echo "🔍 Test 1: Basic path resolution"
PROJECT_ROOT=$(doh_find_project_root)
echo "   Resolved project root: $PROJECT_ROOT"

# Test 2: Project validation
echo ""
echo "🔍 Test 2: Project validation"
if doh_validate_project_path "$PROJECT_ROOT" false; then
    echo "   ✅ Project validation passed"
else
    echo "   ❌ Project validation failed"
    exit 1
fi

# Test 3: UUID functions
echo ""
echo "🔍 Test 3: UUID functions"
if UUID=$(doh_get_project_uuid "$PROJECT_ROOT" 2>/dev/null); then
    echo "   ✅ UUID found: $UUID"
else
    echo "   ⚠️  No UUID found (legacy project or not initialized)"
fi

# Test 4: Config parsing APIs
echo ""
echo "🔍 Test 4: Configuration parsing"
PROJECT_NAME=$(doh_config_get "project" "name" "unknown")
echo "   Project name: $PROJECT_NAME"

DEBUG_MODE=$(doh_config_bool "scripting" "debug_mode" "false")
echo "   Debug mode: $DEBUG_MODE"

# Test 5: List parsing
echo ""
echo "🔍 Test 5: List parsing (discovered_paths)"
echo "   Discovered paths:"
while IFS= read -r path; do
    echo "   - $path"
done < <(doh_config_list "project" "discovered_paths")

# Test 6: Debug mode path resolution
echo ""
echo "🔍 Test 6: Debug mode path resolution"
echo "   Running with DOH_PATH_DEBUG=1:"
DOH_PATH_DEBUG=1 doh_find_project_root 2>&1 | sed 's/^/   /'

echo ""
echo "🎉 All tests completed successfully!"
echo "✅ T018 Path Resolution System is working"
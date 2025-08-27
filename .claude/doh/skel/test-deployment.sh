#!/bin/bash
# DOH Skeleton Test Deployment Script
# Tests that skeleton structure is properly set up

set -e

SKEL_DIR="./skel"
TEST_DIR="/tmp/doh-skeleton-test-$$"

echo "🧪 Testing DOH Skeleton Deployment"
echo "=================================="

# Create test directory
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

echo "📁 Test directory: $TEST_DIR"

# Copy skeleton structure
if [[ -d "$SKEL_DIR" ]]; then
    echo "❌ Error: This test should be run from project root where $SKEL_DIR exists"
    exit 1
fi

# We need to reference the skeleton from the real project
REAL_SKEL_DIR="./skel"

if [[ ! -d "$REAL_SKEL_DIR" ]]; then
    echo "❌ Error: Skeleton directory not found at $REAL_SKEL_DIR"
    exit 1
fi

echo "📋 Copying skeleton structure..."
cp -r "$REAL_SKEL_DIR" ".doh"

echo "🔍 Validating skeleton structure..."

# Test 1: Check required files exist
required_files=(
    ".doh/project-index.json"
    ".doh/.gitignore" 
    ".doh/README.md"
    ".doh/epics/quick/epic0.md"
    ".doh/memory/.keep"
    ".doh/memory/project/.keep"
    ".doh/memory/epics/.keep"
    ".doh/memory/agent-sessions/.keep"
)

for file in "${required_files[@]}"; do
    if [[ -f "$file" ]]; then
        echo "✅ $file"
    else
        echo "❌ Missing: $file"
        exit 1
    fi
done

# Test 2: Validate JSON structure
echo "📋 Validating project-index.json..."
if jq empty .doh/project-index.json 2>/dev/null; then
    echo "✅ Valid JSON structure"
else
    echo "❌ Invalid JSON in project-index.json"
    exit 1
fi

# Test 3: Check Epic #0 is properly configured
if jq -e '.items.epics."0"' .doh/project-index.json >/dev/null; then
    echo "✅ Epic #0 configured in index"
else
    echo "❌ Epic #0 missing from index"
    exit 1
fi

# Test 4: Check memory directories are created
memory_dirs=(
    ".doh/memory/project"
    ".doh/memory/epics" 
    ".doh/memory/agent-sessions"
)

for dir in "${memory_dirs[@]}"; do
    if [[ -d "$dir" ]]; then
        echo "✅ $dir directory exists"
    else
        echo "❌ Missing directory: $dir"
        exit 1
    fi
done

# Test 5: Check gitignore patterns
if grep -q "memory/active-session.json" .doh/.gitignore; then
    echo "✅ .gitignore contains memory patterns"
else
    echo "❌ .gitignore missing memory patterns"
    exit 1
fi

echo ""
echo "🎉 Skeleton deployment test PASSED!"
echo "✅ All required files and directories created"
echo "✅ JSON structure valid"
echo "✅ Epic #0 properly configured"
echo "✅ Memory system ready"
echo "✅ Gitignore patterns set"

# Cleanup
cd /
rm -rf "$TEST_DIR"

echo "🧹 Test cleanup completed"
echo ""
echo "✅ DOH Skeleton is ready for production use!"
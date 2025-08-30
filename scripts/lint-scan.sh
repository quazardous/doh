#!/bin/bash

# T109: Lint Error Cache - Scan Script (Updated Structure)
# Populates .cache/linting/error-files.txt with files that have linting errors

set -e

PROJECT_ROOT=$(pwd)
CACHE_DIR="$PROJECT_ROOT/.cache/linting"
ERROR_FILE="$CACHE_DIR/error-files.txt"
LINTER="$PROJECT_ROOT/dev-tools/scripts/lint-files.sh"

# Ensure cache directory exists
mkdir -p "$CACHE_DIR"

# Clear existing error file
> "$ERROR_FILE"

echo "🔍 Scanning for files with linting errors..."

# Scan strategy based on arguments
case "${1:-}" in
    "--modified")
        echo "📋 Scanning git-modified files..."
        FILES=$(git diff --name-only --diff-filter=ACMRT "*.md" 2>/dev/null || true)
        ;;
    "--staged") 
        echo "📋 Scanning git-staged files..."
        FILES=$(git diff --cached --name-only --diff-filter=ACMRT "*.md" 2>/dev/null || true)
        ;;
    "--all")
        echo "📋 Scanning all markdown files..."
        FILES=$(find . -name "*.md" -type f | grep -v ".git" | sed 's|^\./||')
        ;;
    *)
        echo "📋 Scanning modified files (default)..."
        FILES=$(git diff --name-only --diff-filter=ACMRT "*.md" 2>/dev/null || true)
        ;;
esac

if [[ -z "$FILES" ]]; then
    echo "ℹ️  No files to scan"
    exit 0
fi

echo "📊 Found $(echo "$FILES" | wc -w) files to check..."

# Check each file and collect those with errors
while IFS= read -r file; do
    if [[ -n "$file" && -f "$file" ]]; then
        echo -n "  Checking: $file ... "
        
        # Run linter check and capture exit code
        if "$LINTER" --check "$file" >/dev/null 2>&1; then
            echo "✅"
        else
            echo "❌"
            echo "$file" >> "$ERROR_FILE"
        fi
    fi
done <<< "$FILES"

# Report results
ERROR_COUNT=$(wc -l < "$ERROR_FILE" 2>/dev/null || echo "0")

echo
echo "📋 Scan Results:"
echo "├── Files checked: $(echo "$FILES" | wc -w)"
echo "├── Files with errors: $ERROR_COUNT"
echo "└── Cache file: $ERROR_FILE"

if [[ "$ERROR_COUNT" -gt 0 ]]; then
    echo
    echo "🎯 Next steps:"
    echo "├── Process all: cat $ERROR_FILE | xargs $LINTER --fix"
    echo "├── Process batch: head -10 $ERROR_FILE | xargs $LINTER --fix" 
    echo "└── Check progress: wc -l < $ERROR_FILE"
else
    echo
    echo "🎉 All files are clean!"
fi
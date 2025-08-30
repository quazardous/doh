#!/bin/bash

# T109: Lint Error Cache - Progress Script (Updated Structure)
# Shows progress and status of linting error cache

set -e

PROJECT_ROOT=$(pwd)
CACHE_DIR="$PROJECT_ROOT/.cache/linting"
ERROR_FILE="$CACHE_DIR/error-files.txt"

# Check if cache exists
if [[ ! -f "$ERROR_FILE" ]]; then
    echo "❌ No lint cache found"
    echo "💡 Run: ./scripts/linting/lint-scan.sh to create cache"
    exit 1
fi

# Get counts
ERROR_COUNT=$(wc -l < "$ERROR_FILE" 2>/dev/null || echo "0")
CACHE_AGE=$(find "$ERROR_FILE" -mmin +60 2>/dev/null && echo "old" || echo "fresh")

echo "📊 Lint Error Cache Status"
echo "├── Cache file: $ERROR_FILE"
echo "├── Files with errors: $ERROR_COUNT"
echo "└── Cache age: $CACHE_AGE"

if [[ "$ERROR_COUNT" -eq 0 ]]; then
    echo
    echo "🎉 No files with errors!"
    echo "✨ All files are clean"
    exit 0
fi

echo
echo "📋 Files with errors:"

# Show first few files as preview
head -5 "$ERROR_FILE" | while IFS= read -r file; do
    echo "  ❌ $file"
done

if [[ "$ERROR_COUNT" -gt 5 ]]; then
    echo "  ... and $((ERROR_COUNT - 5)) more"
fi

echo
echo "🎯 Suggested actions:"
echo "├── Process all: cat $ERROR_FILE | xargs ./scripts/linting/lint-files.sh --fix"
echo "├── Process batch: head -10 $ERROR_FILE | xargs ./scripts/linting/lint-files.sh --fix"
echo "├── Process specific: grep 'todo/' $ERROR_FILE | xargs ./scripts/linting/lint-files.sh --fix"
echo "└── Update cache: ./scripts/linting/lint-update-cache.sh"

# Show distribution by directory if multiple directories
echo
echo "📁 Error distribution by directory:"
cut -d'/' -f1 "$ERROR_FILE" | sort | uniq -c | sort -nr | head -5 | while read -r count dir; do
    echo "  $dir/: $count files"
done
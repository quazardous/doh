#!/bin/bash

# T109: Lint Error Cache - Update Script (Updated Structure)
# Updates cache by removing files that are now clean

set -e

PROJECT_ROOT=$(pwd)
CACHE_DIR="$PROJECT_ROOT/.cache/linting"
ERROR_FILE="$CACHE_DIR/error-files.txt"
TEMP_FILE="$ERROR_FILE.tmp"
LINTER="$PROJECT_ROOT/scripts/linting/lint-files.sh"

# Check if cache exists
if [[ ! -f "$ERROR_FILE" ]]; then
    echo "❌ No lint cache found"
    echo "💡 Run: ./scripts/linting/lint-scan.sh to create cache"
    exit 1
fi

INITIAL_COUNT=$(wc -l < "$ERROR_FILE")

if [[ "$INITIAL_COUNT" -eq 0 ]]; then
    echo "🎉 Cache is already empty - all files clean!"
    exit 0
fi

echo "🔄 Updating lint error cache..."
echo "📊 Initial files with errors: $INITIAL_COUNT"

# Create temp file
> "$TEMP_FILE"

CLEANED_COUNT=0
REMAINING_COUNT=0

echo "🔍 Checking each file in cache..."

# Check each file in the cache
while IFS= read -r file; do
    if [[ -n "$file" && -f "$file" ]]; then
        echo -n "  Checking: $file ... "
        
        # Test if file is now clean
        if "$LINTER" --check "$file" >/dev/null 2>&1; then
            echo "✅ (cleaned)"
            ((CLEANED_COUNT++))
        else
            echo "❌ (still has errors)"
            echo "$file" >> "$TEMP_FILE"
            ((REMAINING_COUNT++))
        fi
    fi
done < "$ERROR_FILE"

# Replace original with updated cache
mv "$TEMP_FILE" "$ERROR_FILE"

echo
echo "📋 Update Results:"
echo "├── Files cleaned: $CLEANED_COUNT"
echo "├── Files still with errors: $REMAINING_COUNT"
echo "└── Progress: $((INITIAL_COUNT - REMAINING_COUNT))/$INITIAL_COUNT files fixed"

if [[ "$REMAINING_COUNT" -eq 0 ]]; then
    echo
    echo "🎉 All files are now clean!"
    echo "✨ Cache is empty - great job!"
else
    echo
    echo "🎯 Next steps for remaining $REMAINING_COUNT files:"
    echo "├── Process all: cat $ERROR_FILE | xargs $LINTER --fix"
    echo "├── Process batch: head -5 $ERROR_FILE | xargs $LINTER --fix"
    echo "└── Check progress: ./scripts/linting/lint-progress.sh"
fi
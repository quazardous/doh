#!/bin/bash
#
# lint-files.sh - Comprehensive auto-correcting linting system
#
# Usage:
#   lint-files.sh [--fix|--check] [target]
#
# Options:
#   --fix    Auto-fix issues (default)
#   --check  Check only, no fixes
#
# Targets:
#   file.md              Single file
#   path/to/dir/         Directory (all .md files)
#   --staged             All staged files (git)
#   --modified           All modified/new files (git)
#   (no target)          All .md files in project
#
# Examples:
#   lint-files.sh README.md                  # Fix single file
#   lint-files.sh --check todo/              # Check all files in todo/
#   lint-files.sh --staged                   # Fix all staged files
#   lint-files.sh --check --modified         # Check modified files only

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Load shared linting library
source "$SCRIPT_DIR/../lib/lint-core.sh"

# Load cache library for performance optimization
source "$SCRIPT_DIR/../lib/cache-lib.sh"

# Default options
MODE="fix"
TARGET=""
FILES=()
SHOW_EXCEPTIONS=false
VALIDATE_EXCEPTIONS=false
SHOW_SKIPPED=false
CACHE_ENABLED=true
CACHE_STATS=false

# Configure cache for linting
export CACHE_DIR="./.cache/linting"
export CONFIG_FILES=".markdownlint.json .prettierrc .prettierrc.json package.json pyproject.toml .codespell.conf scripts/linting/lint-files.sh scripts/lib/lint-core.sh"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --fix)
            MODE="fix"
            shift
            ;;
        --check)
            MODE="check"
            shift
            ;;
        --staged)
            TARGET="staged"
            shift
            ;;
        --modified)
            TARGET="modified"
            shift
            ;;
        --show-exceptions)
            SHOW_EXCEPTIONS=true
            shift
            ;;
        --validate-exceptions)
            VALIDATE_EXCEPTIONS=true
            shift
            ;;
        --show-skipped)
            SHOW_SKIPPED=true
            SHOW_EXCEPTIONS=true
            shift
            ;;
        --cache)
            CACHE_ENABLED=true
            shift
            ;;
        --no-cache)
            CACHE_ENABLED=false
            shift
            ;;
        --cache-stats)
            CACHE_STATS=true
            shift
            ;;
        --help)
            echo "Usage: lint-files.sh [OPTIONS] [target]"
            echo ""
            echo "Options:"
            echo "  --fix                Auto-fix issues (default)"
            echo "  --check              Check only, no fixes"
            echo "  --show-exceptions    Show detected exception markers"
            echo "  --validate-exceptions Validate exception markers are properly closed"
            echo "  --show-skipped       Show what sections were skipped during linting"
            echo "  --cache              Enable caching for performance (default)"
            echo "  --no-cache           Disable caching (force re-processing)"
            echo "  --cache-stats        Show cache statistics after processing"
            echo ""
            echo "Targets:"
            echo "  file.md              Single file"
            echo "  path/to/dir/         Directory (all .md files)"
            echo "  --staged             All staged files (git)"
            echo "  --modified           All modified/new files (git)"
            echo "  (no target)          All .md files in project"
            echo ""
            echo "Exception Patterns:"
            echo "  <!-- markdownlint-disable MD013 --> ... <!-- markdownlint-enable MD013 -->"
            echo "  <!-- prettier-ignore --> ... <!-- prettier-ignore-end -->"
            echo "  <!-- codespell-ignore --> ... <!-- codespell-ignore-end -->"
            echo "  <!-- lint-example:bad --> ... <!-- lint-example:end -->"
            echo "  <!-- teaching-mode --> ... <!-- teaching-mode:end -->"
            echo "  <!-- preserve-original --> ... <!-- preserve-original:end -->"
            exit 0
            ;;
        *)
            if [[ -z "$TARGET" ]]; then
                TARGET="$1"
            fi
            shift
            ;;
    esac
done

# Determine files to process using shared library functions
determine_files() {
    local files_array=()
    
    case "$TARGET" in
        "staged")
            echo "🔍 Finding staged files..."
            mapfile -t files_array < <(get_staged_markdown_files)
            if [[ ${#files_array[@]} -eq 0 ]]; then
                print_info "No staged markdown files found"
                exit 0
            fi
            ;;
        "modified")
            echo "🔍 Finding modified/new files..."
            mapfile -t files_array < <(get_modified_markdown_files)
            if [[ ${#files_array[@]} -eq 0 ]]; then
                print_info "No modified/new markdown files found"
                exit 0
            fi
            ;;
        "")
            echo "🔍 Finding all markdown files..."
            mapfile -t files_array < <(get_markdown_files_in_dir "$PROJECT_ROOT")
            if [[ ${#files_array[@]} -eq 0 ]]; then
                print_info "No markdown files found in project"
                exit 0
            fi
            ;;
        *)
            # Single file or directory
            if [[ -f "$TARGET" ]]; then
                if [[ "$TARGET" =~ \.(md|mdx)$ ]]; then
                    files_array=("$TARGET")
                else
                    print_error "$TARGET is not a markdown file"
                    exit 1
                fi
            elif [[ -d "$TARGET" ]]; then
                echo "🔍 Finding markdown files in $TARGET..."
                mapfile -t files_array < <(get_markdown_files_in_dir "$TARGET")
                if [[ ${#files_array[@]} -eq 0 ]]; then
                    print_info "No markdown files found in $TARGET"
                    exit 0
                fi
            else
                print_error "Target not found: $TARGET"
                exit 1
            fi
            ;;
    esac
    
    FILES=("${files_array[@]}")
    echo "📋 Processing ${#FILES[@]} file(s)"
}

# This function is now provided by lint-core.sh
# check_tools() { ... }

# Linting functions are now provided by lint-core.sh library

# Process a single file using shared library with cache support
process_file() {
    local file="$1"
    local file_status=0
    
    # Check cache first if enabled
    if [[ "$CACHE_ENABLED" == "true" ]]; then
        if cache_check_file "$file"; then
            return 0  # Cache hit, file already processed successfully
        fi
    fi
    
    echo "📝 Processing: $file"
    
    # Use the enhanced lint_file function from lint-core.sh
    if lint_file "$file" "$MODE" "$SHOW_EXCEPTIONS" "$VALIDATE_EXCEPTIONS"; then
        # Mark file as successfully processed in cache
        if [[ "$CACHE_ENABLED" == "true" && "$MODE" == "fix" ]]; then
            cache_mark_clean "$file"
        fi
        
        if [[ "$MODE" == "fix" ]]; then
            print_success "Fixed and clean"
        else
            print_success "Clean"
        fi
    else
        if [[ "$MODE" == "fix" ]]; then
            print_warning "Some issues remain after auto-fix"
        else
            print_error "Issues found"
        fi
        file_status=1
    fi
    
    return $file_status
}

# Main execution
main() {
    local exit_code=0
    
    echo "🔧 Markdown Linting Tool with Exception Handling"
    echo "Mode: $MODE"
    [[ "$SHOW_EXCEPTIONS" == "true" ]] && echo "Show exceptions: enabled"
    [[ "$VALIDATE_EXCEPTIONS" == "true" ]] && echo "Validate exceptions: enabled"
    if [[ "$CACHE_ENABLED" == "true" ]]; then
        echo "Cache: enabled"
        # Initialize cache
        cache_init
    else
        echo "Cache: disabled"
    fi
    echo ""
    
    # Check tools are installed using shared function
    if ! check_linting_tools; then
        exit 1
    fi
    
    # Determine files to process
    determine_files
    
    echo ""
    
    # Process each file
    for file in "${FILES[@]}"; do
        if ! process_file "$file"; then
            exit_code=1
        fi
        echo ""
    done
    
    # Summary
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if [[ $exit_code -eq 0 ]]; then
        if [[ "$MODE" == "fix" ]]; then
            echo "✅ All files processed and fixed successfully"
        else
            echo "✅ All files are clean"
        fi
    else
        if [[ "$MODE" == "fix" ]]; then
            echo "⚠️  Some files have remaining issues after auto-fix"
            echo "Run with --check to see all issues"
        else
            echo "❌ Issues found in some files"
            echo "Run with --fix to auto-correct fixable issues"
        fi
    fi
    
    # Show cache statistics if requested
    if [[ "$CACHE_STATS" == "true" && "$CACHE_ENABLED" == "true" ]]; then
        echo ""
        cache_stats
    fi
    
    exit $exit_code
}

# Run main
main
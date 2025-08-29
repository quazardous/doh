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

# Default mode is fix
MODE="fix"
TARGET=""
FILES=()

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
        *)
            if [[ -z "$TARGET" ]]; then
                TARGET="$1"
            fi
            shift
            ;;
    esac
done

# Determine files to process
determine_files() {
    local files_array=()
    
    case "$TARGET" in
        "staged")
            # Get staged files
            echo "🔍 Finding staged files..."
            mapfile -t files_array < <(git diff --cached --name-only --diff-filter=ACMR | grep -E '\.(md|mdx)$' || true)
            if [[ ${#files_array[@]} -eq 0 ]]; then
                echo "ℹ️  No staged markdown files found"
                exit 0
            fi
            ;;
        "modified")
            # Get modified and new files
            echo "🔍 Finding modified/new files..."
            mapfile -t files_array < <(git diff --name-only --diff-filter=ACMR | grep -E '\.(md|mdx)$' || true)
            mapfile -t new_files < <(git ls-files --others --exclude-standard | grep -E '\.(md|mdx)$' || true)
            files_array+=("${new_files[@]}")
            if [[ ${#files_array[@]} -eq 0 ]]; then
                echo "ℹ️  No modified/new markdown files found"
                exit 0
            fi
            ;;
        "")
            # All markdown files in project
            echo "🔍 Finding all markdown files..."
            mapfile -t files_array < <(find "$PROJECT_ROOT" -type f \( -name "*.md" -o -name "*.mdx" \) \
                -not -path "*/node_modules/*" \
                -not -path "*/.git/*" \
                -not -path "*/dist/*" \
                -not -path "*/build/*" \
                -not -path "*/.next/*" || true)
            if [[ ${#files_array[@]} -eq 0 ]]; then
                echo "ℹ️  No markdown files found in project"
                exit 0
            fi
            ;;
        *)
            # Single file or directory
            if [[ -f "$TARGET" ]]; then
                # Single file
                if [[ "$TARGET" =~ \.(md|mdx)$ ]]; then
                    files_array=("$TARGET")
                else
                    echo "⚠️  Warning: $TARGET is not a markdown file"
                    exit 1
                fi
            elif [[ -d "$TARGET" ]]; then
                # Directory
                echo "🔍 Finding markdown files in $TARGET..."
                mapfile -t files_array < <(find "$TARGET" -type f \( -name "*.md" -o -name "*.mdx" \) \
                    -not -path "*/node_modules/*" \
                    -not -path "*/.git/*" || true)
                if [[ ${#files_array[@]} -eq 0 ]]; then
                    echo "ℹ️  No markdown files found in $TARGET"
                    exit 0
                fi
            else
                echo "❌ Error: Target not found: $TARGET"
                exit 1
            fi
            ;;
    esac
    
    FILES=("${files_array[@]}")
    echo "📋 Processing ${#FILES[@]} file(s)"
}

# Check if tools are installed
check_tools() {
    local missing_tools=()
    
    if ! command -v prettier &> /dev/null; then
        missing_tools+=("prettier")
    fi
    
    if ! command -v markdownlint &> /dev/null; then
        missing_tools+=("markdownlint")
    fi
    
    if ! command -v codespell &> /dev/null; then
        missing_tools+=("codespell")
    fi
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        echo "❌ Missing required tools: ${missing_tools[*]}"
        echo ""
        echo "Install with:"
        echo "  npm install -g prettier markdownlint-cli"
        echo "  pip install codespell"
        exit 1
    fi
}

# Run prettier
run_prettier() {
    local file="$1"
    
    if [[ "$MODE" == "fix" ]]; then
        prettier --write "$file" &> /dev/null || {
            echo "  ⚠️  Prettier failed on $file"
            return 1
        }
    else
        if ! prettier --check "$file" &> /dev/null; then
            echo "  ⚠️  Prettier: formatting issues in $file"
            return 1
        fi
    fi
    return 0
}

# Run markdownlint
run_markdownlint() {
    local file="$1"
    local config_file=""
    
    # Look for markdownlint config
    if [[ -f "$PROJECT_ROOT/.markdownlint.json" ]]; then
        config_file="--config $PROJECT_ROOT/.markdownlint.json"
    elif [[ -f "$PROJECT_ROOT/.markdownlintrc" ]]; then
        config_file="--config $PROJECT_ROOT/.markdownlintrc"
    fi
    
    if [[ "$MODE" == "fix" ]]; then
        markdownlint --fix $config_file "$file" 2> /dev/null || {
            # Try to show remaining issues
            local issues
            issues=$(markdownlint $config_file "$file" 2>&1 || true)
            if [[ -n "$issues" ]]; then
                echo "  ⚠️  Markdownlint: unfixable issues in $file"
                echo "$issues" | head -5 | sed 's/^/      /'
            fi
            return 1
        }
    else
        if ! markdownlint $config_file "$file" &> /dev/null; then
            local issues
            issues=$(markdownlint $config_file "$file" 2>&1 || true)
            echo "  ⚠️  Markdownlint: issues in $file"
            echo "$issues" | head -5 | sed 's/^/      /'
            return 1
        fi
    fi
    return 0
}

# Run codespell
run_codespell() {
    local file="$1"
    local config_args=""
    
    # Look for codespell config
    if [[ -f "$PROJECT_ROOT/.codespellrc" ]]; then
        config_args="--config $PROJECT_ROOT/.codespellrc"
    else
        # Default ignore list for common false positives
        config_args="-L teh,nd,iam,doesnt,thats"
    fi
    
    if [[ "$MODE" == "fix" ]]; then
        codespell -w $config_args "$file" &> /dev/null || {
            # Show remaining issues
            local issues
            issues=$(codespell $config_args "$file" 2>&1 || true)
            if [[ -n "$issues" ]]; then
                echo "  ⚠️  Codespell: spelling issues in $file"
                echo "$issues" | head -3 | sed 's/^/      /'
            fi
            return 1
        }
    else
        if ! codespell $config_args "$file" &> /dev/null; then
            local issues
            issues=$(codespell $config_args "$file" 2>&1 || true)
            echo "  ⚠️  Codespell: spelling issues in $file"
            echo "$issues" | head -3 | sed 's/^/      /'
            return 1
        fi
    fi
    return 0
}

# Process a single file
process_file() {
    local file="$1"
    local file_status=0
    
    echo "📝 Processing: $file"
    
    # Run tools in order: prettier -> markdownlint -> codespell
    # This order ensures best compatibility and fix coverage
    
    # 1. Prettier (formatting foundation)
    if ! run_prettier "$file"; then
        file_status=1
    fi
    
    # 2. Markdownlint (Markdown-specific rules)
    if ! run_markdownlint "$file"; then
        file_status=1
    fi
    
    # 3. Codespell (spelling corrections)
    if ! run_codespell "$file"; then
        file_status=1
    fi
    
    if [[ $file_status -eq 0 ]]; then
        if [[ "$MODE" == "fix" ]]; then
            echo "  ✅ Fixed and clean"
        else
            echo "  ✅ Clean"
        fi
    else
        if [[ "$MODE" == "fix" ]]; then
            echo "  ⚠️  Some issues remain after auto-fix"
        else
            echo "  ❌ Issues found"
        fi
    fi
    
    return $file_status
}

# Main execution
main() {
    local exit_code=0
    
    echo "🔧 Markdown Linting Tool"
    echo "Mode: $MODE"
    echo ""
    
    # Check tools are installed
    check_tools
    
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
    
    exit $exit_code
}

# Run main
main
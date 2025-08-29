#!/bin/bash
#
# lint-core.sh - Shared linting functions library
#
# This library provides common functions used by both
# the main linting script and git hooks
#
# Usage:
#   source scripts/lib/lint-core.sh

# Configuration
SCRIPT_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_LIB_DIR/../.." && pwd)"

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Print colored output
print_error() {
    echo -e "${RED}❌ $1${NC}" >&2
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if required tools are installed
check_linting_tools() {
    local missing_tools=()
    
    if ! command_exists prettier; then
        missing_tools+=("prettier")
    fi
    
    if ! command_exists markdownlint; then
        missing_tools+=("markdownlint")
    fi
    
    if ! command_exists codespell; then
        missing_tools+=("codespell")
    fi
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        echo ""
        echo "Install with:"
        echo "  npm install -g prettier markdownlint-cli"
        echo "  pip install codespell"
        return 1
    fi
    
    return 0
}

# Get staged markdown files
get_staged_markdown_files() {
    git diff --cached --name-only --diff-filter=ACMR | grep -E '\.(md|mdx)$' || true
}

# Get modified markdown files (not staged)
get_modified_markdown_files() {
    git diff --name-only --diff-filter=ACMR | grep -E '\.(md|mdx)$' || true
    git ls-files --others --exclude-standard | grep -E '\.(md|mdx)$' || true
}

# Get all markdown files in a directory
get_markdown_files_in_dir() {
    local dir="$1"
    find "$dir" -type f \( -name "*.md" -o -name "*.mdx" \) \
        -not -path "*/node_modules/*" \
        -not -path "*/.git/*" \
        -not -path "*/dist/*" \
        -not -path "*/build/*" \
        -not -path "*/.next/*" 2>/dev/null || true
}

# Check if file has exception markers
has_exception_marker() {
    local file="$1"
    local marker="$2"
    
    grep -q "$marker" "$file" 2>/dev/null
}

# Extract sections with exceptions
extract_exception_sections() {
    local file="$1"
    local temp_file="${file}.lint-temp"
    
    # Check for inline exceptions
    if has_exception_marker "$file" "markdownlint-disable"; then
        echo "  📝 Found markdownlint exceptions"
    fi
    
    if has_exception_marker "$file" "prettier-ignore"; then
        echo "  📝 Found prettier exceptions"
    fi
    
    if has_exception_marker "$file" "codespell-ignore"; then
        echo "  📝 Found codespell exceptions"
    fi
    
    if has_exception_marker "$file" "lint-example:bad"; then
        echo "  📝 Found bad example sections (will skip)"
    fi
    
    if has_exception_marker "$file" "teaching-mode"; then
        echo "  📝 Found teaching mode sections (will skip)"
    fi
}

# Run prettier on a file
run_prettier_on_file() {
    local file="$1"
    local mode="$2"  # "fix" or "check"
    
    if [[ "$mode" == "fix" ]]; then
        prettier --write "$file" &> /dev/null || return 1
    else
        prettier --check "$file" &> /dev/null || return 1
    fi
    
    return 0
}

# Run markdownlint on a file
run_markdownlint_on_file() {
    local file="$1"
    local mode="$2"  # "fix" or "check"
    local config_args=""
    
    # Look for config file
    if [[ -f "$PROJECT_ROOT/.markdownlint.json" ]]; then
        config_args="--config $PROJECT_ROOT/.markdownlint.json"
    elif [[ -f "$PROJECT_ROOT/.markdownlintrc" ]]; then
        config_args="--config $PROJECT_ROOT/.markdownlintrc"
    fi
    
    if [[ "$mode" == "fix" ]]; then
        markdownlint --fix $config_args "$file" 2> /dev/null || {
            # Show remaining issues
            markdownlint $config_args "$file" 2>&1 | head -5 || true
            return 1
        }
    else
        markdownlint $config_args "$file" &> /dev/null || {
            markdownlint $config_args "$file" 2>&1 | head -5 || true
            return 1
        }
    fi
    
    return 0
}

# Run codespell on a file
run_codespell_on_file() {
    local file="$1"
    local mode="$2"  # "fix" or "check"
    local config_args=""
    
    # Look for config file
    if [[ -f "$PROJECT_ROOT/.codespellrc" ]]; then
        config_args="--config $PROJECT_ROOT/.codespellrc"
    else
        # Default ignore list
        config_args="-L teh,nd,iam,doesnt,thats"
    fi
    
    if [[ "$mode" == "fix" ]]; then
        codespell -w $config_args "$file" &> /dev/null || {
            codespell $config_args "$file" 2>&1 | head -3 || true
            return 1
        }
    else
        codespell $config_args "$file" &> /dev/null || {
            codespell $config_args "$file" 2>&1 | head -3 || true
            return 1
        }
    fi
    
    return 0
}

# Main linting function for a single file
lint_file() {
    local file="$1"
    local mode="${2:-fix}"  # Default to fix mode
    local show_exceptions="${3:-false}"
    local file_status=0
    
    # Check for exceptions if requested
    if [[ "$show_exceptions" == "true" ]]; then
        extract_exception_sections "$file"
    fi
    
    # Run linting pipeline
    # 1. Prettier (formatting foundation)
    if ! run_prettier_on_file "$file" "$mode"; then
        print_warning "Prettier: formatting issues in $file"
        file_status=1
    fi
    
    # 2. Markdownlint (Markdown-specific rules)
    if ! run_markdownlint_on_file "$file" "$mode"; then
        print_warning "Markdownlint: issues in $file"
        file_status=1
    fi
    
    # 3. Codespell (spelling corrections)
    if ! run_codespell_on_file "$file" "$mode"; then
        print_warning "Codespell: spelling issues in $file"
        file_status=1
    fi
    
    return $file_status
}

# Lint multiple files
lint_files() {
    local mode="${1:-fix}"
    shift
    local files=("$@")
    local overall_status=0
    
    for file in "${files[@]}"; do
        echo "📝 Processing: $file"
        if lint_file "$file" "$mode"; then
            if [[ "$mode" == "fix" ]]; then
                print_success "Fixed and clean"
            else
                print_success "Clean"
            fi
        else
            if [[ "$mode" == "fix" ]]; then
                print_warning "Some issues remain after auto-fix"
            else
                print_error "Issues found"
            fi
            overall_status=1
        fi
        echo ""
    done
    
    return $overall_status
}

# Export functions for use by other scripts
export -f command_exists
export -f print_error
export -f print_success
export -f print_warning
export -f print_info
export -f check_linting_tools
export -f get_staged_markdown_files
export -f get_modified_markdown_files
export -f get_markdown_files_in_dir
export -f has_exception_marker
export -f extract_exception_sections
export -f run_prettier_on_file
export -f run_markdownlint_on_file
export -f run_codespell_on_file
export -f lint_file
export -f lint_files
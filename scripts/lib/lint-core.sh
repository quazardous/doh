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
    
    if [[ -f "$file" ]]; then
        grep -q "$marker" "$file" 2>/dev/null
    else
        return 1
    fi
}

# Extract sections with exceptions and create filtered file
extract_exception_sections() {
    local file="$1"
    local temp_file="${file}.lint-temp"
    local show_info="${2:-false}"
    
    # Copy original file
    cp "$file" "$temp_file"
    
    # Check for and report inline exceptions
    local found_exceptions=false
    
    if has_exception_marker "$file" "markdownlint-disable"; then
        [[ "$show_info" == "true" ]] && echo "  📝 Found markdownlint exceptions"
        found_exceptions=true
    fi
    
    if has_exception_marker "$file" "prettier-ignore"; then
        [[ "$show_info" == "true" ]] && echo "  📝 Found prettier exceptions"
        found_exceptions=true
    fi
    
    if has_exception_marker "$file" "codespell-ignore"; then
        [[ "$show_info" == "true" ]] && echo "  📝 Found codespell exceptions"
        found_exceptions=true
    fi
    
    # Handle special teaching/example sections by removing them
    if has_exception_marker "$file" "lint-example:bad"; then
        [[ "$show_info" == "true" ]] && echo "  📝 Found bad example sections (will skip)"
        # Remove content between lint-example:bad and lint-example:end markers
        sed -i '/<!-- lint-example:bad -->/,/<!-- lint-example:end -->/d' "$temp_file"
        found_exceptions=true
    fi
    
    if has_exception_marker "$file" "teaching-mode"; then
        [[ "$show_info" == "true" ]] && echo "  📝 Found teaching mode sections (will skip)"
        # Remove content between teaching-mode and teaching-mode:end markers
        sed -i '/<!-- teaching-mode -->/,/<!-- teaching-mode:end -->/d' "$temp_file"
        found_exceptions=true
    fi
    
    if has_exception_marker "$file" "preserve-original"; then
        [[ "$show_info" == "true" ]] && echo "  📝 Found preserve-original sections (will skip)"
        # Remove content between preserve-original and preserve-original:end markers
        sed -i '/<!-- preserve-original -->/,/<!-- preserve-original:end -->/d' "$temp_file"
        found_exceptions=true
    fi
    
    # Return the temp file path and whether exceptions were found
    echo "$temp_file"
    return $([ "$found_exceptions" = true ] && echo 0 || echo 1)
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

# Validate exception markers are properly closed
validate_exception_markers() {
    local file="$1"
    local validation_errors=0
    
    # Check markdownlint disable/enable pairs
    local disable_count
    local enable_count
    disable_count=$(grep -c "markdownlint-disable" "$file" 2>/dev/null || echo 0)
    enable_count=$(grep -c "markdownlint-enable" "$file" 2>/dev/null || echo 0)
    
    if [[ $disable_count -gt $enable_count ]]; then
        print_warning "Unclosed markdownlint-disable markers in $file"
        validation_errors=1
    fi
    
    # Check teaching-mode pairs
    local teaching_start
    local teaching_end
    teaching_start=$(grep -c "<!-- teaching-mode -->" "$file" 2>/dev/null || echo 0)
    teaching_end=$(grep -c "<!-- teaching-mode:end -->" "$file" 2>/dev/null || echo 0)
    
    if [[ $teaching_start -ne $teaching_end ]]; then
        print_warning "Mismatched teaching-mode markers in $file ($teaching_start start, $teaching_end end)"
        validation_errors=1
    fi
    
    # Check lint-example pairs
    local example_bad
    local example_end
    example_bad=$(grep -c "<!-- lint-example:bad -->" "$file" 2>/dev/null || echo 0)
    example_end=$(grep -c "<!-- lint-example:end -->" "$file" 2>/dev/null || echo 0)
    
    if [[ $example_bad -gt 0 && $example_bad -ne $example_end ]]; then
        print_warning "Mismatched lint-example markers in $file ($example_bad bad, $example_end end)"
        validation_errors=1
    fi
    
    return $validation_errors
}

# Main linting function for a single file with intelligent exception handling
lint_file() {
    local file="$1"
    local mode="${2:-fix}"  # Default to fix mode
    local show_exceptions="${3:-false}"
    local validate_exceptions="${4:-false}"
    local file_status=0
    local target_file="$file"
    local temp_file=""
    local cleanup_temp=false
    
    # Validate exception markers if requested
    if [[ "$validate_exceptions" == "true" ]]; then
        if ! validate_exception_markers "$file"; then
            return 1
        fi
    fi
    
    # Handle exceptions by creating filtered file
    if has_exception_marker "$file" "lint-example:bad\|teaching-mode\|preserve-original"; then
        temp_file=$(extract_exception_sections "$file" "$show_exceptions")
        if [[ $? -eq 0 ]]; then
            target_file="$temp_file"
            cleanup_temp=true
            [[ "$show_exceptions" == "true" ]] && echo "  🔧 Using filtered version for linting"
        fi
    elif [[ "$show_exceptions" == "true" ]]; then
        extract_exception_sections "$file" "$show_exceptions" > /dev/null
    fi
    
    # Run linting pipeline on target file
    # 1. Prettier (formatting foundation) - respects prettier-ignore
    if ! run_prettier_on_file "$target_file" "$mode"; then
        print_warning "Prettier: formatting issues in $(basename "$file")"
        file_status=1
    fi
    
    # 2. Markdownlint (Markdown-specific rules) - respects markdownlint-disable
    if ! run_markdownlint_on_file "$target_file" "$mode"; then
        print_warning "Markdownlint: issues in $(basename "$file")"
        file_status=1
    fi
    
    # 3. Codespell (spelling corrections) - respects codespell-ignore
    if ! run_codespell_on_file "$target_file" "$mode"; then
        print_warning "Codespell: spelling issues in $(basename "$file")"
        file_status=1
    fi
    
    # Copy changes back to original file if we used a temp file and mode is fix
    if [[ "$cleanup_temp" == "true" && "$mode" == "fix" && $file_status -eq 0 ]]; then
        # Carefully merge changes back, preserving exception sections
        merge_linting_changes "$file" "$temp_file"
    fi
    
    # Cleanup temp file
    if [[ "$cleanup_temp" == "true" && -f "$temp_file" ]]; then
        rm -f "$temp_file"
    fi
    
    return $file_status
}

# Merge linting changes back to original file while preserving exceptions
merge_linting_changes() {
    local original_file="$1"
    local linted_file="$2"
    
    # For now, simple approach: don't merge back changes to preserve exceptions
    # In future versions, could implement more sophisticated merging
    [[ -f "$linted_file" ]] && echo "  ℹ️  Exception sections preserved, some changes not applied"
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
export -f validate_exception_markers
export -f merge_linting_changes
export -f run_prettier_on_file
export -f run_markdownlint_on_file
export -f run_codespell_on_file
export -f lint_file
export -f lint_files
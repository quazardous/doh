#!/bin/bash

# DOH File Headers Library
# Pure library for adding and managing version headers in files (no automatic execution)

# Source core library dependencies
source "$(dirname "${BASH_SOURCE[0]}")/frontmatter.sh"
source "$(dirname "${BASH_SOURCE[0]}")/version.sh"

# Guard against multiple sourcing
[[ -n "${DOH_LIB_FILE_HEADERS_LOADED:-}" ]] && return 0
DOH_LIB_FILE_HEADERS_LOADED=1

# Constants
readonly FILE_HEADERS_LIB_VERSION="1.0.0"

# @description Add version header to a file based on its type
# @arg $1 string Path to the file to add header to
# @arg $2 string Optional version to use (defaults to current project version)
# @stdout Success message
# @stderr Error messages if file not found or unsupported type
# @exitcode 0 If successful
# @exitcode 1 If file not found or error occurred
# @description Add version header to a file based on its type
# @public
# @arg $1 string Path to the file to add header to
# @arg $2 string Optional version to use (defaults to current project version)
# @stdout Success message
# @stderr Error messages if file not found or unsupported type
# @exitcode 0 If successful
# @exitcode 1 If file not found or error occurred
file_headers_add_version() {
    local file="$1"
    local version="${2:-}"
    
    if [[ -z "$file" ]]; then
        echo "Error: File path required" >&2
        return 1
    fi
    
    if [[ ! -f "$file" ]]; then
        echo "Error: File not found: $file" >&2
        return 1
    fi
    
    # Get current version if not provided
    if [[ -z "$version" ]]; then
        version=$(version_get_current) || {
            echo "Error: Could not determine current version" >&2
            return 1
        }
    fi
    
    local created_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local extension="${file##*.}"
    local filename=$(basename "$file")
    
    # For markdown files, we need special handling to respect existing style
    # For other file types, skip if header already exists
    if [[ "$extension" != "md" ]] && file_headers_file_has_version "$file"; then
        echo "File already has version header: $file" >&2
        return 0
    fi
    
    # Add header based on file type
    case "$extension" in
        sh)
            _file_headers_add_shell "$file" "$version" "$created_date"
            ;;
        md)
            _file_headers_add_markdown "$file" "$version" "$created_date"
            ;;
        py)
            _file_headers_add_python "$file" "$version" "$created_date"
            ;;
        js|ts)
            _file_headers_add_javascript "$file" "$version" "$created_date"
            ;;
        yml|yaml)
            _file_headers_add_yaml "$file" "$version" "$created_date"
            ;;
        *)
            echo "Warning: Unsupported file type: $extension" >&2
            return 0
            ;;
    esac
    
    echo "Added version header to: $file (v$version)"
}

# @description Check if file already has a version header
# @arg $1 string Path to the file to check
# @exitcode 0 If file has version header
# @exitcode 1 If file doesn't have version header
# @description Check if file already has a version header
# @public
# @arg $1 string Path to the file to check
# @exitcode 0 If file has version header
# @exitcode 1 If file doesn't have version header
file_headers_file_has_version() {
    local file="$1"
    
    # Check for various version header patterns:
    # - Bash/Python: # DOH Version:
    # - JavaScript/CSS: // DOH Version:
    # - Markdown frontmatter: file_version:
    # - Markdown HTML comments: <!-- DOH Version:
    if head -n 10 "$file" | grep -qE "(DOH Version:|file_version:|<!-- DOH Version:)" 2>/dev/null; then
        return 0
    fi
    
    return 1
}

# @description Check if markdown file already uses HTML comments for versions
# @arg $1 string Path to the markdown file to check
# @exitcode 0 If file uses HTML comment style
# @exitcode 1 If file doesn't use HTML comment style
# @description Check if markdown file already uses HTML comments for versions
# @private
# @arg $1 string Path to the markdown file to check
# @exitcode 0 If file uses HTML comment style
# @exitcode 1 If file doesn't use HTML comment style
_file_headers_markdown_uses_html_comments() {
    local file="$1"
    
    if head -n 10 "$file" | grep -q "<!-- DOH Version:" 2>/dev/null; then
        return 0
    fi
    
    return 1
}

# @description Add shell script header
# @arg $1 string Path to file
# @arg $2 string Version
# @arg $3 string Created date
# @description Add shell script header
# @private
# @arg $1 string Path to file
# @arg $2 string Version
# @arg $3 string Created date
_file_headers_add_shell() {
    local file="$1"
    local version="$2"
    local created="$3"
    
    local temp_file=$(mktemp)
    
    # Check if file has shebang
    if head -n 1 "$file" | grep -q "^#!"; then
        # Keep shebang, add header after
        head -n 1 "$file" > "$temp_file"
        echo "# DOH Version: $version" >> "$temp_file"
        echo "# Created: $created" >> "$temp_file"
        echo "" >> "$temp_file"
        tail -n +2 "$file" >> "$temp_file"
    else
        # Add header at top
        echo "# DOH Version: $version" > "$temp_file"
        echo "# Created: $created" >> "$temp_file"
        echo "" >> "$temp_file"
        cat "$file" >> "$temp_file"
    fi
    
    mv "$temp_file" "$file"
}

# @description Add markdown header (respects existing style: frontmatter or HTML comments)
# @arg $1 string Path to file
# @arg $2 string Version
# @arg $3 string Created date
# @description Add markdown header (respects existing style: frontmatter or HTML comments)
# @private
# @arg $1 string Path to file
# @arg $2 string Version
# @arg $3 string Created date
_file_headers_add_markdown() {
    local file="$1"
    local version="$2"
    local created="$3"
    local filename=$(basename "$file")
    
    # Decision logic:
    # 1. If file already has frontmatter → use frontmatter_update_many
    # 2. If file already has HTML comments → use HTML comments
    # 3. If file has neither → choose based on file type/location
    
    if frontmatter_has "$file"; then
        # File already has frontmatter - use frontmatter_update_many
        frontmatter_update_many "$file" \
            "file_version:$version" \
            "created:$created"
    elif _file_headers_markdown_uses_html_comments "$file"; then
        # File already uses HTML comments - update them
        _file_headers_add_markdown_html "$file" "$version" "$created"
    else
        local doh_dir
        doh_dir=$(doh_project_dir) || {
            echo "Error: Not in DOH project" >&2
            return 1
        }
        # File has no existing version headers - choose format based on file type
        if [[ "$file" == "$doh_dir/"* ]] && { [[ "$file" =~ \.(epic|task|prd)\.md$ ]] || [[ "$filename" =~ ^[0-9]+\.md$ ]] }; then
            # Structured DOH files - add frontmatter using frontmatter_update_many
            # frontmatter_update_many handles file without frontmatter via frontmatter_assert internally
            frontmatter_update_many "$file" \
                "file_version:$version" \
                "created:$created"
        else
            # General markdown files - add HTML comments
            _file_headers_add_markdown_html "$file" "$version" "$created"
        fi
    fi
}

# @description Add or update HTML comment headers in markdown files
# @private
# @arg $1 string Path to file
# @arg $2 string Version
# @arg $3 string Created date
_file_headers_add_markdown_html() {
    local file="$1"
    local version="$2"
    local created="$3"
    
    local temp_file=$(mktemp)
    local updated_version=false
    local updated_created=false
    local has_existing_headers=false
    
    # Check if file already has HTML headers
    if _file_headers_markdown_uses_html_comments "$file"; then
        has_existing_headers=true
    fi
    
    if [[ "$has_existing_headers" == true ]]; then
        # Update existing HTML comments
        while IFS= read -r line; do
            if [[ "$line" =~ ^\<!--[[:space:]]*DOH[[:space:]]+Version: ]]; then
                echo "<!-- DOH Version: $version -->" >> "$temp_file"
                updated_version=true
            elif [[ "$line" =~ ^\<!--[[:space:]]*Created: ]]; then
                # Preserve existing created date
                echo "$line" >> "$temp_file"
                updated_created=true
            else
                echo "$line" >> "$temp_file"
            fi
        done < "$file"
        
        # Add missing headers if not updated
        if [[ "$updated_version" == false ]]; then
            # Insert at beginning
            local final_temp=$(mktemp)
            echo "<!-- DOH Version: $version -->" > "$final_temp"
            cat "$temp_file" >> "$final_temp"
            mv "$final_temp" "$temp_file"
        fi
        if [[ "$updated_created" == false ]]; then
            # Insert at beginning (after version if present)
            local final_temp=$(mktemp)
            if [[ "$updated_version" == true ]]; then
                head -1 "$temp_file" > "$final_temp"
                echo "<!-- Created: $created -->" >> "$final_temp"
                tail -n +2 "$temp_file" >> "$final_temp"
            else
                echo "<!-- Created: $created -->" > "$final_temp"
                cat "$temp_file" >> "$final_temp"
            fi
            mv "$final_temp" "$temp_file"
        fi
    else
        # Add new HTML comments at the beginning
        echo "<!-- DOH Version: $version -->" > "$temp_file"
        echo "<!-- Created: $created -->" >> "$temp_file"
        echo "" >> "$temp_file"
        cat "$file" >> "$temp_file"
    fi
    
    mv "$temp_file" "$file"
}

# @description Add Python header
# @arg $1 string Path to file
# @arg $2 string Version
# @arg $3 string Created date
# @description Add Python header
# @private
# @arg $1 string Path to file
# @arg $2 string Version
# @arg $3 string Created date
_file_headers_add_python() {
    local file="$1"
    local version="$2"
    local created="$3"
    
    local temp_file=$(mktemp)
    
    # Check if file has shebang
    if head -n 1 "$file" | grep -q "^#!.*python"; then
        # Keep shebang, add header after
        head -n 1 "$file" > "$temp_file"
        echo "# DOH Version: $version" >> "$temp_file"
        echo "# Created: $created" >> "$temp_file"
        echo "" >> "$temp_file"
        tail -n +2 "$file" >> "$temp_file"
    else
        # Add header at top
        echo "# DOH Version: $version" > "$temp_file"
        echo "# Created: $created" >> "$temp_file"
        echo "" >> "$temp_file"
        cat "$file" >> "$temp_file"
    fi
    
    mv "$temp_file" "$file"
}

# @description Add JavaScript/TypeScript header
# @arg $1 string Path to file
# @arg $2 string Version
# @arg $3 string Created date
# @description Add JavaScript/TypeScript header
# @private
# @arg $1 string Path to file
# @arg $2 string Version
# @arg $3 string Created date
_file_headers_add_javascript() {
    local file="$1"
    local version="$2"
    local created="$3"
    
    local temp_file=$(mktemp)
    
    echo "// DOH Version: $version" > "$temp_file"
    echo "// Created: $created" >> "$temp_file"
    echo "" >> "$temp_file"
    cat "$file" >> "$temp_file"
    
    mv "$temp_file" "$file"
}

# @description Add YAML header
# @arg $1 string Path to file
# @arg $2 string Version
# @arg $3 string Created date
# @description Add YAML header
# @private
# @arg $1 string Path to file
# @arg $2 string Version
# @arg $3 string Created date
_file_headers_add_yaml() {
    local file="$1"
    local version="$2"
    local created="$3"
    
    local temp_file=$(mktemp)
    
    echo "# DOH Version: $version" > "$temp_file"
    echo "# Created: $created" >> "$temp_file"
    echo "" >> "$temp_file"
    cat "$file" >> "$temp_file"
    
    mv "$temp_file" "$file"
}

# @description Process multiple files to add version headers
# @arg $@ string Paths to files to process
# @stdout Progress and success messages
# @stderr Error messages for failures
# @exitcode 0 If all files processed successfully
# @exitcode 1 If any file failed
# @description Process multiple files to add version headers
# @public
# @arg $@ string Paths to files to process
# @stdout Progress and success messages
# @stderr Error messages for failures
# @exitcode 0 If all files processed successfully
# @exitcode 1 If any file failed
file_headers_batch_add() {
    local failed=0
    
    for file in "$@"; do
        if file_headers_add_version "$file"; then
            echo "✓ $file"
        else
            echo "✗ $file" >&2
            failed=1
        fi
    done
    
    return $failed
}

# @description Find all files missing version headers
# @arg $1 string Optional directory to search (default: current directory)
# @stdout List of files missing version headers
# @description Find all files missing version headers
# @public
# @arg $1 string Optional directory to search (default: current directory)
# @stdout List of files missing version headers
file_headers_find_missing_files() {
    local dir="${1:-.}"
    
    find "$dir" -type f \( -name "*.sh" -o -name "*.md" -o -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.yml" -o -name "*.yaml" \) | while read -r file; do
        if ! file_headers_file_has_version "$file"; then
            echo "$file"
        fi
    done
}
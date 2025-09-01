#!/bin/bash
# DOH Version: 0.1.0
# Created: 2025-09-01T18:40:00Z

# DOH File Headers Library
# Provides utilities for adding and managing version headers in files

# Source required dependencies
source "$(dirname "${BASH_SOURCE[0]}")/dohenv.sh"
source "$(dirname "${BASH_SOURCE[0]}")/frontmatter.sh"
source "$(dirname "${BASH_SOURCE[0]}")/version.sh"

# @description Add version header to a file based on its type
# @arg $1 string Path to the file to add header to
# @arg $2 string Optional version to use (defaults to current project version)
# @stdout Success message
# @stderr Error messages if file not found or unsupported type
# @exitcode 0 If successful
# @exitcode 1 If file not found or error occurred
add_version_header() {
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
        version=$(get_current_version) || {
            echo "Error: Could not determine current version" >&2
            return 1
        }
    fi
    
    local created_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local extension="${file##*.}"
    local filename=$(basename "$file")
    
    # For markdown files, we need special handling to respect existing style
    # For other file types, skip if header already exists
    if [[ "$extension" != "md" ]] && file_has_version_header "$file"; then
        echo "File already has version header: $file" >&2
        return 0
    fi
    
    # Add header based on file type
    case "$extension" in
        sh)
            add_shell_header "$file" "$version" "$created_date"
            ;;
        md)
            add_markdown_header "$file" "$version" "$created_date"
            ;;
        py)
            add_python_header "$file" "$version" "$created_date"
            ;;
        js|ts)
            add_javascript_header "$file" "$version" "$created_date"
            ;;
        yml|yaml)
            add_yaml_header "$file" "$version" "$created_date"
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
file_has_version_header() {
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
markdown_uses_html_comments() {
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
add_shell_header() {
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
add_markdown_header() {
    local file="$1"
    local version="$2"
    local created="$3"
    local filename=$(basename "$file")
    
    # Decision logic:
    # 1. If file already has frontmatter → use frontmatter
    # 2. If file already has HTML comments → use HTML comments
    # 3. If file has neither → choose based on file type/location
    
    if has_frontmatter "$file"; then
        # File already has frontmatter - update it safely
        local temp_file=$(mktemp)
        local in_frontmatter=false
        local has_version=false
        local has_created=false
        
        while IFS= read -r line; do
            if [[ "$line" == "---" ]]; then
                if [[ "$in_frontmatter" == false ]]; then
                    # Start of frontmatter
                    in_frontmatter=true
                    echo "$line" >> "$temp_file"
                else
                    # End of frontmatter - add missing fields before closing
                    if [[ "$has_version" == false ]]; then
                        echo "file_version: $version" >> "$temp_file"
                    fi
                    if [[ "$has_created" == false ]]; then
                        echo "created: $created" >> "$temp_file"  
                    fi
                    echo "$line" >> "$temp_file"
                    in_frontmatter=false
                fi
            elif [[ "$in_frontmatter" == true ]]; then
                # Inside frontmatter
                if [[ "$line" =~ ^file_version: ]]; then
                    echo "file_version: $version" >> "$temp_file"
                    has_version=true
                elif [[ "$line" =~ ^created: ]] && [[ "$has_created" == false ]]; then
                    echo "$line" >> "$temp_file"  # Keep existing created date
                    has_created=true
                else
                    echo "$line" >> "$temp_file"
                fi
            else
                # Outside frontmatter
                echo "$line" >> "$temp_file"
            fi
        done < "$file"
        
        mv "$temp_file" "$file"
    elif markdown_uses_html_comments "$file"; then
        # File already uses HTML comments - update them
        local temp_file=$(mktemp)
        local updated_version=false
        local updated_created=false
        
        while IFS= read -r line; do
            if [[ "$line" =~ ^\<!--[[:space:]]*DOH[[:space:]]+Version: ]]; then
                echo "<!-- DOH Version: $version -->" >> "$temp_file"
                updated_version=true
            elif [[ "$line" =~ ^\<!--[[:space:]]*Created: ]]; then
                if [[ "$updated_created" == false ]]; then
                    echo "<!-- Created: $created -->" >> "$temp_file"
                    updated_created=true
                else
                    echo "$line" >> "$temp_file"
                fi
            else
                echo "$line" >> "$temp_file"
            fi
        done < "$file"
        
        mv "$temp_file" "$file"
    else
        # File has no existing version headers - choose format based on file type
        if [[ "$file" =~ \.(epic|task|prd)\.md$ ]] || [[ "$filename" =~ ^[0-9]+\.md$ ]] || [[ "$file" =~ \.doh/.*\.md$ ]]; then
            # Structured DOH files - add frontmatter
            local temp_file=$(mktemp)
            echo "---" > "$temp_file"
            echo "file_version: $version" >> "$temp_file"
            echo "created: $created" >> "$temp_file"
            echo "---" >> "$temp_file"
            echo "" >> "$temp_file"
            cat "$file" >> "$temp_file"
            mv "$temp_file" "$file"
        else
            # General markdown files - add HTML comments
            local temp_file=$(mktemp)
            echo "<!-- DOH Version: $version -->" > "$temp_file"
            echo "<!-- Created: $created -->" >> "$temp_file"
            echo "" >> "$temp_file"
            cat "$file" >> "$temp_file"
            mv "$temp_file" "$file"
        fi
    fi
}

# @description Add Python header
# @arg $1 string Path to file
# @arg $2 string Version
# @arg $3 string Created date
add_python_header() {
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
add_javascript_header() {
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
add_yaml_header() {
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
batch_add_headers() {
    local failed=0
    
    for file in "$@"; do
        if add_version_header "$file"; then
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
find_files_missing_headers() {
    local dir="${1:-.}"
    
    find "$dir" -type f \( -name "*.sh" -o -name "*.md" -o -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.yml" -o -name "*.yaml" \) | while read -r file; do
        if ! file_has_version_header "$file"; then
            echo "$file"
        fi
    done
}
#!/bin/bash

# DOH Frontmatter Library
# Handles YAML frontmatter parsing and manipulation in markdown files

# @description Extract YAML frontmatter from a markdown file
# @arg $1 string Path to the markdown file
# @stdout YAML frontmatter content
# @stderr Error messages if file not found
# @exitcode 0 If successful
# @exitcode 1 If file not found
extract_frontmatter() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        echo "Error: File not found: $file" >&2
        return 1
    fi
    
    # Extract content between first --- and second ---
    sed -n '1,/^---$/d; /^---$/q; p' "$file"
}

# @description Get a specific field value from frontmatter
# @arg $1 string Path to the markdown file
# @arg $2 string Field name to extract
# @stdout Field value (stripped of quotes)
# @exitcode 0 Always successful
get_frontmatter_field() {
    local file="$1"
    local field="$2"
    
    extract_frontmatter "$file" | grep "^$field:" | sed "s/^$field: *//" | sed 's/^"\(.*\)"$/\1/' | sed "s/^'\(.*\)'$/\1/"
}

# @description Update a specific field in frontmatter
# @arg $1 string Path to the markdown file
# @arg $2 string Field name to update
# @arg $3 string New value for the field
# @stderr Error messages if file not found
# @exitcode 0 If successful
# @exitcode 1 If file not found
update_frontmatter_field() {
    local file="$1"
    local field="$2"
    local value="$3"
    local temp_file="${file}.tmp"
    
    if [[ ! -f "$file" ]]; then
        echo "Error: File not found: $file" >&2
        return 1
    fi
    
    # Create temp file with updated frontmatter
    {
        # Print everything before second ---
        sed -n '1,/^---$/p' "$file"
        
        # Extract frontmatter, update field, and print
        extract_frontmatter "$file" | {
            local found=false
            while IFS= read -r line; do
                if [[ "$line" =~ ^$field: ]]; then
                    echo "$field: $value"
                    found=true
                else
                    echo "$line"
                fi
            done
            
            # Add field if not found
            if [[ "$found" = false ]]; then
                echo "$field: $value"
            fi
        }
        
        # Print second --- and everything after
        echo "---"
        sed -n '/^---$/,${/^---$/d; p}' "$file" | tail -n +2
        
    } > "$temp_file"
    
    # Replace original file
    mv "$temp_file" "$file"
}

# @description Validate that required fields are present in frontmatter
# @arg $1 string Path to the markdown file
# @arg $2+ string List of required field names
# @stderr Error messages listing missing required fields
# @exitcode 0 If all fields present
# @exitcode 1 If any fields missing
validate_frontmatter() {
    local file="$1"
    shift
    local missing_fields=()
    
    for field in "$@"; do
        if [[ -z "$(get_frontmatter_field "$file" "$field")" ]]; then
            missing_fields+=("$field")
        fi
    done
    
    if [[ ${#missing_fields[@]} -gt 0 ]]; then
        echo "Error: Missing required fields in $file: ${missing_fields[*]}" >&2
        return 1
    fi
    
    return 0
}

# @description Check if frontmatter exists in file
# @arg $1 string Path to the markdown file
# @exitcode 0 If frontmatter exists
# @exitcode 1 If file not found or no frontmatter
has_frontmatter() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        return 1
    fi
    
    # Check if file starts with --- and has a second ---
    head -1 "$file" | grep -q "^---$" && grep -q "^---$" "$file"
}
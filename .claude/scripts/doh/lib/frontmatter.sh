#!/bin/bash

# DOH Frontmatter Library
# Handles YAML frontmatter parsing and manipulation in markdown files

# Extract YAML frontmatter from a markdown file
# Usage: extract_frontmatter <file>
extract_frontmatter() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        echo "Error: File not found: $file" >&2
        return 1
    fi
    
    # Extract content between first --- and second ---
    sed -n '1,/^---$/d; /^---$/q; p' "$file"
}

# Get a specific field value from frontmatter
# Usage: get_frontmatter_field <file> <field>
get_frontmatter_field() {
    local file="$1"
    local field="$2"
    
    extract_frontmatter "$file" | grep "^$field:" | sed "s/^$field: *//" | sed 's/^"\(.*\)"$/\1/' | sed "s/^'\(.*\)'$/\1/"
}

# Update a specific field in frontmatter
# Usage: update_frontmatter_field <file> <field> <value>
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

# Validate that required fields are present in frontmatter
# Usage: validate_frontmatter <file> <field1> <field2> ...
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

# Check if frontmatter exists in file
# Usage: has_frontmatter <file>
has_frontmatter() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        return 1
    fi
    
    # Check if file starts with --- and has a second ---
    head -1 "$file" | grep -q "^---$" && grep -q "^---$" "$file"
}
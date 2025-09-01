#!/bin/bash

# DOH YAML Frontmatter Library with yq
# Handles YAML frontmatter parsing and manipulation using yq
# File version: 0.1.0 | Created: 2025-09-01

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
    sed -n '/^---$/,/^---$/{/^---$/d; p}' "$file"
}

# @description Get a specific field value from frontmatter using yq
# @arg $1 string Path to the markdown file
# @arg $2 string Field name to extract (supports nested with dot notation)
# @stdout Field value
# @exitcode 0 Always successful
get_frontmatter_field() {
    local file="$1"
    local field="$2"
    
    if [[ ! -f "$file" ]]; then
        echo ""
        return
    fi
    
    local frontmatter_content
    frontmatter_content=$(extract_frontmatter "$file")
    
    if [[ -z "$frontmatter_content" ]]; then
        echo ""
        return
    fi
    
    # Use yq to extract field value
    echo "$frontmatter_content" | yq eval ".${field} // \"\"" -
}

# @description Update a specific field in frontmatter using yq
# @arg $1 string Path to the markdown file
# @arg $2 string Field name to update (supports nested with dot notation)
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
    
    # Check if file has frontmatter
    if ! has_frontmatter "$file"; then
        echo "Error: File has no frontmatter: $file" >&2
        return 1
    fi
    
    local frontmatter_content updated_frontmatter
    frontmatter_content=$(extract_frontmatter "$file")
    
    # Update field using yq
    updated_frontmatter=$(echo "$frontmatter_content" | yq eval ".${field} = \"${value}\"" -)
    
    # Reconstruct the file with updated frontmatter
    {
        echo "---"
        echo "$updated_frontmatter"
        echo "---"
        # Get everything after the closing --- of frontmatter
        awk '/^---$/ {count++; if (count==2) print_rest=1; next} print_rest {print}' "$file"
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
        local value
        value=$(get_frontmatter_field "$file" "$field")
        if [[ -z "$value" ]]; then
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
    
    # Check if file starts with --- and has exactly two --- lines (opening and closing)
    if head -1 "$file" | grep -q "^---$"; then
        local count
        count=$(grep -c "^---$" "$file")
        [[ "$count" -ge 2 ]]
    else
        return 1
    fi
}

# @description Add a field to frontmatter (or update if exists) using yq
# @arg $1 string Path to the markdown file
# @arg $2 string Field name (supports nested with dot notation)
# @arg $3 string Field value
# @stderr Error messages if file not found
# @exitcode 0 If successful
# @exitcode 1 If file not found
add_frontmatter_field() {
    local file="$1"
    local field="$2"
    local value="$3"
    
    if [[ ! -f "$file" ]]; then
        echo "Error: File not found: $file" >&2
        return 1
    fi
    
    # If file has no frontmatter, create it
    if ! has_frontmatter "$file"; then
        local content temp_file="${file}.tmp"
        content=$(cat "$file")
        
        {
            echo "---"
            echo "${field}: \"${value}\""
            echo "---"
            echo "$content"
        } > "$temp_file"
        
        mv "$temp_file" "$file"
        return 0
    fi
    
    # Use update function for existing frontmatter
    update_frontmatter_field "$file" "$field" "$value"
}

# @description Remove a field from frontmatter using yq
# @arg $1 string Path to the markdown file
# @arg $2 string Field name to remove
# @stderr Error messages if file not found
# @exitcode 0 If successful
# @exitcode 1 If file not found
remove_frontmatter_field() {
    local file="$1"
    local field="$2"
    local temp_file="${file}.tmp"
    
    if [[ ! -f "$file" ]]; then
        echo "Error: File not found: $file" >&2
        return 1
    fi
    
    if ! has_frontmatter "$file"; then
        return 0  # Nothing to remove
    fi
    
    local frontmatter_content updated_frontmatter
    frontmatter_content=$(extract_frontmatter "$file")
    
    # Remove field using yq
    updated_frontmatter=$(echo "$frontmatter_content" | yq eval "del(.${field})" -)
    
    # Reconstruct the file
    {
        echo "---"
        echo "$updated_frontmatter"
        echo "---"
        awk '/^---$/ {count++; if (count==2) print_rest=1; next} print_rest {print}' "$file"
    } > "$temp_file"
    
    mv "$temp_file" "$file"
}

# @description Get all field names from frontmatter using yq
# @arg $1 string Path to the markdown file
# @stdout List of field names, one per line
# @exitcode 0 Always successful
get_frontmatter_fields() {
    local file="$1"
    
    if [[ ! -f "$file" ]] || ! has_frontmatter "$file"; then
        return 0
    fi
    
    local frontmatter_content
    frontmatter_content=$(extract_frontmatter "$file")
    
    echo "$frontmatter_content" | yq eval 'keys | .[]' -
}

# @description Pretty print frontmatter using yq
# @arg $1 string Path to the markdown file
# @stdout Formatted YAML frontmatter
# @exitcode 0 If successful
# @exitcode 1 If file not found or no frontmatter
pretty_print_frontmatter() {
    local file="$1"
    
    if [[ ! -f "$file" ]] || ! has_frontmatter "$file"; then
        echo "Error: File not found or no frontmatter: $file" >&2
        return 1
    fi
    
    local frontmatter_content
    frontmatter_content=$(extract_frontmatter "$file")
    
    echo "$frontmatter_content" | yq eval '.' -
}

# @description Merge frontmatter from another file using yq
# @arg $1 string Path to target markdown file
# @arg $2 string Path to source markdown file (to merge from)
# @stderr Error messages if files not found
# @exitcode 0 If successful
# @exitcode 1 If files not found
merge_frontmatter() {
    local target_file="$1"
    local source_file="$2"
    local temp_file="${target_file}.tmp"
    
    if [[ ! -f "$target_file" || ! -f "$source_file" ]]; then
        echo "Error: Both files must exist" >&2
        return 1
    fi
    
    if ! has_frontmatter "$target_file" || ! has_frontmatter "$source_file"; then
        echo "Error: Both files must have frontmatter" >&2
        return 1
    fi
    
    local target_frontmatter source_frontmatter merged_frontmatter
    target_frontmatter=$(extract_frontmatter "$target_file")
    source_frontmatter=$(extract_frontmatter "$source_file")
    
    # Merge using yq (source overwrites target for conflicting keys)
    merged_frontmatter=$(echo "$target_frontmatter" | yq eval-all '. * load("'"$(mktemp)"'")' - <(echo "$source_frontmatter"))
    
    # Reconstruct target file with merged frontmatter
    {
        echo "---"
        echo "$merged_frontmatter"
        echo "---"
        awk '/^---$/ {count++; if (count==2) print_rest=1; next} print_rest {print}' "$target_file"
    } > "$temp_file"
    
    mv "$temp_file" "$target_file"
}

# @description Create a markdown file with frontmatter using yq
# @arg $1 string Path to new markdown file
# @arg $2+ string Field=value pairs for frontmatter
# @stderr Error messages if creation fails
# @exitcode 0 If successful
# @exitcode 1 If creation failed
create_markdown_with_frontmatter() {
    local file="$1"
    shift
    
    if [[ -z "$file" ]]; then
        echo "Error: Output file path required" >&2
        return 1
    fi
    
    # Start with empty YAML object
    local yaml_content="{}"
    
    # Add each field using yq
    for field_value in "$@"; do
        if [[ "$field_value" == *"="* ]]; then
            local field="${field_value%%=*}"
            local value="${field_value#*=}"
            yaml_content=$(echo "$yaml_content" | yq eval ".${field} = \"${value}\"" -)
        fi
    done
    
    # Create the file
    {
        echo "---"
        echo "$yaml_content"
        echo "---"
        echo ""
        echo "# Document"
        echo ""
        echo "Content here."
    } > "$file"
}

# @description Query frontmatter with complex yq expressions
# @arg $1 string Path to the markdown file
# @arg $2 string yq query expression
# @stdout Query result
# @exitcode 0 If successful
query_frontmatter() {
    local file="$1"
    local query="$2"
    
    if [[ ! -f "$file" ]] || ! has_frontmatter "$file"; then
        echo ""
        return
    fi
    
    local frontmatter_content
    frontmatter_content=$(extract_frontmatter "$file")
    
    echo "$frontmatter_content" | yq eval "$query" -
}

# @description Update multiple fields at once using yq
# @arg $1 string Path to the markdown file
# @arg $2+ string Field=value pairs to update
# @stderr Error messages if file not found
# @exitcode 0 If successful
# @exitcode 1 If file not found
bulk_update_frontmatter() {
    local file="$1"
    shift
    local temp_file="${file}.tmp"
    
    if [[ ! -f "$file" ]]; then
        echo "Error: File not found: $file" >&2
        return 1
    fi
    
    if ! has_frontmatter "$file"; then
        echo "Error: File has no frontmatter: $file" >&2
        return 1
    fi
    
    local frontmatter_content updated_frontmatter
    frontmatter_content=$(extract_frontmatter "$file")
    updated_frontmatter="$frontmatter_content"
    
    # Apply each update using yq
    for field_value in "$@"; do
        if [[ "$field_value" == *"="* ]]; then
            local field="${field_value%%=*}"
            local value="${field_value#*=}"
            updated_frontmatter=$(echo "$updated_frontmatter" | yq eval ".${field} = \"${value}\"" -)
        fi
    done
    
    # Reconstruct the file
    {
        echo "---"
        echo "$updated_frontmatter"
        echo "---"
        awk '/^---$/ {count++; if (count==2) print_rest=1; next} print_rest {print}' "$file"
    } > "$temp_file"
    
    mv "$temp_file" "$file"
}
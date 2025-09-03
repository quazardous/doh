#!/bin/bash

# DOH YAML Frontmatter Library with yq
# Pure library for YAML frontmatter parsing and manipulation (no automatic execution)
# File version: 0.1.0 | Created: 2025-09-01

# Source core library dependencies (zero dependencies for this library)
# Guard against multiple sourcing
[[ -n "${DOH_LIB_FRONTMATTER_LOADED:-}" ]] && return 0
DOH_LIB_FRONTMATTER_LOADED=1

# @description Extract YAML frontmatter from a markdown file
# @public
# @arg $1 string Path to the markdown file
# @stdout YAML frontmatter content
# @stderr Error messages if file not found
# @exitcode 0 If successful
# @exitcode 1 If file not found
frontmatter_extract() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        echo "Error: File not found: $file" >&2
        return 1
    fi
    
    # Extract content between first --- and second ---
    sed -n '/^---$/,/^---$/{/^---$/d; p}' "$file"
}

# @description Get a specific field value from frontmatter using yq
# @public
# @arg $1 string Path to the markdown file
# @arg $2 string Field name to extract (supports nested with dot notation)
# @stdout Field value
# @exitcode 0 Always successful
frontmatter_get_field() {
    local file="$1"
    local field="$2"
    
    if [[ ! -f "$file" ]]; then
        echo ""
        return
    fi
    
    local frontmatter_content
    frontmatter_content=$(frontmatter_extract "$file")
    
    if [[ -z "$frontmatter_content" ]]; then
        echo ""
        return
    fi
    
    # Use yq to extract field value
    echo "$frontmatter_content" | yq eval ".${field} // \"\"" -
}

# @description Update a specific field in frontmatter using yq
# @public
# @arg $1 string Path to the markdown file
# @arg $2 string Field name to update (supports nested with dot notation)
# @arg $3 string New value for the field
# @stderr Error messages if file not found
# @exitcode 0 If successful
# @exitcode 1 If file not found
frontmatter_update_field() {
    local file="$1"
    local field="$2"
    local value="$3"
    
    if [[ ! -f "$file" ]]; then
        echo "Error: File not found: $file" >&2
        return 1
    fi
    
    if [[ ! "$file" =~ \.md$ ]]; then
        echo "Error: Only markdown files (.md) are supported" >&2
        return 1
    fi
    
    # Create temporary file
    local temp_file
    temp_file=$(mktemp)
    
    # Extract frontmatter
    local frontmatter_content
    frontmatter_content=$(frontmatter_extract "$file")
    
    if [[ -z "$frontmatter_content" ]]; then
        echo "Error: No frontmatter found in $file" >&2
        rm "$temp_file"
        return 1
    fi
    
    # Update field using yq and save to temp
    local updated_frontmatter
    updated_frontmatter=$(echo "$frontmatter_content" | yq eval ".${field} = \"${value}\"" -)
    
    # Reconstruct file
    {
        echo "---"
        echo "$updated_frontmatter"
        echo "---"
        # Extract content after frontmatter (everything after the closing ---)
        awk '/^---$/{c++} c==2{getline; print; while((getline) > 0) print}' "$file"
    } > "$temp_file"
    
    # Replace original file
    mv "$temp_file" "$file"
}

# @description Validate frontmatter syntax using yq
# @public
# @arg $1 string Path to the markdown file
# @stderr Error messages if invalid YAML
# @exitcode 0 If valid frontmatter
# @exitcode 1 If invalid or missing frontmatter
frontmatter_validate() {
    local file="$1"
    shift  # Remove file parameter, rest are required fields
    local required_fields=("$@")
    
    if [[ ! -f "$file" ]]; then
        echo "Error: File not found: $file" >&2
        return 1
    fi
    
    local frontmatter_content
    frontmatter_content=$(frontmatter_extract "$file")
    
    if [[ -z "$frontmatter_content" ]]; then
        echo "Error: No frontmatter found" >&2
        return 1
    fi
    
    # Test with yq - will fail if invalid YAML
    if ! echo "$frontmatter_content" | yq eval '.' - >/dev/null 2>&1; then
        echo "Error: Invalid YAML syntax in frontmatter" >&2
        return 1
    fi
    
    # Validate required fields if specified
    if [[ ${#required_fields[@]} -gt 0 ]]; then
        for field in "${required_fields[@]}"; do
            local value
            value=$(echo "$frontmatter_content" | yq eval ".$field" - 2>/dev/null)
            if [[ "$value" == "null" || -z "$value" ]]; then
                echo "Error: Required field '$field' is missing or empty" >&2
                return 1
            fi
        done
    fi
    
    return 0
}

# @description Check if a file has frontmatter
# @public
# @arg $1 string Path to the markdown file
# @exitcode 0 If file has frontmatter
# @exitcode 1 If no frontmatter or file not found
frontmatter_has() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        return 1
    fi
    
    # Check if file starts with --- and has a closing ---
    if ! head -n 1 "$file" | grep -q "^---$"; then
        return 1
    fi
    
    # Look for closing --- delimiter (skip the first line which is opening ---)
    if ! tail -n +2 "$file" | grep -q "^---$"; then
        return 1
    fi
    
    return 0
}

# @description Add a new field to frontmatter
# @public
# @arg $1 string Path to the markdown file
# @arg $2 string Field name to add (supports nested with dot notation)
# @arg $3 string Value for the field
# @stderr Error messages if file not found
# @exitcode 0 If successful
# @exitcode 1 If file not found or error
frontmatter_add_field() {
    local file="$1"
    local field="$2"
    local value="$3"
    
    if [[ ! -f "$file" ]]; then
        echo "Error: File not found: $file" >&2
        return 1
    fi
    
    # Use update_field since yq will create field if it doesn't exist
    frontmatter_update_field "$file" "$field" "$value"
}

# @description Remove a field from frontmatter
# @public
# @arg $1 string Path to the markdown file
# @arg $2 string Field name to remove (supports nested with dot notation)
# @stderr Error messages if file not found
# @exitcode 0 If successful
# @exitcode 1 If file not found
frontmatter_remove_field() {
    local file="$1"
    local field="$2"
    
    if [[ ! -f "$file" ]]; then
        echo "Error: File not found: $file" >&2
        return 1
    fi
    
    # Create temporary file
    local temp_file
    temp_file=$(mktemp)
    
    # Extract frontmatter
    local frontmatter_content
    frontmatter_content=$(frontmatter_extract "$file")
    
    if [[ -z "$frontmatter_content" ]]; then
        echo "Error: No frontmatter found in $file" >&2
        rm "$temp_file"
        return 1
    fi
    
    # Remove field using yq
    local updated_frontmatter
    updated_frontmatter=$(echo "$frontmatter_content" | yq eval "del(.${field})" -)
    
    # Reconstruct file
    {
        echo "---"
        echo "$updated_frontmatter"
        echo "---"
        # Extract content after frontmatter
        sed -n '/^---$/,/^---$/{/^---$/d; p}' "$file" | tail -n +2
        sed '1,/^---$/d; /^---$/,$d' "$file"
    } > "$temp_file"
    
    # Replace original file
    mv "$temp_file" "$file"
}

# @description Get all fields from frontmatter
# @public
# @arg $1 string Path to the markdown file
# @stdout Field names (one per line)
# @exitcode 0 Always successful
frontmatter_get_fields() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        return
    fi
    
    local frontmatter_content
    frontmatter_content=$(frontmatter_extract "$file")
    
    if [[ -z "$frontmatter_content" ]]; then
        return
    fi
    
    # Get all keys using yq
    echo "$frontmatter_content" | yq eval 'keys | .[]' -
}

# @description Pretty print frontmatter in a readable format
# @public
# @arg $1 string Path to the markdown file
# @stdout Formatted frontmatter
# @exitcode 0 Always successful
frontmatter_pretty_print() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        echo "File not found: $file"
        return
    fi
    
    local frontmatter_content
    frontmatter_content=$(frontmatter_extract "$file")
    
    if [[ -z "$frontmatter_content" ]]; then
        echo "No frontmatter found"
        return
    fi
    
    # Pretty print using yq
    echo "$frontmatter_content" | yq eval '.' -
}

# @description Merge frontmatter from one file into another
# @public
# @arg $1 string Source file (to copy from)
# @arg $2 string Target file (to merge into)
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If error
frontmatter_merge() {
    local source_file="$1"
    local target_file="$2"
    
    if [[ ! -f "$source_file" ]]; then
        echo "Error: Source file not found: $source_file" >&2
        return 1
    fi
    
    if [[ ! -f "$target_file" ]]; then
        echo "Error: Target file not found: $target_file" >&2
        return 1
    fi
    
    local source_frontmatter target_frontmatter
    source_frontmatter=$(frontmatter_extract "$source_file")
    target_frontmatter=$(frontmatter_extract "$target_file")
    
    if [[ -z "$source_frontmatter" ]]; then
        echo "Error: No frontmatter in source file" >&2
        return 1
    fi
    
    if [[ -z "$target_frontmatter" ]]; then
        echo "Error: No frontmatter in target file" >&2
        return 1
    fi
    
    # Merge using yq (source fields take precedence)
    local merged_frontmatter
    merged_frontmatter=$(yq eval-all '. as $item ireduce ({}; . * $item)' <(echo "$target_frontmatter") <(echo "$source_frontmatter"))
    
    # Update target file
    local temp_file
    temp_file=$(mktemp)
    
    {
        echo "---"
        echo "$merged_frontmatter"
        echo "---"
        # Extract content after frontmatter from target file
        sed '1,/^---$/d; /^---$/,$d' "$target_file"
    } > "$temp_file"
    
    mv "$temp_file" "$target_file"
}

# @description Create a new markdown file with frontmatter
# @public
# @arg $1 string Path to the new file
# @arg $2 string YAML frontmatter content
# @arg $3 string Markdown content (optional)
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If error
frontmatter_create_markdown() {
    local file="$1"
    local frontmatter="$2"
    local content="${3:-}"
    
    if [[ -f "$file" ]]; then
        echo "Error: File already exists: $file" >&2
        return 1
    fi
    
    # Validate frontmatter YAML
    if ! echo "$frontmatter" | yq eval '.' - >/dev/null 2>&1; then
        echo "Error: Invalid YAML frontmatter" >&2
        return 1
    fi
    
    # Create file
    {
        echo "---"
        echo "$frontmatter"
        echo "---"
        if [[ -n "$content" ]]; then
            echo
            echo "$content"
        fi
    } > "$file"
}

# @description Query frontmatter with complex yq expressions
# @public
# @arg $1 string Path to the markdown file
# @arg $2 string yq query expression
# @stdout Query result
# @exitcode 0 Always successful
frontmatter_query() {
    local file="$1"
    local query="$2"
    
    if [[ ! -f "$file" ]]; then
        return
    fi
    
    local frontmatter_content
    frontmatter_content=$(frontmatter_extract "$file")
    
    if [[ -z "$frontmatter_content" ]]; then
        return
    fi
    
    # Execute query using yq
    echo "$frontmatter_content" | yq eval "$query" -
}

# @description Update multiple fields in frontmatter at once
# @public
# @arg $1 string Path to the markdown file
# @arg $... string Field=value pairs
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If error
frontmatter_bulk_update() {
    local file="$1"
    shift
    
    if [[ ! -f "$file" ]]; then
        echo "Error: File not found: $file" >&2
        return 1
    fi
    
    # Process each field=value pair
    for pair in "$@"; do
        if [[ "$pair" =~ ^([^=]+)=(.*)$ ]]; then
            local field="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            frontmatter_update_field "$file" "$field" "$value"
        else
            echo "Error: Invalid field=value format: $pair" >&2
            return 1
        fi
    done
}

# @description Ensure a file has frontmatter, add minimal frontmatter with created timestamp if missing
# @public
# @arg $1 string Path to the markdown file (must exist)
# @arg $2 string Optional created timestamp (ISO format), defaults to file creation time
# @stdout No output on success
# @stderr Error messages
# @exitcode 0 If successful or frontmatter already exists
# @exitcode 1 If file not found or error
frontmatter_assert() {
    local file="$1"
    local created_date="${2:-}"
    
    if [[ ! -f "$file" ]]; then
        echo "Error: File not found: $file" >&2
        return 1
    fi
    
    # Add minimal frontmatter if missing
    if ! frontmatter_has "$file"; then
        # Determine created timestamp
        local created_timestamp
        if [[ -n "$created_date" ]]; then
            created_timestamp="$created_date"
        else
            # Use file creation time (birth time if available, otherwise modification time)
            if stat -c %W "$file" &>/dev/null && [[ "$(stat -c %W "$file")" != "0" ]]; then
                # Linux with birth time support
                created_timestamp=$(date -d "@$(stat -c %W "$file")" -Iseconds)
            elif stat -f %B "$file" &>/dev/null 2>&1; then
                # macOS birth time
                created_timestamp=$(date -r "$(stat -f %B "$file")" -Iseconds)
            else
                # Fallback to modification time
                created_timestamp=$(date -r "$file" -Iseconds)
            fi
        fi
        
        # Create temporary file
        local temp_file
        temp_file=$(mktemp)
        
        # Add frontmatter at the beginning, then append original content
        cat > "$temp_file" << EOF
---
created: $created_timestamp
---
EOF
        echo >> "$temp_file"  # Add blank line after frontmatter
        cat "$file" >> "$temp_file"  # Append original content
        
        # Replace original file with temporary file
        mv "$temp_file" "$file"
    fi
}

# @description Update multiple fields in frontmatter with intelligent auto-injection
# @public
# @arg $1 string Path to the markdown file (must exist, use touch to create)
# @arg $... string Options and Field:value pairs
# @option --auto-number Auto-generate number field if not provided
# @stdout Complete frontmatter YAML content after updates
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If error
frontmatter_update_many() {
    local file="$1"
    shift
    
    local auto_number=false
    local field_pairs=()
    
    # Parse arguments for flags and field pairs
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --auto-number)
                auto_number=true
                shift
                ;;
            *)
                field_pairs+=("$1")
                shift
                ;;
        esac
    done
    
    # Check if file exists
    if [[ ! -f "$file" ]]; then
        echo "Error: File not found: $file" >&2
        return 1
    fi
    
    # Check which auto-fields are already provided
    local has_file_version=false
    local has_created=false
    local has_updated=false
    local has_number=false
    local created_for_assert=""
    
    for pair in "${field_pairs[@]}"; do
        if [[ "$pair" =~ ^file_version: ]]; then
            has_file_version=true
        elif [[ "$pair" =~ ^created:(.*)$ ]]; then
            has_created=true
            created_for_assert="${BASH_REMATCH[1]}"
        elif [[ "$pair" =~ ^updated: ]]; then
            has_updated=true
        elif [[ "$pair" =~ ^number: ]]; then
            has_number=true
        fi
    done
    
    # Ensure file has frontmatter with created timestamp
    if [[ "$has_created" == true ]]; then
        frontmatter_assert "$file" "$created_for_assert"
    else
        frontmatter_assert "$file"
    fi
    
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local api_script="$script_dir/../api.sh"
    local current_timestamp=$(date -Iseconds)
    
    # Auto-inject file_version if not provided
    if [[ "$has_file_version" == false ]] && [[ -x "$api_script" ]]; then
        local current_version
        current_version=$("$api_script" version get_current 2>/dev/null)
        if [[ -n "$current_version" ]]; then
            frontmatter_update_field "$file" "file_version" "$current_version"
        fi
    fi
    
    # Auto-inject created timestamp if not provided and field doesn't exist
    if [[ "$has_created" == false ]]; then
        local existing_created
        existing_created=$(frontmatter_get_field "$file" "created")
        if [[ -z "$existing_created" || "$existing_created" == "null" ]]; then
            frontmatter_update_field "$file" "created" "$current_timestamp"
        fi
    fi
    
    # Auto-inject updated timestamp (always updated)
    if [[ "$has_updated" == false ]]; then
        frontmatter_update_field "$file" "updated" "$current_timestamp"
    fi
    
    # Auto-inject number if requested and not provided
    if [[ "$auto_number" == true ]] && [[ "$has_number" == false ]] && [[ -x "$api_script" ]]; then
        local next_number
        next_number=$("$api_script" numbering get_next "task" 2>/dev/null)
        if [[ -n "$next_number" ]]; then
            frontmatter_update_field "$file" "number" "$next_number"
        fi
    fi
    
    # Remove temporary placeholder if it exists (legacy cleanup)
    local temp_value
    temp_value=$(frontmatter_get_field "$file" "temp")
    if [[ "$temp_value" == "placeholder" ]]; then
        frontmatter_remove_field "$file" "temp"
    fi
    
    # Process each field:value pair
    for pair in "${field_pairs[@]}"; do
        if [[ "$pair" =~ ^([^:]+):(.*)$ ]]; then
            local field="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            frontmatter_update_field "$file" "$field" "$value"
        else
            echo "Error: Invalid field:value format: $pair" >&2
            return 1
        fi
    done
    
    # Output the complete frontmatter on stdout
    frontmatter_extract "$file"
}


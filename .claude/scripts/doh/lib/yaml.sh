#!/bin/bash

# DOH YAML Library  
# Advanced YAML parsing utilities for DOH
# File version: 0.1.0 | Created: 2025-09-01

# @description Advanced YAML parser function
# @arg $1 string Path to YAML file or "-" for stdin
# @arg $2 string Variable prefix for output variables (optional, default "")
# @stdout Variable assignments in format "PREFIX_key=value" 
# @stderr Error messages if file not found or parsing fails
# @exitcode 0 If successful
# @exitcode 1 If file not found or parsing error
parse_yaml() {
   local input="$1"
   local prefix="${2:-}"
   
   if [[ "$input" != "-" && ! -f "$input" ]]; then
       echo "Error: YAML file not found: $input" >&2
       return 1
   fi
   
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  "$input" |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

# @description Parse YAML content from a string
# @arg $1 string YAML content as string  
# @arg $2 string Variable prefix for output variables (optional, default "")
# @stdout Variable assignments in format "PREFIX_key=value"
# @exitcode 0 Always successful
parse_yaml_string() {
    local yaml_content="$1"
    local prefix="${2:-}"
    
    echo "$yaml_content" | parse_yaml "-" "$prefix"
}

# @description Get a specific field value from parsed YAML variables
# @arg $1 string Field name (can be nested with underscores, e.g. "metadata_author")  
# @arg $2 string Variable prefix used during parsing
# @stdout Field value if found, empty string if not found
# @exitcode 0 Always successful
get_yaml_field() {
    local field="$1"
    local prefix="${2:-}"
    local varname="${prefix}${field}"
    
    # Use indirect variable expansion to get the value
    echo "${!varname:-}"
}

# @description Load YAML file into shell variables with given prefix
# @arg $1 string Path to YAML file
# @arg $2 string Variable prefix (required to avoid conflicts)  
# @stderr Error messages if file not found or prefix missing
# @exitcode 0 If successful
# @exitcode 1 If file not found or prefix missing
load_yaml_vars() {
    local file="$1"
    local prefix="$2"
    
    if [[ -z "$prefix" ]]; then
        echo "Error: Variable prefix required for load_yaml_vars" >&2
        return 1
    fi
    
    if [[ ! -f "$file" ]]; then
        echo "Error: YAML file not found: $file" >&2
        return 1
    fi
    
    # Parse YAML and evaluate variable assignments
    eval "$(parse_yaml "$file" "$prefix")"
}

# @description Create temporary YAML file from string content
# @arg $1 string YAML content
# @stdout Path to temporary YAML file
# @exitcode 0 If successful  
create_temp_yaml() {
    local content="$1"
    local temp_file
    temp_file=$(mktemp --suffix=.yaml)
    echo "$content" > "$temp_file"
    echo "$temp_file"
}

# @description Validate YAML syntax (basic validation)
# @arg $1 string Path to YAML file or "-" for stdin
# @stderr Error messages if validation fails
# @exitcode 0 If YAML is valid
# @exitcode 1 If YAML is invalid
validate_yaml() {
    local input="$1"
    
    # Basic validation - check if parse_yaml runs without errors
    if parse_yaml "$input" "test_" >/dev/null 2>&1; then
        return 0
    else
        echo "Error: Invalid YAML syntax in $input" >&2
        return 1
    fi
}

# @description Extract specific section from YAML by key path
# @arg $1 string Path to YAML file
# @arg $2 string Key path (e.g., "metadata" or "config_database")  
# @stdout YAML content under the specified key
# @exitcode 0 If successful
# @exitcode 1 If key not found
extract_yaml_section() {
    local file="$1"
    local key_path="$2"
    
    # This is a simplified implementation - could be enhanced
    # For now, it extracts top-level keys only
    awk -v key="$key_path" '
        /^[a-zA-Z0-9_-]+:/ { 
            if ($0 ~ "^" key ":") {
                found=1; print; next
            } else {
                found=0
            }
        }
        /^[[:space:]]/ { if (found) print }
        /^$/ { if (found) print }
    ' "$file"
}

# @description Update a YAML field in a file
# @arg $1 string Path to YAML file
# @arg $2 string Field name (supports nested fields with dots, e.g., "metadata.author")
# @arg $3 string New value
# @stderr Error messages if file not found or field invalid
# @exitcode 0 If successful
# @exitcode 1 If file not found or update failed
update_yaml_field() {
    local file="$1"
    local field="$2"
    local value="$3"
    local temp_file="${file}.tmp"
    
    if [[ ! -f "$file" ]]; then
        echo "Error: YAML file not found: $file" >&2
        return 1
    fi
    
    # Convert dot notation to underscore for internal use
    local internal_field="${field//./_}"
    
    # For simple fields (no nesting), use direct sed replacement
    if [[ "$field" != *"."* ]]; then
        sed "s/^${field}:.*/${field}: ${value}/" "$file" > "$temp_file"
        mv "$temp_file" "$file"
        return 0
    fi
    
    # For nested fields, this is more complex - basic implementation
    # Parse the file, update the variable, then reconstruct
    local parsed_vars temp_var_file
    temp_var_file=$(mktemp)
    
    # Parse existing YAML into variables
    parse_yaml "$file" "yaml_" > "$temp_var_file"
    
    # Update the specific variable
    sed -i "s/^yaml_${internal_field}=.*/yaml_${internal_field}=\"${value}\"/" "$temp_var_file"
    
    # Check if the field existed
    if ! grep -q "^yaml_${internal_field}=" "$temp_var_file"; then
        echo "yaml_${internal_field}=\"${value}\"" >> "$temp_var_file"
    fi
    
    # Reconstruct YAML (basic implementation)
    reconstruct_yaml_from_vars "$temp_var_file" "yaml_" > "$temp_file"
    mv "$temp_file" "$file"
    rm -f "$temp_var_file"
}

# @description Reconstruct YAML from variable assignments
# @arg $1 string File containing variable assignments
# @arg $2 string Variable prefix to strip
# @stdout YAML content
# @exitcode 0 If successful
reconstruct_yaml_from_vars() {
    local var_file="$1"
    local prefix="$2"
    
    # This is a simplified reconstruction - doesn't handle nesting perfectly
    # Read variables and convert back to YAML format
    while IFS='=' read -r var value; do
        if [[ "$var" == "${prefix}"* ]]; then
            local field="${var#$prefix}"
            # Remove quotes from value
            value="${value#\"}"
            value="${value%\"}"
            
            # Convert underscores back to nested structure
            if [[ "$field" == *"_"* ]]; then
                # This is a simplified approach - doesn't recreate proper nesting
                local yaml_key="${field//_/:}"
                echo "$yaml_key: $value"
            else
                echo "$field: $value"
            fi
        fi
    done < "$var_file"
}

# @description Create a new YAML file with given fields
# @arg $1 string Path to new YAML file  
# @arg $2+ string Field-value pairs in format "field=value"
# @stderr Error messages if creation fails
# @exitcode 0 If successful
# @exitcode 1 If creation failed
create_yaml_file() {
    local file="$1"
    shift
    
    if [[ -z "$file" ]]; then
        echo "Error: Output file path required" >&2
        return 1
    fi
    
    # Create the file
    > "$file"
    
    # Add fields
    for field_value in "$@"; do
        if [[ "$field_value" == *"="* ]]; then
            local field="${field_value%%=*}"
            local value="${field_value#*=}"
            echo "$field: $value" >> "$file"
        fi
    done
}

# @description Add a field to an existing YAML file
# @arg $1 string Path to YAML file
# @arg $2 string Field name
# @arg $3 string Field value
# @stderr Error messages if file not found
# @exitcode 0 If successful  
# @exitcode 1 If file not found
add_yaml_field() {
    local file="$1"
    local field="$2"
    local value="$3"
    
    if [[ ! -f "$file" ]]; then
        echo "Error: YAML file not found: $file" >&2
        return 1
    fi
    
    # Check if field already exists
    if grep -q "^${field}:" "$file"; then
        # Update existing field
        update_yaml_field "$file" "$field" "$value"
    else
        # Add new field
        echo "$field: $value" >> "$file"
    fi
}

# @description Remove a field from YAML file
# @arg $1 string Path to YAML file
# @arg $2 string Field name to remove
# @stderr Error messages if file not found
# @exitcode 0 If successful
# @exitcode 1 If file not found
remove_yaml_field() {
    local file="$1" 
    local field="$2"
    local temp_file="${file}.tmp"
    
    if [[ ! -f "$file" ]]; then
        echo "Error: YAML file not found: $file" >&2
        return 1
    fi
    
    # Remove the field (simple implementation)
    grep -v "^${field}:" "$file" > "$temp_file"
    mv "$temp_file" "$file"
}

# @description Merge two YAML files
# @arg $1 string Path to first YAML file (base)
# @arg $2 string Path to second YAML file (overlay)  
# @arg $3 string Path to output file (optional, defaults to first file)
# @stderr Error messages if files not found
# @exitcode 0 If successful
# @exitcode 1 If files not found
merge_yaml_files() {
    local base_file="$1"
    local overlay_file="$2"
    local output_file="${3:-$base_file}"
    local temp_file temp_vars
    
    if [[ ! -f "$base_file" || ! -f "$overlay_file" ]]; then
        echo "Error: Both YAML files must exist" >&2
        return 1
    fi
    
    temp_file=$(mktemp)
    temp_vars=$(mktemp)
    
    # Parse both files and merge variables
    {
        parse_yaml "$base_file" "base_"
        parse_yaml "$overlay_file" "overlay_" | sed 's/^overlay_/base_/'
    } | sort -u -t'=' -k1,1 > "$temp_vars"
    
    # Reconstruct merged YAML
    reconstruct_yaml_from_vars "$temp_vars" "base_" > "$temp_file"
    mv "$temp_file" "$output_file"
    rm -f "$temp_vars"
}

# @description Convert YAML to JSON format using parsed variables
# @arg $1 string Path to YAML file
# @stdout JSON representation
# @exitcode 0 If successful
yaml_to_json() {
    local file="$1"
    local temp_vars temp_json
    
    temp_vars=$(mktemp)
    temp_json=$(mktemp)
    
    # Parse YAML into variables
    parse_yaml "$file" "yaml_" > "$temp_vars"
    
    # Convert variables to JSON
    echo "{" > "$temp_json"
    local first=true
    while IFS='=' read -r var value; do
        if [[ "$var" == "yaml_"* ]]; then
            local key="${var#yaml_}"
            # Remove quotes from value
            value="${value#\"}"
            value="${value%\"}"
            
            # Add comma for all but first entry
            if [[ "$first" == "true" ]]; then
                first=false
            else
                echo "," >> "$temp_json"
            fi
            
            # Convert nested fields (underscores) to dot notation
            key="${key//_/.}"
            printf '  "%s": "%s"' "$key" "$value" >> "$temp_json"
        fi
    done < "$temp_vars"
    echo "" >> "$temp_json"
    echo "}" >> "$temp_json"
    
    cat "$temp_json"
    rm -f "$temp_vars" "$temp_json"
}

# @description Convert JSON back to YAML format
# @arg $1 string Path to JSON file or "-" for stdin
# @stdout YAML representation
# @exitcode 0 If successful
json_to_yaml() {
    local input="$1"
    
    # Use jq to convert JSON to key-value pairs, then format as YAML
    if [[ "$input" == "-" ]]; then
        jq -r 'to_entries[] | "\(.key): \(.value)"'
    else
        jq -r 'to_entries[] | "\(.key): \(.value)"' "$input"
    fi
}

# @description Get field value from YAML using jq via JSON conversion
# @arg $1 string Path to YAML file
# @arg $2 string Field name (supports dot notation for nested fields)
# @stdout Field value
# @exitcode 0 If successful
get_yaml_field_jq() {
    local file="$1"
    local field="$2"
    
    # Convert YAML to JSON and use jq to extract field
    yaml_to_json "$file" | jq -r ".\"$field\" // empty"
}

# @description Update field in YAML using jq via JSON conversion
# @arg $1 string Path to YAML file
# @arg $2 string Field name (supports dot notation)
# @arg $3 string New value
# @exitcode 0 If successful
update_yaml_field_jq() {
    local file="$1"
    local field="$2"
    local value="$3"
    local temp_json temp_yaml temp_updated_json
    
    temp_json=$(mktemp)
    temp_yaml=$(mktemp)
    temp_updated_json=$(mktemp)
    
    # Convert YAML to JSON
    yaml_to_json "$file" > "$temp_json"
    
    # Update field using jq
    jq --arg field "$field" --arg value "$value" '. + {($field): $value}' "$temp_json" > "$temp_updated_json"
    
    # Convert back to YAML
    json_to_yaml "$temp_updated_json" > "$temp_yaml"
    
    # Replace original file
    mv "$temp_yaml" "$file"
    rm -f "$temp_json" "$temp_updated_json"
}

# @description Remove field from YAML using jq via JSON conversion
# @arg $1 string Path to YAML file  
# @arg $2 string Field name
# @exitcode 0 If successful
remove_yaml_field_jq() {
    local file="$1"
    local field="$2"
    local temp_json temp_yaml
    
    temp_json=$(mktemp)
    temp_yaml=$(mktemp)
    
    # Convert YAML to JSON
    yaml_to_json "$file" > "$temp_json"
    
    # Remove field using jq
    jq --arg field "$field" 'del(.[$field])' "$temp_json" | json_to_yaml > "$temp_yaml"
    
    # Replace original file
    mv "$temp_yaml" "$file"
    rm -f "$temp_json"
}
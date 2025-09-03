---
name: add-file-headers
description: Add version headers to files based on their type
type: bash
parallel_execution: false
success_exit_code: 0
timeout: 30000
file_version: 0.1.0
---

# /doh:add-file-headers

## Description
Add DOH version headers to files based on their file type. Supports multiple file types with appropriate comment syntax.

## Usage
```
/doh:add-file-headers <files...> [--version <version>] [--batch]
```

## Arguments
- `<files...>`: One or more files to add headers to
- `--version <version>`: Specific version to use (defaults to current project version)
- `--batch`: Process all files missing headers in current directory

## Implementation
```bash
#!/bin/bash
# Use DOH API instead of direct library sourcing

# Parse arguments
files=()
version=""
batch_mode=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --version)
            version="$2"
            shift 2
            ;;
        --batch)
            batch_mode=true
            shift
            ;;
        *)
            files+=("$1")
            shift
            ;;
    esac
done

if [[ "$batch_mode" == true ]]; then
    echo "Finding files missing version headers..."
    missing_files=$(./.claude/scripts/doh/helper.sh file-headers find_missing)
    
    if [[ -z "$missing_files" ]]; then
        echo "All files already have version headers!"
        exit 0
    fi
    
    echo "Found files missing headers:"
    echo "$missing_files"
    echo ""
    echo "Adding headers..."
    
    while IFS= read -r file; do
        ./.claude/scripts/doh/helper.sh file-headers add_header "$file" "$version"
    done <<< "$missing_files"
else
    if [[ ${#files[@]} -eq 0 ]]; then
        echo "Error: No files specified. Use --batch for all files or specify files."
        exit 1
    fi
    
    for file in "${files[@]}"; do
        ./.claude/scripts/doh/helper.sh file-headers add_header "$file" "$version"
    done
fi
```

## File Type Support
- **Shell Scripts (.sh)**: `# DOH Version: X.Y.Z`
- **Markdown (.md)**: Frontmatter with `file_version: X.Y.Z`
- **Python (.py)**: `# DOH Version: X.Y.Z`
- **JavaScript/TypeScript (.js/.ts)**: `// DOH Version: X.Y.Z`
- **YAML (.yml/.yaml)**: `# DOH Version: X.Y.Z`

## Examples
```bash
# Add header to a single file
/doh:add-file-headers script.sh

# Add headers to multiple files
/doh:add-file-headers lib/*.sh

# Use specific version
/doh:add-file-headers --version 1.0.0 new-feature.py

# Process all files missing headers
/doh:add-file-headers --batch
```
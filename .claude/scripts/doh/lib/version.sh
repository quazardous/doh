#!/bin/bash

# DOH Version Management Library
# Provides version tracking and manipulation utilities for DOH files

# Source required dependencies
source "$(dirname "${BASH_SOURCE[0]}")/frontmatter.sh"

# Constants
readonly VERSION_LIB_VERSION="1.0.0"

# Get current project version from VERSION file at project root
# Usage: get_current_version
get_current_version() {
    local doh_root
    doh_root="$(_find_doh_root)" || {
        echo "Error: Not in a DOH project" >&2
        return 1
    }
    
    local version_file="$doh_root/VERSION"
    
    if [[ ! -f "$version_file" ]]; then
        echo "Error: VERSION file not found at project root: $version_file" >&2
        return 1
    fi
    
    local version
    version=$(cat "$version_file" | tr -d '[:space:]')
    
    if [[ -z "$version" ]]; then
        echo "Error: VERSION file is empty" >&2
        return 1
    fi
    
    if ! validate_version "$version"; then
        echo "Error: Invalid version format in VERSION file: $version" >&2
        return 1
    fi
    
    echo "$version"
}

# Get version from a specific DOH file (epic, task, or PRD)
# Usage: get_file_version <file_path>
get_file_version() {
    local file="$1"
    
    if [[ -z "$file" ]]; then
        echo "Error: File path required" >&2
        return 1
    fi
    
    if [[ ! -f "$file" ]]; then
        echo "Error: File not found: $file" >&2
        return 1
    fi
    
    # Try to get file_version first, fall back to target_version
    local version
    version=$(get_frontmatter_field "$file" "file_version")
    
    if [[ -z "$version" ]]; then
        version=$(get_frontmatter_field "$file" "target_version")
    fi
    
    if [[ -z "$version" ]]; then
        echo "Error: No version field found in $file" >&2
        return 1
    fi
    
    echo "$version"
}

# Set/update the file_version in a DOH file
# Usage: set_file_version <file_path> <version>
set_file_version() {
    local file="$1"
    local version="$2"
    
    if [[ -z "$file" || -z "$version" ]]; then
        echo "Error: File path and version required" >&2
        return 1
    fi
    
    if [[ ! -f "$file" ]]; then
        echo "Error: File not found: $file" >&2
        return 1
    fi
    
    # Validate semver format (basic check)
    if ! [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.-]+)?(\+[a-zA-Z0-9.-]+)?$ ]]; then
        echo "Error: Invalid semver format: $version" >&2
        return 1
    fi
    
    update_frontmatter_field "$file" "file_version" "$version"
}

# Increment version (patch, minor, or major)
# Usage: increment_version <current_version> <level>
# Level can be: patch, minor, major
increment_version() {
    local current="$1"
    local level="$2"
    
    if [[ -z "$current" || -z "$level" ]]; then
        echo "Error: Current version and increment level required" >&2
        return 1
    fi
    
    # Extract version parts (ignore pre-release and build metadata for now)
    local version_part="${current%%-*}"  # Remove pre-release
    version_part="${version_part%%+*}"   # Remove build metadata
    
    IFS='.' read -ra parts <<< "$version_part"
    local major="${parts[0]:-0}"
    local minor="${parts[1]:-0}"
    local patch="${parts[2]:-0}"
    
    case "$level" in
        "patch")
            patch=$((patch + 1))
            ;;
        "minor")
            minor=$((minor + 1))
            patch=0
            ;;
        "major")
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        *)
            echo "Error: Invalid increment level: $level. Use: patch, minor, major" >&2
            return 1
            ;;
    esac
    
    echo "${major}.${minor}.${patch}"
}

# Set/update the project version in VERSION file
# Usage: set_project_version <version>
set_project_version() {
    local version="$1"
    
    if [[ -z "$version" ]]; then
        echo "Error: Version required" >&2
        return 1
    fi
    
    # Validate semver format
    if ! validate_version "$version"; then
        echo "Error: Invalid semver format: $version" >&2
        return 1
    fi
    
    local doh_root
    doh_root="$(_find_doh_root)" || {
        echo "Error: Not in a DOH project" >&2
        return 1
    }
    
    local version_file="$doh_root/VERSION"
    
    echo "$version" > "$version_file" || {
        echo "Error: Failed to write to VERSION file: $version_file" >&2
        return 1
    }
    
    echo "Project version updated to: $version"
}

# Bump project version by increment level
# Usage: bump_project_version <level>
bump_project_version() {
    local level="$1"
    
    if [[ -z "$level" ]]; then
        echo "Error: Increment level required (patch, minor, major)" >&2
        return 1
    fi
    
    local current_version
    current_version=$(get_current_version) || return 1
    
    local new_version
    new_version=$(increment_version "$current_version" "$level") || return 1
    
    set_project_version "$new_version" || return 1
    
    echo "$new_version"
}

# Bump file version by increment level
# Usage: bump_file_version <file_path> <level>
bump_file_version() {
    local file="$1"
    local level="$2"
    
    if [[ -z "$file" || -z "$level" ]]; then
        echo "Error: File path and increment level required" >&2
        return 1
    fi
    
    local current_version
    current_version=$(get_file_version "$file") || return 1
    
    local new_version
    new_version=$(increment_version "$current_version" "$level") || return 1
    
    set_file_version "$file" "$new_version" || return 1
    
    echo "$new_version"
}

# Compare two semver versions
# Usage: compare_versions <version1> <version2>
# Returns: 0 if equal, 1 if version1 > version2, 2 if version1 < version2
compare_versions() {
    local ver1="$1"
    local ver2="$2"
    
    if [[ -z "$ver1" || -z "$ver2" ]]; then
        echo "Error: Two versions required for comparison" >&2
        return 1
    fi
    
    # Simple lexicographic comparison for now
    if [[ "$ver1" == "$ver2" ]]; then
        return 0
    elif [[ "$ver1" > "$ver2" ]]; then
        return 1
    else
        return 2
    fi
}

# Check if a version is valid semver format
# Usage: validate_version <version>
validate_version() {
    local version="$1"
    
    if [[ -z "$version" ]]; then
        return 1
    fi
    
    # Basic semver regex validation
    [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.-]+)?(\+[a-zA-Z0-9.-]+)?$ ]]
}

# Get all files with missing file_version field
# Usage: find_files_missing_version [directory]
find_files_missing_version() {
    local dir="${1:-.}"
    
    find "$dir" -name "*.md" -type f | while read -r file; do
        if has_frontmatter "$file"; then
            local version
            version=$(get_frontmatter_field "$file" "file_version")
            if [[ -z "$version" ]]; then
                echo "$file"
            fi
        fi
    done
}
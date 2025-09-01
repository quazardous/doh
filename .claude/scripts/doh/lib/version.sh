#!/bin/bash

# DOH Version Management Library
# Provides version tracking and manipulation utilities for DOH files

# Source required dependencies
source "$(dirname "${BASH_SOURCE[0]}")/frontmatter.sh"

# Constants
readonly VERSION_LIB_VERSION="1.0.0"

# @description Get current project version from VERSION file at project root
# @stdout Current project version string
# @stderr Error messages if VERSION file is missing, empty, or invalid
# @exitcode 0 If successful
# @exitcode 1 If not in DOH project, VERSION file not found, empty, or invalid
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

# @description Get version from a specific DOH file (epic, task, or PRD)
# @arg $1 string Path to the file to read version from
# @stdout Version string from file frontmatter
# @stderr Error messages if file not found or no version field found
# @exitcode 0 If successful
# @exitcode 1 If file path missing, file not found, or no version field found
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

# @description Set/update the file_version in a DOH file
# @arg $1 string Path to the file to update
# @arg $2 string New version string to set
# @stderr Error messages if parameters missing, file not found, or invalid version format
# @exitcode 0 If successful
# @exitcode 1 If parameters missing, file not found, or invalid semver format
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

# @description Increment version (patch, minor, or major)
# @arg $1 string Current version string
# @arg $2 string Increment level ("patch", "minor", or "major")
# @stdout New incremented version string
# @stderr Error messages if parameters missing or invalid increment level
# @exitcode 0 If successful
# @exitcode 1 If parameters missing or invalid increment level
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

# @description Set/update the project version in VERSION file
# @arg $1 string New version string to set
# @stdout Success message with updated version
# @stderr Error messages if version missing, invalid format, not in DOH project, or write failure
# @exitcode 0 If successful
# @exitcode 1 If version missing, invalid semver format, not in DOH project, or write failure
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

# @description Bump project version by increment level
# @arg $1 string Increment level ("patch", "minor", or "major")
# @stdout New version string
# @stderr Error messages if increment level missing or other errors from dependent functions
# @exitcode 0 If successful
# @exitcode 1 If increment level missing or errors from dependent functions
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

# @description Bump file version by increment level
# @arg $1 string Path to the file to update
# @arg $2 string Increment level ("patch", "minor", or "major")
# @stdout New version string
# @stderr Error messages if parameters missing or errors from dependent functions
# @exitcode 0 If successful
# @exitcode 1 If parameters missing or errors from dependent functions
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

# @description Compare two semver versions
# @arg $1 string First version to compare
# @arg $2 string Second version to compare
# @stderr Error messages if two versions not provided
# @exitcode 0 If versions are equal
# @exitcode 1 If ver1 > ver2 or parameters missing
# @exitcode 2 If ver1 < ver2
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

# @description Check if a version is valid semver format
# @arg $1 string Version string to validate
# @exitcode 0 If valid semver format
# @exitcode 1 If invalid or empty version string
validate_version() {
    local version="$1"
    
    if [[ -z "$version" ]]; then
        return 1
    fi
    
    # Basic semver regex validation
    [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.-]+)?(\+[a-zA-Z0-9.-]+)?$ ]]
}

# @description Get all files with missing file_version field
# @arg $1 string Optional directory to search (default: current directory)
# @stdout List of files missing file_version field
# @exitcode 0 Always successful
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
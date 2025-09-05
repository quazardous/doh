#!/bin/bash

# DOH Version Management Library
# Pure library for version tracking and manipulation utilities (no automatic execution)

# Source core library dependencies
source "$(dirname "${BASH_SOURCE[0]}")/doh.sh"
source "$(dirname "${BASH_SOURCE[0]}")/frontmatter.sh"

# Guard against multiple sourcing
[[ -n "${DOH_LIB_VERSION_LOADED:-}" ]] && return 0
DOH_LIB_VERSION_LOADED=1

# Constants
readonly VERSION_LIB_VERSION="1.0.0"

# @description Get current project version from VERSION file at project root
# @public
# @stdout Current project version string
# @stderr Error messages if VERSION file is missing, empty, or invalid
# @exitcode 0 If successful
# @exitcode 1 If not in DOH project, VERSION file not found, empty, or invalid
version_get_current() {
    local version_file
    version_file="$(doh_version_file)" || return 1
    
    if [[ ! -f "$version_file" ]]; then
        echo "Error: VERSION file not found at project root: $version_file" >&2
        return 1
    fi
    
    local version
    version=$(head -n 1 "$version_file" | tr -d '[:space:]')
    
    if [[ -z "$version" ]]; then
        echo "Error: VERSION file is empty or contains only whitespace" >&2
        return 1
    fi
    
    # Validate version format (basic semver check)
    if ! version_validate "$version"; then
        echo "Error: Invalid version format in VERSION file: $version" >&2
        return 1
    fi
    
    echo "$version"
}

# @description Get version from file frontmatter
# @public
# @arg $1 string Path to file to check
# @stdout Version string from frontmatter
# @stderr Error messages if file not found or no version
# @exitcode 0 If successful
# @exitcode 1 If file not found or no version found
version_get_file() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        echo "Error: File not found: $file" >&2
        return 1
    fi
    
    # First try file_version field
    local version
    version=$(frontmatter_get_field "$file" "file_version")
    
    # If no file_version, try target_version as fallback
    if [[ -z "$version" || "$version" == "null" ]]; then
        version=$(frontmatter_get_field "$file" "target_version")
    fi
    
    if [[ -z "$version" || "$version" == "null" ]]; then
        echo "Error: No file_version or target_version found in frontmatter" >&2
        return 1
    fi
    
    echo "$version"
}

# @description Set version in file frontmatter
# @public
# @arg $1 string Path to file to update
# @arg $2 string New version string
# @stderr Error messages if file not found or invalid version
# @exitcode 0 If successful
# @exitcode 1 If file not found or error
version_set_file() {
    local file="$1"
    local new_version="$2"
    
    if [[ ! -f "$file" ]]; then
        echo "Error: File not found: $file" >&2
        return 1
    fi
    
    if ! version_validate "$new_version"; then
        echo "Error: Invalid version format: $new_version" >&2
        return 1
    fi
    
    # Update file_version field
    frontmatter_update_field "$file" "file_version" "$new_version"
}

# @description Increment a version string according to semver rules
# @public
# @arg $1 string Version string to increment
# @arg $2 string Increment type (major, minor, patch, prerelease)
# @stdout Incremented version string
# @stderr Error messages if invalid version or increment type
# @exitcode 0 If successful
# @exitcode 1 If invalid version or increment type
version_increment() {
    local version="$1"
    local increment_type="$2"
    
    if ! version_validate "$version"; then
        echo "Error: Invalid version format: $version" >&2
        return 1
    fi
    
    # Parse version components (strip build metadata first)
    local clean_version="${version%%+*}"  # Remove build metadata
    local major minor patch prerelease
    if [[ "$clean_version" =~ ^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-([a-zA-Z0-9.-]+))?$ ]]; then
        major="${BASH_REMATCH[1]}"
        minor="${BASH_REMATCH[2]}"
        patch="${BASH_REMATCH[3]}"
        prerelease="${BASH_REMATCH[5]}"
    else
        echo "Error: Unable to parse version: $version" >&2
        return 1
    fi
    
    case "$increment_type" in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            prerelease=""
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            prerelease=""
            ;;
        patch)
            patch=$((patch + 1))
            prerelease=""
            ;;
        prerelease)
            if [[ -n "$prerelease" ]]; then
                # Increment existing prerelease
                if [[ "$prerelease" =~ ^([a-zA-Z.-]+)([0-9]+)$ ]]; then
                    local pre_text="${BASH_REMATCH[1]}"
                    local pre_num="${BASH_REMATCH[2]}"
                    ((pre_num++))
                    prerelease="${pre_text}${pre_num}"
                else
                    prerelease="${prerelease}.1"
                fi
            else
                # Add first prerelease
                prerelease="alpha.1"
            fi
            ;;
        *)
            echo "Error: Invalid increment type: $increment_type" >&2
            echo "Valid types: major, minor, patch, prerelease" >&2
            return 1
            ;;
    esac
    
    # Construct new version
    local new_version="${major}.${minor}.${patch}"
    if [[ -n "$prerelease" ]]; then
        new_version="${new_version}-${prerelease}"
    fi
    
    echo "$new_version"
}

# @description Set current project version in VERSION file
# @public
# @arg $1 string New version string
# @stderr Error messages if invalid version or unable to write
# @exitcode 0 If successful
# @exitcode 1 If not in DOH project, invalid version, or write error
version_set_current() {
    local new_version="$1"
    
    if ! version_validate "$new_version"; then
        echo "Error: Invalid version format: $new_version" >&2
        return 1
    fi
    
    local version_file
    version_file="$(doh_version_file)" || return 1
    
    # Write new version to file
    if ! echo "$new_version" > "$version_file"; then
        echo "Error: Unable to write to VERSION file: $version_file" >&2
        return 1
    fi
}

# @description Bump current project version by increment type
# @public
# @arg $1 string Increment type (major, minor, patch, prerelease)
# @stdout New version string
# @stderr Error messages if unable to bump version
# @exitcode 0 If successful
# @exitcode 1 If error
version_bump_current() {
    local increment_type="$1"
    
    local current_version
    current_version="$(version_get_current)" || return 1
    
    local new_version
    new_version="$(version_increment "$current_version" "$increment_type")" || return 1
    
    version_set_current "$new_version" || return 1
    
    echo "$new_version"
}

# @description Bump file version by increment type
# @public
# @arg $1 string Path to file to update
# @arg $2 string Increment type (major, minor, patch, prerelease)
# @stdout New version string
# @stderr Error messages if unable to bump version
# @exitcode 0 If successful
# @exitcode 1 If error
version_bump_file() {
    local file="$1"
    local increment_type="$2"
    
    local current_version
    current_version=$(version_get_file "$file") || return 1
    
    local new_version
    new_version="$(version_increment "$current_version" "$increment_type")" || return 1
    
    version_set_file "$file" "$new_version" || return 1
    
    echo "$new_version"
}

# @description Convert version string to comparable number
# @private
# @arg $1 string Version string
# @stdout Comparable number
# @exitcode 0 Always successful
_version_to_number() {
    local version="$1"
    
    # Strip build metadata if present
    version="${version%%+*}"
    
    # Extract major.minor.patch and ignore prerelease for comparison
    if [[ "$version" =~ ^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*) ]]; then
        local major="${BASH_REMATCH[1]}"
        local minor="${BASH_REMATCH[2]}"
        local patch="${BASH_REMATCH[3]}"
        
        # Convert to comparable number: major * 1000000 + minor * 1000 + patch
        echo $((major * 1000000 + minor * 1000 + patch))
    else
        echo "0"
    fi
}

# @description Convert prerelease suffix to adjustment number
# @private
# @arg $1 string Version string
# @stdout Adjustment number for prerelease comparison
# @exitcode 0 Always successful
_version_prerelease_to_adjustment() {
    local version="$1"
    
    # Strip build metadata if present
    version="${version%%+*}"
    
    if [[ "$version" =~ -([a-zA-Z0-9.-]+)$ ]]; then
        local prerelease="${BASH_REMATCH[1]}"
        
        # Prerelease versions are less than release versions
        # Return negative adjustment
        local base_adjust=0
        local suffix_adjust=0
        
        # Parse prerelease type and optional suffix
        if [[ "$prerelease" =~ ^(alpha|beta|rc)(\.|$)(.*)$ ]]; then
            local type="${BASH_REMATCH[1]}"
            local rest="${BASH_REMATCH[3]}"
            
            case "$type" in
                alpha) base_adjust=-1000 ;;
                beta) base_adjust=-500 ;;
                rc) base_adjust=-100 ;;
            esac
            
            # Handle suffix - numeric identifiers come before non-numeric
            if [[ -n "$rest" ]]; then
                if [[ "$rest" =~ ^[0-9]+$ ]]; then
                    # Pure numeric suffix
                    suffix_adjust="${rest}"
                elif [[ "$rest" =~ ^([0-9]+)\. ]]; then
                    # Numeric followed by more
                    suffix_adjust="${BASH_REMATCH[1]}"
                else
                    # Non-numeric suffix - stays within the base range
                    # alpha.x should still be less than beta
                    suffix_adjust=50
                fi
            fi
        else
            base_adjust=-50
        fi
        
        echo $((base_adjust + suffix_adjust))
    else
        # No prerelease, full release
        echo "0"
    fi
}

# @description Compare two version strings
# @public
# @arg $1 string First version string
# @arg $2 string Second version string
# @stdout Comparison result: -1 (v1 < v2), 0 (v1 == v2), 1 (v1 > v2)
# @stderr Error messages if invalid versions
# @exitcode 0 If versions are equal
# @exitcode 1 If first version is greater
# @exitcode 2 If first version is lesser
version_compare() {
    local version1="$1"
    local version2="$2"
    
    local num1 num2 adj1 adj2
    num1=$(_version_to_number "$version1")
    num2=$(_version_to_number "$version2")
    adj1=$(_version_prerelease_to_adjustment "$version1")
    adj2=$(_version_prerelease_to_adjustment "$version2")
    
    local total1=$((num1 + adj1))
    local total2=$((num2 + adj2))
    
    if [[ $total1 -lt $total2 ]]; then
        echo "-1"
        return 2
    elif [[ $total1 -gt $total2 ]]; then
        echo "1"
        return 1
    else
        echo "0"
        return 0
    fi
}

# @description Validate version string format
# @public
# @arg $1 string Version string to validate
# @arg $2 string Optional "explode" flag to output parsed components
# @stdout If explode flag set: "major=X minor=Y patch=Z prerelease=PRE build=BUILD"
# @exitcode 0 If valid version format
# @exitcode 1 If invalid version format
version_validate() {
    local version="$1"
    local explode="${2:-false}"
    
    # Check basic semver pattern with optional build metadata (no leading zeros)
    if [[ "$version" =~ ^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-([a-zA-Z0-9.-]+))?(\+([a-zA-Z0-9.-]+))?$ ]]; then
        if [[ "$explode" == "true" || "$explode" == "explode" ]]; then
            local major="${BASH_REMATCH[1]}"
            local minor="${BASH_REMATCH[2]}"
            local patch="${BASH_REMATCH[3]}"
            local prerelease="${BASH_REMATCH[5]}"
            local build="${BASH_REMATCH[7]}"
            
            # Echo exploded version components
            echo "major=$major minor=$minor patch=$patch prerelease=$prerelease build=$build"
        fi
        return 0
    else
        return 1
    fi
}

# @description Find files without file_version information
# @public
# @stdout List of files missing file_version information
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If not in DOH project
version_find_files_without_file_version() {
    local doh_dir
    doh_dir="$(doh_project_dir)" || return 1
    
    # Find markdown files in DOH directory structure
    find "$doh_dir" -name "*.md" -type f | while read -r file; do
        if ! frontmatter_has "$file"; then
            continue
        fi
        
        local version
        version=$(frontmatter_get_field "$file" "file_version")
        
        if [[ -z "$version" || "$version" == "null" ]]; then
            echo "$file"
        fi
    done
}

# @description Find files with version inconsistencies
# @public
# @stdout List of files with version issues
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If not in DOH project
version_find_inconsistencies() {
    local doh_dir
    doh_dir="$(doh_project_dir)" || return 1
    
    # Find markdown files and check for version issues
    find "$doh_dir" -name "*.md" -type f | while read -r file; do
        if ! frontmatter_has "$file"; then
            continue
        fi
        
        local file_version
        file_version=$(frontmatter_get_field "$file" "file_version")
        
        if [[ -n "$file_version" && "$file_version" != "null" ]]; then
            if ! version_validate "$file_version"; then
                echo "Invalid version format in $file: $file_version"
            fi
        fi
    done
}

# @description List all versions found in project
# @public
# @stdout List of unique versions found
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If not in DOH project
version_list() {
    local doh_dir
    doh_dir="$(doh_project_dir)" || return 1
    
    # Collect all versions from markdown files
    {
        # Project version
        local version_file
        version_file="$(doh_version_file)" && [[ -f "$version_file" ]] && {
            version_get_current 2>/dev/null || true
        }
        
        # File versions
        find "$doh_dir" -name "*.md" -type f | while read -r file; do
            if frontmatter_has "$file"; then
                local version
                version=$(frontmatter_get_field "$file" "version" 2>/dev/null) || true
                if [[ -n "$version" && "$version" != "null" ]]; then
                    echo "$version"
                fi
                
                version=$(frontmatter_get_field "$file" "file_version" 2>/dev/null) || true
                if [[ -n "$version" && "$version" != "null" ]]; then
                    echo "$version"
                fi
                
                version=$(frontmatter_get_field "$file" "target_version" 2>/dev/null) || true
                if [[ -n "$version" && "$version" != "null" ]]; then
                    echo "$version"
                fi
            fi
        done
    } | sort -u
}

# @description Create version milestone content with proper formatting
# @arg $1 string Version number
# @arg $2 string Version type (initial|release|patch|minor|major)
# @arg $3 string Description (optional)
# @stdout Version milestone markdown content
# @exitcode 0 Always succeeds
version_create_content() {
    local version="$1"
    local type="${2:-release}"
    local description="${3:-}"
    
    local description_section=""
    if [[ -n "$description" ]]; then
        description_section="$description

"
    fi
    
    # Escape special characters for sed
    local escaped_version="${version//\//\\/}"
    local escaped_desc="${description_section//\//\\/}"
    escaped_desc="${escaped_desc//$'\n'/\\n}"
    
    cat <<'VERSION_TEMPLATE' | sed "s/VERSION_PLACEHOLDER/$escaped_version/g" | sed "s/DESCRIPTION_SECTION_PLACEHOLDER/$escaped_desc/g"

# Version VERSION_PLACEHOLDER

DESCRIPTION_SECTION_PLACEHOLDER## Changes
<!-- List of changes in this version -->

## Breaking Changes
<!-- List any breaking changes that require user action -->

## Migration Notes
<!-- Instructions for migrating from previous version -->

## Contributors
<!-- List contributors to this version -->
VERSION_TEMPLATE
}

# @description Create new version milestone file with frontmatter
# @arg $1 string Version path
# @arg $2 string Version number
# @arg $3 string Version type (initial|release|patch|minor|major)
# @arg $4 string Description (optional)
# @arg $5 string Git tag (optional)
# @stdout Creation status messages
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If creation failed
version_create() {
    local version_path="$1"
    local version="$2"
    local type="${3:-release}"
    local description="${4:-}"
    local git_tag="${5:-}"
    
    if [[ -z "$version_path" || -z "$version" ]]; then
        echo "Error: Missing required parameters" >&2
        echo "Usage: version_create <path> <version> [type] [description] [git_tag]" >&2
        return 1
    fi
    
    # Validate version format
    if ! version_validate "$version"; then
        echo "Error: Invalid version format: $version" >&2
        return 1
    fi
    
    # Generate content using the content creation function
    local version_content
    version_content=$(version_create_content "$version" "$type" "$description")
    
    # Build frontmatter fields
    local -a frontmatter_fields=(
        "version:$version"
        "type:$type"
    )
    
    if [[ -n "$git_tag" ]]; then
        frontmatter_fields+=("git_tag:$git_tag")
    fi
    
    # Create version file with frontmatter
    frontmatter_create_markdown "$version_path" "$version_content" "${frontmatter_fields[@]}"
    
    return $?
}

# @description Update version fields using frontmatter
# @arg $1 string Version file path
# @arg $... string Field:value pairs to update
# @stdout Update status messages
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If update failed
version_update() {
    local version_path="$1"
    shift
    
    if [[ -z "$version_path" ]]; then
        echo "Error: Missing version file path" >&2
        echo "Usage: version_update <path> field:value [field:value ...]" >&2
        return 1
    fi
    
    if [[ ! -f "$version_path" ]]; then
        echo "Error: Version file not found: $version_path" >&2
        return 1
    fi
    
    # Update version fields using frontmatter_update_many
    frontmatter_update_many "$version_path" "$@"
    
    return $?
}


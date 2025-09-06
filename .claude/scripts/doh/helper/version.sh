#!/bin/bash

# DOH Version Helper
# User-facing functions for version management operations

set -euo pipefail

# Source required dependencies
DOH_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
source "${DOH_ROOT}/.claude/scripts/doh/lib/dohenv.sh"
source "${DOH_ROOT}/.claude/scripts/doh/lib/doh.sh"
source "${DOH_ROOT}/.claude/scripts/doh/lib/version.sh"

# Load DOH environment
dohenv_load

# Guard against multiple sourcing
[[ -n "${DOH_HELPER_VERSION_LOADED:-}" ]] && return 0
DOH_HELPER_VERSION_LOADED=1

# @description Définir une nouvelle version
# @arg $1 string Version à définir (ex: 1.0.0)
# @arg $2 string Description de la version (optionnel)
# @stdout Confirmation de la version définie
# @exitcode 0 Si définition réussie
# @exitcode 1 Si version invalide ou erreur
helper_version_new() {
    local version="$1"
    local description="${2:-}"
    
    if [[ -z "$version" ]]; then
        echo "Error: Version required" >&2
        echo "Usage: helper.sh version new <version> [description]" >&2
        echo "Example: helper.sh version new 1.0.0 'New release'" >&2
        return 1
    fi
    
    # Validate version format using version API
    if ! version_validate "$version"; then
        echo "Error: Invalid version format: $version" >&2
        echo "Version must be in semantic format (e.g., 1.0.0)" >&2
        return 1
    fi
    
    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }

    local version_file="$doh_dir/versions/${version}.md"
    
    # Check if version file already exists
    if [[ -f "$version_file" ]]; then
        echo "Error: Version file already exists: $version_file" >&2
        echo "Use 'helper.sh version edit $version' to modify existing version" >&2
        return 1
    fi
    
    echo "Creating version: $version"
    
    # Create version file using version_create from lib/version.sh
    if ! version_create "$version_file" "$version" "release" "$description"; then
        echo "Error: Failed to create version file" >&2
        return 1
    fi
    
    echo "✅ Version file created: $version_file"
    echo "💡 Version created as milestone only"
    echo "   Use 'helper.sh version bump $version' to set as current if needed"
    
    return 0
}

# @description Afficher les informations de version
# @arg $1 string Fichier à analyser (optionnel, par défaut: VERSION)
# @stdout Informations de version
# @exitcode 0 Toujours
helper_version_show() {
    local target_file="${1:-}"
    
    if [[ -n "$target_file" ]]; then
        echo "Version information for: $target_file"
        echo "=================================="
        
        # Show version from specific file
        local file_version
        file_version="$(version_get_file "$target_file" 2>/dev/null || echo "")"
        
        if [[ -n "$file_version" ]]; then
            echo "📄 File Version: $file_version"
        else
            echo "❌ No version found in file: $target_file"
            return 0
        fi
        
    else
        echo "DOH Version Information"
        echo "======================"
        
        # Show current project version
        local current_version
        current_version="$(version_get_current 2>/dev/null || echo "unknown")"
        echo "📋 Current Version: $current_version"
        
        # Show VERSION file location
        if [[ -f "VERSION" ]]; then
            echo "📄 Version File: VERSION"
        else
            echo "⚠️ No VERSION file found"
        fi
        
        local doh_dir
        doh_dir=$(doh_project_dir) || {
            echo "Error: Not in DOH project" >&2
            return 1
        }

        # Show available version files
        echo ""
        echo "📚 Available Version Files:"
        if [[ -d "$doh_dir/versions" ]]; then
            local version_files
            version_files=$(ls "$doh_dir/versions/*.md" 2>/dev/null | wc -l)
            if [[ "$version_files" -gt 0 ]]; then
                for version_file in "$doh_dir/versions/*.md"; do
                    if [[ -f "$version_file" ]]; then
                        local version_name
                        version_name=$(basename "$version_file" .md)
                        local version_status
                        version_status="$(frontmatter_get_field "$version_file" "status" 2>/dev/null || echo "unknown")"
                        echo "   - $version_name ($version_status)"
                    fi
                done
            else
                echo "   (none found)"
            fi
        else
            echo "   (no versions directory)"
        fi
        
        # Show version comparison info
        echo ""
        echo "🔍 Version Consistency Check:"
        local inconsistencies
        inconsistencies="$(version_find_inconsistencies 2>/dev/null || echo "")"
        if [[ -n "$inconsistencies" ]]; then
            echo "⚠️ Found version inconsistencies:"
            echo "$inconsistencies"
        else
            echo "✅ All versions appear consistent"
        fi
    fi
    
    return 0
}

# @description Incrémenter la version
# @arg $1 string Type d'incrément (major, minor, patch)
# @stdout Nouvelle version après incrément
# @exitcode 0 Si incrément réussi
# @exitcode 1 Si type invalide ou erreur
helper_version_bump() {
    local bump_type="${1:-}"
    
    if [[ -z "$bump_type" ]]; then
        echo "Error: Bump type required" >&2
        echo "Usage: helper.sh version bump <type>" >&2
        echo "Types: major, minor, patch" >&2
        return 1
    fi
    
    # Validate bump type
    case "$bump_type" in
        "major"|"minor"|"patch")
            # Valid bump type
            ;;
        *)
            echo "Error: Invalid bump type '$bump_type'" >&2
            echo "Valid types: major, minor, patch" >&2
            return 1
            ;;
    esac
    
    # Get current version
    local current_version
    current_version="$(version_get_current 2>/dev/null || echo "")"
    
    if [[ -z "$current_version" ]]; then
        echo "Error: No current version found" >&2
        echo "Set initial version first: helper.sh version new 1.0.0" >&2
        return 1
    fi
    
    echo "Bumping version: $bump_type"
    echo "Current version: $current_version"
    
    # Increment version using version API
    local new_version
    new_version="$(version_increment "$current_version" "$bump_type")" || {
        echo "Error: Failed to increment version" >&2
        return 1
    }
    
    # Set the new version
    version_set_current "$new_version" || {
        echo "Error: Failed to set new version" >&2
        return 1
    }
    
    echo "✅ Version bumped:"
    echo "   From: $current_version"
    echo "   To: $new_version"
    echo "   Type: $bump_type"
    
    # Suggest next steps
    echo ""
    echo "💡 Next steps:"
    echo "   - Update CHANGELOG.md with changes"
    echo "   - Create version file: /doh:version-new $new_version"
    echo "   - Tag release: git tag v$new_version"
    
    return 0
}

# @description Lister toutes les versions
# @stdout Liste des versions avec statuts
# @exitcode 0 Toujours
helper_version_list() {
    echo "DOH Version List"
    echo "================"
    
    # Show current version
    local current_version
    current_version="$(version_get_current 2>/dev/null || echo "unknown")"
    echo "📋 Current: $current_version"
    echo ""
    
    # List version files using version API
    local version_list
    version_list="$(version_list 2>/dev/null || echo "")"
    
    if [[ -n "$version_list" ]]; then
        echo "📚 Version Files:"
        echo "$version_list"
    else
        echo "📚 Version Files: (none found)"
        echo ""
        echo "💡 Create your first version file:"
        echo "   /doh:version-new $current_version"
    fi
    
    return 0
}

# @description Comparer deux versions
# @arg $1 string Première version
# @arg $2 string Deuxième version
# @stdout Résultat de la comparaison
# @exitcode 0 Si comparaison réussie
helper_version_compare() {
    local version1="$1"
    local version2="$2"
    
    if [[ -z "$version1" || -z "$version2" ]]; then
        echo "Error: Two versions required for comparison" >&2
        echo "Usage: helper.sh version compare <version1> <version2>" >&2
        return 1
    fi
    
    echo "Comparing versions:"
    echo "  Version 1: $version1"
    echo "  Version 2: $version2"
    
    # Use version API to compare
    local result
    result="$(version_compare "$version1" "$version2" 2>/dev/null || echo "error")"
    
    case "$result" in
        "0")
            echo "✅ Result: Versions are equal"
            ;;
        "1")
            echo "📈 Result: $version1 is greater than $version2"
            ;;
        "-1")
            echo "📉 Result: $version1 is less than $version2"
            ;;
        *)
            echo "❌ Result: Error comparing versions"
            return 1
            ;;
    esac
    
    return 0
}

# @description Afficher l'aide des commandes version
# @stdout Informations d'aide
# @exitcode 0 Toujours
helper_version_help() {
    cat <<'EOF'
DOH Version Management
=====================

Usage: helper.sh version <command> [options]

Commands:
    new <version>               Set new version (e.g., 1.0.0)
    show [file]                 Show version information
    bump <type>                 Increment version (major|minor|patch)
    list                        List all versions with status
    compare <version1> <version2>  Compare two versions
    help                        Show this help message

Bump types:
    major     - Increment major version (1.0.0 → 2.0.0)
    minor     - Increment minor version (1.0.0 → 1.1.0)
    patch     - Increment patch version (1.0.0 → 1.0.1)

Examples:
    helper.sh version new 1.0.0
    helper.sh version show
    helper.sh version show VERSION
    helper.sh version bump patch
    helper.sh version compare 1.0.0 2.0.0
    helper.sh version list
EOF
    return 0
}

# @description Update version fields
# @arg $1 string Version identifier
# @arg $... string Field:value pairs to update
# @stdout Update status messages
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If update failed
helper_version_update() {
    local version="${1:-}"
    shift
    
    # Validation
    if [[ -z "$version" ]]; then
        echo "Error: Version identifier required" >&2
        echo "Usage: version update <version> field:value [field:value ...]" >&2
        return 1
    fi
    
    # Get DOH directory
    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }
    
    # Find version file
    local version_file="$doh_dir/versions/${version}.md"
    
    if [[ ! -f "$version_file" ]]; then
        # Try with v prefix
        version_file="$doh_dir/versions/v${version}.md"
        if [[ ! -f "$version_file" ]]; then
            echo "Error: Version not found: $version" >&2
            echo "Available versions:" >&2
            find "$doh_dir/versions" -name "*.md" -type f 2>/dev/null | while read -r file; do
                [ -f "$file" ] && echo "  • $(basename "$file" .md)" >&2
            done
            return 1
        fi
    fi
    
    # Update version fields using library function
    echo "📝 Updating version: $version"
    version_update "$version_file" "$@"
    local result=$?
    
    if [[ $result -eq 0 ]]; then
        echo "✅ Version updated successfully"
        
        # Show updated fields
        for field_value in "$@"; do
            if [[ "$field_value" =~ ^([^:]+):(.*)$ ]]; then
                local field="${BASH_REMATCH[1]}"
                local value="${BASH_REMATCH[2]}"
                echo "   • $field: $value"
            fi
        done
    else
        echo "❌ Failed to update version" >&2
    fi
    
    return $result
}

# @description Delete a version file (only planned/draft versions)
# @arg $1 string Version to delete (ex: 1.0.0)
# @arg $2 string Force flag (--force) to skip confirmation
# @stdout Confirmation of deletion
# @exitcode 0 Si suppression réussie
# @exitcode 1 Si version introuvable ou erreur
helper_version_delete() {
    local version="$1"
    local force="${2:-}"
    
    if [[ -z "$version" ]]; then
        echo "Error: Version required" >&2
        echo "Usage: helper.sh version delete <version> [--force]" >&2
        return 1
    fi
    
    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }
    
    local version_file="$doh_dir/versions/${version}.md"
    
    if [[ ! -f "$version_file" ]]; then
        echo "Error: Version not found: $version" >&2
        return 1
    fi
    
    # Check status to prevent deletion of released versions
    local status
    status=$(frontmatter_get_field "$version_file" "status" 2>/dev/null || echo "unknown")
    
    if [[ "$status" == "released" ]]; then
        echo "Error: Cannot delete released version $version" >&2
        echo "Released versions are preserved for project history" >&2
        return 1
    fi
    
    if [[ "$force" != "--force" ]]; then
        echo "⚠️  Delete version $version (status: $status)?"
        echo "This action cannot be undone."
        echo ""
        echo "1. ✅ Yes, delete version $version"
        echo "2. ❌ No, cancel deletion"
        echo ""
        echo "Add --force to skip this confirmation"
        return 1
    fi
    
    rm "$version_file" || {
        echo "Error: Failed to delete version file: $version_file" >&2
        return 1
    }
    
    echo "✅ Version deleted: $version"
    return 0
}

# @description Show version status overview
# @arg $1 string Optional flags (--all, --detailed)
# @stdout Version status information
# @exitcode 0 Si réussi
helper_version_status() {
    local flags="${1:-}"
    
    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }
    
    local current_version
    current_version=$(version_get_current 2>/dev/null || echo "unknown")
    
    echo "📊 Version Status"
    echo "=================="
    echo "Current version: $current_version"
    echo ""
    
    if [[ "$flags" == "--all" || "$flags" == "--detailed" ]]; then
        # Delegate to helper_version_list for detailed listing
        helper_version_list
    else
        # Show summary
        local version_count
        version_count=$(find "$doh_dir/versions" -name "*.md" -type f 2>/dev/null | wc -l)
        echo "Total versions: $version_count"
        
        if [[ $version_count -gt 0 ]]; then
            echo ""
            echo "Recent versions:"
            find "$doh_dir/versions" -name "*.md" -type f 2>/dev/null | \
                head -5 | while read -r file; do
                    local ver=$(basename "$file" .md)
                    local status=$(frontmatter_get_field "$file" "status" 2>/dev/null || echo "unknown")
                    echo "  • $ver ($status)"
                done
        fi
    fi
    
    return 0
}

# @description Validate version files and structure
# @arg $1 string Optional specific version to validate
# @stdout Validation results
# @exitcode 0 Si validation réussie
# @exitcode 1 Si erreurs trouvées
helper_version_validate() {
    local specific_version="${1:-}"
    
    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }
    
    local errors=0
    
    echo "🔍 Validating versions..."
    echo ""
    
    if [[ -n "$specific_version" ]]; then
        # Validate specific version
        local version_file="$doh_dir/versions/${specific_version}.md"
        if [[ ! -f "$version_file" ]]; then
            echo "❌ Version not found: $specific_version" >&2
            return 1
        fi
        
        if ! frontmatter_validate "$version_file"; then
            echo "❌ Invalid frontmatter in $specific_version" >&2
            errors=$((errors + 1))
        else
            echo "✅ $specific_version: Valid"
        fi
    else
        # Validate all versions
        if [[ -d "$doh_dir/versions" ]]; then
            for version_file in "$doh_dir/versions"/*.md; do
                [[ -f "$version_file" ]] || continue
                
                local version=$(basename "$version_file" .md)
                
                if ! frontmatter_validate "$version_file"; then
                    echo "❌ $version: Invalid frontmatter"
                    errors=$((errors + 1))
                elif ! version_validate "$version"; then
                    echo "❌ $version: Invalid version format"
                    errors=$((errors + 1))
                else
                    echo "✅ $version: Valid"
                fi
            done
        fi
    fi
    
    echo ""
    if [[ $errors -eq 0 ]]; then
        echo "✅ All versions valid"
        return 0
    else
        echo "❌ Found $errors validation errors"
        return 1
    fi
}

# @description Migrate project to use versioning system
# @stdout Migration progress and results
# @exitcode 0 Si migration réussie
# @exitcode 1 Si erreur during migration
helper_version_migrate() {
    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }
    
    echo "🔄 Migrating to versioning system..."
    echo ""
    
    # Create versions directory if it doesn't exist
    if [[ ! -d "$doh_dir/versions" ]]; then
        mkdir -p "$doh_dir/versions" || {
            echo "Error: Failed to create versions directory" >&2
            return 1
        }
        echo "✅ Created versions directory"
    fi
    
    # Check if VERSION file exists
    if [[ ! -f "VERSION" ]]; then
        echo "📝 Creating initial VERSION file..."
        echo "0.1.0" > VERSION || {
            echo "Error: Failed to create VERSION file" >&2
            return 1
        }
        echo "✅ Created VERSION file with 0.1.0"
    fi
    
    # Create initial version file if none exist
    local version_count
    version_count=$(find "$doh_dir/versions" -name "*.md" -type f 2>/dev/null | wc -l)
    
    if [[ $version_count -eq 0 ]]; then
        local current_version
        current_version=$(version_get_current 2>/dev/null || echo "0.1.0")
        
        echo "📄 Creating initial version file for $current_version..."
        if version_create "$doh_dir/versions/${current_version}.md" "$current_version" "release" "Initial version"; then
            echo "✅ Created initial version file: $current_version"
        else
            echo "Error: Failed to create initial version file" >&2
            return 1
        fi
    fi
    
    echo ""
    echo "✅ Migration to versioning system complete"
    echo ""
    echo "Next steps:"
    echo "• Use '/doh:version' to manage versions"
    echo "• Use '/doh:version status' to see current state"
    echo "• Use '/doh:version 1.0.0' to create new versions"
    
    return 0
}

# Helpers should only be called through helper.sh bootstrap
# Direct execution is not allowed
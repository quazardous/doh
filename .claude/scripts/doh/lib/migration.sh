#!/bin/bash

# DOH Migration Library
# Pure library for DOH project migration operations (no automatic execution)

# Source core library dependencies
source "$(dirname "${BASH_SOURCE[0]}")/doh.sh"
source "$(dirname "${BASH_SOURCE[0]}")/version.sh"
source "$(dirname "${BASH_SOURCE[0]}")/frontmatter.sh"

# Guard against multiple sourcing
[[ -n "${DOH_LIB_MIGRATION_LOADED:-}" ]] && return 0
DOH_LIB_MIGRATION_LOADED=1

# Constants
readonly MIGRATION_LIB_VERSION="1.0.0"
readonly MIGRATION_LOG_FILE=".doh/migration.log"
readonly BACKUP_PREFIX=".doh_backup_"

# @description Perform DOH version migration with specified options
# @arg $1 string Options string (comma-separated flags)
# @stdout Migration progress and results
# @stderr Error messages
# @exitcode 0 If migration successful
# @exitcode 1 If migration failed
migration_migrate_version() {
    local options="${1:-}"
    
    # Parse options
    local analyze_only=false
    local dry_run=false
    local from_git=false
    local interactive=false
    local rollback=false
    local force=false
    local deduplicate=false
    local initial_version="0.1.0"
    
    IFS=',' read -ra OPTS <<< "$options"
    for opt in "${OPTS[@]}"; do
        case "$opt" in
            analyze) analyze_only=true ;;
            dry-run) dry_run=true ;;
            from-git) from_git=true ;;
            interactive) interactive=true ;;
            rollback) rollback=true ;;
            force) force=true ;;
            deduplicate) deduplicate=true ;;
            *) ;; # Ignore unknown options
        esac
    done
    
    local doh_root
    doh_root=$(doh_find_root) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }

    # Initialize logging
    mkdir -p "$(dirname "$MIGRATION_LOG_FILE")"
    echo "=== DOH Version Migration - $(date) ===" > "$MIGRATION_LOG_FILE"
    
    if [[ "$rollback" == "true" ]]; then
        _migration_rollback_migration "$doh_root"
        return $?
    fi
    
    if [[ "$analyze_only" == "true" ]]; then
        _migration_analyze_project "$doh_root" "$from_git"
        return $?
    fi
    
    if [[ "$interactive" == "true" ]]; then
        _migration_interactive_migration "$doh_root"
        return $?
    fi
    
    # Standard migration
    _migration_perform_migration "$doh_root" "$dry_run" "$from_git" "$initial_version" "$deduplicate"
}

# @description Analyze project for migration readiness
# @arg $1 string DOH root directory
# @arg $2 boolean Whether to analyze git history
# @stdout Analysis report
# @stderr Error messages
# @exitcode 0 If analysis successful
# @exitcode 1 If not a valid DOH project
_migration_analyze_project() {
    local doh_root="$1"
    local from_git="$2"
    
    echo "📊 Migration Analysis Report"
    echo "============================"
    echo ""
    
    # Check if versioning already enabled
    if [[ -f "$doh_root/VERSION" ]]; then
        echo "⚠️  VERSION file already exists ($(cat "$doh_root/VERSION"))"
        echo "   Project already has versioning enabled"
    else
        echo "✅ No VERSION file found - ready for migration"
    fi
    
    # Check .doh structure
    if [[ -d "$doh_root/.doh" ]]; then
        echo "✅ DOH project structure detected"
        
        # Count files that need version migration
        local md_files
        md_files=$(find "$doh_root/.doh" -name "*.md" -type f | wc -l)
        echo "📄 Found $md_files markdown files for migration"
        
        # Check for existing frontmatter
        local files_with_frontmatter=0
        local files_needing_version=0
        
        while IFS= read -r -d '' file; do
            if frontmatter_has "$file"; then
                ((files_with_frontmatter++))
                if ! frontmatter_get_field "$file" "file_version" >/dev/null 2>&1; then
                    ((files_needing_version++))
                fi
            fi
        done < <(find "$doh_root/.doh" -name "*.md" -type f -print0)
        
        echo "📋 $files_with_frontmatter files have frontmatter"
        echo "🔄 $files_needing_version files need version field"
    else
        echo "❌ No .doh directory found - not a DOH project"
        return 1
    fi
    
    # Check git history if requested
    if [[ "$from_git" == "true" ]]; then
        if [[ -d "$doh_root/.git" ]]; then
            local git_tags
            git_tags=$(git -C "$doh_root" tag -l | wc -l)
            echo "🏷️  Found $git_tags git tags for version history"
        else
            echo "⚠️  No git repository found for history import"
        fi
    fi
    
    echo ""
    echo "💡 Recommendations:"
    if [[ -f "$doh_root/VERSION" ]]; then
        echo "   • Use --rollback to remove existing versioning first"
        echo "   • Or continue with current version system"
    else
        echo "   • Project is ready for version migration"
        echo "   • Use --dry-run to see planned changes"
        echo "   • Use --interactive for guided migration"
    fi
}

# @description Perform the actual migration
# @arg $1 string DOH root directory
# @arg $2 boolean Dry run mode
# @arg $3 boolean Import git history
# @arg $4 string Initial version
# @arg $5 boolean Include deduplication
# @stdout Migration progress
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If failed
_migration_perform_migration() {
    local doh_root="$1"
    local dry_run="$2"
    local from_git="$3"
    local initial_version="$4"
    local deduplicate="$5"
    
    echo "🚀 Starting DOH version migration..."
    
    # Create backup
    local backup_location
    backup_location=$(_migration_create_backup "$doh_root" "$dry_run") || return 1
    
    # Initialize version system
    _migration_initialize_version_system "$doh_root" "$dry_run" "$initial_version" || return 1
    
    # Import git history if requested
    if [[ "$from_git" == "true" ]]; then
        _migration_import_git_history "$doh_root" "$dry_run"
    fi
    
    # Update files with versions
    _migration_update_files_with_versions "$doh_root" "$dry_run" "$initial_version" || return 1
    
    # Validate migration
    if [[ "$dry_run" != "true" ]]; then
        _migration_validate_migration "$doh_root" "$initial_version" || return 1
    fi
    
    # Generate report
    _migration_generate_report "$doh_root" "$dry_run" "$initial_version" "$backup_location"
    
    echo "✅ Migration completed successfully!"
}

# @description Create backup of current state
# @arg $1 string DOH root directory
# @arg $2 boolean Dry run mode
# @stdout Backup location
# @stderr Error messages
# @exitcode 0 If successful
_migration_create_backup() {
    local doh_root="$1"
    local dry_run="$2"
    
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_location="$doh_root/${BACKUP_PREFIX}$timestamp"
    
    echo "ℹ️  Creating backup at: $backup_location"
    
    if [[ "$dry_run" == "true" ]]; then
        echo "ℹ️  [DRY RUN] Would create backup directory"
        echo "$backup_location"
        return 0
    fi
    
    mkdir -p "$backup_location" || {
        echo "❌ Failed to create backup directory" >&2
        return 1
    }
    
    # Backup VERSION file if it exists
    [[ -f "$doh_root/VERSION" ]] && cp "$doh_root/VERSION" "$backup_location/"
    
    # Backup .doh directory
    if [[ -d "$doh_root/.doh" ]]; then
        cp -r "$doh_root/.doh" "$backup_location/"
    fi
    
    echo "✅ Backup created successfully"
    echo "$backup_location" > "$doh_root/.doh/last_backup.txt"
    echo "$backup_location"
}

# @description Initialize version system
# @arg $1 string DOH root directory
# @arg $2 boolean Dry run mode
# @arg $3 string Initial version
# @stdout Initialization progress
# @stderr Error messages
# @exitcode 0 If successful
_migration_initialize_version_system() {
    local doh_root="$1"
    local dry_run="$2"
    local initial_version="$3"
    
    echo "ℹ️  Initializing version system..."
    
    if [[ "$dry_run" == "true" ]]; then
        echo "ℹ️  [DRY RUN] Would create VERSION file with: $initial_version"
        echo "ℹ️  [DRY RUN] Would create .doh/versions/ directory"
        return 0
    fi
    
    # Create VERSION file
    echo "$initial_version" > "$doh_root/VERSION"
    echo "✅ Created VERSION file with version $initial_version"
    
    # Create versions directory
    mkdir -p "$doh_root/.doh/versions"
    
    # Create initial version milestone file
    cat > "$doh_root/.doh/versions/$initial_version.md" << EOF
---
version: $initial_version
type: initial
created: $(date -u +%Y-%m-%dT%H:%M:%SZ)
migration: true
---

# Version $initial_version - Migration Baseline

Initial version created during DOH versioning system migration.

## Migration Details
- Migration date: $(date)
- Migration tool: doh:version-migrate
- Baseline version for existing project

## Changes
- Added versioning system to existing DOH project
- All existing files preserved with baseline version
EOF
    
    echo "✅ Created initial version milestone file"
}

# @description Update files with version information
# @arg $1 string DOH root directory
# @arg $2 boolean Dry run mode
# @arg $3 string Initial version
# @stdout Update progress
# @stderr Error messages
# @exitcode 0 If successful
_migration_update_files_with_versions() {
    local doh_root="$1"
    local dry_run="$2"
    local initial_version="$3"
    
    echo "ℹ️  Updating files with version information..."
    
    local updated_count=0
    local skipped_count=0
    
    # Find all markdown files in .doh directory
    while IFS= read -r -d '' file; do
        local relative_file="${file#$doh_root/}"
        
        if frontmatter_has "$file"; then
            # Check if file already has version
            if frontmatter_get_field "$file" "file_version" >/dev/null 2>&1; then
                echo "ℹ️  Skipping $relative_file (already has version)"
                ((skipped_count++))
                continue
            fi
            
            if [[ "$dry_run" == "true" ]]; then
                echo "ℹ️  [DRY RUN] Would add file_version to: $relative_file"
                ((updated_count++))
            else
                # Add file_version field to frontmatter
                if frontmatter_update_field "$file" "file_version" "$initial_version"; then
                    echo "✅ Added version to: $relative_file"
                    ((updated_count++))
                else
                    echo "❌ Failed to update: $relative_file"
                fi
            fi
        else
            echo "ℹ️  Skipping $relative_file (no frontmatter)"
            ((skipped_count++))
        fi
    done < <(find "$doh_root/.doh" -name "*.md" -type f -print0)
    
    echo "ℹ️  File update summary: $updated_count updated, $skipped_count skipped"
}

# @description Import version history from git tags
# @arg $1 string DOH root directory
# @arg $2 boolean Dry run mode
# @stdout Import progress
# @stderr Error messages
_migration_import_git_history() {
    local doh_root="$1"
    local dry_run="$2"
    
    echo "ℹ️  Importing version history from git tags..."
    
    if [[ ! -d "$doh_root/.git" ]]; then
        echo "⚠️  No git repository found, skipping history import"
        return 0
    fi
    
    # Get git tags that look like version numbers
    local version_tags
    version_tags=$(git -C "$doh_root" tag -l | grep -E '^v?[0-9]+\.[0-9]+\.[0-9]+' | sort -V)
    
    if [[ -z "$version_tags" ]]; then
        echo "⚠️  No version tags found in git history"
        return 0
    fi
    
    echo "ℹ️  Found version tags: $(echo "$version_tags" | tr '\n' ' ')"
    
    if [[ "$dry_run" == "true" ]]; then
        echo "ℹ️  [DRY RUN] Would create version files for git tags"
        return 0
    fi
    
    # Create version files for each tag
    while IFS= read -r tag; do
        # Clean version number (remove 'v' prefix if present)
        local version="${tag#v}"
        
        if version_validate "$version"; then
            # Get tag information
            local tag_date
            tag_date=$(git -C "$doh_root" log -1 --format=%ai "$tag" 2>/dev/null)
            local tag_message
            tag_message=$(git -C "$doh_root" tag -l -n1 "$tag" | cut -d' ' -f2-)
            
            # Create version file
            cat > "$doh_root/.doh/versions/$version.md" << EOF
---
version: $version
type: release
created: $(date -d "$tag_date" -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u +%Y-%m-%dT%H:%M:%SZ)
git_tag: $tag
imported: true
---

# Version $version

$(if [[ -n "$tag_message" ]]; then echo "$tag_message"; else echo "Release version $version"; fi)

## Import Details
- Imported from git tag: \`$tag\`
- Original tag date: $tag_date
- Migration tool: doh:version-migrate
EOF
            
            echo "✅ Created version file for $version"
        else
            echo "⚠️  Skipping invalid version tag: $tag"
        fi
    done <<< "$version_tags"
}

# @description Validate migration results
# @arg $1 string DOH root directory
# @arg $2 string Initial version
# @stdout Validation results
# @stderr Error messages
# @exitcode 0 If valid
# @exitcode 1 If invalid
_migration_validate_migration() {
    local doh_root="$1"
    local initial_version="$2"
    
    echo "ℹ️  Validating migration results..."
    
    local validation_errors=()
    
    # Check VERSION file
    if [[ ! -f "$doh_root/VERSION" ]]; then
        validation_errors+=("VERSION file missing")
    else
        local version
        version=$(cat "$doh_root/VERSION")
        if ! version_validate "$version"; then
            validation_errors+=("Invalid version in VERSION file: $version")
        fi
    fi
    
    # Check versions directory
    if [[ ! -d "$doh_root/.doh/versions" ]]; then
        validation_errors+=(".doh/versions directory missing")
    fi
    
    # Check initial version file
    if [[ ! -f "$doh_root/.doh/versions/$initial_version.md" ]]; then
        validation_errors+=("Initial version milestone file missing")
    fi
    
    # Validate file versions
    local files_missing_version=0
    while IFS= read -r -d '' file; do
        if frontmatter_has "$file"; then
            if ! frontmatter_get_field "$file" "file_version" >/dev/null 2>&1; then
                ((files_missing_version++))
            fi
        fi
    done < <(find "$doh_root/.doh" -name "*.md" -type f -print0)
    
    if [[ $files_missing_version -gt 0 ]]; then
        validation_errors+=("$files_missing_version files missing version field")
    fi
    
    # Report validation results
    if [[ ${#validation_errors[@]} -eq 0 ]]; then
        echo "✅ Migration validation passed"
        return 0
    else
        echo "❌ Migration validation failed:" >&2
        printf '   • %s\n' "${validation_errors[@]}"
        return 1
    fi
}

# @description Generate migration report
# @arg $1 string DOH root directory
# @arg $2 boolean Dry run mode
# @arg $3 string Initial version
# @arg $4 string Backup location
# @stdout Migration report
_migration_generate_report() {
    local doh_root="$1"
    local dry_run="$2"
    local initial_version="$3"
    local backup_location="$4"
    
    echo ""
    echo "📋 Migration Report"
    echo "=================="
    echo ""
    echo "Project: $doh_root"
    echo "Migration Date: $(date)"
    echo "Initial Version: $initial_version"
    echo "Backup Location: $backup_location"
    echo ""
    echo "Summary:"
    
    if [[ "$dry_run" == "true" ]]; then
        echo "• DRY RUN - No actual changes made"
    else
        echo "• Version system successfully initialized"
        echo "• VERSION file created with version $initial_version"
        echo "• Version milestone files created"
        echo "• Existing files updated with version information"
    fi
    
    echo ""
    echo "Next Steps:"
    echo "• Use '/doh:version-status' to check version system status"
    echo "• Use '/doh:version-validate' to verify consistency"
    echo "• Use '/doh:version-bump' to increment versions"
    echo "• Review created version files in .doh/versions/"
    
    if [[ "$dry_run" != "true" ]]; then
        echo ""
        echo "Rollback Instructions:"
        echo "• Use '/doh:version-migrate --rollback' to undo changes"
        echo "• Or restore from backup: $backup_location"
    fi
}

# @description Rollback previous migration
# @arg $1 string DOH root directory
# @stdout Rollback progress
# @stderr Error messages
# @exitcode 0 If successful
_migration_rollback_migration() {
    local doh_root="$1"
    
    local last_backup_file="$doh_root/.doh/last_backup.txt"
    local backup_location
    
    if [[ -f "$last_backup_file" ]]; then
        backup_location=$(cat "$last_backup_file")
    else
        # Look for most recent backup
        backup_location=$(find "$doh_root" -maxdepth 1 -name "${BACKUP_PREFIX}*" -type d | sort | tail -1)
    fi
    
    if [[ -z "$backup_location" || ! -d "$backup_location" ]]; then
        echo "❌ No backup found for rollback" >&2
        return 1
    fi
    
    echo "ℹ️  Rolling back from backup: $backup_location"
    
    # Remove VERSION file
    [[ -f "$doh_root/VERSION" ]] && rm "$doh_root/VERSION"
    
    # Restore .doh directory
    if [[ -d "$backup_location/.doh" ]]; then
        rm -rf "$doh_root/.doh"
        cp -r "$backup_location/.doh" "$doh_root/"
    fi
    
    # Restore VERSION file if it existed
    [[ -f "$backup_location/VERSION" ]] && cp "$backup_location/VERSION" "$doh_root/"
    
    echo "✅ Migration rolled back successfully"
    rm -f "$last_backup_file"
}

# @description Interactive migration workflow
# @arg $1 string DOH root directory
# @stdout Interactive prompts and results
# @stderr Error messages
# @exitcode 0 If successful
_migration_interactive_migration() {
    local doh_root="$1"
    
    echo "🚀 DOH Interactive Version Migration"
    echo "===================================="
    echo ""
    
    # Run analysis first
    _migration_analyze_project "$doh_root" "false" || return 1
    
    echo "Would you like to proceed with migration? (y/N): "
    read -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "ℹ️  Migration cancelled by user"
        return 0
    fi
    
    # Ask about git import
    local from_git=false
    if [[ -d "$doh_root/.git" ]]; then
        echo "Import version history from git tags? (y/N): "
        read -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            from_git=true
        fi
    fi
    
    # Ask about initial version
    local initial_version="0.1.0"
    echo "Initial version (current: $initial_version): "
    read -r version_input
    if [[ -n "$version_input" ]]; then
        if version_validate "$version_input"; then
            initial_version="$version_input"
        else
            echo "❌ Invalid version format, using default: $initial_version"
        fi
    fi
    
    # Proceed with migration
    _migration_perform_migration "$doh_root" "false" "$from_git" "$initial_version" "false"
}
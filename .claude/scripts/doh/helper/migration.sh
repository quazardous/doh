#!/bin/bash

# DOH Migration Helper
# Helper for DOH project migration operations

# Source core library dependencies
source "$(dirname "${BASH_SOURCE[0]}")/../lib/doh.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/version.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/frontmatter.sh"

# Constants
readonly BACKUP_PREFIX=".doh_backup_"

# @description Perform DOH version migration with specified options
# @arg $1 string Options string (comma-separated flags)
# @stdout Migration progress and results
# @stderr Error messages
# @exitcode 0 If migration successful
# @exitcode 1 If migration failed
helper_migration_migrate_version() {
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
    
    local project_root
    project_root=$(doh_project_root) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }
    
    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }

    # Initialize logging
    local migration_log_file="$doh_dir/migration.log"
    mkdir -p "$(dirname "$migration_log_file")"
    echo "=== DOH Version Migration - $(date) ===" > "$migration_log_file"
    
    if [[ "$rollback" == "true" ]]; then
        _helper_migration_rollback_migration "$project_root" "$doh_dir"
        return $?
    fi
    
    if [[ "$analyze_only" == "true" ]]; then
        _helper_migration_analyze_project "$project_root" "$doh_dir" "$from_git"
        return $?
    fi
    
    if [[ "$interactive" == "true" ]]; then
        _helper_migration_interactive_migration "$project_root" "$doh_dir"
        return $?
    fi
    
    # Standard migration
    _helper_migration_perform_migration "$project_root" "$doh_dir" "$dry_run" "$from_git" "$initial_version" "$deduplicate"
}

# @description Analyze project for migration readiness
# @arg $1 string Project root directory
# @arg $2 string DOH directory
# @arg $3 boolean Whether to analyze git history
# @stdout Analysis report
# @stderr Error messages
# @exitcode 0 If analysis successful
# @exitcode 1 If not a valid DOH project
_helper_migration_analyze_project() {
    local project_root="$1"
    local doh_dir="$2"
    local from_git="$3"
    
    echo "📊 Migration Analysis Report"
    echo "============================"
    echo ""
    
    # Check if versioning already enabled
    local version_file
    version_file="$(doh_version_file)" && [[ -f "$version_file" ]] && {
        echo "⚠️  VERSION file already exists ($(cat "$version_file"))"
        echo "   Project already has versioning enabled"
    } || {
        echo "✅ No VERSION file found - ready for migration"
    }
    
    # Check .doh structure
    if [[ -d "$doh_dir" ]]; then
        echo "✅ DOH project structure detected"
        
        # Count files that need version migration
        local md_files
        md_files=$(find "$doh_dir" -name "*.md" -type f | wc -l)
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
        done < <(find "$doh_dir" -name "*.md" -type f -print0)
        
        echo "📋 $files_with_frontmatter files have frontmatter"
        echo "🔄 $files_needing_version files need version field"
    else
        echo "❌ No .doh directory found - not a DOH project"
        return 1
    fi
    
    # Check git history if requested
    if [[ "$from_git" == "true" ]]; then
        if [[ -d "$project_root/.git" ]]; then
            local git_tags
            git_tags=$(git -C "$project_root" tag -l | wc -l)
            echo "🏷️  Found $git_tags git tags for version history"
        else
            echo "⚠️  No git repository found for history import"
        fi
    fi
    
    echo ""
    echo "💡 Recommendations:"
    local version_file
    version_file="$(doh_version_file)" && [[ -f "$version_file" ]] && {
        echo "   • Use --rollback to remove existing versioning first"
        echo "   • Or continue with current version system"
    } || {
        echo "   • Project is ready for version migration"
        echo "   • Use --dry-run to see planned changes"
        echo "   • Use --interactive for guided migration"
    }
}

# @description Perform the actual migration
# @arg $1 string Project root directory
# @arg $2 string DOH directory  
# @arg $3 boolean Dry run mode
# @arg $4 boolean Import git history
# @arg $5 string Initial version
# @arg $6 boolean Include deduplication
# @stdout Migration progress
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If failed
_helper_migration_perform_migration() {
    local project_root="$1"
    local doh_dir="$2"
    local dry_run="$3"
    local from_git="$4"
    local initial_version="$5"
    local deduplicate="$6"
    
    echo "🚀 Starting DOH version migration..."
    
    # Create backup
    local backup_location
    backup_location=$(_helper_migration_create_backup "$project_root" "$doh_dir" "$dry_run") || return 1
    
    # Initialize version system
    _helper_migration_initialize_version_system "$project_root" "$doh_dir" "$dry_run" "$initial_version" || return 1
    
    # Import git history if requested
    if [[ "$from_git" == "true" ]]; then
        _helper_migration_import_git_history "$project_root" "$doh_dir" "$dry_run"
    fi
    
    # Update files with versions
    _helper_migration_update_files_with_versions "$doh_dir" "$dry_run" "$initial_version" || return 1
    
    # Validate migration
    if [[ "$dry_run" != "true" ]]; then
        _helper_migration_validate_migration "$project_root" "$doh_dir" "$initial_version" || return 1
    fi
    
    # Generate report
    _helper_migration_generate_report "$project_root" "$dry_run" "$initial_version" "$backup_location"
    
    echo "✅ Migration completed successfully!"
}

# @description Create backup of current state
# @arg $1 string Project root directory
# @arg $2 string DOH directory
# @arg $3 boolean Dry run mode
# @stdout Backup location
# @stderr Error messages
# @exitcode 0 If successful
_helper_migration_create_backup() {
    local project_root="$1"
    local doh_dir="$2"
    local dry_run="$3"
    
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_location="$project_root/${BACKUP_PREFIX}$timestamp"
    
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
    local version_file
    version_file="$(doh_version_file)" && [[ -f "$version_file" ]] && cp "$version_file" "$backup_location/"
    
    # Backup .doh directory
    if [[ -d "$doh_dir" ]]; then
        cp -r "$doh_dir" "$backup_location/"
    fi
    
    echo "✅ Backup created successfully"
    echo "$backup_location" > "$doh_dir/last_backup.txt"
    echo "$backup_location"
}

# @description Initialize version system
# @arg $1 string Project root directory
# @arg $2 string DOH directory
# @arg $3 boolean Dry run mode
# @arg $4 string Initial version
# @stdout Initialization progress
# @stderr Error messages
# @exitcode 0 If successful
_helper_migration_initialize_version_system() {
    local project_root="$1"
    local doh_dir="$2"
    local dry_run="$3"
    local initial_version="$4"
    
    echo "ℹ️  Initializing version system..."
    
    if [[ "$dry_run" == "true" ]]; then
        echo "ℹ️  [DRY RUN] Would create VERSION file with: $initial_version"
        echo "ℹ️  [DRY RUN] Would create versions/ directory"
        return 0
    fi
    
    # Create VERSION file
    local version_file
    version_file="$(doh_version_file)"
    echo "$initial_version" > "$version_file"
    echo "✅ Created VERSION file with version $initial_version"
    
    # Create versions directory
    mkdir -p "$doh_dir/versions"
    
    # Create initial version milestone file using centralized function
    local description="Initial version created during DOH versioning system migration.

## Migration Details
- Migration date: $(date)
- Migration tool: doh:version-migrate
- Baseline version for existing project"
    
    version_create "$doh_dir/versions/$initial_version.md" "$initial_version" "initial" "$description"
    
    echo "✅ Created initial version milestone file"
}

# @description Update files with version information
# @arg $1 string DOH directory
# @arg $2 boolean Dry run mode
# @arg $3 string Initial version
# @stdout Update progress
# @stderr Error messages
# @exitcode 0 If successful
_helper_migration_update_files_with_versions() {
    local doh_dir="$1"
    local dry_run="$2"
    local initial_version="$3"
    
    echo "ℹ️  Updating files with version information..."
    
    local updated_count=0
    local skipped_count=0
    
    # Find all markdown files in .doh directory
    while IFS= read -r -d '' file; do
        local relative_file
        relative_file=$(realpath --relative-to="$(doh_project_dir)" "$file")
        
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
    done < <(find "$doh_dir" -name "*.md" -type f -print0)
    
    echo "ℹ️  File update summary: $updated_count updated, $skipped_count skipped"
}

# @description Import version history from git tags
# @arg $1 string Project root directory
# @arg $2 string DOH directory
# @arg $3 boolean Dry run mode
# @stdout Import progress
# @stderr Error messages
_helper_migration_import_git_history() {
    local project_root="$1"
    local doh_dir="$2"
    local dry_run="$3"
    
    echo "ℹ️  Importing version history from git tags..."
    
    if [[ ! -d "$project_root/.git" ]]; then
        echo "⚠️  No git repository found, skipping history import"
        return 0
    fi
    
    # Get git tags that look like version numbers
    local version_tags
    version_tags=$(git -C "$project_root" tag -l | grep -E '^v?[0-9]+\.[0-9]+\.[0-9]+' | sort -V)
    
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
            tag_date=$(git -C "$project_root" log -1 --format=%ai "$tag" 2>/dev/null)
            local tag_message
            tag_message=$(git -C "$project_root" tag -l -n1 "$tag" | cut -d' ' -f2-)

            # Create version file using centralized function
            local import_description="$tag_message

## Import Details
- Imported from git tag: \`$tag\`
- Original tag date: $tag_date
- Migration tool: doh:version-migrate"
            
            version_create "$doh_dir/versions/$version.md" "$version" "release" "$import_description" "$tag"
            
            echo "✅ Created version file for $version"
        else
            echo "⚠️  Skipping invalid version tag: $tag"
        fi
    done <<< "$version_tags"
}

# @description Validate migration results
# @arg $1 string Project root directory
# @arg $2 string DOH directory
# @arg $3 string Initial version
# @stdout Validation results
# @stderr Error messages
# @exitcode 0 If valid
# @exitcode 1 If invalid
_helper_migration_validate_migration() {
    local project_root="$1"
    local doh_dir="$2"
    local initial_version="$3"
    
    echo "ℹ️  Validating migration results..."
    
    local validation_errors=()
    
    # Check VERSION file
    local version_file
    version_file="$(doh_version_file)"
    if [[ ! -f "$version_file" ]]; then
        validation_errors+=("VERSION file missing")
    else
        local version
        version=$(cat "$version_file")
        if ! version_validate "$version"; then
            validation_errors+=("Invalid version in VERSION file: $version")
        fi
    fi
    
    # Check versions directory
    if [[ ! -d "$doh_dir/versions" ]]; then
        validation_errors+=("versions directory missing")
    fi
    
    # Check initial version file
    if [[ ! -f "$doh_dir/versions/$initial_version.md" ]]; then
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
    done < <(find "$doh_dir" -name "*.md" -type f -print0)
    
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
# @arg $1 string Project root directory
# @arg $2 boolean Dry run mode
# @arg $3 string Initial version
# @arg $4 string Backup location
# @stdout Migration report
_helper_migration_generate_report() {
    local project_root="$1"
    local dry_run="$2"
    local initial_version="$3"
    local backup_location="$4"
    
    echo ""
    echo "📋 Migration Report"
    echo "=================="
    echo ""
    echo "Project: $project_root"
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
    echo "• Review created version files in versions/"
    
    if [[ "$dry_run" != "true" ]]; then
        echo ""
        echo "Rollback Instructions:"
        echo "• Use '/doh:version-migrate --rollback' to undo changes"
        echo "• Or restore from backup: $backup_location"
    fi
}

# @description Rollback previous migration
# @arg $1 string Project root directory
# @arg $2 string DOH directory
# @stdout Rollback progress
# @stderr Error messages
# @exitcode 0 If successful
_helper_migration_rollback_migration() {
    local project_root="$1"
    local doh_dir="$2"
    
    local last_backup_file="$doh_dir/last_backup.txt"
    local backup_location
    
    if [[ -f "$last_backup_file" ]]; then
        backup_location=$(cat "$last_backup_file")
    else
        # Look for most recent backup
        backup_location=$(find "$project_root" -maxdepth 1 -name "${BACKUP_PREFIX}*" -type d | sort | tail -1)
    fi
    
    if [[ -z "$backup_location" || ! -d "$backup_location" ]]; then
        echo "❌ No backup found for rollback" >&2
        return 1
    fi
    
    echo "ℹ️  Rolling back from backup: $backup_location"
    
    # Remove VERSION file
    local version_file
    version_file="$(doh_version_file)" && [[ -f "$version_file" ]] && rm "$version_file"
    
    # Restore .doh directory
    if [[ -d "$backup_location/.doh" ]]; then
        rm -rf "$doh_dir"
        cp -r "$backup_location/.doh" "$doh_dir/"
    fi
    
    # Restore VERSION file if it existed
    [[ -f "$backup_location/VERSION" ]] && cp "$backup_location/VERSION" "$(doh_version_file)"
    
    echo "✅ Migration rolled back successfully"
    rm -f "$last_backup_file"
}

# @description Interactive migration workflow
# @arg $1 string Project root directory
# @arg $2 string DOH directory
# @stdout Interactive prompts and results
# @stderr Error messages
# @exitcode 0 If successful
_helper_migration_interactive_migration() {
    local project_root="$1"
    local doh_dir="$2"
    
    echo "🚀 DOH Interactive Version Migration"
    echo "===================================="
    echo ""
    
    # Run analysis first
    _helper_migration_analyze_project "$project_root" "$doh_dir" "false" || return 1
    
    echo "Would you like to proceed with migration? (y/N): "
    read -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "ℹ️  Migration cancelled by user"
        return 0
    fi
    
    # Ask about git import
    local from_git=false
    if [[ -d "$project_root/.git" ]]; then
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
    _helper_migration_perform_migration "$project_root" "$doh_dir" "false" "$from_git" "$initial_version" "false"
}
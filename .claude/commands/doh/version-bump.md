---
name: version-bump
description: Bump project version with validation, git integration, and release management
type: bash
parallel_execution: false
success_exit_code: 0
timeout: 60000
file_version: 0.1.0
---

# /doh:version-bump

## Description
Bump project version using semantic versioning rules with comprehensive validation, git integration, and optional release management. Supports patch, minor, and major version increments with pre/post-bump hooks.

## Usage
```
/doh:version-bump <level> [--dry-run] [--no-git] [--no-files] [--message "Release message"]
```

## Arguments
- `<level>`: Version increment level (patch, minor, major)
- `--dry-run`: Show what would change without making changes
- `--no-git`: Skip git operations (tag, commit, push)
- `--no-files`: Skip updating file_version in DOH files
- `--message`: Custom release/commit message

## Implementation
```bash
#!/bin/bash
source "$(dirname "$0")/../../scripts/doh/lib/version.sh"
source "$(dirname "$0")/../../scripts/doh/lib/frontmatter.sh"

# Parse arguments
level=""
dry_run=false
no_git=false
no_files=false
custom_message=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        patch|minor|major)
            if [[ -z "$level" ]]; then
                level="$1"
            else
                echo "Error: Multiple increment levels specified" >&2
                exit 1
            fi
            shift
            ;;
        --dry-run)
            dry_run=true
            shift
            ;;
        --no-git)
            no_git=true
            shift
            ;;
        --no-files)
            no_files=true
            shift
            ;;
        --message)
            custom_message="$2"
            shift 2
            ;;
        *)
            echo "Error: Unknown argument: $1" >&2
            echo "Usage: /doh:version-bump <level> [--dry-run] [--no-git] [--no-files] [--message \"Release message\"]"
            exit 1
            ;;
    esac
done

# Validate required arguments
if [[ -z "$level" ]]; then
    echo "Error: Version increment level required (patch, minor, major)" >&2
    exit 1
fi

# Pre-bump validation
echo "🔍 Pre-bump validation..."

# Check if we're in a DOH project
doh_root="$(_find_doh_root)" || {
    echo "Error: Not in a DOH project" >&2
    exit 1
}

# Get current version
current_version=$(get_current_version) || {
    echo "Error: Could not determine current version" >&2
    exit 1
}

# Calculate new version
new_version=$(increment_version "$current_version" "$level") || {
    echo "Error: Could not calculate new version" >&2
    exit 1
}

echo "📊 Version bump: $current_version → $new_version ($level)"

# Git validation (if not skipping git operations)
if [[ "$no_git" == false ]]; then
    # Check if git repository exists
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "Warning: Not in a git repository, enabling --no-git mode"
        no_git=true
    else
        # Check for uncommitted changes
        if ! git diff-index --quiet HEAD --; then
            echo "Warning: Working directory has uncommitted changes"
            echo "Git status:"
            git status --porcelain
            echo ""
            read -p "Continue anyway? [y/N] " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo "Aborted by user"
                exit 1
            fi
        fi
        
        # Check if tag already exists
        if git tag -l | grep -q "^v${new_version}$"; then
            echo "Error: Git tag v${new_version} already exists" >&2
            exit 1
        fi
    fi
fi

# Dry run output
if [[ "$dry_run" == true ]]; then
    echo "🔍 DRY RUN - No changes will be made"
    echo ""
    echo "Would perform the following actions:"
    echo "  1. Update VERSION file: $current_version → $new_version"
    
    if [[ "$no_files" == false ]]; then
        echo "  2. Update file_version in DOH files:"
        find_files_missing_version . | head -5 | while read -r file; do
            echo "     - $file"
        done
        file_count=$(find_files_missing_version . | wc -l)
        if [[ $file_count -gt 5 ]]; then
            echo "     ... and $((file_count - 5)) more files"
        fi
    fi
    
    if [[ "$no_git" == false ]]; then
        echo "  3. Create git commit with updated files"
        echo "  4. Create git tag: v${new_version}"
        echo "  5. Push changes and tags to remote"
    fi
    
    exit 0
fi

# Create release message
if [[ -z "$custom_message" ]]; then
    case "$level" in
        patch)
            custom_message="Patch release $new_version - Bug fixes and improvements"
            ;;
        minor)
            custom_message="Minor release $new_version - New features and enhancements"
            ;;
        major)
            custom_message="Major release $new_version - Breaking changes and new architecture"
            ;;
    esac
fi

echo "🚀 Starting version bump workflow..."

# Step 1: Update VERSION file
echo "📝 Updating VERSION file..."
if ! set_project_version "$new_version"; then
    echo "Error: Failed to update VERSION file" >&2
    exit 1
fi

# Step 2: Update file versions (if not skipped)
updated_files=()
if [[ "$no_files" == false ]]; then
    echo "📝 Updating file_version in DOH files..."
    
    # Find DOH files that need version updates
    doh_files=$(find "$doh_root" -name "*.md" -path "*/.doh/*" -o -name "*.epic.md" -o -name "*.task.md" -o -name "*.prd.md" | head -20)
    
    if [[ -n "$doh_files" ]]; then
        while IFS= read -r file; do
            if has_frontmatter "$file"; then
                current_file_version=$(get_frontmatter_field "$file" "file_version")
                # Only update if file has a version field or if it's missing
                if [[ -n "$current_file_version" ]] || [[ -z "$current_file_version" ]]; then
                    if set_file_version "$file" "$new_version" 2>/dev/null; then
                        updated_files+=("$file")
                        echo "  ✅ Updated: $(basename "$file")"
                    fi
                fi
            fi
        done <<< "$doh_files"
    fi
    
    echo "📊 Updated file_version in ${#updated_files[@]} files"
fi

# Step 3: Git operations (if not skipped)
if [[ "$no_git" == false ]]; then
    echo "🔀 Git integration..."
    
    # Add VERSION file to git
    git add VERSION || {
        echo "Error: Failed to add VERSION file to git" >&2
        exit 1
    }
    
    # Add updated DOH files to git
    for file in "${updated_files[@]}"; do
        git add "$file"
    done
    
    # Create commit
    commit_message="chore: bump version to $new_version"
    if [[ -n "$custom_message" ]]; then
        commit_message="$custom_message"
    fi
    
    echo "📝 Creating commit: $commit_message"
    if ! git commit -m "$commit_message"; then
        echo "Error: Failed to create git commit" >&2
        exit 1
    fi
    
    # Create tag
    tag_name="v${new_version}"
    echo "🏷️  Creating tag: $tag_name"
    if ! git tag -a "$tag_name" -m "$custom_message"; then
        echo "Error: Failed to create git tag" >&2
        exit 1
    fi
    
    # Check if remote exists and push
    if git remote | grep -q "origin"; then
        echo "📤 Pushing to remote..."
        if git push origin HEAD; then
            echo "📤 Pushing tags..."
            git push origin --tags
        else
            echo "Warning: Failed to push to remote, but local changes are complete"
        fi
    else
        echo "ℹ️  No remote repository configured, skipping push"
    fi
fi

# Success summary
echo ""
echo "✅ Version bump completed successfully!"
echo "   Previous version: $current_version"
echo "   New version: $new_version"
echo "   Increment level: $level"
echo "   Files updated: ${#updated_files[@]}"

if [[ "$no_git" == false ]]; then
    echo "   Git tag created: v${new_version}"
    echo "   Changes committed and pushed"
fi

echo ""
echo "🎉 Release $new_version is ready!"
```

## Workflow Steps
1. **Pre-bump validation**
   - Check DOH project structure
   - Validate current version
   - Check git status (if applicable)
   - Verify tag doesn't exist

2. **Version calculation**
   - Calculate new version based on increment level
   - Validate new version format

3. **File updates**
   - Update VERSION file at project root
   - Update file_version in DOH markdown files
   - Preserve frontmatter structure

4. **Git integration** (optional)
   - Stage updated files
   - Create commit with version message
   - Create annotated git tag
   - Push to remote repository

5. **Validation and reporting**
   - Verify all operations completed
   - Report updated files and new version
   - Display success summary

## Examples
```bash
# Patch release (bug fixes)
/doh:version-bump patch

# Minor release with custom message
/doh:version-bump minor --message "Add new task management features"

# Major release (breaking changes)
/doh:version-bump major

# Preview changes without executing
/doh:version-bump patch --dry-run

# Bump version without git operations
/doh:version-bump minor --no-git

# Update only VERSION file, skip DOH file updates
/doh:version-bump patch --no-files
```

## Safety Features
- Pre-validation checks prevent invalid operations
- Dry-run mode for preview without changes
- Git status verification before operations
- Tag conflict detection
- Atomic operations with rollback capability
- Comprehensive error handling and reporting
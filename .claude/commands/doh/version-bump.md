---
name: version-bump
description: Intelligent version bumping with AI analysis, validation, git integration, and release management
type: hybrid
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
/doh:version-bump [level] [options]
```

## Arguments
- `[level]`: Version increment level (patch, minor, major) - optional for analysis mode

## Options
### Analysis Options
- `--analyze`: Enable intelligent analysis mode (default: true when no level specified)
- `--no-analyze`: Skip analysis and perform direct bump (requires level)

### Execution Options
- `--dry-run`: Show what would change without making changes
- `--commit`: Create git commit with changes (default: false)
- `--no-commit`: Explicitly skip git commit (default behavior)
- `--tag`: Create git tag (requires --commit, overrides DOH_TAG_BUMP)
- `--no-tag`: Skip git tag creation (overrides DOH_TAG_BUMP)
- `--no-files`: Skip updating file_version in DOH files
- `--force`: Bypass git staging validation (allow dirty working directory)
- `--message "text"`: Custom commit/tag message

## Configuration
Version bump behavior is controlled by `.doh/env`:
```bash
# Create git tags during version bumps (default: false)
DOH_TAG_BUMP=false
```

## Examples

### Analysis Mode (AI-powered)
```bash
# Auto-analyze and suggest appropriate bump type
/doh:version-bump                    # Analyzes completed tasks → suggests patch/minor/major

# Analyze specific bump for coherence
/doh:version-bump patch --analyze    # Checks if patch is appropriate for current changes
/doh:version-bump minor              # Auto-analysis enabled by default

# Analysis-only (no execution)
/doh:version-bump --dry-run          # Shows analysis + what bump would do
```

### Direct Script Mode (traditional)
```bash
# Bypass analysis - direct bump
/doh:version-bump patch --no-analyze

# Combined with other options
/doh:version-bump minor --no-analyze --commit --tag
```

### Full Workflow Examples
```bash
# Interactive workflow: analyze → confirm → execute
/doh:version-bump                    # 1. Shows analysis
/doh:version-bump minor --commit     # 2. Execute recommended bump

# One-shot release with validation
/doh:version-bump minor --commit --tag --analyze

# Force release without analysis
/doh:version-bump patch --no-analyze --commit --force
```

## Validation Rules
- **Clean staging required**: Command fails if git working directory is dirty (unless --force)
- **No tag without commit**: Cannot use --tag without --commit (fails with error)
- **Config override**: --tag/--no-tag override DOH_TAG_BUMP setting
- **Default behavior**: Files-only update (no commit, no git operations)

## Implementation
**Cache Optimization**: Only updates cache for the specific version being bumped and its immediate dependents

```bash
#!/bin/bash
source "$(dirname "$0")/../../scripts/doh/lib/version.sh"
source "$(dirname "$0")/../../scripts/doh/lib/frontmatter.sh"
source "$(dirname "$0")/../../scripts/doh/lib/dohenv.sh"

# Parse arguments
level=""
dry_run=false
do_analyze=""  # empty=auto-detect, true=force analysis, false=skip analysis
do_commit=false
do_tag=""  # empty=use DOH_TAG_BUMP, true=force tag, false=no tag
no_files=false
force_dirty=false
custom_message=""

# Load DOH environment configuration
DOH_TAG_BUMP="${DOH_TAG_BUMP:-false}"

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
        --analyze)
            do_analyze="true"
            shift
            ;;
        --no-analyze)
            do_analyze="false"
            shift
            ;;
        --commit)
            do_commit=true
            shift
            ;;
        --no-commit)
            do_commit=false
            shift
            ;;
        --tag)
            do_tag="true"
            shift
            ;;
        --no-tag)
            do_tag="false"
            shift
            ;;
        --no-files)
            no_files=true
            shift
            ;;
        --force)
            force_dirty=true
            shift
            ;;
        --message)
            custom_message="$2"
            shift 2
            ;;
        *)
            echo "Error: Unknown argument: $1" >&2
            echo "Usage: /doh:version-bump [level] [--analyze] [--no-analyze] [--commit] [--tag] [--no-tag] [--no-files] [--force] [--message \"text\"]"
            exit 1
            ;;
    esac
done

# Determine analysis mode
if [[ -z "$do_analyze" ]]; then
    # Auto-detect: analyze if no level provided, or if level provided with analysis intent
    if [[ -z "$level" ]]; then
        do_analyze="true"  # No level = analysis mode
    else
        do_analyze="true"  # Level provided = validation mode (analyze + execute)
    fi
fi

# Validate arguments based on mode
if [[ "$do_analyze" == "false" && -z "$level" ]]; then
    echo "Error: --no-analyze requires a version level (patch, minor, major)" >&2
    echo "Use: /doh:version-bump <level> --no-analyze" >&2
    exit 1
fi

# Determine final tag behavior
final_do_tag="$DOH_TAG_BUMP"
if [[ -n "$do_tag" ]]; then
    final_do_tag="$do_tag"
fi

# Validate commit/tag logic
if [[ "$do_commit" == false && "$final_do_tag" == "true" ]]; then
    echo "Error: Cannot create git tag without commit. Use --commit with --tag or set --no-tag" >&2
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

# Git validation (if committing or tagging)
if [[ "$do_commit" == true || "$final_do_tag" == "true" ]]; then
    # Check if git repository exists
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "Error: Not in a git repository but --commit or --tag requested" >&2
        echo "Either initialize git or use --no-commit --no-tag" >&2
        exit 1
    fi
    
    # Strict staging validation - fail if dirty unless --force
    if ! git diff-index --quiet HEAD --; then
        echo "Error: Working directory has uncommitted changes" >&2
        echo "Git status:"
        git status --porcelain
        echo ""
        
        if [[ "$force_dirty" == true ]]; then
            echo "⚠️  --force specified, continuing with dirty working directory"
        else
            echo "Solutions:"
            echo "  1. Commit or stash changes: git add . && git commit -m 'prep for version bump'"
            echo "  2. Use --force to bypass this check"
            echo "  3. Use --no-commit --no-tag for files-only bump"
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

## AI Analysis Implementation

When analysis mode is enabled (`--analyze` or default behavior), the AI component will:

### 1. Task Completion Analysis
- Scan all completed tasks since last version
- Categorize changes by type:
  - **Bug fixes** → suggest `patch`
  - **New features** → suggest `minor`  
  - **Breaking changes** → suggest `major`
- Check for epic completions and milestones

### 2. Version Validation (when level specified)
- Verify the proposed bump level matches completed work
- Check if version milestone conditions are met
- Analyze task dependencies and completion status
- Warn about potential issues or suggest alternatives

### 3. Analysis Output Format
```
🔍 DOH Version Analysis
=======================
Current Version: 0.5.0
Analyzed Period: Since 2025-09-01 (last version)

📊 Completed Work Analysis:
✅ Bug Fixes (3 tasks):
  - Task 015: Fix authentication timeout
  - Task 018: Resolve memory leak in cache
  - Task 021: Fix version parsing edge case

✅ New Features (1 task):
  - Task 022: Add AI-powered version analysis

🎯 Recommended Bump: MINOR (0.5.0 → 0.6.0)
Reason: New feature addition with backward compatibility

⚠️  Version Readiness Check:
- Version 0.6.0 milestone: 4/5 tasks complete (80%)
- Blocking task: Task 019 (in_progress)
- Estimated readiness: 3-5 days

💡 Recommendations:
1. Complete Task 019 before release
2. Consider patch release (0.5.1) for bug fixes now
3. Wait for minor release (0.6.0) when Task 019 complete
```

### 4. Interactive Confirmation
For analysis-only mode, the AI will:
- Present the analysis
- Show recommended command to execute
- Allow user to decide on timing and approach

### 5. Validation Mode
When level is specified with analysis:
- Compare specified level with AI recommendation
- Show warnings if mismatch detected
- Provide reasoning for alternative suggestions
- Allow override with explicit confirmation

## Safety Features
- Pre-validation checks prevent invalid operations
- AI analysis prevents inappropriate version bumps
- Dry-run mode for preview without changes
- Git status verification before operations
- Tag conflict detection
- Atomic operations with rollback capability
- Comprehensive error handling and reporting
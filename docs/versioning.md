---
title: DOH Versioning System - Complete Guide
file_version: 0.1.0
created: 2025-09-01T22:30:00Z
updated: 2025-09-01T22:30:00Z
---

# DOH Versioning System

Complete guide to DOH's semantic versioning system with AI-powered version management, milestone tracking, and automated release workflows.

## Table of Contents
- [Quick Start](#quick-start)
- [Overview](#overview) 
- [Version Commands](#version-commands)
- [Version Files](#version-files)
- [Milestone System](#milestone-system)
- [Version Bump Workflow](#version-bump-workflow)
- [Graph Cache Integration](#graph-cache-integration)
- [API Reference](#api-reference)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Quick Start

1. **Check current version status:**
   ```bash
   /doh:version-status
   ```

2. **Create a new version:**
   ```bash
   /doh:version-new 1.1.0 "Feature release with new capabilities"
   ```

3. **Validate version readiness:**
   ```bash
   /doh:version-validate 1.1.0
   ```

4. **Bump to new version:**
   ```bash
   /doh:version-bump minor --message "Release 1.1.0"
   ```

## Overview

DOH's versioning system provides:

- **Semantic Versioning** - MAJOR.MINOR.PATCH format with validation
- **AI-Powered Commands** - Intelligent version management and analysis
- **Milestone Tracking** - Automatic progress monitoring and release readiness
- **Graph Cache Integration** - Performance-optimized relationship tracking
- **Git Integration** - Automated tagging, commits, and releases

### Architecture

```
VERSION file (project root) ← Current version
    ↓
.doh/versions/*.md ← Version plans and milestones
    ↓
AI Commands ← Parse requirements, check progress
    ↓
Graph Cache ← Optimized relationship storage
    ↓
Bash Scripts ← Fast synchronization and automation
```

## Version Commands

### Status and Information

#### `/doh:version-status`
Display current version and progress toward planned releases.

```bash
/doh:version-status
```

**Output:**
```
DOH Version Status
==================
Current Version: 0.1.0
Next Version: 0.2.0 (planned)

Version 0.2.0 Progress:
-----------------------
Target Release: TBD
Overall Progress: 60%

✅ Completed (2):
  - Task 022: AI-powered version planning commands
  - Task 023: Update prd-edit with AI version matching

⏳ In Progress (1):
  - Task 009: Version management commands
```

#### `/doh:version-list`
List all available versions with status.

#### `/doh:version-show <version>`
Display detailed information about a specific version.

### Version Validation

#### `/doh:version-validate [version]`
Check if version milestone conditions are met.

```bash
# Validate specific version
/doh:version-validate 1.0.0

# Validate all planned versions
/doh:version-validate
```

**Output:**
```
Version 1.0.0 Validation:
-------------------------
❌ NOT READY (4/7 tasks completed - 57%)

Required Tasks (4/7 completed):
✅ Task 005: Create frontmatter integration
✅ Task 006: Version bump workflow implementation  
❌ Task 007: Version milestone conditions and auto-bump
❌ Task 008: Version dependencies in task graph

Blocking Items:
- Complete remaining versioning tasks (007, 008)
- Finish versioning epic
```

### Version Management

#### `/doh:version-new <version> <description>`
Create a new version file with AI assistance.

```bash
/doh:version-new 2.0.0 "Major release with breaking changes"
```

#### `/doh:version-edit <version>`
Edit existing version with AI assistance.

#### `/doh:version-delete <version>`
Remove a version (with safety checks).

### Version Bumping

#### `/doh:version-bump <level> [options]`
Bump project version with comprehensive workflow.

```bash
# Basic version bump
/doh:version-bump patch
/doh:version-bump minor
/doh:version-bump major

# With options
/doh:version-bump minor --dry-run
/doh:version-bump patch --no-git --message "Bug fixes"
```

**Options:**
- `--dry-run` - Show what would change without executing
- `--no-git` - Skip git operations (tag, commit, push)
- `--no-files` - Skip updating file_version in DOH files
- `--message "text"` - Custom commit/release message

### Dependency Analysis

#### `/doh:version-graph [version]`
Display version dependency relationships.

```bash
# Single version analysis
/doh:version-graph 1.0.0

# Complete dependency tree
/doh:version-graph --all

# Task impact analysis
/doh:version-graph --task 005
```

#### `/doh:task-versions <task_number>`
Show version impact of a specific task.

```bash
/doh:task-versions 005
```

## Version Files

Version files are stored in `.doh/versions/{version}.md` with structured frontmatter and milestone conditions.

### File Structure

```markdown
---
version: 1.1.0
status: planned
release_date: TBD
type: minor
file_version: 0.1.0
---

# Version 1.1.0 - Feature Release

## Overview
Description of this version and its goals.

## Release Conditions
This version will be automatically proposed when ALL conditions are met:

### Required Tasks
- [ ] 008 - Version dependencies in task graph
- [ ] 009 - Version management commands

### Required Epics
- [ ] versioning - Complete versioning system

### Quality Gates
- [ ] All tests passing
- [ ] Documentation complete
- [ ] No critical bugs

## Features Included
- Feature A: Description
- Feature B: Description

## Breaking Changes
None for minor releases.

## Migration Guide
Steps for users to adopt this version.
```

### Frontmatter Fields

- `version` - Semantic version number (required)
- `status` - planned | in-progress | ready | released
- `release_date` - Target or actual release date
- `type` - patch | minor | major
- `file_version` - DOH file version for tracking

### Release Conditions

**Required Tasks** - Must be completed before release
```markdown
- [ ] 005 - Create frontmatter integration
- [ ] 006 - Version bump workflow
```

**Required Epics** - Epics that must be finished
```markdown
- [ ] versioning - Complete versioning system
```

**Quality Gates** - Non-task requirements
```markdown
- [ ] All tests passing
- [ ] Documentation complete
- [ ] No critical bugs
```

## Milestone System

The milestone system automatically tracks progress and proposes version bumps when conditions are met.

### How It Works

1. **AI Commands Parse Milestones** - Version commands read and analyze version files
2. **Task Status Tracking** - Real-time monitoring of task completion
3. **Progress Calculation** - Automatic percentage calculations
4. **Release Proposals** - Notifications when versions are ready
5. **Graph Cache Updates** - Performance optimization for scripts

### Milestone Types

**Sequential Milestones** - Must complete in order
```markdown
### Required Tasks
- [x] 005 - Foundation work
- [ ] 006 - Build on foundation  
- [ ] 007 - Final integration
```

**Parallel Milestones** - Can work simultaneously
```markdown
### Required Tasks
- [ ] 008 - Independent feature A
- [ ] 009 - Independent feature B
```

**Quality Gates** - Non-task requirements
```markdown
### Quality Gates
- [ ] 95% test coverage achieved
- [ ] Performance benchmarks met
- [ ] Security audit completed
```

## Version Bump Workflow

Complete workflow for releasing new versions.

### 1. Pre-Bump Validation

```bash
# Check readiness
/doh:version-validate 1.1.0

# Preview changes
/doh:version-bump minor --dry-run
```

### 2. Execute Bump

```bash
/doh:version-bump minor --message "Release 1.1.0 - New features"
```

**Automatic Steps:**
1. Validate current version and calculate new version
2. Check git status and working directory
3. Update VERSION file at project root
4. Update file_version in DOH markdown files (optional)
5. Create git commit with version changes
6. Create annotated git tag
7. Push changes and tags to remote

### 3. Post-Release Actions

- GitHub release creation (if configured)
- Notification to team
- Documentation updates
- Version file status updates

### Safety Features

- **Pre-validation checks** prevent invalid operations
- **Dry-run mode** previews changes without execution
- **Git status verification** ensures clean working directory
- **Tag conflict detection** prevents duplicate version tags
- **Atomic operations** with rollback capability

## Graph Cache Integration

The versioning system uses an intelligent graph cache for performance optimization.

### Cache Structure

```json
{
  "relationships": {
    "005": {
      "parent": "003",
      "epic": "versioning"
    }
  },
  "versions": {
    "1.0.0": {
      "required_tasks": ["005", "006", "007"],
      "required_epics": ["versioning"],
      "completion_percentage": 67,
      "last_updated": "2025-09-01T22:00:00Z"
    }
  }
}
```

### Smart Caching Strategy

**Selective Updates** - Only cache versions relevant to current operations
```bash
# Only processes v3.0.0 + dependencies
/doh:version-graph 3.0.0

# Only processes versions referencing task 005
/doh:task-versions 005
```

**Auto-Population** - AI commands automatically maintain cache
- No manual cache management required
- Real-time updates during version operations
- Optimized for script consumption

## API Reference

### Version Library Functions (`version.sh`)

#### Core Functions

**`get_current_version()`**
```bash
# Get current project version from VERSION file
version=$(get_current_version)
echo "Current: $version"  # Output: "Current: 0.1.0"
```

**`get_file_version(file)`**
```bash
# Get version from DOH file frontmatter
version=$(get_file_version ".doh/epics/versioning/epic.md")
echo "File version: $version"
```

**`set_file_version(file, version)`**
```bash
# Update file_version in frontmatter
set_file_version ".doh/epics/test/task.md" "1.1.0"
```

**`increment_version(current, level)`**
```bash
# Calculate next version
new_version=$(increment_version "1.0.0" "minor")
echo "$new_version"  # Output: "1.1.0"
```

**`validate_version(version)`**
```bash
# Check if version is valid semver
if validate_version "1.0.0"; then
    echo "Valid version"
fi
```

#### Project Version Management

**`set_project_version(version, [--quiet])`**
```bash
# Update VERSION file
set_project_version "1.1.0"
set_project_version "1.1.0" --quiet  # No output
```

**`bump_project_version(level)`**
```bash
# Bump and return new version
new_version=$(bump_project_version "patch")
echo "Bumped to: $new_version"
```

**`bump_file_version(file, level)`**
```bash
# Bump specific file version
new_version=$(bump_file_version "task.md" "minor")
```

#### Version Analysis

**`compare_versions(ver1, ver2)`**
```bash
# Compare two versions (returns 0=equal, 1=ver1>ver2, 2=ver1<ver2)
if compare_versions "1.1.0" "1.0.0"; then
    echo "Versions equal"
elif [[ $? -eq 1 ]]; then
    echo "1.1.0 is greater"
else
    echo "1.1.0 is less"
fi
```

**`find_files_missing_version([directory])`**
```bash
# Find DOH files without file_version
missing_files=$(find_files_missing_version)
echo "$missing_files"
```

### Graph Cache Functions (`graph-cache.sh`)

#### Version Cache Management

**`update_version_cache(version, json_data)`**
```bash
# Update cache with version data
version_data='{"required_tasks": ["005", "006"], "completion_percentage": 50}'
update_version_cache "1.0.0" "$version_data"
```

**`get_version_cache(version)`**
```bash
# Retrieve version data
version_data=$(get_version_cache "1.0.0")
echo "$version_data" | jq '.required_tasks'
```

**`get_version_blocking_tasks(version)`**
```bash
# Get tasks blocking a version
tasks=$(get_version_blocking_tasks "1.0.0")
while IFS= read -r task; do
    echo "Task $task blocks v1.0.0"
done <<< "$tasks"
```

**`get_task_versions(task_number)`**
```bash
# Get versions affected by a task
versions=$(get_task_versions "005")
echo "Task 005 affects: $versions"
```

#### Selective Syncing

**`sync_specific_versions(version1, version2, ...)`**
```bash
# Update cache for specific versions only
sync_specific_versions "1.0.0" "2.0.0"
```

**`find_versions_for_task(task_number)`**
```bash
# Find which versions reference a task
affected_versions=$(find_versions_for_task "005")
echo "Task 005 affects versions: $affected_versions"
```

### Error Codes

| Code | Meaning | Common Causes |
|------|---------|---------------|
| 0 | Success | Operation completed |
| 1 | General error | Invalid parameters, file not found |
| 2 | Version comparison | Used by `compare_versions()` |

## Best Practices

### Version Planning

**1. Create Meaningful Milestones**
```markdown
### Required Tasks
- [ ] 005 - Core foundation (enables all other work)
- [ ] 006 - User interface (depends on 005)
- [ ] 007 - Integration testing (depends on 005, 006)
```

**2. Use Quality Gates for Non-Task Requirements**
```markdown
### Quality Gates
- [ ] Performance benchmarks met (>95% of baseline)
- [ ] Security audit completed with no high-risk issues
- [ ] Documentation coverage >90%
```

**3. Plan Breaking Changes Carefully**
```markdown
## Breaking Changes
- API endpoint `/v1/data` removed → use `/v2/data`
- Config format changed → see migration guide below

## Migration Guide
1. Update API calls: find/replace `/v1/data` → `/v2/data`
2. Convert config: run `doh migrate-config`
```

### Semantic Versioning Guidelines

**Patch Versions (X.Y.Z+1)**
- Bug fixes
- Performance improvements
- Documentation updates
- Internal refactoring

```bash
/doh:version-bump patch --message "Fix memory leak in task processor"
```

**Minor Versions (X.Y+1.0)**
- New features (backwards compatible)
- New commands or options
- Enhanced functionality

```bash
/doh:version-bump minor --message "Add AI-powered version planning"
```

**Major Versions (X+1.0.0)**
- Breaking changes
- API changes
- Architecture overhauls

```bash
/doh:version-bump major --message "Complete versioning system rewrite"
```

### Release Workflow

**1. Feature Development**
```bash
# Work on tasks targeting version
git checkout feature/new-versioning
# ... implement features ...
# Complete tasks, update status to closed
```

**2. Version Readiness Check**
```bash
# Validate version is ready
/doh:version-validate 1.1.0

# If not ready, check blocking items
/doh:version-graph 1.1.0
```

**3. Pre-Release Testing**
```bash
# Run comprehensive tests
./tests/run.sh

# Dry-run the version bump
/doh:version-bump minor --dry-run
```

**4. Execute Release**
```bash
# Bump version with release
/doh:version-bump minor --message "Release 1.1.0 - Enhanced version management"

# Verify release
git log --oneline -5
git tag -l | tail -5
```

### Team Collaboration

**1. Version Planning in PRDs**
- Include target_version in PRD frontmatter
- Link version milestones to business goals
- Regular version planning meetings

**2. Task Assignment**
- Assign tasks to versions during task creation
- Update version files when requirements change
- Track progress with `/doh:version-status`

**3. Release Communication**
- Use version descriptions for release notes
- Share milestone progress with stakeholders
- Document breaking changes early

## Troubleshooting

### Common Issues

**Issue: Version bump fails with "Working directory has uncommitted changes"**
```bash
# Check what's uncommitted
git status

# Either commit changes or use force
git add . && git commit -m "Pre-release cleanup"
/doh:version-bump minor
```

**Issue: Task marked complete but version validation still shows it as blocking**
```bash
# Check task file status
grep "status:" .doh/epics/*/005.md

# Status should be "completed" or "closed"
# If not, update the task file:
# status: completed
```

**Issue: Version file references non-existent tasks**
```bash
# Validate version file references
/doh:version-validate 1.0.0

# Update version file to remove invalid task references
/doh:version-edit 1.0.0
```

### Performance Issues

**Issue: Version commands running slowly**
```bash
# Check graph cache size
ls -la ~/.doh/projects/*/graph_cache.json

# If cache is large, selective operations help:
/doh:version-graph 1.0.0  # Instead of --all
/doh:task-versions 005    # Instead of full scan
```

**Issue: Graph cache out of sync**
```bash
# Force cache rebuild
source .claude/scripts/doh/lib/graph-cache.sh
rebuild_graph_cache
```

### File Format Issues

**Issue: Version file frontmatter invalid**
```yaml
# ❌ Wrong format
version: "1.0.0"  # Don't quote
type: "minor"     # Don't quote

# ✅ Correct format  
version: 1.0.0
type: minor
```

**Issue: Task references not found**
```markdown
# ❌ Wrong format
- [ ] Task 005 - Description

# ✅ Correct format
- [ ] 005 - Description
```

### Error Messages

**"Error: Not in a DOH project"**
- Run commands from DOH project root
- Ensure `.doh/` directory exists

**"Error: VERSION file not found"**
- Create VERSION file: `echo "0.1.0" > VERSION`
- Or run `/doh:version-bump` to create it

**"Error: Invalid semver format"**
- Use X.Y.Z format: `1.0.0` not `v1.0` or `1.0`
- No prefixes or suffixes in basic version

### Debug Mode

Enable verbose output for troubleshooting:
```bash
# For bash functions
set -x
source .claude/scripts/doh/lib/version.sh
get_current_version
set +x

# For AI commands
# AI commands show detailed analysis in their output
/doh:version-validate 1.0.0  # Shows detailed blocking analysis
```

---

## Integration Examples

### CI/CD Integration

**GitHub Actions Example:**
```yaml
name: Release
on:
  workflow_dispatch:
    inputs:
      version_level:
        description: 'Version bump level'
        required: true
        default: 'minor'
        type: choice
        options:
        - patch
        - minor  
        - major

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Validate version readiness
      run: /doh:version-validate
      
    - name: Bump version
      run: /doh:version-bump ${{ github.event.inputs.version_level }}
```

### Git Hooks Integration

**Pre-commit Hook:**
```bash
#!/bin/bash
# .git/hooks/pre-commit

# Check if version files are consistent
if ! /doh:version-validate --quiet; then
    echo "Warning: Version milestones not met"
    exit 1  # Prevent commit
fi
```

---

**Related Documentation:**
- [DOH Data API Reference](../docs/doh-data-api.md) - Internal data manipulation functions
- [DEVELOPMENT.md](../DEVELOPMENT.md) - DOH development overview
- [CLAUDE.md](../CLAUDE.md) - Claude Code project configuration
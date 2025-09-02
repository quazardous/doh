---
name: version-new
description: "Create a new version milestone with AI assistance"
version: 1.0.0
category: versioning
priority: 1
requires_doh: true
author: Claude
created: 2025-09-01
file_version: 0.1.0
---

# DOH Version Creation Command

Create a new semantic version milestone with intelligent planning assistance, release notes generation, and task dependency analysis.

## Usage

```bash
/doh:version-new [version] [options]
```

## Parameters

- `version` (optional) - Semantic version number (e.g., 1.2.0)
- `--type TYPE` - Version type: major, minor, patch, or custom
- `--interactive` - Interactive version planning session
- `--from-tasks` - Analyze current tasks to suggest version
- `--dry-run` - Preview version creation without saving

## Examples

```bash
# Interactive version creation with AI assistance
/doh:version-new --interactive

# Create specific version
/doh:version-new 1.2.0

# Auto-suggest version based on current tasks
/doh:version-new --from-tasks

# Create major version with planning
/doh:version-new --type major --interactive
```

## AI-Powered Features

This command provides intelligent version planning through:

1. **Smart Version Suggestion**
   - Analyzes current project state
   - Reviews pending tasks and epics
   - Suggests appropriate version increment
   - Considers breaking changes and features

2. **Release Planning Assistant**
   - Groups related tasks into version scope
   - Identifies dependencies and blockers
   - Estimates completion timeline
   - Suggests release strategy

3. **Content Generation**
   - Creates version milestone files
   - Generates release notes templates
   - Documents breaking changes
   - Creates migration guides

4. **Validation & Safety**
   - Ensures semantic versioning compliance
   - Checks for version conflicts
   - Validates project readiness
   - Provides rollback guidance

## Version File Structure

Creates `.doh/versions/{version}.md` with:

```yaml
---
version: "1.2.0"
type: "minor"
status: "planned"
created: "2025-09-01T22:00:00Z"
target_date: "2025-09-15"
breaking_changes: false
---

# Version 1.2.0 - Feature Release

## Overview
Brief description of this version's purpose and scope.

## Features & Changes
- New feature implementations
- Enhancements to existing functionality  
- Bug fixes and improvements

## Task Dependencies
- Epic 001: Core features (Tasks 001-005)
- Epic 002: UI improvements (Tasks 010-012)

## Breaking Changes
None in this release.

## Migration Guide
No migration required for this version.
```

## Interactive Mode

When run with `--interactive`, the command provides:

- **Version Analysis**: Reviews current project state and suggests version
- **Scope Planning**: Helps define what goes in this version
- **Task Assignment**: Links tasks and epics to the version
- **Release Notes**: Guides creation of comprehensive release documentation
- **Timeline Planning**: Suggests realistic completion dates
- **Risk Assessment**: Identifies potential blockers and dependencies

## Integration

- **Task Linking**: Automatically links related tasks and epics
- **Version Inheritance**: Updates child components with version context
- **Git Integration**: Optional git tag creation for version milestones
- **Documentation**: Updates project documentation with version info

## Output

The command provides detailed feedback including:
- Version creation confirmation
- File locations and structure
- Next steps and recommendations
- Related commands for version management

## See Also

- `/doh:version-edit` - Modify existing versions
- `/doh:version-list` - List all versions
- `/doh:version-bump` - Increment project version
- `/doh:version-status` - Check version status
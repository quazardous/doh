---
title: DOH Development Versioning Guide
file_version: 0.1.0
created: 2025-08-31T19:13:44Z
---

# DOH Development Versioning Guide

This document explains the specific versioning practices used for developing DOH itself, which differ from how DOH is used in typical projects.

## Self-Hosting Context

The DOH project uses DOH to manage its own development - a "dog-fooding" approach where:
- We develop DOH features using DOH workflows
- We test DOH capabilities on DOH development tasks
- We demonstrate DOH best practices through our own usage

## File Versioning Strategy

### Current Version: v0.1.0

All new and updated files starting from v0.1.0 include version information to track feature evolution.

### Version Format by File Type

#### Markdown Files (.md)
```yaml
---
title: Document Title
file_version: 0.1.0
created: 2025-08-31T19:13:44Z
---
```

#### Shell Scripts (.sh)
```bash
#!/bin/bash
# DOH Version: 0.1.0
# Created: 2025-08-31T19:13:44Z
```

#### Other Languages
- **Python**: `# DOH Version: 0.1.0`
- **JavaScript**: `// DOH Version: 0.1.0`  
- **JSON**: Not versioned (no comment syntax)
- **YAML**: `# DOH Version: 0.1.0`

### Versioning Rules

1. **New Files**: Get current DOH version when created
2. **Updated Files**: Version updated only for significant changes
3. **Existing Files**: No retroactive versioning
4. **Format**: Appropriate to file type's comment syntax

### Non-Retroactive Policy

**Important**: Existing files do not get version fields added retroactively. Only files created or significantly modified after v0.1.0 include version tracking.

This maintains a clean history and avoids noise in git commits.

## Version Hierarchy

### DOH Development Versions
- **v0.1.0**: Numbering system, core libraries (current)
- **v1.0.0**: Versioning system, release management (target)
- **v2.0.0**: Advanced workflows, automation (future)

### PRD → Epic → Task Versioning
- **PRDs**: Set `target_version` for planned DOH release
- **Epics**: Inherit or override version from PRD
- **Tasks**: Inherit version context from epic

### Example Version Flow
```
PRD: versioning (target_version: 1.0.0, file_version: 0.1.0)
├── Epic: Core Version System (target_version: 1.0.0, file_version: 0.1.0)
│   └── Task: Version file schema (target_version: 1.0.0, file_version: 0.1.0)
└── Epic: Documentation (target_version: 1.0.0, file_version: 0.1.0)
    └── Task: Versioning guide (target_version: 1.0.0, file_version: 0.1.0)
```

## Version Storage

### Project Version File
- **Path**: `VERSION` (at project root)
- **Content**: Single line with current project version (e.g., `1.0.0`)
- **Purpose**: Central source of truth for project version
- **Usage**: Used by `get_current_version()` function without parameters

Example VERSION file content:
```
1.0.0
```

### Version Files Location
- **Path**: `.doh/versions/1.0.0.md`
- **Format**: Release notes, breaking changes, migration guides
- **Status**: draft → released → deprecated

### Development Tracking
- **Current Work**: Tracked in individual file versions
- **Project Version**: Centralized in root VERSION file
- **Release Planning**: Coordinated through PRD target_version
- **Change History**: Git provides detailed change tracking

## Version API Functions

The DOH version library (`.claude/scripts/doh/lib/version.sh`) provides these functions:

### Project Version Functions
- `get_current_version()` - Read version from root VERSION file
- `set_project_version <version>` - Update root VERSION file
- `bump_project_version <level>` - Increment project version (patch/minor/major)

### File Version Functions
- `get_file_version <file>` - Read version from file's frontmatter
- `set_file_version <file> <version>` - Update file's frontmatter version
- `bump_file_version <file> <level>` - Increment file version

### Utility Functions
- `validate_version <version>` - Check semver format
- `compare_versions <v1> <v2>` - Compare two versions
- `increment_version <version> <level>` - Calculate new version
- `find_files_missing_version [dir]` - Find files without version field

### Usage Examples
```bash
# Get current project version
version=$(get_current_version)

# Bump project version
bump_project_version "minor"  # 1.0.0 → 1.1.0

# Update specific file version
set_file_version "docs/api.md" "1.2.0"
```

## Integration with DOH Commands

When the versioning system is complete, all DOH commands will:
- Automatically add appropriate version headers to new files
- Display version context in status outputs  
- Handle version inheritance in epic/task creation
- Validate version consistency across system
- Use VERSION file as central source of truth

## Migration Strategy

### Phase 1: Foundation (v0.1.0 → v1.0.0)
- Core version system implementation
- File version tracking for new files only
- PRD/epic/task version integration
- **VERSION file adoption**: Remove hardcoded version references from documentation (DEVELOPMENT.md, etc.) once VERSION file is in use

### Phase 2: Automation (v1.0.0+)
- Automatic version detection and addition
- Version-aware command behaviors
- Release management automation

## Best Practices

1. **Version When Created**: Always include version in new files
2. **Update Thoughtfully**: Only update version for significant changes
3. **Document Changes**: Use git commits to explain version updates
4. **Maintain Consistency**: Follow file type conventions
5. **Test Integration**: Verify version features work with DOH workflows

---

**Related Documents:**
- [DEVELOPMENT.md](../DEVELOPMENT.md) - DOH development overview
- [.doh/prds/versioning.md](../.doh/prds/versioning.md) - Complete versioning PRD
- [.claude/rules/doh-data-api.md](../.claude/rules/doh-data-api.md) - DOH data manipulation guide
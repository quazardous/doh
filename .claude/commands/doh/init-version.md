---
name: init-version
description: "Initialize versioning system in existing DOH project"
version: 1.0.0
category: versioning
priority: 2
requires_doh: true
author: Claude
created: 2025-09-01
file_version: 0.1.0
---

# DOH Version Initialization Command

Initialize the versioning system in an existing DOH project with automated setup, validation, and rollback capabilities.

## Usage

```bash
/doh:version-init [options]
```

## Options

- `--analyze` - Analyze project without making changes
- `--dry-run` - Show what changes would be made
- `--from-git` - Import version history from git tags
- `--interactive` - Step-by-step guided migration
- `--rollback` - Rollback previous migration
- `--force` - Skip safety checks and confirmations
- `--backup-dir DIR` - Custom backup directory location
- `--initial-version VERSION` - Set initial version (default: 0.1.0)

## Examples

```bash
# Analyze current project for initialization readiness
/doh:version-init --analyze

# Dry run to see what would change
/doh:version-init --dry-run

# Interactive initialization with git history import
/doh:version-init --interactive --from-git

# Automated initialization with specific initial version
/doh:version-init --initial-version 1.0.0

# Rollback previous initialization
/doh:version-init --rollback
```

## Initialization Process

1. **Pre-initialization Analysis**
   - Scan project structure
   - Detect existing versioning
   - Check git history
   - Generate initialization plan

2. **Backup Creation**
   - Create timestamped backup
   - Include all affected files
   - Store migration metadata

3. **Version System Setup**
   - Create VERSION file
   - Initialize .doh/versions/ directory
   - Set up version registry

4. **File Updates**
   - Add file_version to frontmatter
   - Update existing markdown files
   - Preserve all content

5. **Validation & Report**
   - Verify migration success
   - Generate migration report
   - Test version operations

## Safety Features

- Automatic backup before any changes
- Comprehensive rollback capability
- Validation at each step
- Interactive confirmation prompts
- Detailed logging and reporting

## Output

The command provides detailed progress information and generates:
- Pre-migration analysis report
- Migration execution log  
- Post-migration validation results
- Rollback instructions if needed

## Error Handling

- Validates project structure before starting
- Creates backup before any modifications
- Provides clear error messages with solutions
- Offers rollback option on failure

## See Also

- `/doh:version-status` - Check version system status
- `/doh:version-validate` - Validate version consistency  
- `/doh:version-bump` - Bump project version
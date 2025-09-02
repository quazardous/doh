---
description: "Migrate DOH project to versioning system"
category: "version"
---

# Version Migration Command

Migrate an existing DOH project to the versioning system with comprehensive analysis and conversion tools.

## Usage

```bash
/doh:version-migrate [OPTIONS]
```

## Options

- `--analyze` - Analyze project without making changes
- `--dry-run` - Show what changes would be made
- `--from-git` - Import version history from git tags
- `--interactive` - Step-by-step guided migration
- `--rollback` - Rollback previous migration
- `--force` - Skip safety checks and confirmations
- `--deduplicate` - Include duplicate number cleanup
- `--backup-dir DIR` - Custom backup directory location
- `--initial-version VER` - Set initial version (default: 0.1.0)
- `-h, --help` - Show help message

## Examples

```bash
# Analyze project for migration readiness
/doh:version-migrate --analyze

# Preview changes without applying them
/doh:version-migrate --dry-run --from-git

# Interactive guided migration
/doh:version-migrate --interactive

# Rollback previous migration
/doh:version-migrate --rollback
```

## Implementation

```bash
#!/bin/bash
# DOH Version Migration Command

# Source helper bootstrap
source "$(dirname "${BASH_SOURCE[0]}")/../../scripts/doh/helper.sh"

# Call the helper function
helper_core_version_migrate "$@"
exit $?
```

## Related Commands

- `/doh:version-status` - Check version information
- `/doh:version-validate` - Validate version consistency
- `/doh:validate` - Validate overall system health
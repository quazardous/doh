# DOH Development Project

This project uses the DOH system to develop DOH itself - a self-hosting approach where we eat our own dog food.

## File Versioning

All new and updated files include `file_version` to track when features were introduced. Existing files are not retroactively versioned.

## Version Management

The current DOH version is maintained in the `VERSION` file at the project root. This file is the single source of truth for the project version and is used by all DOH commands and scripts.

To check the current version:
```bash
cat VERSION
# or
source .claude/scripts/doh/lib/version.sh && get_current_version
```

## Documentation
- [Local Versioning Guide](docs/versioning.md) - Detailed versioning specifics for DOH development
- [Writing Good Scripts](docs/writing-good-scripts.md) - Best practices for shell scripting in DOH project

---

**Last Updated**: 2025-08-31T19:13:44Z
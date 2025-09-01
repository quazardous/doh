---
name: version-delete
description: Delete a draft or planned version (cannot delete released versions)
type: ai
parallel_execution: false
success_exit_code: 0
timeout: 30000
file_version: 0.1.0
---

# /doh:version-delete

## Description
Remove a draft or planned version from the project. Released versions cannot be deleted to preserve project history.

## Usage
```
/doh:version-delete <version> [--force]
```

## Arguments
- `<version>`: The version number to delete (e.g., 2.0.0)
- `--force`: Skip confirmation prompt (optional)

## Implementation
The AI agent will:
1. Validate the version number format
2. Check if version file exists in `.doh/versions/{version}.md`
3. Parse version status from file
4. Prevent deletion if status is "released"
5. Check for dependencies:
   - Find PRDs/epics/tasks targeting this version
   - Warn if items depend on this version
6. Confirm deletion with user (unless --force)
7. Delete the version file
8. Update any referencing items to remove target_version

## Output Format
```
Version Deletion Check: 2.0.0
==============================
Status: planned ✅ (can be deleted)
Created: 2025-09-01T18:00:00Z

⚠️ Warning: Found 3 items targeting this version:
  - PRD: new-feature
  - Epic: performance-improvements
  - Task 045: Implement caching

These items will have their target_version cleared.

Confirm deletion? (y/N): y

✅ Version 2.0.0 deleted successfully
📝 Updated 3 items to remove version reference
```

## Error Handling
- If version not found, show available versions
- If version is released, explain why it cannot be deleted
- If user cancels, abort gracefully
- Handle file permission errors
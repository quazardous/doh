# DOH Path Resolution System (T018)

## Overview

The DOH Path Resolution System provides robust, cross-environment compatibility for finding and validating DOH projects
across symlinks, encrypted filesystems, bind mounts, and different working directories.

## Key Features

- **Priority-based resolution**: Claude CWD → PROJECT_ROOT → preferred_path → .doh detection → equivalency → cache →
  fallback
- **UUID-based project identity**: Prevents false positives between projects with same name
- **Path equivalency detection**: Handles symlinks, .private encryption, bind mounts
- **Discovered paths cache**: Learns equivalent paths automatically
- **Debug mode**: Comprehensive troubleshooting with `DOH_PATH_DEBUG=1`

## Resolution Priority

The system follows this exact priority order:

1. **Claude Code Working Directory** - Preserves user's preferred directory
2. **Explicit PROJECT_ROOT** - Environment variable override
3. **Configuration preferred_path** - User's configured preference
4. **Standard .doh detection** - Parent directory traversal
5. **Path equivalency detection** - Common patterns (symlinks, .private, mounts)
6. **Discovered paths cache** - Previously learned equivalents
7. **Fallback** - Current directory (may not be DOH project)

## Configuration

### config.ini Settings

```ini
[project]
name = my-project
preferred_path = /home/user/dev/projects/my-project
canonical_path = /home/user/Private/dev/projects/my-project
discovered_paths = /home/user/dev/projects/my-project,/home/user/Private/dev/projects/my-project
last_discovered = 2025-08-27T12:43:00Z
```

- **preferred_path**: User's preferred working directory
- **canonical_path**: Resolved canonical path (automatically maintained)
- **discovered_paths**: Comma-separated list of equivalent paths
- **last_discovered**: Timestamp of last discovery update

### UUID Identity System

Each DOH project gets a unique UUID in `.doh/uuid`:

```bash
# Generated during /doh:init
cat .doh/uuid
# Output: 550e8400-e29b-41d4-a716-446655440000
```

## Public API Functions

All DOH functions follow the `doh_` prefix convention:

### Path Resolution

```bash
# Find project root with comprehensive fallback logic
doh_find_project_root

# Validate project path (with optional UUID checking)
doh_validate_project_path "/path/to/project" [require_uuid]

# Get project UUID
doh_get_project_uuid [project_path]
```

### Path Discovery

```bash
# Auto-discover equivalent paths
doh_discover_equivalent_path "/current/path" "/equivalent/path"

# Validate UUID match between paths
doh_validate_uuid_match "/path1" "/path2"
```

### Configuration Parsing

```bash
# Get configuration values with proper type conversion
doh_config_get "section" "key" "default"
doh_config_bool "section" "key" "default"
doh_config_list "section" "key" "default"
doh_config_int "section" "key" "default" [min] [max]
doh_config_path "section" "key" "default" [must_exist]

# Set configuration values
doh_config_set "section" "key" "value"
doh_config_set_list "section" "key" item1 item2 item3
doh_config_add_to_list "section" "key" "new_item"
```

## Common Filesystem Scenarios

### Symlinks

```bash
# Real path: /home/user/Private/dev/projects/my-project
# Symlink:   /home/user/dev/projects/my-project -> ../Private/dev/projects/my-project

# Both paths resolved correctly:
cd /home/user/dev/projects/my-project
doh_find_project_root
# → /home/user/Private/dev/projects/my-project (canonical)
```

### Encrypted Filesystems (.private)

```bash
# Encrypted: /home/user/.private/ → /home/user/Private/
# Pattern detection handles:
/home/user/dev/projects/my-project     ↔ /home/user/Private/dev/projects/my-project
/home/user/work/project               ↔ /home/user/Private/work/project
```

### Bind Mounts

```bash
# Docker bind mount: /host/project → /container/app
# Network mount: /net/server/project → /mnt/project
# Auto-discovery learns these patterns via UUID validation
```

### WSL/Cross-Platform

```bash
# Windows: C:\Users\user\projects\my-project
# WSL:     /mnt/c/Users/user/projects/my-project
# System handles path canonicalization appropriately
```

## Debugging

### Enable Debug Mode

```bash
export DOH_PATH_DEBUG=1
doh_find_project_root
```

Output example:

```text
🐛 DOH Path Resolution Debug Mode
🐛 Found via Claude CWD: /home/user/dev/projects/my-project
🐛 UUID validation: 550e8400-e29b-41d4-a716-446655440000
/home/user/Private/dev/projects/my-project
```

### Troubleshooting Steps

1. **Check basic structure**:

   ```bash
   ls -la .doh/
   # Should contain: project-index.json, config.ini, uuid, etc.
   ```

2. **Validate UUID**:

   ```bash
   doh_get_project_uuid
   # Should return valid UUID format
   ```

3. **Test path validation**:

   ```bash
   doh_validate_project_path "$PWD"
   echo $?  # 0 = success, 1 = no .doh, 2 = invalid UUID
   ```

4. **Check discovered paths**:

   ```bash
   doh_config_list "project" "discovered_paths"
   ```

5. **Debug path resolution**:

   ```bash
   DOH_PATH_DEBUG=1 doh_find_project_root
   ```

## Error Codes

### doh_validate_project_path

- `0`: Success
- `1`: No .doh directory or project-index.json
- `2`: Invalid UUID format

### doh_discover_equivalent_path

- `0`: Success
- `1`: Current path invalid
- `2`: Equivalent path invalid
- `3`: UUID mismatch (different projects)

## Advanced Usage

### Manual Path Discovery

```bash
# Teach DOH about equivalent paths
doh_discover_equivalent_path \
    "/home/user/dev/projects/my-project" \
    "/mnt/network/projects/my-project"

# Verify they're learned
doh_config_list "project" "discovered_paths"
```

### Custom Configuration

```bash
# Set preferred path
doh_config_set "project" "preferred_path" "/custom/path"

# Add multiple discovered paths
doh_config_set_list "project" "discovered_paths" \
    "/path1" "/path2" "/path3"
```

### Integration in Scripts

```bash
#!/bin/bash
source path/to/doh.sh

# Always use the DOH path resolution
PROJECT_ROOT=$(doh_find_project_root)

# Validate before proceeding
if ! doh_validate_project_path "$PROJECT_ROOT"; then
    echo "Not a valid DOH project"
    exit 1
fi

# Use project root for operations
cd "$PROJECT_ROOT"
# ... rest of script
```

## Migration Guide

### From Legacy DOH

Old scripts using manual path detection should be updated:

```bash
# OLD (manual detection)
while [[ "$dir" != "/" ]]; do
    if [[ -d "$dir/.doh" ]]; then
        PROJECT_ROOT="$dir"
        break
    fi
    dir="$(dirname "$dir")"
done

# NEW (use DOH API)
PROJECT_ROOT=$(doh_find_project_root)
```

### Enabling UUID System

For existing projects without UUIDs:

```bash
# Run doh-init.sh to add UUID
./path/to/doh-init.sh --force

# Or manually generate
uuidgen > .doh/uuid
```

## Performance

- **Path resolution**: ~10ms typical, <50ms worst case
- **Config parsing**: Uses awk for speed and reliability
- **Caching**: Discovered paths cached in config for fast lookup
- **Minimal overhead**: Only resolves paths when needed

## Security

- **UUID validation**: Prevents path confusion attacks
- **Path canonicalization**: Resolves all symlinks and relative paths
- **No arbitrary code execution**: Pure bash/awk implementation
- **Safe fallbacks**: Never fails destructively

---

### T018 Path Resolution System

Robust cross-environment DOH project detection

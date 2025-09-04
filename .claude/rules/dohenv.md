# DOH Environment Variables

DOH environment variables configure system behavior and must be loaded before any DOH operations.

## Loading Environment

All DOH scripts must source the environment loader first:
```bash
# At the top of every DOH script
source .claude/scripts/doh/lib/dohenv.sh
```

This loads `{doh_project_dir}/env` if it exists and exports all `DOH_*` variables with sensible defaults.

## Configuration File

Optional file `{doh_project_dir}/env` in DOH directory:
```bash
# DOH Environment Configuration
DOH_GLOBAL_DIR=~/.doh
DOH_DEBUG=0
```

Only `DOH_*` variables are processed. Comments and empty lines are ignored.

## Standard Variables

### DOH_GLOBAL_DIR
- **Default**: `~/.doh`
- **Purpose**: Global state directory outside any repository
- **Structure**: 
  ```
  ~/.doh/
  ├── projects/
  │   ├── PROJECTS.txt
  │   └── {project-id}/
  │       ├── workspace-state.yml
  │       ├── logs/
  │       └── locks/
  ```

### DOH_DEBUG
- **Default**: `0`
- **Purpose**: Enable debug output when set to `1`
- **Usage**: `DOH_DEBUG=1 /doh:command`

## Project Detection

The environment loader automatically detects the current DOH project by finding the nearest directory containing both `.git/` and `.doh/` in the directory hierarchy.

## Best Practices

1. **Always source first** - No exceptions
2. **Use defaults** - Don't override unless necessary  
3. **Keep it simple** - Only add variables you actually need
4. **No validation** - The loader just loads variables, validation happens elsewhere
5. **Shell scripts only** - Never source dohenv.sh from other libraries

## Library Architecture

### Shell Scripts (✅ Correct)
```bash
#!/bin/bash
source .claude/scripts/doh/lib/dohenv.sh  # OK - shell script

# Now DOH_GLOBAL_DIR is available
source .claude/scripts/doh/lib/workspace.sh
```

### Libraries (❌ Incorrect) 
```bash
#!/bin/bash
# DOH Library
source .claude/scripts/doh/lib/dohenv.sh  # WRONG - don't do this

# Libraries should expect environment to be pre-loaded
```

### Libraries (✅ Correct)
```bash
#!/bin/bash
# DOH Library
# NOTE: This library expects DOH environment variables to be already loaded
# by the calling script via: source .claude/scripts/doh/lib/dohenv.sh

# Use variables directly
mkdir -p "$DOH_GLOBAL_DIR/projects"
```

## Rationale

- **Single responsibility** - dohenv.sh only loads environment variables
- **Clean dependencies** - Prevents circular dependencies between libraries
- **Performance** - Avoid multiple environment loading
- **Clarity** - Clear separation between environment setup and business logic
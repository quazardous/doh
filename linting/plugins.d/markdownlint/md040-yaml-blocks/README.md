# Plugin: MD040 YAML Auto-Detection

**Version**: 1.0.0  
**Created**: 2025-08-29  
**Linter**: markdownlint  
**Target Error**: MD040 (fenced-code-language)

## Description

Automatically detects YAML content in fenced code blocks and adds appropriate language specification to resolve MD040 errors.

**Pattern Detection**: Identifies code blocks containing YAML structures like:
- Key-value pairs: `key: value`  
- Lists: `- item`
- Document separators: `---`
- Nested structures with indentation

## Target Configuration

- **File**: `.markdownlint.json`
- **Rule**: MD040 (fenced-code-language)
- **Action**: Add exception for YAML blocks or auto-fix detection

## Plugin Components

- **config-fragment.json**: Markdownlint configuration fragment
- **detect-yaml.js**: Custom detection logic (if advanced rules needed)
- **STATUS**: Current plugin status (PROPOSED/APPLIED/REFUSED)

## Installation

This plugin is managed by the markdownlint plugin manager:

```bash
# Enable plugin
./linting/plugins.d/manager_markdownlint_plugin.sh --enable md040-yaml-blocks

# Check status  
./linting/plugins.d/manager_markdownlint_plugin.sh --status md040-yaml-blocks

# Disable plugin
./linting/plugins.d/manager_markdownlint_plugin.sh --disable md040-yaml-blocks
```

## Integration with /dd:lint

```bash
# Apply this plugin
/dd:lint --apply-plugin markdownlint:md040-yaml-blocks

# List markdownlint plugins
/dd:lint --list-plugins markdownlint
```

## Error Patterns Targeted

Based on error cache analysis, this plugin targets:

- **Files affected**: ~45 files in project
- **Pattern frequency**: 23 YAML blocks, 15 config blocks, 7 data blocks
- **Success rate**: Expected 95% auto-resolution of MD040 errors in YAML contexts

## Version History

- **1.0.0**: Initial implementation with basic YAML pattern detection
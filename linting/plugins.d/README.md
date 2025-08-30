# Linting Plugins Management System

**Version**: 1.0  
**Created**: 2025-08-29  

## Overview

This directory contains linting plugins organized by linter tool. Each linter has its own management system and plugin specifications.

## Supported Linters

### Markdownlint
- **Tool**: markdownlint-cli
- **Manager**: `manager_markdownlint_plugin.sh`
- **Plugin Directory**: `markdownlint/`
- **Supported Errors**: MD040, MD036, MD013, MD024, MD025, MD032

### Prettier
- **Tool**: prettier
- **Manager**: `manager_prettier_plugin.sh` 
- **Plugin Directory**: `prettier/`
- **Supported Errors**: Formatting, line length, code style

### Codespell
- **Tool**: codespell
- **Manager**: `manager_codespell_plugin.sh`
- **Plugin Directory**: `codespell/`
- **Supported Errors**: Spelling corrections, custom dictionaries

## Plugin Structure

Each linter has its own subdirectory with the following structure:

```text
./linting/plugins.d/
├── README.md                           # This file
├── manager_markdownlint_plugin.sh      # Markdownlint plugin manager
├── manager_prettier_plugin.sh          # Prettier plugin manager  
├── manager_codespell_plugin.sh         # Codespell plugin manager
├── markdownlint/                       # Markdownlint plugins
│   ├── md040-yaml-blocks/
│   │   ├── README.md                   # Plugin specification
│   │   ├── STATUS                      # PROPOSED|APPLIED|REFUSED
│   │   ├── detect-yaml.js              # Custom rule implementation
│   │   └── config-fragment.json        # Configuration fragment
│   ├── md036-emphasis-headers/
│   │   ├── README.md
│   │   ├── STATUS
│   │   └── config-fragment.json
│   └── md013-line-length/
│       ├── README.md
│       ├── STATUS
│       └── config-fragment.json
├── prettier/                           # Prettier plugins
│   ├── smart-line-breaks/
│   │   ├── README.md
│   │   ├── STATUS
│   │   └── config-fragment.json
│   └── code-block-formatting/
│       ├── README.md
│       ├── STATUS
│       └── config-fragment.json
└── codespell/                          # Codespell plugins
    ├── project-dictionary/
    │   ├── README.md
    │   ├── STATUS
    │   └── words.txt
    └── ignore-patterns/
        ├── README.md
        ├── STATUS
        └── ignore-list.txt
```

## Plugin Manager Commands

### Install Plugin
```bash
# Install a markdownlint plugin
./manager_markdownlint_plugin.sh --install md040-yaml-blocks

# Install a prettier plugin
./manager_prettier_plugin.sh --install smart-line-breaks

# Install a codespell plugin
./manager_codespell_plugin.sh --install project-dictionary
```

### List Plugins
```bash
# List all markdownlint plugins with status
./manager_markdownlint_plugin.sh --list

# List specific linter plugins
./manager_prettier_plugin.sh --list
./manager_codespell_plugin.sh --list
```

### Plugin Status Management
```bash
# Check plugin status
./manager_markdownlint_plugin.sh --status md040-yaml-blocks

# Enable plugin (PROPOSED → APPLIED)
./manager_markdownlint_plugin.sh --enable md040-yaml-blocks

# Disable plugin (APPLIED → REFUSED)
./manager_markdownlint_plugin.sh --disable md040-yaml-blocks

# Remove plugin completely
./manager_markdownlint_plugin.sh --remove md040-yaml-blocks
```

## Plugin States

- **PROPOSED**: Plugin suggested by AI analysis, awaiting approval
- **APPLIED**: Plugin active and integrated into linter configuration
- **REFUSED**: Plugin rejected or disabled by user

## Integration with /dd:lint

The `/dd:lint` command integrates with this system via flags:

```bash
# Suggest plugins based on error cache analysis
/dd:lint --suggest-plugins

# List all plugins across all linters
/dd:lint --list-plugins

# Apply a specific plugin
/dd:lint --apply-plugin markdownlint:md040-yaml-blocks

# Refuse a proposed plugin
/dd:lint --refuse-plugin prettier:smart-line-breaks
```

## Configuration Management

Each linter manager handles configuration differently:

### Markdownlint
- **Main config**: `.markdownlint.json`
- **Plugin integration**: Merges `config-fragment.json` into main config
- **Custom rules**: Copies `.js` files to `.markdownlint/rules/`
- **Backup**: Creates `.markdownlint.json.bak-[plugin-name]`

### Prettier  
- **Main config**: `.prettierrc`
- **Plugin integration**: Merges `config-fragment.json` into main config
- **Custom formatting**: Applies formatting rules
- **Backup**: Creates `.prettierrc.bak-[plugin-name]`

### Codespell
- **Main config**: `.codespell.cfg` or `pyproject.toml`
- **Plugin integration**: Appends to dictionaries or ignore files
- **Custom dictionaries**: Manages word lists and ignore patterns
- **Backup**: Creates config backups before modification

## AI Integration

The AI system:

1. **Analyzes error cache** patterns from `.cache/linting/error-patterns.json`
2. **Generates plugin specifications** in appropriate linter subdirectories
3. **Creates README.md** with installation instructions per linter
4. **Sets STATUS** to PROPOSED for human approval
5. **Integrates with managers** using standardized commands

## Development Workflow

1. **AI detects error patterns** → suggests plugin
2. **Plugin created** in appropriate linter subdirectory with STATUS=PROPOSED
3. **Human reviews** plugin specification
4. **Human approves**: `./manager_[linter]_plugin.sh --enable [plugin-name]`
5. **Plugin integrates** into linter configuration automatically
6. **Backup created** before any config modifications

## Benefits

- 🔧 **Linter-specific**: Each tool has optimized management
- 📦 **Modular**: Independent plugin systems per linter
- 🤖 **AI-driven**: Intelligent plugin suggestions based on real error patterns
- 🔄 **Reversible**: Easy enable/disable with automatic backups
- 🎯 **Targeted**: Plugins solve specific recurring errors
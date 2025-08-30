# Plugin: Project-Specific Dictionary

**Version**: 1.0.0  
**Created**: 2025-08-29  
**Linter**: codespell  
**Target Error**: Spelling corrections for project-specific terms

## Description

Adds project-specific technical terms and acronyms to the codespell dictionary to prevent false positives on legitimate
project terminology.

**Common Project Terms**:

- `markdownlint`, `codespell`, `prettier`
- `bashutils`, `gitignore`, `eslint`
- `repos`, `configs`, `utils`
- Technical abbreviations and tool names

## Target Configuration

- **Files**: `.codespell.cfg`, `.codespell-words.txt`
- **Action**: Add custom dictionary entries
- **Backup**: Automatic backup before modification

## Plugin Components

- **words.txt**: Custom dictionary entries for project terms
- **config-fragment.cfg**: Codespell configuration fragment
- **STATUS**: Current plugin status

## Installation

Managed by the codespell plugin manager:

```bash
# Enable plugin
./scripts/linting/manager_codespell_plugin.sh --enable project-dictionary

# Check status
./scripts/linting/manager_codespell_plugin.sh --status project-dictionary
```

## Integration with /dd:lint

```bash
# Apply this plugin
/dd:lint --apply-plugin codespell:project-dictionary

# List codespell plugins
/dd:lint --list-plugins codespell
```

## Dictionary Entries

Based on project analysis, prevents false positives for:

- **Development tools**: markdownlint, codespell, prettier, eslint
- **Project structure**: bashutils, gitignore, workflows
- **Technical terms**: repos, configs, utils, linters
- **File extensions**: `.md`, `.json`, `.yml`, `.cfg`

## Expected Impact

- **False positive reduction**: ~23 corrections per scan
- **Files affected**: All markdown and configuration files
- **Maintenance**: Dictionary grows with project terminology

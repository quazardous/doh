# /doh:lint - Optional Project Linting with Smart Integration

Provides optional intelligent linting for DOH-managed projects with smart integration, respecting existing project linting setup while offering DOH-enhanced documentation quality assurance.

## Usage

```bash
/doh:lint [--check-only] [--files=pattern] [--verbose] [--enable]
```

## Parameters

- `--check-only`: Report issues without making changes (skips auto-fixes)
- `--files=pattern`: Lint specific files or patterns (e.g., `--files="docs/*.md"`)
- `--verbose`: Show detailed fix information and integration status
- `--enable`: Enable DOH linting for this project (updates .doh/config.ini)

## Smart Integration Strategy

This command integrates intelligently with existing project linting:

### 1. Auto-Detection Mode (Default)

**Configuration Check**:
```bash
# Checks .doh/config.ini for lint_enabled setting
[pipeline]
lint_enabled = true    # DOH linting active
lint_enabled = false   # DOH linting disabled
# (missing)            # Auto-detect based on project
```

**Project Detection**:
- **Existing Linting**: Detects `.eslintrc`, `prettier.config.js`, `markdownlint.json`
- **Integration Mode**: Works alongside existing linting, focuses on DOH-specific rules
- **Standalone Mode**: Provides comprehensive linting if no existing setup

### 2. DOH-Specific Enhancements

When enabled, adds DOH-specific linting rules:

#### DOH Task Documentation
- **.doh/tasks/*.json**: Validates DOH task structure and required fields
- **CHANGELOG.md**: Ensures DOH task references are properly formatted
- **README.md**: Validates DOH integration sections if present

#### Documentation Quality
- **Markdown consistency**: Standardizes DOH documentation patterns
- **Link validation**: Checks internal links to .doh/ structure
- **Format compliance**: Ensures DOH template compliance

### 3. Respectful Integration

**Existing Project Linting**:
- **Never conflicts**: DOH linting runs after existing project linting
- **Complementary rules**: Focuses on DOH-specific content, not general code style
- **Graceful coexistence**: Respects project's existing linting configuration

**Example Integration**:
```bash
# Project with existing linting
npm run lint              # Project's own linting
/doh:lint                 # DOH-specific enhancements (if enabled)

# Project without linting
/doh:lint --enable        # Enables DOH linting with broader scope
```

## Configuration Management

### Enable DOH Linting

```bash
# Enable for current project
/doh:lint --enable

# Creates/updates .doh/config.ini:
[pipeline]
lint_enabled = true
lint_rules = standard    # strict, standard, relaxed
lint_scope = doh         # doh-only, enhanced, comprehensive
```

### Scope Levels

1. **doh-only**: Only .doh/ folder and DOH-specific files
2. **enhanced**: DOH files + project documentation (README, CHANGELOG)  
3. **comprehensive**: Full project linting (if no existing linting detected)

### Auto-Detection Logic

```
Project has .eslintrc or similar?
├── Yes → lint_scope = doh-only (respectful mode)
├── No → lint_scope = enhanced (helpful mode)
└── --enable flag → User choice of scope level
```

## Linting Rules by Scope

### DOH-Only Scope
- **.doh/tasks/*.json**: Task structure validation
- **.doh/config.ini**: Configuration format validation
- **CHANGELOG.md**: DOH task reference format (DOH-123, [DOH #123])

### Enhanced Scope (+ DOH-Only)
- **README.md**: DOH integration sections
- **docs/*.md**: General markdown quality
- **Project documentation**: Link validation, formatting

### Comprehensive Scope (+ Enhanced)
- **All markdown files**: Full markdown linting
- **JSON/YAML**: Format validation
- **Basic code quality**: If no existing linting

## Example Usage

### Check if DOH linting is recommended
```bash
/doh:lint
# Auto-detects project setup:
# "Project has ESLint configured. DOH linting will use 'doh-only' scope."
# "Run with --enable to activate DOH linting for this project."
```

### Enable DOH linting
```bash
/doh:lint --enable
# Prompts for scope selection:
# "Select DOH linting scope:
#  1. doh-only     - Only .doh/ files (recommended for projects with existing linting)
#  2. enhanced     - DOH files + project documentation  
#  3. comprehensive - Full project linting
# Choice [1]: "
```

### Run DOH linting (when enabled)
```bash
/doh:lint
# Output:
# 📋 DOH Linting (enhanced scope)
# ├── ✅ .doh/tasks/ - 12 files validated
# ├── ✅ .doh/config.ini - Format valid
# ├── 🔧 CHANGELOG.md - Fixed 2 DOH reference formats
# ├── 📝 README.md - DOH integration section looks good
# └── ✅ 4 files processed, 2 auto-fixes applied
```

### Check-only mode
```bash
/doh:lint --check-only
# Reports issues without fixes, respects existing project workflow
```

## Integration with Pipeline Commands

### /doh:changelog Integration

```bash
# /doh:changelog calls /doh:lint only if enabled
[pipeline]
lint_enabled = true     # /doh:changelog will call /doh:lint
lint_enabled = false    # /doh:changelog skips linting

# Manual override
/doh:changelog --no-lint    # Skip linting even if enabled
```

### /doh:commit Integration

```bash
# Full pipeline respects linting configuration
/doh:commit "DOH-123 complete"
# → /doh:changelog (includes /doh:lint if enabled)
# → Git operations
```

## Error Handling

### Graceful Degradation

- **Missing config**: Defaults to disabled, suggests --enable
- **Conflicting rules**: Warns about conflicts, suggests scope adjustment
- **Tool missing**: Falls back to basic validation, continues operation
- **Permission issues**: Reports problems, doesn't block pipeline

### Smart Suggestions

```bash
# Detected existing linting
"✨ Detected ESLint in your project. DOH linting will focus on .doh/ files only.
   Use '/doh:lint --enable' to configure DOH-specific enhancements."

# No existing linting detected  
"💡 No existing linting detected. DOH can provide comprehensive linting.
   Use '/doh:lint --enable' to improve code quality across your project."
```

## Use Cases

### For Projects with Existing Linting
- **Complementary**: Adds DOH-specific validation without conflicts
- **Focused**: Only processes DOH-related files and documentation
- **Respectful**: Never overrides existing project linting rules

### For Projects without Linting
- **Comprehensive**: Offers full project linting capabilities
- **Gradual adoption**: Start with DOH files, expand scope as needed
- **Quality improvement**: Enhances overall project documentation quality

### For DOH-Heavy Projects
- **Task validation**: Ensures DOH task files are properly structured
- **Documentation consistency**: Maintains quality across DOH documentation
- **Link integrity**: Validates references between DOH tasks and documentation

## Migration from /doh-sys

Key differences for runtime use:

- **Optional by default**: Projects opt-in rather than mandatory
- **Respects existing setup**: Integrates with project linting instead of replacing
- **Configurable scope**: Adapts to project needs and existing tools
- **Graceful fallback**: Pipeline continues even if linting fails or is disabled
- **Project-specific rules**: Uses .doh/config.ini instead of hardcoded DOH system rules

This command brings intelligent linting capabilities to DOH projects while respecting existing project setup and providing flexible, optional enhancement rather than mandatory processing.
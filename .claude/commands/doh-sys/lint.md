# /doh-sys:lint - Intelligent DOH System Linting with Auto-Fix

Executes comprehensive linting for DOH projects with intelligent auto-fix capabilities, progressive error handling, and priority-based repair strategies.

## Usage

```bash
/doh-sys:lint [--check-only] [--format] [--files=pattern] [--verbose]
```

## Parameters

- `--check-only`: Report issues without making changes (overrides default auto-fix behavior)
- `--format`: Run additional formatters (prettier, etc.) after auto-fixes
- `--files=pattern`: Lint specific files or patterns (e.g., `--files="docs/*.md"`)
- `--verbose`: Show detailed fix information and progress

**Default Behavior**: Auto-fix is enabled by default. Use `--check-only` to disable fixes and only report issues.

## Auto-Fix Priority System

The command applies fixes in this intelligent priority order:

### Priority 1: Critical (Blocks commits)
- **Syntax errors**: Malformed markdown, broken code blocks
- **Structure violations**: Missing headings hierarchy, broken lists
- **File endings**: Missing final newlines, incorrect line endings

### Priority 2: High (Functional issues)
- **Link validation**: Fix broken internal references
- **Code block languages**: Add missing language specifications
- **Heading structure**: Fix heading levels and hierarchy
- **List formatting**: Correct indentation and spacing

### Priority 3: Medium (Consistency)
- **Line length**: Intelligent text wrapping preserving meaning
- **Spacing**: Standardize blank lines around elements
- **Emphasis formatting**: Normalize bold/italic usage
- **Table formatting**: Align columns and fix structure

### Priority 4: Low (Style preferences)
- **Trailing whitespace**: Remove unnecessary spaces
- **Quote consistency**: Standardize quote types
- **Capitalization**: Fix heading capitalization patterns

## Intelligent Line Length Handling

Unlike basic linting, `/doh-sys:lint` uses smart wrapping:

```markdown
# Before (132 chars - too long)
- **Components**: Enhanced README.md with comprehensive document map, improved navigation between workflow documents, minimal cross-reference policy

# After (intelligent wrapping)
- **Components**: Enhanced README.md with comprehensive document map, improved navigation between workflow documents,
  minimal cross-reference policy
```

**Smart wrapping rules**:
- Preserves sentence structure and meaning
- Maintains proper indentation for lists
- Keeps code examples intact
- Respects markdown formatting (tables, links, emphasis)

## File Type Handling

### Markdown Files (`*.md`)
- **Linter**: `markdownlint-cli` with DOH configuration
- **Formatter**: `prettier` with markdown-specific rules
- **Auto-fixes**: Structure, spacing, links, code blocks
- **Preservation**: Analysis documents remain semantically unchanged

### Configuration Files
- **JSON**: `prettier` formatting, syntax validation
- **YAML**: `yamllint` with auto-correction
- **Package files**: Dependency sorting, format standardization

### Code Files (when present)
- **JavaScript/TypeScript**: ESLint with auto-fix
- **CSS**: Stylelint with corrections
- **Shell scripts**: ShellCheck with suggestions

## Analysis Document Policy

Respects the DOH analysis document preservation policy:

```bash
# Analysis documents get formatting fixes only
/doh-sys:lint analysis/
# ✅ Fixes: line length, spacing, syntax
# ❌ Preserves: project names, examples, semantic content
```

## Progressive Error Handling

When auto-fixes fail, the system:

1. **Attempts individual fixes** rather than failing entirely
2. **Reports unfixable issues** with specific guidance
3. **Suggests manual fixes** for complex problems
4. **Continues processing** other files even if one fails

## Example Usage

```bash
# Standard auto-fix linting (default behavior)
/doh-sys:lint

# Check issues without fixing (report-only mode)
/doh-sys:lint --check-only

# Auto-fix specific file types
/doh-sys:lint --files="docs/*.md"

# Auto-fix with additional formatting
/doh-sys:lint --format

# Verbose auto-fix output
/doh-sys:lint --verbose

# Auto-fix TODO and CHANGELOG specifically
/doh-sys:lint --files="TODO.md CHANGELOG.md"
```

## Integration with /doh-sys:commit

The commit pipeline automatically runs this linting process:

```bash
# These are equivalent for linting
/doh-sys:commit --dry-run  # includes /doh-sys:lint
/doh-sys:lint --check-only  # standalone check
```

## Output Format

Provides clear, actionable feedback:

```
🔧 DOH System Linting with Auto-Fix
├── 📝 Scanning 47 markdown files...
├── ⚡ Priority 1: Fixed 3 critical syntax errors
├── ⚡ Priority 2: Fixed 8 structural issues  
├── ⚡ Priority 3: Applied 12 consistency fixes
├── ⚡ Priority 4: Cleaned 5 style issues
├── ⚠️  2 manual fixes needed (see details below)
└── ✅ Linting complete: 28 auto-fixes applied

Manual fixes needed:
• TODO.md:1520 - Table structure too complex for auto-fix
• docs/architecture.md:89 - Link target needs verification
```

## Error Recovery

Handles common issues gracefully:

- **File permissions**: Suggests chmod commands
- **Git conflicts**: Detects and reports merge conflicts
- **Binary files**: Skips non-text files automatically
- **Large files**: Processes in chunks to avoid memory issues
- **Encoding issues**: Detects and handles UTF-8/ASCII mixed files

## Configuration

Uses DOH-optimized linting configuration:

- **Line length**: 120 chars for code, 80 for docs (with smart wrapping)
- **Heading style**: ATX preferred (`# Heading`)
- **List style**: Consistent hyphen bullets (`-`)
- **Code blocks**: Language specification required
- **Link validation**: Internal links checked, external links reported

## Performance Optimization

- **Parallel processing**: Lints multiple files simultaneously
- **Incremental checking**: Only re-processes changed files when possible
- **Caching**: Remembers successful fixes to speed up reruns
- **File filtering**: Skips irrelevant files (node_modules, .git, etc.)

This command provides the same intelligent, progressive auto-fix approach as the commit pipeline, but focused specifically on code quality and formatting.
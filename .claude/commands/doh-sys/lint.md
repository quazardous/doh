# /doh-sys:lint - Intelligent DOH System Linting with Auto-Fix

Executes comprehensive linting for DOH projects with intelligent auto-fix capabilities, progressive error handling, and
priority-based repair strategies.

## Usage

```bash
/doh-sys:lint [--check-only] [--files=pattern] [--verbose]
```

## Parameters

- `--check-only`: Report issues without making changes (skips prettier and all auto-fixes)
- `--files=pattern`: Lint specific files or patterns (e.g., `--files="docs/*.md"`)
- `--verbose`: Show detailed fix information including prettier step progress

**Default Behavior**: Auto-fix is enabled by default with prettier ALWAYS running first. Use `--check-only` to disable
all fixes and only report issues.

## Prettier-First Workflow

This command implements a **prettier-first approach** to ensure maximum consistency:

1. **Step 1 - Baseline Formatting**: `prettier --write` runs on ALL supported files before any linting
2. **Step 2 - Rule-Based Fixes**: Language-specific linters apply their fixes to the prettier-formatted files
3. **Step 3 - DOH Intelligence**: Custom intelligent fixes for remaining issues

**Why Prettier First?**

- **Consistent foundation**: All files start with identical formatting baseline
- **Reduces conflicts**: Fewer conflicts between prettier and rule-based linters
- **Predictable results**: Same input always produces same output
- **Faster processing**: Prettier handles bulk formatting, linters focus on logic/structure

## Auto-Fix Priority System

The command applies fixes in this intelligent priority order:

### Priority 0: Pre-Processing (ALWAYS FIRST)

- **Prettier Auto-Fix**: ALWAYS runs first on all supported files (.md, .json, .yaml, .js, .ts, .css)
- **Baseline Formatting**: Establishes consistent formatting foundation before rule-based fixes
- **Critical Foundation**: Essential step that enables all subsequent priority levels to work correctly

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

- **Components**: Enhanced README.md with comprehensive document map, improved navigation between workflow documents,
  minimal cross-reference policy

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

1. **ALWAYS FIRST**: `prettier --write` (baseline formatting)
2. **Then**: `markdownlint-cli --fix` (rule-based fixes)
3. **Finally**: DOH-specific intelligent fixes

- **Preservation**: Analysis documents remain semantically unchanged

### Configuration Files

1. **ALWAYS FIRST**: `prettier --write` for JSON/YAML files
2. **Then**: Syntax validation and linting
3. **Package files**: Dependency sorting, format standardization

### Code Files (when present)

1. **ALWAYS FIRST**: `prettier --write` for JS/TS/CSS files
2. **Then**: Language-specific linting:
   - **JavaScript/TypeScript**: ESLint with auto-fix
   - **CSS**: Stylelint with corrections
   - **Shell scripts**: ShellCheck with suggestions

**Critical Workflow**: Every file gets prettier formatting BEFORE any rule-based linting to establish a consistent
baseline.

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
# Standard auto-fix linting (prettier ALWAYS runs first)
/doh-sys:lint
# → Step 1: prettier --write on all supported files
# → Step 2: markdownlint --fix, eslint --fix, etc.
# → Step 3: DOH-specific intelligent fixes

# Check issues without fixing (report-only mode, NO prettier)
/doh-sys:lint --check-only

# Auto-fix specific file types (prettier runs on matched files)
/doh-sys:lint --files="docs/*.md"

# Verbose output showing prettier step
/doh-sys:lint --verbose

# Auto-fix TODO and CHANGELOG (prettier then markdownlint)
/doh-sys:lint --files="TODO.md CHANGELOG.md"
```

**Note**: The `--format` parameter has been removed as prettier formatting is now ALWAYS the first step in auto-fix
mode.

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
├── 📝 Scanning 47 files (*.md, *.json, *.js, *.ts, *.css)...
├── ✨ Priority 0: Prettier auto-fix applied to 42 files
├── ⚡ Priority 1: Fixed 3 critical syntax errors
├── ⚡ Priority 2: Fixed 8 structural issues
├── ⚡ Priority 3: Applied 12 consistency fixes
├── ⚡ Priority 4: Cleaned 5 style issues
├── ⚠️  2 manual fixes needed (see details below)
└── ✅ Linting complete: 70 total fixes (42 prettier + 28 rule-based)

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

## AI-Driven Optimization Detection

This command continuously learns and improves through auto-fix pattern analysis:

### Auto-Detection Capabilities

**Auto-Fix Success Pattern Analysis**:

- **Repeated manual fixes**: When certain issue types consistently require manual intervention
- **Priority order inefficiency**: When lower-priority fixes conflict with higher-priority ones
- **File type gaps**: When new file types appear that aren't handled by current logic

**Example Detection Scenarios**:

```bash
# After consistent manual fixes for table formatting issues
🔍 Optimization Detected: Table auto-fix logic incomplete
   Pattern: 7/10 recent runs required manual table formatting fixes
   Missing: Complex table alignment, multi-row header detection

   Proposed optimization: Enhanced table processing
   - Add multi-pass table alignment algorithm
   - Detect and preserve complex table structures
   - Priority boost for table fixes (blocks other formatting)

   Update /doh-sys:lint with this optimization? [Y/n]
```

**Progressive Fix Learning**:

- **Fix conflict patterns**: When prettier conflicts with rule-based linters
- **Retry success analysis**: When certain fixes succeed on second/third attempts
- **File-specific patterns**: When certain files consistently need special handling

### Smart Priority Reordering

**Dynamic Priority Learning**:

```bash
# After detecting that line-length fixes often break code blocks
🔍 Optimization Detected: Fix priority order causing conflicts
   Pattern: Line length fixes breaking code block formatting (5 occurrences)
   Conflict: Priority 3 (line length) interfering with Priority 2 (code blocks)

   Proposed optimization: Smart dependency-aware priorities
   - Defer line length fixes until after code block processing
   - Add fix compatibility matrix
   - Context-aware priority adjustment

   Update /doh-sys:lint priority system with this optimization? [Y/n]
```

### Optimization Confirmation Workflow

1. **Fix Pattern Monitoring**: Track success rates, manual intervention frequency, conflict patterns
2. **Efficiency Analysis**: Identify bottlenecks and improvement opportunities
3. **Logic Enhancement**: Design specific improvements for detected patterns
4. **User Confirmation**: Request permission with clear benefit explanation
5. **Optimization Logging**: Records optimization in `.claude/optimization/DOHSYSOPTIM.md`
6. **Implementation**: Update auto-fix intelligence and apply immediately

**Confirmation Format**:

```
🔍 Optimization Detected: [Auto-fix component] needs enhancement
   Pattern: [Statistical observation from recent executions]
   Issue: [Current limitation or inefficiency]

   Proposed optimization: [Specific improvement]
   - [Technical enhancement 1]
   - [Technical enhancement 2]

   Update /doh-sys:lint with this optimization? [Y/n]

   [If confirmed, logs to DOHSYSOPTIM.md with success rate data and fix pattern analysis]
```

This command provides an intelligent, progressive auto-fix approach that continuously evolves through pattern
recognition and optimization, ensuring maximum effectiveness across diverse codebases and file types.

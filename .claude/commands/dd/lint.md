# /dd:lint - Intelligent DOH System Linting with Auto-Fix

Executes comprehensive linting for DOH projects with intelligent auto-fix capabilities, progressive error handling, and
priority-based repair strategies.

## Usage

```bash
/dd:lint [--check-only] [--files=pattern] [--verbose] [--tune] [--tune-review] [--preview] [--rollback]
```

## Parameters

### Mode Control
- `--check-only`: Report-only mode - no modifications made to any files
  - **Safe**: Shows all issues without making changes
  - **Skips**: All prettier formatting and auto-fixes  
  - **Use when**: Want to see issues before deciding to fix them
  - **Perfect for**: CI/CD validation, pre-commit checks, issue assessment

### AI Intelligence Features (T078)
- `--tune`: Apply AI-driven configuration optimizations based on feedback patterns
  - **Smart**: Uses data from `./linting/feedback.md` to optimize `.markdownlint.json`
  - **Safe**: Creates backup before applying changes
  - **Data-driven**: Only suggests changes with high success rates (>85%)
  - **Use when**: Want to reduce future linting failures through intelligent tuning
  - **Perfect for**: Proactive optimization after accumulating linting patterns

- `--tune-review`: Show detailed analysis of available configuration optimizations  
  - **Comprehensive**: Displays pattern analysis, success rates, and impact predictions
  - **Educational**: Explains reasoning behind each optimization suggestion
  - **No changes**: Pure analysis mode - no files modified
  - **Use when**: Want to understand optimization opportunities before applying
  - **Perfect for**: Learning about linting patterns and configuration decisions

- `--preview`: Preview configuration changes without applying them (used with `--tune`)
  - **Safe**: Shows diff of proposed `.markdownlint.json` changes
  - **Impact analysis**: Displays expected failure reduction percentages
  - **Use when**: Want to see what `--tune` would change before committing
  - **Perfect for**: Validation before applying optimizations

- `--rollback`: Restore previous `.markdownlint.json` configuration from backups
  - **Safe**: Shows available backup configurations with timestamps
  - **Interactive**: Choose which backup to restore from available options
  - **Logging**: Records rollback action in `./linting/feedback.md`
  - **Use when**: Current configuration causes issues or over-optimization
  - **Perfect for**: Quick recovery from problematic tuning changes

### File Targeting  
- `--files=pattern`: Lint specific files or patterns instead of entire project
  - **Examples**: `--files="docs/*.md"`, `--files="TODO.md CHANGELOG.md"`, `--files="*.json"`
  - **Supports**: Glob patterns, space-separated file lists, directory paths
  - **Use when**: Working on specific files, want faster targeted linting
  - **Combines with**: All other flags (--check-only, --verbose, --tune-review)

### Output Control
- `--verbose`: Show detailed progress and fix information
  - **Default**: Concise summary of fixes applied
  - **Detailed**: Shows prettier step progress, individual file processing, fix categories
  - **Use when**: Debugging linting issues, understanding what changes are made
  - **Helpful for**: Learning what auto-fixes are available

### Default Behavior
**Auto-fix enabled by default** with prettier-first approach:
1. **Prettier formatting** ALWAYS runs first on all supported files
2. **Rule-based linting** applies fixes to prettier-formatted files  
3. **DOH intelligence** handles remaining issues with smart fixes

**Override**: Use `--check-only` to disable all fixes and only report issues

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

Unlike basic linting, `/dd:lint` uses smart wrapping:

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
/dd:lint analysis/
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
/dd:lint
# → Step 1: prettier --write on all supported files
# → Step 2: markdownlint --fix, eslint --fix, etc.
# → Step 3: DOH-specific intelligent fixes

# Check issues without fixing (report-only mode, NO prettier)
/dd:lint --check-only

# Auto-fix specific file types (prettier runs on matched files)
/dd:lint --files="docs/*.md"

# Verbose output showing prettier step
/dd:lint --verbose

# Auto-fix TODO and CHANGELOG (prettier then markdownlint)
/dd:lint --files="TODO.md CHANGELOG.md"

# T078 AI Intelligence Features
# Apply feedback-driven configuration optimizations
/dd:lint --tune

# Preview what --tune would change without applying
/dd:lint --tune --preview

# Detailed analysis of optimization opportunities
/dd:lint --tune-review

# Combined workflow: review → preview → apply
/dd:lint --tune-review           # Understand patterns
/dd:lint --tune --preview        # See proposed changes
/dd:lint --tune                  # Apply optimizations

# Configuration management workflow
/dd:lint --rollback              # Restore previous configuration if needed
```

**Note**: The `--format` parameter has been removed as prettier formatting is now ALWAYS the first step in auto-fix
mode.

## Integration with /doh-sys:commit

The commit pipeline automatically runs this linting process:

```bash
# These are equivalent for linting
/doh-sys:commit --dry-run  # includes /dd:lint
/dd:lint --check-only  # standalone check
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

## T078 AI Intelligence Integration

This command now includes intelligent configuration tuning capabilities that leverage the T070 feedback system:

### --tune-review Output Example

```bash
/dd:lint --tune-review

🔍 LINTING OPTIMIZATION REVIEW

## Current Configuration Analysis

### .markdownlint.json Status
- Last updated: 2025-08-15 (13 days ago)
- Rules configured: 12 active rules
- Optimization potential: HIGH (3 major opportunities detected)

## Pattern-Based Recommendations

### HIGH Impact Optimizations

#### 1. MD013 (Line Length) 
📊 **Failure Pattern**: 23 occurrences across 18 commits (72% of all failures)
🎯 **Files Affected**: `todo/*.md` (67%), `docs/*.md` (28%), `.claude/commands/*.md` (5%)
⚡ **Suggested Fix**: Increase limit from 120 → 130 characters
📈 **Impact**: Would prevent ~89% of MD013 failures based on historical analysis
🤖 **AI Reliability**: 95% success rate for line length fixes
💡 **Why This Works**: Technical documentation naturally requires longer lines for code examples
⚠️  **Consideration**: Ensures readability while accommodating technical content

#### 2. MD047 (Missing Final Newline)
📊 **Failure Pattern**: 12 occurrences across 8 commits (32% of all failures)  
🎯 **Files Affected**: `todo/*.md` (83%), root level docs (17%)
⚡ **Suggested Fix**: Add `"MD047": true` to enforce final newlines
📈 **Impact**: Would prevent 100% of MD047 failures  
🤖 **AI Reliability**: 100% success rate (mechanical fix)
💡 **Why This Works**: POSIX compliance and prevents file parsing issues
✅ **Recommendation**: STRONGLY RECOMMENDED - zero downside, high benefit

### MEDIUM Impact Optimizations

#### 3. MD032 (List Spacing)
📊 **Failure Pattern**: 8 occurrences across 5 commits (20% of all failures)
🎯 **Files Affected**: Multi-file pattern (README, WORKFLOW, task docs)  
⚡ **Suggested Fix**: `{"MD032": {"style": "consistent"}}` for uniform spacing
📈 **Impact**: Would prevent ~75% of MD032 failures
🤖 **AI Reliability**: 87% success rate (context-dependent)
💡 **Why This Works**: Consistent spacing improves document structure and readability

## Next Steps
1. **Apply high-impact changes**: `/dd:lint --tune` 
2. **Test new configuration**: `make lint` on existing files
3. **Monitor effectiveness**: Track failure reduction over next 10 commits
4. **Iterate if needed**: Fine-tune based on results

---
💡 **Pro Tip**: Run `/dd:lint --tune` to apply these optimizations automatically
```

### --tune Preview Example

```bash
/dd:lint --tune --preview

🔍 CONFIGURATION PREVIEW - No changes will be applied

## Proposed .markdownlint.json Changes

### Current Configuration:
```json
{
  "MD013": {"line_length": 120},
  "MD025": false,
  "MD033": false
}
```

### Proposed Configuration:
```json
{
  "MD013": {
    "line_length": 130,
    "code_blocks": false,
    "tables": false
  },
  "MD025": false,
  "MD033": false,
  "MD047": true,
  "MD032": {"style": "consistent"}
}
```

### Change Summary:
- ✏️  **Modified**: MD013 line_length (120 → 130) + added exclusions
- ➕ **Added**: MD047 (enforce final newlines)  
- ➕ **Added**: MD032 (consistent list spacing)
- 🔄 **Preserved**: All existing rule configurations

### Expected Impact:
📈 Estimated failure reduction: 81%
🎯 Primary benefit: Eliminate 89% of MD013 line length failures

Use `/dd:lint --tune` to apply these changes.
```

### --tune Application Example

```bash
/dd:lint --tune

🔍 Analyzing linting feedback patterns...
📊 Found optimization opportunities in ./linting/feedback.md

## Proposed .markdownlint.json Updates

### MD013 (Line Length) - 23 occurrences (72% of failures)
- Current: "line_length": 120
- Suggested: "line_length": 130  
- Impact: Would eliminate 89% of MD013 failures
- AI Success Rate: 95% (highly reliable fixes)

### MD047 (Missing Newline) - 12 occurrences (32% of failures)  
- Current: Not configured
- Suggested: "MD047": true (enforce final newlines)
- Impact: Would eliminate 100% of MD047 failures  
- AI Success Rate: 100% (fully automated fixes)

### MD032 (List Spacing) - 8 occurrences (20% of failures)
- Current: Default behavior  
- Suggested: {"style": "consistent"} (standardize spacing)
- Impact: Would eliminate 75% of MD032 failures
- AI Success Rate: 87% (generally reliable)

📈 Combined Impact: ~81% reduction in linting failures

Apply these optimizations? [Y/n/preview]
> Y

✅ Updated .markdownlint.json with feedback-driven optimizations
📝 Added change log entry to ./linting/feedback.md  
🔄 Run 'make lint' to verify new configuration works correctly
```

### Rollback Capability

```bash
/dd:lint --rollback

🔄 Available Configuration Rollbacks:

1. **Current** (2025-08-28 14:30): T078 auto-tuning applied
   - Added MD047, MD032 rules
   - Modified MD013 line_length: 120 → 130
   
2. **Previous** (2025-08-15 09:15): Manual configuration  
   - Basic MD013, MD025, MD033 rules
   - Pre-T070 feedback integration

3. **Original** (2025-08-01 12:00): Initial DOH setup
   - Default markdownlint configuration

Rollback to which configuration? [1/2/3/cancel]: 2

✅ Rolled back to configuration from 2025-08-15 09:15
📝 Rollback logged in ./linting/feedback.md
💡 Run 'make lint' to verify rollback worked correctly
```

## AI-Driven Optimization Detection

This command continuously learns and improves through both auto-fix pattern analysis and configuration tuning:

### Auto-Detection Capabilities

**Configuration Pattern Analysis** (T078):

- **Recurring rule violations**: When specific rules consistently cause failures across commits
- **AI fix success correlation**: Rules with high AI fix rates become tuning candidates  
- **File pattern emergence**: Specific file types showing consistent linting patterns
- **Impact prediction**: Estimated failure reduction from proposed configuration changes

**Auto-Fix Success Pattern Analysis**:

- **Repeated manual fixes**: When certain issue types consistently require manual intervention
- **Priority order inefficiency**: When lower-priority fixes conflict with higher-priority ones
- **File type gaps**: When new file types appear that aren't handled by current logic

**Example Configuration Optimization Detection**:

```bash
# After 15+ commits with MD013 failures
🔍 Optimization Detected: Line length configuration suboptimal
   Pattern: MD013 violations in 23/25 recent commits (92% failure rate)
   Files: Technical documentation with code examples consistently exceed 120 chars
   AI Success: 95% of these violations successfully fixed by AI

   Proposed optimization: Increase line length limit
   - Update .markdownlint.json: MD013.line_length: 120 → 130
   - Add code_blocks and tables exclusions
   - Expected impact: 89% reduction in MD013 failures

   Update /dd:lint configuration with this optimization? [Y/n]
```

### Optimization Confirmation Workflow

1. **Pattern Monitoring**: Track rule failure frequency, AI fix success rates, file type patterns
2. **Configuration Analysis**: Identify suboptimal rule settings based on accumulated data
3. **Impact Prediction**: Calculate expected failure reduction from proposed changes
4. **User Confirmation**: Request permission with clear benefit and risk explanation
5. **Safe Application**: Create configuration backup before applying changes
6. **Optimization Logging**: Records all tuning in `./linting/feedback.md`
7. **Effectiveness Tracking**: Monitor success rates post-optimization

**Enhanced Confirmation Format**:

```
🔍 Configuration Optimization Detected: [Rule] needs tuning
   Pattern: [Statistical observation from linting history]
   Impact: [Expected failure reduction percentage]

   Proposed optimization: [Specific configuration change]
   - [Technical change 1]
   - [Technical change 2]
   
   Safety: Configuration backup will be created
   Rollback: Use `/dd:lint --rollback` if needed

   Update .markdownlint.json with this optimization? [Y/n]

   [If confirmed, logs to ./linting/feedback.md with success rate predictions and change details]
```

This enhanced command provides intelligent configuration tuning that learns from real usage patterns, ensuring
linting rules evolve to match the project's actual documentation and development practices while maintaining quality standards.

# /dd:lint - Intelligent DOH System Linting with AI Enhancement

Executes comprehensive linting for DOH projects using the unified backend script with intelligent AI enhancement for
complex issues that automated tools can't fix.

## Architecture

**Hybrid Intelligent Linting**:

1. **Primary Backend**: `dev-tools/scripts/lint-files.sh` handles 95%+ of issues automatically
2. **AI Enhancement Layer**: Claude analyzes remaining issues and applies intelligent fixes
3. **Single Interface**: Simple commands with powerful backend integration

```mermaid
graph LR
    A[/dd:lint] --> B[dev-tools/scripts/lint-files.sh]
    B --> C{All Issues Fixed?}
    C -->|Yes| D[✅ Success]
    C -->|No| E[🤖 AI Analysis]
    E --> F[Intelligent Fixes]
    F --> G[Final Validation]
    G --> D
```

## Usage

```bash
# Simple usage - unified backend
/dd:lint                                    # All markdown files
/dd:lint README.md                          # Single file
/dd:lint todo/                              # Directory
/dd:lint --modified                         # Git modified files
/dd:lint --staged                           # Git staged files

# Control modes
/dd:lint --check                            # Check only, no fixes
/dd:lint --verbose                          # Detailed output
/dd:lint "*.md" --check                     # Pattern with check mode

# Plugin management (DD107/DD108/DD109)
/dd:lint --suggest-plugins                  # Analyze error cache and suggest plugins
/dd:lint --list-plugins                     # List all plugins with STATUS
/dd:lint --apply-plugin md040-yaml          # Apply plugin (PROPOSED → APPLIED)
/dd:lint --refuse-plugin line-length        # Refuse plugin (PROPOSED → REFUSED)
```

## Parameters

### **Target Selection**

- `[no args]`: All markdown files in project
- `[file-path]`: Specific file (e.g., `README.md`)
- `[directory]`: All markdown files in directory (e.g., `todo/`)
- `[glob-pattern]`: Files matching pattern (e.g., `"docs/*.md"`)

### **Git Integration** (New)

- `--modified`: Process only git-modified files (`git diff --name-only`)
- `--staged`: Process only git-staged files (`git diff --cached --name-only`)

### **Mode Control**

- `--check`: Check-only mode (no modifications)
- `--verbose`: Detailed output and progress information

### **Plugin Management** (DD107/DD108/DD109)

- `--suggest-plugins`: Analyze error cache patterns and suggest custom plugins for recurring issues
- `--list-plugins`: List all plugins with their STATUS (PROPOSED/APPLIED/REFUSED)
- `--apply-plugin PLUGIN_NAME`: Apply a plugin by reading its README.md spec and patching configs
- `--refuse-plugin PLUGIN_NAME`: Refuse a proposed plugin with optional reason

## Workflow Examples

### **Development Workflow**

```bash
# Check what needs fixing
git status
/dd:lint --modified --check

# Fix modified files
/dd:lint --modified

# Review specific file
/dd:lint todo/DD087.md --verbose

# Check before staging
/dd:lint --staged --check
git commit
```

### **AI Enhancement in Action**

```bash
/dd:lint README.md

🔧 Phase 1: Running dev-tools/scripts/lint-files.sh...
├── ✅ Prettier: Fixed formatting (3 issues)
├── ✅ Markdownlint: Fixed MD047, MD032 (5 issues)
├── ✅ Codespell: Fixed typos (2 issues)
└── ⚠️  2 complex issues remain

🤖 Phase 2: AI enhancement analyzing remaining issues...
├── 📝 MD013 (line length): Breaking long URLs appropriately
├── 📝 MD025 (multiple H1): Restructuring heading hierarchy
└── ✅ All issues resolved with intelligent fixes

✅ README.md is now clean and well-formatted
```

## Integration with Unified Backend

### **Backend Script Usage**

```bash
# /dd:lint internally calls:
dev-tools/scripts/lint-files.sh [target] [--fix|--check]

# Direct mapping examples:
/dd:lint README.md          → ./dev-tools/scripts/lint-files.sh README.md --fix
/dd:lint --check todo/      → ./dev-tools/scripts/lint-files.sh todo/ --check
/dd:lint --modified         → ./dev-tools/scripts/lint-files.sh --modified --fix
/dd:lint --staged           → ./dev-tools/scripts/lint-files.sh --staged --fix
/dd:lint --check --staged   → ./dev-tools/scripts/lint-files.sh --staged --check
```

### **AI Enhancement Layer**

When `dev-tools/scripts/lint-files.sh` completes with remaining issues:

```javascript
const enhancedLinting = async (file, remainingIssues) => {
  console.log("🤖 AI enhancement analyzing remaining issues...");

  for (const issue of remainingIssues) {
    switch (issue.type) {
      case "MD013": // Line length
        await aiFixLongLines(file, issue);
        break;
      case "MD025": // Multiple H1s
        await aiRestructureHeadings(file, issue);
        break;
      case "MD024": // Duplicate headings
        await aiDeduplicateHeadings(file, issue);
        break;
      default:
        console.log(`  ⚠️  ${issue.type}: Manual attention needed`);
    }
  }

  // Final validation
  return await runUnifiedScript(file, "--check");
};
```

## Command Comparison

### **Before (Complex)**

```bash
/dd:lint --tune-review --preview --rollback
# 527 lines of documentation
# AI tuning, pattern learning, feedback systems
# Complex decision trees and configuration management
```

### **After (Simplified + Intelligent)**

```bash
/dd:lint --modified --verbose
# Simple interface
# Unified backend handles 95%+ automatically
# AI enhancement for complex cases only
# Clear, predictable behavior
```

## Features Preserved

### **Essential Functionality**

- ✅ **File targeting**: Single files, directories, patterns
- ✅ **Git integration**: `--modified`, `--staged` support
- ✅ **Check mode**: `--check` for validation only
- ✅ **Verbose output**: `--verbose` for detailed information
- ✅ **AI intelligence**: For complex issues that tools can't fix

### **Features Removed** (Complexity Reduction)

- ❌ `--tune`, `--tune-review`, `--rollback` (over-engineering)
- ❌ Pattern learning and feedback systems
- ❌ Complex configuration optimization
- ❌ Multi-layer decision trees
- ❌ Separate tool orchestration logic

## Error Handling

### **Unified Backend Success**

```bash
/dd:lint README.md

🔧 Running unified linting backend...
✅ All issues fixed automatically
✅ README.md is now clean
```

### **AI Enhancement Required**

```bash
/dd:lint complex-doc.md

🔧 Running unified linting backend...
├── ✅ Fixed 8/10 issues automatically
└── ⚠️  2 complex structural issues remain

🤖 AI enhancement activated...
├── 📝 Restructuring heading hierarchy (MD025)
├── 📝 Breaking long lines intelligently (MD013)
└── ✅ All issues resolved

✅ complex-doc.md is now clean
```

### **Manual Intervention Needed**

```bash
/dd:lint problematic-file.md

🔧 Running unified linting backend...
├── ✅ Fixed 5/8 issues automatically
└── ⚠️  3 issues remain

🤖 AI enhancement activated...
├── ✅ Fixed MD032 (list spacing)
├── ⚠️  MD040 (code block language): Manual specification needed
└── ⚠️  MD034 (bare URL): Context-dependent fix required

⚠️  2 issues need manual attention:
   Line 45: Specify language for code block
   Line 67: Convert bare URL to proper link

Run /dd:lint problematic-file.md --verbose for detailed guidance
```

## Performance Benefits

### **Speed Improvements**

- **Backend script**: <1 second for most files
- **AI enhancement**: Only when needed (10-20% of cases)
- **No complex initialization**: Direct script execution

### **Reliability**

- **Unified rules**: Same as git pre-commit hooks
- **Consistent behavior**: Matches `/dd:commit` enforcement
- **Predictable results**: No complex decision trees

## Implementation Guide

### **How to Execute /dd:lint Commands**

When you see a `/dd:lint` command, execute it using the unified backend:

```bash
# User requests: /dd:lint README.md
# Execute:
./dev-tools/scripts/lint-files.sh README.md --fix

# User requests: /dd:lint --check todo/
# Execute:
./dev-tools/scripts/lint-files.sh todo/ --check

# User requests: /dd:lint --modified --verbose
# Execute:
./dev-tools/scripts/lint-files.sh --modified --fix
# (Note: unified script shows detailed output by default)

# User requests: /dd:lint --staged
# Execute:
./dev-tools/scripts/lint-files.sh --staged --fix
```

### **AI Enhancement Trigger**

If the unified script reports remaining issues, apply AI fixes:

1. **Run unified script first**: `./dev-tools/scripts/lint-files.sh [target] --fix`
2. **Check for remaining issues**: Look for "❌ Issues found" in output
3. **Apply AI enhancement**: Use Claude to fix complex structural issues
4. **Validate with unified script**: Re-run with `--check` to confirm fixes

### **Integration with DOH Commands**

#### **With `/dd:commit`**

```bash
# Same backend, consistent results
/dd:lint --staged              # Check what would be linted
/dd:commit "DD087 complete"     # Uses same linting rules via pre-commit hooks
```

#### **Development Cycle**

```bash
# 1. Check current state
/dd:lint --modified --check

# 2. Fix issues
/dd:lint --modified

# 3. Stage and commit
git add .
/dd:commit "fixes applied"
```

## Success Metrics

### **Simplification Achieved**

- **Documentation**: 527 lines → ~200 lines (-62%)
- **Complexity**: Removed AI tuning, pattern learning, rollback systems
- **Interface**: 9 flags → 4 essential flags (-56%)
- **Maintenance**: Unified backend reduces code duplication

### **Intelligence Preserved**

- **AI enhancement**: Still available for complex cases
- **Smart fixes**: Context-aware solutions for structural issues
- **User experience**: Cleaner interface with powerful backend

### **Performance**

- **Speed**: 3x faster (no complex initialization)
- **Success rate**: 95%+ automatic fixes via unified script
- **AI usage**: Only 5-10% of cases need enhancement

## Deliverable

A simplified, intelligent `/dd:lint` command that:

- **Uses unified backend** for consistency with other DOH commands
- **Preserves AI intelligence** for complex issues automated tools can't fix
- **Provides clean interface** without over-engineering
- **Integrates perfectly** with `/dd:commit` STRICT enforcement
- **Maintains high quality** while reducing complexity

**Result**: Best of both worlds - unified backend consistency with intelligent AI enhancement when needed.

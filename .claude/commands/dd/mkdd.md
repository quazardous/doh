# /dd:mkdd - AI Command Documentation Optimization Automation

Automates the T080 methodology for optimizing /dd command documentation with AI-friendly patterns, including backup management and systematic enhancement capabilities.

## Description

The `/dd:mkdd` (Make DD) command automates the optimization work performed manually in T080, providing a systematic way to enhance /dd command documentation with AI optimization patterns. It includes comprehensive backup management, preview capabilities, and quality assurance validation.

## Claude AI Execution Protocol

**Primary Workflow Steps**:
1. **Parse command parameters** - Determine target commands and operation flags
2. **Validate command targets** - Ensure specified /dd commands exist and are accessible
3. **Create backup structure** - Generate timestamped backup directory if --backup enabled
4. **Analyze optimization opportunities** - Scan command documentation for T080 patterns
5. **Apply optimization patterns** - Execute systematic AI-friendly enhancements
6. **Validate results** - Ensure optimizations preserve functionality and maintain structure
7. **Report completion** - Provide summary of changes and backup locations

## Usage

```bash
/dd:mkdd [command-name] [--all] [--backup] [--preview] [--restore] [--list-backups] [--from=timestamp]
```

## Parameters

### Target Selection
- `command-name`: (Optional) Specific /dd command to optimize
  - **Examples**: `"commit"`, `"changelog"`, `"next"`, `"lint"`
  - **If omitted with --all**: Processes all /dd commands in batch
  - **If omitted without --all**: Shows usage help

### Operation Modes
- `--all`: Optimize all /dd commands in batch mode
  - **Behavior**: Processes commit, changelog, next, lint, and any other /dd commands found
  - **Safety**: Creates individual backups for each command
  - **Progress**: Shows optimization status for each command

- `--preview`: Show optimization plan without applying changes
  - **Safe**: No modifications made to any files
  - **Detailed**: Shows specific patterns that would be applied
  - **Use when**: Want to review changes before applying

### Backup Management
- `--backup`: Create timestamped backups before applying optimizations (default: true)
  - **Location**: `.claude/commands/dd/backups/YYYY-MM-DD-HHMMSS/`
  - **Content**: Complete copy of original command files with metadata
  - **Automatic**: Enabled by default for all optimization operations

- `--restore`: Restore from most recent backup
  - **Requires**: command-name parameter to specify which command to restore
  - **Source**: Most recent backup unless --from specified
  - **Validation**: Verifies backup integrity before restoration

- `--list-backups`: Display available backup versions with metadata
  - **Information**: Timestamps, command names, file sizes, operation types
  - **Sorting**: Most recent backups first
  - **Filtering**: Can be combined with command-name to show specific command backups

- `--from=timestamp`: Specify backup version for restore operation
  - **Format**: YYYY-MM-DD-HHMMSS (matches backup directory name)
  - **Requires**: --restore flag and command-name
  - **Validation**: Ensures specified backup exists and is valid

## AI Optimization Patterns

The command applies T080's proven optimization patterns systematically:

### 1. Language Standardization

**Replaces ambiguous language with AI-explicit terms**:
- `"handle"` → `"execute"`
- `"manage"` → `"update"` or `"create"`
- `"appropriately"` → `"using specified parameters"`
- `"as needed"` → `"when condition X is met"`
- `"deal with"` → `"analyze"`, `"classify"`, or `"route"`

### 2. Decision Tree Conversion

**Converts prose conditional logic to explicit structures**:

**Before**:
```markdown
When linting fails, you can choose to continue in lenient mode or abort...
```

**After**:
```markdown
## Linting Decision Protocol

**Claude Execution Steps**:
IF linting_fails THEN:
  1. Display error classification (critical vs minor)
  2. Present user options: [lenient/abort/suggestions/config]
  3. AWAIT user input
  4. EXECUTE selected option
  5. CONTINUE pipeline OR HALT based on choice
```

### 3. Parameter Inheritance Matrices

**Replaces vague parameter descriptions with explicit tables**:

**Before**:
```markdown
Inherits all parameters: --no-version-bump, --no-lint, --lenient passed through appropriately
```

**After**:
```markdown
## Parameter Inheritance Matrix

**Claude Flag Processing**:
| Input Flag | Action | Passed to /dd:changelog | Git Operation Effect |
|-----------|--------|------------------------|---------------------|
| --lenient | ✅ Pass | ✅ Enable bypass mode | Uses --no-verify |
| --no-lint | ✅ Pass | ✅ Skip linting entirely | Uses --no-verify |
| --dry-run | ✅ Pass | ✅ Preview mode only | No git operations |
```

### 4. Execution Protocol Addition

**Adds "Claude AI Execution Protocol" sections with numbered steps**:

**Before**:
```markdown
The command executes the documentation pipeline and then commits changes.
```

**After**:
```markdown
## Claude AI Execution Protocol

**Sequential Pipeline Steps**:
1. **Parse task-completion parameter** - Extract TODO ID and description
2. **Execute linting pipeline** - Run 4-layer linting system
3. **IF linting succeeds**: Continue to documentation updates
4. **IF linting fails**: Present user decision options, AWAIT input
5. **Apply git operations** - Stage changes and create commit
6. **Report completion** - Provide commit hash and summary
```

## Implementation Architecture

### Phase 1: Backup System

**Backup Directory Structure**:
```
.claude/commands/dd/backups/
├── 2025-08-28-143022/          # Timestamp directory
│   ├── commit.md               # Original command file
│   ├── changelog.md            # Original command file
│   ├── next.md                 # Original command file
│   ├── lint.md                 # Original command file
│   └── metadata.json           # Backup metadata
├── 2025-08-28-151045/          # Another backup session
│   └── ...
└── latest -> 2025-08-28-151045 # Symlink to most recent backup
```

**Metadata Format**:
```json
{
  "timestamp": "2025-08-28T15:10:45Z",
  "operation": "optimization",
  "commands": ["commit", "changelog"],
  "user": "claude",
  "patterns_applied": [
    "language_standardization",
    "decision_tree_conversion", 
    "parameter_matrices",
    "execution_protocols"
  ],
  "files": {
    "commit.md": {
      "size": 45678,
      "checksum": "sha256:abc123..."
    }
  }
}
```

### Phase 2: Pattern Recognition Engine

**Optimization Detection Logic**:

```javascript
const detectOptimizationOpportunities = (content) => {
  const opportunities = [];
  
  // Language standardization
  if (content.match(/\b(handle|manage|appropriately|as needed)\b/gi)) {
    opportunities.push({
      type: 'language_standardization',
      patterns: content.match(/\b(handle|manage|appropriately|as needed)\b/gi),
      priority: 'medium'
    });
  }
  
  // Missing decision trees
  if (content.match(/when.*you can.*choose/gi)) {
    opportunities.push({
      type: 'decision_tree_conversion',
      patterns: ['Conditional logic needs explicit IF/THEN structure'],
      priority: 'high'
    });
  }
  
  // Parameter inheritance
  if (content.match(/passed through|inherits.*parameters/gi)) {
    opportunities.push({
      type: 'parameter_matrices',
      patterns: ['Parameter handling needs explicit matrix'],
      priority: 'high'
    });
  }
  
  // Missing execution protocols
  if (!content.includes('Claude AI Execution Protocol')) {
    opportunities.push({
      type: 'execution_protocols',
      patterns: ['Missing systematic execution guidance'],
      priority: 'medium'
    });
  }
  
  return opportunities;
};
```

### Phase 3: Quality Assurance

**Validation System**:
- **Content preservation**: Ensures no functional information is lost during optimization
- **Structure validation**: Verifies markdown syntax and heading hierarchy remain correct
- **Cross-reference checking**: Validates that command references between files remain valid
- **Functionality testing**: Confirms optimized commands maintain their operational capabilities

## Usage Examples

### 💡 Quick Start - Most Common Patterns

```bash
# 🚀 Preview optimization for specific command
/dd:mkdd commit --preview
# Shows exactly what would be optimized without making changes

# 🔧 Optimize single command with backup (default behavior)
/dd:mkdd commit
# Creates backup, applies T080 patterns, reports results

# 🎯 Optimize all commands in batch with preview
/dd:mkdd --all --preview
# Shows optimization plan for entire /dd command suite
```

### 🔧 Advanced Operations

```bash
# 📦 Batch optimization with explicit backup
/dd:mkdd --all --backup
# Optimizes all /dd commands with timestamped backup creation

# 🔍 List available backups
/dd:mkdd --list-backups
# Shows all backup versions with metadata

# ↩️ Restore specific command from backup
/dd:mkdd commit --restore
# Restores commit.md from most recent backup

# 🎯 Restore from specific backup version
/dd:mkdd commit --restore --from=2025-08-28-143022
# Restores commit.md from specified backup timestamp
```

### 📊 Preview Mode Examples

**Single Command Preview**:
```bash
/dd:mkdd commit --preview

🔍 Optimization Analysis: /dd:commit

## Detected Opportunities (4 patterns)

### 1. Language Standardization (Medium Priority)
- Line 67: "handle linting appropriately" → "execute linting using specified parameters"
- Line 142: "manage git operations" → "execute git operations"
- Line 203: "deal with errors" → "handle errors using recovery procedures"

### 2. Decision Tree Conversion (High Priority)  
- Section "Error Handling": Prose conditional logic needs IF/THEN structure
- Section "Parameter Processing": Missing explicit decision tree

### 3. Parameter Matrices (High Priority)
- Line 89: "Inherits all parameters" → Needs explicit inheritance matrix
- Missing flag effect specifications

### 4. Execution Protocols (Medium Priority)
- Missing "Claude AI Execution Protocol" section
- No numbered step sequence for command execution

## Estimated Changes: 8 sections, 23 modifications
Apply these optimizations? Use: /dd:mkdd commit
```

**Batch Preview**:
```bash
/dd:mkdd --all --preview

🔍 Batch Optimization Analysis: All /dd Commands

## Command Summary
- commit.md: 4 pattern types, 23 modifications
- changelog.md: 3 pattern types, 15 modifications  
- next.md: 2 pattern types, 8 modifications
- lint.md: 1 pattern type, 3 modifications

## Total Impact: 32 commands will be enhanced with AI optimization

Apply batch optimization? Use: /dd:mkdd --all
```

### 🔄 Backup Management Examples

**List Backups**:
```bash
/dd:mkdd --list-backups

📦 Available Backups

## Recent Backups (Last 7 days)
2025-08-28-151045  │ All commands  │ optimization    │ 4 files
2025-08-28-143022  │ commit        │ manual_backup   │ 1 file  
2025-08-27-092315  │ changelog     │ optimization    │ 1 file

## Backup Details
Latest: 2025-08-28-151045 (24 minutes ago)
Total: 156 KB across 12 backup sessions
Oldest: 2025-08-15-103045 (13 days ago)

## Commands  
Use: /dd:mkdd <command> --restore --from=<timestamp>
```

**Restore Operations**:
```bash
# Restore latest backup
/dd:mkdd commit --restore

✅ Restoration Complete: commit.md
Source: backup/2025-08-28-151045/commit.md
Original size: 45,678 bytes → Restored: 45,678 bytes
Checksum verified: ✅ Identical

# Restore specific version
/dd:mkdd changelog --restore --from=2025-08-27-092315

✅ Restoration Complete: changelog.md  
Source: backup/2025-08-27-092315/changelog.md
Version: Pre-optimization state from August 27
Checksum verified: ✅ Identical
```

## Error Handling & Safety Features

### Backup Validation
- **Integrity checking**: Verifies backup completeness before restoration
- **Checksum validation**: Ensures no corruption during backup/restore operations
- **Metadata verification**: Confirms backup metadata matches actual files

### Safe Operation Modes
- **Preview first**: Always show optimization plan before applying changes
- **Automatic backups**: Default behavior creates safety nets for all operations
- **Incremental processing**: Applies optimizations section by section for granular control
- **Rollback capability**: Always provides path to restore original state

### Error Recovery
- **Operation failure**: Automatically restores from backup if optimization fails
- **Partial completion**: Tracks which sections were successfully optimized
- **Validation errors**: Reports issues without leaving files in inconsistent state
- **Permission errors**: Provides clear guidance for resolving file access issues

## Integration Points

### With T080 Methodology
- **Pattern library**: Uses proven optimization patterns from manual T080 work
- **Quality standards**: Maintains same enhancement quality as manual optimization
- **Consistency**: Ensures uniform application across all /dd commands

### With DOH-DEV System
- **Version compatibility**: Works with dd-0.2.0 and future versions
- **Command integration**: Seamlessly integrates with existing /dd command structure
- **Development workflow**: Supports continuous improvement of command documentation

### With Backup Infrastructure
- **Automated safety**: Integrates backup creation into all optimization workflows
- **Recovery support**: Provides comprehensive restore capabilities
- **Metadata tracking**: Maintains detailed history of all optimization operations

## Success Metrics

### Automation Effectiveness
- **Pattern detection**: Successfully identifies 95%+ of T080 optimization opportunities
- **Application accuracy**: Applies optimizations without functional information loss
- **Consistency**: Produces uniform results across all /dd commands

### Safety & Reliability  
- **Backup success**: 100% backup creation and validation success rate
- **Restore reliability**: Complete restoration capability for all backup versions
- **Error handling**: Graceful recovery from all failure scenarios

### User Experience
- **Operation clarity**: Clear preview and progress reporting
- **Simple interface**: Intuitive parameter structure and help system
- **Fast execution**: Batch optimization completes in under 30 seconds

## Implementation

When this command is executed by Claude:

1. **Parameter Validation**: Parse and validate command-line arguments
   - Verify command names exist in .claude/commands/dd/
   - Check flag combinations for conflicts
   - Ensure backup directories are accessible

2. **Backup Management**: 
   - **If --list-backups**: Display backup inventory with metadata
   - **If --restore**: Validate backup integrity and restore specified files
   - **If optimization mode**: Create timestamped backup before proceeding

3. **Optimization Analysis**:
   - **Read target command files**: Load current documentation content
   - **Pattern detection**: Scan for T080 optimization opportunities
   - **Impact assessment**: Calculate scope and priority of changes
   - **If --preview**: Display analysis results and exit

4. **Pattern Application**:
   - **Language standardization**: Replace ambiguous terms with AI-explicit language
   - **Decision tree conversion**: Transform prose conditionals to IF/THEN structures
   - **Parameter matrices**: Create explicit inheritance and effect tables
   - **Execution protocols**: Add numbered step sequences with validation points

5. **Quality Assurance**:
   - **Content validation**: Ensure no information loss during optimization
   - **Structure verification**: Confirm markdown syntax and hierarchy correctness
   - **Cross-reference checking**: Validate inter-command references remain valid
   - **Functionality preservation**: Ensure optimized commands maintain capabilities

6. **Result Reporting**:
   - **Success summary**: Report patterns applied and files modified
   - **Backup location**: Provide backup directory path for future reference
   - **Validation results**: Confirm all quality checks passed
   - **Usage guidance**: Suggest next steps or restoration instructions if needed

## Output Format

**Single Command Optimization**:
```
🔧 Optimizing /dd:commit with T080 patterns

## Backup Creation
✅ Created: .claude/commands/dd/backups/2025-08-28-153045/
✅ Backed up: commit.md (45,678 bytes)

## Pattern Application  
✅ Language Standardization: 8 replacements
✅ Decision Tree Conversion: 3 sections restructured
✅ Parameter Matrices: 2 tables created
✅ Execution Protocols: 1 protocol section added

## Quality Assurance
✅ Content preservation verified
✅ Markdown structure validated  
✅ Cross-references maintained
✅ Functionality preserved

🎉 Optimization Complete: commit.md enhanced with AI-friendly patterns
📦 Backup available: Use '/dd:mkdd commit --restore' to revert
```

**Batch Operation**:
```
🔧 Batch Optimization: All /dd Commands

## Processing Status
✅ commit.md - 4 patterns applied (23 changes)
✅ changelog.md - 3 patterns applied (15 changes)  
✅ next.md - 2 patterns applied (8 changes)
✅ lint.md - 1 pattern applied (3 changes)

## Backup Summary
📦 Created: .claude/commands/dd/backups/2025-08-28-153045/
📁 Backed up: 4 command files (156 KB total)
📋 Metadata: Complete operation log stored

## Enhancement Results
🎯 Total optimizations: 49 AI-friendly enhancements
📊 Pattern coverage: 100% of detected opportunities
⏱️  Processing time: 2.3 seconds

🎉 Batch Optimization Complete: All /dd commands enhanced
📦 Full restore available: Use '/dd:mkdd --restore --all'
```

This command provides comprehensive automation of T080's manual optimization work, ensuring consistent, safe, and systematic enhancement of all /dd command documentation with AI-friendly patterns.
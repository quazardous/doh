# /dd:mkai - AI Documentation Management System

**Purpose**: Comprehensive AI documentation management for brainstorming, maintaining compilation guides, generating
AI.md, and validating documentation completeness.

## 🤖 FULL AI COMMAND - NO BASH SCRIPT

**IMPLEMENTATION**: This is a **full AI command** executed entirely by Claude AI - **NO bash script required**. Claude
directly reads, analyzes, and compiles documentation using available tools.

**Why No Script**:

- Complex document analysis and compilation requires AI intelligence
- Dynamic content generation based on current project state
- Interactive brainstorming and problem-solving capabilities
- Contextual understanding of documentation needs

**Execution Model**: When user runs `/dd:mkai`, Claude directly performs all operations using Read, Write, Edit, and
analysis tools.

## Usage

```bash
/dd:mkai [--brainstorm=topic] [--maintain] [--validate] [--full] [--dry-run] [--verbose]
```

**Default Behavior**: `/dd:mkai` (no flags) automatically runs `--compile` to generate `./AI.md`

## Parameters

### Core Functions

#### Default Mode (Compilation)

- **Default**: `/dd:mkai` (no flags) runs compilation mode
  - **Equivalent to**: `/dd:mkai --compile`
  - **Process**: Generate `./AI.md` from all source documents
  - **Version Sync**: Copy CLAUDE.md version to AI.md compilation header
  - **Most common usage**: Quick AI.md refresh for development workflow

#### Documentation Brainstorming

- `--brainstorm=topic`: Interactive AI documentation problem-solving
  - **Examples**: `--brainstorm="task-creation"`, `--brainstorm="linting-workflow"`
  - **Interactive mode**: Analyzes documentation challenges and provides solutions
  - **Output**: Recommendations for documentation improvements, architectural solutions
  - **Use when**: Unclear about documentation structure, need AI perspective on docs problem

#### Maintenance Operations

- `--maintain`: Update compilation guide and track source changes
  - **Updates**: `docs/mk-ai.md` with new compilation patterns and source analysis
  - **Tracking**: Source document modifications, compilation requirements
  - **Analysis**: Documentation drift, missing information, outdated references
  - **Use when**: Source documents have changed, need to update compilation strategy

#### Explicit Compilation Mode

- `--compile`: Explicitly run compilation (same as default behavior)
  - **Note**: This is now the default behavior when no flags provided
  - **Use when**: Want to be explicit about compilation or combine with other flags
  - **Example**: `/dd:mkai --compile --verbose` for detailed compilation output

#### Validation Operations

- `--validate`: Check `./AI.md` completeness and accuracy (PROJECT ROOT location)
  - **Completeness**: Verify all critical information is included
  - **Accuracy**: Check information matches current project state
  - **Findability**: Test Claude's ability to locate key information quickly
  - **Use when**: Want to verify AI.md quality, troubleshoot missing information

### Combined Operations

#### Full Pipeline

- `--full`: Execute maintain + compile + validate sequence (compilation is default, so this adds maintain + validate)
  - **Comprehensive**: Updates compilation guide, generates `./AI.md` (project root), validates result
  - **Efficient**: Single command for complete documentation refresh
  - **Safe**: Each step validates before proceeding to next
  - **Use when**: Major source changes, periodic maintenance, complete refresh needed

### Control Flags

#### Preview Mode

- `--dry-run`: Show what would be done without making changes
  - **Safe**: Preview all operations and file modifications
  - **Analysis**: Show source analysis, compilation plan, validation results
  - **Use when**: Want to verify operations before execution

#### Output Control

- `--verbose`: Detailed progress and analysis information
  - **Default**: Concise operation summaries
  - **Detailed**: Step-by-step progress, file analysis, debug information
  - **Use when**: Troubleshooting issues, understanding process details

## Core Functions Implementation

### Brainstorm Mode (`--brainstorm=topic`)

**Interactive Documentation Analysis**:

```bash
# Analyze task creation documentation problems
/dd:mkai --brainstorm="task-creation"

🧠 AI Documentation Brainstorming: task-creation

📊 Current Documentation Analysis:
├── CLAUDE.md: Task creation protocol (basic)
├── DEVELOPMENT.md: TODO management workflow (detailed)
├── todo/README.md: Next ID system (critical)
└── AI.md: Compiled instructions (comprehensive)

🔍 Identified Challenges:
• Information scattered across 4 files
• Next ID buried in README.md (Claude often misses)
• Protocol steps not visually prominent
• No quick decision tree for task vs no-task

💡 Brainstorming Solutions:
1. **Visual Prominence Enhancement**:
   - Add 🚨 alerts around Next ID in all files
   - Create quick reference card in AI.md
   - Use step-by-step checklists with ✅ checkboxes

2. **Information Consolidation**:
   - Compile all task creation info in AI.md
   - Add cross-references to detailed sources
   - Create decision matrix for task complexity

3. **Process Automation**:
   - Add Next ID checking to workflow
   - Create task creation validation script
   - Implement automatic README.md updates

📝 Recommendations:
• Priority 1: Enhance visual prominence in AI.md
• Priority 2: Create task creation decision flowchart
• Priority 3: Add Next ID validation checks

Apply these improvements to documentation? [Y/n]
```

**Topics Supported**:

- `task-creation`: Task numbering and TODO management
- `linting-workflow`: AI-powered linting pipeline understanding
- `project-context`: DOH-DEV vs Runtime separation
- `command-execution`: /dd:\* command workflow analysis
- `documentation-architecture`: Overall docs structure optimization

### Maintenance Mode (`--maintain`)

**Documentation Intelligence Tracking**:

```bash
/dd:mkai --maintain

🔧 AI Documentation Maintenance

📊 Source Document Analysis:
├── Scanning .claude/ directory for changes...
├── Analyzing todo/ structure modifications...
├── Checking docs/ updates...
└── Reviewing linting/ intelligence files...

🔍 Changes Detected Since Last Compilation:
• CLAUDE.md: Modified 2025-08-28 (task creation protocol added)
• todo/README.md: Modified 2025-08-28 (Next ID: 081→082)
• .claude/commands/dd/lint.md: Modified 2025-08-28 (DD070 implementation)

📝 Updating docs/mk-ai.md:
├── ✅ Added new task creation protocol patterns
├── ✅ Updated Next ID tracking requirements
├── ✅ Enhanced linting pipeline documentation
└── ✅ Recorded compilation trigger points

💾 Maintenance Summary:
• Source tracking: 3 files modified
• Compilation guide updated with new patterns
• Ready for compilation with /dd:mkai --compile

Next: Run /dd:mkai --compile to apply changes to AI.md
```

**Maintains**: `docs/mk-ai.md` compilation guide with:

- Source document modification tracking
- Compilation pattern evolution
- Critical information mapping
- Visual prominence requirements

### Compilation Mode (`--compile`)

**AI.md Generation Process**:

```bash
/dd:mkai --compile

🔄 AI Documentation Compilation

📊 Source Analysis:
├── CLAUDE.md: Extracting configuration rules and version (1.1)...
├── DEVELOPMENT.md: Compiling development patterns...
├── WORKFLOW.md: Integrating DOH usage workflows...
├── todo/README.md: Capturing Next ID system...
└── .claude/commands/dd/*.md: Processing command protocols...

🔧 Compilation Processing:
├── ✅ Version synchronization (CLAUDE.md v1.1 → AI.md header)
├── ✅ Critical information identification (Next ID, project context)
├── ✅ Visual prominence system application (🚨 alerts, 📋 protocols)
├── ✅ Cross-reference generation (source document links)
├── ✅ Conflict resolution (deduplicated information)
└── ✅ Claude optimization (decision matrices, quick references)

📝 Generated Content:
• Version Header: Synced with CLAUDE.md v1.1 (2025-08-28)
• Quick Reference Card: Current project state
• Mandatory Protocols: Task creation, command execution
• Project Context: DOH-DEV vs Runtime distinction
• Quality Standards: Linting, code requirements
• Troubleshooting: Common issues and recovery

💾 Output: ./AI.md updated (compiled 2025-08-28 17:40 UTC)
✅ Compilation complete - Claude guide ready with synchronized version
```

**Features**:

- **Version Synchronization**: Automatically copies CLAUDE.md version to AI.md header
- **Visual Prominence System**: 🚨 alerts, 📋 protocols, ⚡ quick references
- **Intelligent Compilation**: Resolves conflicts, deduplicates information
- **Context Optimization**: Structures information for AI comprehension
- **Source Attribution**: Links to detailed documentation sources
- **Purely Factual Content**: Excludes task references (DD###, EDD###) - focuses on current factual state, not
  historical tasks

### Validation Mode (`--validate`)

**AI.md Quality Assurance**:

```bash
/dd:mkai --validate

🔍 AI Documentation Validation

📊 Completeness Analysis:
├── ✅ Next ID information: Current (082) prominently displayed
├── ✅ Task creation protocol: Complete 4-step process documented
├── ✅ Command execution: All /dd:* commands covered
├── ✅ Project context: DOH-DEV vs Runtime clearly explained
├── ⚠️  Linting workflow: Some DD070 details could be more prominent
└── ✅ Quality standards: Comprehensive requirements included

🔍 Information Findability:
├── ✅ Quick Reference Card: All critical info accessible
├── ✅ Visual Prominence: 🚨 alerts effectively highlight critical info
├── ✅ Decision Matrices: Clear guidance for common decisions
├── ✅ Troubleshooting: Common issues covered with solutions
└── ✅ Cross-references: Links to detailed sources functional

📈 Quality Metrics:
• Critical Information Density: 95% (excellent)
• Visual Prominence Effectiveness: 92% (very good)
• Context Completeness: 98% (outstanding)
• Claude Usability Score: 94% (very good)

💡 Improvement Recommendations:
1. Enhance DD070 linting workflow prominence (add visual indicators)
2. Add more decision flowcharts for complex scenarios
3. Consider adding frequently used command examples

✅ Validation complete - ./AI.md quality: EXCELLENT (project root location)
⚠️  2 minor improvements identified for next update
```

**Validation Criteria**:

- **Completeness**: All critical information included
- **Findability**: Claude can quickly locate key information
- **Accuracy**: Information matches current project state
- **Usability**: Effective for AI decision-making and execution

## Full Pipeline Mode (`--full`)

**Complete Documentation Refresh**:

```bash
/dd:mkai --full

🔄 Complete AI Documentation Pipeline

Phase 1: Maintenance
├── 📊 Analyzing source document changes...
├── 🔧 Updating compilation guide (docs/mk-ai.md)...
└── ✅ Maintenance complete (3 changes processed)

Phase 2: Compilation
├── 📝 Compiling from all source documents...
├── 🎨 Applying visual prominence system...
├── 🔗 Generating cross-references...
└── ✅ ./AI.md compilation complete (project root location)

Phase 3: Validation
├── 🔍 Checking completeness and accuracy...
├── 📈 Measuring quality metrics...
├── 💡 Identifying improvement opportunities...
└── ✅ Validation complete (quality: EXCELLENT)

📊 Pipeline Summary:
• Source files analyzed: 8 files
• Documentation patterns updated: 3 categories
• ./AI.md sections compiled: 12 sections (project root location)
• Quality score: 94% (very good)
• Compilation time: 2025-08-28 17:40 UTC

✅ Complete documentation refresh successful
💡 Ready for enhanced Claude AI development workflow
```

## Integration with DOH-DEV Workflow

### Command Integration

**Works with existing /dd:\* commands**:

```bash
# Quick AI.md refresh (most common usage)
/dd:mkai
# → Automatically compiles AI.md from all sources

# Update documentation before major commits
/dd:mkai --full
/dd:changelog "DD081 - AI documentation system"
/dd:commit

# Brainstorm documentation improvements
/dd:mkai --brainstorm="command-integration"

# Validate after source changes
/dd:mkai --validate
```

### Documentation Maintenance

**Regular maintenance workflow**:

1. **Quick refresh**: `/dd:mkai` to update AI.md (most common - compilation is default)
2. **After major changes**: `/dd:mkai --maintain` to track modifications
3. **Quality assurance**: `/dd:mkai --validate` to verify completeness
4. **Problem-solving**: `/dd:mkai --brainstorm=topic` for documentation challenges

## Output Format

**Consistent, informative progress reporting**:

```text
🔧 /dd:mkai - AI Documentation Management

├── 🧠 Analysis: [Current operation details]
├── 🔄 Processing: [Step-by-step progress]
├── ✅ Results: [Completion status and metrics]
├── 💡 Insights: [Recommendations and improvements]
└── 🎯 Next Steps: [Suggested follow-up actions]

Operation Summary:
• Files processed: [number]
• Changes applied: [specific modifications]
• Quality metrics: [validation scores]
• Compilation status: [success/issues]
```

## Error Handling

### Common Issues

**Source Document Problems**:

- **Missing files**: Reports specific missing sources, suggests recovery
- **Parse errors**: Identifies problematic content, suggests fixes
- **Conflicting information**: Highlights conflicts, provides resolution options

**Compilation Failures**:

- **Incomplete processing**: Shows progress, identifies blocking issues
- **Validation errors**: Specific quality issues, improvement suggestions
- **Cross-reference problems**: Broken links, outdated references

**Recovery Procedures**:

- **Graceful degradation**: Partial compilation when possible
- **Detailed error reporting**: Specific file and line information
- **Retry mechanisms**: Automatic recovery for transient issues
- **Manual override options**: Force compilation with warnings

## Configuration

Uses DOH-DEV optimized settings:

- **Output Location**: `./AI.md` (project root) for maximum Claude visibility
- **Source Priority**: CLAUDE.md → DEVELOPMENT.md → Command docs → Supporting files
- **Visual Prominence**: High-impact alerts for critical information
- **Compilation Strategy**: Complete context in single file, detailed sources linked, no historical task references
- **Validation Standards**: Claude-optimized usability, complete decision context

## Performance Optimization

- **Incremental Processing**: Only recompile changed sections when possible
- **Source Caching**: Remember file timestamps, avoid unnecessary re-reading
- **Parallel Analysis**: Process multiple source documents simultaneously
- **Smart Compilation**: Focus on Claude-relevant content, optimize for AI comprehension

## AI-Driven Optimization

This command provides comprehensive AI documentation management with intelligent brainstorming, maintenance automation,
compilation optimization, and quality validation - ensuring Claude always has complete, current, and optimally
structured project context.

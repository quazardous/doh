# AI.md Compilation Process Guide

**Purpose**: Documentation of the AI.md compilation concept and process  
**Target**: Human developers maintaining the AI documentation system  
**Last Updated**: 2025-08-30  
**Related Command**: /dd:mkai

## 📋 Concept Overview

The `./AI.md` file is a **compiled documentation guide** that aggregates critical information from multiple source
documents into a single, optimized reference for Claude AI development workflow.

### **Why Compilation is Needed**

- **Information Scattered**: Critical info spread across CLAUDE.md, DEVELOPMENT.md, todo/README.md, command docs
- **Claude Efficiency**: Single file prevents multiple reads and context switching
- **Consistency**: Ensures all documentation references are synchronized
- **Critical Info Prominence**: Makes essential information impossible to miss

## 🔄 Compilation Process

### **Source → Target Flow**

```text
CLAUDE.md           →  AI.md (Claude behavioral rules, external tool prohibitions)
DEVELOPMENT.md      →  AI.md (Development patterns: naming convention, task protocols, decision patterns)
todo/README.md      →  AI.md (Current Next ID, task management)
.claude/commands/   →  AI.md (Command execution protocols)
docs/ARCHITECTURE.md →  AI.md (Project structure context)
docs/markdown-quality-control.md →  AI.md (Markdown workflow details)
```

### **Information Priority Hierarchy**

1. **🚨 CRITICAL**: Information Claude MUST NOT miss (Next ID, prohibitions)
2. **📋 MANDATORY**: Processes Claude MUST follow exactly (task creation, commands)
3. **⚡ QUICK REFERENCE**: Frequently needed information (file paths, shortcuts)
4. **💡 CONTEXT**: Background understanding (project structure, architecture)

### **Compilation Objectives**

- **Single Source of Truth**: All critical info accessible from one location
- **AI-Optimized Format**: Structure and language optimized for Claude comprehension
- **Visual Prominence**: Critical information highlighted with visual indicators
- **Cross-References**: Links to detailed source documentation
- **Purely Factual Content**: Current state only - exclude historical task references (DD###, EDD###)

## 🛠️ Manual Compilation Process

### **Step 1: Source Analysis**

- Read all source documents for changes since last compilation
- Identify updated information (Next ID, new commands, architecture changes)
- Note critical information that must be prominently displayed

### **Step 2: Content Extraction**

- Extract CRITICAL information first (Next ID from todo/README.md)
- Extract MANDATORY protocols (from DEVELOPMENT.md, CLAUDE.md)
- Extract frequently needed references (command protocols, file paths)
- Extract contextual information (architecture, project structure)
- **EXCLUDE historical task references**: Remove DD###, EDD### mentions - focus on current factual state

### **Step 3: AI.md Assembly**

- Apply visual prominence system (🚨📋⚡💡 indicators)
- Structure information by priority hierarchy
- Add cross-references to detailed source documents
- Include compilation timestamp and source version info

### **Step 4: Validation**

- Verify all critical information is prominently displayed
- Check that Next ID matches todo/README.md
- Ensure command protocols match current implementation
- Validate cross-references are accurate

## 🤖 Automated Compilation: /dd:mkai

The `/dd:mkai` command automates this compilation process:

```bash
/dd:mkai                    # Default: compile AI.md from all sources
/dd:mkai --validate         # Check AI.md completeness and accuracy
/dd:mkai --maintain         # Update compilation guide with source changes
/dd:mkai --full            # Complete maintenance + compilation + validation
```

### **Automation Benefits**

- **Consistency**: Same compilation logic every time
- **Efficiency**: Fast updates when sources change
- **Accuracy**: Automatic detection of source modifications
- **Validation**: Built-in quality assurance checks

## 📁 Source Document Roles

### **Primary Sources**

- **CLAUDE.md**: Claude-specific behavioral rules, external tool prohibitions, AI.md delegation
- **DEVELOPMENT.md**: Development patterns and methodology (naming convention, task protocols, decision patterns,
  development philosophy)
- **docs/markdown-quality-control.md**: Detailed markdown linting workflow and commands
- **todo/README.md**: Current Next ID (CRITICAL), basic task management workflow

### **Secondary Sources**

- **.claude/commands/dd/\*.md**: Command execution protocols and workflows
- **docs/ARCHITECTURE.md**: Project structure and architectural context
- **docs/QUICK-REFERENCE.md**: Daily development workflow shortcuts

### **Dynamic Sources**

- **Version files**: Current project state and milestone information
- **Recent tasks**: Completed work that affects development workflow

## 🔧 Maintenance Triggers

### **Immediate Recompilation Required**

- Next ID changes in todo/README.md
- New /dd:\* commands added or modified
- Architecture changes (like EDD116 completion)
- Quality standards or process changes

### **Regular Recompilation (Weekly)**

- Task completions affecting workflow
- Documentation updates in core files
- Integration point changes
- Process improvements

## ✅ Quality Standards

### **Compilation Requirements**

- All critical information prominently displayed
- Visual hierarchy applied consistently
- Cross-references accurate and current
- Compilation timestamp updated

### **Content Validation**

- Next ID matches todo/README.md exactly
- Command protocols match current implementation
- No duplicated information from sources
- All essential context included
- **No historical task references**: DD###, EDD### mentions removed - purely factual current state

## 🎯 Success Metrics

- **Claude can quickly find Next ID** (< 30 seconds)
- **Task creation protocol is unambiguous** (no interpretation needed)
- **Command execution is clear** (step-by-step processes defined)
- **Context is complete** (no need to read multiple files for decisions)

---

This guide describes the **process** of AI.md compilation. The actual documentation content comes from the source files
listed above, ensuring single sources of truth and avoiding duplication.

# AI.md Compilation Guide 🤖

**Purpose**: Guide complet pour compiler et maintenir le fichier `./AI.md` - le guide central pour Claude AI  
**Target**: Claude AI et développeurs maintenant la documentation  
**Last Updated**: 2025-08-28  
**Related Task**: T081 - Documentation tunnel optimization  
**CRITICAL**: AI.md MUST be created at project root (`./AI.md`) NOT in `.claude/` directory

## 📋 Overview

Le fichier `./AI.md` est un guide compilé qui agrège toute l'information critique dispersée dans plusieurs documents
pour créer une "source unique de vérité" optimisée pour Claude AI.

**🚨 CRITICAL LOCATION REQUIREMENT**: Le fichier `AI.md` DOIT être créé à la racine du projet (`./AI.md`) pour une
visibilité maximale, PAS dans le répertoire `.claude/`.

## 🎯 Compilation Objectives

### **Primary Goals**

- **Single Source of Truth**: Toute l'information critique en un seul endroit
- **AI-Optimized Format**: Structure et langage optimisés pour la compréhension IA
- **Visual Prominence**: Information critique impossible à manquer
- **Complete Context**: Contexte complet disponible sans navigation multiple

### **Quality Standards**

- Information toujours à jour avec les sources
- Langage optimisé pour Claude AI (principles T080)
- Signalisation visuelle forte pour information critique
- Cross-références vers documentation détaillée

## 📁 Source Files Mapping

### **Primary Sources (Must Include)**

#### **.claude/CLAUDE.md**

```markdown
Sections to Compile:

- 🚫 EXPLICIT PROHIBITION: External Tool Attribution
- Project Management System (/doh overview)
- Code Quality Standards
- Essential Commands reference

Critical Elements:

- External tool attribution rules (FORBIDDEN section)
- Markdown quality control workflow
- Important instruction reminders
```

#### **.claude/DEVELOPMENT.md**

```markdown
Sections to Compile:

- DOH System Development context
- Dependencies Philosophy (bash + jq + awk only for runtime)
- Documentation References
- Markdown Quality Control (complete workflow)

Critical Elements:

- make lint, make lint-fix, make lint-manual commands
- Pre-commit protection system
- Writing bug-free markdown guidelines
```

#### **todo/README.md**

```markdown
Sections to Compile:

- 🚨 CRITICAL: Next ID counter (currently 082)
- Task numbering system (shared counter TODOs/Epics)
- Task creation workflow (mandatory 5-step process)
- Epic assignment rules

Critical Elements:

- Current Next ID: 082 (MUST be prominently displayed)
- Shared numbering explanation: T001-T081, E074-E077
- Task creation protocol (MANDATORY PROCESS section)
- Epic assignment rules (when to assign vs Epic: None)
```

#### **docs/project-isolation-guide.md**

```markdown
Sections to Compile:

- DOH-DEV Internal vs DOH Runtime distinction
- Task creation context rules
- Version management (dd-x.x.x vs doh-x.x.x)
- Command context mapping

Critical Elements:

- Project context rules (when to use DOH-DEV Internal)
- Default: DOH Runtime unless enhancing /dd:\* commands
- Version file associations (dd-_.md vs doh-_.md)
```

#### **.claude/commands/dd/\*.md**

```markdown
Files to Compile:

- commit.md (pipeline overview, not full 1100 lines)
- changelog.md (linting pipeline, archive management)
- next.md (AI recommendations, project filtering)

Critical Elements:

- Command execution protocols
- Flag inheritance patterns
- Pipeline integration (T070 linting)
- AI decision workflows
```

### **Secondary Sources (Context/Reference)**

#### **linting/feedback.md**

```markdown
Sections to Reference:

- Current linting intelligence status
- AI success rates overview
- Pattern learning system

Usage: Quick reference, link to full file for details
```

#### **docs/pattern-isolation-guide.md**

```markdown
Sections to Reference:

- Development patterns overview
- Architecture principles

Usage: Background context, link for comprehensive patterns
```

## 🔧 Compilation Process

### **Step 1: Information Extraction**

#### **A. Critical Information First**

```markdown
Priority Order:

1. 🚨 CRITICAL ALERTS - Information Claude MUST NOT miss
   - Current Next ID (082)
   - Task numbering protocol
   - External tool attribution prohibition
   - DOH-DEV vs Runtime context rules

2. 📋 MANDATORY PROTOCOLS - Processes Claude MUST follow exactly
   - Task creation 5-step process
   - Command execution workflows
   - Quality standards (linting, documentation)

3. ⚡ QUICK REFERENCE - Frequently needed information
   - Command summaries
   - Flag inheritance patterns
   - File structure overview

4. 💡 CONTEXT NOTES - Background understanding
   - Project architecture
   - Integration points
   - Historical context
```

#### **B. Content Optimization for AI**

```markdown
Language Optimization Rules (from T080):

- ❌ "Handle appropriately" → ✅ "Execute specific protocol X"
- ❌ "As needed" → ✅ "When condition Y is true, then Z"
- ❌ "Manage files" → ✅ "Move T###.md from todo/ to todo/archive/"

Decision Tree Format:

- Use explicit IF/THEN/ELSE structures
- Number sequential steps clearly
- Specify exact conditions and actions
- Provide failure recovery procedures
```

### **Step 2: Structure Assembly**

#### **A. AI.md Template Structure (ROOT LOCATION: `./AI.md`)**

```markdown
# 🤖 CLAUDE AI - COMPLETE PROJECT GUIDE 🤖

🚨 **CRITICAL**: This file is located at `./AI.md` (project root) for maximum visibility 🚨

## 🚨 READ THIS FIRST - CRITICAL INSTRUCTIONS 🚨

[Attention-grabbing section with most critical info]

### ⚡ QUICK REFERENCE CARD ⚡

- **Next Task ID**: 082 (ALWAYS verify in todo/README.md)
- **Project Context**: DOH-DEV Internal vs DOH Runtime (default)
- **Linting Status**: T070 strict enforcement active
- **Active Commands**: /dd:commit, /dd:changelog, /dd:next

## Part 1: ESSENTIAL CONTEXT (Always Read)

### 1.1 🚫 EXPLICIT PROHIBITIONS

### 1.2 📋 TASK CREATION PROTOCOL (MANDATORY)

### 1.3 💡 PROJECT CONTEXT RULES

### 1.4 🔧 QUALITY STANDARDS

## Part 2: COMMAND EXECUTION PROTOCOLS

### 2.1 /dd:commit - Complete Pipeline

### 2.2 /dd:changelog - Documentation Updates

### 2.3 /dd:next - Task Recommendations

## Part 3: DEVELOPMENT WORKFLOWS

### 3.1 Documentation Standards

### 3.2 Code Quality Requirements

### 3.3 Error Handling & Recovery

## Part 4: REFERENCE INFORMATION

### 4.1 File Structure & Organization

### 4.2 Integration Points

### 4.3 Source Document References

---

📍 **File Location**: `./AI.md` (project root) - NOT in `.claude/` directory
```

#### **B. Visual Prominence Implementation**

```markdown
Visual Hierarchy: 🚨 - CRITICAL ALERTS (cannot be missed) 📋 - MANDATORY PROTOCOLS (must be followed exactly) ⚡ - QUICK
REFERENCE (frequently needed) 💡 - CONTEXT NOTES (background understanding) 🔧 - IMPLEMENTATION DETAILS (execution
specifics) 🎯 - EXAMPLES (practical demonstrations) ⚠️ - WARNINGS (important caveats) ✅ - SUCCESS CRITERIA (validation
checkpoints)
```

### **Step 3: Content Compilation**

#### **A. Critical Sections Assembly**

**🚨 CRITICAL ALERTS Section:**

```markdown
## 🚨 READ THIS FIRST - CRITICAL INSTRUCTIONS 🚨

### TASK CREATION PROTOCOL - NO EXCEPTIONS

**MANDATORY PROCESS**:

1. ✅ **READ todo/README.md FIRST** - Get current Next ID (082)
2. ✅ **CREATE T082.md** - Use EXACT next number (never arbitrary)
3. ✅ **UPDATE README.md** - Increment Next ID to 083
4. ✅ **VERIFY** - No T082.md exists already

**RECENT ERROR**: T074 used instead of T078 → T079 created to prevent recurrence **PREVENTION**: ALWAYS consult
todo/README.md before task creation

### PROJECT CONTEXT RULES

**DEFAULT**: DOH Runtime (doh-x.x.x versioning) **DOH-DEV Internal**: ONLY when enhancing /dd:\* commands or internal
tooling

- Add `**Project**: DOH-DEV Internal` header
- Use dd-x.x.x versioning (dd-0.1.0.md, dd-0.2.0.md)

### EXTERNAL TOOL ATTRIBUTION - FORBIDDEN

❌ NO "Generated with [Claude Code]" in commits, docs, or code ❌ NO "Co-Authored-By: Claude" or similar attributions  
❌ NO references to AI tools, IDEs, or development environments ✅ All work must appear as independent professional
software
```

**📋 MANDATORY PROTOCOLS Section:**

```markdown
## 📋 MANDATORY PROTOCOLS - MUST FOLLOW EXACTLY 📋

### Command Execution Protocol

**Every /dd:\* command execution**:

1. **Parse user flags** - Identify --lenient, --no-lint, --dry-run, etc.
2. **Check dependencies** - Verify required files/context available
3. **Execute pipeline** - Follow specific command protocol
4. **Handle errors** - Use defined recovery procedures
5. **Report results** - Provide clear success/failure feedback

### Quality Standards Protocol

**T070 Strict Linting Enforcement**:

- **Default**: Pixel perfect linting (zero errors allowed)
- **Bypass**: Only with --lenient (warnings) or --no-lint (skip entirely)
- **Pipeline**: 4-layer fix system (make lint-fix → AI fixes → validation → user decision)
- **Feedback**: Patterns stored in ./linting/feedback.md for optimization

### Documentation Protocol

**All documentation must**:

- Follow markdown linting rules (make lint)
- Use English language throughout
- Maintain professional standards
- Include proper metadata and structure
```

#### **B. Command Integration Section**

```markdown
## Command Execution Protocols

### /dd:commit - Complete Pipeline

**Purpose**: Execute full DOH commit workflow with documentation updates **Pipeline**: /dd:changelog → git operations →
intelligent commit messages

| **Flag Inheritance**: | Flag    | /dd:changelog    | Git Operation           | Effect       |
| --------------------- | ------- | ---------------- | ----------------------- | ------------ | ----------------- | ------- | ---------------- | -------- |
| --lenient             | ✅ Pass | Uses --no-verify | Bypass linting warnings |              | --no-lint         | ✅ Pass | Uses --no-verify | Skip all |
| linting               |         | --dry-run        | ✅ Pass                 | Preview only | No git operations |

**Execution Protocol**:

1. Parse flags and task description
2. Call /dd:changelog with parameters
3. Handle linting pipeline results (T070)
4. Generate intelligent commit message
5. Execute git operations with appropriate --no-verify usage

### /dd:changelog - Documentation Updates

**Purpose**: Update documentation, manage archives, enforce quality **New Feature**: T070 AI-powered linting pipeline
integration

**Execution Protocol**:

1. Run AI-powered linting pipeline (unless --no-lint)
2. Update TODO files and CHANGELOG.md
3. Manage todo/archive/ folder (move completed tasks)
4. Handle version tracking and metadata
5. Report results with linting status

### /dd:next - AI Task Recommendations

**Purpose**: Provide intelligent task recommendations based on analysis **Enhancement**: T073 --internal flag for
DOH-DEV focus

**Project Filtering**:

- **Default**: DOH Runtime tasks (doh-x.x.x versioning)
- **--internal**: DOH-DEV Internal tasks (dd-x.x.x versioning)
- **--project=all**: Both contexts with clear separation
```

### **Step 4: Source Attribution & Cross-References**

#### **A. Source Tracking Section**

```markdown
## 📚 SOURCE DOCUMENT REFERENCES

### Detailed Documentation

For comprehensive information, refer to source documents:

**Core Configuration**:

- `.claude/CLAUDE.md` - Basic project configuration and rules
- `.claude/DEVELOPMENT.md` - Development workflow and patterns
- `todo/README.md` - Task management system (CRITICAL for Next ID)

**Command Details**:

- `.claude/commands/dd/commit.md` - Complete /dd:commit documentation (~1100 lines)
- `.claude/commands/dd/changelog.md` - Full /dd:changelog pipeline details
- `.claude/commands/dd/next.md` - AI recommendation system details

**Context & Patterns**:

- `docs/project-isolation-guide.md` - DOH-DEV vs Runtime separation
- `docs/pattern-isolation-guide.md` - Development pattern guidelines
- `linting/feedback.md` - AI linting intelligence and patterns

### Compilation Information

- **Last Compiled**: 2025-08-28
- **Source Document Versions**: As of compilation date
- **Critical Updates**: Next ID, command enhancements, linting pipeline
- **Compilation Guide**: `docs/mk-ai.md` (this file)
```

## 🔄 Maintenance Protocol

### **When to Recompile AI.md**

#### **Immediate Recompilation Required**

- [ ] **Next ID changes** in todo/README.md (critical update)
- [ ] **New /dd:\* commands** added or significantly modified
- [ ] **Quality standards changes** (linting rules, requirements)
- [ ] **Project context rules** modified (DOH-DEV vs Runtime)

#### **Regular Recompilation (Weekly)**

- [ ] **Task completions** that affect workflow
- [ ] **Documentation updates** in core files
- [ ] **New integration points** or dependencies
- [ ] **Process improvements** or optimizations

### **Recompilation Checklist**

#### **Pre-Compilation**

- [ ] **Read all source files** for changes since last compilation
- [ ] **Check current Next ID** in todo/README.md
- [ ] **Verify command status** - which /dd:\* commands are active
- [ ] **Review recent tasks** for workflow changes (T070, T078, T080, T081)

#### **During Compilation**

- [ ] **Extract critical information** using priority hierarchy
- [ ] **Optimize language** for Claude AI comprehension
- [ ] **Apply visual prominence** system consistently
- [ ] **Verify cross-references** are current and accurate

#### **Post-Compilation**

- [ ] **Update compilation timestamp** in AI.md
- [ ] **Verify all critical information** present and prominent
- [ ] **Check visual hierarchy** works effectively
- [ ] **Test findability** of key information (Next ID, protocols, etc.)

### **Quality Assurance**

#### **Content Validation**

```markdown
Validation Checklist:

- [ ] Next ID correctly displayed (currently 082)
- [ ] All CRITICAL and MANDATORY sections complete
- [ ] Command protocols match current implementation
- [ ] Project context rules clearly explained
- [ ] Source attributions accurate and current
```

#### **AI Comprehension Test**

```markdown
Test Questions:

- Can Claude quickly find current Next ID?
- Are task creation steps unambiguous?
- Is command execution protocol clear?
- Are decision points well-defined?
- Is context complete for typical operations?
```

## ⚡ Quick Compilation Workflow

### **Fast Update Protocol** (for minor changes)

```bash
1. Identify changed source sections
2. Update corresponding AI.md sections
3. Verify critical info (Next ID) is current
4. Update compilation timestamp
5. Validate key information findability
```

### **Full Recompilation Protocol** (for major changes)

```bash
1. Read all source documents completely
2. Extract information using priority hierarchy
3. Rebuild AI.md structure from template
4. Apply visual prominence system
5. Add cross-references and source attribution
6. Complete quality assurance checklist
7. Test AI comprehension effectiveness
```

## 🎯 Success Criteria

### **Primary Objectives**

- [ ] **Single source availability**: All critical info in AI.md
- [ ] **Visual prominence effective**: Critical info impossible to miss
- [ ] **Context completeness**: No need for multiple file navigation
- [ ] **Current accuracy**: Information matches project state

### **Quality Metrics**

- [ ] **Information density**: High critical-to-total info ratio
- [ ] **Findability speed**: Key info locatable in <30 seconds
- [ ] **Decision support**: Complete context at decision points
- [ ] **Error prevention**: Processes like T079 numbering prevented

## 🚨 Critical Reminders

### **For Claude AI**

- **ALWAYS check `./AI.md` first** before reading other documentation (located at project root)
- **Verify Next ID** in Quick Reference Card matches todo/README.md
- **Follow MANDATORY PROTOCOLS** exactly as specified
- **Use visual prominence** to prioritize information processing

### **For Developers**

- **Update AI.md** when core processes change
- **Verify compilation accuracy** after significant changes
- **Monitor Claude's usage patterns** to improve effectiveness
- **Maintain visual prominence** system consistently

---

**This guide ensures `./AI.md` (at project root) remains an effective "tunnel" for Claude AI, providing complete,
current, and optimally formatted information for reliable project execution.**

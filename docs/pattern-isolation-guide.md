# DOH Pattern Isolation Guide - Chinese Wall Policy

**Purpose**: Enforce a strict "Chinese Wall" separation between DOH internal development patterns and user-facing
runtime patterns

## The Chinese Wall Principle

This document establishes an information barrier (Chinese Wall) between:

- **Internal Side**: How we build and develop the DOH system
- **User Side**: How users interact with and use DOH in their projects

### Information Barrier Requirement

This separation must be absolute - no information leakage across the wall

## Quick Reference

### 🚫 Never Mix These Patterns

| Internal Development   | User Runtime                |
| ---------------------- | --------------------------- |
| TODO.md task tracking  | .doh/ project structure     |
| T### task numbers      | !### issue IDs              |
| E### epic numbers      | Epic folders in .doh/epics/ |
| /doh-dev commands      | /doh commands               |
| .claude/doh/ internals | .doh/ user content          |

## Documentation Categories

### 1. Internal Development Docs 🔧

**Can Include**: T###, E###, TODO.md references, /doh-dev commands

**Files**:

- `TODO.md` - DOH development roadmap
- `DEVELOPMENT.md` - Internal development guide
- `TODOARCHIVED.md` - Completed internal tasks
- `CHANGELOG.md` - Release history with T### refs
- `analysis/*.md` - Design documents

### 2. User-Facing Docs 👤

**Must Exclude**: All internal development patterns

**Files**:

- `README.md` - User introduction
- `WORKFLOW.md` - How to use /doh commands
- `docs/*.md` - Usage documentation
- `.claude/commands/doh/*.md` - Command docs
- `.claude/doh/templates/*.md` - Project templates

### 3. Mixed-Purpose Docs ⚠️

**Requires Care**: General concepts OK, specific internals NO

**Files**:

- `CONTRIBUTING.md` - External contributor guide
    - ✅ "We use TODO.md for tracking"
    - ❌ "See T048 for details"

## Enforcement Rules

### Rule 1: Command Documentation

```markdown
❌ WRONG (mixes internal and runtime): "The /doh:init command (similar to T001 skeleton) creates..."

✅ CORRECT (clean separation): "The /doh:init command creates your project structure..."
```

### Rule 2: Example Projects

```markdown
❌ WRONG (exposes internal structure): ".claude/doh/skel/ contains the templates..."

✅ CORRECT (user perspective): "Your .doh/ folder will contain epics and tasks..."
```

### Rule 3: Development References

```markdown
❌ WRONG (specific internal task): "This feature (T044) enables natural language..."

✅ CORRECT (generic reference): "Natural language support is under development..."
```

## Review Checklist

### Before Committing User-Facing Docs

- [ ] No T### or E### numbers present
- [ ] No /doh-sys command references
- [ ] No TODO.md workflow explanations
- [ ] Examples use .doh/ not .claude/doh/
- [ ] Focus on what users do, not how we build

### Before Committing Internal Docs

- [ ] Clearly marked as internal documentation
- [ ] Placed in appropriate internal location
- [ ] Not linked from user-facing docs

## Common Violations & Fixes

### Violation: Task Number in User Doc

**Found**: "Feature pending (see T020)"  
**Fix**: "Feature under development"

### Violation: Internal Command in Guide

**Found**: "Run /doh-sys:next to see tasks"  
**Fix**: Remove or replace with user command

### Violation: Development Process in User Doc

**Found**: "We track this in TODO.md as T###"  
**Fix**: "This feature is on our roadmap"

## Validation Commands

### Check User Docs for Internal Patterns

```bash
# Should return 0
grep -r "T0[0-9][0-9]" README.md WORKFLOW.md docs/*.md \
  .claude/commands/doh/*.md .claude/doh/templates/*.md | wc -l

# Should return 0
grep -r "/doh-sys" README.md WORKFLOW.md docs/*.md \
  .claude/commands/doh/*.md | wc -l
```

### Find Mixed Patterns

```bash
# Identify potential violations
grep -rn "TODO\|T0[0-9]\|E0[0-9]\|doh-sys" \
  --include="*.md" \
  --exclude-dir=".git" \
  --exclude="TODO*.md" \
  --exclude="DEVELOPMENT.md" \
  --exclude="CHANGELOG.md"
```

## Enforcement Process

1. **Pre-commit**: Review docs against checklist
2. **PR Review**: Verify pattern isolation
3. **Regular Audits**: Run validation commands
4. **Documentation Updates**: Maintain this guide

## Why This Matters

- **User Clarity**: Users need runtime docs, not dev process
- **Professional Image**: Clean separation shows maturity
- **Reduced Confusion**: Clear boundaries help everyone
- **Maintainability**: Easier to update when separated

---

_This guide ensures DOH maintains professional separation between internal development and user-facing documentation._

# DOH Project Context Isolation Guide

**Purpose**: Establish clear separation between DOH-DEV Internal development and DOH Runtime distribution to prevent
context mixing and ensure proper dependency isolation.

## Project Contexts

### DOH Runtime (`doh-x.x.x`)

- **Purpose**: Public distribution, end-user features, runtime functionality
- **Version Files**: `todo/doh-1.4.0.md`, `todo/doh-1.5.0.md`
- **Task Header**: `**Project**: DOH Runtime` (default, can be omitted)
- **Focus**: Runtime distribution, user features, public API, end-user workflows

### DOH-DEV Internal (`dd-x.x.x`)

- **Purpose**: Internal development support, command tooling, developer experience
- **Version Files**: `todo/dd-0.1.0.md`, `todo/dd-0.2.0.md`
- **Task Header**: `**Project**: DOH-DEV Internal` (required when applicable)
- **Focus**: Command development, internal tooling, developer workflows

## Task Creation Rules

### Default Context: DOH Runtime

- Tasks without explicit project context are DOH Runtime by default
- Use `doh-x.x.x` versioning unless specifically enhancing doh-dev commands
- Example: `/doh` commands, runtime features, distribution concerns

### Explicit DOH-DEV Context

- Only when enhancing `/doh-dev` commands or internal tooling
- Must include `**Project**: DOH-DEV Internal` header
- Use `dd-x.x.x` versioning for internal development milestones
- Example: `/dd:commit` improvements, command beautification

## Command Context Mapping

```bash
# DOH Runtime (default)
/doh:commit          → DOH Runtime
/doh:changelog       → DOH Runtime
/doh:quick           → DOH Runtime

# DOH-DEV Internal (explicit)
/dd:commit      → DOH-DEV Internal
/dd:changelog   → DOH-DEV Internal
/dd:next        → DOH-DEV Internal
/dd:lint        → DOH-DEV Internal
```

## Dependency Isolation Policy

### Strict Isolation Rules

- DOH-DEV tasks CANNOT depend on DOH Runtime tasks (unless explicit)
- DOH Runtime tasks CANNOT depend on DOH-DEV tasks (unless explicit)
- Cross-project dependencies require explicit documentation

### Exception Format (rare cases)

```markdown
**Cross-Project Dependency**:

- Depends on: [T###-DOH-Runtime] "task description"
- Rationale: "Why this cross-project dependency is necessary"
- Impact: "What breaks if this dependency fails"
```

## `/dd:next` Project Awareness

### Project Filtering

```bash
# Show only internal tooling tasks
/dd:next --project=doh-dev

# Show only runtime distribution tasks
/dd:next --project=doh-runtime

# Show both with clear separation (default)
/dd:next --project=all
```

### Recommendation Separation

- **DOH-DEV Internal**: Command improvements, developer experience, internal workflows
- **DOH Runtime**: End-user features, distribution, public API, runtime functionality
- **Cross-project warnings**: Alerts when dependencies cross boundaries

## Version Management

### Dual Version Tracking

- **Runtime**: `doh-1.4.0.md`, `doh-1.5.0.md` (public releases)
- **Internal**: `dd-0.1.0.md`, `dd-0.2.0.md` (internal development milestones)

### Version Selection Rules

- Default: Use `doh-x.x.x` versioning for all tasks
- Exception: Use `dd-x.x.x` only when specifically enhancing `/doh-dev` commands
- Rationale: Most work is runtime-focused; internal tooling is specialized

## Task Examples

### DOH Runtime Task (Default)

```markdown
# T123 - Implement Task Distribution System

**Status**: READY **Priority**: HIGH **Epic**: E001 DOH Runtime doh-1.4.0 Release **Proposed Version**: doh-1.4.0
```

### DOH-DEV Internal Task (Explicit)

```markdown
# T124 - Add Auto-completion to /doh-dev Commands

**Project**: DOH-DEV Internal **Status**: READY  
**Priority**: MEDIUM **Epic**: E002 DOH-DEV Internal System **Proposed Version**: dd-0.2.0
```

## Benefits

- **Context Clarity**: No confusion between internal vs runtime work
- **Clean Dependencies**: Prevents accidental cross-project coupling
- **Focused Development**: Commands understand their operational context
- **Scalable Architecture**: Clean separation supports future growth

## Migration Notes

- Existing tasks default to DOH Runtime context
- Only add `**Project**: DOH-DEV Internal` when specifically working on `/doh-dev` commands
- Version files maintain separate evolution tracks
- `/dd:next` behavior remains backward compatible
- **History Immutability**: NEVER modify CHANGELOG.md or completed tasks during refactoring
- **Archive Protection**: Completed tasks in `todo/archive/` are historical records

---

This isolation ensures clean project boundaries while maintaining development velocity and clarity.

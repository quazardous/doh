# TODO Management System

**Last Updated**: 2025-08-27  
**System Version**: 2.0 (Structured Files)  
**Next ID**: 078 (shared counter for TODOs and Epics)

## Overview

This directory contains the structured TODO management system for the DOH project. Each TODO and Epic is maintained as an individual file for better organization, version control, and collaboration.

## Structure

```
todo/
├── README.md                 # This file - management documentation
├── T002.md ... T057.md       # Individual TODO files (active and proposed)
├── E074.md, E075.md, E076.md, E077.md # Epic files
└── archive/                  # Completed TODOs
    ├── T013.md
    ├── T017.md
    └── ...
```

## File Organization

### Active and Proposed TODOs

- Place directly in `todo/` folder
- Format: `T###.md` (e.g., `T054.md`, `T055.md`)
- No subfolders for active/proposed items

### Completed TODOs
  
- Move to `todo/archive/` when completed
- Maintain same filename: `T###.md`
- Preserve all history and metadata

### Epics

- Place directly in `todo/` folder  
- Format: `E###.md` (e.g., `E074.md`, `E076.md`)
- Track component TODOs and progress

## TODO Template

Use this lightweight template for creating new TODOs:

```markdown
# T### - [TODO Title]

**Status**: PROPOSED  
**Priority**: MEDIUM  
**Dependencies**: None  
**Epic**: None (see Epic Assignment Rules)

[Brief description of what this TODO accomplishes]

**Tasks**:
- [ ] Task 1
- [ ] Task 2

**Deliverable**: [What will be completed]
```

## Epic Template

Use this lightweight template for creating new Epics:

```markdown
# E### - [Epic Title]

**Epic Status**: PROPOSED  
**Priority**: MEDIUM  
**Epic Components**: T###, T###, T###

[Brief description of what this Epic encompasses]

## Epic Phases

- T###: Brief task description
- T###: Another task description
- T###: Final task description

## Progress Tracking

### Completed Tasks
- [x] T### - Completed YYYY-MM-DD

### Pending Tasks  
- [ ] T### - Pending
- [ ] T### - Pending

## Deliverable

[Clear description of what will be delivered when this Epic is complete]
```

## Status Management

### TODO Statuses

- **PROPOSED**: Awaiting approval or planning
- **ACTIVE**: Currently being worked on
- **COMPLETED**: Finished and moved to archive

### Epic Statuses
  
- **PROPOSED**: Epic planning phase
- **ACTIVE**: Components being implemented
- **COMPLETED**: All components finished

## Priority Levels

- **HIGH**: Critical path items, blockers 🚩
- **MEDIUM**: Important but not blocking
- **LOW**: Nice-to-have, future enhancements

## Epic Assignment Rules

When creating new TODOs, follow these rules for Epic assignment:

### Default: Epic-less TODOs
- **Most TODOs should be Epic-less** unless there's an obvious match
- Use `**Epic**: None` by default
- Don't force artificial Epic assignments

### When to Assign an Epic
Only assign a TODO to an Epic when:
1. **Existing Epic matches**: There's a clear, existing Epic that obviously relates
2. **Component relationship**: The TODO is clearly a component of an established Epic
3. **Natural fit**: The assignment feels natural and adds organizational value

### When NOT to Assign an Epic
- **No existing Epic matches**: Don't create new Epics just to assign TODOs
- **Unclear relationship**: If the connection to an Epic is vague or forced  
- **Standalone work**: Independent TODOs that don't belong to larger initiatives
- **Simple enhancements**: Minor improvements that don't need Epic-level organization

### Examples
```
✅ Good Epic Assignment:
T072 - Epic: E075 (clear component of existing DOH-DEV Internal System Epic)

❌ Bad Epic Assignment: 
T073 - Epic: E004 (E004 doesn't exist, forced assignment)

✅ Good Epic-less TODO:
T073 - Epic: None (standalone enhancement, no existing Epic matches)
```

### Shared Numbering
- TODOs and Epics share the same sequence counter
- Current sequence: T001-T073, E074-E077, next ID: 078
- This prevents numbering conflicts and maintains chronological order

## Workflow

### Creating New TODOs

1. Use next available number from shared counter (currently 078)
2. Copy TODO template from this README
3. Fill in all required metadata
4. Save as `T078.md` in `todo/` folder
5. Update "Next ID" counter in this README to 079

### Creating New Epics

1. Use next available number from shared counter (currently 078)
2. Copy Epic template from this README (see below)
3. Define component TODOs
4. Save as `E078.md` in `todo/` folder
5. Update "Next ID" counter in this README to 079

### Completing TODOs

1. Update status to COMPLETED with date
2. Move file to `todo/archive/`
3. Update any parent Epic progress

### Completing Epics

1. Ensure all component TODOs completed
2. Update Epic status to COMPLETED  
3. Add completion date
4. Keep Epic file in `todo/` for reference

## Manual Management

All TODO management is done manually by editing files directly:

- **Create TODO**: Copy template from this README, create `T078.md` file (use next ID)
- **Create Epic**: Copy epic template, create `E078.md` file (use next ID)
- **Update status**: Edit the file's Status line
- **Archive completed**: Move file from `todo/` to `todo/archive/`
- **Update counter**: Increment "Next ID" in this README after creating TODO/Epic

## Metadata Requirements

### Required Fields (TODOs)

- Status, Priority, Created date
- Title and Description
- Tasks breakdown

### Optional Fields (TODOs)
  
- Dependencies, Epic, Tags
- Estimated Effort, Updated date
- Completed date (when done)

## Validation Rules

### File Structure

- All TODO/Epic files must use templates
- Required metadata must be present
- Consistent formatting and structure

### Dependencies

- All T### references must exist as files
- Epic components must list valid TODOs
- No circular dependencies allowed

### Naming

- Sequential numbering (no gaps allowed)
- Consistent filename patterns
- Clear, descriptive titles

## Integration with Development Workflow

### /doh-sys Commands

- `/dd:commit` - Will be updated to work with individual files
- `/dd:changelog` - Will generate from individual TODO files
- Archive management integrated with completion workflow

### Version Control

- Each TODO file tracked independently
- Reduced merge conflicts
- Clear history per TODO
- Easy collaborative editing

## Migration Notes

This system replaces the previous monolithic `TODO.md` and `TODOARCHIVED.md` files. Benefits include:

- **Individual Files**: Easy editing and tracking per TODO
- **Better Organization**: Clear separation without complex subfolders  
- **Version Control**: Reduced conflicts, clear history
- **Collaboration**: Multiple developers can work simultaneously
- **Searchability**: File-based organization and navigation

---

## TODO Management System v2.0 - Structured File Approach

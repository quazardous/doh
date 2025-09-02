---
name: version-edit
description: "Edit and update version milestones with AI assistance"
version: 1.0.0
category: versioning
priority: 1
requires_doh: true
author: Claude
created: 2025-09-01
file_version: 0.1.0
---

# DOH Version Editing Command

Intelligently modify existing version milestones with AI-powered content updates, scope adjustments, and release planning assistance.

## Usage

```bash
/doh:version-edit <version> [options]
```

## Parameters

- `version` (required) - Version to edit (e.g., 1.2.0)
- `--interactive` - Interactive editing session with AI guidance
- `--scope` - Update version scope and task assignments
- `--content` - Edit release notes and documentation
- `--status STATUS` - Change version status (planned, active, released, deprecated)
- `--dry-run` - Preview changes without saving

## Examples

```bash
# Interactive version editing with AI assistance  
/doh:version-edit 1.2.0 --interactive

# Update version scope and task assignments
/doh:version-edit 1.2.0 --scope

# Edit release notes and content
/doh:version-edit 1.2.0 --content

# Change version status
/doh:version-edit 1.2.0 --status active
```

## AI-Powered Editing Features

1. **Intelligent Content Updates**
   - Analyzes current version content and context
   - Suggests improvements to release notes
   - Updates task dependencies automatically
   - Maintains consistency across version documentation

2. **Scope Management**
   - Reviews current task assignments
   - Suggests scope adjustments based on progress
   - Identifies completed tasks to move to version
   - Recommends task reassignment between versions

3. **Status Transitions**
   - Validates status changes against project state
   - Updates dependent tasks and epics
   - Manages version lifecycle transitions
   - Provides guidance for each status change

4. **Content Enhancement**
   - Improves release note clarity and completeness
   - Adds missing technical details
   - Updates migration guides based on changes
   - Ensures documentation consistency

## Interactive Editing Modes

### **Scope Review Mode**
- Analyzes current task assignments
- Reviews completion progress
- Suggests scope adjustments
- Handles task reassignment between versions

### **Content Editing Mode**  
- Reviews existing release notes
- Suggests content improvements
- Updates technical documentation
- Enhances migration guides

### **Status Management Mode**
- Validates proposed status changes
- Updates related project components
- Manages version lifecycle
- Provides transition guidance

### **Comprehensive Review Mode**
- Full version analysis and optimization
- Coordinated updates across all aspects
- Consistency checking and validation
- Strategic recommendations

## Version Status Transitions

**Planned → Active**
- Validates readiness to begin development
- Updates task priorities and assignments
- Initiates version tracking workflows

**Active → Released**
- Verifies all assigned tasks completed
- Finalizes release notes and documentation
- Creates version tags and archives

**Released → Deprecated**
- Manages deprecation timeline
- Updates migration documentation
- Handles backward compatibility

## Smart Content Analysis

The AI analyzes:
- **Task Completion**: Progress toward version goals
- **Scope Alignment**: Whether current scope matches reality
- **Documentation Quality**: Completeness of release notes
- **Dependency Changes**: Impact of task modifications
- **Timeline Accuracy**: Realistic completion estimates

## Validation & Safety

- **Change Impact Analysis**: Reviews effects of modifications
- **Consistency Checking**: Ensures version coherence
- **Rollback Planning**: Provides undo guidance
- **Conflict Detection**: Identifies potential issues

## Integration Features

- **Task Synchronization**: Updates linked tasks and epics
- **Version Inheritance**: Propagates changes to child components  
- **Git Integration**: Optional commit and tag management
- **Documentation Updates**: Maintains cross-reference consistency

## Output

Provides comprehensive feedback:
- Summary of changes made
- Impact analysis and recommendations
- Next steps and action items
- Related command suggestions

## Advanced Usage

```bash
# Comprehensive version review and optimization
/doh:version-edit 1.2.0 --interactive --scope --content

# Quick status update with validation
/doh:version-edit 1.2.0 --status released --dry-run

# Focused content improvement
/doh:version-edit 1.2.0 --content --interactive
```

## Safety Features

- **Backup Creation**: Automatic backup before major changes
- **Rollback Support**: Easy reversion of modifications
- **Validation Checks**: Ensures version consistency
- **Preview Mode**: Review changes before applying

## See Also

- `/doh:version-new` - Create new versions
- `/doh:version-show` - Display version details
- `/doh:version-status` - Check version status
- `/doh:version-list` - List all versions
- `/doh:task-versions` - View task-version relationships
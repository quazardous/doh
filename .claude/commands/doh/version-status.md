---
name: version-status
description: Unified version management interface - status, list, graph, and analysis
type: ai
parallel_execution: false
success_exit_code: 0
timeout: 30000
file_version: 0.1.0
---

# /doh:version-status

## Description
Unified command providing comprehensive version information including current status, complete version listing, dependency graphs, and task relationships. Combines functionality of former version-list, version-graph, and version-status commands.

## Usage
```
/doh:version-status [options] [version]

# Default: Show current version + progress toward next versions
/doh:version-status

# Show all versions in table format
/doh:version-status --all
/doh:version-status --list

# Show version dependency graph
/doh:version-status --graph [version]
/doh:version-status --graph --all

# Show detailed info for specific version
/doh:version-status 0.5.0

# Show task impact analysis
/doh:version-status --task 005

# Filter by status
/doh:version-status --status planned|released|deprecated

# Detailed output
/doh:version-status --detailed
```

## Options
- `--all, --list`: Show all versions in table format (former version-list)
- `--graph`: Show dependency graph visualization (former version-graph)
- `--task <number>`: Show version impact of specific task
- `--status <status>`: Filter by status (planned, released, deprecated)
- `--detailed`: Show detailed information for each version
- `<version>`: Show detailed info for specific version

## Implementation
The AI agent will determine the display mode based on arguments:

### Default Mode (version-status behavior)
1. Read current version from VERSION file at project root
2. Find planned versions from `.doh/versions/`
3. Calculate completion percentage for next 2-3 versions
4. Show progress toward immediate releases

### List Mode (--all, --list)
1. Check for `.doh/versions/` directory
2. List all version files (*.md)
3. Parse each version file to extract metadata
4. Display in formatted table

### Graph Mode (--graph)
1. **Scope Analysis**: Determine version exploration path
   - Single version: Load that version + direct dependencies
   - All versions: Load incrementally during tree traversal
   - Task impact: Load only affected versions
2. Build dependency graph for query scope
3. **Minimal cache update** - Only process versions in scope
4. Display visualization with critical path analysis

### Single Version Mode (version argument)
1. Load specific version file
2. Parse requirements and dependencies
3. Show detailed status, progress, and blocking issues

**Cache Optimization**: 
- Only processes and caches data for versions being displayed
- Selective updates avoid full recalculation
- Scope-aware processing minimizes resource usage

## Output Formats

### Default Mode Output
```
DOH Version Status
==================
Current Version: 0.5.0
Next Version: 0.6.0 (planned)

Version 0.6.0 Progress:
-----------------------
Target Release: TBD
Overall Progress: 60%

✅ Completed (2):
  - Task 022: AI-powered version planning commands
  - Task 023: Update prd-edit with AI version matching

⏳ In Progress (1):
  - Task 009: Version management commands

📋 Pending (2):
  - Task 010: Version validation utilities
  - Task 011: Version file headers system

💡 Next Actions:
  1. Complete Task 009 (version management)
  2. Start Task 010 (version validation)
```

### List Mode Output (--all)
```
DOH Project Versions
====================
Current: 0.5.0

Version  | Status    | Date       | Progress | Type
---------|-----------|------------|----------|-------
0.1.0    | released  | 2025-08-30 | -        | initial
0.2.0    | released  | 2025-09-01 | -        | minor  
0.5.0    | released  | 2025-09-01 | -        | minor
0.6.0    | planned   | TBD        | 60%      | minor
1.0.0    | planned   | TBD        | 75%      | major

📊 Summary:
- Released: 3 versions
- Planned: 2 versions  
- Ready for release: 1 version (0.6.0 at 60%+ completion)
```

### Graph Mode Output (--graph)
```
DOH Version Dependency Tree
===========================

📈 Release Timeline:

v1.0.0 (planned - 75% ready) 🎯
  ├── ✅ completed: [005 ✓, 006 ✓, 007 ✓]
  ├── ⏳ in progress: [008]
  └── 📋 Epic: versioning (90% complete)

v0.6.0 (planned - 60% ready)
  ├── 🔒 requires: v0.5.0 ✅
  ├── ✅ completed: [022 ✓, 023 ✓]
  └── 📋 blocked by: [009, 010, 011]

v0.5.0 (released) ✅
  └── 📅 Released: 2025-09-01

🚀 Ready for Release:
  - v1.0.0: 75% complete, estimated 1 week remaining
  
🔒 Critical Path:
  Task 008 → Epic versioning completion → v1.0.0 release
```

### Single Version Output (0.5.0)
```
Version Details: v0.5.0
=======================
Status: released ✅
Release Date: 2025-09-01
Type: minor

📋 Release Conditions (Met):
   Required Tasks: 4/4 completed (100%)
   ✅ 005 - Frontmatter integration
   ✅ 006 - Version bump workflow
   ✅ 007 - Version milestone conditions  
   ✅ 022 - AI-powered version planning

   Required Epics: 1/1 completed (100%)
   ✅ versioning - Core versioning system

🔗 Version Dependencies:
   Prerequisites: v0.2.0 ✅
   Enables: v0.6.0, v1.0.0
   
📊 Impact Analysis:
   Unblocked: 2 future versions
   New Features: AI-powered version planning
   Foundation: Complete versioning system
```

### Task Impact Analysis (--task 005)
```
Task Impact Analysis: 005 - Frontmatter Integration
==================================================

🎯 Direct Impact:
   Primary Version: v1.0.0 (required)
   Status: ✅ Completed

🌊 Cascading Impact:
   Unblocks Versions:
   ├── v1.0.0 → enables major release
   ├── v0.6.0 → inherited requirement  
   └── future versions → inherited requirement

📊 Release Impact:
   Affects: 3+ version releases
   Timeline Impact: Critical path item
   Completion Benefits: Foundation for all versioning
```

## Graph Cache Integration
This command automatically:
- Updates `.doh/projects/*/graph_cache.json` with version relationships
- Maintains bidirectional task↔version mappings  
- Provides cached data for other versioning commands
- Enables fast queries for dependencies and impact analysis

## Error Handling
- If VERSION file missing, suggest initializing project version
- If no planned versions, suggest creating version roadmap
- If version file format invalid, show expected structure
- If task references invalid, identify orphaned requirements
- Handle missing or invalid version references gracefully
- Handle circular dependencies gracefully

## Compatibility Notes
This unified command replaces:
- `/doh:version-list` → use `--all` or `--list`
- `/doh:version-graph` → use `--graph` 
- Original `/doh:version-status` → default behavior (no options)

All previous command syntaxes are supported through option mapping.
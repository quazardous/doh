---
name: version-status
description: Show current project version and progress toward next versions
type: ai
parallel_execution: false
success_exit_code: 0
timeout: 30000
file_version: 0.1.0
---

# /doh:version-status

## Description
Display the current DOH project version and show progress toward planned versions with task completion metrics.

## Usage
```
/doh:version-status
```

## Implementation
The AI agent will:
1. Read current version from VERSION file at project root
2. Find all planned versions from `.doh/versions/`
3. For each planned version:
   - Count PRDs/epics/tasks targeting this version
   - Calculate completion percentage
   - Show blocking items
4. Display version roadmap

## Output Format
```
DOH Version Status
==================
Current Version: 0.1.0
Next Version: 0.2.0 (planned)

Version 0.2.0 Progress:
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

Version 1.0.0 Progress:
-----------------------
Target Release: TBD
Overall Progress: 0%

📋 All tasks pending or not yet assigned
```

## Error Handling
- If VERSION file missing, suggest initializing project version
- If no planned versions, suggest creating version roadmap
- Handle missing or invalid version references gracefully
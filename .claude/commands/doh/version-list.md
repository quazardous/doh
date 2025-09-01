---
name: version-list
description: List all project versions with their status
type: ai
parallel_execution: false
success_exit_code: 0
timeout: 30000
file_version: 0.1.0
---

# /doh:version-list

## Description
List all DOH project versions showing their status, release dates, and progress for planned versions.

## Usage
```
/doh:version-list [options]
```

## Options
- `--status <status>`: Filter by status (planned, released, deprecated)
- `--detailed`: Show detailed information for each version

## Implementation
The AI agent will:
1. Check for `.doh/versions/` directory
2. List all version files (*.md)
3. Parse each version file to extract:
   - Version number
   - Status (planned, released, deprecated)
   - Release date (if released)
   - Progress percentage (if planned)
4. Display in a formatted table

## Output Format
```
DOH Project Versions
====================
Current: 0.1.0

Version  | Status    | Date       | Progress
---------|-----------|------------|----------
0.1.0    | released  | 2025-08-30 | -
0.2.0    | planned   | TBD        | 60%
1.0.0    | planned   | TBD        | 0%
```

## Error Handling
- If no versions directory exists, suggest creating first version
- If no version files found, display helpful message
- Handle malformed version files gracefully
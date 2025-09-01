---
name: version-show
description: Display detailed information about a specific version
type: ai
parallel_execution: false
success_exit_code: 0
timeout: 30000
file_version: 0.1.0
---

# /doh:version-show

## Description
Show detailed information about a specific DOH version including goals, requirements, and associated tasks.

## Usage
```
/doh:version-show <version>
```

## Arguments
- `<version>`: The version number to display (e.g., 0.2.0, 1.0.0)

## Implementation
The AI agent will:
1. Validate the version number format
2. Check if version file exists in `.doh/versions/{version}.md`
3. Parse and display version file contents including:
   - Version metadata (status, type, dates)
   - Must-have features
   - Should-have features
   - Must-not-have features
   - Success criteria
   - Release readiness conditions
4. Find and list all PRDs/epics/tasks targeting this version
5. Show completion metrics

## Output Format
```
Version 0.2.0 - AI-Powered Version Planning
============================================
Status: planned
Type: minor
Created: 2025-09-01T17:30:00Z
Release Date: TBD

📋 Must Have Features:
- AI-powered version creation with natural language input
- AI-powered version editing and updates
- Intelligent target_version suggestions during PRD creation

🎯 Should Have Features:
- Enhanced PRD creation workflow with version integration
- Automatic version compatibility checking

🚫 Must Not Have Features:
- Complex bash scripting for version commands
- Technical implementation details in version files

✅ Success Criteria:
- AI commands understand conversational natural language
- Version files maintain strategic, goal-oriented focus

📊 Release Readiness:
[ ] Task 022 completed ✅
[ ] /doh:version-new working ✅
[ ] /doh:version-edit functional ✅
[ ] /doh:prd-new enhanced ✅
[x] All AI commands tested
[x] Strategic format established

Associated Work Items:
----------------------
Tasks (3):
  ✅ 022: AI-powered version planning commands
  ✅ 023: Update prd-edit with AI version matching
  ⏳ 009: Version management commands

Progress: 66% complete
```

## Error Handling
- If version not found, suggest available versions
- If version file malformed, show raw content with error
- Validate semantic version format before lookup
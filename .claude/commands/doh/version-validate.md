---
name: version-validate
description: Validate version milestone conditions and check release readiness
type: ai
parallel_execution: false
success_exit_code: 0
timeout: 30000
file_version: 0.1.0
---

# /doh:version-validate

## Description
Check if a specific version meets all its milestone conditions and is ready for release. Validates required tasks, epics, and quality gates defined in version files.

## Usage
```
/doh:version-validate [version]
/doh:version-validate              # Check all planned versions
```

## Implementation
The AI agent will:
1. If version specified, load `.doh/versions/{version}.md`
2. If no version specified, check all versions in `.doh/versions/`
3. For each version:
   - Parse "Release Conditions" or "Release Readiness Conditions" sections
   - Check status of required tasks (by number or name)
   - Check status of required epics  
   - Evaluate quality gates
   - Calculate completion percentage
   - **Selectively update graph cache** ONLY for the specific version(s) being validated
4. Display detailed validation report with live data

**Cache Optimization**: 
- Single version query: Updates cache only for that version
- All versions query: Updates cache incrementally as each version is processed
- Never recalculates unrelated versions

## Output Format
```
Version Validation Report
========================

Version 0.2.0 Validation:
-------------------------
✅ READY FOR RELEASE

Required Tasks (6/6 completed):
✅ Task 022: AI-powered version planning commands
✅ Task 023: Update prd-edit with AI version matching  
✅ Task 009: Version management commands
✅ Task 010: Version validation utilities
✅ Task 011: Version file headers system
✅ Task 006: Version bump workflow implementation

Quality Gates (3/3 met):
✅ All AI commands tested and validated
✅ Strategic version file format established  
✅ Integration with DOH workflow confirmed

🚀 Version 0.2.0 is ready for release!
   Run: /doh:version-bump minor --message "AI-Powered Version Planning Release"

---

Version 1.0.0 Validation:
-------------------------
❌ NOT READY (4/7 tasks completed - 57%)

Required Tasks (4/7 completed):
✅ Task 005: Create frontmatter integration
✅ Task 006: Version bump workflow implementation  
✅ Task 009: Version management commands
✅ Task 011: Version file headers system
❌ Task 007: Version milestone conditions and auto-bump
❌ Task 008: Version dependencies in task graph
❌ Task 010: Version validation utilities

Required Epics (0/1 completed):
❌ versioning - Complete versioning system implementation (58% progress)

Quality Gates (0/3 met):
❌ All tests passing
❌ Documentation complete  
❌ No critical bugs

Blocking Items:
- Complete remaining versioning tasks (007, 008)
- Finish versioning epic
- Run comprehensive test suite
- Complete documentation

Estimated time to completion: ~2-3 weeks
```

## Error Handling
- If version file not found, suggest creating it with /doh:version-new
- If version format invalid, show expected format
- If no version files exist, suggest creating version roadmap
- Handle missing or invalid task/epic references gracefully

## Integration
- Can be called after task completion to check readiness
- Integrates with /doh:version-status for progress tracking
- Supports /doh:version-bump workflow for release execution
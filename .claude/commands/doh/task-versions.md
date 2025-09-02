---
name: task-versions
description: Show version impact analysis for a specific task
type: ai
parallel_execution: false
success_exit_code: 0
timeout: 20000
file_version: 0.1.0
---

# /doh:task-versions

## Description
Analyze which versions are affected by a specific task, showing direct requirements and cascading impact across the version roadmap.

## Usage
```
/doh:task-versions <task_number>
/doh:task-versions 005
```

## Implementation
The AI agent will:
1. **Smart Search**: Scan version files ONLY for references to the specific task (avoid full scan)
2. Load and parse ONLY version files that reference the target task
3. Analyze task completion impact on affected versions only
4. Calculate cascading effects through version dependencies (minimal traversal)
5. **Targeted cache update** - Only update cache for versions that reference this task
6. Display focused impact analysis

**Cache Optimization**: 
- Only processes versions that actually reference the queried task
- Skips unrelated versions entirely
- Example: `task-versions 005` only processes v1.0.0, v0.2.0 (if they reference task 005)

## Output Format
```
Task Version Impact: 005 - Frontmatter Integration
=================================================

📋 Task Status:
   Status: ✅ Completed (2025-09-01)
   Epic: versioning
   Parallel: Yes

🎯 Direct Version Impact:
   Required for Versions:
   ├── v1.0.0 (required) ✅ Satisfied
   └── v0.2.0 (required) ✅ Satisfied

🌊 Cascading Impact:
   Unblocks Version Chain:
   v1.0.0 ✅ → v1.1.0 🔓 → v2.0.0 🔓
   
   Timeline Benefits:
   ├── v1.0.0: Ready when other requirements met
   ├── v1.1.0: Can proceed (inherited requirement satisfied)
   └── v2.0.0: Foundation established

📊 Impact Statistics:
   Affects Versions: 3 direct, 2 inherited
   Critical Path: Yes (blocks major release)
   Completion Value: High (unblocks 75% of roadmap)
   
💡 Analysis:
   This task is a critical foundation component that enables
   the entire versioning system roadmap. Its completion 
   removes a major blocker for v1.0.0 and enables cascading
   progress through subsequent releases.

📈 Version Readiness Changes:
   v1.0.0: 40% → 50% (+10%)  
   v1.1.0: 20% → 33% (+13%)
   v2.0.0: 0% → 0% (no change - other blockers remain)
```

## Graph Cache Integration
This command:
- Queries and updates task→version mappings in graph cache
- Provides fast lookup for version impact analysis
- Maintains completion percentage calculations
- Enables synchronization with external systems

## Error Handling
- If task number not found, suggest correct format
- If no version references found, show how to add task to versions
- Handle malformed version files gracefully
- Validate task number format and existence
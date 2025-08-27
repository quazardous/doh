# /doh:feature Command

## Description
Brainstorm on a Feature using the specialized DOH Brainstormer Agent.

## Usage
```
/doh:feature [id]
```

## Parameters
- `id` (optional): ID of existing Feature to brainstorm on. If omitted, starts brainstorming for a new Feature.

## Examples
- `/doh:feature` - Start brainstorming a new Feature
- `/doh:feature 12` - Brainstorm on existing Feature #12

## Implementation
When this command is executed:

1. **Parse Parameters**: Extract optional ID parameter
2. **Load Context**: If ID provided, load existing Feature from `.claude/doh/epics/{epic}/{feature}/feature{id}.md`
3. **Determine Parent**: For new Features, identify parent Epic context
4. **Invoke Brainstormer**: Use DOH Brainstormer Agent for ideation session
5. **Generate Output**: Create or update Feature file with brainstorming results
6. **Folder Management**: Create feature subfolder within epic folder

## Agent Invocation
```
Use the DOH Brainstormer Agent to facilitate a brainstorming session on Feature #{id}.
{existing_context_if_any}
{parent_epic_context_if_new}

Please generate structured brainstorming output following /doh standards for Feature specifications.
Include suggestions for feature folder mnemonic name.
```

## Output Location
- New Features: `.claude/doh/epics/{epic_folder}/{mnemonic}/feature{next_id}.md`
- Existing Features: Updates `.claude/doh/epics/{epic_folder}/{feature_folder}/feature{id}.md`

## Folder Structure
Features are nested within Epic folders:
```
.claude/doh/epics/
└── notification-system/          # Epic folder
    ├── epic2.md                  # Epic definition
    └── email-notifications/      # Feature folder
        └── feature12.md          # Feature definition
```

## Integration
- Links to parent Epic automatically
- Prepares foundation for `/doh:feature-tasks` decomposition
- Maintains nested folder hierarchy
- Ensures proper parent-child traceability
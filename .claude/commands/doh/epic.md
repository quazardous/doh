# /doh:epic Command

## Description

Brainstorm on an Epic using the specialized DOH Brainstormer Agent.

## Usage

```bash
/doh:epic [id]
```

## Parameters

- `id` (optional): ID of existing Epic to brainstorm on. If omitted, starts
  brainstorming for a new Epic.

## Examples

- `/doh:epic` - Start brainstorming a new Epic
- `/doh:epic 2` - Brainstorm on existing Epic #2

## Implementation

When this command is executed:

1. **Parse Parameters**: Extract optional ID parameter
2. **Load Context**: If ID provided, load existing Epic from
   `.doh/epics/{folder}/epic{id}.md` using index lookup
3. **Determine Parent**: For new Epics, identify parent PRD context
4. **Invoke Brainstormer**: Use DOH Brainstormer Agent for ideation session
5. **Generate Output**: Create or update epic{id}.md file with brainstorming results
6. **Folder Management**: Create epic folder with appropriate mnemonic name
7. **Index Update**: Update project-index.json with new ID and metadata

## Agent Invocation

```text
Use the DOH Brainstormer Agent to facilitate a brainstorming session on Epic #{id}.
{existing_context_if_any}
{parent_prd_context_if_new}

Please generate structured brainstorming output following /doh standards for Epic specifications.
Include suggestions for epic folder mnemonic name.
```

## Output Location

- New Epics: `.doh/epics/{mnemonic}/epic{next_id}.md` (next_id from project-index.json)
- Existing Epics: Updates `.doh/epics/{folder}/epic{id}.md` (folder from index lookup)

## Folder Creation

For new Epics, creates descriptive folder structure:

- Suggests mnemonic folder name (e.g., `notification-system`, `user-dashboard`)
- Creates folder if it doesn't exist
- Places epic definition file within folder

## Integration

- Links to parent PRD automatically
- Updates project-index.json with epic metadata (id, name, folder, parent) using counters.next_id
- Prepares foundation for `/doh:epic-tasks` or `/doh:epic-features` decomposition
- Maintains traceability chain through ID system

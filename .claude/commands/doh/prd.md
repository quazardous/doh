# /doh:prd Command

## Description
Brainstorm on a Product Requirements Document (PRD) using the specialized DOH Brainstormer Agent.

## Usage
```
/doh:prd [id]
```

## Parameters
- `id` (optional): ID of existing PRD to brainstorm on. If omitted, starts brainstorming for a new PRD.

## Examples
- `/doh:prd` - Start brainstorming a new PRD
- `/doh:prd 1` - Brainstorm on existing PRD #1

## Implementation
When this command is executed:

1. **Parse Parameters**: Extract optional ID parameter
2. **Load Context**: If ID provided, load existing PRD from `.doh/prds/prd{id}.md` using index lookup
3. **Invoke Brainstormer**: Use DOH Brainstormer Agent for ideation session
4. **Generate Output**: Create or update prd{id}.md file with brainstorming results
5. **Index Update**: Update project-index.json with new ID and metadata
6. **Update Tracking**: Record brainstorming session in project logs

## Agent Invocation
```
Use the DOH Brainstormer Agent to facilitate a brainstorming session on PRD #{id}. 
{existing_context_if_any}

Please generate structured brainstorming output following /doh standards for PRD specifications.
```

## Output Location
- New PRDs: `.doh/prds/prd{next_id}.md` (next_id from project-index.json)
- Existing PRDs: Updates `.doh/prds/prd{id}.md`

## Integration
- Automatically assigns next available ID for new PRDs (from project-index.json counters.next_id)
- Updates project-index.json with PRD metadata (id, name, status)
- Links to parent issues or business objectives if specified
- Prepares foundation for future `/doh:prd-epics` decomposition
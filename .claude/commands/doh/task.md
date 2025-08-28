# /doh:task Command

## Description

Brainstorm on a Task using the specialized DOH Brainstormer Agent.

## Usage

```
/doh:task [id]
```

## Parameters

- `id` (optional): ID of existing Task to brainstorm on. If omitted, starts brainstorming for a new Task.

## Examples

- `/doh:task` - Start brainstorming a new Task
- `/doh:task 45` - Brainstorm on existing Task #45

## Implementation

When this command is executed:

1. **Parse Parameters**: Extract optional ID parameter
2. **Load Context**: If ID provided, locate and load existing Task file
3. **Determine Parent**: For new Tasks, identify parent Epic or Feature context
4. **Invoke Brainstormer**: Use DOH Brainstormer Agent for ideation session
5. **Generate Output**: Create or update Task file with brainstorming results
6. **Placement Logic**: Place in appropriate folder (Epic or Feature subfolder)

## Agent Invocation

```
Use the DOH Brainstormer Agent to facilitate a brainstorming session on Task #{id}.
{existing_context_if_any}
{parent_context_if_new}

Please generate structured brainstorming output following /doh standards for Task specifications.
Focus on actionable implementation details and technical considerations.
```

## Output Location

Tasks can be placed in two locations:

### Direct under Epic

```
.claude/doh/epics/{epic_folder}/task{id}.md
```

### Under Feature subfolder

```
.claude/doh/epics/{epic_folder}/{feature_folder}/task{id}.md
```

## Task Specifications

Brainstorming output for tasks should include:

- Clear acceptance criteria
- Technical implementation approach
- Dependencies and prerequisites  
- Effort estimation
- Testing considerations
- Code traceability references

## Integration

- Links to parent Epic or Feature automatically
- Prepares task for implementation phase
- Establishes foundation for code traceability
- Maintains proper hierarchical relationships

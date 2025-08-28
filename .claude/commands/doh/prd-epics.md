# /doh:prd-epics Command

## Description

Analyze a PRD and create/update epics with suggested mnemonics using the specialized DOH Decomposer Agent.

## Usage

```
/doh:prd-epics <prd_id>
```

## Parameters

- `prd_id` (required): ID of the PRD to analyze and decompose into epics

## Examples

- `/doh:prd-epics 1` - Analyze PRD #1 and suggest/create epics

## Implementation

When this command is executed:

1. **Load PRD**: Read source PRD from `.claude/doh/prds/prd{id}.md`
2. **Analyze Content**: Extract major functional areas, user journeys, and system components
3. **Invoke Decomposer**: Use DOH Decomposer Agent for analysis and suggestion
4. **Generate Epics**: Create epic files with appropriate folder structure
5. **Link Relationships**: Establish parent-child references between PRD and epics

## Agent Invocation

```
Use the DOH Decomposer Agent to analyze PRD #{prd_id} and suggest logical epic breakdowns.

PRD Content:
{prd_content}

Please identify:
- Major functional areas that warrant separate epics
- User journey boundaries
- System component groupings
- Suggested mnemonic folder names for each epic
- Clear scope definition for each epic

Generate structured epic specifications following /doh standards.
```

## Decomposition Criteria

The agent analyzes for:

- **Functional Boundaries**: Distinct feature sets or capabilities
- **User Personas**: Different user types or workflows  
- **System Components**: Backend, frontend, integrations, etc.
- **Project Phases**: Sequential delivery milestones
- **Domain Areas**: Business logic groupings

## Output Generation

For each identified epic:

1. Creates epic folder with mnemonic name
2. Generates `epic{id}.md` file within folder
3. Populates with structured specification
4. Links back to parent PRD
5. Suggests next steps for further decomposition

## Folder Structure Created

```
.claude/doh/epics/
├── notification-system/        # Epic folder (mnemonic)
│   └── epic2.md               # Epic definition
├── user-dashboard/            # Another epic folder
│   └── epic3.md               # Epic definition  
└── data-analytics/            # Third epic folder
    └── epic4.md               # Epic definition
```

## Integration

- Updates PRD file with references to generated epics
- Prepares epics for further decomposition with `/doh:epic-tasks` or `/doh:epic-features`
- Maintains complete traceability chain

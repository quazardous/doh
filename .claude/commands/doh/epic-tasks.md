# /doh:epic-tasks Command

## Description
Analyze an epic and create/update tasks directly using the specialized DOH Decomposer Agent.

## Usage
```
/doh:epic-tasks <epic_id>
```

## Parameters
- `epic_id` (required): ID of the Epic to analyze and decompose into tasks

## Examples
- `/doh:epic-tasks 2` - Analyze Epic #2 and create direct tasks

## Implementation
When this command is executed:

1. **Locate Epic**: Find epic file in `.claude/doh/epics/{folder}/epic{id}.md`
2. **Load Context**: Read epic specification and any existing tasks
3. **Analyze Scope**: Identify actionable implementation units
4. **Invoke Decomposer**: Use DOH Decomposer Agent for task breakdown
5. **Generate Tasks**: Create task files directly under epic folder
6. **Update References**: Link tasks to parent epic

## Agent Invocation
```
Use the DOH Decomposer Agent to analyze Epic #{epic_id} and break it down into direct implementation tasks.

Epic Content:
{epic_content}

Please identify:
- Specific, actionable implementation units
- Technical tasks and development work items
- Configuration and setup tasks
- Testing and validation tasks
- Documentation tasks

Generate structured task specifications following /doh standards.
Each task should be independently implementable and testable.
```

## Task Identification Criteria
The agent analyzes for:
- **Implementation Units**: Specific code modules or functions
- **Technical Setup**: Infrastructure, configuration, dependencies
- **Data Layer**: Database changes, migrations, models
- **API Development**: Endpoints, services, integrations
- **UI Components**: Frontend elements and interactions
- **Testing Tasks**: Unit tests, integration tests, validation
- **Documentation**: Technical docs, user guides, API docs

## Output Generation
Tasks created directly under epic folder:
```
.claude/doh/epics/notification-system/
├── epic2.md                    # Epic definition
├── task15.md                   # Task: Setup WebSocket server
├── task16.md                   # Task: Implement notification queue
├── task17.md                   # Task: Create notification UI components
└── task18.md                   # Task: Write integration tests
```

## Task Specifications
Each generated task includes:
- Clear acceptance criteria
- Technical implementation approach  
- Dependencies on other tasks
- Estimated effort/complexity
- Testing requirements
- Code traceability placeholders

## Integration
- Links all tasks back to parent epic
- Establishes task dependencies and sequencing
- Prepares tasks for implementation phase
- Maintains traceability for future code references
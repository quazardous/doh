# /doh:feature-tasks Command

## Description
Analyze a feature and create/update tasks using the specialized DOH Decomposer Agent.

## Usage
```
/doh:feature-tasks <feature_id>
```

## Parameters
- `feature_id` (required): ID of the Feature to analyze and decompose into tasks

## Examples
- `/doh:feature-tasks 12` - Analyze Feature #12 and create tasks

## Implementation
When this command is executed:

1. **Locate Feature**: Find feature file in `.claude/doh/epics/{epic}/{feature}/feature{id}.md`
2. **Load Context**: Read feature specification and parent epic context
3. **Analyze Implementation**: Identify specific tasks needed for feature completion
4. **Invoke Decomposer**: Use DOH Decomposer Agent for task breakdown
5. **Generate Tasks**: Create task files within feature subfolder
6. **Link Hierarchy**: Maintain feature-task relationships

## Agent Invocation
```
Use the DOH Decomposer Agent to analyze Feature #{feature_id} and break it down into implementation tasks.

Feature Content:
{feature_content}

Parent Epic Context:
{epic_context}

Please identify:
- Specific implementation tasks for this feature
- Frontend development tasks
- Backend development tasks  
- Integration tasks
- Testing and validation tasks
- Configuration and deployment tasks

Generate structured task specifications following /doh standards.
Tasks should be focused on completing this specific feature.
```

## Task Identification Criteria
The agent analyzes for:
- **Frontend Tasks**: UI components, user interactions, styling
- **Backend Tasks**: APIs, business logic, data processing  
- **Integration Tasks**: External services, system connections
- **Data Tasks**: Models, migrations, database work
- **Testing Tasks**: Unit tests, integration tests, E2E tests
- **Configuration**: Environment setup, feature flags, settings
- **Documentation**: User guides, technical documentation

## Output Generation
Tasks created within feature subfolder:
```
.claude/doh/epics/notification-system/email-notifications/
├── feature12.md                        # Feature definition
├── task25.md                          # Task: Email template engine
├── task26.md                          # Task: SMTP configuration
├── task27.md                          # Task: Email queue management
├── task28.md                          # Task: Unsubscribe handling
└── task29.md                          # Task: Email analytics tracking
```

## Task Specifications
Each generated task includes:
- Feature-specific acceptance criteria
- Technical implementation details
- Dependencies within the feature scope
- Integration points with other features
- Testing requirements specific to the feature
- Code traceability for feature completion

## Integration
- Links all tasks back to parent feature and epic
- Maintains nested hierarchy integrity
- Establishes task sequencing within feature scope
- Prepares for focused feature development
- Enables feature-based parallel development workflows
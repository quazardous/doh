# /doh:epic-features Command

## Description
Analyze an epic and create/update features with mnemonics using the specialized DOH Decomposer Agent.

## Usage
```
/doh:epic-features <epic_id>
```

## Parameters
- `epic_id` (required): ID of the Epic to analyze and decompose into features

## Examples
- `/doh:epic-features 2` - Analyze Epic #2 and create/suggest features

## Implementation
When this command is executed:

1. **Locate Epic**: Find epic file in `.claude/doh/epics/{folder}/epic{id}.md`
2. **Load Context**: Read epic specification and any existing features
3. **Analyze Groupings**: Identify logical feature boundaries
4. **Invoke Decomposer**: Use DOH Decomposer Agent for feature breakdown
5. **Generate Features**: Create feature subfolders and definition files
6. **Update Structure**: Maintain proper nested hierarchy

## Agent Invocation
```
Use the DOH Decomposer Agent to analyze Epic #{epic_id} and identify logical feature groupings.

Epic Content:
{epic_content}

Please identify:
- Logical groupings of related functionality
- User-facing feature sets
- Technical capability groups
- Integration boundaries
- Suggested mnemonic folder names for each feature

Generate structured feature specifications following /doh standards.
Features should group related tasks and represent coherent user-facing capabilities.
```

## Feature Identification Criteria
The agent analyzes for:
- **User Workflows**: Complete user interaction flows
- **Functional Cohesion**: Related capabilities that belong together
- **Technical Boundaries**: Natural architectural separations
- **Integration Points**: External system interactions
- **UI/UX Groupings**: Related interface elements
- **Business Logic Areas**: Coherent domain functionality

## Output Generation
Creates nested feature structure:
```
.claude/doh/epics/notification-system/
├── epic2.md                           # Epic definition
├── email-notifications/               # Feature folder
│   └── feature12.md                   # Feature definition
├── push-notifications/                # Feature folder
│   └── feature13.md                   # Feature definition
└── notification-preferences/          # Feature folder
    └── feature14.md                   # Feature definition
```

## Feature Specifications
Each generated feature includes:
- Clear feature scope and boundaries
- User stories and acceptance criteria
- Technical requirements and constraints
- Integration points and dependencies
- UI/UX considerations
- Preparation for task decomposition

## Integration
- Links all features back to parent epic
- Creates foundation for `/doh:feature-tasks` decomposition
- Maintains nested folder hierarchy
- Establishes feature interdependencies
- Prepares for parallel development workflows
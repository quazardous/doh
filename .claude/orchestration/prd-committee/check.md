# PRD Committee Gate Check

## Purpose
**Go/No-Go gate** before starting the committee. Realistic checks for Project Management Consultant approach - key info must be available either from user input OR discoverable from project context.

## Gate Check Philosophy
The committee acts as Project Management Consultants who can:
- **Discover** technical debt from existing codebase analysis
- **Infer** current stack from project files (package.json, requirements.txt, etc.)
- **Extract** version info from existing project structure
- **Analyze** existing components and architecture

**Only block if essential business context is missing AND cannot be reasonably inferred.**

## Essential Gate Checks

### 1. Valid Feature Identity
Must have sufficient identity to proceed:
- `feature_name` (kebab-case, safe for directories) OR can be generated from description
- `description` (feature summary) - this is the minimum business context needed

### 2. Business Direction Available
Must have enough business context to guide the committee (from user OR inferable):
- **Problem understanding**: What problem does this solve? (user input OR inferable from description)
- **Basic requirements**: Core functionality needed (user input OR can be discovered/refined by committee)
- **Success criteria**: How we measure success (user input OR committee can propose based on problem)

### 3. Project Context Discoverable
The orchestrator should attempt to discover automatically:
- `current_stack` - Analyze project files (package.json, composer.json, requirements.txt, etc.)
- `current_version` - Read VERSION file, git tags, or version files
- `technical_context` - Examine existing architecture, .doh structure
- `target_version` - Use current version + semantic versioning rules if not specified

### 4. Session Configuration
Defaults available if not specified:
- `execution_mode` - Default to "sequential" if not specified
- `created` - Auto-generate timestamp

### 5. Enhanced Context (Discoverable)
The committee can discover/generate during analysis:
- `business_context` - Can be developed through committee analysis
- `constraints` - Can be discovered from project analysis and technical debt assessment
- `complexity` - Committee can assess during draft phase
- `user_impact` - Committee can evaluate during UX analysis  
- `breaking_changes` - Committee can determine during technical architecture phase
- `dependencies` - Discoverable through project analysis and epic/task review

## Gate Decision Logic

The orchestrator performs this **realistic gate check**:

1. **Verify minimum business context**
   - If `description` missing AND cannot infer from feature name → **NO-GO**: "Need basic feature description"
   - If `feature_name` invalid AND cannot generate from description → **NO-GO**: "Need valid feature identifier"

2. **Auto-discover project context**
   - Attempt to discover `current_stack` from project files
   - Read `current_version` from VERSION file or git tags
   - Extract `technical_context` from .doh structure, README, architecture files
   - Set `execution_mode` to "sequential" if not specified
   - Generate `created` timestamp

3. **Assess business direction adequacy**
   - If problem understanding available (explicit or inferable) → **PROCEED**
   - If basic requirements available (explicit or discoverable) → **PROCEED**  
   - If success criteria available (explicit or committee can reasonably propose) → **PROCEED**
   - If ALL three missing AND cannot be reasonably inferred → **NO-GO**: "Need basic business direction"

4. **Create committee session structure**
   - Create `.doh/committees/{feature_name}/` directory
   - Create round directories as needed during workflow
   - Ensure write permissions for all output locations

5. **Note discoverable context for committee**
   - Mark what was auto-discovered vs. provided by user
   - Flag what the committee should focus on discovering/refining
   - List areas where committee analysis will be especially valuable

6. **Final decision**
   - If minimum business context available → **GO**: "Committee ready - will discover technical context"
   - If essential business direction missing → **NO-GO**: "Need clearer feature direction"

**Gate responsibilities**: Validate seed + Create session workspace → Committee ready to execute.
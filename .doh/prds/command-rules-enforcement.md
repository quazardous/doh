---
name: command-rules-enforcement
description: Ensure AI commands are aware of and strictly follow all applicable rules from the DOH rules system
status: backlog
created: 2025-09-02T07:05:19Z
updated: 2025-09-02T07:22:20Z
target_version: 0.5.1
file_version: 0.1.0
---

# PRD: command-rules-enforcement

## Executive Summary

Establish a comprehensive rule enforcement system for AI-executed DOH commands by ensuring each command explicitly references and acknowledges all applicable rules from `.claude/rules/`. This initiative will create rule-aware command contexts that prevent violations of established patterns, improve consistency, and reduce errors in AI command execution.

## Problem Statement

AI agents executing DOH commands currently lack consistent awareness of applicable rules, with a critical gap in **rule-less commands**:

### Primary Issue: Commands with No Rules Specified
Many DOH commands have **zero rule references**, leaving AI agents without guidance on:
- Which patterns to follow
- What mistakes to avoid  
- How to handle edge cases consistently
- When to use API functions vs direct access

### Secondary Issues: Incomplete Rule Awareness
Even commands with some rules often miss applicable ones:
1. **Rule violations**: Commands may violate established patterns without the AI realizing it
2. **Inconsistent behavior**: Different commands follow different subsets of rules
3. **Context blindness**: AI agents don't always know which rules apply to their current operation
4. **Maintenance burden**: Rule updates don't automatically propagate to command awareness

### Impact Examples:
- Commands might directly edit files instead of using API functions
- DateTime formatting might be inconsistent
- Task workflow rules might be violated
- Frontmatter operations might not follow established patterns

## User Stories

### Primary User: AI Agent
**As an** AI agent executing DOH commands  
**I want** explicit rule references in my command context  
**So that** I can strictly follow all applicable patterns and avoid violations

**Acceptance Criteria:**
- Each command lists all applicable rules
- Rules are loaded into context before execution
- Clear instructions on rule precedence
- Examples of correct rule application

### Primary User: DOH Developer
**As a** DOH developer creating new commands  
**I want** a template that shows how to specify required rules  
**So that** my commands guide AI agents correctly

**Acceptance Criteria:**
- Command template with rule specification section
- Documentation on determining applicable rules
- Validation that rules are properly referenced
- Example "model" command showing best practices

### Primary User: System Administrator
**As a** system administrator  
**I want** confidence that AI commands follow established patterns  
**So that** the system remains consistent and maintainable

**Acceptance Criteria:**
- All commands have rule specifications
- AI agents acknowledge rules before execution
- Audit trail of rule compliance
- No command executes without rule context

## Requirements

### Functional Requirements

#### 1. Rule Specification Format

Each AI command file must include a `## Required Rules` section that explicitly lists all applicable rules:

```markdown
## Required Rules

**IMPORTANT:** Before executing this command, read and follow these rules in order:

1. `.claude/rules/datetime.md` - For consistent datetime handling
2. `.claude/rules/frontmatter-operations.md` - For frontmatter field updates
3. `.claude/rules/task-workflow.md` - For task status transitions
4. `.claude/rules/doh-api-usage.md` - For using API functions instead of direct file access

**Rule Precedence:** If rules conflict, follow the order listed above.
```

#### 2. Rule Categories and Applicability

**Core Rules** (apply to most commands):
- `datetime.md` - Any command dealing with timestamps
- `frontmatter-operations.md` - Any command modifying markdown files
- `doh-api-usage.md` - Any command reading/writing DOH data (NEW - to be created)

**Workflow Rules** (apply to specific workflows):
- `task-workflow.md` - Task creation, status updates
- `worktree-operations.md` - Git worktree commands
- `agent-coordination.md` - Multi-agent operations
- `standard-patterns.md` - General code patterns

**Specialized Rules** (context-specific):
- `commit-message-format.md` - Git operations
- `test-patterns.md` - Test-related commands
- `documentation-standards.md` - Doc generation

#### 3. Model Command Template

Create a "témoin" (model/reference) command that demonstrates perfect rule compliance:

**Selected Model Command: `/doh:task-new`**

This command is representative because it:
- Creates files (needs frontmatter rules)
- Updates registries (needs data API rules)
- Manages workflow states (needs task workflow rules)
- Handles timestamps (needs datetime rules)
- Interacts with git (needs worktree rules)

```markdown
---
name: task-new
type: ai
description: Create new task following all DOH rules
---

## Required Rules

**CRITICAL:** These rules MUST be loaded and followed strictly:

1. `.claude/rules/task-workflow.md` - Core task creation workflow
2. `.claude/rules/frontmatter-operations.md` - Frontmatter field management
3. `.claude/rules/datetime.md` - Timestamp formatting
4. `.claude/rules/doh-api-usage.md` - Use API functions only
5. `.claude/rules/numbering-conventions.md` - Task numbering rules

## Pre-execution Checklist

Before proceeding, acknowledge each rule:
- [ ] I have read task-workflow.md and will follow task creation patterns
- [ ] I have read frontmatter-operations.md and will use proper field updates
- [ ] I have read datetime.md and will use ISO 8601 format
- [ ] I have read doh-api-usage.md and will use API functions only
- [ ] I have read numbering-conventions.md and will use proper task numbers

## Command Implementation

[Rest of command following all specified rules...]
```

#### 4. Rule Enforcement Patterns

1. **Pre-flight acknowledgment**:
   ```markdown
   ## Rule Acknowledgment
   
   Before executing, confirm understanding of:
   - Task workflow states: pending → in_progress → completed
   - Frontmatter must use update_frontmatter_field()
   - Dates must use date -u +"%Y-%m-%dT%H:%M:%SZ"
   - Version must use get_current_version()
   ```

2. **Inline rule reminders**:
   ```markdown
   ### Step 3: Update task status
   **Rule: task-workflow.md** - Use proper status transition
   **Rule: doh-api-usage.md** - Use update_frontmatter_field(), not direct edit
   ```

3. **Rule violation guards**:
   ```markdown
   ### Common Mistakes to Avoid
   ❌ DON'T: `cat VERSION`
   ✅ DO: `get_current_version`
   
   ❌ DON'T: Edit frontmatter directly
   ✅ DO: Use frontmatter API functions
   ```

#### 5. Command Audit and Update Plan

**Phase 1: Comprehensive Command Audit**
- List all AI commands in `.claude/commands/doh/`
- **Prioritize commands with ZERO rule references** (biggest impact)
- Categorize commands by risk level and usage frequency
- Create detailed compliance matrix showing current vs required rules

**Phase 2: Rule-Less Command Remediation**  
- **Focus exclusively on commands with no rules specified**
- Add comprehensive `## Required Rules` sections
- Include pre-execution checklists
- Add inline rule reminders for critical operations
- Test with AI agents to ensure compliance

**Phase 3: Incomplete Rule Command Updates**
- Address commands with partial rule coverage
- Fill gaps in existing rule specifications
- Ensure consistency with model command patterns

**Phase 4: Enforcement Infrastructure**
- Command template generator
- Rule applicability checker
- Compliance validator

### Non-Functional Requirements

#### Documentation
- Clear rule specification format
- Examples in each rule file
- Command developer guide
- AI agent instruction manual

#### Maintainability
- Rules referenced by path for easy updates
- Single source of truth for each rule
- Version tracking for rule changes
- Backward compatibility considerations

#### Usability
- Rules presented clearly in command context
- No ambiguity in rule application
- Progressive disclosure of complexity
- Clear error messages for violations

#### Auditability
- AI agents acknowledge rules explicitly
- Command execution logs show rule compliance
- Ability to trace decisions to rules
- Post-execution validation possible

## Success Criteria

1. **Coverage metrics**:
   - **PRIORITY**: 100% of previously rule-less commands now have rule specifications
   - 95%+ of AI commands have comprehensive rule coverage
   - All applicable rules identified for each command
   - Zero unspecified rule dependencies

2. **Compliance metrics**:
   - 95%+ reduction in rule violations
   - AI agents acknowledge rules before execution
   - Consistent behavior across similar commands

3. **Developer metrics**:
   - New commands created with proper rule specs
   - Reduced time to identify applicable rules
   - Fewer questions about correct patterns

4. **Quality metrics**:
   - Reduced inconsistencies in command execution
   - Fewer bug reports related to rule violations
   - Improved code review efficiency

## Constraints & Assumptions

### Constraints
- Cannot modify core AI behavior
- Must work within existing command structure
- Rules must remain in `.claude/rules/` directory
- Changes must be backward compatible

### Assumptions
- AI agents will read and follow specified rules
- Rule files remain stable and accessible
- Developers will maintain rule specifications
- Rules are comprehensive enough to cover edge cases

## Out of Scope

- Modifying AI agent core capabilities
- Creating new rule types or categories
- Automatic rule inference or discovery
- Runtime rule validation engines
- Rule versioning system
- Cross-command rule coordination
- Rule conflict resolution algorithms
- Machine learning for rule application

## Dependencies

### Internal Dependencies
- All `.claude/rules/*.md` files must be complete
- Command files in `.claude/commands/doh/`
- Data API functions (for rule examples)
- Documentation system

### External Dependencies
- AI agent's ability to read and interpret markdown
- File system access to rules directory
- Git for version control

## Implementation Phases

### Phase 1: Rule Catalog and Mapping
1. Catalog all existing rules in `.claude/rules/`
2. Create new rule: `.claude/rules/doh-api-usage.md`
3. Create rule applicability matrix
4. Document rule categories and use cases
5. Identify rule dependencies and conflicts

### Phase 2: Model Command Development
1. Select `/doh:task-new` as model command
2. Add comprehensive rule specifications
3. Include all enforcement patterns
4. Test with AI agents for compliance

### Phase 3: Command Updates - Rule-Less Commands (PRIORITY)
**Focus on commands with ZERO rule references first:**
1. Audit all commands in `.claude/commands/doh/` to identify rule-less commands
2. Categorize by risk level (high-impact commands get priority)
3. Add comprehensive rule specifications to rule-less commands
4. Examples likely to need rules:
   - Commands creating/modifying files
   - Commands reading data directly
   - Commands with complex workflows

### Phase 4: Command Updates - Incomplete Rule Commands  
Commands that have some rules but are missing applicable ones:
1. `/doh:task-new` (model command - ensure complete)
2. `/doh:epic-new`
3. `/doh:prd-new` 
4. `/doh:version-bump`
5. `/doh:task-reopen`

### Phase 5: Command Updates - Full Coverage
1. All version-related commands
2. All worktree commands  
3. All epic management commands
4. All PRD commands

### Phase 6: Documentation and Training
1. Create command developer guide
2. Update CLAUDE.md with rule enforcement
3. Create rule quick reference
4. Develop compliance checking tools

### Phase 7: Validation and Rollout
1. Audit all updated commands
2. Test with AI agents
3. Gather feedback
4. Iterate on format and content

## Risk Mitigation

1. **AI non-compliance**: Clear, explicit rule statements with examples
2. **Rule conflicts**: Explicit precedence ordering
3. **Missed rules**: Comprehensive audit and peer review
4. **Maintenance burden**: Automated rule reference validation
5. **Developer resistance**: Clear benefits and templates

## Appendix: Rule Applicability Matrix

### Command-to-Rule Mapping (Sample)

| Command | datetime | frontmatter | task-workflow | doh-api | worktree | Other |
|---------|----------|-------------|---------------|----------|----------|-------|
| task-new | ✓ | ✓ | ✓ | ✓ | ○ | numbering |
| epic-new | ✓ | ✓ | ○ | ✓ | ○ | - |
| version-bump | ✓ | ✓ | ○ | ✓ | ○ | versioning |
| prd-new | ✓ | ✓ | ○ | ✓ | ○ | - |
| task-reopen | ○ | ✓ | ✓ | ✓ | ○ | - |

Legend: ✓ Required, ○ Optional/Conditional

### Rule Quick Reference

1. **datetime.md**: ISO 8601 format, use `date -u +"%Y-%m-%dT%H:%M:%SZ"`
2. **frontmatter-operations.md**: Use API functions, never direct edit
3. **task-workflow.md**: Follow status transitions, update descriptions
4. **doh-api-usage.md**: Use get_current_version, not cat VERSION
5. **worktree-operations.md**: Proper branch naming, cleanup
6. **agent-coordination.md**: Multi-agent task distribution
7. **standard-patterns.md**: General coding conventions
8. **numbering-conventions.md**: Three-digit padding, sequential
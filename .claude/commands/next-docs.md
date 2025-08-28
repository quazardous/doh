# /next-docs - Documentation Task Recommendations

Focused access to documentation and writing tasks - perfect for documentation sprints, improving project communication, or when you want to enhance project clarity and usability.

## Usage

```bash
/next-docs [query] [--format=output] [--limit=N] [--cache-only]
```

## Description

This is a shortcut command for `/doh-sys:next --context=docs` optimized for documentation-focused work sessions. Shows tasks that improve project documentation, communication, and knowledge sharing - essential for project maintainability and team collaboration.

## Parameters

- `query`: (Optional) Natural language query to refine documentation focus
  - **Examples**: `"README improvements"`, `"workflow documentation"`, `"what docs need updating"`
  - **Smart filtering**: Combines documentation filter with specific documentation areas
- `--format=output`: Control detail level for documentation planning
  - `brief` - Concise task list (default for quick documentation decisions)
  - `plan` - Step-by-step writing/editing plans for immediate execution
  - `detailed` - Full analysis with documentation impact and relationships
- `--limit=N`: Maximum tasks to show (default: 3-4 for focused documentation work)
- `--cache-only`: Ultra-fast mode from memory (perfect for documentation sprints)

## Documentation Task Categories

Shows tasks focused on:
- 📝 **README Updates** - Main project documentation and getting started guides
- 📋 **Workflow Documentation** - DEVELOPMENT.md, WORKFLOW.md process improvements
- 📊 **TODO Management** - Task documentation, completion tracking, project planning
- 🔧 **Technical Documentation** - API docs, architecture, implementation guides
- 📖 **User Guides** - Usage examples, tutorials, best practices
- 🏷️ **Meta Documentation** - Documentation structure, cross-references, navigation

## Example Usage

```bash
# Focus on documentation tasks
/next-docs
# Shows 3-4 best documentation improvements → perfect for doc sprints

# Documentation with implementation plans  
/next-docs --format=plan
# Documentation tasks → with writing/editing steps → ready to execute

# Ultra-fast for documentation workflow
/next-docs --cache-only
# Sub-100ms response → instant documentation task suggestions

# Specific documentation needs
/next-docs "what README improvements are needed?"
# Natural language → README-specific documentation tasks

# Documentation sprint planning
/next-docs --limit=5 --format=plan
# Multiple documentation tasks → with plans → full documentation session
```

## Smart Documentation Examples

**Project Clarity:**
```bash
/next-docs "project clarity"
# → README structure improvements
# → Getting started guide enhancements  
# → Navigation and cross-reference updates
```

**Process Documentation:**
```bash
/next-docs "workflow and development process"
# → DEVELOPMENT.md updates
# → WORKFLOW.md improvements
# → Process automation documentation
```

**User Experience:**
```bash
/next-docs "user experience and guides"
# → Usage examples
# → Tutorial creation
# → Best practices documentation
```

## Common Documentation Scenarios

**Documentation Sprint:**
```bash
/next-docs --format=plan --limit=5
# Multiple doc tasks → with implementation plans → focused documentation session
```

**Project Polish:**
```bash
/next-docs "project presentation and clarity"
# Professional documentation improvements → project polish
```

**Onboarding Improvement:**
```bash
/next-docs "new user onboarding"
# Getting started improvements → easier project adoption
```

**Technical Debt Reduction:**
```bash
/next-docs "outdated documentation"
# Find and update stale documentation → maintain accuracy
```

## Documentation Impact Analysis

Documentation tasks often provide:
- 🎯 **High Impact** - Improves entire project usability
- ⚡ **Quick Completion** - Many documentation tasks are 1-2 hours
- 🔗 **Enabling Effect** - Better docs help with all future development
- 👥 **Collaboration Value** - Essential for team and open source projects

## Workflow Integration

**Weekly Documentation Time:**
```bash
# Dedicated documentation improvement sessions
/next-docs --format=plan --limit=3
# Pick 2-3 documentation improvements → focused writing session
```

**Between Development Tasks:**
```bash
# Quick documentation improvements between coding
/next-docs --cache-only --limit=1
# Single quick documentation win → maintain project polish
```

**Epic Completion Documentation:**
```bash
# After completing major features
/next-docs "update documentation for recent changes"
# Document new features → maintain documentation currency
```

## Documentation Quality Focus

Shows tasks that improve:
- **Clarity** - Making complex concepts understandable
- **Completeness** - Filling documentation gaps
- **Accuracy** - Updating outdated information  
- **Navigation** - Cross-references and document structure
- **Examples** - Practical usage demonstrations
- **Onboarding** - New user experience improvements

## Integration

This command is equivalent to:
```bash
/doh-sys:next --context=docs [same-parameters]
```

But provides:
- **Documentation-focused mindset** for writing and editing sessions
- **Faster access** to project communication improvements
- **Shorter syntax** for documentation sprints
- **Optimized defaults** for documentation workflow

Perfect for:
- Dedicated documentation improvement sessions
- Project polish and professional presentation
- Improving team collaboration through better docs
- Maintaining project documentation currency
- Building user adoption through clear guides

## Success Criteria

- Shows only documentation and writing-focused tasks
- Provides clear documentation improvement opportunities
- Maintains smart memory and performance features
- Supports both quick documentation wins and comprehensive documentation sprints
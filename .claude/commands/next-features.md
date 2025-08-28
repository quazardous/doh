# /next-features - Feature Development Recommendations

Focused access to core functionality development tasks - perfect for implementation sessions, building new capabilities, or when you want to advance the project's feature set and technical capabilities.

## Usage

```bash
/next-features [query] [--format=output] [--limit=N] [--cache-only]
```

## Description

This is a shortcut command for `/doh-sys:next --context=features` optimized for feature development work sessions. Shows tasks that implement new functionality, enhance existing capabilities, or build the technical foundation for advanced features.

## Parameters

- `query`: (Optional) Natural language query to refine feature focus
  - **Examples**: `"core functionality ready to implement"`, `"what features can I build next"`
  - **Smart filtering**: Combines feature filter with specific implementation areas
- `--format=output`: Control detail level for implementation planning
  - `brief` - Concise task list (default for quick feature selection)
  - `plan` - Step-by-step implementation plans for technical execution
  - `detailed` - Full analysis with dependencies, impact, and technical requirements
- `--limit=N`: Maximum tasks to show (default: 3 for focused feature work)
- `--cache-only`: Ultra-fast mode from memory (perfect for rapid development workflow)

## Feature Development Categories

Shows tasks focused on:
- ⚡ **Core Functionality** - Essential features and primary capabilities
- 🔧 **System Enhancements** - Infrastructure improvements and tool extensions
- 🚀 **New Capabilities** - Novel features that expand project scope
- 🔗 **Integration Features** - Connecting systems and improving workflow
- 🎯 **User Experience** - Features that improve usability and interaction
- 🏗️ **Architecture** - Foundational systems that enable future development

## Example Usage

```bash
# Focus on implementable features
/next-features
# Shows 3 best feature development opportunities → ready for technical work

# Features with implementation plans
/next-features --format=plan  
# Feature tasks → with technical implementation steps → ready to code

# Ultra-fast for development workflow
/next-features --cache-only
# Sub-100ms response → instant feature development suggestions

# Specific feature areas
/next-features "what core features need implementation?"
# Natural language → core functionality development tasks

# Feature development sprint planning
/next-features --limit=4 --format=detailed
# Multiple features → with dependencies and impact analysis → strategic development
```

## Smart Feature Examples

**Core System Features:**
```bash
/next-features "core system capabilities"
# → Advanced task intelligence systems
# → Workflow automation enhancements  
# → Command pipeline improvements
```

**User Experience Features:**
```bash
/next-features "user experience improvements"
# → Interactive command enhancements
# → Auto-completion and help systems
# → Workflow optimization features
```

**Integration Features:**
```bash  
/next-features "system integration and connectivity"
# → External tool integrations
# → API enhancements
# → Cross-system communication features
```

## Common Feature Development Scenarios

**Technical Implementation Session:**
```bash
/next-features --format=plan --limit=2
# Pick 1-2 features → with implementation plans → focused development session
```

**Architecture Building:**
```bash
/next-features "foundational features"
# System foundation work → enables future development
```

**Capability Expansion:**
```bash
/next-features "new capabilities and functionality"
# Novel features → expand project scope and value
```

**Epic Feature Work:**
```bash
/next-features --format=detailed "high impact features"
# Strategic features → understand dependencies and impact → epic-level development
```

## Feature Development Impact

Feature tasks typically provide:
- 🎯 **High Value** - Directly advances project capabilities
- 🔧 **Technical Growth** - Builds implementation skills and patterns
- 🚀 **Future Enablement** - Creates foundation for advanced features  
- 👥 **User Benefit** - Improves project utility and adoption
- 📈 **Project Advancement** - Moves project toward strategic goals

## Development Workflow Integration

**Feature Development Sprints:**
```bash
# Dedicated technical implementation sessions
/next-features --format=plan --limit=3
# Pick 2-3 related features → technical focus session
```

**Between Documentation Work:**
```bash
# Balance documentation with technical implementation
/next-features --cache-only --limit=1
# Quick technical win → maintain development momentum
```

**Epic Implementation Planning:**
```bash
# Major feature development planning
/next-features --format=detailed "epic level features"
# Understand complex features → plan epic-level implementation
```

## Technical Complexity Awareness

Shows features with consideration for:
- **Dependencies** - What needs to be complete first
- **Complexity** - Implementation difficulty and time requirements
- **Impact** - How this feature affects other systems
- **Testing** - What validation and quality assurance is needed
- **Documentation** - What docs need updating after implementation
- **Integration** - How this connects with existing systems

## Feature Readiness Assessment

Prioritizes features that are:
- ✅ **Well-Defined** - Clear requirements and acceptance criteria
- ✅ **Dependency-Ready** - All blockers completed or minimal
- ✅ **Technically Feasible** - Implementation approach is clear
- ✅ **Value-Driven** - Provides meaningful capability improvement
- ✅ **Testable** - Can be validated and quality-assured

## Integration

This command is equivalent to:
```bash
/doh-sys:next --context=features [same-parameters]
```

But provides:
- **Technical implementation focus** for development sessions
- **Faster access** to capability-building tasks
- **Shorter syntax** for feature development workflow
- **Optimized defaults** for technical work planning

Perfect for:
- Technical implementation sprints and development sessions
- Building new project capabilities and functionality
- Advancing strategic project goals through feature development
- Balancing technical work with documentation and maintenance
- Planning epic-level feature development initiatives

## Success Criteria

- Shows only core functionality and feature development tasks
- Provides clear technical implementation opportunities
- Maintains dependency awareness and technical feasibility
- Supports both quick feature wins and complex feature development planning
# /next-quick - Quick Task Recommendations

Fast access to quick win tasks that can be completed in under 2 hours - perfect for building momentum, filling time slots, or when you want immediate productivity.

## Usage

```bash
/next-quick [query] [--format=output] [--limit=N] [--cache-only]
```

## Description

This is a shortcut command for `/dd:next --context=quick` optimized for rapid task selection and momentum building. Shows only tasks that can be completed quickly, helping you stay productive during short work sessions or when switching between larger projects.

## Parameters

- `query`: (Optional) Natural language query to refine quick tasks
  - **Examples**: `"documentation quick wins"`, `"what can I finish in 1 hour"`
  - **Smart filtering**: Combines quick task filter with your specific intent
- `--format=output`: Control detail level
  - `brief` - Concise task list (default for quick decisions)
  - `plan` - Implementation steps for immediate execution
  - `detailed` - Full analysis (rarely needed for quick tasks)
- `--limit=N`: Maximum tasks to show (default: 3 for quick selection)
- `--cache-only`: Ultra-fast mode from memory (perfect for rapid workflow)

## Quick Task Criteria

Shows tasks that are:
- ✅ **Estimated under 2 hours** - Can be completed in single session
- ✅ **No complex dependencies** - Ready to start immediately  
- ✅ **Clear scope** - Well-defined deliverables
- ✅ **High completion probability** - Low risk of scope creep

## Example Usage

```bash
# Find quick wins immediately  
/next-quick
# Shows 3 best quick tasks → ready for immediate selection

# Quick tasks with implementation plans
/next-quick --format=plan
# Quick tasks → with step-by-step execution → ready to start

# Ultra-fast for rapid workflow
/next-quick --cache-only
# Sub-100ms response → instant quick task suggestions

# Specific quick task hunting
/next-quick "documentation tasks I can finish quickly"
# Natural language → quick documentation wins

# Build momentum with options
/next-quick --limit=5
# More options → find perfect quick task for current mood
```

## Smart Quick Task Examples

**Documentation Quick Wins:**
```bash
/next-quick "docs"
# → T037: Clean up old project references (1h)
# → T008: Update CLAUDE.md integration (45min)
# → Quick README fixes (30min)
```

**Technical Quick Wins:**  
```bash
/next-quick "technical tasks"
# → Configuration cleanup (1h)
# → Code formatting improvements (45min)  
# → Dependency updates (1.5h)
```

**Momentum Building:**
```bash
/next-quick --format=plan --limit=1
# Single best quick task → with implementation plan → immediate start
```

## Common Scenarios

**Between Meetings:**
```bash
/next-quick --cache-only --limit=1
# Instant single recommendation → perfect for 1-hour slots
```

**Friday Afternoons:**
```bash
/next-quick "easy tasks to wrap up the week"
# Natural language → easy completion tasks → good week closure
```

**Productivity Kickstart:**
```bash
/next-quick --format=plan
# Quick wins with plans → build momentum → prepare for bigger tasks
```

**Context Switch Recovery:**
```bash
/next-quick "what can I complete while waiting for feedback?"
# Find parallel work → maintain productivity → avoid context switching costs
```

## Performance Benefits

| Command | Response Time | Use Case |
|---------|---------------|----------|
| `/next-quick` | 1-2 seconds | Normal quick task selection |
| `/next-quick --cache-only` | <100ms | Rapid workflow, frequent use |
| `/next-quick --format=plan` | 2-3 seconds | Ready-to-execute planning |

## Integration with Workflow

**Morning Momentum:**
```bash
# 1. Quick overview
/next-quick --cache-only

# 2. Pick one and get plan
/next-quick --format=plan --limit=1

# 3. Execute and build momentum for bigger tasks
```

**Time Slot Filling:**
```bash
# Got an unexpected hour free?
/next-quick --limit=2
# Pick perfect task for available time
```

**Epic Work Preparation:**
```bash
# Warm up before tackling big epic tasks
/next-quick --format=plan --limit=1
# Complete quick win → build confidence → tackle complex work
```

## Integration

This command is equivalent to:
```bash
/dd:next --context=quick [same-parameters]
```

But provides:
- **Faster access** to productivity-building tasks
- **Focused mindset** on quick completion
- **Shorter syntax** for frequent momentum building
- **Optimized defaults** for rapid task selection

Perfect for:
- Building momentum at start of work sessions
- Filling unexpected free time productively
- Maintaining productivity during complex project phases
- Learning task completion patterns through quick wins

## Success Criteria

- Shows only tasks completable in under 2 hours
- Provides immediate task selection for productivity
- Maintains smart memory and performance features
- Integrates seamlessly with broader DOH workflow
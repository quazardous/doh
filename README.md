# /doh - Project Management System

## What is /doh?

**Philosophy**: *"DOH !" - Context is obvious... once you have it.*

/doh gives context to both humans AND AI. No more developers scratching their heads wondering "why this code?" - and no more AI spinning in circles asking "what should I implement?"

Like Homer's "Doh!" - the answer was there all along, you just needed the right context to see it.

## Quick Install

```bash
/doh:init
```

> **Note**: `/doh:init` is separate from Claude Code's `/init` command. Claude Code's `/init` initializes general project structure, while `/doh:init` specifically sets up the DOH task management system.
>
> **Confirmation Required**: `/doh:init` will always prompt for confirmation before proceeding (unless `--no-confirm` is used). This prevents accidental initialization and gives you control over when DOH is set up in your projects.

## Quick Start

```bash
/doh:quick "fix login bug"     # Create task in Epic #0
/doh:epic 1                   # Brainstorm on epic
/doh:agent #123               # Autonomous implementation
```

## Key Features

- **Complete Traceability**: PRD → Epic → [Feature] → Task → Code
- **Git Worktree Support**: Parallel development on different features
- **Natural Language**: "create epic for user dashboard"
- **Autonomous Agents**: `/doh:agent #123` for hands-off development
- **Epic #0 System**: Quick tasks without bureaucracy

## Documentation Structure

### For Claude/AI Runtime Usage

- **[inclaude.md](inclaude.md)** - **RUNTIME REFERENCE** - Essential /doh usage guide for Claude
  - This is the primary document Claude uses during project work
  - Contains only what's needed for using /doh, not developing it
  - Optimized for fast loading and reference (2KB vs 15KB+)
  - **Referenced by `.claude/CLAUDE.md`** in projects using /doh
  - **Version**: Runtime 1.2.0 (Stable)

### For /doh System Development

- **[VERSION.md](VERSION.md)** - **Version management and release tracking**
- **[CHANGELOG.md](CHANGELOG.md)** - **Complete history of features and releases**
- **[TODO.md](../../TODO.md)** - **Development roadmap and progress tracking** (Dev 1.3.0) - *Now in project root*
- **[Architecture](docs/architecture.md)** - Structure, IDs, and file organization
- **[Commands](docs/commands.md)** - All commands and natural language usage
- **[Worktree Strategy](docs/worktree-strategy.md)** - Parallel development setup
- **[Memory System](docs/memory-system.md)** - Persistent context and learning
- **[Agent Context Protocol](docs/agent-context-protocol.md)** - How autonomous agents receive and use context
- **[AI Context Rules](docs/ai-context-rules.md)** - Guidelines for AI development

## Credits

Philosophy inspired by Homer Simpson's "Doh!" - the answer was there all along, you just needed the right context to see it.

Built for developers who believe context beats magic, and AI that needs good specifications to produce good code.

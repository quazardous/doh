# /doh - Project Management System

## What is /doh?

**Philosophy**: _"DOH !" - Context is obvious... once you have it._

/doh gives context to both humans AND AI. No more developers scratching their heads wondering "why this code?" - and no
more AI spinning in circles asking "what should I implement?"

Like Homer's "Doh!" - the answer was there all along, you just needed the right context to see it.

## Quick Install

```bash
/doh:init
```

> **Note**: `/doh:init` is separate from Claude Code's `/init` command. Claude Code's `/init` initializes general
> project structure, while `/doh:init` specifically sets up the DOH task management system.
>
> **Confirmation Required**: `/doh:init` will always prompt for confirmation before proceeding (unless `--no-confirm` is
> used). This prevents accidental initialization and gives you control over when DOH is set up in your projects.

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

## Documentation Map

**📖 New to DOH?** Start here: [WORKFLOW.md](WORKFLOW.md) → [Commands](docs/commands.md) → Practice with `/doh:quick`

### 🎯 For Users (Get Started)

- **[WORKFLOW.md](WORKFLOW.md)** - **Start here!** Simple workflow example (5 min read)
- **[docs/commands.md](docs/commands.md)** - **Essential reference** All commands and natural language usage
- **[docs/workflow-patterns.md](docs/workflow-patterns.md)** - Advanced patterns and decision guides
- **[docs/workflow-examples.md](docs/workflow-examples.md)** - Real-world examples for different project types

### 🤖 For Claude/AI Runtime

- **[.claude/doh/inclaude.md](.claude/doh/inclaude.md)** - **RUNTIME REFERENCE** Essential /doh guide for Claude
    - Primary document Claude uses during project work
    - Optimized for fast loading and reference (2KB vs 15KB+)
    - Referenced by `.claude/CLAUDE.md` in projects using /doh

### 👩‍💻 For Contributors (Development)

- **[CONTRIBUTING.md](CONTRIBUTING.md)** - **Development setup** Get started contributing in 5 minutes
- **[DEVELOPMENT.md](DEVELOPMENT.md)** - **Internal patterns** Development guidelines and architecture
- **[TODO.md](TODO.md)** - **Current roadmap** Active development tasks and progress
- **[CHANGELOG.md](CHANGELOG.md)** - **Release history** Complete feature and release tracking
- **[VERSION.md](VERSION.md)** - **Version management** Release tracking and version strategy

### 🏗️ Architecture & Advanced Topics

- **[docs/architecture.md](docs/architecture.md)** - **System structure** File organization, IDs, and data flow
- **[docs/memory-system.md](docs/memory-system.md)** - **Persistent context** How DOH learns and remembers
- **[docs/agent-context-protocol.md](docs/agent-context-protocol.md)** - **Autonomous agents** Context and integration
- **[docs/worktree-strategy.md](docs/worktree-strategy.md)** - **Parallel development** Multiple feature strategy
- **[docs/ai-context-rules.md](docs/ai-context-rules.md)** - **AI guidelines** Development with AI assistance

### 📋 Quick Reference

| I want to... | Go to... | Time needed |
|--------------|----------|-------------|
| **Learn DOH basics** | [WORKFLOW.md](WORKFLOW.md) | 5 min |
| **Start using DOH** | `/doh:quick "my first task"` | 1 min |
| **See all commands** | [docs/commands.md](docs/commands.md) | 10 min |
| **Contribute code** | [CONTRIBUTING.md](CONTRIBUTING.md) | 5 min setup |
| **Understand architecture** | [docs/architecture.md](docs/architecture.md) | 15 min |
| **See what's planned** | [TODO.md](TODO.md) | Browse |

## Credits

Philosophy inspired by Homer Simpson's "Doh!" - the answer was there all along, you just needed the right context to see
it.

Built for developers who believe context beats magic, and AI that needs good specifications to produce good code.

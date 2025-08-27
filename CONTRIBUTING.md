# Contributing to DOH System

Welcome to DOH (DevOps Helper) development! This guide will help you set up your development environment and contribute
to the project.

## Quick Start

### One-Command Setup

```bash
# Clone the repository
git clone https://github.com/user/doh
cd doh

# Set up development environment
make dev-setup
```

That's it! The `make dev-setup` command will:

- Install system dependencies (Node.js, jq, shellcheck)
- Install npm dev dependencies (markdownlint-cli)
- Set up git hooks for automatic code quality checks

### Manual Setup Steps

If you prefer to understand what's happening:

```bash
# 1. Install system dependencies
make deps-install

# 2. Install Node.js dependencies
npm install

# 3. Install git hooks (optional but recommended)
make hooks-install

# 4. Verify everything works
make deps-check
```

## Development Environment

### System Requirements

- **Bash** (4.0+) - Core runtime requirement
- **jq** - JSON processing
- **Node.js** (14+) - Development tooling only
- **Git** - Version control

### Platform Support

The development environment supports:

- **Linux** (Ubuntu, Fedora, Arch, etc.)
- **macOS** (via Homebrew)
- **Windows** (via WSL)

Package managers automatically detected:

- Homebrew (macOS)
- apt (Ubuntu/Debian)
- yum/dnf (RHEL/CentOS/Fedora)
- pacman (Arch Linux)

## Available Commands

```bash
make                # Show all available commands
make dev-setup      # One-command development environment setup
```

For all other commands, just type `make` to see the full list.

## Project Structure

```text
doh/
├── dev-tools/              # Development toolchain
│   ├── linters/            # Linter configurations
│   │   └── .markdownlint.json
│   ├── hooks/              # Git hooks
│   │   ├── pre-commit
│   │   └── install-hooks.sh
│   └── scripts/            # Development scripts
│       └── setup-dev-env.sh
├── docs/                   # Documentation
├── analysis/               # Development analysis
├── skel/                   # Project skeleton templates
├── tests/                  # Test files
├── .claude/doh/            # Runtime scripts only
│   └── scripts/
├── Makefile                # Build automation
├── package.json            # Dev dependencies
└── TODO.md                 # Development roadmap
```

## Code Quality Standards

### Pre-commit Hooks

When installed (`make hooks-install`), the pre-commit hook will:

- **Markdown linting** - Check documentation quality
- **Shell script linting** - Validate bash scripts with shellcheck
- **Basic checks** - Trailing whitespace, file size limits

To bypass hooks temporarily:

```bash
git commit --no-verify
```

### Manual Quality Checks

```bash
# Check everything
make check

# Individual linters
make lint           # All linters
npm run lint:md     # Markdown only
shellcheck *.sh     # Shell scripts only
```

## DOH Development Philosophy

### Dependencies

- **DOH System Development**: Can use any tools/dependencies (Node.js, Python, etc.)
- **DOH Runtime Distribution**: MUST be 100% bash + jq + awk only

### Language

- **Project Language**: Full English for all code, docs, comments, files
- **Universal compatibility** for distribution

## Workflow

### 1. Development Setup

```bash
make dev-setup
```

### 2. Make Changes

- Edit code, documentation, or configuration
- Follow existing patterns and conventions
- Write tests when adding new features

### 3. Quality Check

```bash
make check
```

### 4. Commit Changes

```bash
git add .
git commit -m "Description of changes"
# Pre-commit hooks run automatically
```

### 5. Submit Contribution

- Push to your fork
- Open a pull request
- Ensure CI checks pass

## Task Management

DOH uses a mature TODO.md system for development task tracking:

- **TODO.md** - Development roadmap and task tracking
- **CHANGELOG.md** - Completed features and releases
- **VERSION.md** - Version management

### Contributing to Complex Tasks

For complex tasks (restructuring, new features):

1. Check if a mature TODO exists in TODO.md
2. If not, propose adding a TODO for proper planning
3. Only work on well-documented, planned tasks

## IDE Setup

### VS Code (Recommended)

Install these extensions:

- **ShellCheck** - Shell script linting
- **markdownlint** - Markdown linting
- **GitLens** - Git integration

### Configuration

The project includes:

- `.markdownlint.json` - Markdown linting rules
- Pre-configured Makefile targets
- Git hooks for automatic quality checks

## Testing

### Current Status

- Testing framework (T024) is in development
- Basic linting and validation available now
- Integration tests coming soon

### Running Tests

```bash
make test     # Will run comprehensive tests when T024 is complete
make check    # Current quality checks (linting)
```

## Getting Help

### Documentation

- **CLAUDE.md** - Project overview and development guidelines
- **TODO.md** - Development roadmap and active tasks
- **docs/** - Detailed documentation

### Community

- Open issues for bugs or feature requests
- Check existing TODOs before proposing new features
- Follow the established development patterns

## Common Issues

### Dependencies Not Found

```bash
# Check what's missing
make deps-check

# Install dependencies
make deps-install
```

### Git Hooks Not Working

```bash
# Reinstall hooks
make hooks-remove
make hooks-install
```

### Permission Issues

```bash
# Fix script permissions
chmod +x dev-tools/hooks/*
chmod +x dev-tools/scripts/*
```

## Release Process

(For maintainers)

1. Complete TODO items
2. Update CHANGELOG.md
3. Update VERSION.md
4. Test on multiple platforms
5. Create release

---

**Thank you for contributing to DOH!** 🚀

Your contributions help make project management better for Claude.ai users everywhere.

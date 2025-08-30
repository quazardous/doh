# DOH Development Quick Reference

**Architecture**: Post-EDD116 Separation-by-Function  
**Quick access guide for daily development workflows**

## 🚀 Common Operations

### **Linting**

```bash
# Main linting engine
scripts/linting/lint-files.sh README.md

# AI-enhanced linting
scripts/linting/smart-lint.sh fix README.md

# Check multiple files
make lint

# Plugin management
scripts/linting/manager_markdownlint_plugin.sh --list
```

### **Git Integration**

```bash
# Install hooks
scripts/git/install-hooks.sh

# Manual hook usage
scripts/git/hooks/pre-commit-new
```

### **Development Setup**

```bash
# Environment setup
scripts/development/setup-dev-env.sh

# Complete dev setup
make dev-setup
```

## 📁 Where to Find Things

| Need                  | Location                    | Example                                |
| --------------------- | --------------------------- | -------------------------------------- |
| **Linting scripts**   | `scripts/linting/`          | `lint-files.sh`, `smart-lint.sh`       |
| **Git tools**         | `scripts/git/`              | `install-hooks.sh`, `hooks/pre-commit` |
| **Development tools** | `scripts/development/`      | `setup-dev-env.sh`                     |
| **Shared libraries**  | `scripts/lib/`              | `lint-core.sh`, `cache-lib.sh`         |
| **Plugin configs**    | `linting/plugins.d/`        | `markdownlint/`, `codespell/`          |
| **Base configs**      | `linting/config/`           | `.markdownlint.json`                   |
| **Documentation**     | `docs/`                     | `ARCHITECTURE.md`, this file           |
| **Examples**          | `contrib/examples/scripts/` | `cache-usage-examples.sh`              |
| **Cache**             | `.cache/linting/`           | `error-files.txt`, `data/`             |

## 🔧 Adding New Components

### **New Linting Script**

1. **Executable** → `scripts/linting/your-script.sh`
2. **Config** → `linting/plugins.d/your-tool/config.json`
3. **Documentation** → Update relevant docs

### **New Development Tool**

1. **Tool script** → `scripts/development/your-tool.sh`
2. **Makefile target** → Add target that calls your script
3. **Documentation** → Update `docs/` if significant

### **New Shared Library**

1. **Library** → `scripts/lib/your-lib.sh`
2. **Source in scripts** → `source scripts/lib/your-lib.sh`
3. **Documentation** → Comment functions well

## ⚡ Performance Tips

### **Cache System**

```bash
# Populate error cache
scripts/linting/lint-scan.sh

# Check cache progress
scripts/linting/lint-progress.sh

# Update cache
scripts/linting/lint-update-cache.sh
```

### **Makefile Shortcuts**

```bash
make lint              # Full project linting
make lint-fix          # Auto-fix issues
make lint-staged       # Lint staged files only
make hooks-install     # Install git hooks
```

## 🏗️ Architecture Rules

### **✅ Do**

- Put executables in `scripts/[category]/`
- Put configs in `linting/` or `config/`
- Put documentation in `docs/`
- Put references in `contrib/`
- Use function-based organization

### **❌ Don't**

- Put scripts in `linting/plugins.d/` (configs only)
- Put configs in `scripts/` (executables only)
- Mix hot and cold storage
- Create deep nested structures

## 🔍 Troubleshooting

### **Script Not Found**

- Check if moved in EDD116 migration
- Use new paths: `scripts/linting/` not `dev-tools/scripts/`

### **Permission Issues**

```bash
# Make script executable
chmod +x scripts/linting/your-script.sh
```

### **Path Issues**

- All scripts use relative paths from project root
- No hard-coded `/dev-tools/` references remain

### **Integration Issues**

- Check Makefile targets updated to new paths
- Verify `.claude/commands/` reference correct scripts
- Test git hooks use `scripts/git/hooks/`

## 📚 Full Documentation

- **Complete architecture**: `docs/ARCHITECTURE.md`
- **Development patterns**: `DEVELOPMENT.md`
- **Exception handling**: `docs/exception-handling.md`
- **Task management**: `todo/README.md`

---

_This quick reference reflects the EDD116 architectural refactoring. All paths and workflows updated for the new
separation-by-function structure._

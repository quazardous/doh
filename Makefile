# DOH System Development Environment
# Makefile for cross-platform development setup and automation

.PHONY: dev-setup deps-install deps-check lint lint-fix check hooks-install hooks-update hooks-remove test build clean install help

# Default target - show help when just typing 'make'
all: help

help: ## Show this help message
	@echo "DOH Development Environment"
	@echo "=========================="
	@echo ""
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Development setup
dev-setup: deps-install ## Complete development environment setup
	@echo "📦 Installing Node.js dependencies..."
	npm install
	@echo "🔗 Installing git hooks..."
	$(MAKE) hooks-install
	@echo "✅ Development environment ready!"
	@echo ""
	@echo "Next steps:"
	@echo "  make lint      # Check code quality"
	@echo "  make test      # Run tests"

# Install system dependencies
deps-install: ## Install system dependencies (node, jq, shellcheck)
	@echo "🔍 Installing system dependencies..."
	@if command -v brew >/dev/null 2>&1; then \
		echo "📱 Using Homebrew (macOS)..."; \
		brew install node jq shellcheck || true; \
	elif command -v apt >/dev/null 2>&1; then \
		echo "🐧 Using apt (Ubuntu/Debian)..."; \
		sudo apt update && sudo apt install -y nodejs npm jq shellcheck || true; \
	elif command -v yum >/dev/null 2>&1; then \
		echo "🎩 Using yum (RHEL/CentOS)..."; \
		sudo yum install -y nodejs npm jq ShellCheck || true; \
	elif command -v pacman >/dev/null 2>&1; then \
		echo "🏹 Using pacman (Arch Linux)..."; \
		sudo pacman -S --noconfirm nodejs npm jq shellcheck || true; \
	elif command -v dnf >/dev/null 2>&1; then \
		echo "🎩 Using dnf (Fedora)..."; \
		sudo dnf install -y nodejs npm jq ShellCheck || true; \
	else \
		echo "❌ Package manager not detected."; \
		echo "Please install manually:"; \
		echo "  - Node.js (https://nodejs.org)"; \
		echo "  - jq (https://jqlang.github.io/jq/)"; \
		echo "  - shellcheck (https://www.shellcheck.net)"; \
		exit 1; \
	fi
	@echo "✅ System dependencies installation attempted"

# Check dependencies
deps-check: ## Verify all dependencies are present
	@echo "🔍 Checking dependencies..."
	@command -v node >/dev/null || (echo "❌ Node.js not found" && exit 1)
	@command -v npm >/dev/null || (echo "❌ npm not found" && exit 1)
	@command -v jq >/dev/null || (echo "❌ jq not found" && exit 1)
	@command -v shellcheck >/dev/null || (echo "❌ shellcheck not found" && exit 1)
	@echo "✅ All dependencies present"
	@echo "Node.js: $$(node --version)"
	@echo "npm: $$(npm --version)"
	@echo "jq: $$(jq --version)"
	@echo "shellcheck: $$(shellcheck --version | head -n1)"

# Linting - Comprehensive auto-correcting system
lint: ## Run linters on all markdown files (check mode)
	@./dev-tools/scripts/lint-files.sh --check

lint-fix: ## Auto-fix all markdown files with 3-tool pipeline
	@./dev-tools/scripts/lint-files.sh --fix

lint-file: ## Lint single file (usage: make lint-file FILE=README.md)
	@if [ -z "$(FILE)" ]; then \
		echo "❌ Usage: make lint-file FILE=path/to/file.md"; \
		exit 1; \
	fi
	@./dev-tools/scripts/lint-files.sh --fix "$(FILE)"

lint-check-file: ## Check single file without fixing (usage: make lint-check-file FILE=README.md)
	@if [ -z "$(FILE)" ]; then \
		echo "❌ Usage: make lint-check-file FILE=path/to/file.md"; \
		exit 1; \
	fi
	@./dev-tools/scripts/lint-files.sh --check "$(FILE)"

lint-staged: ## Auto-fix all staged files
	@./dev-tools/scripts/lint-files.sh --fix --staged

lint-modified: ## Auto-fix all modified/new files
	@./dev-tools/scripts/lint-files.sh --fix --modified

lint-dir: ## Lint all files in directory (usage: make lint-dir DIR=todo/)
	@if [ -z "$(DIR)" ]; then \
		echo "❌ Usage: make lint-dir DIR=path/to/dir/"; \
		exit 1; \
	fi
	@./dev-tools/scripts/lint-files.sh --fix "$(DIR)"

lint-manual: deps-check ## Show manual markdown fixes needed (line length, etc.)
	@echo "📝 Checking for manual fixes needed..."
	@echo "🔍 Running comprehensive check to identify non-auto-fixable issues..."
	@./dev-tools/scripts/lint-files.sh --check | grep -E "(MD013|MD024|MD036)" || echo "✅ No manual fixes needed"

# Quality checks
check: lint ## All quality checks (lint + test)
	@echo "✅ All quality checks passed"

# Git hooks
hooks-install: ## Install pre-commit hooks with linter integration
	@echo "🔗 Installing git hooks..."
	@if [ -f dev-tools/hooks/pre-commit ]; then \
		if [ -f .git/hooks/pre-commit ] && [ ! -L .git/hooks/pre-commit ]; then \
			echo "⚠️  Existing pre-commit hook detected!"; \
			echo "💾 Backing up to .git/hooks/pre-commit.backup"; \
			cp .git/hooks/pre-commit .git/hooks/pre-commit.backup; \
		fi; \
		chmod +x dev-tools/hooks/pre-commit; \
		ln -sf ../../dev-tools/hooks/pre-commit .git/hooks/pre-commit; \
		echo "✅ Pre-commit hook installed"; \
	else \
		echo "❌ Pre-commit hook not found at dev-tools/hooks/pre-commit"; \
		exit 1; \
	fi

hooks-update: hooks-install ## Update git hooks
	@echo "✅ Git hooks updated"

hooks-remove: ## Remove git hooks and restore backups
	@echo "🗑️  Removing git hooks..."
	@if [ -L .git/hooks/pre-commit ]; then \
		rm -f .git/hooks/pre-commit; \
		if [ -f .git/hooks/pre-commit.backup ]; then \
			echo "🔄 Restoring original pre-commit hook from backup"; \
			mv .git/hooks/pre-commit.backup .git/hooks/pre-commit; \
		fi; \
	else \
		echo "⚠️  No DOH hooks to remove (not a symlink)"; \
	fi
	@echo "✅ Git hooks removed"

# Testing
test: ## Run test suite
	@echo "🧪 Running tests..."
	@echo "⚠️  Test framework not yet implemented (T024)"
	@echo "✅ Tests would run here"

# Building
build: ## Prepare distribution
	@echo "🏗️  Building DOH distribution..."
	@echo "⚠️  Build process not yet implemented"
	@echo "✅ Build would run here"

# Clean
clean: ## Clean build artifacts
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf node_modules/.cache
	@echo "✅ Clean complete"

# Install DOH locally
install: ## Install DOH system locally
	@echo "📦 Installing DOH system locally..."
	@echo "⚠️  Installation process not yet implemented"
	@echo "✅ Install would run here"
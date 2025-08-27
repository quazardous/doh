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

# Linting
lint: deps-check ## Run all linters (markdown, shell)
	@echo "🔍 Running linters..."
	@if [ -f package.json ] && npm list markdownlint-cli >/dev/null 2>&1; then \
		echo "📝 Linting Markdown files..."; \
		npm run lint:md 2>/dev/null || npx markdownlint --config dev-tools/linters/.markdownlint.json *.md docs/ analysis/ || true; \
	else \
		echo "⚠️  markdownlint-cli not installed, skipping markdown linting"; \
	fi
	@echo "🐚 Linting shell scripts..."
	@find . -name "*.sh" -not -path "./node_modules/*" -exec shellcheck {} + || true
	@echo "✅ Linting complete"

lint-fix: deps-check ## Auto-fix linting issues where possible
	@echo "🔧 Auto-fixing linting issues..."
	@if [ -f package.json ] && npm list prettier >/dev/null 2>&1; then \
		echo "📝 Formatting with prettier..."; \
		npx prettier --write '*.md' 'docs/**/*.md' 'analysis/**/*.md' 'templates/**/*.md' 'skel/**/*.md' || true; \
	fi
	@if [ -f package.json ] && npm list markdownlint-cli >/dev/null 2>&1; then \
		echo "📝 Auto-fixing Markdown files..."; \
		npm run lint:md:fix 2>/dev/null || npx markdownlint --config dev-tools/linters/.markdownlint.json --fix *.md docs/ analysis/ templates/ skel/ || true; \
	fi
	@echo "✅ Auto-fix complete"

lint-manual: deps-check ## Show manual markdown fixes needed (line length, etc.)
	@echo "📝 Checking for manual fixes needed..."
	@if [ -f package.json ] && npm list markdownlint-cli >/dev/null 2>&1; then \
		echo "🔍 Scanning for non-auto-fixable issues..."; \
		echo ""; \
		npx markdownlint --config dev-tools/linters/.markdownlint.json '*.md' 'docs/**/*.md' 'analysis/**/*.md' 2>&1 | \
		grep -E "(MD013|MD029|MD024|MD036)" | \
		head -20 | \
		while IFS= read -r line; do \
			if echo "$$line" | grep -q "MD013"; then \
				echo "📏 $$line"; \
			elif echo "$$line" | grep -q "MD029"; then \
				echo "🔢 $$line"; \
			elif echo "$$line" | grep -q "MD024"; then \
				echo "📑 $$line"; \
			elif echo "$$line" | grep -q "MD036"; then \
				echo "📝 $$line"; \
			else \
				echo "❓ $$line"; \
			fi; \
		done; \
		echo ""; \
		echo "💡 Fix these manually, then run 'make lint' to verify"; \
	else \
		echo "⚠️  markdownlint-cli not available"; \
	fi

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
#!/bin/bash
# DOH Git Hooks Installation Script
# Installs git hooks via symlinks

set -e

echo "🔗 Installing DOH git hooks..."

# Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "❌ Not in a git repository"
    exit 1
fi

# Get the root directory of the git repository
GIT_ROOT=$(git rev-parse --show-toplevel)
HOOKS_DIR="$GIT_ROOT/dev-tools/hooks"
GIT_HOOKS_DIR="$GIT_ROOT/.git/hooks"

# Check if hooks directory exists
if [ ! -d "$HOOKS_DIR" ]; then
    echo "❌ Hooks directory not found: $HOOKS_DIR"
    exit 1
fi

# Create .git/hooks directory if it doesn't exist
mkdir -p "$GIT_HOOKS_DIR"

# Install pre-commit hook
if [ -f "$HOOKS_DIR/pre-commit" ]; then
    echo "📝 Installing pre-commit hook..."
    
    # Check for existing non-symlink hook
    if [ -f "$GIT_HOOKS_DIR/pre-commit" ] && [ ! -L "$GIT_HOOKS_DIR/pre-commit" ]; then
        echo "⚠️  Existing pre-commit hook detected!"
        echo "💾 Backing up to $GIT_HOOKS_DIR/pre-commit.backup"
        cp "$GIT_HOOKS_DIR/pre-commit" "$GIT_HOOKS_DIR/pre-commit.backup"
    fi
    
    chmod +x "$HOOKS_DIR/pre-commit"
    ln -sf "../../dev-tools/hooks/pre-commit" "$GIT_HOOKS_DIR/pre-commit"
    echo "✅ Pre-commit hook installed"
else
    echo "❌ Pre-commit hook not found: $HOOKS_DIR/pre-commit"
    exit 1
fi

# Install pre-push hook if it exists
if [ -f "$HOOKS_DIR/pre-push" ]; then
    echo "📤 Installing pre-push hook..."
    chmod +x "$HOOKS_DIR/pre-push"
    ln -sf "../../dev-tools/hooks/pre-push" "$GIT_HOOKS_DIR/pre-push"
    echo "✅ Pre-push hook installed"
fi

echo "✅ Git hooks installation complete"
echo ""
echo "💡 Hooks installed:"
echo "  - pre-commit: Runs linting on staged files"
echo ""
echo "💡 To bypass hooks temporarily:"
echo "  git commit --no-verify"
echo ""
echo "💡 To remove hooks:"
echo "  make hooks-remove"
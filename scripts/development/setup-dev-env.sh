#!/bin/bash
# DOH Development Environment Setup Script
# One-command setup for contributors

set -e

echo "🚀 DOH Development Environment Setup"
echo "===================================="
echo ""

# Check if we're in the DOH project directory
if [ ! -f "Makefile" ] || [ ! -d "dev-tools" ]; then
    echo "❌ This doesn't appear to be the DOH project directory"
    echo "Please run this script from the DOH project root"
    exit 1
fi

# Run make dev-setup
echo "🏗️  Running make dev-setup..."
make dev-setup

echo ""
echo "🎉 DOH development environment setup complete!"
echo ""
echo "💡 Available commands:"
echo "  make help          Show all available commands"
echo "  make lint          Run all linters"
echo "  make test          Run tests"
echo "  make hooks-install Install git hooks"
echo ""
echo "💡 VS Code users: Install these extensions:"
echo "  - shellcheck"
echo "  - markdownlint"
echo ""
echo "🚀 You're ready to contribute to DOH!"
#!/bin/bash
# linux_cleanup.sh - Cleanup script for Linux Setup
# Usage: ./linux_cleanup.sh

set -e

echo "---------------------------------------------------"
echo "🧹 Starting Linux Cleanup..."
echo "---------------------------------------------------"

# 1. Homebrew Cleanup
echo "🍺 Cleaning up Homebrew..."
brew cleanup -s

# 2. System (Apt) Cleanup
echo "📦 Cleaning up Apt packages..."
sudo apt autoremove -y && sudo apt clean

# 3. Node.js (NPM) Cleanup
echo "🌐 Cleaning up NPM cache..."
if command -v npm &> /dev/null; then
    npm cache clean --force
fi

# 4. Java (SDKMAN) Cleanup
echo "☕ Cleaning up SDKMAN..."
if [ -d "$HOME/.sdkman" ]; then
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    sdk flush temp
    sdk flush archives
fi

# 5. Python (Pip) Cleanup
echo "🐍 Purging Pip cache..."
if command -v pip3 &> /dev/null; then pip3 cache purge; elif command -v pip &> /dev/null; then pip cache purge; fi

# 6. Go Cleanup
echo "🐹 Cleaning up Go cache..."
if command -v go &> /dev/null; then
    go clean -cache -testcache -modcache
fi

# 7. Podman Cleanup
echo "🐳 Cleaning up unused Podman data..."
if command -v podman &> /dev/null; then
    podman system prune -f || echo "Podman prune skipped."
fi

echo "---------------------------------------------------"
echo "✅ Cleanup Complete!"
echo "---------------------------------------------------"

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
# Remove unused dependencies installed by Homebrew
if command -v brew &> /dev/null; then
    brew autoremove || true
fi

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
# Prefer using an available `sdk` command to avoid sourcing the init script
# which can fail under older /bin/bash.
if [ -d "$HOME/.sdkman" ]; then
    if command -v sdk &> /dev/null; then
        sdk flush temp && sdk flush archives || echo "⚠️ sdk flush failed."
    else
        echo "⚠️ 'sdk' not found in PATH; skipping SDKMAN flush to avoid shell incompatibility."
    fi
fi

# 5. Python (Pip) Cleanup
echo "🐍 Purging Pip cache..."
if command -v python3 &> /dev/null; then
    PY=python3
elif command -v python &> /dev/null; then
    PY=python
else
    PY=""
fi

if [ -n "$PY" ]; then
    "$PY" -m pip cache purge || echo "⚠️ pip cache purge failed or pip not available for $PY"
    PIP_CACHE_DIR="$HOME/.cache/pip"
    if [ -d "$PIP_CACHE_DIR/wheels" ]; then
        rm -rf "$PIP_CACHE_DIR/wheels" || true
    fi
fi

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

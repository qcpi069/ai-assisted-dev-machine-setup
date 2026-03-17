#!/bin/bash
# macos_cleanup.sh
set -e
echo "🧹 Cleaning up macOS caches..."

# 1. Homebrew
echo "🍺 Cleaning up Homebrew..."
brew cleanup -s
# Remove unused dependencies installed by Homebrew
if command -v brew &> /dev/null; then
    brew autoremove || true
fi

# 2. Node.js (NPM)
echo "🌐 Cleaning up NPM cache..."
[ -d "$HOME/.nvm" ] && npm cache clean --force

# 3. Java (SDKMAN)
echo "☕ Cleaning up SDKMAN..."
# Prefer using an available `sdk` command to avoid sourcing the init script
# which can fail under older /bin/bash on macOS.
if [ -d "$HOME/.sdkman" ]; then
    if command -v sdk &> /dev/null; then
        sdk flush temp && sdk flush archives || echo "⚠️ sdk flush failed."
    else
        echo "⚠️ 'sdk' not found in PATH; skipping SDKMAN flush to avoid shell incompatibility."
    fi
fi

# 4. Python (Pip)
echo "🐍 Purging Pip cache..."
# Use the same python selection strategy as the updater to ensure the correct pip is targeted.
if command -v python3 &> /dev/null; then
    PY=python3
elif command -v python &> /dev/null; then
    PY=python
else
    PY=""
fi

if [ -n "$PY" ]; then
    # Use pip's cache purge command if available
    "$PY" -m pip cache purge || echo "⚠️ pip cache purge failed or pip not available for $PY"

    # Also remove wheel caches that sometimes remain
    PIP_CACHE_DIR="$HOME/.cache/pip"
    if [ -d "$PIP_CACHE_DIR/wheels" ]; then
        rm -rf "$PIP_CACHE_DIR/wheels" || true
    fi
fi

# 5. Go
echo "🐹 Cleaning up Go cache..."
if command -v go &> /dev/null; then
    go clean -cache -testcache -modcache
fi

# 6. Podman
echo "🐳 Cleaning up unused Podman data..."
if command -v podman &> /dev/null; then
    podman system prune -f || echo "Podman prune skipped."
fi

echo "✅ macOS Cleanup Complete!"

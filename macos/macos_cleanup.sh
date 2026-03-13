#!/bin/bash
# macos_cleanup.sh
set -e
echo "🧹 Cleaning up macOS caches..."

# 1. Homebrew
echo "🍺 Cleaning up Homebrew..."
brew cleanup -s

# 2. Node.js (NPM)
echo "🌐 Cleaning up NPM cache..."
[ -d "$HOME/.nvm" ] && npm cache clean --force

# 3. Java (SDKMAN)
echo "☕ Cleaning up SDKMAN..."
[ -d "$HOME/.sdkman" ] && (source "$HOME/.sdkman/bin/sdkman-init.sh" && sdk flush temp && sdk flush archives)

# 4. Python (Pip)
echo "🐍 Purging Pip cache..."
if command -v pip3 &> /dev/null; then pip3 cache purge; elif command -v pip &> /dev/null; then pip cache purge; fi

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

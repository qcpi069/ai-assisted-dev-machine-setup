#!/bin/bash
# linux_cleanup.sh - Cleanup script for Linux Setup
# Usage: ./linux_cleanup.sh

set -e

DRY_RUN=false
SDKMAN_INIT="$HOME/.sdkman/bin/sdkman-init.sh"

run_sdkman() {
    if command -v sdk &> /dev/null; then
        sdk "$@"
        return $?
    fi

    if [ -s "$SDKMAN_INIT" ]; then
        if [ "${BASH_VERSINFO[0]}" -lt 4 ] && command -v zsh &> /dev/null; then
            "$(command -v zsh)" -lc '
                unset BASH_VERSION
                export SDKMAN_DIR="$HOME/.sdkman"
                source "$SDKMAN_DIR/bin/sdkman-init.sh"
                sdk "$@"
            ' zsh "$@"
            return $?
        fi

        bash -lc '
            export SDKMAN_DIR="$HOME/.sdkman"
            source "$SDKMAN_DIR/bin/sdkman-init.sh"
            sdk "$@"
        ' bash "$@"
        return $?
    fi

    return 127
}

# Parse arguments
for arg in "$@"; do
    case $arg in
        -d|--dry-run)
            DRY_RUN=true
            ;;
    esac
done

if [ "$DRY_RUN" = true ]; then
    echo "🔍 DRY-RUN MODE: No changes will be made."
    echo ""
else
    echo "⚠️  WARNING: This script is intended for FRESH INSTALLATIONS."
    echo "⚠️  It follows an opinionated setup and may conflict with existing packages"
    echo "⚠️  or environments managed by other tools or manual installations."
    echo ""

    read -p "Continue? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

echo "---------------------------------------------------"
echo "🧹 Starting Linux Cleanup..."
echo "---------------------------------------------------"

# 1. Homebrew Cleanup
echo "🍺 Cleaning up Homebrew..."
if [ "$DRY_RUN" = true ]; then
    echo "[DRY-RUN] Would run: brew cleanup -s && brew autoremove"
else
    brew cleanup -s
    # Remove unused dependencies installed by Homebrew
    if command -v brew &> /dev/null; then
        brew autoremove || true
    fi
fi

# 2. System (Apt) Cleanup
echo "📦 Cleaning up Apt packages..."
if [ "$DRY_RUN" = true ]; then
    echo "[DRY-RUN] Would run: sudo apt autoremove -y && sudo apt clean"
else
    sudo apt autoremove -y && sudo apt clean
fi

# 3. Node.js (NPM) Cleanup
echo "🌐 Cleaning up NPM cache..."
if command -v npm &> /dev/null; then
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY-RUN] Would run: npm cache clean --force"
    else
        npm cache clean --force
    fi
fi

# 4. Java (SDKMAN) Cleanup
echo "☕ Cleaning up SDKMAN..."
# Prefer the existing `sdk` command when present, otherwise use a bash subshell
# so non-interactive shells still work without mutating the current shell.
if [ -d "$HOME/.sdkman" ]; then
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY-RUN] Would run: sdk flush temp && sdk flush archives"
    elif command -v sdk &> /dev/null || [ -s "$SDKMAN_INIT" ]; then
        run_sdkman flush temp && run_sdkman flush archives || echo "⚠️ sdk flush failed."
    else
        echo "⚠️ SDKMAN init script not found; skipping SDKMAN flush."
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
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY-RUN] Would run: $PY -m pip cache purge"
    else
        "$PY" -m pip cache purge || echo "⚠️ pip cache purge failed or pip not available for $PY"
        PIP_CACHE_DIR="$HOME/.cache/pip"
        if [ -d "$PIP_CACHE_DIR/wheels" ]; then
            rm -rf "$PIP_CACHE_DIR/wheels" || true
        fi
    fi
fi

# 6. Go Cleanup
echo "🐹 Cleaning up Go cache..."
if command -v go &> /dev/null; then
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY-RUN] Would run: go clean -cache -testcache -modcache"
    else
        go clean -cache -testcache -modcache
    fi
fi

# 7. Podman Cleanup
echo "🐳 Cleaning up unused Podman data..."
if command -v podman &> /dev/null; then
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY-RUN] Would run: podman system prune -f"
    else
        podman system prune -f || echo "Podman prune skipped."
    fi
fi

echo "---------------------------------------------------"
if [ "$DRY_RUN" = true ]; then
    echo "✅ Cleanup Dry-Run Complete!"
else
    echo "✅ Cleanup Complete!"
fi
echo "---------------------------------------------------"

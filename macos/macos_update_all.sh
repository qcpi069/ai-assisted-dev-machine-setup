#!/bin/bash
# macos_update_all.sh
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

echo "🚀 Updating macOS environment..."

# 1. Homebrew
echo "🍺 Updating Homebrew..."
if [ "$DRY_RUN" = true ]; then
    echo "[DRY-RUN] Would run: brew update && brew upgrade"
else
    brew update && brew upgrade
fi

# 2. Oh My Zsh
echo "🐚 Updating Oh My Zsh..."
if [ -d "$HOME/.oh-my-zsh" ]; then
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY-RUN] Would run Oh My Zsh upgrade"
    else
        ZSH=$HOME/.oh-my-zsh /bin/sh $HOME/.oh-my-zsh/tools/upgrade.sh --non-interactive
    fi
fi

# 3. Node.js (Global npm)
echo "🌐 Updating global NPM packages..."
if command -v npm &> /dev/null; then
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY-RUN] Would run: npm install -g npm@latest && npm update -g"
    else
        npm install -g npm@latest
        npm update -g
    fi
fi

# 4. Java (SDKMAN)
echo "☕ Updating SDKMAN..."
# Prefer the existing `sdk` command when present, otherwise use a bash subshell
# so non-interactive shells still work without mutating the current shell.
if [ -d "$HOME/.sdkman" ]; then
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY-RUN] Would run: sdk selfupdate"
    elif command -v sdk &> /dev/null || [ -s "$SDKMAN_INIT" ]; then
        run_sdkman selfupdate || echo "⚠️ sdk selfupdate failed."
    else
        echo "⚠️ SDKMAN init script not found; skipping SDKMAN update."
    fi
fi

# 5. Python & AI Agent Frameworks
echo "🐍 Updating AI Agent Frameworks (Pip)..."
# Use `python -m pip` for a consistent environment, upgrade pip tools first,
# and prefer binary wheels to avoid source builds that trigger large downloads.
if command -v python3 &> /dev/null; then
    PY=python3
elif command -v python &> /dev/null; then
    PY=python
else
    echo "⚠️ Python not found; skipping pip package upgrades."
    PY=""
fi

if [ -n "$PY" ]; then
    VENV_DIR="$HOME/.ai-agent-venv"

    if [ "$DRY_RUN" = true ]; then
        echo "[DRY-RUN] Would update/create venv at $VENV_DIR and install packages"
    else
        # Wipe stale venv if it contains old langchain-core (<0.3) which conflicts with packaging>=24
        if [ -d "$VENV_DIR" ]; then
            OLD_LC=$("$VENV_DIR/bin/pip" show langchain-core 2>/dev/null | awk '/^Version:/{print $2}' || true)
            if [ -n "$OLD_LC" ] && [[ "$OLD_LC" == 0.1.* || "$OLD_LC" == 0.2.* ]]; then
                echo "🗑️  Stale venv detected (langchain-core $OLD_LC). Recreating..."
                rm -rf "$VENV_DIR"
            fi
        fi

        if [ ! -d "$VENV_DIR" ]; then
            echo "🐍 Creating virtualenv at $VENV_DIR..."
            "$PY" -m venv "$VENV_DIR" || { echo "⚠️ Failed to create venv; skipping pip step."; VENV_DIR=""; }
        fi

        if [ -n "$VENV_DIR" ]; then
            VENV_PY="$VENV_DIR/bin/python"

            echo "🔧 Upgrading pip in venv..."
            "$VENV_PY" -m pip install --upgrade pip || true

            echo "📦 Installing/Upgrading AI packages (binary wheels preferred)..."
            "$VENV_PY" -m pip install --upgrade --upgrade-strategy only-if-needed --prefer-binary \
                chromadb langchain langgraph || \
            echo "⚠️ Pip install failed; try: $VENV_DIR/bin/pip install chromadb langchain langgraph"
        fi
    fi
fi

# 6. Go Tools
echo "🐹 Updating Go Tools..."
if command -v golangci-lint &> /dev/null; then
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY-RUN] Would run: brew upgrade golangci-lint"
    else
        brew upgrade golangci-lint
    fi
fi

# 7. GitHub CLI Extensions (Copilot)
echo "🐙 Updating GitHub CLI extensions..."
if command -v gh &> /dev/null; then
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY-RUN] Would run: gh extension upgrade --all"
    else
        gh extension upgrade --all
    fi
fi

# 8. VS Code Extensions
echo "💻 Updating VS Code extensions..."
if command -v code &> /dev/null; then
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY-RUN] Would update all VS Code extensions"
    else
        for ext in $(code --list-extensions); do
            code --install-extension "$ext" --force
        done
    fi
fi

# 9. Ollama Models
echo "🤖 Updating Ollama models..."
if command -v ollama &> /dev/null; then
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY-RUN] Would run: ollama pull llama3"
    else
        ollama pull llama3 || echo "Ollama pull skipped."
    fi
fi

if [ "$DRY_RUN" = true ]; then
    echo "✅ macOS Update Dry-Run Complete!"
else
    echo "✅ macOS Update Complete!"
fi

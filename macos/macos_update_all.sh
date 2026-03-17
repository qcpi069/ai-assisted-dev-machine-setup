#!/bin/bash
# macos_update_all.sh
set -e
echo "🚀 Updating macOS environment..."

# 1. Homebrew
echo "🍺 Updating Homebrew..."
brew update && brew upgrade

# 2. Oh My Zsh
echo "🐚 Updating Oh My Zsh..."
if [ -d "$HOME/.oh-my-zsh" ]; then
    ZSH=$HOME/.oh-my-zsh /bin/sh $HOME/.oh-my-zsh/tools/upgrade.sh --non-interactive
fi

# 3. Node.js (Global npm)
echo "🌐 Updating global NPM packages..."
if command -v npm &> /dev/null; then
    npm install -g npm@latest
    npm update -g
fi

# 4. Java (SDKMAN)
echo "☕ Updating SDKMAN..."
# Avoid sourcing sdkman init script (can break in non-bash shells).
if [ -d "$HOME/.sdkman" ]; then
    if command -v sdk &> /dev/null; then
        sdk selfupdate || echo "⚠️ sdk selfupdate failed."
    else
        echo "⚠️ 'sdk' not found in PATH; skipping SDKMAN update to avoid shell incompatibility."
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

# 6. Go Tools
echo "🐹 Updating Go Tools..."
if command -v golangci-lint &> /dev/null; then
    brew upgrade golangci-lint
fi

# 7. GitHub CLI Extensions (Copilot)
echo "🐙 Updating GitHub CLI extensions..."
if command -v gh &> /dev/null; then
    gh extension upgrade --all
fi

# 8. VS Code Extensions
echo "💻 Updating VS Code extensions..."
if command -v code &> /dev/null; then
    for ext in $(code --list-extensions); do
        code --install-extension "$ext" --force
    done
fi

# 9. Ollama Models
echo "🤖 Updating Ollama models..."
if command -v ollama &> /dev/null; then
    ollama pull llama3 || echo "Ollama pull skipped."
fi

echo "✅ macOS Update Complete!"

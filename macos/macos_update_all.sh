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
if [ -d "$HOME/.sdkman" ]; then
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    sdk selfupdate
fi

# 5. Python & AI Agent Frameworks
echo "🐍 Updating AI Agent Frameworks (Pip)..."
pip3 install --upgrade crewai chromadb langchain langgraph || pip install --upgrade crewai chromadb langchain langgraph

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

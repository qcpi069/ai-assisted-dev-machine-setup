#!/bin/bash
# linux_update_all.sh - Automated Update Script for Linux Setup
set -e
echo "---------------------------------------------------"
echo "🚀 Starting Global Linux Update..."
echo "---------------------------------------------------"

# 1. System (Apt)
echo "📦 Updating Apt packages..."
sudo apt update && sudo apt upgrade -y

# 2. Homebrew
echo "🍺 Updating Homebrew formulae..."
brew update && brew upgrade

# 3. Oh My Zsh
echo "🐚 Updating Oh My Zsh..."
if [ -d "$HOME/.oh-my-zsh" ]; then
    ZSH=$HOME/.oh-my-zsh /bin/sh $HOME/.oh-my-zsh/tools/upgrade.sh --non-interactive || echo "Oh My Zsh update skipped."
fi

# 4. Node.js (Global npm)
echo "🌐 Updating global NPM packages..."
if command -v npm &> /dev/null; then
    npm install -g npm@latest
    npm update -g
fi

# 5. Java (SDKMAN)
echo "☕ Updating SDKMAN..."
if [ -d "$HOME/.sdkman" ]; then
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    sdk selfupdate
fi

# 6. Python & AI Agent Frameworks
echo "🐍 Updating AI Agent Frameworks (Pip)..."
pip3 install --upgrade crewai chromadb langchain langgraph || pip install --upgrade crewai chromadb langchain langgraph

# 7. Go Tools
echo "🐹 Updating Go Tools..."
if command -v golangci-lint &> /dev/null; then
    brew upgrade golangci-lint
fi

# 8. GitHub CLI Extensions (Copilot)
echo "🐙 Updating GitHub CLI extensions..."
if command -v gh &> /dev/null; then
    gh extension upgrade --all
fi

# 9. VS Code Extensions
echo "💻 Updating VS Code extensions..."
if command -v code &> /dev/null; then
    for ext in $(code --list-extensions); do
        code --install-extension "$ext" --force
    done
fi

# 10. Ollama Models
echo "🤖 Updating Ollama models..."
if command -v ollama &> /dev/null; then
    ollama pull llama3 || echo "Ollama pull skipped."
fi

echo "---------------------------------------------------"
echo "✅ Global Update Complete!"
echo "---------------------------------------------------"

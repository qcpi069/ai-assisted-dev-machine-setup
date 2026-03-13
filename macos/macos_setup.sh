#!/bin/bash
# macos_setup.sh - Mac Setup Script
set -e
echo "Starting Mac Setup..."

# Helper: Install Brew formula if not present
install_formula() {
    if ! brew list "$1" &>/dev/null; then
        echo "Installing $1..."
        brew install "$1"
    else
        echo "$1 is already installed. Skipping."
    fi
}

# Helper: Install Brew cask if not present
install_cask() {
    if ! brew list --cask "$1" &>/dev/null; then
        echo "Installing $1..."
        brew install --cask "$1"
    else
        echo "$1 is already installed. Skipping."
    fi
}

# Homebrew
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
brew update

# Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Zsh Plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# Runtimes
echo "Installing Node.js (via NVM)..."
export NVM_DIR="$HOME/.nvm"
[ ! -d "$NVM_DIR" ] && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install 22 || true
nvm install 20 || true

echo "Installing Java (via SDKMAN)..."
export SDKMAN_DIR="$HOME/.sdkman"
[ ! -d "$SDKMAN_DIR" ] && curl -s "https://get.sdkman.io" | bash
source "$SDKMAN_DIR/bin/sdkman-init.sh"
sdk install java 21.0.2-tem || true
sdk install java 17.0.10-tem || true

echo "Installing Python (via Pyenv)..."
install_formula pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
pyenv install 3.13:latest || true
pyenv install 3.12:latest || true
pyenv global $(pyenv versions --bare | grep "3.13" | tail -1) || true

echo "Installing Go (via Goenv)..."
install_formula goenv
export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$PATH"
eval "$(goenv init -)"
goenv install 1.26.0 || true
goenv install 1.25.0 || true
goenv global 1.26.0 || true
install_formula golangci-lint

# AI Agent Frameworks
echo "Installing AI Agent Frameworks..."
pip3 install --upgrade crewai chromadb langchain langgraph || pip install --upgrade crewai chromadb langchain langgraph

# OpenClaw
if [ ! -d "$HOME/openclaw" ]; then
    git clone https://github.com/OpenClaw/OpenClaw.git "$HOME/openclaw"
    cd "$HOME/openclaw" && pip3 install -r requirements.txt || true && cd -
else
    echo "OpenClaw directory already exists. Skipping clone."
fi

# Apps
echo "Installing Apps..."
APPS=(visual-studio-code cursor iterm2 podman-desktop ollama lm-studio anythingllm bruno rectangle draw-things diffusionbee upscayl strawberry steam epic-games)
for app in "${APPS[@]}"; do install_cask "$app"; done

# CLI Tools
echo "Installing CLI Tools..."
CLI_TOOLS=(gh jq fzf ripgrep podman-compose)
for tool in "${CLI_TOOLS[@]}"; do install_formula "$tool"; done

gh extension install github/gh-copilot --force || true

# VS Code Extensions
echo "Installing VS Code Extensions..."
EXTENSIONS=(saoudrizwan.claude-dev vscjava.vscode-java-pack ms-python.python Angular.ng-template dsznajder.es7-react-js-snippets dbaeumer.vscode-eslint esbenp.prettier-vscode mtxr.sqltools eamodio.gitlens usernamehw.errorlens)
for ext in "${EXTENSIONS[@]}"; do code --install-extension "$ext" --force; done

echo "✅ macOS Setup Complete! Check MACOS_USER_GUIDE.md."

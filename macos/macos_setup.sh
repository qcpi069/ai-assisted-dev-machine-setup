#!/bin/bash
# macos_setup.sh - Mac Setup Script (Improved for Junior Developers)
set -e

# Source the shared helpers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/../scripts/helpers.sh" ]; then
    source "$SCRIPT_DIR/../scripts/helpers.sh"
else
    # Fallback if helpers not found (for standalone use)
    echo "Note: Shared helpers not found. Running in standalone mode."
fi

# ============================================================================
# CONFIGURATION
# ============================================================================

DRY_RUN=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        -d|--dry-run)
            DRY_RUN=true
            ;;
    esac
done

# ============================================================================
# HELPER FUNCTIONS (duplicated for standalone use)
# ============================================================================

log_info() { echo -e "\033[0;34m[INFO]\033[0m $1"; }
log_success() { echo -e "\033[0;32m[SUCCESS]\033[0m $1"; }
log_warning() { echo -e "\033[1;33m[WARNING]\033[0m $1"; }
log_error() { echo -e "\033[0;31m[ERROR]\033[0m $1"; }

print_header() {
    echo ""
    echo -e "\033[0;36m╔════════════════════════════════════════════════════════════╗\033[0m"
    echo -e "\033[0;36m║$(printf '%*s' $((58 - ${#1})) | tr ' ' '=')\033[0m"
    echo -e "\033[0;36m║  $1\033[0m"
    echo -e "\033[0;36m╚════════════════════════════════════════════════════════════╝\033[0m"
    echo ""
}

print_section() {
    local section_name="$1"
    echo ""
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\033[0;34m➡  $section_name\033[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""
}

command_exists() { command -v "$1" &>/dev/null; }
brew_package_installed() { brew list "$1" &>/dev/null; }

install_formula() {
    local package="$1"
    if brew_package_installed "$package"; then
        log_info "✓ $package is already installed. Skipping."
        return 0
    fi
    log_info "Installing $package..."
    
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would install $package"
        return 0
    fi
    
    if brew install "$package"; then
        log_success "✓ $package installed successfully"
        return 0
    else
        log_error "✗ Failed to install $package"
        return 1
    fi
}

install_cask() {
    local package="$1"
    if brew list --cask "$package" &>/dev/null; then
        log_info "✓ $package is already installed. Skipping."
        return 0
    fi
    log_info "Installing $package..."
    
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would install $package (cask)"
        return 0
    fi
    
    if brew install --cask "$package"; then
        log_success "✓ $package installed successfully"
        return 0
    else
        log_error "✗ Failed to install $package (cask)"
        return 1
    fi
}

# ============================================================================
# MAIN SETUP FUNCTIONS
# ============================================================================

setup_homebrew() {
    print_section "Homebrew Installation"
    
    if ! command_exists brew; then
        if [ "$DRY_RUN" = true ]; then
            log_info "[DRY-RUN] Would install Homebrew"
        else
            log_info "Homebrew not found. Installing..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    else
        log_success "✓ Homebrew is already installed"
    fi
    
    log_info "Updating Homebrew..."
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would run brew update"
    else
        brew update
    fi
}

setup_shell() {
    print_section "Shell Configuration (Zsh + Oh My Zsh)"
    
    # Install Oh My Zsh
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        if [ "$DRY_RUN" = true ]; then
            log_info "[DRY-RUN] Would install Oh My Zsh"
        else
            log_info "Installing Oh My Zsh..."
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        fi
    else
        log_success "✓ Oh My Zsh is already installed"
    fi
    
    # Install zsh-autosuggestions
    local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        if [ "$DRY_RUN" = true ]; then
            log_info "[DRY-RUN] Would install zsh-autosuggestions plugin"
        else
            log_info "Installing zsh-autosuggestions plugin..."
            git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
        fi
    else
        log_success "✓ zsh-autosuggestions is already installed"
    fi
    
    # Install zsh-syntax-highlighting
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        if [ "$DRY_RUN" = true ]; then
            log_info "[DRY-RUN] Would install zsh-syntax-highlighting plugin"
        else
            log_info "Installing zsh-syntax-highlighting plugin..."
            git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
        fi
    else
        log_success "✓ zsh-syntax-highlighting is already installed"
    fi
}

setup_runtimes() {
    print_section "Development Runtimes (Node.js, Java, Python, Go)"
    
    # --- Node.js via NVM ---
    log_info "Installing Node.js (via NVM)..."
    export NVM_DIR="$HOME/.nvm"
    
    if [ ! -d "$NVM_DIR" ]; then
        if [ "$DRY_RUN" = true ]; then
            log_info "[DRY-RUN] Would install NVM"
        else
            log_info "Installing NVM..."
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        fi
    else
        log_success "✓ NVM is already installed"
    fi
    
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would install Node.js versions 20 and 22"
    else
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        
        log_info "Installing Node.js versions..."
        nvm install 22 || log_warning "⚠ Could not install Node.js 22"
        nvm install 20 || log_warning "⚠ Could not install Node.js 20"
    fi
    
    # --- Java via SDKMAN ---
    log_info "Installing Java (via SDKMAN)..."
    export SDKMAN_DIR="$HOME/.sdkman"
    
    if [ ! -d "$SDKMAN_DIR" ]; then
        if [ "$DRY_RUN" = true ]; then
            log_info "[DRY-RUN] Would install SDKMAN"
        else
            log_info "Installing SDKMAN..."
            curl -s "https://get.sdkman.io" | bash
        fi
    else
        log_success "✓ SDKMAN is already installed"
    fi
    
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would install Java versions 17 and 21"
    else
        [ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ] && \. "$SDKMAN_DIR/bin/sdkman-init.sh"
        
        log_info "Installing Java versions..."
        sdk install java 21.0.2-tem || log_warning "⚠ Could not install Java 21"
        sdk install java 17.0.10-tem || log_warning "⚠ Could not install Java 17"
    fi
    
    # --- Python via Pyenv ---
    log_info "Installing Python (via Pyenv)..."
    
    if ! brew_package_installed pyenv; then
        install_formula pyenv
    fi
    
    export PYENV_ROOT="$HOME/.pyenv"
    
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would install Python versions 3.12 and 3.13"
    else
        [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init -)" 2>/dev/null || true
        
        log_info "Installing Python versions..."
        pyenv install 3.13:latest || log_warning "⚠ Could not install Python 3.13"
        pyenv install 3.12:latest || log_warning "⚠ Could not install Python 3.12"
        
        # Set default Python version
        local latest_313=$(pyenv versions --bare | grep "3.13" | tail -1)
        local latest_312=$(pyenv versions --bare | grep "3.12" | tail -1)
        
        if [ -n "$latest_313" ]; then
            pyenv global "$latest_313"
        elif [ -n "$latest_312" ]; then
            pyenv global "$latest_312"
        fi
    fi
    
    # --- Go via Goenv ---
    log_info "Installing Go (via Goenv)..."
    
    if ! brew_package_installed goenv; then
        install_formula goenv
    fi
    
    export GOENV_ROOT="$HOME/.goenv"
    
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would install Go versions 1.25 and 1.26"
    else
        export PATH="$GOENV_ROOT/bin:$PATH"
        eval "$(goenv init -)" 2>/dev/null || true
        
        log_info "Installing Go versions..."
        goenv install 1.26.0 || log_warning "⚠ Could not install Go 1.26"
        goenv install 1.25.0 || log_warning "⚠ Could not install Go 1.25"
        goenv global 1.26.0 || true
    fi
    
    if brew_package_installed golangci-lint; then
        log_success "✓ golangci-lint is already installed"
    else
        install_formula golangci-lint
    fi
}

setup_ai_frameworks() {
    print_section "AI Agent Frameworks"
    
    log_info "Installing AI Agent Frameworks (LangChain, etc.)..."
    
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would install AI Agent Frameworks via pip"
    else
        if pip3 install --upgrade chromadb langchain langgraph 2>/dev/null; then
            log_success "✓ AI Agent Frameworks installed successfully"
        elif pip install --upgrade chromadb langchain langgraph 2>/dev/null; then
            log_success "✓ AI Agent Frameworks installed successfully"
        else
            log_warning "⚠ Could not install AI Agent Frameworks (check Python/pip)"
        fi
    fi
    
    # OpenClaw
    if [ ! -d "$HOME/openclaw" ]; then
        if [ "$DRY_RUN" = true ]; then
            log_info "[DRY-RUN] Would clone OpenClaw"
        else
            log_info "Cloning OpenClaw..."
            if git clone https://github.com/OpenClaw/OpenClaw.git "$HOME/openclaw"; then
                log_success "✓ OpenClaw cloned successfully"
                
                if [ -f "$HOME/openclaw/requirements.txt" ]; then
                    log_info "Installing OpenClaw dependencies..."
                    if pip3 install -r "$HOME/openclaw/requirements.txt" 2>/dev/null; then
                        log_success "✓ OpenClaw dependencies installed"
                    elif pip install -r "$HOME/openclaw/requirements.txt" 2>/dev/null; then
                        log_success "✓ OpenClaw dependencies installed"
                    else
                        log_warning "⚠ Could not install OpenClaw dependencies"
                    fi
                fi
            else
                log_error "✗ Failed to clone OpenClaw"
            fi
        fi
    else
        log_success "✓ OpenClaw directory already exists"
    fi
}

setup_apps() {
    print_section "Applications (Homebrew Casks)"
    
    local APPS=(visual-studio-code cursor antigravity iterm2 podman-desktop ollama lm-studio anythingllm bruno rectangle draw-things diffusionbee upscayl strawberry steam epic-games)
    
    log_info "Installing ${#APPS[@]} applications..."
    
    for app in "${APPS[@]}"; do
        install_cask "$app"
    done
    
    log_success "✓ All applications installed successfully"
}

setup_cli_tools() {
    print_section "CLI Tools (Homebrew)"
    
    local CLI_TOOLS=(gh jq fzf ripgrep podman podman-compose)
    
    log_info "Installing ${#CLI_TOOLS[@]} CLI tools..."
    
    for tool in "${CLI_TOOLS[@]}"; do
        install_formula "$tool"
    done
    
    # GitHub CLI extensions
    if command_exists gh; then
        log_info "Installing GitHub CLI extensions..."
        gh extension install github/gh-copilot --force 2>/dev/null || log_warning "⚠ Could not install gh-copilot"
    else
        log_warning "⚠ GitHub CLI not found, skipping extensions"
    fi
    
    log_success "✓ All CLI tools installed successfully"
}

setup_vscode_extensions() {
    print_section "VS Code Extensions"
    
    local EXTENSIONS=(saoudrizwan.claude-dev vscjava.vscode-java-pack ms-python.python Angular.ng-template dsznajder.es7-react-js-snippets dbaeumer.vscode-eslint esbenp.prettier-vscode mtxr.sqltools eamodio.gitlens usernamehw.errorlens)
    
    log_info "Installing ${#EXTENSIONS[@]} VS Code extensions..."
    
    if ! command_exists code; then
        log_warning "⚠ VS Code not found, skipping extensions"
        return 0
    fi
    
    local installed=0
    local skipped=0
    
    for ext in "${EXTENSIONS[@]}"; do
        if code --install-extension "$ext" --force 2>/dev/null; then
            ((installed++))
        else
            ((skipped++))
        fi
    done
    
    log_success "✓ Installed $installed VS Code extensions ($skipped skipped)"
}

print_summary() {
    print_header "Installation Summary"
    
    echo ""
    echo -e "\033[0;36mDuration:\033[0m $(( $(date +%s) - START_TIME )) seconds"
    echo ""
    
    # Show installed versions
    if command_exists node; then
        echo -e "\033[0;32mNode.js:\033[0m $(node --version 2>/dev/null || echo 'N/A')"
    fi
    
    if command_exists python3; then
        echo -e "\033[0;32mPython:\033[0m $(python3 --version 2>/dev/null || echo 'N/A')"
    fi
    
    if command_exists java; then
        echo -e "\033[0;32mJava:\033[0m $(java -version 2>&1 | head -1 || echo 'N/A')"
    fi
    
    if command_exists ollama; then
        echo -e "\033[0;32mOllama:\033[0m $(ollama --version 2>/dev/null || echo 'N/A')"
    fi
    
    if command_exists podman; then
        echo -e "\033[0;32mPodman:\033[0m $(podman --version 2>/dev/null || echo 'N/A')"
    fi
    
    if command_exists gh; then
        echo -e "\033[0;32mGitHub CLI:\033[0m $(gh --version 2>/dev/null || echo 'N/A')"
    fi
    
    if command_exists code; then
        echo -e "\033[0;32mVS Code:\033[0m $(code --version 2>/dev/null || echo 'N/A')"
    fi
    
    if command_exists brew; then
        echo -e "\033[0;32mHomebrew:\033[0m $(brew --version | head -1 || echo 'N/A')"
    fi
    
    echo ""
    print_header "Next Steps"
    
    echo ""
    echo -e "\033[0;36m1.\033[0m \033[1mRestart your terminal\033[0m (or run: source ~/.zshrc)"
    echo -e "\033[0;36m2.\033[0m \033[1mVerify installations:\033[0m"
    echo ""
    echo -e "   \033[0;34mnode -v\033[0m            # Node.js — expect v20.x or v22.x"
    echo -e "   \033[0;34mjava -version\033[0m      # Java — expect 21.x or 17.x"
    echo -e "   \033[0;34mpython3 --version\033[0m  # Python — expect 3.12+"
    echo -e "   \033[0;34mollama --version\033[0m   # Ollama local LLM runner"
    echo -e "   \033[0;34mpodman --version\033[0m   # Podman CLI"
    echo -e "   \033[0;34mgh --version\033[0m       # GitHub CLI"
    echo -e "   \033[0;34mcode --version\033[0m     # VS Code"
    echo ""
    echo -e "\033[0;36m3.\033[0m \033[1mStart using your AI development environment!\033[0m"
    echo ""
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

START_TIME=$(date +%s)

if [ "$DRY_RUN" = true ]; then
    print_header "AI Agent Dev Machine Setup - macOS (DRY-RUN)"
    log_info "Running in dry-run mode. No changes will be made."
else
    print_header "AI Agent Dev Machine Setup - macOS"

    echo ""
    echo -e "\033[0;36mThis script will set up your development environment with:\033[0m"
    echo -e "  • \033[0;32mDevelopment Runtimes\033[0m: Node.js, Java, Python, Go"
    echo -e "  • \033[0;32mAI Tools\033[0m: LM Studio, Ollama, AnythingLLM, LangChain, LangGraph"
    echo -e "  • \033[0;32mEditors\033[0m: VS Code, Cursor, Antigravity"
    echo -e "  • \033[0;32mCLI Tools\033[0m: GitHub CLI, jq, fzf, ripgrep"
    echo -e "  • \033[0;32mApplications\033[0m: Various dev tools and utilities"
    echo ""

    log_warning "IMPORTANT: This setup is intended for FRESH INSTALLATIONS."
    log_warning "It may conflict with existing packages, applications, or environments"
    log_warning "managed by other tools or manual installations."
    echo ""

    # Ask for confirmation
    read -p "Continue? (y/N) " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Setup cancelled by user"
        exit 0
    fi
fi

echo ""
log_info "Starting macOS setup..."
echo ""

# Run all setup functions
setup_homebrew
setup_shell
setup_runtimes
setup_ai_frameworks
setup_apps
setup_cli_tools
setup_vscode_extensions

# Print summary
print_summary

if [ "$DRY_RUN" = true ]; then
    log_success "✅ macOS Setup Dry-Run Complete!"
else
    log_success "✅ macOS Setup Complete!"
fi

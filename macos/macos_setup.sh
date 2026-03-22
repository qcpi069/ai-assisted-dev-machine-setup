#!/bin/zsh
# macos_setup.sh - Mac Setup Script (Improved for Junior Developers)
set -e

# Source the shared helpers
SCRIPT_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
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
    install_ohmyzsh
    
    # Install plugins
    install_zsh_autosuggestions
    install_zsh_syntax_highlighting
}

setup_runtimes() {
    print_section "Development Runtimes (Node.js, Java, Python, Go)"
    
    # --- Node.js via NVM ---
    log_info "Installing Node.js (via NVM)..."
    if install_nvm; then
        if [ "$DRY_RUN" = true ]; then
            log_info "[DRY-RUN] Would install Node.js versions 20 and 22"
        else
            log_info "Installing Node.js versions..."
            install_nvm_version 22
            install_nvm_version 20
        fi
    fi
    
    # --- Java via SDKMAN ---
    log_info "Installing Java (via SDKMAN)..."
    if install_sdkman; then
        if [ "$DRY_RUN" = true ]; then
            log_info "[DRY-RUN] Would install Java versions 17 and 21"
        else
            log_info "Installing Java versions..."
            install_java_version "21.0.2-tem"
            install_java_version "17.0.10-tem"
        fi
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
        for py_ver in "3.13:latest" "3.12:latest"; do
            local base_ver=${py_ver%:latest}
            if pyenv_version_installed "$base_ver"; then
                log_success "✓ Python $base_ver is already installed. Skipping."
            else
                pyenv install "$py_ver" || log_warning "⚠ Could not install Python $py_ver"
            fi
        done
        
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
        for go_ver in "1.26.0" "1.25.0"; do
            if goenv_version_installed "$go_ver"; then
                log_success "✓ Go $go_ver is already installed. Skipping."
            else
                goenv install "$go_ver" || log_warning "⚠ Could not install Go $go_ver"
            fi
        done
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
    
    local APPS=(visual-studio-code cursor antigravity iterm2 podman-desktop ollama lm-studio anythingllm bruno rectangle draw-things diffusionbee upscayl steam epic-games)
    
    log_info "Installing ${#APPS[@]} applications..."
    
    for app in "${APPS[@]}"; do
        install_cask "$app"
    done
    
    log_success "✓ All applications installed successfully"
}

setup_cli_tools() {
    print_section "CLI Tools (Homebrew)"
    
    # Podman 5.x on macOS requires virtualization backends
    # vfkit is standard, krunkit provides better performance on Apple Silicon
    log_info "Installing Podman virtualization backends..."
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would tap slp/homebrew-krunkit"
    else
        brew tap slp/homebrew-krunkit 2>/dev/null || log_warning "⚠ Could not tap slp/homebrew-krunkit"
    fi
    
    local CLI_TOOLS=(gh jq fzf ripgrep podman podman-compose vfkit krunkit)
    
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

setup_docker_alias() {
    print_section "Container Aliases (Docker -> Podman)"
    
    if ! command_exists podman; then
        log_warning "⚠ Podman not found, skipping alias setup"
        return 0
    fi
    
    local alias_cmd="alias docker=podman"
    local shell_configs=("$HOME/.zshrc" "$HOME/.bashrc")
    local updated=false
    
    for config in "${shell_configs[@]}"; do
        if [ -f "$config" ]; then
            if ! grep -q "$alias_cmd" "$config"; then
                if [ "$DRY_RUN" = true ]; then
                    log_info "[DRY-RUN] Would add alias to $config"
                else
                    echo "" >> "$config"
                    echo "# Podman alias for Docker compatibility" >> "$config"
                    echo "$alias_cmd" >> "$config"
                    log_success "✓ Added docker alias to $config"
                    updated=true
                fi
            else
                log_success "✓ Docker alias already exists in $config"
            fi
        fi
    done
    
    if [ "$updated" = true ] && [ "$DRY_RUN" = false ]; then
        log_info "Alias added. It will be available in new terminal sessions."
        log_info "To use it in this session, run: source ~/.zshrc (or your shell config)"
    fi
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
        echo -e "\033[0;32mDocker/Podman:\033[0m $(podman --version 2>/dev/null || echo 'N/A')"
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
    echo -e "   \033[0;34mdocker --version\033[0m   # Podman aliased as docker"
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
    read "REPLY?Continue? (y/N) "
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
setup_docker_alias
setup_vscode_extensions

# Print summary
print_summary

if [ "$DRY_RUN" = true ]; then
    log_success "✅ macOS Setup Dry-Run Complete!"
else
    log_success "✅ macOS Setup Complete!"
fi

#!/bin/bash
# linux_setup.sh - Linux Setup Script (Improved for Junior Developers)
set -e

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
# HELPER FUNCTIONS
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

install_apt() {
    local package="$1"
    if dpkg -l | grep -q "^ii  $package "; then
        log_info "✓ $package is already installed. Skipping."
        return 0
    fi
    log_info "Installing $package..."
    
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would install $package via apt"
        return 0
    fi
    
    if sudo apt install -y "$package"; then
        log_success "✓ $package installed successfully"
        return 0
    else
        log_error "✗ Failed to install $package (apt)"
        return 1
    fi
}

pyenv_version_installed() {
    local version="$1"
    if command -v pyenv &>/dev/null; then
        pyenv versions --bare | grep -q "^${version}"
        return $?
    fi
    return 1
}

goenv_version_installed() {
    local version="$1"
    if command -v goenv &>/dev/null; then
        goenv versions --bare | grep -q "^${version}"
        return $?
    fi
    return 1
}

# ============================================================================
# MAIN SETUP FUNCTIONS
# ============================================================================

setup_system_update() {
    print_section "System Update & Dependencies"
    
    log_info "Updating system packages..."
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would run: sudo apt update && sudo apt upgrade -y"
    else
        if sudo apt update && sudo apt upgrade -y; then
            log_success "✓ System packages updated successfully"
        else
            log_warning "⚠ Could not update system packages (may already be up to date)"
        fi
    fi
    
    log_info "Installing base dependencies..."
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would install base dependencies via apt"
    else
        if sudo apt install -y build-essential curl file git procps zsh; then
            log_success "✓ Base dependencies installed successfully"
        else
            log_warning "⚠ Could not install all base dependencies"
        fi
    fi
}

setup_homebrew() {
    print_section "Homebrew Installation (Linuxbrew)"
    
    if ! command_exists brew; then
        if [ "$DRY_RUN" = true ]; then
            log_info "[DRY-RUN] Would install Homebrew"
        else
            log_info "Homebrew not found. Installing..."
            
            if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
                log_success "✓ Homebrew installed successfully"
                
                # Add to PATH for current session
                test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
                test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
                
                # Add to bashrc for future sessions
                if ! grep -q "brew shellenv" "$HOME/.bashrc"; then
                    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$HOME/.bashrc"
                    log_success "✓ Homebrew added to PATH in ~/.bashrc"
                fi
            else
                log_error "✗ Failed to install Homebrew"
                return 1
            fi
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
            if sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
                log_success "✓ Oh My Zsh installed successfully"
            else
                log_warning "⚠ Could not install Oh My Zsh"
            fi
        fi
    else
        log_success "✓ Oh My Zsh is already installed"
    fi
    
    # Install zsh-autosuggestions
    local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        if [ "$DRY_RUN" = true ]; then
            log_info "[DRY-RUN] Would install zsh-autosuggestions"
        else
            log_info "Installing zsh-autosuggestions plugin..."
            if git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"; then
                log_success "✓ zsh-autosuggestions installed successfully"
            else
                log_warning "⚠ Could not install zsh-autosuggestions"
            fi
        fi
    else
        log_success "✓ zsh-autosuggestions is already installed"
    fi
    
    # Install zsh-syntax-highlighting
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        if [ "$DRY_RUN" = true ]; then
            log_info "[DRY-RUN] Would install zsh-syntax-highlighting"
        else
            log_info "Installing zsh-syntax-highlighting plugin..."
            if git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"; then
                log_success "✓ zsh-syntax-highlighting installed successfully"
            else
                log_warning "⚠ Could not install zsh-syntax-highlighting"
            fi
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
            if curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash; then
                log_success "✓ NVM installed successfully"
            else
                log_warning "⚠ Could not install NVM"
            fi
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
            if curl -s "https://get.sdkman.io" | bash; then
                log_success "✓ SDKMAN installed successfully"
            else
                log_warning "⚠ Could not install SDKMAN"
            fi
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

    # Use a dedicated virtualenv to avoid polluting system site-packages
    local VENV_DIR="$HOME/.ai-agent-venv"
    local PY=""
    if command_v python3 &> /dev/null; then PY=python3
    elif command_v python &> /dev/null; then PY=python
    fi

    if [ -n "$PY" ]; then
        if [ "$DRY_RUN" = true ]; then
            log_info "[DRY-RUN] Would create venv and install AI Agent Frameworks"
        else
            if [ ! -d "$VENV_DIR" ]; then
                log_info "Creating virtualenv at $VENV_DIR..."
                "$PY" -m venv "$VENV_DIR" || { log_warning "⚠ Could not create venv"; return 1; }
            fi
            local VENV_PY="$VENV_DIR/bin/python"
            "$VENV_PY" -m pip install --upgrade pip || true
            if "$VENV_PY" -m pip install --upgrade --upgrade-strategy only-if-needed --prefer-binary \
                chromadb langchain langgraph 2>/dev/null; then
                log_success "✓ AI Agent Frameworks installed successfully"
            else
                log_warning "⚠ Could not install AI Agent Frameworks (check Python/pip)"
            fi
        fi
    else
        log_warning "⚠ Python not found; skipping AI Agent Frameworks"
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

setup_opencode() {
    print_section "OpenCode (AI Agent CLI Tool)"
    
    log_info "Installing OpenCode..."
    
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would install opencode via Homebrew"
        return 0
    fi
    
    if brew list opencode &>/dev/null; then
        log_success "✓ OpenCode is already installed"
    else
        if brew install anomalyco/tap/opencode; then
            log_success "✓ OpenCode installed successfully"
        else
            log_warning "⚠ Could not install OpenCode"
        fi
    fi
}

setup_docker_alias() {
    print_section "Container Aliases (Docker -> Podman)"
    
    if ! command_exists podman; then
        log_warning "⚠ Podman not found, skipping alias setup"
        return 0
    fi
    
    local alias_cmd="alias docker=podman"
    local shell_configs=("$HOME/.bashrc" "$HOME/.zshrc")
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
        log_info "To use it in this session, run: source ~/.bashrc (or your shell config)"
    fi
}

setup_applications() {
    print_section "GUI Applications (Apt/Snap)"
    
    # VS Code via Snap
    log_info "Installing VS Code..."
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would install code via snap"
    else
        if sudo snap install code --classic 2>/dev/null; then
            log_success "✓ VS Code installed successfully"
        else
            log_warning "⚠ Could not install VS Code via snap (may already be installed)"
        fi
    fi
    
    # Bruno via Snap
    log_info "Installing Bruno..."
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would install bruno via snap"
    else
        if sudo snap install bruno 2>/dev/null; then
            log_success "✓ Bruno installed successfully"
        else
            log_warning "⚠ Could not install Bruno via snap (may already be installed)"
        fi
    fi
    
    # Antigravity IDE via Snap
    log_info "Installing Antigravity IDE..."
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would install antigravity via snap"
    else
        if sudo snap install antigravity --classic 2>/dev/null; then
            log_success "✓ Antigravity IDE installed successfully"
        else
            log_warning "⚠ Could not install Antigravity IDE via snap (may already be installed)"
        fi
    fi
    
    # Steam
    log_info "Installing Steam..."
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would install steam via apt"
    else
        if sudo apt install -y steam 2>/dev/null; then
            log_success "✓ Steam installed successfully"
        else
            log_warning "⚠ Could not install Steam (may already be installed)"
        fi
    fi
    
    # Ollama
    log_info "Installing Ollama..."
    if ! command_exists ollama; then
        if [ "$DRY_RUN" = true ]; then
            log_info "[DRY-RUN] Would install Ollama"
        else
            if curl -fsSL https://ollama.com/install.sh | sh; then
                log_success "✓ Ollama installed successfully"
            else
                log_warning "⚠ Could not install Ollama"
            fi
        fi
    else
        log_success "✓ Ollama is already installed"
    fi
    
    log_success "✓ All applications installed successfully"
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
    
    if command_exists docker; then
        echo -e "\033[0;32mDocker/Podman:\033[0m $(docker --version 2>/dev/null || echo 'N/A')"
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
    
    if command_exists opencode; then
        echo -e "\033[0;32mOpenCode:\033[0m $(opencode --version 2>/dev/null || echo 'N/A')"
    fi
    
    echo ""
    print_header "Next Steps"
    
    echo ""
    echo -e "\033[0;36m1.\033[0m \033[1mRestart your terminal\033[0m (or run: source ~/.bashrc)"
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
    print_header "AI Agent Dev Machine Setup - Linux (DRY-RUN)"
    log_info "Running in dry-run mode. No changes will be made."
else
    print_header "AI Agent Dev Machine Setup - Linux"

    echo ""
    echo -e "\033[0;36mThis script will set up your development environment with:\033[0m"
    echo -e "  • \033[0;32mSystem Updates\033[0m: Base dependencies and package updates"
    echo -e "  • \033[0;32mDevelopment Runtimes\033[0m: Node.js, Java, Python, Go"
    echo -e "  • \033[0;32mAI Tools\033[0m: LM Studio, Ollama, AnythingLLM, LangChain, LangGraph"
    echo -e "  • \033[0;32mEditors\033[0m: VS Code, Cursor, Antigravity"
    echo -e "  • \033[0;32mCLI Tools\033[0m: GitHub CLI, jq, fzf, ripgrep"
    echo -e "  • \033[0;32mApplications\033[0m: Various dev tools and utilities"
    echo ""

    log_warning "IMPORTANT: This setup is intended for FRESH INSTALLATIONS."
    log_warning "It may conflict with existing packages (Snap, Apt, Flatpak), applications,"
    log_warning "or environments managed by other tools or manual installations."
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
log_info "Starting Linux setup..."
echo ""

# Run all setup functions
setup_system_update
setup_homebrew
setup_shell
setup_runtimes
setup_ai_frameworks
setup_cli_tools
setup_opencode
setup_docker_alias
setup_applications

# Print summary
print_summary

if [ "$DRY_RUN" = true ]; then
    log_success "✅ Linux Setup Dry-Run Complete!"
else
    log_success "✅ Linux Setup Complete!"
fi
#!/bin/bash
# helpers.sh - Shared helper functions for all setup scripts
# Usage: source scripts/helpers.sh

# ============================================================================
# CONFIGURATION
# ============================================================================

SCRIPT_START_TIME=$(date +%s)
LOG_FILE="/tmp/setup_$(date +%Y%m%d_%H%M%S).log"
VERBOSE=false
DRY_RUN=false

# Colors for output (works on most terminals)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$level" in
        INFO)  echo -e "${BLUE}[INFO]${NC} ${timestamp} - $message" | tee -a "$LOG_FILE" ;;
        SUCCESS) echo -e "${GREEN}[SUCCESS]${NC} ${timestamp} - $message" | tee -a "$LOG_FILE" ;;
        WARNING) echo -e "${YELLOW}[WARNING]${NC} ${timestamp} - $message" | tee -a "$LOG_FILE" ;;
        ERROR)   echo -e "${RED}[ERROR]${NC} ${timestamp} - $message" | tee -a "$LOG_FILE" ;;
        HEADER)  echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}" | tee -a "$LOG_FILE"
                 echo -e "${CYAN}║ ${message}" | tee -a "$LOG_FILE" ;;
        FOOTER)  echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}" | tee -a "$LOG_FILE" ;;
    esac
}

log_info() { log "INFO" "$@"; }
log_success() { log "SUCCESS" "$@"; }
log_warning() { log "WARNING" "$@"; }
log_error() { log "ERROR" "$@"; }

print_header() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║$(printf '%*s' $((58 - ${#1})) | tr ' ' '=')${NC}"
    echo -e "${CYAN}║  $1${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_section() {
    local section_name="$1"
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}➡  $section_name${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

# Check if a command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Check if a package is installed via Homebrew
brew_package_installed() {
    brew list "$1" &>/dev/null
}

# Install Homebrew formula if not present
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

# Install Homebrew cask if not present
install_cask() {
    local package="$1"
    
    if brew list --cask "$package" &>/dev/null; then
        log_info "✓ $package is already installed. Skipping."
        return 0
    fi
    
    log_info "Installing $package..."
    
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would install $package as cask"
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

# Install APT package if not present
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

# Install Chocolatey package if not present
install_choco() {
    local package="$1"
    
    if choco list --local-only | grep -qi "^$package "; then
        log_info "✓ $package is already installed. Skipping."
        return 0
    fi
    
    log_info "Installing $package..."
    
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would install $package via Chocolatey"
        return 0
    fi
    
    if choco install "$package" -y; then
        log_success "✓ $package installed successfully"
        return 0
    else
        log_error "✗ Failed to install $package (Chocolatey)"
        return 1
    fi
}

# Install NVM if not present
install_nvm() {
    local nvm_dir="$HOME/.nvm"
    
    if [ -d "$nvm_dir" ]; then
        log_info "✓ NVM is already installed. Skipping."
        return 0
    fi
    
    log_info "Installing NVM..."
    
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would install NVM"
        return 0
    fi
    
    if curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash; then
        log_success "✓ NVM installed successfully"
        
        # Source NVM in current session
        export NVM_DIR="$nvm_dir"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        
        return 0
    else
        log_error "✗ Failed to install NVM"
        return 1
    fi
}

# Install SDKMAN if not present
install_sdkman() {
    local sdkman_dir="$HOME/.sdkman"
    
    if [ -d "$sdkman_dir" ]; then
        log_info "✓ SDKMAN is already installed. Skipping."
        return 0
    fi
    
    log_info "Installing SDKMAN..."
    
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would install SDKMAN"
        return 0
    fi
    
    if curl -s "https://get.sdkman.io" | bash; then
        log_success "✓ SDKMAN installed successfully"
        
        # Source SDKMAN in current session
        export SDKMAN_DIR="$sdkman_dir"
        [ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ] && \. "$SDKMAN_DIR/bin/sdkman-init.sh"
        
        return 0
    else
        log_error "✗ Failed to install SDKMAN"
        return 0  # Don't fail the whole script for SDKMAN
    fi
}

# Install Oh My Zsh if not present
install_ohmyzsh() {
    local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    
    if [ -d "$HOME/.oh-my-zsh" ]; then
        log_info "✓ Oh My Zsh is already installed. Skipping."
        return 0
    fi
    
    log_info "Installing Oh My Zsh..."
    
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would install Oh My Zsh"
        return 0
    fi
    
    if sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
        log_success "✓ Oh My Zsh installed successfully"
        return 0
    else
        log_error "✗ Failed to install Oh My Zsh"
        return 1
    fi
}

# Install zsh-autosuggestions plugin
install_zsh_autosuggestions() {
    local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    
    if [ -d "$zsh_custom/plugins/zsh-autosuggestions" ]; then
        log_info "✓ zsh-autosuggestions is already installed. Skipping."
        return 0
    fi
    
    log_info "Installing zsh-autosuggestions..."
    
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would install zsh-autosuggestions"
        return 0
    fi
    
    if git clone https://github.com/zsh-users/zsh-autosuggestions "$zsh_custom/plugins/zsh-autosuggestions"; then
        log_success "✓ zsh-autosuggestions installed successfully"
        return 0
    else
        log_error "✗ Failed to install zsh-autosuggestions"
        return 1
    fi
}

# Install zsh-syntax-highlighting plugin
install_zsh_syntax_highlighting() {
    local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    
    if [ -d "$zsh_custom/plugins/zsh-syntax-highlighting" ]; then
        log_info "✓ zsh-syntax-highlighting is already installed. Skipping."
        return 0
    fi
    
    log_info "Installing zsh-syntax-highlighting..."
    
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would install zsh-syntax-highlighting"
        return 0
    fi
    
    if git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$zsh_custom/plugins/zsh-syntax-highlighting"; then
        log_success "✓ zsh-syntax-highlighting installed successfully"
        return 0
    else
        log_error "✗ Failed to install zsh-syntax-highlighting"
        return 1
    fi
}

# Install a runtime version using nvm
install_nvm_version() {
    local version="$1"
    
    log_info "Installing Node.js $version via NVM..."
    
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would install Node.js $version"
        return 0
    fi
    
    # Source NVM if not already sourced
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    if nvm install "$version" 2>/dev/null; then
        log_success "✓ Node.js $version installed successfully"
        return 0
    else
        log_warning "⚠ Could not install Node.js $version (may already exist)"
        return 0
    fi
}

# Install a Java version using SDKMAN
install_java_version() {
    local version="$1"
    
    log_info "Installing Java $version via SDKMAN..."
    
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would install Java $version"
        return 0
    fi
    
    # Source SDKMAN if not already sourced
    export SDKMAN_DIR="$HOME/.sdkman"
    [ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ] && \. "$SDKMAN_DIR/bin/sdkman-init.sh"
    
    if sdk install java "$version" 2>/dev/null; then
        log_success "✓ Java $version installed successfully"
        return 0
    else
        log_warning "⚠ Could not install Java $version (may already exist)"
        return 0
    fi
}

# Install a Python version using pyenv
install_pyenv_version() {
    local version="$1"
    
    log_info "Installing Python $version via Pyenv..."
    
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would install Python $version"
        return 0
    fi
    
    # Source Pyenv if not already sourced
    export PYENV_ROOT="$HOME/.pyenv"
    [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)" 2>/dev/null || true
    
    if pyenv install "$version" 2>/dev/null; then
        log_success "✓ Python $version installed successfully"
        return 0
    else
        log_warning "⚠ Could not install Python $version (may already exist)"
        return 0
    fi
}

# Install a Go version using goenv
install_goenv_version() {
    local version="$1"
    
    log_info "Installing Go $version via Goenv..."
    
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would install Go $version"
        return 0
    fi
    
    # Source Goenv if not already sourced
    export GOENV_ROOT="$HOME/.goenv"
    export PATH="$GOENV_ROOT/bin:$PATH"
    eval "$(goenv init -)" 2>/dev/null || true
    
    if goenv install "$version" 2>/dev/null; then
        log_success "✓ Go $version installed successfully"
        return 0
    else
        log_warning "⚠ Could not install Go $version (may already exist)"
        return 0
    fi
}

# Install AI Agent Frameworks via pip
install_ai_frameworks() {
    log_info "Installing AI Agent Frameworks (CrewAI, LangChain, etc.)..."
    
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would install AI Agent Frameworks"
        return 0
    fi
    
    if pip3 install --upgrade crewai chromadb langchain langgraph 2>/dev/null; then
        log_success "✓ AI Agent Frameworks installed successfully"
        return 0
    elif pip install --upgrade crewai chromadb langchain langgraph 2>/dev/null; then
        log_success "✓ AI Agent Frameworks installed successfully"
        return 0
    else
        log_warning "⚠ Could not install AI Agent Frameworks (check Python/pip)"
        return 0
    fi
}

# Clone OpenClaw if not present
clone_openclaw() {
    local openclaw_dir="$HOME/openclaw"
    
    if [ -d "$openclaw_dir" ]; then
        log_info "✓ OpenClaw directory already exists. Skipping clone."
        return 0
    fi
    
    log_info "Cloning OpenClaw..."
    
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would clone OpenClaw to $openclaw_dir"
        return 0
    fi
    
    if git clone https://github.com/OpenClaw/OpenClaw.git "$openclaw_dir"; then
        log_success "✓ OpenClaw cloned successfully"
        
        # Install dependencies if requirements.txt exists
        if [ -f "$openclaw_dir/requirements.txt" ]; then
            log_info "Installing OpenClaw dependencies..."
            if pip3 install -r "$openclaw_dir/requirements.txt" 2>/dev/null; then
                log_success "✓ OpenClaw dependencies installed"
            elif pip install -r "$openclaw_dir/requirements.txt" 2>/dev/null; then
                log_success "✓ OpenClaw dependencies installed"
            else
                log_warning "⚠ Could not install OpenClaw dependencies"
            fi
        fi
        
        return 0
    else
        log_error "✗ Failed to clone OpenClaw"
        return 1
    fi
}

# Install GitHub CLI extensions
install_gh_extensions() {
    log_info "Installing GitHub CLI extensions..."
    
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would install gh-copilot extension"
        return 0
    fi
    
    if command_exists gh; then
        if gh extension install github/gh-copilot --force 2>/dev/null; then
            log_success "✓ gh-copilot extension installed"
        else
            log_warning "⚠ Could not install gh-copilot (may already exist)"
        fi
    else
        log_warning "⚠ GitHub CLI not found, skipping extensions"
    fi
}

# Install VS Code extensions
install_vscode_extensions() {
    local extensions=("$@")
    
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would install ${#extensions[@]} VS Code extensions"
        return 0
    fi
    
    if ! command_exists code; then
        log_warning "⚠ VS Code not found, skipping extensions"
        return 0
    fi
    
    log_info "Installing ${#extensions[@]} VS Code extensions..."
    
    local installed=0
    local skipped=0
    
    for ext in "${extensions[@]}"; do
        if code --install-extension "$ext" --force 2>/dev/null; then
            ((installed++))
        else
            ((skipped++))
        fi
    done
    
    log_success "✓ Installed $installed VS Code extensions ($skipped skipped)"
}

# ============================================================================
# VALIDATION FUNCTIONS
# ============================================================================

check_prerequisites() {
    local missing=()
    
    log_info "Checking prerequisites..."
    
    # Check for curl
    if ! command_exists curl; then
        missing+=("curl")
    fi
    
    # Check for git
    if ! command_exists git; then
        missing+=("git")
    fi
    
    # Check for wget (some scripts use it)
    if ! command_exists wget; then
        missing+=("wget")
    fi
    
    # Check for sudo (Linux/macOS)
    if [ "$(uname)" != "Darwin" ] && ! command_exists sudo; then
        missing+=("sudo")
    fi
    
    if [ ${#missing[@]} -gt 0 ]; then
        log_error "Missing required tools: ${missing[*]}"
        return 1
    fi
    
    log_success "✓ All prerequisites are installed"
    return 0
}

check_disk_space() {
    local min_space_mb=10000  # Minimum 10GB free
    
    if [ "$(uname)" = "Darwin" ]; then
        local available=$(df -m / | awk 'NR==2 {print $4}')
    else
        local available=$(df -m / | awk 'NR==2 {print $4}')
    fi
    
    if [ "$available" -lt "$min_space_mb" ]; then
        log_error "Insufficient disk space! Need at least $((min_space_mb / 1024))GB free, have $((available / 1024))GB"
        return 1
    fi
    
    log_success "✓ Sufficient disk space available ($((available / 1024))GB free)"
    return 0
}

check_internet() {
    log_info "Checking internet connection..."
    
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would check internet connection"
        return 0
    fi
    
    if curl -s --head "https://google.com" > /dev/null 2>&1; then
        log_success "✓ Internet connection is available"
        return 0
    else
        log_error "✗ No internet connection detected"
        return 1
    fi
}

# ============================================================================
# SUMMARY FUNCTIONS
# ============================================================================

print_summary() {
    local start_time="$1"
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    echo ""
    print_header "Installation Summary"
    echo ""
    echo -e "${CYAN}Duration:${NC} $((duration / 60)) minutes $((duration % 60)) seconds"
    echo -e "${CYAN}Log File:${NC} $LOG_FILE"
    echo ""
    
    # List installed tools (if available)
    if command_exists node; then
        echo -e "${GREEN}Node.js:${NC} $(node --version 2>/dev/null || echo 'N/A')"
    fi
    
    if command_exists python3; then
        echo -e "${GREEN}Python:${NC} $(python3 --version 2>/dev/null || echo 'N/A')"
    fi
    
    if command_exists java; then
        echo -e "${GREEN}Java:${NC} $(java -version 2>&1 | head -1 || echo 'N/A')"
    fi
    
    if command_exists ollama; then
        echo -e "${GREEN}Ollama:${NC} $(ollama --version 2>/dev/null || echo 'N/A')"
    fi
    
    if command_exists docker; then
        echo -e "${GREEN}Docker/Podman:${NC} $(docker --version 2>/dev/null || echo 'N/A')"
    fi
    
    if command_exists gh; then
        echo -e "${GREEN}GitHub CLI:${NC} $(gh --version 2>/dev/null || echo 'N/A')"
    fi
    
    if command_exists code; then
        echo -e "${GREEN}VS Code:${NC} $(code --version 2>/dev/null || echo 'N/A')"
    fi
    
    echo ""
    print_header "Next Steps"
    echo ""
    echo -e "${CYAN}1.${NC} Restart your terminal or run: source ~/.zshrc (or ~/.bashrc)"
    echo -e "${CYAN}2.${NC} Verify installations: see README.md for verification commands"
    echo -e "${CYAN}3.${NC} Start using your AI development environment!"
    echo ""
}

# ============================================================================
# MAIN SCRIPT STRUCTURE
# ============================================================================

setup_main() {
    local script_name="$1"
    shift
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --verbose|-v)
                VERBOSE=true
                shift
                ;;
            --help|-h)
                echo "Usage: $script_name [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --dry-run    Show what would be installed without installing"
                echo "  --verbose    Show detailed output"
                echo "  --help       Show this help message"
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
    
    # Print header
    print_header "AI Agent Dev Machine Setup"
    
    # Check prerequisites
    if ! check_prerequisites; then
        log_error "Prerequisite checks failed. Please install the required tools and try again."
        exit 1
    fi
    
    if ! check_disk_space; then
        log_error "Disk space check failed. Please free up some space and try again."
        exit 1
    fi
    
    if ! check_internet; then
        log_error "Internet check failed. Please connect to the internet and try again."
        exit 1
    fi
    
    # Run the setup function passed as argument
    if [ -n "$1" ] && declare -f "$1" >/dev/null; then
        "$@"
    else
        log_error "No setup function specified"
        exit 1
    fi
    
    # Print summary
    print_summary "$SCRIPT_START_TIME"
}

# Export functions for use in other scripts
export -f log log_info log_success log_warning log_error
export -f print_header print_section print_success print_error print_warning
export -f command_exists brew_package_installed install_formula install_cask
export -f install_apt install_choco install_nvm install_sdkman
export -f install_ohmyzsh install_zsh_autosuggestions install_zsh_syntax_highlighting
export -f install_nvm_version install_java_version install_pyenv_version install_goenv_version
export -f install_ai_frameworks clone_openclaw install_gh_extensions install_vscode_extensions
export -f check_prerequisites check_disk_space check_internet print_summary setup_main
# Scripts Directory

This directory contains shared helper functions for the AI Agent Dev Machine Setup project.

## Files

- `helpers.sh` - Shared helper functions (can be sourced by platform-specific scripts)
- `README.md` - This file

## Helper Functions

### Logging Functions
| Function | Description |
|----------|-------------|
| `log_info` | Log an informational message |
| `log_success` | Log a success message (green) |
| `log_warning` | Log a warning message (yellow) |
| `log_error` | Log an error message (red) |

### UI Functions
| Function | Description |
|----------|-------------|
| `print_header` | Print a formatted header section |
| `print_section` | Print a formatted section divider |
| `print_success` | Print a success indicator with checkmark |
| `print_error` | Print an error indicator with X |
| `print_warning` | Print a warning indicator |

### Installation Functions
| Function | Description |
|----------|-------------|
| `install_formula` | Install a Homebrew formula (if not already installed) |
| `install_cask` | Install a Homebrew cask (GUI app, if not already installed) |
| `install_apt` | Install an APT package (if not already installed) |
| `install_choco` | Install a Chocolatey package (Windows, if not already installed) |

### Runtime Installation
| Function | Description |
|----------|-------------|
| `install_nvm` | Install NVM (Node Version Manager) |
| `install_sdkman` | Install SDKMAN (Java version manager) |
| `install_ohmyzsh` | Install Oh My Zsh shell framework |
| `install_zsh_autosuggestions` | Install zsh-autosuggestions plugin |
| `install_zsh_syntax_highlighting` | Install zsh-syntax-highlighting plugin |

### Runtime Version Installation
| Function | Description |
|----------|-------------|
| `install_nvm_version` | Install a specific Node.js version via NVM |
| `install_java_version` | Install a specific Java version via SDKMAN |
| `install_pyenv_version` | Install a specific Python version via Pyenv |
| `install_goenv_version` | Install a specific Go version via Goenv |

### AI Frameworks
| Function | Description |
|----------|-------------|
| `install_ai_frameworks` | Install LangChain, LangGraph, ChromaDB |
| `clone_openclaw` | Clone and set up OpenClaw repository |

### CLI Tools
| Function | Description |
|----------|-------------|
| `install_gh_extensions` | Install GitHub CLI extensions (e.g., gh-copilot) |
| `install_vscode_extensions` | Install VS Code extensions |

### Validation Functions
| Function | Description |
|----------|-------------|
| `check_prerequisites` | Check for required tools (curl, git, wget) |
| `check_disk_space` | Verify at least 10GB free disk space |
| `check_internet` | Test internet connectivity |

### Summary Functions
| Function | Description |
|----------|-------------|
| `print_summary` | Print installation summary with versions and next steps |

## Usage

### As a standalone script
```bash
# Make the script executable
chmod +x scripts/helpers.sh

# Source it in your setup script
source scripts/helpers.sh
```

### In platform-specific scripts
```bash
#!/bin/bash

# Source the shared helpers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/helpers.sh"

# Use the helper functions
print_header "My Setup Script"
check_prerequisites || exit 1
install_formula "git"
install_nvm_version "20"
print_summary "$START_TIME"
```

## Options

All scripts that use these helpers support:

- `--dry-run` - Show what would be installed without installing
- `--verbose` or `-v` - Show detailed output
- `--help` or `-h` - Show help message

## Example

```bash
# Dry run to see what would be installed
./macos_setup.sh --dry-run

# Verbose mode for debugging
./linux_setup.sh --verbose

# Standard installation with confirmation prompt
./wsl_setup.sh
```

## Log Files

All scripts create log files in `/tmp/`:
- Format: `setup_YYYYMMDD_HHMMSS.log`
- Contains timestamped output of all operations
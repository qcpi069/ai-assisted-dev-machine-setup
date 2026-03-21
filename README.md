# AI Agent Dev Machine Setup

A comprehensive, multi-platform workspace designed to automate the setup and management of an AI-optimized development environment. This project streamlines the installation of open-source tools, local AI frameworks, and development runtimes across macOS, Linux, and Windows (WSL 2).

> [!IMPORTANT]
> **Intended for Fresh Installs:** These setup, update, and cleanup scripts are strictly designed for **fresh installations**. They follow an opinionated configuration and do not handle conflicts with existing packages, applications, or environments managed by other tools or manual installations outside the scope of this project. Use with caution on machines with pre-existing development setups.

## 🗺 Quick Navigation
- [🤖 Purpose & The Agent](#-purpose--the-agent)
- [📁 Project Structure](#-project-structure)
- [✅ Prerequisites](#-prerequisites)
- [🚀 Getting Started](#-getting-started)
- [🛠 Features & Included Tools](#-features--included-tools)
- [⚙️ Version Management](#️-version-management)
- [📏 Standards & Maintenance](#-standards--maintenance)
- [📄 License](#-license)

---

## 🤖 Purpose & The Agent
This repository is built for **AI-native development**. It doesn't just install standard compilers and editors; it prepares your machine for **AI Agents** (like OpenClaw, LangChain, LangGraph, and Cline) and **Local LLMs** (via LM Studio and Ollama).

### Why use this?
- **Standardization:** Ensure your development environment is consistent across different machines and OSs.
- **Local-First AI:** Optimized for offline-first AI workflows, reducing dependency on external APIs.
- **Clean & OSS:** Focuses strictly on Free/Open Source Software (OSS) to keep your machine lean and transparent.
- **Automation:** Provides "one-command" setup, update, and cleanup scripts for all platforms.

---

## 📁 Project Structure

- **`/macos`**: Scripts and guide for macOS (Homebrew + Zsh).
- **`/linux`**: Scripts and guide for Linux (optimized for Ubuntu/Debian using Homebrew + Apt/Snap).
- **`/windows`**: PowerShell scripts for Windows (Chocolatey) and Bash scripts for WSL 2 (Ubuntu).

---

## ✅ Prerequisites

Before running any setup script, make sure your machine meets the following requirements.

### 🍎 macOS
- macOS 12 (Monterey) or later
- **Xcode Command Line Tools:** `xcode-select --install`
- **Homebrew:** [brew.sh](https://brew.sh) — `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
- **Zsh** (default shell on macOS 10.15+): verify with `echo $SHELL`

### 🐧 Linux
- Ubuntu 22.04+ or Debian 11+ (other distros may work but are untested)
- `curl` and `git` installed: `sudo apt update && sudo apt install -y curl git`
- **Homebrew:** [brew.sh](https://brew.sh) — same install command as macOS

### 🪟 Windows & WSL 2
- Windows 10 (version 2004+) or Windows 11
- **WSL 2 enabled** — see the [Windows User Guide](./windows/WINDOWS_USER_GUIDE.md) for step-by-step instructions
- **Ubuntu** installed from the Microsoft Store (recommended: Ubuntu 22.04 LTS)
- Admin PowerShell access for the Windows setup script

---

## 🚀 Getting Started

Refer to the platform-specific instructions below or the detailed user guide within each folder.

### 🍎 macOS
Full guide: [`macos/MACOS_USER_GUIDE.md`](./macos/MACOS_USER_GUIDE.md)
```bash
./macos/macos_setup.sh
```

### 🐧 Linux
Full guide: [`linux/LINUX_USER_GUIDE.md`](./linux/LINUX_USER_GUIDE.md)
```bash
./linux/linux_setup.sh
```
*Optimized for Ubuntu/Debian. Uses Homebrew for CLI tools and Apt/Snap for system apps.*

### 🪟 Windows & WSL 2
Full guide: [`windows/WINDOWS_USER_GUIDE.md`](./windows/WINDOWS_USER_GUIDE.md)
1. **PowerShell (Admin):**
   ```powershell
   powershell ./windows/windows_setup.ps1
   ```
2. **WSL 2 (Ubuntu):**
   ```bash
   ./windows/wsl_setup.sh
   ```

### ✔️ Verifying Your Setup
After running the script for your platform, confirm the key tools are installed:
```bash
node -v          # Node.js (via NVM)
java -version    # Java (via SDKMAN)
python3 --version  # Python (via Pyenv)
# LM Studio: Preferred LLM host (Check Applications/Start Menu)
ollama --version # Ollama (secondary LLM runner)
docker --version # Podman (aliased as docker)
gh --version     # GitHub CLI
```

---

## 🛠 Features & Included Tools

### 🧠 AI & LLM Tools
- **LM Studio:** Preferred local LLM host with GUI and OpenAI-compatible API.
- **Ollama:** Secondary CLI-based LLM runner.
- **AnythingLLM:** Private "chat-with-your-files" interface.
- **Local Image Gen:** Tools like DiffusionBee and Upscayl.

### 🤖 Agent Frameworks
- **OpenClaw:** Personal AI assistant.
- **LangChain & LangGraph:** Build and orchestrate AI agent pipelines.
- **Cline & Cursor:** AI-powered coding and autonomous agents within your editor.

### 💻 Development Runtimes
- **Node.js:** Managed via NVM (v20/v22).
- **Java:** Managed via SDKMAN (v17/v21).
- **Python:** Managed via Pyenv (v3.12+).
- **Containers:** Podman (aliased to `docker`) for daemonless container management.

### 🧰 Power Tools
- **GitHub Copilot CLI:** AI assistance in the terminal via `gh copilot`.
- **Bruno:** Open-source API testing (Postman alternative).
- **Shell:** Zsh with Oh My Zsh.
- **Editors:** VS Code, Cursor, and Antigravity (AI-powered IDE).

---

## ⚙️ Version Management

This setup uses standard version managers to allow switching between different runtime versions.

### 🌐 Node.js (NVM)
- **Install latest LTS:** `nvm install --lts`
- **Switch version:** `nvm use 20` or `nvm use 22`
- **Set default:** `nvm alias default 20`
- **Check installed:** `nvm ls`

### ☕ Java (SDKMAN)
- **Install latest LTS (e.g., v21):** `sdk install java 21.0.2-tem`
- **Switch version:** `sdk use java 21.0.2-tem` or `sdk use java 17.0.10-tem`
- **Set default:** `sdk default java 21.0.2-tem`
- **Check installed:** `sdk list java` (look for the 'installed' tag)

### 🐍 Python (Pyenv)
- **Install latest version:** `pyenv install 3.13:latest`
- **Switch version:** `pyenv local 3.12.x` or `pyenv global 3.13.x`
- **Check installed:** `pyenv versions`

### 🐹 Go (Goenv)
- **Install specific version:** `goenv install 1.26.0`
- **Switch version:** `goenv local 1.25.0` or `goenv global 1.26.0`
- **Check installed:** `goenv versions`

---

## 📏 Standards & Maintenance

- **Update All:** Each platform has an `update_all.sh` script to refresh all tools and models.
- **Cleanup:** Reclaim disk space using the `cleanup.sh` scripts.
- **OSS Focus:** We prioritize open-source alternatives to keep your stack free and customizable.

---

## 📄 License
This project is open-source. See the individual scripts for specific tool licenses.

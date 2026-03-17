# macOS Setup User Guide

This guide covers prerequisites, setup, version management, and maintenance for your macOS AI development environment.

## 🗺 Quick Navigation
- [📋 Prerequisites](#-prerequisites)
- [🚀 Quick Start](#-quick-start)
- [✔️ Verifying Your Setup](#️-verifying-your-setup)
- [⚙️ Version Management](#️-version-management)
- [🐳 Container Management (Podman)](#-container-management-podman)
- [🛠 Installed Tools & Applications](#-installed-tools--applications)
- [🔄 Maintenance](#-maintenance)
- [🩺 Troubleshooting](#-troubleshooting)

---

## 📋 Prerequisites

Before running the setup script, ensure you have:

1. **macOS 12 (Monterey) or later**
2. **Xcode Command Line Tools:**
   ```bash
   xcode-select --install
   ```
3. **Homebrew** (macOS package manager):
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
4. **Zsh** — the default shell on macOS 10.15+. Verify with:
   ```bash
   echo $SHELL   # should output /bin/zsh
   ```

---

## 🚀 Quick Start

From the repo root, run:
```bash
./macos/macos_setup.sh
```

> **Note:** If you get a `permission denied` error, make the script executable first:
> ```bash
> chmod +x ./macos/macos_setup.sh
> ```

---

## ✔️ Verifying Your Setup

After the script completes, confirm key tools are installed:
```bash
node -v            # Node.js — expect v20.x or v22.x
java -version      # Java — expect 21.x or 17.x
python3 --version  # Python — expect 3.12+
ollama --version   # Ollama local LLM runner
docker --version   # Podman aliased as docker
gh --version       # GitHub CLI
code --version     # VS Code
```

---

## ⚙️ Version Management

### 🌐 Node.js (NVM)
- **Install a version:** `nvm install 22`
- **Switch version:** `nvm use 20` or `nvm use 22`
- **Set default:** `nvm alias default 22`
- **Check installed:** `nvm ls`

### ☕ Java (SDKMAN)
- **Install a version:** `sdk install java 21.0.2-tem`
- **Switch version:** `sdk use java 21.0.2-tem` or `sdk use java 17.0.10-tem`
- **Set default:** `sdk default java 21.0.2-tem`
- **Check installed:** `sdk list java` (look for the `installed` tag)

### 🐍 Python (Pyenv)
- **Install a version:** `pyenv install 3.13:latest`
- **Switch version (project):** `pyenv local 3.12.x`
- **Switch version (global):** `pyenv global 3.13.x`
- **Check installed:** `pyenv versions`

### 🐹 Go (Goenv)
- **Install a version:** `goenv install 1.22.0`
- **Switch version:** `goenv local 1.22.0` or `goenv global 1.22.0`
- **Check installed:** `goenv versions`

---

## 🐳 Container Management (Podman)

This setup uses **Podman** — a daemonless Docker-compatible container engine. The `docker` command is aliased to `podman`, so existing Docker workflows work without changes.

- **Run a container:** `docker run -d nginx`
- **List running containers:** `docker ps`
- **Multi-container apps:** use `podman-compose` (works like `docker-compose`)

---

## 🛠 Installed Tools & Applications

| Category | Tool |
|---|---|
| Package Manager | Homebrew |
| Shell | Zsh + Oh My Zsh |
| CLIs | Git, GitHub CLI (`gh`), NVM, SDKMAN, Pyenv, Goenv |
| Editors | VS Code, Cursor, Antigravity |
| Containers | Podman (aliased as `docker`), Podman Compose |
| Local AI | Ollama, AnythingLLM |
| API Testing | Bruno |
| Agent Frameworks | OpenClaw, LangChain, LangGraph, Cline |

---

## 🔄 Maintenance

- **Update all tools:** `./macos/macos_update_all.sh`
- **Clean up disk space:** `./macos/macos_cleanup.sh`

---

## 🩺 Troubleshooting

**`zsh: permission denied` when running the script**
```bash
chmod +x ./macos/macos_setup.sh
```

**`brew: command not found` after installing Homebrew**
Homebrew may not be on your PATH. Add it manually:
```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
source ~/.zprofile
```

**`nvm: command not found` in a new terminal**
NVM needs to be sourced. Add this to your `~/.zshrc`:
```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
```
Then run `source ~/.zshrc`.

**`sdk: command not found` after SDKMAN install**
```bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
```

**Ollama models are slow or crash**
Ollama runs best with 16GB+ RAM for larger models. Try a smaller model:
```bash
ollama pull llama3:8b
```

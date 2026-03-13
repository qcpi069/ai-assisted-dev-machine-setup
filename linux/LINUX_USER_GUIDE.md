# Linux Setup User Guide

This document explains how to set up and manage your development environment and AI tools on Linux (optimized for Ubuntu/Debian).

## 🚀 Quick Navigation
- [0. Prerequisites](#0-prerequisites)
- [✔️ Verifying Your Setup](#️-verifying-your-setup)
- [1. Shell & Terminals](#1-shell--terminals)
- [2. Managing Versions (The Switching Guide)](#2-managing-versions-the-switching-guide)
- [3. Docker & Containers (Podman)](#3-docker--containers-podman)
- [4. AI Agent Frameworks](#4-ai-agent-frameworks)
- [5. In-Editor Tools (VS Code Power-Ups & Cursor)](#5-in-editor-tools-vs-code-power-ups--cursor)
- [6. AI & LLM Tools (Ollama)](#6-ai--llm-tools-ollama)
- [7. Local AI Image Generation](#7-local-ai-image-generation)
- [8. Web Development (React & Angular)](#8-web-development-react--angular)
- [9. Power Tools (API, Web & AI Data)](#9-power-tools-api-web--ai-data)
- [10. Recreational & Media Tools](#10-recreational--media-tools)
- [11. Keeping Everything Up to Date](#11-keeping-everything-up-to-date)
- [12. Post-Installation Cleanup](#12-post-installation-cleanup)
- [13. Installed Tools & Applications](#13-installed-tools--applications)
- [14. Troubleshooting](#14-troubleshooting)

---

## 0. Prerequisites

Before running the setup script, ensure the following:

1. **Ubuntu 22.04+ or Debian 11+** (other distros may work but are untested)
2. **curl and git:**
   ```bash
   sudo apt update && sudo apt install -y curl git
   ```
3. **Homebrew** (used for CLI tool management):
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
   After install, add Homebrew to your PATH:
   ```bash
   echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
   source ~/.bashrc
   ```
4. Make the setup script executable:
   ```bash
   chmod +x ./linux/linux_setup.sh
   ```

Then run:
```bash
./linux/linux_setup.sh
```

---

## ✔️ Verifying Your Setup

After the script completes, confirm key tools are working:
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

## 1. Shell & Terminals
- **Shell:** Zsh (Oh My Zsh)
- **Terminal:** System default (Gnome Terminal, Terminator, etc.)

## 2. Managing Versions (The "Switching" Guide)

### Node.js (via NVM)
- **Switch:** `nvm use 20` or `nvm use 22`

### Java (via SDKMAN)
- **Switch:** `sdk use java 17.0.10-tem` or `sdk use java 21.0.2-tem`

### Python (via Pyenv)
- **Switch:** `pyenv local 3.12.2`

## 3. Docker & Containers (Podman)
`docker` commands are aliased to `podman`.
- **Start Container:** `docker run -d nginx`

## 4. AI Agent Frameworks
- **OpenClaw:** Personal assistant (lives in `~/openclaw`).
- **CrewAI:** Orchestrate groups of specialized agents.

## 5. In-Editor Tools (VS Code Power-Ups & Cursor)
- **Cline:** Autonomous AI Agent.
- **Cursor:** AI-powered editor (Fork of VS Code).
    - *Note:* Download the AppImage for Cursor manually if the setup didn't include it.

## 6. AI & LLM Tools (Ollama)
- **Update Binary:** `curl -fsSL https://ollama.com/install.sh | sh`
- **Update Models:** `ollama pull llama3`

## 7. Local AI Image Generation
- **Upscayl** (image upscaler): Install via Snap:
  ```bash
  sudo snap install upscayl
  ```
- **DiffusionBee alternative on Linux — InvokeAI:**
  ```bash
  pip install invokeai
  invokeai-web  # launches a local web UI
  ```
  > *Note:* DiffusionBee is macOS-only. InvokeAI is the recommended open-source alternative for local image generation on Linux.

## 8. Web Development (React & Angular)
- **React:** `pnpm create vite my-app --template react-ts`
- **Angular:** `ng new my-app`

## 9. Power Tools (API, Web & AI Data)
- **Bruno:** (Open Source) API testing tool.
- **AnythingLLM:** Private Chat-with-your-files.

## 10. Recreational & Media Tools
- **Strawberry:** (Open Source) Music player.
- **Steam:** Native Linux client available.

## 11. Keeping Everything Up to Date
To refresh your entire environment:
```bash
./linux_update_all.sh
```

## 12. Post-Installation Cleanup
To reclaim disk space:
```bash
./linux_cleanup.sh
```

## 13. Installed Tools & Applications

| Category | Tool |
|---|---|
| Package Managers | Homebrew (CLI), Apt (system packages) |
| Shell | Zsh + Oh My Zsh |
| CLIs | Git, GitHub CLI (`gh`), NVM, SDKMAN, Pyenv, Goenv |
| Editors | VS Code, Cursor |
| Containers | Podman (aliased as `docker`), Podman Compose |
| Local AI | Ollama, AnythingLLM |
| API Testing | Bruno |
| Agent Frameworks | OpenClaw (`~/openclaw`), CrewAI, Cline |
| Media | Strawberry music player, Steam |

---

## 14. Troubleshooting

**`permission denied` when running the script**
```bash
chmod +x ./linux/linux_setup.sh
```

**`brew: command not found` after installing Homebrew**
Add Homebrew to your PATH:
```bash
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
source ~/.bashrc
```

**`nvm: command not found` in a new terminal**
Add this to your `~/.bashrc` or `~/.zshrc`:
```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
```
Then run `source ~/.bashrc`.

**`sdk: command not found` after SDKMAN install**
```bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
```

**Cursor AppImage won't launch**
Make it executable first:
```bash
chmod +x cursor-*.AppImage
./cursor-*.AppImage --no-sandbox
```

**Ollama models are slow**
Ollama runs best with 16GB+ RAM for larger models. Try a smaller model:
```bash
ollama pull llama3:8b
```

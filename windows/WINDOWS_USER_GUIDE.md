# Windows & WSL 2 Setup User Guide

This guide covers prerequisites, setup, version management, and maintenance for your AI development environment on Windows (GUI) and WSL 2 (Ubuntu).

## 🗺 Quick Navigation
- [📋 Prerequisites](#-prerequisites)
- [🚀 Quick Start](#-quick-start)
- [✔️ Verifying Your Setup](#️-verifying-your-setup)
- [⚙️ Version Management (WSL 2)](#️-version-management-wsl-2)
- [🐳 Container Management](#-container-management)
- [🛠 Maintenance](#-maintenance)
- [🩺 Troubleshooting](#-troubleshooting)

---

## 📋 Prerequisites

### Step 1 — Enable WSL 2

If you haven't set up WSL 2 yet, follow these steps in an **Admin PowerShell**:

```powershell
# Enable WSL and the Virtual Machine Platform
wsl --install
```

This installs WSL 2 and Ubuntu by default. **Restart your machine** after this completes.

> If `wsl --install` doesn't work (older Windows 10), enable features manually:
> ```powershell
> dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
> dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
> wsl --set-default-version 2
> ```
> Then install **Ubuntu 22.04 LTS** from the [Microsoft Store](https://aka.ms/wslstore).

### Step 2 — Verify WSL 2 is Running
```powershell
wsl --list --verbose
# Ubuntu should show VERSION 2
```

### Step 3 — Requirements Checklist
- Windows 10 (version 2004, Build 19041+) or Windows 11
- Admin PowerShell access
- WSL 2 with Ubuntu 22.04 installed
- Internet connection for downloading tools

---

## 🚀 Quick Start

1. **PowerShell (Admin) — Windows tools:**
   ```powershell
   powershell ./windows/windows_setup.ps1
   ```
2. **Restart your machine.**
3. **WSL 2 Ubuntu terminal — Linux dev tools:**
   ```bash
   chmod +x ./windows/wsl_setup.sh
   ./windows/wsl_setup.sh
   ```

---

## ✔️ Verifying Your Setup

**In your WSL 2 terminal**, confirm key tools are installed:
```bash
node -v            # Node.js — expect v20.x or v22.x
java -version      # Java — expect 21.x or 17.x
python3 --version  # Python — expect 3.12+
ollama --version   # Ollama local LLM runner
docker --version   # Podman aliased as docker
gh --version       # GitHub CLI
```

**In PowerShell**, confirm Windows tools:
```powershell
choco --version    # Chocolatey package manager
code --version     # VS Code
```

---

## ⚙️ Version Management (WSL 2)

These tools are available within your WSL 2 Ubuntu environment.

### 🌐 Node.js (NVM)
- **Install a version:** `nvm install 22`
- **Switch version:** `nvm use 20` or `nvm use 22`
- **Set default:** `nvm alias default 22`
- **Check installed:** `nvm ls`

### ☕ Java (SDKMAN)
- **Install a version:** `sdk install java 21.0.2-tem`
- **Switch version:** `sdk use java 21.0.2-tem` or `sdk use java 17.0.10-tem`
- **Set default:** `sdk default java 21.0.2-tem`
- **Check installed:** `sdk list java`

### 🐍 Python (Pyenv)
- **Install a version:** `pyenv install 3.13:latest`
- **Switch version:** `pyenv local 3.12.x`
- **Check installed:** `pyenv versions`

---

## 🐳 Container Management

- **WSL 2:** Use `podman` and `podman-compose` — `docker` is aliased to `podman`
- **Windows GUI:** Use **Podman Desktop** to manage containers visually

---

## 🛠 Maintenance

- **Update Windows apps:** `choco upgrade all` (Admin PowerShell)
- **Update WSL Ubuntu packages:** `sudo apt update && sudo apt upgrade`

---

## 🩺 Troubleshooting

**`wsl --install` says WSL is already installed but Ubuntu isn't running**
```powershell
wsl --install -d Ubuntu-22.04
```

**`permission denied` when running `wsl_setup.sh`**
```bash
chmod +x ./windows/wsl_setup.sh
```

**`nvm: command not found` in a new WSL terminal**
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

**WSL 2 is very slow accessing Windows files**
Work inside the Linux filesystem (`~/`) instead of `/mnt/c/`. WSL 2 has near-native speed for Linux paths but is slow across the `/mnt/c` boundary.

**Chocolatey script blocked by execution policy**
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
```

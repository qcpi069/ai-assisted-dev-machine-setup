# Windows & WSL 2 Setup User Guide

This guide covers managing your AI development environment on Windows (GUI) and WSL 2 (Ubuntu).

## 🚀 Quick Start
1. Run `powershell ./windows_setup.ps1` in an Admin PowerShell.
2. Restart your machine.
3. Run `./wsl_setup.sh` inside your WSL 2 (Ubuntu) terminal.

## ⚙️ Version Management (WSL 2)

These tools are available within your WSL 2 Ubuntu environment.

### 🌐 Node.js (NVM)
- **Switch version:** `nvm use 20` or `nvm use 22`
- **Set default:** `nvm alias default 22`
- **Check installed:** `nvm ls`

### ☕ Java (SDKMAN)
- **Switch version:** `sdk use java 21.0.2-tem` or `sdk use java 17.0.10-tem`
- **Set default:** `sdk default java 21.0.2-tem`
- **Check installed:** `sdk list java`

### 🐍 Python (Pyenv)
- **Switch version:** `pyenv local 3.12.x`
- **Check installed:** `pyenv versions`

## 🛠 Maintenance
- **Update WSL:** Run `sudo apt update && sudo apt upgrade`
- **Update Windows Apps:** `choco upgrade all`

## 🐳 Container Management
- **Podman:** Use `podman` and `podman-compose` within WSL 2.
- **Podman Desktop:** Manage containers from the Windows GUI.

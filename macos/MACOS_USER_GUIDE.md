# macOS Setup User Guide

This guide provides details on maintaining and using your macOS AI development environment.

## 🚀 Quick Start
Run `./macos_setup.sh` to install everything.

## ⚙️ Version Management

### 🌐 Node.js (NVM)
- **Switch version:** `nvm use 20` or `nvm use 22`
- **Set default:** `nvm alias default 22`
- **Check installed:** `nvm ls`

### ☕ Java (SDKMAN)
- **Switch version:** `sdk use java 21.0.2-tem` or `sdk use java 17.0.10-tem`
- **Set default:** `sdk default java 21.0.2-tem`
- **Check installed:** `sdk list java` (look for the 'installed' tag)

## 🛠 Maintenance
- Update: `./macos_update_all.sh`
- Cleanup: `./macos_cleanup.sh`

## 🐳 Container Management
This setup uses **Podman**. 
- The `docker` command is aliased to `podman`.
- Use `podman-compose` for multi-container orchestration.

# GEMINI.md - Multi-Platform Workspace Context

This workspace provides automated setup and management scripts for macOS, Windows (WSL 2), and Linux.

## 📁 Structure
- `/macos`: Scripts and guide for macOS (Homebrew + Zsh).
- `/windows`: PowerShell (Chocolatey) and WSL 2 (Ubuntu) bash scripts.
- `/linux`: Scripts and guide for Linux (Homebrew + Apt/Snap).

## 🚀 Usage
Refer to the `USER_GUIDE.md` within each folder for platform-specific instructions.
- **macOS:** `./macos/macos_setup.sh`
- **Windows:** `powershell ./windows/windows_setup.ps1`
- **Linux:** `./linux/linux_setup.sh`

## 📏 Standards
- **Open Source:** Only include free/OSS tools.
- **Local AI:** Optimize for offline-first AI workflows (Ollama, LM Studio).
- **Clean:** Provide automated update and cleanup scripts for all platforms.

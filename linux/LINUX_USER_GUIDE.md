# Linux Setup User Guide

This document explains how to manage your development environment and AI tools on Linux (optimized for Ubuntu/Debian).

## 🚀 Quick Navigation
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
- **DiffusionBee:** Usually via AppImage or Flatpak on Linux.
- **Upscayl:** Available via Snap or Flatpak.

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
- **Package Manager:** Homebrew (CLI), Apt (System).
- **CLIs:** Git, GH CLI, NVM, SDKMAN, Pyenv.
- **Apps:** VS Code, Cursor, Podman, Ollama, Bruno, Strawberry, Steam.

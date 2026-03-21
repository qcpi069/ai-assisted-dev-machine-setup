# Copilot Instructions

## Commands

This repository does not have a conventional application build, test, or lint pipeline. The primary executable entrypoints are the platform setup and maintenance scripts:

- macOS setup: `./macos/macos_setup.sh`
- macOS update: `./macos/macos_update_all.sh`
- macOS cleanup: `./macos/macos_cleanup.sh`
- Linux setup: `./linux/linux_setup.sh`
- Linux update: `./linux/linux_update_all.sh`
- Linux cleanup: `./linux/linux_cleanup.sh`
- Windows setup: `powershell ./windows/windows_setup.ps1`
- WSL setup: `./windows/wsl_setup.sh`

When validating script changes, use targeted syntax checks on the script you changed instead of trying to run every platform flow:

- Single shell script: `bash -n ./macos/macos_setup.sh`
- Multiple shell scripts: `bash -n ./macos/macos_setup.sh ./linux/linux_setup.sh ./windows/wsl_setup.sh`

After changing a setup, update, or cleanup script, validate the closest real workflow by running only the relevant platform script and then checking the expected verification commands from the user guides, such as `node -v`, `java -version`, `python3 --version`, `ollama --version`, `docker --version`, and `gh --version`.

## High-level architecture

This repository is a multi-platform machine-bootstrap toolkit for AI-oriented development environments, not an application service. The top-level design is:

- `macos/`: macOS bootstrap plus maintenance scripts. Uses Homebrew for both formulae and casks.
- `linux/`: Linux bootstrap plus maintenance scripts. Combines Apt/Snap for system packages and apps with Homebrew for CLI tooling.
- `windows/`: a two-stage Windows flow. `windows_setup.ps1` installs Windows GUI tools with Chocolatey and enables WSL, then `wsl_setup.sh` provisions the Ubuntu-side developer environment.
- `scripts/helpers.sh`: shared logging, install, validation, and summary helpers intended for platform scripts.

The setup scripts all follow the same coarse workflow even though the implementations are duplicated in places:

1. Prepare the package manager and base dependencies.
2. Configure the shell environment (`zsh`, Oh My Zsh, autosuggestions, syntax highlighting).
3. Install runtimes with version managers:
   - Node via NVM
   - Java via SDKMAN
   - Python via Pyenv
   - Go via Goenv
4. Install AI tooling:
   - Python agent libraries such as `chromadb`, `langchain`, and `langgraph`
   - Clone OpenClaw into `~/openclaw`
5. Install developer CLI tools such as `gh`, `jq`, `fzf`, `ripgrep`, and Podman-related tools.
6. Install GUI/editor tools where relevant.
7. Print a verification-oriented summary.

Maintenance is split cleanly from bootstrap:

- `*_update_all.sh` scripts refresh package managers, runtimes, Python AI packages, GitHub CLI extensions, VS Code extensions, and Ollama models.
- `*_cleanup.sh` scripts reclaim space from Homebrew, npm, SDKMAN, pip, Go, and Podman caches.

## Key conventions

- Optimize for local-first AI workflows and workstation setup. Changes should fit the repo’s existing focus on local LLM tooling, agent frameworks, and developer environment automation.

- Treat each platform directory as a first-class product surface. If you change runtime versions, installed tool lists, or verification steps in one platform, check whether the same update should also be mirrored in the sibling platform scripts and user guides.

- Prefer the actual script behavior over the prose docs when they diverge. For example, `scripts/helpers.sh` and `scripts/README.md` describe reusable helpers plus `--dry-run` / `--verbose` / `--help`, but the main platform entrypoints mostly inline their own flow and generally do not invoke `setup_main`.

- Keep setup scripts idempotent and skip-aware. Existing scripts consistently check whether a package, directory, or tool already exists and log a skip instead of assuming a clean machine.

- Preserve the package-manager split by platform:
  - macOS: Homebrew formulae and casks
  - Linux: Apt/Snap for system packages and apps, Homebrew for many CLI tools
  - Windows: Chocolatey for Windows-side apps, Bash provisioning inside WSL for the Unix toolchain

- The Linux and WSL flows are intentionally very close. If you fix logic in one of `linux/linux_setup.sh`, `linux/linux_update_all.sh`, or `linux/linux_cleanup.sh`, inspect the corresponding `windows/wsl_setup.sh` or sibling maintenance script for the same issue.

- Python AI packages on Linux/WSL and in the update scripts are managed in `~/.ai-agent-venv`, and the scripts intentionally recreate that virtualenv when they detect stale `langchain-core` versions. Keep that conflict-avoidance behavior intact when editing those sections.

- OpenClaw is expected to live outside the repo at `~/openclaw`. Do not move it into the repository or rewrite that assumption without updating every platform flow and the docs.

- Maintenance scripts intentionally avoid sourcing SDKMAN init scripts in non-bash contexts; they prefer using `sdk` directly when it is already on `PATH`. Preserve that approach in update and cleanup scripts.

- The setup scripts are interactive and ask for confirmation with `Continue? (y/N)`. Keep that prompt unless the repository intentionally moves to non-interactive automation.

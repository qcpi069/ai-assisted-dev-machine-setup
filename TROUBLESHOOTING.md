# Troubleshooting Guide

This guide helps junior developers resolve common issues when running the setup scripts.

## Table of Contents
- [General Issues](#general-issues)
- [macOS-Specific Issues](#macos-specific-issues)
- [Linux/WSL-Specific Issues](#linuxwsl-specific-issues)
- [Common Errors and Solutions](#common-errors-and-solutions)

---

## General Issues

### 1. Script won't execute (Permission denied)

**Error:**
```bash
-bash: ./macos_setup.sh: Permission denied
```

**Solution:**
```bash
chmod +x macos_setup.sh  # or linux_setup.sh / wsl_setup.sh
```

### 2. Internet connection issues

**Symptoms:**
- Script hangs on "Checking internet connection..."
- Homebrew installation fails
- Git clone operations fail

**Solutions:**
1. Check your internet connection:
   ```bash
   ping google.com
   ```

2. If behind a corporate firewall, you may need to configure proxy:
   ```bash
   export http_proxy=http://your-proxy:port
   export https_proxy=https://your-proxy:port
   ```

### 3. Disk space issues

**Error:**
```
Insufficient disk space! Need at least 10GB free
```

**Solution:**
Run the cleanup script to free up space:
```bash
./macos_cleanup.sh  # or linux_cleanup.sh
```

Or manually clean:
```bash
# macOS/Linux
brew cleanup -s
npm cache clean --force
```

---

## macOS-Specific Issues

### 1. Homebrew installation fails

**Error:**
```
xcode-select: error: command line tools are missing
```

**Solution:**
Install Xcode Command Line Tools first:
```bash
xcode-select --install
```

Then retry the setup script.

### 2. Homebrew not in PATH after installation

**Error:**
```
command not found: brew
```

**Solution:**
Add Homebrew to your PATH:
```bash
# For Apple Silicon Macs (M1/M2/M3)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
eval "$(/opt/homebrew/bin/brew shellenv)"

# For Intel Macs
echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zshrc
eval "$(/usr/local/bin/brew shellenv)"
```

### 3. Oh My Zsh installation hangs

**Solution:**
Run the script with verbose output:
```bash
bash -x macos_setup.sh 2>&1 | tee setup.log
```

Or install Oh My Zsh manually:
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
```

### 4. VS Code command not found

**Error:**
```
command not found: code
```

**Solution:**
1. Open VS Code
2. Press `Cmd+Shift+P` (or `F1`)
3. Type "shell command"
4. Select "Shell Command: Install 'code' command in PATH"

---

## Linux/WSL-Specific Issues

### 1. apt-get update fails (GPG errors)

**Error:**
```
The following signatures were invalid: EXPKEYSIG ...
```

**Solution:**
```bash
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*
sudo apt-get update
```

### 2. Homebrew installation fails on Linux

**Error:**
```
E: Unable to locate package gcc
```

**Solution:**
Install build dependencies first:
```bash
sudo apt update
sudo apt install -y build-essential curl file git procps zsh
```

Then retry Homebrew installation:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

### 3. Podman not working (WSL)

**Error:**
```
Cannot connect to Podman socket
```

**Solution:**
Start the Podman service:
```bash
# For WSL 2
sudo systemctl start podman
sudo systemctl enable podman

# Or use rootless mode
podman system service --time=0 &
```

### 4. Python pip installation fails

**Error:**
```
ModuleNotFoundError: No module named 'pip'
```

**Solution:**
Install pip:
```bash
# Ubuntu/Debian
sudo apt install -y python3-pip

# Or use get-pip.py
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3 get-pip.py
```

---

## Common Errors and Solutions

### NVM Installation Issues

**Error:**
```
nvm: command not found
```

**Solution:**
```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
```

Add to your shell config:
```bash
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.zshrc
```

### SDKMAN Installation Issues

**Error:**
```
sdk: command not found
```

**Solution:**
```bash
export SDKMAN_DIR="$HOME/.sdkman"
[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ] && \. "$SDKMAN_DIR/bin/sdkman-init.sh"
```

### Git Clone Issues (SSL errors)

**Error:**
```
SSL certificate problem: unable to get local issuer certificate
```

**Solution:**
```bash
# Option 1: Configure git to use system CA bundle
git config --global http.sslVerify false

# Option 2: Update CA certificates (Linux)
sudo apt update && sudo apt install -y ca-certificates
```

### Ollama Installation Issues

**Error:**
```
Ollama service failed to start
```

**Solution:**
```bash
# Restart Ollama service
sudo systemctl restart ollama

# Or on macOS
ollama serve &
```

### VS Code Extension Installation Issues

**Error:**
```
Unable to install extension
```

**Solution:**
1. Check VS Code is running:
   ```bash
   code --version
   ```

2. Try installing manually in VS Code:
   - Open Extensions (`Cmd+Shift+X` on macOS, `Ctrl+Shift+X` on Windows/Linux)
   - Search for the extension ID
   - Click Install

---

## Debug Mode

Run scripts with verbose output to see what's happening:

```bash
# macOS/Linux
bash -x macos_setup.sh 2>&1 | tee setup.log

# Or with logging
export DEBUG=1
./macos_setup.sh
```

The log file will be saved to `/tmp/setup_YYYYMMDD_HHMMSS.log`.

---

## Getting Help

If you're still having issues:

1. **Check the log file** at `/tmp/setup_*.log`
2. **Verify prerequisites** are installed:
   ```bash
   which curl git
   ```
3. **Check disk space**:
   ```bash
   df -h /
   ```
4. **Verify internet connection**:
   ```bash
   curl https://google.com
   ```

---

## Prerequisites Checklist

Before running the setup script, ensure you have:

- [ ] Internet connection
- [ ] At least 10GB free disk space
- [ ] `curl` installed (`which curl`)
- [ ] `git` installed (`which git`)
- [ ] Sudo/administrator access (for system-wide installations)

---

## Quick Recovery Commands

If something goes wrong, you can:

```bash
# Clean up failed installations
brew cleanup -s
npm cache clean --force

# Re-run specific sections manually
# (see the script to identify which function failed)

# Check what's installed
brew list
npm list -g --depth=0

# Update everything
brew update && brew upgrade
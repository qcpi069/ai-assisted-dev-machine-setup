# windows_setup.ps1
$DRY_RUN = $false
foreach ($arg in $args) {
    if ($arg -eq "--dry-run" -or $arg -eq "-d") {
        $DRY_RUN = $true
    }
}

if ($DRY_RUN) {
    Write-Host "🔍 DRY-RUN MODE: No changes will be made." -ForegroundColor Cyan
} else {
    Write-Warning "IMPORTANT: This setup is intended for FRESH INSTALLATIONS."
    Write-Warning "It may conflict with existing packages (Chocolatey, Winget, Scoop),"
    Write-Warning "applications, or environments managed by other tools."
    Write-Host ""
    $confirmation = Read-Host "Continue? (y/N)"
    if ($confirmation -ne "y") {
        Write-Host "Setup cancelled by user."
        exit
    }
}

if (-not (Get-Command choco.exe -ErrorAction SilentlyContinue)) {
    if ($DRY_RUN) {
        Write-Host "[DRY-RUN] Would install Chocolatey"
    } else {
        Set-ExecutionPolicy Bypass -Scope Process -Force;
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    }
}

$apps = @("microsoft-windows-terminal", "visualstudiocode", "cursor", "antigravity", "ollama", "lm-studio", "anythingllm", "upscayl", "bruno", "strawberry", "steam-client", "epicgameslauncher", "davinci-resolve", "openjdk17", "openjdk21")

foreach ($app in $apps) {
    if ($DRY_RUN) {
        Write-Host "[DRY-RUN] Would install $app via Chocolatey"
    } else {
        choco install $app -y
    }
}

if ($DRY_RUN) {
    Write-Host "[DRY-RUN] Would enable WSL and VirtualMachinePlatform features"
} else {
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
}

if ($DRY_RUN) {
    Write-Host "✅ Windows GUI Setup Dry-Run Complete!" -ForegroundColor Green
} else {
    Write-Host "✅ Windows GUI Setup Complete! Restart and run wsl_setup.sh inside Ubuntu." -ForegroundColor Green
}

# windows_setup.ps1
if (-not (Get-Command choco.exe -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}
$apps = @("microsoft-windows-terminal", "visualstudiocode", "cursor", "ollama", "lm-studio", "anythingllm", "upscayl", "bruno", "strawberry", "steam-client", "epicgameslauncher", "davinci-resolve", "openjdk17", "openjdk21")
foreach ($app in $apps) { choco install $app -y }
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
Write-Host "✅ Windows GUI Setup Complete! Restart and run wsl_setup.sh inside Ubuntu."

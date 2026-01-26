# IDE Configs Installation Script for Windows
# Run: powershell -ExecutionPolicy Bypass -File install.ps1

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "=== IDE Configs Installer (Windows) ===" -ForegroundColor Cyan
Write-Host ""

# Claude Code
Write-Host "Installing Claude Code configs..." -ForegroundColor Yellow
$ClaudeDir = Join-Path $env:USERPROFILE ".claude"
$ClaudeScriptsDir = Join-Path $ClaudeDir "scripts"
New-Item -ItemType Directory -Force -Path $ClaudeDir | Out-Null
New-Item -ItemType Directory -Force -Path $ClaudeScriptsDir | Out-Null

Copy-Item "$ScriptDir\claude\CLAUDE.md" $ClaudeDir -Force
Copy-Item "$ScriptDir\claude\WORKING_PRINCIPLES.md" $ClaudeDir -Force
Copy-Item "$ScriptDir\claude\deslop.md" $ClaudeDir -Force
Copy-Item "$ScriptDir\claude\settings.json" $ClaudeDir -Force

# Copy Windows-specific settings if they exist
if (Test-Path "$ScriptDir\claude\settings-windows.json") {
    Copy-Item "$ScriptDir\claude\settings-windows.json" "$ClaudeDir\settings.json" -Force
}

# Copy scripts
if (Test-Path "$ScriptDir\scripts\cleanup-antigravity.ps1") {
    Copy-Item "$ScriptDir\scripts\cleanup-antigravity.ps1" $ClaudeScriptsDir -Force
}
Write-Host "  [OK] Claude Code configs installed" -ForegroundColor Green

# Gemini/Antigravity
Write-Host "Installing Gemini/Antigravity configs..." -ForegroundColor Yellow
$GeminiDir = Join-Path $env:USERPROFILE ".gemini"
New-Item -ItemType Directory -Force -Path $GeminiDir | Out-Null
Copy-Item "$ScriptDir\gemini\GEMINI.md" $GeminiDir -Force
Write-Host "  [OK] Gemini configs installed" -ForegroundColor Green

# VSCode
Write-Host "Installing VSCode global settings..." -ForegroundColor Yellow
$VSCodeSettings = Join-Path $env:APPDATA "Code\User\settings.json"
$VSCodeDir = Split-Path $VSCodeSettings

if (Test-Path $VSCodeSettings) {
    $BackupPath = "$VSCodeSettings.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
    Copy-Item $VSCodeSettings $BackupPath
    Write-Host "  [OK] Backed up existing settings.json to $BackupPath" -ForegroundColor Green
}

New-Item -ItemType Directory -Force -Path $VSCodeDir | Out-Null

# Use Windows-specific settings if available
if (Test-Path "$ScriptDir\vscode\global-settings-windows.json") {
    Copy-Item "$ScriptDir\vscode\global-settings-windows.json" $VSCodeSettings -Force
} else {
    Copy-Item "$ScriptDir\vscode\global-settings.json" $VSCodeSettings -Force
}
Write-Host "  [OK] VSCode settings installed" -ForegroundColor Green

# Clawd
Write-Host "Installing Clawd config..." -ForegroundColor Yellow
$ClawdDir = Join-Path $env:USERPROFILE ".clawd"
New-Item -ItemType Directory -Force -Path $ClawdDir | Out-Null
Copy-Item "$ScriptDir\clawd\config.json" $ClawdDir -Force
Write-Host "  [OK] Clawd config installed" -ForegroundColor Green

Write-Host ""
Write-Host "=== Installation Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Installed:" -ForegroundColor White
Write-Host "  - $ClaudeDir\CLAUDE.md"
Write-Host "  - $ClaudeDir\WORKING_PRINCIPLES.md"
Write-Host "  - $ClaudeDir\deslop.md"
Write-Host "  - $ClaudeDir\settings.json"
Write-Host "  - $GeminiDir\GEMINI.md"
Write-Host "  - $VSCodeSettings"
Write-Host "  - $ClawdDir\config.json"
Write-Host ""
Write-Host "To clean Antigravity cache: $ClaudeScriptsDir\cleanup-antigravity.ps1" -ForegroundColor Yellow
Write-Host ""

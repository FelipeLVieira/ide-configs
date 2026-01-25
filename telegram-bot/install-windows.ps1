# Claude Code Telegram Bot - Windows Installation Script
# Run: powershell -ExecutionPolicy Bypass -File install-windows.ps1

$ErrorActionPreference = "Stop"

Write-Host "=== Claude Code Telegram Bot Installer ===" -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

# Check Python
try {
    $pythonVersion = python --version 2>&1
    Write-Host "  [OK] Python: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "  [ERROR] Python not found. Install from https://python.org" -ForegroundColor Red
    exit 1
}

# Check Claude CLI
$claudePath = "$env:APPDATA\npm\claude.cmd"
if (Test-Path $claudePath) {
    Write-Host "  [OK] Claude CLI found at $claudePath" -ForegroundColor Green
} else {
    Write-Host "  [WARNING] Claude CLI not found at expected path" -ForegroundColor Yellow
    Write-Host "           Install with: npm install -g @anthropic-ai/claude-code" -ForegroundColor Yellow
}

# Check Git
try {
    $gitVersion = git --version 2>&1
    Write-Host "  [OK] Git: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "  [ERROR] Git not found. Install from https://git-scm.com" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Clone repository
$projectDir = "$env:USERPROFILE\projects\claude-code-telegram"
if (Test-Path $projectDir) {
    Write-Host "Project already exists at $projectDir" -ForegroundColor Yellow
    $response = Read-Host "Update it? (y/n)"
    if ($response -eq 'y') {
        Set-Location $projectDir
        git pull
    }
} else {
    Write-Host "Cloning repository..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\projects" | Out-Null
    Set-Location "$env:USERPROFILE\projects"
    git clone https://github.com/RichardAtCT/claude-code-telegram.git
}

Set-Location $projectDir

# Create virtual environment
Write-Host "Creating virtual environment..." -ForegroundColor Yellow
if (-not (Test-Path "venv")) {
    python -m venv venv
}
Write-Host "  [OK] Virtual environment created" -ForegroundColor Green

# Install dependencies
Write-Host "Installing dependencies..." -ForegroundColor Yellow
& ".\venv\Scripts\pip.exe" install -e . --quiet
Write-Host "  [OK] Dependencies installed" -ForegroundColor Green

# Create data directory
New-Item -ItemType Directory -Force -Path "data" | Out-Null

# Create .env if not exists
if (-not (Test-Path ".env")) {
    Copy-Item ".env.example" ".env"

    # Auto-configure Claude CLI path if found
    if (Test-Path $claudePath) {
        $envContent = Get-Content ".env" -Raw
        $envContent = $envContent -replace "CLAUDE_CLI_PATH=.*", "CLAUDE_CLI_PATH=$claudePath"
        $envContent = $envContent -replace "CLAUDE_BINARY_PATH=.*", "CLAUDE_BINARY_PATH=$claudePath"
        Set-Content ".env" $envContent
        Write-Host "  [OK] Claude CLI path auto-configured" -ForegroundColor Green
    }

    Write-Host ""
    Write-Host "=== Configuration Required ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Get a bot token from @BotFather on Telegram"
    Write-Host "2. Get your user ID from @userinfobot on Telegram"
    Write-Host "3. Edit .env file with your settings:"
    Write-Host ""
    Write-Host "   notepad $projectDir\.env" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "IMPORTANT: Set both CLAUDE_CLI_PATH and CLAUDE_BINARY_PATH to:" -ForegroundColor Yellow
    Write-Host "   $claudePath" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "  [OK] .env already exists" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== Installation Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "To start the bot:" -ForegroundColor White
Write-Host "  cd $projectDir" -ForegroundColor Yellow
Write-Host "  .\venv\Scripts\python.exe src\main.py" -ForegroundColor Yellow
Write-Host ""

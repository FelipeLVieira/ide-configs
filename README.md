# IDE Configs

Personal configuration files for Claude Code, Antigravity (Gemini/Grok), VSCode, and Clawd autonomous orchestration.

## Prerequisites Installation

### Claude Code

Official docs: https://code.claude.com/docs

**macOS / Linux:**
```bash
# Recommended
curl -fsSL https://claude.ai/install.sh | bash

# Or via Homebrew
brew install --cask claude-code
```

**Windows:**
```powershell
# PowerShell (Recommended)
irm https://claude.ai/install.ps1 | iex

# Or via WinGet
winget install Anthropic.ClaudeCode

# Or CMD
curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd
```

Requires a [Claude subscription](https://claude.com/pricing) (Pro, Max, Teams, or Enterprise).

---

### Gemini CLI (Antigravity)

Official docs: https://geminicli.com/docs

**macOS:**
```bash
# Homebrew (Recommended)
brew install gemini-cli

# Or via npm
npm install -g @google/gemini-cli

# Or run instantly without install
npx @google/gemini-cli
```

**Windows / Linux:**
```bash
# Requires Node.js 20+
npm install -g @google/gemini-cli

# Or run instantly
npx @google/gemini-cli
```

Free tier: 60 requests/min, 1,000 requests/day with Google account.

---

### VSCode

Official docs: https://code.visualstudio.com/docs/setup

**macOS:**
1. Download from https://code.visualstudio.com/download
2. Drag to Applications folder
3. Add to PATH: Cmd+Shift+P → "Shell Command: Install 'code' command"

**Windows:**
1. Download from https://code.visualstudio.com/download
2. Run installer (User or System)
3. Check "Add to PATH" during install

**Linux:**
```bash
# Debian/Ubuntu
sudo apt install code

# Or via Snap
sudo snap install code --classic
```

---

### Clawdbot

Official docs: https://docs.clawd.bot

**macOS / Linux:**
```bash
npm install -g clawdbot

# Start gateway
clawdbot gateway start
```

**Windows:**
```powershell
npm install -g clawdbot

# Start gateway
clawdbot gateway start
```

Requires Node.js 18+ and a Claude subscription.

---

## Structure

```
ide-configs/
├── claude/
│   ├── CLAUDE.md              # Global Claude Code instructions
│   ├── WORKING_PRINCIPLES.md  # Code quality principles
│   ├── deslop.md              # 50+ clean code principles for analysis
│   ├── settings.json          # Claude Code settings (macOS/Linux)
│   └── settings-windows.json  # Claude Code settings (Windows)
├── gemini/
│   └── GEMINI.md              # Antigravity/Grok global instructions
├── vscode/
│   ├── global-settings.json   # VSCode global settings (macOS/Linux)
│   └── global-settings-windows.json  # VSCode settings (Windows/.NET)
├── clawd/
│   └── config.json            # Clawd autonomous orchestration config
├── scripts/
│   ├── cleanup-antigravity.sh     # Cache cleanup (macOS/Linux)
│   └── cleanup-antigravity.ps1    # Cache cleanup (Windows)
├── project-templates/
│   ├── TEMPLATE-CLAUDE.md           # Generic project instructions template
│   ├── TEMPLATE-antigravityignore   # Antigravity ignore template
│   ├── TEMPLATE-vscode-settings.json # VSCode project settings template
│   ├── aphos-CLAUDE.md              # Game project example
│   ├── ez-crm-CLAUDE.md             # Web app example
│   ├── bmi-calculator-CLAUDE.md     # Mobile app example
│   ├── bills-tracker-CLAUDE.md      # Mobile app example
│   ├── screen-translator-CLAUDE.md  # Mobile app example
│   └── linklounge-CLAUDE.md         # SaaS example
├── install.sh                 # Installation script (macOS/Linux)
├── install.ps1                # Installation script (Windows)
└── README.md
```

## Quick Install

### macOS / Linux

```bash
# Clone the repo
git clone git@github.com:FelipeLVieira/ide-configs.git ~/repos/ide-configs

# Run installer
cd ~/repos/ide-configs && ./install.sh
```

### Windows

```powershell
# Clone the repo
git clone https://github.com/FelipeLVieira/ide-configs.git $env:USERPROFILE\repos\ide-configs

# Run installer (PowerShell)
cd $env:USERPROFILE\repos\ide-configs
powershell -ExecutionPolicy Bypass -File install.ps1
```

## Manual Installation

### macOS / Linux

#### Claude Code
```bash
cp claude/CLAUDE.md ~/.claude/
cp claude/WORKING_PRINCIPLES.md ~/.claude/
cp claude/deslop.md ~/.claude/
cp claude/settings.json ~/.claude/
```

#### Antigravity (Gemini/Grok)
```bash
mkdir -p ~/.gemini
cp gemini/GEMINI.md ~/.gemini/
```

#### VSCode
```bash
cp vscode/global-settings.json ~/Library/Application\ Support/Code/User/settings.json
```

#### Clawd
```bash
npm install -g clawd
mkdir -p ~/.clawd
cp clawd/config.json ~/.clawd/
```

#### Scripts
```bash
mkdir -p ~/.claude/scripts
cp scripts/cleanup-antigravity.sh ~/.claude/scripts/
chmod +x ~/.claude/scripts/cleanup-antigravity.sh
```

### Windows

#### Claude Code
```powershell
$ClaudeDir = "$env:USERPROFILE\.claude"
New-Item -ItemType Directory -Force -Path $ClaudeDir | Out-Null
Copy-Item claude\CLAUDE.md $ClaudeDir
Copy-Item claude\WORKING_PRINCIPLES.md $ClaudeDir
Copy-Item claude\deslop.md $ClaudeDir
Copy-Item claude\settings-windows.json "$ClaudeDir\settings.json"
```

#### Antigravity (Gemini/Grok)
```powershell
$GeminiDir = "$env:USERPROFILE\.gemini"
New-Item -ItemType Directory -Force -Path $GeminiDir | Out-Null
Copy-Item gemini\GEMINI.md $GeminiDir
```

#### VSCode
```powershell
$VSCodeSettings = "$env:APPDATA\Code\User\settings.json"
Copy-Item vscode\global-settings-windows.json $VSCodeSettings
```

#### Clawd
```powershell
npm install -g clawd
$ClawdDir = "$env:USERPROFILE\.clawd"
New-Item -ItemType Directory -Force -Path $ClawdDir | Out-Null
Copy-Item clawd\config.json $ClawdDir
```

#### Scripts
```powershell
$ScriptsDir = "$env:USERPROFILE\.claude\scripts"
New-Item -ItemType Directory -Force -Path $ScriptsDir | Out-Null
Copy-Item scripts\cleanup-antigravity.ps1 $ScriptsDir
```

## Features

### Claude Code Instructions
- Meta-cognitive protocol (personas, confidence, self-challenge)
- Development preferences for web/mobile/game
- Memory leak prevention guidelines
- Deslop code quality analysis (50+ principles)
- Clawd autonomous orchestration triggers

### Antigravity Rules
- Build & server management
- Testing & verification
- Code quality & review
- Git workflow
- Memory management
- Deslop principles (synced with Claude)

### Clawd Configuration
Pre-configured projects:
- **aphos** - Channel-based social RPG
- **shitcoin-bot** - Polymarket trading bot
- **ez-crm** - Legal case management
- **bmi-calculator** - Health tracking app
- **bills-tracker** - Subscription tracker
- **screen-translator** - OCR translation app
- **linklounge** - Link-in-bio platform

### Cleanup Script
Clears Antigravity cache when IDE is slow:

**macOS / Linux:**
```bash
~/.claude/scripts/cleanup-antigravity.sh
```

**Windows (PowerShell):**
```powershell
& "$env:USERPROFILE\.claude\scripts\cleanup-antigravity.ps1"
```

## Using Clawd

Ask Claude to run tasks autonomously:
- "Run clawd to [task]"
- "Use clawd for [task]"
- "Run perpetually and keep improving"

Commands:
```bash
clawd                          # Interactive mode
clawd --non-interactive "task" # Single task
clawd --perpetual "task"       # Continuous improvement
```

## Project Templates

Templates for setting up new projects:

### For a new project:
```bash
# Copy templates to your project
cp project-templates/TEMPLATE-CLAUDE.md ~/repos/my-project/CLAUDE.md
cp project-templates/TEMPLATE-antigravityignore ~/repos/my-project/.antigravityignore
cp project-templates/TEMPLATE-vscode-settings.json ~/repos/my-project/.vscode/settings.json

# Edit CLAUDE.md with your project specifics
```

### Example project configs:
- `aphos-CLAUDE.md` - MMORPG game (Next.js + Colyseus + Capacitor)
- `ez-crm-CLAUDE.md` - Legal case management (Next.js + Supabase)
- `bmi-calculator-CLAUDE.md` - Health app (Expo + RevenueCat + AdMob)
- `bills-tracker-CLAUDE.md` - Subscription tracker (Expo + SQLite + RevenueCat)
- `screen-translator-CLAUDE.md` - OCR translation (React Native + ML Kit + RevenueCat)
- `linklounge-CLAUDE.md` - Link-in-bio platform (Next.js + Stripe + Redis)
- `shitcoin-bot-CLAUDE.md` - Polymarket trading bot (Python + Kelly Criterion)
- `clawd-monitor-CLAUDE.md` - Bot monitoring dashboard (Next.js + SWR)

## Syncing

The CLAUDE.md and GEMINI.md files are kept in sync. When updating one, update the other:
- Antigravity rules are identical in both
- Deslop principles are in both
- Clawd triggers are in both

## License

Personal configuration - use at your own discretion.

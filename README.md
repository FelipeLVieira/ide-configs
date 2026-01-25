# IDE Configs

Personal configuration files for Claude Code, Antigravity (Gemini/Grok), VSCode, and Clawd autonomous orchestration.

## Structure

```
ide-configs/
├── claude/
│   ├── CLAUDE.md              # Global Claude Code instructions
│   ├── WORKING_PRINCIPLES.md  # Code quality principles
│   ├── deslop.md              # 50+ clean code principles for analysis
│   └── settings.json          # Claude Code settings (hooks, permissions)
├── gemini/
│   └── GEMINI.md              # Antigravity/Grok global instructions
├── vscode/
│   └── global-settings.json   # VSCode global settings
├── clawd/
│   └── config.json            # Clawd autonomous orchestration config
├── scripts/
│   └── cleanup-antigravity.sh # Cache cleanup script
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
├── install.sh                 # Installation script
└── README.md
```

## Quick Install

```bash
# Clone the repo
git clone git@github.com:FelipeLVieira/ide-configs.git ~/repos/ide-configs

# Run installer
cd ~/repos/ide-configs && ./install.sh
```

## Manual Installation

### Claude Code
```bash
cp claude/CLAUDE.md ~/.claude/
cp claude/WORKING_PRINCIPLES.md ~/.claude/
cp claude/deslop.md ~/.claude/
cp claude/settings.json ~/.claude/
```

### Antigravity (Gemini/Grok)
```bash
mkdir -p ~/.gemini
cp gemini/GEMINI.md ~/.gemini/
```

### VSCode
```bash
cp vscode/global-settings.json ~/Library/Application\ Support/Code/User/settings.json
```

### Clawd
```bash
# Install Clawd first
npm install -g clawd

# Copy config
mkdir -p ~/.clawd
cp clawd/config.json ~/.clawd/
```

### Scripts
```bash
mkdir -p ~/.claude/scripts
cp scripts/cleanup-antigravity.sh ~/.claude/scripts/
chmod +x ~/.claude/scripts/cleanup-antigravity.sh
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
```bash
~/.claude/scripts/cleanup-antigravity.sh
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

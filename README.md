# IDE Configs

Personal configuration files for Claude Code, Cursor, VSCode, Clawdbot, and Mac Mini bot factory.

## 🚀 Quick Start

```bash
# Clone
git clone git@github.com:FelipeLVieira/ide-configs.git ~/repos/ide-configs
cd ~/repos/ide-configs

# Install (macOS/Linux)
./install.sh

# Sync to Mac Mini
./mac-mini/sync-to-mini.sh
```

## 📁 Repository Structure

```
ide-configs/
├── 🤖 clawdbot/              # Clawdbot Bot Factory (NEW!)
│   ├── PERSISTENT-BOTS.md    # 9-bot architecture & management
│   ├── CREDIT-OPTIMIZATION.md # API credit savings (90% reduction)
│   ├── SCRIPTS-REFERENCE.md  # Mac Mini scripts docs
│   ├── MONITOR-INTEGRATION.md # Dashboard setup
│   ├── PREREQUISITES.md      # System requirements
│   └── README.md             # Clawdbot overview
│
├── 🧠 clawd/                 # Clawdbot workspace files
│   ├── AGENTS.md             # Agent behavior rules
│   ├── SOUL.md               # Personality & tone
│   ├── USER.md               # Human profile
│   ├── IDENTITY.md           # Bot identity
│   ├── HEARTBEAT.md          # Periodic check tasks
│   ├── adapter.js            # Multi-account failover
│   ├── scripts/              # Auto-resume, shutdown scripts
│   └── docs/ARCHITECTURE.md  # Multi-account rate limit docs
│
├── 💻 claude/                # Claude Code CLI configs
│   ├── CLAUDE.md             # Per-project template
│   ├── CLAUDE-global.md      # Global settings
│   └── settings.json         # Hooks (ESLint, Prettier)
│
├── 🔌 mcp/                   # MCP Server configs
│   ├── claude-code-mcps.json
│   ├── cursor-mcps.json
│   └── vscode-mcps.json
│
├── 🖥️ mac-mini/              # Mac Mini server setup
│   ├── README.md             # Setup guide
│   ├── PERSISTENCE.md        # Bot persistence
│   ├── launchagents/         # LaunchAgent plists
│   └── scripts/              # Startup scripts
│
├── 📝 project-templates/     # Per-project CLAUDE.md
├── 🍺 homebrew/              # Brewfiles
├── ⚙️ vscode/                # VSCode settings
├── 🔧 git/                   # Git configs
└── 🔐 ssh/                   # SSH configs
```

## 🤖 Clawdbot Bot Factory

The Mac Mini runs 9 persistent AI bots 24/7:

| Bot | Project | Purpose |
|-----|---------|---------|
| bot-ez-crm | EZ-CRM | Next.js/Supabase CRM |
| bot-linklounge | LinkLounge | Linktree competitor |
| bot-aphos | Aphos | MMORPG (Next.js + Three.js) |
| bot-game-assets | Game Assets | Asset generation tool |
| bot-ios-bmi | BMI Calculator | iOS app |
| bot-ios-bills | Bills Tracker | iOS app |
| bot-ios-translator | Screen Translator | iOS app |
| bot-clawd-monitor | Dashboard | Bot monitoring UI |
| bot-shitcoin-brain | Trading Research | Strategy analysis |

### Key Features
- **10-minute cycles** for dev bots (90% API savings)
- **Multi-account failover** on rate limits
- **Simulator coordination** for iOS bots
- **Browser lock** to prevent conflicts
- **Research-first** approach (Grok/X/Reddit before Claude)

### Quick Commands
```bash
# Check all bots
~/clawd/scripts/manage-bots.sh status

# Restart all
~/clawd/scripts/manage-bots.sh restart

# View bot logs
tmux attach -t bot-<name>
```

📖 See [clawdbot/PERSISTENT-BOTS.md](clawdbot/PERSISTENT-BOTS.md) for full docs.

## 💰 Credit Optimization

Strategies that reduced API usage by ~90%:

| Strategy | Savings |
|----------|---------|
| 10-min pause (was 60s) | ~90% |
| Multi-account failover | No downtime on 429 |
| Grok/X research first | Variable |
| Browser task skipping | Avoids failures |

📖 See [clawdbot/CREDIT-OPTIMIZATION.md](clawdbot/CREDIT-OPTIMIZATION.md)

## 🖥️ Mac Mini Architecture

```
┌─────────────────────────────────────────┐
│           MAC MINI BOT FACTORY          │
├─────────────────────────────────────────┤
│  Clawdbot Gateway (port 18789)          │
│  ├── 9 Persistent Bots (tmux)           │
│  ├── Python Trading Bot                 │
│  └── clawd-monitor Dashboard (:9009)    │
├─────────────────────────────────────────┤
│  Scripts: ~/clawd/scripts/              │
│  Memory: ~/clawd/memory/                │
│  Repos: ~/repos/                        │
└─────────────────────────────────────────┘
```

## 📦 Installation

### macOS/Linux
```bash
./install.sh
```

Creates symlinks for:
- `~/.claude/CLAUDE.md` → Global Claude settings
- `~/.claude/settings.json` → Claude hooks
- `~/.gitconfig` → Git config
- `~/.ssh/config` → SSH config

### Windows
```powershell
.\install.ps1
```

### Homebrew Packages
```bash
# MacBook
brew bundle --file=homebrew/Brewfile-macbook

# Mac Mini
brew bundle --file=homebrew/Brewfile-macmini
```

## 🔧 Configuration Files

### Claude Code
| File | Purpose |
|------|---------|
| `claude/CLAUDE.md` | Per-project rules template |
| `claude/CLAUDE-global.md` | Global ~/.claude/CLAUDE.md |
| `claude/settings.json` | Pre-commit hooks |
| `claude/deslop.md` | Anti-slop writing guide |

### Clawdbot Workspace
| File | Purpose |
|------|---------|
| `clawd/AGENTS.md` | Bot behavior & memory rules |
| `clawd/SOUL.md` | Personality & tone |
| `clawd/USER.md` | Human profile |
| `clawd/HEARTBEAT.md` | Periodic check tasks |
| `clawd/adapter.js` | Multi-account rate limit adapter |

### MCP Servers
| File | IDEs |
|------|------|
| `mcp/claude-code-mcps.json` | Claude Code |
| `mcp/cursor-mcps.json` | Cursor |
| `mcp/vscode-mcps.json` | VSCode |

## 🔄 Syncing

### MacBook → Mac Mini
```bash
./mac-mini/sync-to-mini.sh
```

### Pull latest on both
```bash
# MacBook
cd ~/repos/ide-configs && git pull

# Mac Mini (via SSH)
ssh mac-mini 'cd ~/repos/ide-configs && git pull'
```

## 📚 Documentation Index

### Clawdbot
- [PERSISTENT-BOTS.md](clawdbot/PERSISTENT-BOTS.md) - Bot architecture & management
- [CREDIT-OPTIMIZATION.md](clawdbot/CREDIT-OPTIMIZATION.md) - API savings strategies
- [SCRIPTS-REFERENCE.md](clawdbot/SCRIPTS-REFERENCE.md) - Script documentation
- [MONITOR-INTEGRATION.md](clawdbot/MONITOR-INTEGRATION.md) - Dashboard setup
- [ARCHITECTURE.md](clawd/docs/ARCHITECTURE.md) - Multi-account failover

### Mac Mini
- [mac-mini/README.md](mac-mini/README.md) - Server setup guide
- [mac-mini/PERSISTENCE.md](mac-mini/PERSISTENCE.md) - Bot persistence strategy

### Claude Code
- [claude/WORKING_PRINCIPLES.md](claude/WORKING_PRINCIPLES.md) - Dev principles
- [claude/deslop.md](claude/deslop.md) - Writing quality guide

## 🏷️ Project Templates

Pre-configured CLAUDE.md for each project:

| Template | Project |
|----------|---------|
| `game-project-CLAUDE.md` | Aphos MMORPG |
| `crm-app-CLAUDE.md` | EZ-CRM |
| `links-app-CLAUDE.md` | LinkLounge |
| `health-app-CLAUDE.md` | BMI Calculator |
| `finance-app-CLAUDE.md` | Bills Tracker |
| `translator-app-CLAUDE.md` | Screen Translator |
| `trading-bot-CLAUDE.md` | Shitcoin Bot |
| `clawd-monitor-CLAUDE.md` | Bot Dashboard |

## 📄 License

Personal configuration files. Feel free to use as inspiration for your own setup.

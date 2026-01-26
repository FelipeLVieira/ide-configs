# IDE Configs

Personal configuration files for Claude Code, Cursor, VSCode, Gemini/Antigravity, Clawdbot, and Mac Mini server setup.

## Repository Structure

```
ide-configs/
├── claude/                    # Claude Code CLI configs
│   ├── CLAUDE.md             # Per-project template
│   ├── CLAUDE-global.md      # Global ~/.claude/CLAUDE.md
│   ├── WORKING_PRINCIPLES.md # Development principles
│   ├── deslop.md             # Anti-slop writing guide
│   ├── settings.json         # Claude Code hooks (ESLint, Prettier, etc.)
│   └── settings-windows.json # Windows variant
├── clawd/                    # Clawdbot workspace files
│   ├── AGENTS.md             # Agent behavior rules
│   ├── SOUL.md               # Personality & tone
│   ├── USER.md               # Human profile
│   ├── IDENTITY.md           # Bot identity
│   ├── HEARTBEAT.md          # Periodic check tasks
│   ├── BOOTSTRAP.md          # First-run onboarding
│   ├── TOOLS.md              # Tool-specific notes
│   ├── OPTIMIZATION_RULES.md # Token optimization
│   ├── clawdbot.template.json # Gateway config template
│   └── scripts/              # Auto-resume, shutdown scripts
├── mcp/                      # MCP Server configs (all IDEs)
│   ├── README.md             # MCP inventory & sync status
│   ├── claude-code-mcps.json # Claude Code MCP template
│   ├── cursor-mcps.json      # Cursor MCP template
│   └── vscode-mcps.json      # VSCode MCP template
├── vscode/                   # VSCode configs
│   ├── global-settings.json  # User settings (macOS)
│   ├── global-settings-windows.json
│   ├── keybindings.json      # Custom keybindings
│   └── extensions.txt        # Installed extensions list
├── homebrew/                 # Homebrew package lists
│   ├── Brewfile-macbook      # MacBook formulae & casks
│   └── Brewfile-macmini      # Mac Mini formulae & casks
├── git/                      # Git configs
│   ├── gitconfig.template    # ~/.gitconfig template
│   └── gitignore_global      # Global gitignore
├── ssh/                      # SSH configs
│   └── config.template       # SSH config for both machines
├── mac-mini/                 # Mac Mini server setup
│   ├── README.md             # Full setup guide & architecture
│   ├── PERSISTENCE.md        # Bot persistence strategy
│   ├── sync-to-mini.sh       # One-command config sync
│   ├── launchagents/         # All 5 LaunchAgent plists
│   │   ├── com.clawdbot.gateway.plist
│   │   ├── com.clawdbot.aphos.plist
│   │   ├── com.clawdbot.shitcoin-bot.plist
│   │   ├── com.clawdbot.failover.plist
│   │   └── com.clawdbot.node.plist
│   └── scripts/              # Startup scripts
│       ├── start-aphos.sh
│       ├── start-shitcoin-bot.sh
│       └── failover.sh
├── gemini/                   # Gemini/Antigravity configs
│   └── GEMINI.md
├── project-templates/        # Per-project CLAUDE.md templates
│   ├── TEMPLATE-CLAUDE.md
│   ├── aphos-CLAUDE.md
│   ├── bills-tracker-CLAUDE.md
│   ├── bmi-calculator-CLAUDE.md
│   ├── clawd-monitor-CLAUDE.md
│   ├── ez-crm-CLAUDE.md
│   ├── linklounge-CLAUDE.md
│   ├── screen-translator-CLAUDE.md
│   └── shitcoin-bot-CLAUDE.md
├── scripts/                  # Utility scripts
│   ├── cleanup-antigravity.sh
│   └── cleanup-antigravity.ps1
├── clawdbot/                 # Clawdbot setup docs
│   ├── README.md
│   └── clawdbot-watchdog.ps1
├── install.sh                # macOS/Linux setup script
└── install.ps1               # Windows setup script
```

## Quick Setup

### New Mac
```bash
git clone git@github.com:FelipeLVieira/ide-configs.git ~/repos/ide-configs
cd ~/repos/ide-configs
./install.sh
```

### Sync to Mac Mini
```bash
./mac-mini/sync-to-mini.sh
```

### Restore Homebrew packages
```bash
brew bundle --file=homebrew/Brewfile-macbook
# or on Mac Mini:
brew bundle --file=homebrew/Brewfile-macmini
```

## Machines

| Machine | Role | Status |
|---------|------|--------|
| MacBook Pro (M3 Max) | Primary development + Clawdbot gateway | Active |
| Mac Mini (M4) | Always-on server + failover | Active |

## MCP Servers (synced across both machines)

| Server | Supabase | Sequential Thinking | Vercel | Stripe | BrowserMCP | Playwright |
|--------|----------|-------------------|--------|--------|------------|------------|
| Claude Code | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Cursor | ✅ | ✅ | ✅ | ✅ | ✅ | — |
| VSCode | ✅ | ✅ | ✅ | ✅ | — | ✅ |

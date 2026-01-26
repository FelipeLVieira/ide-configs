# Mac Mini Server Setup

This document describes the setup for the Mac Mini as a dedicated server for running clawdbot agents 24/7.

## Server Details

| Property | Value |
|----------|-------|
| Hostname | `felipes-mac-mini.local` |
| Username | `felipemacmini` |
| macOS | Tahoe 26.2 |
| SSH | Key-based (passwordless) |
| Sudo | Passwordless enabled |

## Quick SSH Access

```bash
ssh felipemacmini@felipes-mac-mini.local
```

## Architecture

| Machine | Role | Telegram |
|---------|------|----------|
| **MacBook** | Controller (gateway + Telegram) | Enabled |
| **Mac Mini** | Worker (task execution) | Disabled |

The MacBook handles all Telegram communication (screenshots, interactive control). Mac Mini executes tasks via SSH from MacBook.

## Installed Tools

| Tool | Version | Path |
|------|---------|------|
| Homebrew | 4.3.0+ | /opt/homebrew/bin/brew |
| Node.js | v25.4.0 | /opt/homebrew/bin/node |
| npm | 11.7.0 | /opt/homebrew/bin/npm |
| pnpm | latest | /opt/homebrew/bin/pnpm |
| Git | 2.52.0 | /opt/homebrew/bin/git |
| gh | latest | /opt/homebrew/bin/gh |
| Claude Code | 2.1.19 | /opt/homebrew/bin/claude |
| Clawdbot | 2026.1.24-3 | /opt/homebrew/bin/clawdbot |
| tmux | 3.6a | /opt/homebrew/bin/tmux |
| mas | 5.0.2 | /opt/homebrew/bin/mas |

## Installed Applications

| App | Purpose |
|-----|---------|
| Visual Studio Code | Code editing |
| Google Chrome | Web testing |
| CleanMyMac 5 | System maintenance |
| Xcode 26.2 | iOS/macOS development |
| Antigravity | Gemini CLI IDE |

## Configuration

### Energy Settings (Always-On)
```bash
sudo pmset -a displaysleep 0 sleep 0 disksleep 0 womp 1 autorestart 1
```
- Display sleep: Disabled
- System sleep: Disabled
- Disk sleep: Disabled
- Wake on network: Enabled
- Auto-restart after power failure: Enabled

### SSH Keys
- MacBook Pro → Mac Mini: `~/.ssh/id_ed25519` (passwordless SSH)
- Mac Mini → GitHub: `~/.ssh/id_ed25519` (added to GitHub account)

### Clawdbot Config
Location: `~/.clawdbot/clawdbot.json`

**Important**: Telegram is DISABLED on Mac Mini to avoid conflicts with MacBook gateway.

```json
{
  "agents": {
    "defaults": {
      "maxConcurrent": 2,
      "subagents": { "maxConcurrent": 2 }
    },
    "list": [
      { "id": "main" },
      { "id": "shitcoin-bot", "workspace": "/Users/felipemacmini/repos/shitcoin-bot" },
      { "id": "aphos", "workspace": "/Users/felipemacmini/repos/aphos" }
    ]
  },
  "channels": {},
  "gateway": {
    "mode": "local"
  },
  "plugins": {
    "entries": {
      "telegram": { "enabled": false }
    }
  }
}
```

## Directory Structure

```
/Users/felipemacmini/
├── repos/                    # All project repositories
│   ├── aphos/
│   ├── shitcoin-bot/
│   ├── linklounge/
│   ├── ez-crm/
│   └── ...
├── clawd/                    # Clawdbot workspace
├── .clawdbot/
│   ├── clawdbot.json        # Main config
│   ├── agents/              # Agent sessions
│   ├── subagents/           # Subagent data
│   ├── logs/                # Gateway logs
│   └── scripts/             # Auto-resume scripts
├── .claude/                  # Claude Code config
├── .gemini/                  # Gemini/Antigravity config
└── Library/LaunchAgents/     # Auto-start services
```

## Managing Clawdbot

### Start Gateway
```bash
ssh felipemacmini@felipes-mac-mini.local 'eval "$(/opt/homebrew/bin/brew shellenv)" && clawdbot gateway start'
```

### Stop Gateway
```bash
ssh felipemacmini@felipes-mac-mini.local 'pkill -f clawdbot-gateway'
```

### Check Status
```bash
ssh felipemacmini@felipes-mac-mini.local 'ps aux | grep clawdbot-gateway'
```

### View Logs
```bash
ssh felipemacmini@felipes-mac-mini.local 'tail -f ~/.clawdbot/logs/gateway.log'
```

### Run in tmux (Persistent Session)
```bash
ssh felipemacmini@felipes-mac-mini.local 'tmux new -d -s clawdbot "eval \"\$(/opt/homebrew/bin/brew shellenv)\" && clawdbot gateway start"'
```

Attach to session:
```bash
ssh -t felipemacmini@felipes-mac-mini.local 'tmux attach -t clawdbot'
```

## Running Tasks on Mac Mini

From MacBook, run commands on Mac Mini via SSH:

```bash
# Run npm test on a project
ssh felipemacmini@felipes-mac-mini.local 'cd ~/repos/aphos && eval "$(/opt/homebrew/bin/brew shellenv)" && pnpm test'

# Run build
ssh felipemacmini@felipes-mac-mini.local 'cd ~/repos/aphos && eval "$(/opt/homebrew/bin/brew shellenv)" && pnpm build'

# Check process
ssh felipemacmini@felipes-mac-mini.local 'ps aux | grep node'
```

When using clawdbot on MacBook, ask it to SSH to Mac Mini for task execution.

## Syncing from MacBook

### Sync Repos
```bash
rsync -avz --exclude 'node_modules' --exclude '.next' --exclude 'dist' ~/repos/ felipemacmini@felipes-mac-mini.local:~/repos/
```

### Sync Clawdbot State
```bash
rsync -avz ~/.clawdbot/agents/ felipemacmini@felipes-mac-mini.local:~/.clawdbot/agents/
rsync -avz ~/.clawdbot/subagents/ felipemacmini@felipes-mac-mini.local:~/.clawdbot/subagents/
```

### Sync Config
```bash
scp ~/.clawdbot/clawdbot.json felipemacmini@felipes-mac-mini.local:~/.clawdbot/
```

## Troubleshooting

### SSH Connection Failed
```bash
# Check if Mac Mini is awake
ping felipes-mac-mini.local

# If on Thunderbolt, check bridge
ifconfig bridge0
```

### Tools Not Found
```bash
# Ensure brew is in PATH
ssh felipemacmini@felipes-mac-mini.local 'eval "$(/opt/homebrew/bin/brew shellenv)" && node --version'
```

### Gateway Not Starting
```bash
# Check for port conflicts
ssh felipemacmini@felipes-mac-mini.local 'lsof -i :18789'

# Check logs
ssh felipemacmini@felipes-mac-mini.local 'cat ~/.clawdbot/logs/gateway.err.log'

# Check gateway status
ssh felipemacmini@felipes-mac-mini.local 'eval "$(/opt/homebrew/bin/brew shellenv)" && clawdbot gateway status'
```

### Telegram Conflict (HTTP 429 / getUpdates conflict)
**Symptom**: "Telegram getUpdates conflict; retrying" in logs

**Cause**: Both MacBook and Mac Mini gateways are polling the same Telegram bot token.

**Fix**: Only ONE gateway should have Telegram enabled. Recommended setup:
- MacBook: Telegram enabled (controller)
- Mac Mini: Telegram disabled (worker)

```bash
# On Mac Mini - disable Telegram in config
# Set "plugins.entries.telegram.enabled": false
ssh felipemacmini@felipes-mac-mini.local 'eval "$(/opt/homebrew/bin/brew shellenv)" && clawdbot gateway restart'
```

### Gateway LAN Binding
If you need MacBook to connect to Mac Mini gateway (advanced):

1. Add auth token to gateway config:
```json
"gateway": {
  "mode": "local",
  "bind": "lan",
  "auth": { "token": "your-secret-token" }
}
```

2. LAN binding requires an auth token for security.

### Clawdbot Doctor
Run diagnostics:
```bash
ssh felipemacmini@felipes-mac-mini.local 'eval "$(/opt/homebrew/bin/brew shellenv)" && clawdbot doctor'
```

## Initial Setup (Reference)

If setting up a new Mac Mini, run:
```bash
# From MacBook Pro
scp /tmp/mac-mini-setup.sh felipemacmini@NEW_MAC_MINI:~/
ssh felipemacmini@NEW_MAC_MINI 'chmod +x ~/mac-mini-setup.sh && ~/mac-mini-setup.sh'
```

Or follow the steps in the main `clawd/README.md`.

## Security Notes

- Passwordless sudo is enabled for convenience - consider restricting for production
- SSH key is the only authentication method (password disabled for SSH)
- Telegram bot token is stored in clawdbot.json - don't commit to public repos
- Mac Mini password: Stored in `~/repos/.env` on MacBook (MAC_MINI_PW)

# Clawdbot Gateway Setup

Clawdbot Gateway is a unified multi-agent orchestrator for Claude Code. It provides:
- **Unified session** across VS Code, terminal, Telegram, and other channels
- **Multi-agent orchestration** - spawn and coordinate sub-agents
- **Inter-bot communication** - agents can message each other
- **Centralized management** - one gateway controls all agents

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    CLAWDBOT GATEWAY                         │
│                   (Main Orchestrator)                       │
├─────────────────────────────────────────────────────────────┤
│  Main Session (telegram:main)                               │
│  └── Orchestrator Bot (monitors swarm)                      │
│  └── Sub-Agents:                                            │
│      ├── project-a (development)                            │
│      ├── project-b (testing)                                │
│      ├── research-agent (research tasks)                    │
│      └── ... (spawn as needed)                              │
└─────────────────────────────────────────────────────────────┘
```

### How It Works

1. **Gateway** runs as the central orchestrator
2. **Main session** connects to Telegram (or other channels)
3. **Sub-agents** are spawned for specific tasks
4. Agents communicate via:
   - `sessions_list` - See all active sessions
   - `sessions_send` - Message other bots by label
   - `sessions_history` - Read conversation history
   - `sessions_spawn` - Create sub-agents

### Directory Structure

```
~/clawd/                          # Main workspace
├── AGENTS.md                     # Bot rules & guidelines
├── SOUL.md                       # Bot personality
├── USER.md                       # User info
├── TOOLS.md                      # Tool notes
├── HEARTBEAT.md                  # Periodic check tasks
├── MEMORY.md                     # Long-term memory
├── memory/                       # Daily session notes
│   └── YYYY-MM-DD.md
└── docs/
    └── ARCHITECTURE.md           # Architecture docs

~/.clawdbot/                      # Clawdbot state
├── clawdbot.json                 # Gateway config
├── agents/
│   └── main/
│       ├── agent/
│       │   └── auth-profiles.json
│       └── sessions/             # Session transcripts
└── logs/
    └── gateway.log
```

## Prerequisites

- Node.js 18+
- Claude Code CLI installed and authenticated (`claude` command works)
- Telegram account (for Telegram channel)

## Quick Setup

### 1. Install Clawdbot

```bash
npm install -g clawdbot
```

### 2. Run Setup Wizard

```bash
clawdbot setup
```

This creates `~/.clawdbot/clawdbot.json` with default configuration.

### 3. Create Telegram Bot

1. Open Telegram and message [@BotFather](https://t.me/BotFather)
2. Send `/newbot`
3. Follow prompts to name your bot (e.g., "Clawdbot Master")
4. Save the bot token (looks like `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`)

### 4. Configure Telegram

```bash
# Set your bot token
clawdbot config set channels.telegram.botToken "YOUR_BOT_TOKEN_HERE"

# Enable Telegram
clawdbot config set channels.telegram.enabled true

# Set DM policy (pairing = requires pairing code)
clawdbot config set channels.telegram.dmPolicy pairing

# Set gateway mode
clawdbot config set gateway.mode local
```

### 5. Set Up Workspace

```bash
# Create workspace directory
mkdir -p ~/clawd/memory

# Copy workspace files from ide-configs
cp ide-configs/clawd/*.md ~/clawd/
```

### 6. Start the Gateway

```bash
clawdbot gateway
```

You should see:
```
[telegram] [default] starting provider (@your_bot_username)
[gateway] listening on ws://127.0.0.1:18789
```

### 7. Test It

Message your bot on Telegram with `/start`

## Configuration Reference

Configuration file: `~/.clawdbot/clawdbot.json`

### Full Example Configuration

```json
{
  "agents": {
    "defaults": {
      "workspace": "~/clawd",
      "maxConcurrent": 4,
      "subagents": {
        "maxConcurrent": 8
      }
    }
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "botToken": "YOUR_BOT_TOKEN_HERE",
      "dmPolicy": "pairing",
      "groupPolicy": "allowlist",
      "streamMode": "partial"
    }
  },
  "gateway": {
    "mode": "local"
  },
  "plugins": {
    "entries": {
      "telegram": {
        "enabled": true
      }
    }
  }
}
```

### Configuration Options

| Key | Description | Values |
|-----|-------------|--------|
| `agents.defaults.workspace` | Default workspace directory | Path |
| `agents.defaults.maxConcurrent` | Max concurrent agents | Number |
| `channels.telegram.enabled` | Enable Telegram channel | `true` / `false` |
| `channels.telegram.botToken` | Bot token from BotFather | String |
| `channels.telegram.dmPolicy` | How to handle DMs | `pairing`, `open`, `allowlist` |
| `channels.telegram.groupPolicy` | How to handle groups | `allowlist`, `open` |
| `channels.telegram.streamMode` | Response streaming | `partial`, `full`, `none` |
| `gateway.mode` | Gateway operation mode | `local`, `cloud` |

### DM Policies

- **pairing**: User must enter a pairing code (most secure)
- **open**: Anyone can message the bot (not recommended)
- **allowlist**: Only specific users can message

## Multi-Agent Orchestration

### Spawning Sub-Agents

The orchestrator (main session) can spawn sub-agents for specific tasks:

```
You: spawn a new agent to work on the API refactor
Bot: [spawns "api-refactor" agent]
```

### Agent Communication

Agents can communicate with each other:

```bash
# List all active sessions
sessions_list

# Send message to another agent
sessions_send api-refactor "What's the status of the auth endpoints?"

# Read another agent's history
sessions_history api-refactor
```

### Orchestrator Responsibilities

The main orchestrator bot:
- Monitors all agents for timeouts
- Resolves port conflicts
- Cleans up resources (browser tabs, processes)
- Reports status to you via Telegram

## Running as a Service

### Windows

**Option 1: Install as service (requires Admin)**
```powershell
# Run PowerShell as Administrator
clawdbot gateway install
```

**Option 2: Scheduled Task**
```powershell
$action = New-ScheduledTaskAction -Execute "clawdbot" -Argument "gateway"
$trigger = New-ScheduledTaskTrigger -AtLogon
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Limited
Register-ScheduledTask -TaskName "Clawdbot Gateway" -Action $action -Trigger $trigger -Principal $principal
```

### macOS (launchd)

Create `~/Library/LaunchAgents/com.clawdbot.gateway.plist`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.clawdbot.gateway</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/clawdbot</string>
        <string>gateway</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
```

Load it:
```bash
launchctl load ~/Library/LaunchAgents/com.clawdbot.gateway.plist
```

### Linux (systemd)

Create `~/.config/systemd/user/clawdbot.service`:
```ini
[Unit]
Description=Clawdbot Gateway
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/clawdbot gateway
Restart=always
RestartSec=10

[Install]
WantedBy=default.target
```

Enable it:
```bash
systemctl --user enable clawdbot
systemctl --user start clawdbot
```

## Troubleshooting

### Gateway won't start

```bash
clawdbot doctor
clawdbot doctor --fix
```

### Token expiring

If you see "expiring (Xh)" in doctor output:
```bash
claude setup-token
```

### Telegram not connecting

1. Verify bot token is correct
2. Check if another instance is running
3. Ensure `channels.telegram.enabled` is `true`

### Check gateway status

```bash
clawdbot status
```

### View logs

**Windows:**
```powershell
type \tmp\clawdbot\clawdbot-*.log
```

**macOS / Linux:**
```bash
cat /tmp/clawdbot/clawdbot-*.log
```

### Bot not responding

```bash
clawdbot sessions list
clawdbot sessions send <label> "ping"
```

### Port conflicts

```bash
# Check what's using the port
lsof -i :18789

# Kill the process
kill $(lsof -t -i :18789)
```

## Commands Reference

| Command | Description |
|---------|-------------|
| `clawdbot setup` | Run initial setup wizard |
| `clawdbot gateway` | Start gateway in foreground |
| `clawdbot gateway install` | Install as system service |
| `clawdbot doctor` | Check configuration health |
| `clawdbot doctor --fix` | Auto-fix configuration issues |
| `clawdbot config set KEY VALUE` | Set configuration value |
| `clawdbot config get KEY` | Get configuration value |
| `clawdbot status` | Check gateway status |
| `clawdbot sessions list` | List all active sessions |
| `clawdbot sessions send LABEL MSG` | Send message to agent |

## Security Notes

- **Bot Token**: Keep your bot token secret
- **DM Policy**: Use `pairing` for personal bots
- **Group Policy**: Use `allowlist` to control which groups can use the bot
- **Telegram Encryption**: Bot messages are not end-to-end encrypted

## Upgrading

```bash
npm update -g clawdbot
clawdbot doctor --fix
```

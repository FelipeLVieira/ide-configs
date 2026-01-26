# Clawdbot Workspace Configuration

These files configure the Clawdbot AI assistant workspace.

## Files

| File | Purpose |
|------|---------|
| `AGENTS.md` | Global instructions for all agents (bots) |
| `SOUL.md` | Personality and behavior guidelines |
| `TOOLS.md` | Local tool configurations (Grok, cameras, SSH, etc.) |
| `USER.md` | Information about the human user |
| `IDENTITY.md` | Bot identity (name, emoji, avatar) |
| `HEARTBEAT.md` | Periodic task checklist |
| `BOOTSTRAP.md` | First-run setup instructions |
| `OPTIMIZATION_RULES.md` | Performance and cost optimization rules |
| `config.json` | Clawd orchestrator configuration |
| `clawdbot.template.json` | Clawdbot gateway config template |

## Quick Start (New Machine)

### 1. Install Clawdbot
```bash
npm install -g clawdbot
clawdbot setup
clawdbot onboard
```

### 2. Apply Rate Limit Config
Copy the template to prevent HTTP 429 errors:
```bash
cp ~/repos/ide-configs/clawd/clawdbot.template.json ~/.clawdbot/clawdbot.json
# Then run: clawdbot configure
```

Or manually add to `~/.clawdbot/clawdbot.json`:
```json
"agents": {
  "defaults": {
    "maxConcurrent": 2,
    "subagents": {
      "maxConcurrent": 2
    }
  }
}
```

### 3. Install Auto-Resume Scripts
```bash
# Create scripts directory
mkdir -p ~/.clawdbot/scripts

# Copy scripts
cp ~/repos/ide-configs/clawd/scripts/auto-resume.sh ~/.clawdbot/scripts/
cp ~/repos/ide-configs/clawd/scripts/save-state-on-shutdown.sh ~/.clawdbot/scripts/
chmod +x ~/.clawdbot/scripts/*.sh

# Install LaunchAgent (runs on login)
cp ~/repos/ide-configs/clawd/scripts/com.clawdbot.auto-resume.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.clawdbot.auto-resume.plist

# Add shutdown hook to shell
echo 'trap "~/.clawdbot/scripts/save-state-on-shutdown.sh" EXIT' >> ~/.zshrc
```

### 4. Copy Workspace Files
```bash
mkdir -p ~/clawd
cp ~/repos/ide-configs/clawd/*.md ~/clawd/
```

## Rate Limit Prevention

**Important:** The default Clawdbot settings allow too many concurrent API calls, causing HTTP 429 rate limit errors from Anthropic.

| Setting | Default | Recommended | Effect |
|---------|---------|-------------|--------|
| `maxConcurrent` | 4 | 2 | Max agents running at once |
| `subagents.maxConcurrent` | 8 | 2 | Max subagents per agent |

Default allows up to **32 concurrent API calls**. Recommended limits to **4 concurrent calls**.

## Auto-Resume on Restart

Clawdbot doesn't automatically resume tasks after a sudden shutdown. The auto-resume scripts track and notify about incomplete work.

**What the scripts do:**
- `auto-resume.sh check` - Detects incomplete tasks, sends Telegram notification
- `auto-resume.sh save` - Saves state before shutdown
- LaunchAgent runs check automatically on login

**What gets saved (always persisted):**
- Conversation history (`.jsonl` files)
- Session metadata (`sessions.json`)
- Completed task results (`runs.json`)

**What is NOT auto-resumed (lost on crash):**
- Mid-API-call responses
- In-progress tool executions
- Active subagent tasks

**Manual commands:**
```bash
# Check for incomplete tasks
~/.clawdbot/scripts/auto-resume.sh check

# Manually save state
~/.clawdbot/scripts/auto-resume.sh save
```

## Key Features

- **Multi-agent orchestration** - Main bot can spawn sub-agents for tasks
- **Grok integration** - Use X/Grok for research to save Claude credits
- **Memory system** - Daily notes + long-term memory (not in repo)
- **Heartbeat system** - Proactive background tasks

## Telegram Setup

1. Create a bot via @BotFather on Telegram
2. Get the bot token
3. Add to `~/.clawdbot/clawdbot.json`:
```json
"channels": {
  "telegram": {
    "botToken": "YOUR_BOT_TOKEN",
    "dmPolicy": "pairing"
  }
}
```
4. Restart clawdbot gateway

## Usage

Copy these files to your Clawdbot workspace (`~/clawd/` or similar).

## Multi-Machine Setup (MacBook + Mac Mini)

When running clawdbot on multiple machines:

| Machine | Role | Telegram |
|---------|------|----------|
| MacBook | Controller | Enabled |
| Mac Mini | Worker | **Disabled** |

**Important**: Only ONE gateway should have Telegram enabled. If both poll the same bot token, you'll see "Telegram getUpdates conflict" errors.

### MacBook Config (Controller)
```json
{
  "gateway": { "mode": "local" },
  "plugins": {
    "entries": {
      "telegram": { "enabled": true }
    }
  }
}
```

### Mac Mini Config (Worker)
```json
{
  "gateway": { "mode": "local" },
  "channels": {},
  "plugins": {
    "entries": {
      "telegram": { "enabled": false }
    }
  }
}
```

For Mac Mini details, see [mac-mini/README.md](../mac-mini/README.md).

## Troubleshooting

### HTTP 429 Rate Limit Errors
Reduce concurrent agents in `~/.clawdbot/clawdbot.json`:
```json
"maxConcurrent": 2,
"subagents": { "maxConcurrent": 2 }
```

### Gateway Not Responding
```bash
# Check if running
ps aux | grep clawdbot-gateway

# Restart
pkill -f clawdbot-gateway
clawdbot doctor
```

### Telegram Not Receiving Messages
```bash
# Check logs
tail -100 ~/.clawdbot/logs/gateway.log | grep telegram

# Verify bot token
clawdbot doctor
```

### Telegram getUpdates Conflict
**Symptom**: Logs show "Telegram getUpdates conflict; retrying"

**Cause**: Multiple gateways polling the same Telegram bot token.

**Fix**: Disable Telegram on all gateways except one:
```bash
# On the worker machine, set in clawdbot.json:
"plugins": {
  "entries": {
    "telegram": { "enabled": false }
  }
}

# Then restart
clawdbot gateway restart
```

## Security Notes

- `MEMORY.md` and `memory/` folder contain personal data - DO NOT commit
- `USER.md` may contain personal info - customize or exclude as needed
- Never commit bot tokens or API keys

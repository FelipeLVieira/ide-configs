# Clawdbot Gateway Setup

Clawdbot Gateway provides a unified multi-channel interface for Claude Code, allowing you to access the **same Claude session** from VS Code, terminal, Telegram, WhatsApp, and other channels simultaneously.

## Why Clawdbot vs claude-code-telegram?

| Feature | Clawdbot Gateway | claude-code-telegram |
|---------|------------------|---------------------|
| Session sharing | Same session across all channels | Separate Claude processes |
| Multi-channel | Telegram, WhatsApp, Web, API | Telegram only |
| Architecture | Unified gateway | Python bot |
| Setup | npm install + config | Python venv + config |
| Memory | Shared context everywhere | Per-channel context |

**Recommendation**: Use Clawdbot Gateway for the best experience (same session in VS Code and mobile).

## Prerequisites

- Node.js 18+
- Claude Code CLI installed and authenticated (`claude` command works)
- Telegram account (for Telegram channel)

## Quick Setup

### 1. Install Clawdbot

**Windows:**
```powershell
npm install -g clawdbot
```

**macOS / Linux:**
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
3. Follow prompts to name your bot (e.g., "My Claude Bot")
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

### 5. Start the Gateway

```bash
clawdbot gateway
```

You should see:
```
[telegram] [default] starting provider (@your_bot_username)
[gateway] listening on ws://127.0.0.1:18789
```

### 6. Test It

Message your bot on Telegram with `/start`

## Configuration Reference

Configuration file: `~/.clawdbot/clawdbot.json`

### Full Example Configuration

```json
{
  "agents": {
    "defaults": {
      "workspace": "C:\\Users\\YourName\\clawd",
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

## Running as a Service

### Windows (Scheduled Task)

**Option 1: Install as service (requires Admin)**
```powershell
# Run PowerShell as Administrator
clawdbot gateway install
```

**Option 2: Manual scheduled task**
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

**Check doctor:**
```bash
clawdbot doctor
```

**Common fixes:**
```bash
clawdbot doctor --fix
```

### Config validation errors

**"Unrecognized keys" error:**
```bash
clawdbot doctor --fix
```
This removes invalid keys from your config.

### Token expiring

If you see "expiring (Xh)" in doctor output:
```bash
claude setup-token
```

### Telegram not connecting

1. Verify bot token is correct
2. Check if another instance is running
3. Ensure `channels.telegram.enabled` is `true`
4. Check firewall isn't blocking outbound connections

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

## Security Notes

- **Bot Token**: Keep your bot token secret. Anyone with it can impersonate your bot.
- **DM Policy**: Use `pairing` for personal bots to prevent unauthorized access.
- **Group Policy**: Use `allowlist` to control which groups can use the bot.
- **Telegram Encryption**: Telegram bots don't have end-to-end encryption. Don't share secrets through the bot.

## Upgrading

```bash
npm update -g clawdbot
```

After upgrading, run doctor to check for config changes:
```bash
clawdbot doctor --fix
```

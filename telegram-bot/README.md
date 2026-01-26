# Claude Code Telegram Bot (Python)

> **Note**: This is the **Python-based** Telegram bot that spawns separate Claude CLI processes.
> For a **unified session** experience (same Claude session in VS Code and Telegram), use [Clawdbot Gateway](../clawdbot/README.md) instead.

## Comparison

| Feature | claude-code-telegram (this) | Clawdbot Gateway |
|---------|----------------------------|------------------|
| Session | Separate processes per chat | Unified session |
| Setup | Python venv | npm install |
| Customization | Full source code access | Config-based |
| Channels | Telegram only | Multi-channel |

**When to use this bot:**
- You want full control over the source code
- You need custom modifications
- You prefer Python over Node.js

**When to use Clawdbot Gateway:**
- You want the same session in VS Code and Telegram
- You want multi-channel support (WhatsApp, Web, etc.)
- You prefer simpler setup

---

## Prerequisites

- Python 3.9+
- Claude Code CLI installed and authenticated (`claude` command works)
- Telegram account

## Setup

### 1. Create Telegram Bot

1. Open Telegram and message [@BotFather](https://t.me/BotFather)
2. Send `/newbot`
3. Follow prompts to name your bot
4. Save the bot token (looks like `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`)

### 2. Get Your Telegram User ID

Message [@userinfobot](https://t.me/userinfobot) on Telegram - it will reply with your numeric user ID.

### 3. Clone and Configure

**Windows (PowerShell):**
```powershell
cd $env:USERPROFILE\projects
git clone https://github.com/RichardAtCT/claude-code-telegram.git
cd claude-code-telegram

# Create virtual environment
python -m venv venv
.\venv\Scripts\pip.exe install -e .

# Create data directory
New-Item -ItemType Directory -Force -Path data

# Copy and edit config
Copy-Item .env.example .env
notepad .env
```

**macOS / Linux:**
```bash
cd ~/projects
git clone https://github.com/RichardAtCT/claude-code-telegram.git
cd claude-code-telegram

# Create virtual environment
python3 -m venv venv
./venv/bin/pip install -e .

# Create data directory
mkdir -p data

# Copy and edit config
cp .env.example .env
nano .env
```

### 4. Configure .env

Edit `.env` with these essential settings:

```env
# Your bot token from BotFather
TELEGRAM_BOT_TOKEN=your_bot_token_here

# Bot username (without @)
TELEGRAM_BOT_USERNAME=your_bot_username

# Base directory for project access
APPROVED_DIRECTORY=/path/to/your/projects  # or C:\Users\you\projects on Windows

# Your Telegram user ID (from @userinfobot)
ALLOWED_USERS=123456789

# Use CLI authentication (your existing login)
USE_SDK=false

# Path to Claude CLI (REQUIRED on Windows)
# Windows: set both variables to your claude.cmd path
# macOS/Linux: can leave empty for auto-detect
CLAUDE_CLI_PATH=C:\Users\you\AppData\Roaming\npm\claude.cmd
CLAUDE_BINARY_PATH=C:\Users\you\AppData\Roaming\npm\claude.cmd
```

### 5. Run the Bot

**Windows:**
```powershell
cd $env:USERPROFILE\projects\claude-code-telegram
.\venv\Scripts\python.exe src\main.py
```

**macOS / Linux:**
```bash
cd ~/projects/claude-code-telegram
./venv/bin/python src/main.py
```

### 6. Test It

Open Telegram and message your bot with `/start`

## Features

- Full Claude Code access from mobile
- File uploads and downloads
- Git integration
- Quick action buttons
- Session persistence
- Image/screenshot analysis

## Running as a Service (Windows)

Create a scheduled task to run at startup:

```powershell
$action = New-ScheduledTaskAction -Execute "C:\Users\$env:USERNAME\projects\claude-code-telegram\venv\Scripts\python.exe" -Argument "src\main.py" -WorkingDirectory "C:\Users\$env:USERNAME\projects\claude-code-telegram"
$trigger = New-ScheduledTaskTrigger -AtLogon
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Limited
Register-ScheduledTask -TaskName "ClaudeCodeTelegram" -Action $action -Trigger $trigger -Principal $principal
```

## Security Notes

- Only allow your own Telegram user ID in `ALLOWED_USERS`
- Telegram doesn't encrypt bot messages end-to-end
- Don't share sensitive credentials through the bot
- The bot has access to files in `APPROVED_DIRECTORY`

## Troubleshooting

**Bot not responding:**
- Check if Claude CLI is authenticated: run `claude` in terminal
- Verify bot token is correct
- Check logs for errors

**Authentication errors:**
- Run `claude` in terminal to re-authenticate
- Ensure `USE_SDK=false` to use CLI mode

**"WinError 2: The system cannot find the file specified" (Windows):**
- This means Claude CLI path is not configured correctly
- Find your Claude CLI: `where claude` in cmd
- Set BOTH variables in .env:
  ```env
  CLAUDE_CLI_PATH=C:\Users\YourName\AppData\Roaming\npm\claude.cmd
  CLAUDE_BINARY_PATH=C:\Users\YourName\AppData\Roaming\npm\claude.cmd
  ```

**"No result message received from Claude Code":**
- This can occur when Claude returns text-only responses
- See [KNOWN_ISSUES.md](KNOWN_ISSUES.md) for the fix

**Model showing wrong (e.g., Sonnet instead of Opus):**
- Use the full model ID in CLAUDE_MODEL:
  ```env
  CLAUDE_MODEL=claude-opus-4-5-20251101
  ```
- Short names like "opus" may not work correctly

**Validation errors on startup (ALLOWED_USERS, CLAUDE_ALLOWED_TOOLS):**
- See [KNOWN_ISSUES.md](KNOWN_ISSUES.md) for validator fixes

**Shell commands blocked:**
- See [KNOWN_ISSUES.md](KNOWN_ISSUES.md) for Issue 6 and Issue 7

## Advanced Configuration

### Full Shell Access (Personal Use Only)

For personal/trusted setups where you want Claude to have full shell access:

```env
# DANGER: Only enable on personal/trusted setups
# Allows shell operators (>, |, &, ;, etc.)
DISABLE_COMMAND_VALIDATION=true
```

**Note**: You may need to patch both `src/security/validators.py` and `src/claude/monitor.py` - see [KNOWN_ISSUES.md](KNOWN_ISSUES.md).

### Broader Directory Access

To give the bot access to your entire user directory (not just projects):

```env
# Windows
APPROVED_DIRECTORY=C:\Users\YourName

# macOS/Linux
APPROVED_DIRECTORY=/home/yourname
```

## Known Issues

See [KNOWN_ISSUES.md](KNOWN_ISSUES.md) for documented issues and their fixes:

1. "No result message received from Claude Code"
2. WinError 2 - File Not Found (Windows)
3. Wrong Model (Sonnet instead of Opus)
4. ALLOWED_USERS Validation Error
5. CLAUDE_ALLOWED_TOOLS Validation Error
6. Shell Commands Blocked (Security Validator)
7. Shell Commands Still Blocked (Tool Monitor)

## Credits

Based on [claude-code-telegram](https://github.com/RichardAtCT/claude-code-telegram) by RichardAtCT.

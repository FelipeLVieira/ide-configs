# Persistent Bot Architecture

## Overview

Bots run 24/7 as persistent tmux sessions instead of one-shot cron jobs. This ensures continuous work without interruption.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    MAC MINI (Bot Server)                    │
├─────────────────────────────────────────────────────────────┤
│  Clawdbot Gateway (always running)                          │
│  └── Persistent Bot Sessions (tmux):                        │
│      ├── bot-ez-crm          → ~/repos/ez-crm               │
│      ├── bot-linklounge      → ~/repos/linklounge           │
│      ├── bot-aphos           → ~/repos/aphos                │
│      ├── bot-ios-appstore    → ~/repos/bmi-calculator       │
│      ├── bot-clawd-monitor   → ~/repos/clawd-monitor        │
│      └── run_bots.py         → ~/repos/shitcoin-bot         │
│                                                             │
│  Cron Jobs (health checks only):                            │
│      └── Every 30 min: restart any crashed bots             │
│                                                             │
│  Auto-start on reboot: @reboot startup-bots.sh              │
└─────────────────────────────────────────────────────────────┘
```

## Management Commands

```bash
# Check all bots
~/clawd/scripts/manage-bots.sh status

# Start all bots
~/clawd/scripts/manage-bots.sh start

# Stop all bots
~/clawd/scripts/manage-bots.sh stop

# Restart crashed bots (health check)
~/clawd/scripts/manage-bots.sh health

# Restart all bots
~/clawd/scripts/manage-bots.sh restart

# View specific bot logs
tmux attach -t bot-ez-crm
tmux attach -t bot-linklounge
# etc.

# Detach from tmux: Ctrl+B, then D
```

## Bot Configuration

Bots are defined in `~/clawd/scripts/manage-bots.sh`:

```bash
BOTS=(
    "ez-crm|/Users/felipemacmini/repos/ez-crm"
    "linklounge|/Users/felipemacmini/repos/linklounge"
    "aphos|/Users/felipemacmini/repos/aphos"
    "ios-appstore|/Users/felipemacmini/repos/bmi-calculator"
    "clawd-monitor|/Users/felipemacmini/repos/clawd-monitor"
)
```

## Adding a New Bot

1. Add to the BOTS array in `manage-bots.sh`
2. Add bot-specific prompt in `run-persistent-bot.sh` case statement
3. Run `manage-bots.sh start`

## Critical Rules (Enforced in Bot Prompts)

1. **MEGA not Google Drive** - Never access Google Drive
2. **iOS builds: LOCAL ONLY** - Use xcodebuild, NEVER eas build
3. **Browser lock** - Use `acquire_browser_lock` before browser access
4. **Save state** - Store progress in `~/clawd/memory/bot-states/`
5. **Use Grok** - x.com/i/grok for research (saves API credits)

## Troubleshooting

### Bot not running
```bash
~/clawd/scripts/manage-bots.sh health
```

### Bot stuck/frozen
```bash
tmux kill-session -t bot-<name>
~/clawd/scripts/run-persistent-bot.sh <name> <workspace>
```

### Check bot logs
```bash
tmux attach -t bot-<name>
# Or check /tmp/bot-loop-<name>.sh output
```

### Gateway issues
```bash
ps aux | grep clawdbot-gateway
clawdbot gateway restart
```

## Files

- `~/clawd/scripts/manage-bots.sh` - Bot manager
- `~/clawd/scripts/run-persistent-bot.sh` - Individual bot runner
- `~/clawd/scripts/startup-bots.sh` - Auto-start on reboot
- `~/clawd/scripts/browser-lock.sh` - Browser lock system
- `~/.clawdbot/cron/jobs.json` - Health check cron jobs

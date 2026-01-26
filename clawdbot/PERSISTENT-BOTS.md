# Persistent Bot Architecture

## Overview

Bots run 24/7 as persistent tmux sessions. Each bot is a **SPECIALIST** focused on ONE project only.

## Specialist Bots

| Bot | Project | Specialization |
|-----|---------|----------------|
| **ez-crm** | ~/repos/ez-crm | Next.js CRM, Supabase, Legal/Law |
| **linklounge** | ~/repos/linklounge | Link-in-bio platform |
| **aphos** | ~/repos/aphos | MMORPG, Colyseus, Phaser.js |
| **ios-appstore** | ~/repos/bmi-calculator + 2 more | iOS apps, LOCAL builds only |
| **clawd-monitor** | ~/repos/clawd-monitor | Bot monitoring dashboard |

### Key Rule: SPECIALIZATION
Each bot works ONLY on its assigned project. They do not touch other repos. This ensures:
- Deep expertise in their domain
- No conflicts between bots
- Focused, high-quality improvements

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    MAC MINI (Bot Server)                    │
├─────────────────────────────────────────────────────────────┤
│  Clawdbot Gateway (always running)                          │
│  └── Specialist Bot Sessions (tmux):                        │
│      ├── bot-ez-crm          → Next.js/Supabase expert      │
│      ├── bot-linklounge      → Link-in-bio expert           │
│      ├── bot-aphos           → Game dev expert              │
│      ├── bot-ios-appstore    → iOS/Xcode expert             │
│      ├── bot-clawd-monitor   → Dashboard expert             │
│      └── run_bots.py         → Crypto trading (Python)      │
│                                                             │
│  Health Check: Every 30 min, restart crashed bots           │
│  Auto-start: @reboot startup-bots.sh                        │
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
# Detach: Ctrl+B, then D
```

## Critical Rules (All Bots)

1. **STAY FOCUSED** - Only work on assigned project
2. **MEGA not Google Drive** - Never access Google Drive
3. **iOS builds: LOCAL ONLY** - xcodebuild, NEVER eas build
4. **Browser lock** - `acquire_browser_lock` before browser use
5. **Save state** - ~/clawd/memory/bot-states/<name>.json
6. **Use Grok** - x.com/i/grok for research (saves credits)

## Adding a New Specialist Bot

1. Add to BOTS array in `manage-bots.sh`:
   ```bash
   "new-bot|/path/to/workspace"
   ```

2. Add specialized prompt in `run-persistent-bot.sh`:
   ```bash
   new-bot)
       PROMPT="You are the **NewBot Specialist**.
       YOUR ONLY PROJECT: ~/repos/new-project
       Your expertise: [specific skills]
       Your cycle: [specific workflow]"
       ;;
   ```

3. Start: `~/clawd/scripts/manage-bots.sh start`

## Files

- `~/clawd/scripts/manage-bots.sh` - Bot manager
- `~/clawd/scripts/run-persistent-bot.sh` - Bot runner with specialized prompts
- `~/clawd/scripts/startup-bots.sh` - Auto-start on reboot
- `~/clawd/scripts/browser-lock.sh` - Browser lock system

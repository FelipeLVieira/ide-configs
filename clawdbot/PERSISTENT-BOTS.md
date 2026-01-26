# Persistent Bot Architecture

## Overview

Bots run 24/7 as persistent tmux sessions. Each bot is a **SPECIALIST** focused on ONE project only.

## Specialist Bots (7 Total)

| Bot | Project | Specialization |
|-----|---------|----------------|
| **ez-crm** | ~/repos/ez-crm | Next.js CRM, Supabase, Legal/Law |
| **linklounge** | ~/repos/linklounge | Link-in-bio platform |
| **aphos** | ~/repos/aphos | **Next.js + Three.js**, 2.5D MMORPG |
| **ios-bmi** | ~/repos/bmi-calculator | BMI Calculator iOS app |
| **ios-bills** | ~/repos/bill-subscriptions-organizer-tracker | Bills Tracker iOS app |
| **ios-translator** | ~/repos/simple-screen-translator | Screen Translator iOS app |
| **clawd-monitor** | ~/repos/clawd-monitor | Bot monitoring dashboard |

### Key Rules

1. **SPECIALIZATION** - Each bot works ONLY on its assigned project
2. **Aphos Tech Stack**: Next.js + Three.js (NOT Colyseus/Phaser!)
   - 2.5D game (isometric/top-down)
   - 3D only for skill effects
3. **iOS Builds**: LOCAL ONLY (xcodebuild), NEVER eas build

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    MAC MINI (Bot Server)                    │
├─────────────────────────────────────────────────────────────┤
│  Clawdbot Gateway (always running)                          │
│  └── Specialist Bot Sessions (tmux):                        │
│      ├── bot-ez-crm          → Next.js/Supabase expert      │
│      ├── bot-linklounge      → Link-in-bio expert           │
│      ├── bot-aphos           → Next.js/Three.js 2.5D expert │
│      ├── bot-ios-bmi         → BMI Calculator expert        │
│      ├── bot-ios-bills       → Bills Tracker expert         │
│      ├── bot-ios-translator  → Screen Translator expert     │
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

# Start/Stop/Restart
~/clawd/scripts/manage-bots.sh start
~/clawd/scripts/manage-bots.sh stop
~/clawd/scripts/manage-bots.sh restart

# Health check (restart crashed bots)
~/clawd/scripts/manage-bots.sh health

# View specific bot logs
tmux attach -t bot-aphos
# Detach: Ctrl+B, then D
```

## Aphos Game - Tech Stack

**DO NOT use Colyseus or Phaser** - those are deprecated!

| Component | Technology |
|-----------|------------|
| Framework | Next.js |
| Rendering | Three.js |
| Style | 2.5D (isometric/top-down) |
| 3D Effects | Skill effects only (spells, particles) |
| Research | Use Grok (x.com/i/grok) for Three.js help |

## Critical Rules (All Bots)

1. **STAY FOCUSED** - Only work on assigned project
2. **MEGA not Google Drive** - Never access Google Drive
3. **iOS builds: LOCAL ONLY** - xcodebuild, NEVER eas build
4. **Browser lock** - `acquire_browser_lock` before browser use
5. **Use Grok** - x.com/i/grok for research (saves credits)

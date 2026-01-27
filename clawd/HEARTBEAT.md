# HEARTBEAT.md - Orchestrator Duties

## Every Heartbeat: Quick Checks Only

Most cleanup is now automated via bash scripts + dedicated cron jobs.
The heartbeat only needs to handle things that need main session context.

### 1. Check for Cron Health Summary
The System Health Monitor cron runs every 2 hours and posts a summary.
If it reported issues recently, follow up on them.

### 2. Quick Mac Mini Connectivity Check
```bash
ssh felipemacmini@felipes-mac-mini.local 'echo "online"' 2>/dev/null || echo "OFFLINE"
```
- If offline, REPORT to Felipe immediately

### 3. Check Context Usage
- If above 50%, run /compact before next task

### 4. Report Only If Something Needs Attention
- ❌ Mac Mini offline / unreachable
- ❌ System Health Monitor reported critical issues
- ✅ Significant milestone (app submitted, major bug fixed)
- Otherwise: HEARTBEAT_OK

## What's Automated (DON'T duplicate these checks)
These are handled by bash scripts (every 15 min, zero tokens) + cron jobs:
- ✅ Simulator cleanup on both MacBook and Mac Mini (launchd bash scripts)
- ✅ Zombie process cleanup (launchd bash scripts)
- ✅ Temp file cleanup (launchd bash scripts)
- ✅ Duplicate process detection (launchd bash scripts)
- ✅ Memory/disk monitoring (launchd bash scripts)
- ✅ Bot health checks (System Health Monitor cron, every 2h, Sonnet)
- ✅ Research agents (Shitcoin Brain + Quant crons, every 30min, Sonnet)
- ✅ Session cleanup (clear-sessions cron, weekly)

## Architecture Reference
```
Bash Scripts (FREE, every 15 min via launchd):
├── MacBook: macbook-cleanup.sh → /tmp/clawdbot/macbook-health.json
└── Mac Mini: mac-mini-cleanup.sh → /tmp/clawdbot/system-health.json

Clawdbot Cron Jobs (Sonnet, isolated sessions):
├── Shitcoin Brain    → :15, :45 every hour (research)
├── Shitcoin Quant    → :00, :30 every hour (quant strategy)
├── System Health     → :05 every 2 hours (reads bash output + checks bots)
└── Clear Sessions    → Sunday midnight (weekly cleanup)

Heartbeat (main session, Opus):
└── Quick connectivity check + context management only
```

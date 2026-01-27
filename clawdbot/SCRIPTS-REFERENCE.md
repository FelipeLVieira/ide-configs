# Mac Mini Scripts Reference

## Automated Cleanup Scripts (Bash, Zero Tokens)

### mac-mini-cleanup.sh
Location: ~/clawd/scripts/mac-mini-cleanup.sh
Runs: Every 15 min via launchd (com.clawdbot.system-cleanup)
Output: /tmp/clawdbot/system-health.json

**Actions:**
- Kill simulators, zombies, duplicate bot processes
- Clean old temp/log files (>7 days), screenshots (>1 day)
- Check memory/disk usage, flag if low
- Verify trading bot + gateway are running
- Detect orphaned agent sessions (>5)
- Check bot log freshness (>10 min = stale)

### macbook-cleanup.sh
Location: ~/clawd/scripts/macbook-cleanup.sh
Runs: Every 15 min via launchd (com.clawdbot.macbook-cleanup)
Output: /tmp/clawdbot/macbook-health.json

**Actions:**
- Kill ALL simulators (should NOT run on MacBook!)
- Clean zombies, temp files
- Check for stale dev servers
- Monitor disk/memory

## Prompt Files

Bot-specific prompts in ~/clawd/prompts/:
- shitcoin-brain.md — Research agent instructions
- shitcoin-quant.md — Quant strategy research instructions

## LaunchAgent Plists

Mac Mini (~/Library/LaunchAgents/):
- com.clawdbot.gateway.plist — Gateway daemon
- com.clawdbot.shitcoin-bot.plist — Python trading bot
- com.clawdbot.system-cleanup.plist — Bash cleanup (15 min)
- com.clawdbot.failover.plist — MacBook health monitor
- com.clawdbot.node.plist — Node connection

MacBook (~/Library/LaunchAgents/):
- com.clawdbot.macbook-cleanup.plist — Bash cleanup (15 min)

## Deprecated (Removed 2026-01-26)
- ❌ run-shitcoin-brain.sh — replaced by Clawdbot cron
- ❌ run-shitcoin-quant.sh — replaced by Clawdbot cron
- ❌ manage-bots.sh — replaced by cron + launchd
- ❌ run-persistent-bot.sh — replaced by cron jobs

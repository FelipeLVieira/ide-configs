# Scripts Reference

## Automated Cleanup & Healing Scripts

### event-watcher.sh (Layer 1 — Instant Healing)
**Location**: `/Users/felipevieira/clawd/scripts/event-watcher.sh`  
**Runs**: 24/7 via launchd (`com.clawdbot.event-watcher`)  
**Interval**: Every 60 seconds  
**Output**: `/tmp/clawdbot/events.jsonl`  
**Cost**: FREE (pure bash)

**Monitors & Auto-Heals:**
- Ollama health on both machines → auto-restart via `brew services`
- pm2 processes on Mac Mini → `pm2 resurrect`
- Mac Mini connectivity → log alert (can't self-heal network)
- Rogue iOS simulators on MacBook → `killall Simulator`
- Zombie processes → `kill -9`

**Management:**
```bash
# Check if running
launchctl list | grep event-watcher

# View recent events
tail -20 /tmp/clawdbot/events.jsonl | jq .

# Restart
launchctl stop com.clawdbot.event-watcher
launchctl start com.clawdbot.event-watcher

# View stdout/stderr logs
tail -f /tmp/clawdbot/event-watcher.out.log
tail -f /tmp/clawdbot/event-watcher.err.log
```

See [HYBRID-HEALING.md](HYBRID-HEALING.md) for full architecture.

---

### mac-mini-cleanup.sh
**Location**: `~/clawd/scripts/mac-mini-cleanup.sh`  
**Runs**: Every 15 min via launchd (`com.clawdbot.system-cleanup`)  
**Output**: `/tmp/clawdbot/system-health.json`

**Actions:**
- Kill simulators, zombies, duplicate bot processes
- Clean old temp/log files (>7 days), screenshots (>1 day)
- Check memory/disk usage, flag if low
- Verify trading bot + gateway are running
- Detect orphaned agent sessions (>5)
- Check bot log freshness (>10 min = stale)

---

### macbook-cleanup.sh
**Location**: `~/clawd/scripts/macbook-cleanup.sh`  
**Runs**: Every 15 min via launchd (`com.clawdbot.macbook-cleanup`)  
**Output**: `/tmp/clawdbot/macbook-health.json`

**Actions:**
- Kill ALL simulators (should NOT run on MacBook!)
- Clean zombies, temp files
- Check for stale dev servers
- Monitor disk/memory

---

## Prompt Files

Bot-specific prompts in `~/clawd/prompts/`:
- `shitcoin-brain.md` — Research agent instructions
- `shitcoin-quant.md` — Quant strategy research instructions

---

## LaunchAgent Plists

### MacBook (`~/Library/LaunchAgents/`):
| Plist | Purpose | Interval |
|-------|---------|----------|
| `com.clawdbot.event-watcher.plist` | Event watcher (Layer 1 healing) | 60s loop |
| `com.clawdbot.macbook-cleanup.plist` | Bash cleanup | 15 min |
| `com.ollama.serve.plist` | Ollama server | Always-on |

### Mac Mini (`~/Library/LaunchAgents/`):
| Plist | Purpose | Interval |
|-------|---------|----------|
| `com.clawdbot.gateway.plist` | Gateway daemon | Always-on |
| `com.clawdbot.shitcoin-bot.plist` | Python trading bot | Always-on |
| `com.clawdbot.system-cleanup.plist` | Bash cleanup | 15 min |
| `com.clawdbot.failover.plist` | MacBook health monitor | Always-on |
| `com.clawdbot.node.plist` | Node connection | Always-on |

---

## Cron Jobs (Clawdbot)

| Job | Schedule | Model | Purpose |
|-----|----------|-------|---------|
| Cleaner Bot | Hourly | gpt-oss:20b / qwen3:8b | Deep cleanup |
| Healer Bot | Hourly | gpt-oss:20b → Sonnet | Diagnose & heal |
| Clear Sessions | Weekly (Sun midnight) | — | Session cleanup |

---

## Deprecated (Removed 2026-01-26)
- ❌ `run-shitcoin-brain.sh` — replaced by Clawdbot cron
- ❌ `run-shitcoin-quant.sh` — replaced by Clawdbot cron
- ❌ `manage-bots.sh` — replaced by cron + launchd
- ❌ `run-persistent-bot.sh` — replaced by cron jobs

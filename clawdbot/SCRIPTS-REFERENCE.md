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

**v2 Features (Event Watcher v2):**
- **Health Probes** — HTTP health checks for services (Ollama, Gateway, clawd-monitor)
- **Circuit Breakers** — Tracks consecutive failures per service; stops restart attempts after threshold to prevent restart loops
- **Desired State** — Reads `desired-state.json` to know which services SHOULD be running

**Key Files:**
- **desired-state.json**: `/tmp/clawdbot/desired-state.json` — Declares which services should be running and their health endpoints
- **Circuit breaker state**: `/tmp/clawdbot/circuit-breaker.json` — Tracks failure counts per service (auto-resets after cooldown)

```json
// desired-state.json example
{
  "services": {
    "ollama": { "check": "http", "url": "http://localhost:11434/api/tags", "restart": "brew services restart ollama" },
    "gateway": { "check": "process", "name": "clawdbot-gateway", "restart": "launchctl start com.clawdbot.gateway" },
    "pm2": { "check": "process", "name": "pm2", "restart": "pm2 resurrect" }
  }
}
```

```json
// circuit-breaker.json example
{
  "ollama": { "failures": 0, "lastFailure": null, "open": false },
  "gateway": { "failures": 3, "lastFailure": "2025-07-30T12:00:00Z", "open": true }
}
```

**Management:**
```bash
# Check if running
launchctl list | grep event-watcher

# View recent events
tail -20 /tmp/clawdbot/events.jsonl | jq .

# Check circuit breaker state
cat /tmp/clawdbot/circuit-breaker.json | jq .

# Check desired state
cat /tmp/clawdbot/desired-state.json | jq .

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
| App Store Manager | 3x daily (9 AM, 3 PM, 9 PM EST) | gpt-oss:20b | iOS app monitoring |

See [APP-STORE-MANAGER.md](APP-STORE-MANAGER.md) for full App Store Manager docs.

---

## Deprecated (Removed 2026-01-26)
- ❌ `run-shitcoin-brain.sh` — replaced by Clawdbot cron
- ❌ `run-shitcoin-quant.sh` — replaced by Clawdbot cron
- ❌ `manage-bots.sh` — replaced by cron + launchd
- ❌ `run-persistent-bot.sh` — replaced by cron jobs

# Hybrid Self-Healing Architecture v3

Three-layer healing system combining free bash scripts with AI-powered diagnostics.

**v3 Enhancements:**
- ✅ Swap monitoring for Mac Mini (16GB RAM protection)
- ✅ Cross-machine Ollama fallback (bidirectional)
- ✅ Resource limits in desired-state.json
- ✅ Auto-unload heavy models when swap >8GB

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                   HYBRID HEALING SYSTEM                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Layer 1: Event Watcher (bash, 60s loop, launchd, FREE)     │
│  ├── Ollama health (both machines) → auto-restart            │
│  ├── pm2 processes → auto-resurrect                          │
│  ├── Mac Mini connectivity → alert                           │
│  ├── Zombie processes → auto-kill                            │
│  ├── Rogue simulators → auto-kill                            │
│  └── Logs → /tmp/clawdbot/events.jsonl                       │
│                                                              │
│  Layer 2: Cleaner Bot (hourly cron, AI)                      │
│  ├── Bash cleanup scripts (both machines)                    │
│  ├── Stale builds/caches cleanup (.next, node_modules/.cache)│
│  ├── Browser tab management                                  │
│  └── Disk usage monitoring                                   │
│                                                              │
│  Layer 3: Healer Bot (hourly cron, AI)                       │
│  ├── Read event-watcher logs                                 │
│  ├── Deep diagnostics (Tailscale, game servers, git repos)   │
│  ├── Smart healing (web research for unknown errors)         │
│  └── Alert escalation to Felipe                              │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## 🔧 Layer 1 — Event Watcher (Instant, FREE, Bash)

**The first line of defense.** Runs 24/7 via launchd, costs zero tokens.

### Script
- **Location**: `/Users/felipevieira/clawd/scripts/event-watcher.sh`
- **Interval**: Every 60 seconds
- **Service**: `com.clawdbot.event-watcher` (launchd)
- **Log output**: `/tmp/clawdbot/events.jsonl`

### What It Monitors

| Check | Action on Failure | Cooldown |
|-------|-------------------|----------|
| Ollama (MacBook) | `brew services restart ollama` | — |
| Ollama (Mac Mini) | SSH restart `brew services restart ollama` | — |
| pm2 processes (Mac Mini) | `pm2 resurrect` | — |
| Mac Mini connectivity | Log alert (can't self-heal network) | — |
| Rogue iOS simulators | `killall Simulator` (MacBook only!) | — |
| Zombie processes | `kill -9` zombies | — |

### LaunchAgent Plist

**File**: `~/Library/LaunchAgents/com.clawdbot.event-watcher.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.clawdbot.event-watcher</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>/Users/felipevieira/clawd/scripts/event-watcher.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/clawdbot/event-watcher.out.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/clawdbot/event-watcher.err.log</string>
</dict>
</plist>
```

### Log Format (JSONL)

Each event logged to `/tmp/clawdbot/events.jsonl`:

```json
{"ts":"2025-07-15T03:42:00Z","type":"ollama_restart","machine":"macbook","detail":"restarted via brew services"}
{"ts":"2025-07-15T03:43:00Z","type":"zombie_kill","machine":"macbook","detail":"killed 3 zombies"}
{"ts":"2025-07-15T04:15:00Z","type":"mac_mini_down","machine":"macbook","detail":"ping failed 3 times"}
```

### Management

```bash
# Check if running
launchctl list | grep event-watcher

# View recent events
tail -20 /tmp/clawdbot/events.jsonl | jq .

# Restart
launchctl stop com.clawdbot.event-watcher
launchctl start com.clawdbot.event-watcher

# View logs
tail -f /tmp/clawdbot/event-watcher.out.log
```

---

## 🧹 Layer 2 — Cleaner Bot (Hourly Cron, AI)

**Deep cleanup that needs judgment.** Runs hourly via Clawdbot cron.

### Schedule
- **Frequency**: Every hour
- **Model**: Local LLM (gpt-oss:20b or qwen3:8b)
- **Cost**: ~FREE (local inference)

### What It Cleans

| Target | Rule | Both Machines? |
|--------|------|----------------|
| `.next` build dirs | Delete if >7 days old | ✅ |
| `node_modules/.cache` | Delete if >7 days old | ✅ |
| Temp files (`/tmp/clawdbot/`) | Rotate logs >7 days | ✅ |
| Old screenshots | Delete if >1 day | ✅ |
| Browser tabs | Close stale tabs | MacBook only |
| Disk usage | Alert if >85% | ✅ |

### How It Works

1. Runs bash cleanup scripts on both machines (SSH for Mac Mini)
2. Checks disk usage and memory pressure
3. Uses AI reasoning for edge cases (e.g., "is this cache safe to delete?")
4. Logs cleanup actions for audit trail

---

## 🏥 Layer 3 — Healer Bot v3 (Hourly Cron, AI)

**The smart doctor.** Reads Layer 1 logs, performs deep diagnosis, researches fixes.

### Schedule
- **Frequency**: Every hour
- **Model**: Claude Sonnet 4.5 in isolated sessions (extended thinking)
- **Cost**: ~$0.05-0.15 per run (worth it for diagnostics)

### What It Heals

| System | Diagnosis | Healing Action |
|--------|-----------|----------------|
| Event-watcher logs | Parse `/tmp/clawdbot/events.jsonl` | Identify patterns, recurring failures |
| **Swap monitoring (Mac Mini)** | Check swap usage, model memory | **Auto-unload gpt-oss:20b if swap >8GB** |
| Clawdbot Gateway | Check port 18789 responsive | Restart gateway service |
| Tailscale | Check mesh connectivity | `tailscale up`, restart service |
| Aphos game servers | pm2 status, port 2567/2568 | `pm2 restart`, rebuild if needed |
| Git repos | Check for stale branches, uncommitted work | Alert Felipe |
| Cross-machine Ollama | Verify both endpoints respond | **Failover to other machine automatically** |

### v3 Features: Swap Protection

**Mac Mini has only 16GB RAM** — heavy models cause swap death.

**Healer Bot v3 monitors:**
```bash
# Check swap usage on Mac Mini
vm_stat | grep "swap" | awk '{print $4}' | sed 's/\.//'
```

**Swap thresholds (desired-state.json):**
```json
{
  "resource_limits": {
    "macmini_swap_warn_gb": 8,
    "macmini_swap_critical_gb": 12,
    "max_loaded_model_gb": 6
  }
}
```

**Actions:**
- Swap >8GB: Auto-unload gpt-oss:20b (14GB), keep qwen3:8b (5GB)
- Swap >12GB: Alert Felipe (critical, needs manual intervention)
- Always: Ensure qwen3:8b is primary (safe for 16GB)

### Smart Healing Logic

```
1. Read event-watcher logs (Layer 1 output)
2. If bash already fixed it → log success, move on
3. If bash couldn't fix it → deep diagnosis:
   a. Check service status, logs, ports
   b. Search web for error messages (if unknown)
   c. Apply fix
4. If still broken → alert Felipe (Telegram notification)
5. Only alert for CRITICAL + UNFIXABLE issues
```

### Alert Escalation

The Healer Bot only bothers Felipe when:
- ❌ Something is **critical** (gateway down, all Ollama instances dead)
- ❌ Something is **unfixable** by automation
- ❌ Something requires **human decision** (e.g., disk 95% full — what to delete?)

Everything else is handled silently.

---

## 🔄 How the Layers Work Together

```
Every 60 seconds:
  Event Watcher checks → fixes instantly → logs events

Every hour:
  Cleaner Bot runs → cleans caches/temp → frees resources
  Healer Bot v3 runs → reads event logs → deep diagnosis → swap monitoring → 
    cross-machine failover → smart healing

Result:
  ✅ 95% of issues fixed in <60 seconds (bash)
  ✅ 4% fixed within the hour (AI healing)
  ✅ 1% escalated to Felipe (truly broken)
  ✅ Mac Mini swap death prevented automatically
  ✅ Cross-machine Ollama failover seamless
```

### Why Hybrid?

| Approach | Pros | Cons |
|----------|------|------|
| **Bash only** | Free, instant | Can't diagnose complex issues |
| **AI only** | Smart, flexible | Expensive, slow (API calls) |
| **Hybrid** | Best of both: instant + smart | Slightly more complex setup |

The event watcher handles 95% of issues for free. The AI layers handle the remaining 5% that need judgment.

---

## 🆕 Hybrid Healing v2 — Enhanced Features

### Health Probes (HTTP, not PID)

**v1** checked if processes were running (PID exists). **v2** checks if services are actually responding:

```bash
# v1 (PID-based) — unreliable, process could be hung
pgrep -f "clawdbot-gateway" > /dev/null

# v2 (HTTP health probe) — checks actual responsiveness
curl -sf http://localhost:18789/health --max-time 5 > /dev/null
curl -sf http://localhost:11434/api/tags --max-time 5 > /dev/null
```

**Why**: A process can be alive but unresponsive (deadlocked, OOM, hung connection). HTTP probes catch these cases.

### Circuit Breakers

Prevents restart loops when a service is fundamentally broken:

```
State file: /tmp/clawdbot/healer_circuit.json
```

```json
{
  "ollama_macbook": {
    "failures": 0,
    "state": "closed",
    "lastFailure": null,
    "openedAt": null
  },
  "clawdbot_gateway": {
    "failures": 0,
    "state": "closed",
    "lastFailure": null,
    "openedAt": null
  }
}
```

**States:**
| State | Meaning | Behavior |
|-------|---------|----------|
| `closed` | Healthy | Normal monitoring, restart on failure |
| `open` | Broken (3+ failures) | **Stop restarting**, alert Felipe |
| `half-open` | Cooling down (after 10 min) | Try one restart, go closed or open |

**Why**: Without circuit breakers, a fundamentally broken service triggers endless restart loops, filling logs and burning resources.

### Reconciler Pattern

Instead of reactive "fix when broken", v2+ uses a **desired-state reconciler**:

```
Desired state: /tmp/clawdbot/desired-state.json
```

```json
{
  "services": {
    "ollama_macbook": { "state": "running", "probe": "http://localhost:11434/api/tags" },
    "ollama_macmini": { "state": "running", "probe": "http://felipes-mac-mini.local:11434/api/tags" },
    "clawdbot_gateway": { "state": "running", "probe": "http://localhost:18789/health" },
    "pm2_aphos_prod": { "state": "running", "port": 2567 },
    "pm2_aphos_dev": { "state": "running", "port": 2568 }
  },
  "resource_limits": {
    "macmini_swap_warn_gb": 8,
    "macmini_swap_critical_gb": 12,
    "max_loaded_model_gb": 6
  }
}
```

**How it works:**
1. Read desired state from `desired-state.json`
2. Probe each service
3. Compare actual vs desired
4. Reconcile: restart services that should be running but aren't
5. Check circuit breaker before restarting
6. Log all actions to `events.jsonl`

**Why**: Declarative > imperative. Add/remove services by editing a JSON file, not bash scripts.

---

## Incident Log

### 2026-01-27: Mac Mini Ollama Binding to localhost Only

**Problem**: Mac Mini Ollama was binding to `localhost:11434` instead of `0.0.0.0:11434`, making it unreachable from other machines on the network. Cross-machine fallback was broken -- MacBook and Windows could not reach Mac Mini Ollama.

**Detection**: Healer Bot circuit breaker triggered after 5 consecutive probe failures to `http://felipes-mac-mini.local:11434/api/tags` over a 14-minute window. The circuit opened, stopping restart attempts and escalating to diagnostics.

**Root Cause**: Homebrew's `brew services` does not reliably persist environment variables like `OLLAMA_HOST=0.0.0.0`. The ephemeral service config only reads from shell profile on interactive login, not when launchd spawns the process. After a reboot or service restart, Ollama reverted to binding `127.0.0.1` only.

**Fix**: Healer Bot created a custom launchd plist at `~/Library/LaunchAgents/com.user.ollama.plist` that embeds `OLLAMA_HOST=0.0.0.0` directly in the plist's `EnvironmentVariables` dict. This replaces Homebrew's service management entirely for Ollama on Mac Mini.

**Steps taken by Healer Bot:**
1. Stopped Homebrew service: `brew services stop ollama`
2. Created custom plist with OLLAMA_HOST=0.0.0.0, OLLAMA_FLASH_ATTENTION=1, OLLAMA_KV_CACHE_TYPE=q8_0
3. Loaded via: `launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.user.ollama.plist`
4. Verified Ollama responding on 0.0.0.0:11434
5. Confirmed cross-machine fallback operational (MacBook and Windows can reach Mac Mini)

**Result**: Cross-machine Ollama fallback restored. Both directions (Mac Mini to MacBook, MacBook to Mac Mini) now operational. See [ollama-setup.md](../ollama-setup.md) for the custom plist documentation.

**Lesson**: Never rely on `brew services` for environment variable persistence on services managed by launchd. Always use a custom plist with embedded `EnvironmentVariables`.

---

## References

- [Three-Machine Architecture](../infrastructure/three-machine-architecture.md) — Full infrastructure overview
- [SCRIPTS-REFERENCE.md](SCRIPTS-REFERENCE.md) — All script documentation
- [PERSISTENT-BOTS.md](PERSISTENT-BOTS.md) — Bot architecture
- [Clawdbot Config](../clawdbot-config.md) — Cron job configuration
- [Ollama Setup](../ollama-setup.md) — Model routing

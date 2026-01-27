# Hybrid Self-Healing Architecture

Three-layer healing system combining free bash scripts with AI-powered diagnostics.

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

## 🏥 Layer 3 — Healer Bot (Hourly Cron, AI)

**The smart doctor.** Reads Layer 1 logs, performs deep diagnosis, researches fixes.

### Schedule
- **Frequency**: Every hour
- **Model**: Local LLM → Claude Sonnet (fallback for complex issues)
- **Cost**: Usually FREE, occasionally ~$0.05 for API calls

### What It Heals

| System | Diagnosis | Healing Action |
|--------|-----------|----------------|
| Event-watcher logs | Parse `/tmp/clawdbot/events.jsonl` | Identify patterns, recurring failures |
| Clawdbot Gateway | Check port 18789 responsive | Restart gateway service |
| Tailscale | Check mesh connectivity | `tailscale up`, restart service |
| Aphos game servers | pm2 status, port 2567/2568 | `pm2 restart`, rebuild if needed |
| Git repos | Check for stale branches, uncommitted work | Alert Felipe |
| Cross-machine Ollama | Verify both endpoints respond | Restart on failing machine |

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
  Healer Bot runs → reads event logs → deep diagnosis → smart healing

Result:
  ✅ 95% of issues fixed in <60 seconds (bash)
  ✅ 4% fixed within the hour (AI healing)
  ✅ 1% escalated to Felipe (truly broken)
```

### Why Hybrid?

| Approach | Pros | Cons |
|----------|------|------|
| **Bash only** | Free, instant | Can't diagnose complex issues |
| **AI only** | Smart, flexible | Expensive, slow (API calls) |
| **Hybrid** | Best of both: instant + smart | Slightly more complex setup |

The event watcher handles 95% of issues for free. The AI layers handle the remaining 5% that need judgment.

---

## 📚 References

- [SCRIPTS-REFERENCE.md](SCRIPTS-REFERENCE.md) — All script documentation
- [PERSISTENT-BOTS.md](PERSISTENT-BOTS.md) — Bot architecture
- [Clawdbot Config](../clawdbot-config.md) — Cron job configuration
- [Ollama Setup](../ollama-setup.md) — Model routing

# Infrastructure - Services, Ports, Connections

**Last Updated**: 2026-01-29  
**Architecture**: MacBook Pro (orchestrator) + Mac Mini (worker) + Windows MSI (gaming)

---

## Table of Contents
1. [Service Overview](#service-overview)
2. [Port Assignments](#port-assignments)
3. [Network Configuration](#network-configuration)
4. [Service Details](#service-details)
5. [Auto-Start Configuration](#auto-start-configuration)
6. [Health Monitoring](#health-monitoring)

---

## Service Overview

### MacBook Pro Services (M3 Max, 48GB)

| Service | Type | Port | Auto-Start | Purpose |
|---------|------|------|------------|---------|
| Clawdbot Gateway | LaunchAgent | 18789 | ✅ | Main orchestration, Telegram enabled |
| Ollama Server | LaunchAgent | 11434 | ✅ | Local LLM inference (hosts all models) |
| Crabwalk Dashboard | LaunchAgent | 9009 | ✅ | Community monitoring dashboard |
| clawd-status API | LaunchAgent | 9010 | ✅ | Cron job reporting endpoint |
| Heartbeat Bot | Cron | N/A | ✅ | 60-minute cycle, machine stats |

### Mac Mini Services (M4, 16GB)

| Service | Type | Port | Auto-Start | Purpose |
|---------|------|------|------------|---------|
| Clawdbot Gateway | LaunchAgent | 18789 | ✅ | Worker gateway, Telegram DISABLED |
| Clawdbot Node | LaunchAgent | N/A | ✅ | Paired to MacBook gateway |
| Ollama (Remote) | PM2 | 11434 | ✅ | Uses MacBook's models via LAN |
| Aphos Server Prod | PM2 | 2567 | ✅ | Production MMORPG game server |
| Aphos Server Dev | PM2 | 2568 | ✅ | Development MMORPG game server |
| Failover Watchdog | LaunchAgent | N/A | ✅ | MacBook health monitoring |
| System Cleanup | LaunchAgent | N/A | ✅ | Every 15 min, zero tokens |
| Caffeinate | LaunchAgent | N/A | ✅ | Prevent sleep |

### Windows MSI Services

| Service | Type | Port | Auto-Start | Purpose |
|---------|------|------|------------|---------|
| Clawdbot Bot | Windows Service | N/A | ✅ | Windows-specific tasks |
| Tailscale | Windows Service | N/A | ✅ | VPN mesh network |
| OpenSSH Server | Windows Service | 22 | ✅ | Remote SSH access |

---

## Port Assignments

### System Ports (Auto-Assigned)

| Port | Service | Machine | Bind | Notes |
|------|---------|---------|------|-------|
| 18789 | Clawdbot Gateway | MacBook | LAN (0.0.0.0) | Telegram enabled |
| 18789 | Clawdbot Gateway | Mac Mini | LAN (0.0.0.0) | Telegram DISABLED |
| 11434 | Ollama | MacBook | LAN (0.0.0.0) | Hosts qwen3-coder:30b, gemma3:12b, devstral |
| 11434 | Ollama (Remote) | Mac Mini | N/A | Uses MacBook's http://10.144.238.116:11434 |
| 9009 | Crabwalk | MacBook | Localhost | Community dashboard |
| 9010 | clawd-status | MacBook | Localhost | Cron job reporting API |

### Project Ports (Reserved Ranges)

| Range | Project | Default Port | Notes |
|-------|---------|--------------|-------|
| **2567-2599** | Aphos game servers | 2567 (prod), 2568 (dev) | PM2 on Mac Mini |
| **3000-3099** | ez-crm | 3000 | Next.js dev server |
| **3100-3199** | linklounge | 3100 | Next.js dev server |
| **4000-4099** | Aphos web | 4000 (prod), 4001 (dev) | NOT currently running |
| **5000-5099** | shitcoin-bot | TBD | If web interface needed |
| **8081** | bmi-calculator | 8081 | Expo web (iOS app) |
| **8082** | bills-tracker | 8082 | Expo web (iOS app) |
| **8083** | screen-translator | 8083 | Expo web (iOS app) |

### Port Conflict Prevention

**Before starting a dev server, ALWAYS check:**
```bash
# Check what's using common ports
lsof -i :3000 -i :4000 -i :5000 -i :8080 | grep LISTEN

# Or check a specific port
lsof -i :3000

# Kill process on port if needed
kill $(lsof -t -i :3000)

# Or use a different port
PORT=3001 npm run dev
```

---

## Network Configuration

### Tailscale Mesh VPN

**Network**: Private mesh VPN (userspace-networking on Macs)

| Device | Tailscale IP | SOCKS5 Proxy | SSH Name |
|--------|--------------|--------------|----------|
| MacBook Pro | 100.125.165.107 | localhost:1055 | N/A (local) |
| Mac Mini | 100.115.10.14 | localhost:1055 | felipes-mac-mini.local |
| Windows MSI | 100.67.241.32 | N/A | msi (via SOCKS) |
| iPhone | 100.89.50.26 | N/A | N/A |

### SSH Configuration

**MacBook → Mac Mini:**
```bash
ssh felipemacmini@felipes-mac-mini.local
# Passwordless (SSH keys)
```

**MacBook → Windows MSI:**
```bash
ssh msi
# Via SOCKS proxy on localhost:1055 (configured in ~/.ssh/config)
# 10-15s timeout recommended (slow connection)
```

**Mac Mini → MacBook:**
```
NOT CONFIGURED
Reason: MacBook Remote Login disabled (security)
Workaround: Mac Mini pushes to git, MacBook pulls
```

### LAN Addresses

| Machine | LAN IP | Hostname | Notes |
|---------|--------|----------|-------|
| MacBook Pro | 10.144.238.116 | felipes-macbook-pro.local | Ollama server accessible via LAN |
| Mac Mini | 10.144.238.117 | felipes-mac-mini.local | SSH passwordless |
| Router | 10.144.238.1 | N/A | Gateway |

### Firewall Rules

**MacBook Pro:**
- Allow incoming: 18789 (Gateway), 11434 (Ollama)
- Bind: 0.0.0.0 (LAN accessible)

**Mac Mini:**
- Allow incoming: 18789 (Gateway), 2567-2568 (Aphos)
- Bind: 0.0.0.0 (LAN accessible)

**Windows MSI:**
- Allow incoming: 22 (SSH), Tailscale ports
- Firewall: Windows Defender enabled

---

## Service Details

### Clawdbot Gateway

**MacBook Pro:**
```yaml
Host: 0.0.0.0 (LAN)
Port: 18789
Telegram: ENABLED (primary bot)
Channels: telegram, groupPolicy: allowlist
Model: Sonnet 4.5 (main session), Opus 4.5 (Felipe direct)
Config: ~/.clawdbot/clawdbot.json
```

**Mac Mini:**
```yaml
Host: 0.0.0.0 (LAN)
Port: 18789
Telegram: DISABLED (standby only)
Purpose: Paired node, failover
Config: ~/.clawdbot/clawdbot.json
```

**Start/Stop:**
```bash
# MacBook
launchctl stop com.clawdbot.gateway
launchctl start com.clawdbot.gateway

# Mac Mini
ssh felipemacmini@felipes-mac-mini.local 'launchctl stop com.clawdbot.gateway'
ssh felipemacmini@felipes-mac-mini.local 'launchctl start com.clawdbot.gateway'
```

---

### Ollama Server

**MacBook Pro (Primary):**
```yaml
Host: 0.0.0.0 (LAN accessible)
Port: 11434
Models:
  - qwen3-coder:30b (19GB) - PRIMARY (73.7% accuracy)
  - gemma3:12b (8GB) - Fallback (vision-capable)
  - devstral-small-2:24b (15GB) - Alternative (code-focused)
Config: ~/.ollama/
```

**Mac Mini (Remote Client):**
```yaml
Connection: http://10.144.238.116:11434 (MacBook's LAN IP)
Models: NONE installed locally (16GB RAM constraint)
Config: OLLAMA_HOST=http://10.144.238.116:11434
```

**Commands:**
```bash
# MacBook: List models
ollama list

# MacBook: Pull new model
ollama pull qwen3-coder:30b

# Mac Mini: Use MacBook's models
ssh felipemacmini@felipes-mac-mini.local 'OLLAMA_HOST=http://10.144.238.116:11434 ollama list'
```

**Queue System:**
```bash
# Max 2 concurrent requests
./utils/with-ollama.sh bot-name qwen3-coder:30b "your command"
```

---

### Crabwalk Dashboard

**Service:**
```yaml
Host: localhost (MacBook only)
Port: 9009
Type: Community monitoring dashboard
Auto-Start: LaunchAgent
Data: public/heartbeat-data.json (written by Heartbeat bot)
```

**Features:**
- Session grouping (main, isolated, subagents)
- Action history (all tool calls)
- Heartbeat status modal (scrollable, real data)
- Active-only filter (performance optimization)
- Real-time updates

**Access:**
```bash
# Local browser
open http://localhost:9009

# Via Tailscale from iPhone
http://100.125.165.107:9009
```

**Performance Notes:**
- Was loading 52 sessions + 4380 actions (slow)
- Now: active-only filter (fast)
- TODO: Persistence TTL (auto-purge >48h sessions, >24h actions)

---

### clawd-status API

**Service:**
```yaml
Host: localhost (MacBook only)
Port: 9010
Purpose: Cron job reporting endpoint
Type: Express.js API
Auto-Start: LaunchAgent
```

**Endpoint:**
```bash
POST http://localhost:9010/api/log
Content-Type: application/json

{
  "jobId": "bot-name",
  "message": "Summary of work completed",
  "status": "ok|warning|critical"
}
```

**Usage Example:**
```bash
curl -sf http://localhost:9010/api/log \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"jobId":"cleaner","message":"Cleaned 5 orphans","status":"ok"}'
```

**All cron jobs POST here** after each cycle.

---

### PM2 Services (Mac Mini)

**Aphos Server Prod:**
```yaml
Name: aphos-server-prod
Script: dist/index.js
CWD: /Users/felipemacmini/repos/aphos/server
Port: 2567
Env: NODE_ENV=production
Auto-Start: PM2 startup
```

**Aphos Server Dev:**
```yaml
Name: aphos-server-dev
Script: dist/index.js
CWD: /Users/felipemacmini/repos/aphos/server
Port: 2568
Env: NODE_ENV=development
Auto-Start: PM2 startup
```

**Ollama (Remote):**
```yaml
Name: ollama
Script: /opt/homebrew/bin/ollama
Args: serve
Env: OLLAMA_HOST=http://10.144.238.116:11434
Auto-Start: PM2 startup
```

**PM2 Commands:**
```bash
# SSH to Mac Mini
ssh felipemacmini@felipes-mac-mini.local

# List services
pm2 list

# Restart service
pm2 restart aphos-server-prod

# View logs
pm2 logs aphos-server-prod --lines 100

# Save config (after changes)
pm2 save
```

---

## Auto-Start Configuration

### LaunchAgents (macOS)

**MacBook Pro:**
```bash
~/Library/LaunchAgents/com.clawdbot.gateway.plist
~/Library/LaunchAgents/com.clawdbot.crabwalk.plist
~/Library/LaunchAgents/com.clawdbot.status-api.plist
/Library/LaunchDaemons/homebrew.mxcl.ollama.plist
```

**Mac Mini:**
```bash
~/Library/LaunchAgents/com.clawdbot.gateway.plist
~/Library/LaunchAgents/com.clawdbot.node.plist
~/Library/LaunchAgents/com.clawdbot.failover.plist
~/Library/LaunchAgents/com.clawdbot.system-cleanup.plist
~/Library/LaunchAgents/com.clawdbot.caffeinate.plist
```

**Manage LaunchAgents:**
```bash
# Load (enable)
launchctl load ~/Library/LaunchAgents/com.clawdbot.gateway.plist

# Unload (disable)
launchctl unload ~/Library/LaunchAgents/com.clawdbot.gateway.plist

# Start
launchctl start com.clawdbot.gateway

# Stop
launchctl stop com.clawdbot.gateway

# Check status
launchctl list | grep clawdbot
```

### Cron Jobs (macOS)

**MacBook Pro crontab:**
```bash
# Lume updater (10am daily)
0 10 * * * /Users/felipevieira/.local/bin/lume-update >/tmp/lume_updater.log 2>&1

# Git auto-sync (every 15 minutes)
*/15 * * * * /Users/felipevieira/clawd/.git-auto-sync.sh >> /tmp/clawd-sync.log 2>&1

# Clear sessions (Sunday midnight)
0 0 * * 0 /tmp/clear-clawdbot-sessions.sh > /tmp/clear-sessions.log 2>&1

# Auto-trim agents (hourly)
0 * * * * ~/.clawdbot/scripts/auto-trim-agents.sh >> ~/.clawdbot/logs/auto-trim.log 2>&1

# Crash monitor (every minute)
* * * * * ~/.clawdbot/scripts/crash-monitor.sh >> ~/.clawdbot/logs/crash-monitor.log 2>&1
```

**Clawdbot Cron Jobs** (managed via Gateway):
- See `~/.clawdbot/cron/jobs.json`
- Managed via Clawdbot Gateway (not system crontab)
- 10 active jobs (see TEAMS.md for details)

### PM2 Startup (Mac Mini)

**Setup:**
```bash
# SSH to Mac Mini
ssh felipemacmini@felipes-mac-mini.local

# Generate startup script
pm2 startup

# Save current process list
pm2 save

# Verify
pm2 list
```

**Config Location:**
```bash
~/.pm2/dump.pm2  # Saved process list
~/.pm2/logs/     # Service logs
```

---

## Health Monitoring

### Healer Team Checks (Every 2 Hours)

**MacBook Pro:**
```bash
# Swap usage
/usr/sbin/sysctl vm.swapusage

# Disk usage
df -h / | tail -1

# Ollama status
curl -sf http://localhost:11434/api/tags --max-time 5

# Crabwalk status
curl -sf http://localhost:9009 --max-time 5 -o /dev/null -w "%{http_code}"

# clawd-status API
curl -sf http://localhost:9010 --max-time 5 -o /dev/null -w "%{http_code}"
```

**Mac Mini (via SSH):**
```bash
ssh felipemacmini@felipes-mac-mini.local "
  sysctl vm.swapusage && \
  df -h / | tail -1 && \
  pm2 jlist 2>/dev/null | python3 -c 'import json,sys;[print(f\"{p[\"name\"]}: {p[\"pm2_env\"][\"status\"]}\") for p in json.load(sys.stdin)]'
"
```

**Cross-Machine Connectivity:**
```bash
# Mac Mini → MacBook Ollama
curl -sf http://felipes-mac-mini.local:11434/api/tags --max-time 5 -o /dev/null -w "%{http_code}"
```

### Cleaner Bot Checks (Every 2 Hours)

**Simulator Cleanup (Mac Mini):**
```bash
ssh felipemacmini@felipes-mac-mini.local 'ps aux | grep CoreSimulator | wc -l'
# If >20, run: xcrun simctl shutdown all
```

**Orphaned Processes (Both Machines):**
```bash
# Find orphans with PPID=1, older than 2h
ps -eo pid,ppid,etime,comm | awk '$2==1 && $3 ~ /[0-9][0-9]:[0-9][0-9]:[0-9][0-9]/'
```

**Port Conflicts:**
```bash
lsof -i :3000 -i :4000 -i :5000 -i :8080 | grep LISTEN
```

### Heartbeat Bot (Every 60 Minutes)

**Metrics Collected:**
- CPU usage (`top -l 1 | grep "CPU usage"`)
- Memory usage (`vm_stat`)
- Disk usage (`df -h /`)
- Gateway health (`curl localhost:18789`)
- Process counts (`ps aux | wc -l`)

**Output:**
- Writes to `Crabwalk/public/heartbeat-data.json`
- Crabwalk displays in modal (scrollable, real data)

---

## Failover & Recovery

### Failover Watchdog (Mac Mini → MacBook)

**Service:** LaunchAgent on Mac Mini  
**Check Interval:** Every 30 seconds  
**Failure Threshold:** 3 consecutive failures  
**Recovery Threshold:** 5 consecutive successes

**Logic:**
```bash
# Ping MacBook Gateway
curl -sf http://felipes-macbook-pro.local:18789 --max-time 5

# If 3 failures → Mac Mini takes over (enable Telegram)
# If 5 successes → Yield back to MacBook (disable Telegram)
```

**Logs:** Check Mac Mini LaunchAgent logs

### Auto-Recovery (Healer Team)

**Script:** `utils/healer-auto-recovery.sh`

**Actions:**
1. Check Gateway health (both machines)
2. Auto-restart Gateway if crashed (max 2 per run)
3. Check rate limit status (Claude API)
4. Trigger emergency mode if all accounts exhausted
5. Clean stale resource locks (Grok, Ollama)
6. Monitor swap/memory (warn if excessive)

**Emergency Mode:**
- All bots switch to Ollama-only
- Telegram alert to Felipe
- Resumes when any account cooldown expires

---

## Service Dependencies

```
┌─────────────────────────────────────────────┐
│          Clawdbot Gateway (MacBook)         │
│            Port 18789 (Telegram ON)         │
└──────────────┬──────────────────────────────┘
               │
      ┌────────┼────────┬─────────┬─────────┐
      │        │        │         │         │
┌─────▼──┐ ┌──▼───┐ ┌──▼───┐ ┌───▼───┐ ┌───▼────┐
│Ollama  │ │Crab- │ │clawd-│ │Heart- │ │ Cron   │
│11434   │ │walk  │ │status│ │beat   │ │ Jobs   │
│        │ │9009  │ │9010  │ │(60min)│ │(10+)   │
└────────┘ └──────┘ └──────┘ └───────┘ └────────┘
               │                          │
               │                          ├─→ Cleaner (2h)
               │                          ├─→ Healer (2h)
               │                          ├─→ iOS Dev (2h)
               │                          ├─→ LinkLounge (2h)
               │                          ├─→ EZ-CRM (2h)
               │                          ├─→ App Store (3x/day)
               │                          ├─→ R&D (6h)
               │                          ├─→ Shitcoin Brain (1h)
               │                          └─→ Shitcoin Quant (1h)
               │
        ┌──────▼──────┐
        │  Mac Mini   │
        │ Gateway:    │
        │  18789 (OFF)│
        ├─────────────┤
        │ PM2:        │
        │ - Aphos:    │
        │   2567,2568 │
        │ - Ollama    │
        │   (remote)  │
        └─────────────┘
```

---

## Troubleshooting

### Gateway Issues

**Problem:** Gateway not responding

**Solution:**
```bash
# Check if running
launchctl list | grep clawdbot

# View logs
tail -100 ~/.clawdbot/logs/gateway.log

# Restart
launchctl stop com.clawdbot.gateway
launchctl start com.clawdbot.gateway
```

### Ollama Issues

**Problem:** Ollama not serving models

**Solution (MacBook):**
```bash
# Check if running
launchctl list | grep ollama

# Test endpoint
curl http://localhost:11434/api/tags

# Restart
launchctl stop homebrew.mxcl.ollama
launchctl start homebrew.mxcl.ollama
```

**Solution (Mac Mini):**
```bash
# Check connection to MacBook
ssh felipemacmini@felipes-mac-mini.local 'curl -sf http://10.144.238.116:11434/api/tags'

# Restart PM2 Ollama service
ssh felipemacmini@felipes-mac-mini.local 'pm2 restart ollama'
```

### PM2 Service Issues

**Problem:** Aphos server down

**Solution:**
```bash
# SSH to Mac Mini
ssh felipemacmini@felipes-mac-mini.local

# Check status
pm2 list

# View logs
pm2 logs aphos-server-prod --lines 100

# Restart
pm2 restart aphos-server-prod

# If still failing, rebuild
cd ~/repos/aphos/server
npm run build
pm2 restart aphos-server-prod
```

### Network Issues

**Problem:** Mac Mini can't reach MacBook Ollama

**Solution:**
```bash
# Check LAN connectivity
ssh felipemacmini@felipes-mac-mini.local 'ping -c 3 10.144.238.116'

# Check Ollama is LAN-bound
lsof -i :11434

# Verify firewall allows 11434
# macOS: System Settings → Network → Firewall
```

---

**Document Status**: ✅ Complete  
**Last Review**: 2026-01-29 00:30 EST  
**Maintained By**: Main Agent + Docs Team Subagent

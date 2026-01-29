# Clawdbot Log Management Guide
**Updated:** 2026-01-29
**Maintainer:** Log Analysis Team

## Overview

This guide documents log locations, retention policies, rotation strategies, and monitoring guidelines for the Clawdbot multi-agent system.

## Quick Reference

| Log Type | Location | Retention | Rotation | Size |
|----------|----------|-----------|----------|------|
| Gateway (active) | `/tmp/clawdbot/*.log` | 7→30 days | Daily compress @ 2AM | ~5-40MB/day |
| Gateway (system) | `~/.clawdbot/logs/*.log` | 7→30 days | Daily compress @ 2AM | ~1-5MB/day |
| PM2 (Mac Mini) | `~/.pm2/logs/*.log` | 7→14 days | pm2-logrotate (10MB max) | ~1-10MB/file |
| Trading Bot | `~/repos/shitcoin-bot/logs/polybot_*.log` | 30→90 days | Monthly compress, MEGA archive | ~2-6MB/day |
| Grok Access | `~/clawd/memory/grok-access.log` | 7→30 days | Weekly compress | ~1KB/day |
| Healer Reports | `~/clawd/memory/healer-reports.log` | Never delete | Compress @ 7 days | ~1KB/event |
| Session Transcripts | `~/.clawdbot/sessions/*` | **Never delete** | N/A | Varies |

## Log Locations

### MacBook Pro

#### Gateway Logs (Main Activity)
**Location:** `/tmp/clawdbot/`

Files:
- `clawdbot-YYYY-MM-DD.log` — Main gateway log (JSON structured)
- `event-watcher.log` — File system event monitoring
- `macbook-cleanup.log` — Cleanup script output
- `shitcoin-bot-stdout.log` — Trading bot stdout redirected here
- `debug.log`, `*-stderr.log`, `*-stdout.log` — Debug streams

**Format:** JSON lines with subsystem tagging
```json
{
  "0": "{\"subsystem\":\"gateway\"}",
  "1": "listening on ws://0.0.0.0:18789 (PID 94175)",
  "_meta": {
    "date": "2026-01-28T05:02:29.749Z",
    "logLevelName": "INFO",
    ...
  }
}
```

**Subsystems:**
- `gateway` — Server lifecycle
- `diagnostic` — Queue metrics, session state
- `agent/embedded` — Agent execution timing
- `browser/*` — Browser control
- `gateway/channels/*` — Channel providers (Telegram, etc.)
- `skills` — Skill registration
- `gateway/heartbeat` — Periodic health checks

#### System Logs
**Location:** `~/.clawdbot/logs/`

Files:
- `gateway.log` — Gateway stdout (2.1MB typical)
- `gateway.err.log` — Gateway stderr (3.5MB typical)
- `auto-resume.log` — Crash recovery system
- `auto-resume-stdout.log` — Recovery stdout
- `crash-monitor.log` — Crash detection
- `watchdog.log` — Process watchdog
- `auto-trim.log` — Context trimming

**Purpose:** Long-term system health monitoring

#### Memory & Analysis
**Location:** `~/clawd/memory/`

Files:
- `grok-access.log` — Grok resource queue tracking (36 lines typical)
- `healer-reports.log` — Self-healing events (rare, critical)
- `YYYY-MM-DD.md` — Daily session notes (keep forever)
- `teams/*.md` — Multi-agent coordination logs

**Format (grok-access.log):**
```
YYYY-MM-DDTHH:MM:SSZ | bot-name | EVENT | details
2026-01-28T20:18:01Z | test-bot | LOCK_ACQUIRED | attempt=1
2026-01-28T20:18:03Z | headless | ERROR | failed_to_open_page
```

#### Temp Files
**Location:** `/tmp/`

Common files:
- `ollama.log`, `ollama-error.log` — Model server
- `exo-macbook.log` — Distributed inference
- `*-pull.log` — Model downloads (DELETE after pull)
- `*-dev.log`, `*-expo.log` — Dev servers (keep 7 days)
- `crabwalk-error.log` — Dashboard errors

### Mac Mini

#### PM2 Logs (Process Manager)
**Location:** `~/.pm2/logs/`

Files:
- `clawdbot-gateway-error.log` — Gateway errors (6MB typical, **NEEDS ROTATION**)
- `clawdbot-gateway-out.log` — Gateway stdout (2.8MB typical)
- `ollama-out.log`, `ollama-error.log` — Model server
- `aphos-server-prod-out.log` — Game server
- `aphos-server-prod-error.log` — Game errors

**Problem:** PM2 does NOT auto-rotate logs!

**Solution:** Install `pm2-logrotate`:
```bash
pm2 install pm2-logrotate
pm2 set pm2-logrotate:max_size 10M
pm2 set pm2-logrotate:retain 7
pm2 set pm2-logrotate:compress true
```

#### Trading Bot Logs (CRITICAL)
**Location:** `~/repos/shitcoin-bot/logs/`

Files:
- `polybot_YYYYMMDD.log` — Daily trading activity

**Content:** Trade execution, P&L, wallet operations, market analysis

**Retention:** 90 days (tax/compliance/audit)
- Day 1-30: Keep uncompressed for quick access
- Day 30-90: Compress with gzip
- After 90 days: Archive to MEGA (don't auto-delete!)

**Special Handling:**
```bash
# Monthly archive script (run manually or cron)
cd ~/repos/shitcoin-bot/logs
find . -name "polybot_*.log" -mtime +30 ! -name "*.gz" -exec gzip {} \;

# After 90 days, MEGA sync (manual approval required)
find . -name "polybot_*.log.gz" -mtime +90 -exec echo "Ready for MEGA: {}" \;
```

#### Other Repo Logs
- `~/repos/aphos/logs/` — Game server (484KB)
- `~/repos/aramranked/logs/` — Ranked tracker (1.6MB)
- `~/repos/ez-crm/logs/` — CRM system (1.3MB)

All safe to rotate with standard 7→30 day policy.

## Retention Policies

### General Principles

1. **Debug logs:** Short retention (7→30 days)
2. **Trading/financial:** Long retention (90 days + archive)
3. **Learning logs:** Never delete (healer, memory)
4. **Session transcripts:** Never delete (long-term memory)
5. **Temp files:** Aggressive cleanup (7 days max)

### By Log Category

#### Category A: Debug & Development (7→30 days)
- Gateway logs
- PM2 logs
- Dev server logs
- Browser control logs
- Diagnostic logs

**Why short:** Rarely needed after 1 week, high volume

#### Category B: Trading & Compliance (30→90 days → MEGA)
- Shitcoin bot trading logs
- Wallet operation logs
- P&L calculations

**Why long:** Tax reporting, audit trail, legal compliance

#### Category C: Learning & Analysis (7→30 days compressed)
- Grok access logs
- Resource queue metrics
- Model performance logs

**Why compress:** Useful for optimization, but low query frequency

#### Category D: Critical System Health (Never Delete)
- Healer reports
- Crash logs (after review)
- Session transcripts
- Memory markdown files

**Why permanent:** Learn from failures, track long-term patterns

## Rotation Commands

### Manual Rotation (All Machines)

```bash
# Run the rotation script (MacBook Pro)
~/clawd/utils/rotate-logs.sh

# View rotation history
tail -f ~/clawd/logs/rotation.log
```

### Automatic Rotation (Cron)

Add to crontab (`crontab -e`):
```bash
# Daily log rotation at 2 AM
0 2 * * * ~/clawd/utils/rotate-logs.sh >> ~/clawd/logs/rotation.log 2>&1
```

### PM2 Rotation (Mac Mini)

```bash
# One-time setup
ssh felipemacmini@felipes-mac-mini.local
pm2 install pm2-logrotate
pm2 set pm2-logrotate:max_size 10M
pm2 set pm2-logrotate:retain 7
pm2 set pm2-logrotate:compress true

# Verify
pm2 conf pm2-logrotate
```

### Trading Log Archive (Mac Mini - Monthly)

```bash
# Compress old trading logs (30+ days)
ssh felipemacmini@felipes-mac-mini.local "
cd ~/repos/shitcoin-bot/logs
find . -name 'polybot_*.log' -mtime +30 ! -name '*.gz' -exec gzip {} \;
"

# Identify logs ready for MEGA archive (90+ days)
ssh felipemacmini@felipes-mac-mini.local "
cd ~/repos/shitcoin-bot/logs
find . -name 'polybot_*.log.gz' -mtime +90 -ls
"

# Manual MEGA sync (requires approval)
# 1. Download from Mac Mini to MacBook
# 2. Upload to MEGA: /Backups/shitcoin-bot/logs/YYYY-MM/
# 3. Delete from Mac Mini ONLY after verified in MEGA
```

## Monitoring Guidelines

### Daily Checks

```bash
# Check log sizes (alert if >50MB in /tmp/clawdbot)
du -sh /tmp/clawdbot

# Check for large individual logs (alert if >10MB)
find /tmp/clawdbot -name "*.log" -size +10M -ls

# Check PM2 logs on Mac Mini
ssh felipemacmini@felipes-mac-mini.local "du -sh ~/.pm2/logs"
```

### Weekly Review

```bash
# Check archive growth
du -sh ~/clawd/logs/archive

# Review Grok access patterns
tail -50 ~/clawd/memory/grok-access.log

# Check for rotation failures
grep -i error ~/clawd/logs/rotation.log | tail -20
```

### Monthly Tasks

1. Review trading log archive status
2. Verify MEGA backups are current
3. Clean up old model pull logs
4. Check for disk space issues

## Troubleshooting

### Problem: Log file too large (>100MB)

```bash
# Check what's writing to it
lsof | grep <logfile>

# Manual compress
gzip <logfile>

# If still active, truncate instead
> <logfile>  # Caution: loses data!
```

### Problem: Rotation script not running

```bash
# Check cron status
crontab -l

# Check rotation log for errors
tail -50 ~/clawd/logs/rotation.log

# Test rotation manually
~/clawd/utils/rotate-logs.sh
```

### Problem: PM2 logs still growing

```bash
# Check pm2-logrotate status
pm2 ls pm2-logrotate

# Reinstall if needed
pm2 uninstall pm2-logrotate
pm2 install pm2-logrotate
# ... reconfigure ...
```

### Problem: Disk space low

```bash
# Find largest logs
find /tmp -name "*.log" -type f -exec du -h {} \; | sort -rh | head -20

# Emergency cleanup
rm -f /tmp/*-pull.log  # Model downloads
find /tmp -name "*.log" -mtime +7 -delete  # Old temp logs

# Compress without archiving
find /tmp/clawdbot -name "*.log" -mtime +1 ! -name "$(date +%Y-%m-%d)*" -exec gzip {} \;
```

## Analysis & Debugging

### Searching Gateway Logs

```bash
# Find errors in last 24 hours
find /tmp/clawdbot -name "clawdbot-$(date +%Y-%m-%d).log" -exec grep -i error {} \;

# Count errors by subsystem
zgrep -h '"logLevelName":"ERROR"' /tmp/clawdbot/*.log* | \
  jq -r '."0" | match("{\"subsystem\":\"([^\"]+)\"") | .captures[0].string' | \
  sort | uniq -c | sort -rn

# Trace a specific session
grep "sessionId=<ID>" /tmp/clawdbot/clawdbot-*.log
```

### Grok Access Analysis

```bash
# Bots using Grok most
awk -F'|' '{print $2}' ~/clawd/memory/grok-access.log | \
  sort | uniq -c | sort -rn

# Failure rate
grep -c "ERROR" ~/clawd/memory/grok-access.log
grep -c "LOCK_ACQUIRED" ~/clawd/memory/grok-access.log

# Average wait time (if implemented)
# TBD: Add wait_ms field to log format
```

### Trading Log Review

```bash
# Recent trades (Mac Mini)
ssh felipemacmini@felipes-mac-mini.local "
tail -100 ~/repos/shitcoin-bot/logs/polybot_$(date +%Y%m%d).log | grep TRADE
"

# P&L summary (requires log parsing script)
# TBD: Create trading log parser
```

## Log Formats Reference

### Gateway JSON Log
```json
{
  "0": "{\"subsystem\":\"gateway\"}",
  "1": "message text",
  "_meta": {
    "runtime": "node",
    "runtimeVersion": "25.4.0",
    "date": "2026-01-28T05:02:29.749Z",
    "logLevelId": 3,
    "logLevelName": "INFO",
    "path": {
      "fileName": "subsystem.js",
      "fileLine": "161"
    }
  },
  "time": "2026-01-28T05:02:29.749Z"
}
```

### Grok Access Log
```
TIMESTAMP | bot-name | EVENT | key=value key=value
```

Events:
- `LOCK_ACQUIRED` — Bot acquired Grok lock
- `LOCK_RELEASED` — Bot released lock
- `headless ATTEMPT` — Headless browser attempt
- `headless ERROR` — Failed to open page
- `TIMEOUT` — Lock acquisition timeout

## Size Benchmarks

Based on analysis of 2026-01-28/29 data:

| Log Type | Daily Size | Weekly Size | Monthly Size |
|----------|-----------|-------------|--------------|
| Gateway (active) | 5-40MB | 50-250MB | 200MB-1GB |
| Gateway (system) | 1-5MB | 10-30MB | 40-120MB |
| PM2 logs | 1-3MB | 10-20MB | 40-80MB |
| Trading bot | 2-6MB | 15-40MB | 60-180MB |
| Grok access | <1KB | <10KB | <50KB |
| Dev servers | 1-10MB | (ephemeral) | (ephemeral) |

**Total Expected:** ~500MB-1.5GB/month before rotation

**After Rotation:** ~100-300MB/month retained

## Related Documentation

- `~/clawd/AGENTS.md` — Memory system overview
- `~/clawd/memory/2026-01-29-log-analysis.md` — Full analysis report
- `~/clawd/utils/rotate-logs.sh` — Rotation script
- `~/clawd/RESOURCE-QUEUE-USAGE.md` — Grok/Ollama coordination

## Changelog

### 2026-01-29
- Initial version created by Log Analysis Team
- Analyzed 115MB of logs across MacBook Pro + Mac Mini
- Defined retention policies by category
- Updated rotation script with multi-tier strategy
- Documented PM2 rotation issue + solution

---

**Questions or Issues?**
- Check `~/clawd/memory/YYYY-MM-DD.md` for daily context
- Review rotation log: `~/clawd/logs/rotation.log`
- Test rotation manually: `~/clawd/utils/rotate-logs.sh`

# Persistent Bot Architecture

Documentation for running 24/7 specialist bots on Mac Mini.

## Overview (Updated 2026-01-26)

```

                    MAC MINI BOT FACTORY

                                                             
   Tier 1: Bash Scripts (FREE, every 15 min)
    mac-mini-cleanup.sh -> /tmp/clawdbot/system-health.json
    - Kill simulators, zombies, duplicate processes
    - Clean temp files, old screenshots
    - Check memory/disk/service health
    
                                                             
   Tier 2: Clawdbot Cron Jobs (Sonnet, isolated)
    Shitcoin Brain -> :15, :45 hourly (research)
    Shitcoin Quant -> :00, :30 hourly (quant strategy)
    System Health -> :05 every 2h (reads bash output)
    Clear Sessions -> Sunday midnight (weekly cleanup)
    
                                                             
   Tier 3: Persistent Services (launchd)
    Clawdbot Gateway (port 18789, always running)
    Python Trading Bot (run_bots, always running)
    Failover Watchdog (monitors MacBook)
    Clawdbot Node (connects to MacBook gateway)
    
                                                             

```

## Cron Jobs (Clawdbot Built-In)

All automated agents run as **isolated cron jobs** with fresh context each run.
Replaced old bash loop scripts (which accumulated context and burned Opus tokens).

**Currently Active** (as of 2026-01-27):

| Job | Schedule | Model | Purpose |
|-----|----------|-------|---------|
| Healer Bot v3 | Hourly | Sonnet 4.5 | Self-healing, swap monitoring, cross-machine failover |
| Cleaner Bot | Hourly | Sonnet 4.5 | Deep cleanup, resource management |
| App Store Manager | 3x daily (9 AM, 3 PM, 9 PM EST) | qwen3:8b | iOS app monitoring |

**System-Level Cron** (via crontab -l):

| Job | Schedule | Purpose |
|-----|----------|---------|
| lume-update | 10:00 AM daily | Lume updater maintenance |
| clawd git sync | Every 15 min | Auto-sync workspace changes |
| Clear Sessions | Sunday midnight | Weekly session cleanup |

### Why Cron > Bash Loops (Migration 2026-01-26)
- **Fresh context each run** -> no token accumulation, predictable costs
- **Sonnet model** -> ~70% cheaper than Opus for research tasks
- **File-based memory** -> research persists via markdown files
- **Proper scheduling** -> no sleep drift, visible in `clawdbot cron list`

### Memory Architecture (File-Based Persistence)
```
~/clawd/memory/shitcoin-brain/
 YYYY-MM-DD.md # Daily research notes (Brain writes)
 strategy-ideas.md # Quant strategy concepts (Quant appends)
 market-analysis.md # Latest market conditions (Quant overwrites)
 swarm-research.md # Framework research notes
```

Each cron run: Read files -> Work -> Write results -> End. Cost: ~$0.01-0.10/run.

### Managing Cron Jobs
```bash
clawdbot cron list # List all jobs
clawdbot cron runs --id <jobId> # Check recent runs
clawdbot cron edit <jobId> --disable # Disable a job
clawdbot cron edit <jobId> --enable # Enable a job
clawdbot cron run --id <jobId> # Run immediately
```

## Bash Cleanup Scripts (Zero Tokens)

Runs every 15 min via launchd. No LLM tokens consumed.

| Script | Machine | Output |
|--------|---------|--------|
| mac-mini-cleanup.sh | Mac Mini | /tmp/clawdbot/system-health.json |
| macbook-cleanup.sh | MacBook | /tmp/clawdbot/macbook-health.json |

Cleans: simulators, zombies, duplicates, temp files. Monitors: memory, disk, services.

## LaunchAgents (Always-On)

| LaunchAgent | Service |
|-------------|---------|
| com.clawdbot.gateway | Clawdbot Gateway (port 18789) |
| com.clawdbot.shitcoin-bot | Python trading bot |
| com.clawdbot.system-cleanup | Bash cleanup (every 15 min) |
| com.clawdbot.failover | MacBook health monitor |
| com.clawdbot.node | Clawdbot node |

## Cost Optimization

```
Tier 1: Bash (FREE) — mechanical cleanup every 15 min
Tier 2: Sonnet (~$0.05/run) — research every 30 min, health every 2h
Tier 3: Opus (~$0.10/run) — heartbeat connectivity check only
Daily estimate: ~$3-5/day (was ~$15+/day before migration)
```

## Deprecated (Removed 2026-01-26)
- [NO] run-shitcoin-brain.sh (replaced by cron)
- [NO] run-shitcoin-quant.sh (replaced by cron)
- [NO] Persistent session IDs
- [NO] health-check-bots cron (replaced by System Health Monitor)
- [NO] 9-bot tmux architecture (simplified to cron + launchd)

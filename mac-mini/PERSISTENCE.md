# Bot Persistence Strategy

How to keep bots running 24/7 without burning tokens.

## Architecture Overview

```

                   ALWAYS-ON LAYER
  (OS-level, zero token cost)
                                                     
  LaunchAgents:
  - Aphos game servers (2567, 2568, 4000, 4001)
  - Shitcoin bot (Polymarket trading)
  - Clawdbot gateway
  - Failover watchdog
  - Node service

                        
                        

                 PERIODIC AI LAYER
  (Token-efficient, scheduled)
                                                     
  Heartbeat (every 30m):
  - Check bot health
  - Monitor positions/trades
  - Review calendar/inbox
  - Proactive check-ins
                                                     
  Cron (exact times):
  - Daily trading summary (9am)
  - Weekly game review (Monday)
  - One-shot reminders

                        
                        

                 ON-DEMAND AI LAYER
  (Only when needed)
                                                     
  Sub-agents:
  - Heavy coding tasks
  - Research/analysis
  - Multi-step workflows
                                                     
  Direct messages:
  - User requests via Telegram
  - Alerts from monitoring

```

## Why NOT Ralph Wiggum for Always-On

The [Ralph Wiggum technique](https://ghuntley.com/ralph/) is a bash loop:
```bash
while :; do cat PROMPT.md | claude-code; done
```

**Good for**: Greenfield coding marathons, building entire projects AFK, iterative development.

**Bad for always-on bots because**:
- Burns tokens **continuously** even when idle (no sleep between iterations)
- No scheduling control (can't say "check at 9am")
- No multi-service awareness (doesn't know about heartbeats, cron, etc.)
- No message routing (can't receive Telegram messages)
- Single-task focused (one prompt, one loop)
- Context resets every iteration (by design)

## What We Use Instead

### 1. LaunchAgents (OS-Level Persistence)
- **Cost**: Zero tokens
- **Reliability**: macOS auto-restarts on crash
- **Use for**: Game servers, trading bots, watchdogs, gateways

### 2. Heartbeat (Periodic AI Check-in)
- **Cost**: ~1 agent turn per 30 minutes
- **Reliability**: Built into Clawdbot, survives restarts
- **Use for**: Health monitoring, batched checks, proactive messages

### 3. Cron Jobs (Scheduled Tasks)
- **Cost**: Only when triggered
- **Reliability**: Exact timing, isolated sessions
- **Use for**: Daily reports, weekly reviews, one-shot reminders

### 4. Sub-agents (Parallel Work)
- **Cost**: Per-task
- **Reliability**: Isolated sessions, announce results
- **Use for**: Heavy coding, research, analysis

## Configuration

### Heartbeat Config (in clawdbot.json):
```json
{
  "agents": {
    "defaults": {
      "heartbeat": {
        "every": "30m",
        "target": "last",
        "activeHours": { "start": "08:00", "end": "24:00" }
      }
    }
  }
}
```

### Cron Examples:
```bash
# Daily trading summary at 9am
clawdbot cron add --name "Trading Summary" --cron "0 9 * * *" --tz "America/New_York" --message "Generate daily Polymarket trading summary"

# Weekly game review on Mondays
clawdbot cron add --name "Game Review" --cron "0 10 * * 1" --tz "America/New_York" --message "Review Aphos game status, test features, plan next sprint"
```

## Comparison Table

| Method | Token Cost | Timing | Context | Best For |
|--------|-----------|--------|---------|----------|
| LaunchAgent | Zero | Always-on | None (OS process) | Servers, bots, watchers |
| Heartbeat | Low (~1/30m) | Approximate | Full main session | Monitoring, check-ins |
| Cron | Low (on trigger) | Exact | Isolated | Reports, reminders |
| Sub-agent | Medium | On-demand | Isolated | Heavy tasks |
| Ralph loop | **HIGH** | Continuous | Fresh each loop | Coding sprints only |

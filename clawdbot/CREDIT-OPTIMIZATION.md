# Claude Credit Optimization

Strategies to reduce Claude API usage while maintaining productivity.

## Bot Cycle Timing

| Bot Type | Pause Between Cycles | Daily Activations |
|----------|---------------------|-------------------|
| Dev bots | 10 minutes | ~144/day |
| Research (shitcoin-brain) | 30 minutes | ~48/day |
| **Old config** | 60 seconds | ~1440/day |

**Savings: ~90% reduction in API calls**

## Multi-Account Failover

When primary account hits rate limit (429), automatically switch to backup.

### Setup
1. Primary account: Default Claude login
2. Backup account: OAuth token in `~/.claude-wisedigital/oauth-token`
3. Wrapper script: `~/.clawd/scripts/claude-multi`

### Configuration
```json
// ~/.clawdbot/clawdbot.json
{
  "agents": {
    "defaults": {
      "cliBackends": {
        "claude-cli": {
          "command": "/Users/<user>/.clawd/scripts/claude-multi"
        }
      }
    }
  }
}
```

## Use Free Resources First

Before asking Claude, bots should check:

1. **Grok (x.com/i/grok)** - Free with X account
   - Debugging help
   - Code explanations
   - Research questions

2. **X/Twitter Search** - `bird search "error message"`
   - Real-time solutions
   - Library issues
   - Community fixes

3. **Reddit** - r/reactnative, r/nextjs, r/gamedev
   - Common problems
   - Best practices
   - Package recommendations

4. **Stack Overflow** - web_fetch or browser
   - Error solutions
   - Code examples

## Avoid Wasteful Patterns

### Do NOT
- ❌ Start browser if Chrome extension not connected
- ❌ Run simulator tests every cycle
- ❌ Duplicate cron jobs with persistent bots
- ❌ Short pause times (< 5 min)

### DO
- ✅ Check `~/clawd/scripts/check-browser.sh` before browser use
- ✅ Use simulator only when needed for testing
- ✅ Minimal cron (health check only)
- ✅ 10+ minute pauses between cycles

## Dashboard Token Safety

The clawd-monitor dashboard does NOT consume AI tokens.

**Safe operations (no tokens):**
- `clawdbot status --json`
- File reads (~/.clawdbot/*)
- tmux log scraping
- SSH resource checks

**Token-consuming (user-initiated only):**
- Chat dialog messages
- Manual agent commands

## Monitoring Usage

Check current token usage:
```bash
clawdbot status --json | jq .usage
```

Check auth profile cooldowns:
```bash
cat ~/.clawdbot/agents/main/agent/auth-profiles.json | jq .usageStats
```

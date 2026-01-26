# Clawd Monitor Integration

> Real-time orchestrator ↔ dashboard synergy

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    MONITORING SYSTEM                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Option A: General Status (JSON)                            │
│  └── ~/clawd/monitor/bot-status.json                        │
│      Updated: Every minute via cron                         │
│      Contains: Bot status, last activity                    │
│                                                             │
│  Option B: Real-time Data                                   │
│  ├── ~/clawd/monitor/realtime-resources.json                │
│  │   Updated: Every minute                                  │
│  │   Contains: CPU, memory, PIDs per bot                    │
│  └── ~/clawd/monitor/realtime-events.jsonl                  │
│      Updated: On each event                                 │
│      Contains: Start/stop/actions/errors (last 1000)        │
│                                                             │
│  Option C: SQLite Database                                  │
│  └── ~/clawd/monitor/bot-logs.db                            │
│      Tables:                                                │
│      - bot_events (crashes, errors, warnings)               │
│      - bot_actions (commits, builds, deploys)               │
│      - bot_communications (inter-bot messages)              │
│      - resource_usage (historical data)                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Security

**Bot communication is secure by design:**
- All bots run on same Mac Mini (localhost only)
- No external network exposure
- Files readable only by felipemacmini user
- Gateway uses local WebSocket (127.0.0.1:18789)
- SQLite is local file, no network access

**For sensitive data:**
- Use `bot_communications.encrypted = 1` flag
- Implement AES encryption in scripts if needed
- API keys/tokens stored in ~/.clawdbot/credentials/

## Data Sources

### bot-status.json (Option A)
```json
{
  "lastUpdate": "2026-01-26T21:15:00Z",
  "gateway": 1,
  "bots": {
    "ez-crm": {"status": "running", "lastActivity": "..."},
    "linklounge": {"status": "running", "lastActivity": "..."}
  }
}
```

### realtime-resources.json (Option B)
```json
{
  "timestamp": "2026-01-26T21:15:14Z",
  "system": {"cpu": 74.16, "memory": 261053},
  "bots": {
    "ez-crm": {"pid": 94090, "cpu": 0.0, "memMb": 0.92},
    "gateway": {"pid": 9112, "cpu": 0.0, "memMb": 42.6}
  }
}
```

### realtime-events.jsonl (Option B)
```jsonl
{"timestamp":"...","bot":"ez-crm","type":"start","severity":"info","message":"Bot started"}
{"timestamp":"...","bot":"aphos","type":"action","action":"commit","project":"aphos","success":true}
```

### SQLite Tables (Option C)

```sql
-- Important events (crashes, errors)
SELECT * FROM bot_events WHERE severity = error ORDER BY timestamp DESC;

-- Recent actions
SELECT * FROM bot_actions ORDER BY timestamp DESC LIMIT 50;

-- Bot communications
SELECT * FROM bot_communications WHERE from_bot = orchestrator;
```

## Logging from Bots

Bots can log events using helper scripts:

```bash
# Log an event
~/clawd/scripts/log-bot-event.sh "ez-crm" "error" "critical" "Build failed" {error:...}

# Log an action
~/clawd/scripts/log-bot-action.sh "aphos" "commit" "aphos" "Fixed combat bug" 1 5000
```

## Clawd-Monitor Dashboard Integration

```javascript
// API route: /api/status
import fs from fs;
import Database from better-sqlite3;

export async function GET() {
  const status = JSON.parse(fs.readFileSync(~/clawd/monitor/bot-status.json));
  const resources = JSON.parse(fs.readFileSync(~/clawd/monitor/realtime-resources.json));
  
  const db = new Database(~/clawd/monitor/bot-logs.db);
  const recentEvents = db.prepare(`
    SELECT * FROM bot_events 
    ORDER BY timestamp DESC LIMIT 20
  `).all();
  
  return Response.json({ status, resources, recentEvents });
}
```

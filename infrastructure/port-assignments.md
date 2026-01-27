# Port Assignments — Master Registry

All assigned ports across all machines. **Check this before using any port.**

## Port Registry

| Port | Service | Machine | Project | Notes |
|------|---------|---------|---------|-------|
| 2567 | Aphos Prod Server | Mac Mini | Aphos | Colyseus game server (pm2) |
| 2568 | Aphos Dev Server | Mac Mini | Aphos | Colyseus dev server (pm2) |
| 2569-2599 | Aphos Reserved | Mac Mini | Aphos | Future game server instances |
| 3000 | EZ-CRM Dev | MacBook | EZ-CRM | Next.js dev server |
| 3001-3099 | EZ-CRM Reserved | MacBook | EZ-CRM | Additional services |
| 4000 | Aphos Web | MacBook | Aphos | Next.js frontend |
| 4001-4099 | Aphos Web Reserved | MacBook | Aphos | Additional services |
| 5000 | Shitcoin Bot | MacBook | Shitcoin Bot | Python web interface (if needed) |
| 5001-5099 | Shitcoin Reserved | MacBook | Shitcoin Bot | Additional services |
| 8081 | BMI Calculator Expo | MacBook | BMI Calculator | Expo web dev server |
| 8082 | Bills Tracker Expo | MacBook | Bills Tracker | Expo web dev server |
| 8083 | Screen Translator Expo | MacBook | Screen Translator | Expo web dev server |
| 9009 | clawd-monitor | Mac Mini | clawd-monitor | Dashboard web UI |
| 9000-9099 | Monitor Reserved | Mac Mini | clawd-monitor | WebSocket, API, etc. |
| 11434 | Ollama | Both Macs | Infrastructure | LLM inference server |
| 18789 | Clawdbot Gateway | Both Macs | Infrastructure | AI orchestrator |
| 18791 | Clawdbot Browser Control | Both Macs | Infrastructure | Browser automation |

## Port Ranges by Project

| Range | Project | Owner |
|-------|---------|-------|
| 2567-2599 | Aphos game servers | Mac Mini |
| 3000-3099 | EZ-CRM | MacBook |
| 4000-4099 | Aphos web | MacBook |
| 5000-5099 | Shitcoin Bot | MacBook |
| 6000-6099 | Documentation/tool servers | Available for docs examples |
| 7000-7099 | ide-configs examples/tests | Available for examples |
| 8081-8083 | Expo apps (fixed) | MacBook |
| 9000-9099 | clawd-monitor | Mac Mini |
| 11434 | Ollama (standard) | Both Macs |
| 18789-18799 | Clawdbot infrastructure | Both Macs |

## Rules

1. **Check before using** — Always run `lsof -i :<port> | grep LISTEN` before starting a server
2. **No conflicts** — Never start a service on a port assigned to another project
3. **Document new ports** — Update this file when adding new services
4. **Use assigned ranges** — Each project has a reserved range; use ports within your range
5. **Example/test ports** — When writing documentation examples, use ports 6000-6099 or 7000-7099

## Quick Check Commands

```bash
# Check all assigned ports at once
lsof -i :2567 -i :2568 -i :3000 -i :4000 -i :5000 -i :8081 -i :8082 -i :8083 -i :9009 -i :11434 -i :18789 | grep LISTEN

# Check a specific port
lsof -i :3000

# Find and kill process on a port
kill $(lsof -t -i :3000)
```

## References

- [Three-Machine Architecture](three-machine-architecture.md) — Full infrastructure overview
- [Aphos Servers](../aphos-servers.md) — Game server details
- [Clawdbot Config](../clawdbot-config.md) — Gateway and service config

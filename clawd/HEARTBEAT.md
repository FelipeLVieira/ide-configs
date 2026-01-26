# HEARTBEAT.md - Game Development Monitoring

## 🤖 Orchestrator Check (PRIORITY)
- Check if `orchestrator-persistent` is running via `sessions_list`
- If not running, spawn a new one with the persistent orchestrator task
- Orchestrator manages all project bots automatically

## 🎮 Aphos Game Development Tasks
- **Game Server Check**: Ensure localhost:2567 is running (Colyseus WebSocket)
- **Player Testing**: Periodically test game functionality  
- **Performance Monitoring**: Check for console errors or issues
- **Feature Testing**: Verify spell system, multiplayer, UI responses
- **Next Implementation**: Structure building (Grok's #1 suggestion)

## 🔀 Dual Environment Setup
- **Production (port 2567)**: `data/storage/` - Felipe tests here
- **Development (port 2568)**: `data/storage-dev/` - Bots develop here
- **Frontend Prod (port 4000)**: Connects to 2567 - Felipe plays here
- **Frontend Dev (port 4001)**: Connects to 2568 - Bots test UI here
- **Commands**: `pnpm dev:server:prod` or `pnpm dev:server:dev`
- **Schema sync**: `pnpm db:sync prod dev` (or `dev prod`)
- **Docs**: `~/repos/aphos/docs/DUAL-ENVIRONMENT.md`

## Schedule:
- Every ~2 hours: Quick game test (connect, cast spell, verify functions)
- Daily: Review and implement next Grok suggestion
- Weekly: Major feature review and polish

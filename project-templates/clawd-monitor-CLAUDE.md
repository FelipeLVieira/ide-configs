# Clawd Monitor - Project Instructions

## Project Overview
Real-time dashboard for monitoring Clawdbot sessions, sub-agents, and system resources. Shows bot hierarchy, context usage, and health status.

## Tech Stack
- **Framework**: Next.js 15 (App Router)
- **Styling**: Tailwind CSS, Shadcn/UI
- **State**: SWR for data fetching
- **API**: Clawdbot CLI integration

## Architecture
- Server-side API routes calling `clawdbot` CLI
- In-memory caching for fast responses
- Real-time refresh (10s sessions, 30s usage)
- PWA support for mobile access

## Key Features
- Bot hierarchy visualization (main + subagents)
- Context usage monitoring per session
- Server health checks (ports)
- Claude subscription status
- Auto-refresh with countdown

## Key Files
- `src/app/api/sessions/route.ts` - Session list API
- `src/app/api/clawdbot/health/route.ts` - Health check
- `src/components/dashboard/BotHierarchy.tsx` - Bot tree view
- `src/components/dashboard/ClaudeUsage.tsx` - Usage stats
- `src/hooks/useSessions.ts` - Data fetching hook

## Personas
- **Frontend Developer**: Dashboard UI, real-time updates
- **API Developer**: CLI integration, caching

## Key Principles
- Fast responses (caching required)
- Auto-refresh without user action
- Clear visualization of bot status
- Mobile-friendly PWA

## Key Commands
```bash
npm run dev # Start dev server (port 9000)
npm run build # Production build
npm run lint # Lint code
```

## Port Assignment
- 9000: clawd-monitor dashboard

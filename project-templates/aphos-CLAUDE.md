# APHOS - Project Instructions

## Project Overview
Real Earth MMORPG with fantasy/modern elements. Channel-based social auto-battle RPG inspired by Ragnarok Online, Final Fantasy, and Chrono Trigger. Mobile-first with strategic skill queue combat.

## Tech Stack
- **Frontend**: Next.js 15 (App Router), React, TypeScript
- **Styling**: Tailwind CSS
- **State**: Zustand
- **Game Server**: Colyseus (WebSocket multiplayer)
- **Database**: JSON file storage (development), PostgreSQL (production)
- **3D/Rendering**: React Three Fiber (R3F) for 2.5D effects
- **Mobile**: Capacitor 6 (iOS/Android)
- **Testing**: Playwright, Vitest
- **Monorepo**: pnpm workspaces

## Dual Environment Setup
- **Production**: Server 2567 + Frontend 4000 + `data/storage/`
- **Development**: Server 2568 + Frontend 4001 + `data/storage-dev/`
- **Commands**: `pnpm dev:server:prod` or `pnpm dev:server:dev`
- **Schema sync**: `pnpm db:sync prod dev` (or `dev prod`)
- **Docs**: `docs/DUAL-ENVIRONMENT.md`

## Architecture
- Server-authoritative multiplayer (Colyseus rooms)
- Atomic transactions for all game actions
- Channel-based navigation (Discord-like lobbies)
- Skill queue auto-battle combat system
- Privacy-first chat (in-memory, not persisted)

## Personas (Select Based on Task)
- **Game Systems Designer**: Combat balancing, skill trees, economy, progression
- **Senior Frontend Engineer**: React components, R3F rendering, mobile-first UI
- **Backend/Multiplayer Engineer**: Colyseus rooms, server authority, atomic transactions
- **Mobile Developer**: Capacitor, iOS/Android optimization, touch controls
- **Pixel Art Director**: 32x64 sprites, 2.5D perspective, animation frames

## Code Conventions
- Functional React with hooks, no class components
- Zustand stores for game state
- All game logic server-authoritative (validate on backend)
- Mobile-first responsive design (vertical layout, thumb-friendly)
- TypeScript strict mode, explicit types for game entities
- Test UI on localhost:4001 (dev) before pushing

## Key Principles
- KISS over cleverness - game code must be debuggable
- Fail-fast for exploits - reject invalid actions immediately
- Atomic transactions - no partial state updates
- Memory leak prevention - cleanup all subscriptions/listeners
- Performance-first for mobile - optimize render cycles
- Use video-frames skill to verify UI at all screen sizes

## Game Systems
- **Stats**: STR/AGI/VIT/INT/DEX/LUK (Ragnarok Online inspired)
- **Classes**: 20+ classes (Novice -> Advanced)
- **Combat**: Skill queue preparation -> auto-execution
- **Channels**: Real world cities (Tokyo, New York, London, etc.)
- **Elements**: Neutral, Fire, Water, Earth, Wind, Holy, Dark, Poison, Ghost, Undead

## Documentation
- /docs/GAME_DESIGN.md - Full game mechanics
- /docs/ARCHITECTURE.md - Technical decisions
- /docs/COMBAT-SYSTEM.md - Battle system details
- /docs/ART_STYLE.md - Pixel art guidelines
- /docs/DUAL-ENVIRONMENT.md - Dev/Prod setup

## Key Commands
```bash
pnpm dev # Start all (web + server prod)
pnpm dev:server:prod # Production server (2567)
pnpm dev:server:dev # Development server (2568)
pnpm dev:web # Web frontend (4000)
pnpm build # Production build
pnpm test # Run tests
pnpm db:sync prod dev # Sync database schema
```

## Port Assignments
- 2567: Game server (production)
- 2568: Game server (development)
- 4000: Web frontend (production)
- 4001: Web frontend (development)

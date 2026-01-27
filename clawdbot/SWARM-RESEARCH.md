# Multi-Agent Swarm Frameworks Research

## MoonDev Tweet Analysis
**Source:** @MoonDevOnYT - "99% of claude trading bots on X are slop"
**Key insight:** Focus on quant-level strategies (Jim Simons approach), not just copy trading.
**Actionable for shitcoin-bot:** Research proper quant strategies, statistical arbitrage, mean reversion.

## Claude-Exclusive Swarm Frameworks

### 1. Claude-Flow ⭐ (Most Mature)
- **GitHub:** https://github.com/ruvnet/claude-flow
- **Install:** `npx claude-flow`
- **What it does:** 60+ specialized agents in coordinated swarms
- **Features:** Self-learning, fault-tolerant consensus, RAG integration, MCP protocol
- **Architecture:** Router → Swarm → Agents → Memory → Learning Loop
- **Agent types:** Coder, Tester, Reviewer, Architect, Security, DevOps...
- **Topology:** Mesh, hierarchical, ring, star patterns
- **Best for:** Large-scale multi-agent orchestration

### 2. ccswarm (Rust-Native)
- **GitHub:** https://github.com/nwiizo/ccswarm
- **What it does:** Multi-agent with Git worktree isolation
- **Key feature:** Each agent gets isolated workspace (no conflicts!)
- **Uses ACP** (Agent Client Protocol) for Claude Code integration
- **Best for:** Development teams, parallel coding without conflicts

### 3. Claude Agent Framework
- **GitHub:** https://github.com/ciscoittech/claude-agent-framework
- **What it does:** Turns Claude Code into parallel specialized agents
- **Best for:** Production-ready multi-agent setups

### 4. Auto-Claude
- **GitHub:** https://github.com/AndyMik90/Auto-Claude
- **What it does:** Autonomous multi-session Kanban-style coordination
- **Best for:** Self-managing project workflows

### 5. SuperClaude Framework
- **GitHub:** https://github.com/SuperClaude-Org/SuperClaude_Framework
- **What it does:** Enhanced Claude Code with specialized personalities

## How Our Current Setup Compares

| Feature | Our Setup | Claude-Flow | ccswarm |
|---------|-----------|-------------|---------|
| Agent count | 9 bots | 60+ | Variable |
| Coordination | tmux + manage-bots.sh | Built-in swarm | ACP protocol |
| Memory | File-based JSON | AgentDB + RAG | Git-based |
| Isolation | Per-project repos | Configurable | Git worktrees |
| Self-learning | Manual state files | Automated loop | Basic |
| Fault tolerance | Cron health check | Consensus (Raft/BFT) | Basic |
| Setup complexity | Simple (bash) | Complex (npm) | Medium (Rust) |
| Token efficiency | Manual (10 min cycles) | Built-in optimization | Basic |

## Recommendations

### Immediate (No Changes Needed)
- Our tmux + Clawdbot setup works well for 9 specialized bots
- State files + memory system provides good continuity
- 10-minute cycles with multi-account failover is efficient

### Short-Term Improvements
1. **Git worktree isolation** (from ccswarm) - prevents bot conflicts
2. **Self-learning loop** (from claude-flow) - bots track what works
3. **Agent communication** - bots can share findings via shared memory files

### Medium-Term (When Ready)
1. **Try claude-flow** for complex multi-agent tasks
2. **Add ccswarm** for parallel development work
3. **Quant strategies** (from MoonDev) for trading bot

### For Shitcoin Brain
1. Research Jim Simons' Renaissance Technologies strategies
2. Study statistical arbitrage on prediction markets
3. Look into mean reversion on Polymarket spreads
4. Monitor pigeon-mcp for when docs come out

# Clawdbot Configuration

Multi-machine Clawdbot setup with Ollama integration for local LLM inference.

## 🤖 Model Routing Strategy

### Primary Models
- **devstral-small-2:24b** (Mistral) — PRIMARY for coding sub-agents (MacBook only)
- **gpt-oss:20b** (DeepSeek-V3) — Primary for heartbeats, general tasks (both machines)
- **qwen3:8b** (Qwen3.1) — Fast model for quick tasks, reasoning mode enabled

### Legacy Models (Removed)
- ❌ qwen2.5-coder:7b — Replaced by qwen3:8b (better reasoning)

## 🧠 Model Assignment by Task

### Heartbeat (Periodic Checks)
- **Model**: gpt-oss:20b on Mac Mini
- **Why**: Always-on, free, good enough for periodic checks

### Sub-Agent Cascade
When spawning sub-agents, models cascade in order:
1. **devstral-small-2:24b** (MacBook Ollama — primary for coding)
2. **gpt-oss:20b** (Mac Mini Ollama — always-on fallback)
3. **gpt-oss:20b** (MacBook Ollama — secondary fallback)
4. **qwen3:8b** (either machine, fast fallback)
5. **Claude Sonnet** (API, if local fails)
6. **Claude Opus** (API, last resort)

### Reasoning Mode
- **qwen3:8b**: `reasoning=true` (thinking mode, free tokens)
- Other models: reasoning disabled by default

## 🖥️ Ollama Providers

Two separate Ollama instances for multi-machine access:

### Provider 1: `ollama` (Mac Mini — always-on)
```yaml
name: ollama
baseUrl: http://felipes-mac-mini.local:11434
tailscaleUrl: http://100.115.10.14:11434
models:
  - gpt-oss:20b      # Primary for heartbeats
  - qwen3:8b         # Fast reasoning
```

### Provider 2: `ollama-macbook` (MacBook Pro — primary for coding)
```yaml
name: ollama-macbook
baseUrl: http://felipes-macbook-pro-2.local:11434
tailscaleUrl: http://100.125.165.107:11434
models:
  - devstral-small-2:24b  # PRIMARY for coding sub-agents
  - gpt-oss:20b           # General fallback
  - qwen3:8b              # Fast reasoning
```

## ⏰ Cron Jobs

### Active Cron Jobs

| Job | Schedule | Model | Purpose |
|-----|----------|-------|---------|
| **Cleaner Bot** | Hourly | gpt-oss:20b / qwen3:8b | Deep cleanup (caches, temp, disk) |
| **Healer Bot** | Hourly | gpt-oss:20b → Sonnet | Read event logs, diagnose, heal |
| **Clear Sessions** | Weekly (Sunday midnight) | — | Clean stale Clawdbot sessions |

### Configuration Example
```bash
# List cron jobs
clawdbot cron list

# Add a cron job
clawdbot cron add --name "cleaner-bot" --schedule "0 * * * *" --model "ollama/gpt-oss:20b"
clawdbot cron add --name "healer-bot" --schedule "30 * * * *" --model "ollama/gpt-oss:20b"
```

## 🩺 Event Watcher (Launchd Service)

The event watcher runs 24/7 via launchd — NOT a cron job.

- **Service**: `com.clawdbot.event-watcher`
- **Script**: `/Users/felipevieira/clawd/scripts/event-watcher.sh`
- **Interval**: Every 60 seconds
- **Cost**: FREE (pure bash)
- **Logs**: `/tmp/clawdbot/events.jsonl`

See [HYBRID-HEALING.md](clawdbot/HYBRID-HEALING.md) for full architecture.

```bash
# Check status
launchctl list | grep event-watcher

# View recent events
tail -20 /tmp/clawdbot/events.jsonl | jq .
```

## ⚙️ Ollama Performance Tuning

Both machines run with optimized settings:

### Environment Variables
```bash
OLLAMA_HOST=0.0.0.0              # Listen on all interfaces
OLLAMA_FLASH_ATTENTION=1          # Enable flash attention
OLLAMA_KV_CACHE_TYPE=q8_0         # 8-bit quantized KV cache
```

### Flash Attention
- **Benefit**: Faster inference, lower memory usage
- **Trade-off**: Slightly reduced quality (negligible in practice)

### Q8_0 KV Cache
- **Benefit**: 4x memory reduction vs f16 cache
- **Trade-off**: Minimal quality impact, enables larger context windows

## 📊 Model Specs

| Model | Size | RAM | Location | Purpose |
|-------|------|-----|----------|---------|
| devstral-small-2:24b | 15 GB | 48 GB | MacBook | **Primary for coding** |
| gpt-oss:20b | 13 GB | 16 GB | Mac Mini (primary), MacBook | Heartbeats, general |
| qwen3:8b | 5.2 GB | Both | Both | Fast reasoning |

## 🔄 Load Balancing

- **MacBook** is primary for sub-agents (devstral-24b for coding)
- **Mac Mini** handles heartbeats (always-on, gpt-oss:20b)
- Sub-agents cascade: MacBook devstral → Mac Mini gpt-oss → MacBook gpt-oss → qwen3
- Both machines reachable via hostname or Tailscale IP

## 🎯 Usage Examples

### CLI Override
```bash
# Use specific model
clawd chat --model ollama/gpt-oss:20b

# Use MacBook Ollama
clawd chat --model ollama-macbook/devstral-small-2:24b

# Force reasoning mode
clawd chat --model ollama/qwen3:8b --reasoning
```

### Config File (.clawdbotrc)
```json
{
  "defaultModel": "ollama-macbook/devstral-small-2:24b",
  "heartbeatModel": "ollama/gpt-oss:20b",
  "subAgentModels": [
    "ollama-macbook/devstral-small-2:24b",
    "ollama/gpt-oss:20b",
    "ollama-macbook/gpt-oss:20b",
    "ollama/qwen3:8b",
    "anthropic/claude-sonnet-4-5",
    "anthropic/claude-opus-4-5"
  ]
}
```

## 💰 Cost Savings

| Task Type | Old Model | New Model | Savings |
|-----------|-----------|-----------|---------|
| Heartbeats | Claude Sonnet | gpt-oss:20b (Mac Mini) | 100% |
| Sub-agents (coding) | Claude Sonnet | devstral-small-2:24b (MacBook) | 100% |
| Sub-agents (general) | Claude Sonnet | gpt-oss:20b | 100% |
| Quick tasks | Claude Haiku | qwen3:8b | 100% |
| Self-healing | Claude Sonnet | Event watcher (bash) + local LLM | 95-100% |

**Estimated monthly savings**: $200-300 USD

## 🔧 Troubleshooting

### Model Not Found
```bash
# Check available models
ollama list

# Pull missing model
ollama pull gpt-oss:20b
```

### Slow Inference
```bash
# Verify flash attention is enabled
echo $OLLAMA_FLASH_ATTENTION  # Should be 1

# Check KV cache type
echo $OLLAMA_KV_CACHE_TYPE    # Should be q8_0
```

### Connection Refused
```bash
# Verify Ollama is running
ps aux | grep ollama

# Check port
lsof -i :11434

# Restart Ollama
brew services restart ollama
```

## 📚 References

- [Ollama Setup](ollama-setup.md) — Installation & configuration
- [Tailscale](tailscale.md) — Network configuration for multi-machine access
- [Dev Teams](dev-teams.md) — Model assignment per project/bot
- [Hybrid Healing](clawdbot/HYBRID-HEALING.md) — Self-healing architecture

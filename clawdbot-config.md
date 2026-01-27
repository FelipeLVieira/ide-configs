# Clawdbot Configuration

Multi-machine Clawdbot setup with Ollama integration for local LLM inference.

## 🤖 Model Routing Strategy

### Primary Models
- **gpt-oss:20b** (DeepSeek-V3) — Primary model for heartbeats and main tasks
- **qwen3:8b** (Qwen3.1) — Fast model for quick tasks, reasoning mode enabled
- **devstral-small-2:24b** (Mistral) — MacBook-only for heavy tasks

### Legacy Models (Removed)
- ❌ qwen2.5-coder:7b — Replaced by qwen3:8b (better reasoning)

## 🧠 Model Assignment by Task

### Heartbeat (Periodic Checks)
- **Model**: gpt-oss:20b
- **Why**: Balance of speed and reasoning for proactive tasks

### Sub-Agent Cascade
When spawning sub-agents, models cascade in order of availability:
1. **gpt-oss:20b** (Mac Mini Ollama)
2. **devstral-small-2:24b** (MacBook Ollama)
3. **qwen3:8b** (both machines, fast fallback)
4. **Claude Sonnet** (API, if local fails)
5. **Claude Opus** (API, last resort)

### Reasoning Mode
- **qwen3:8b**: `reasoning=true` (thinking mode, free tokens)
- Other models: reasoning disabled by default

## 🖥️ Ollama Providers

Two separate Ollama instances for multi-machine access:

### Provider 1: `ollama` (Mac Mini)
```yaml
name: ollama
baseUrl: http://100.115.10.14:11434
models:
  - gpt-oss:20b
  - qwen3:8b
```

### Provider 2: `ollama-macbook` (MacBook Pro)
```yaml
name: ollama-macbook
baseUrl: http://100.125.165.107:11434
models:
  - devstral-small-2:24b
  - gpt-oss:20b
  - qwen3:8b
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
| gpt-oss:20b | 13 GB | 16 GB | Mac Mini | Primary |
| devstral-small-2:24b | 15 GB | 48 GB | MacBook | Heavy tasks |
| qwen3:8b | 5.2 GB | Both | Both | Fast reasoning |

## 🔄 Load Balancing

- **Mac Mini** handles most traffic (always on, 24/7)
- **MacBook** handles overflow and heavy tasks
- Heartbeat polls primary (Mac Mini) first
- Sub-agents cascade to MacBook if Mini is busy

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
  "defaultModel": "ollama/gpt-oss:20b",
  "heartbeatModel": "ollama/gpt-oss:20b",
  "subAgentModels": [
    "ollama/gpt-oss:20b",
    "ollama-macbook/devstral-small-2:24b",
    "ollama/qwen3:8b",
    "anthropic/claude-sonnet-4-5",
    "anthropic/claude-opus-4-5"
  ]
}
```

## 💰 Cost Savings

| Task Type | Old Model | New Model | Savings |
|-----------|-----------|-----------|---------|
| Heartbeats | Claude Sonnet | gpt-oss:20b | 100% |
| Sub-agents | Claude Sonnet | gpt-oss:20b | 90-100% |
| Quick tasks | Claude Haiku | qwen3:8b | 100% |
| Heavy tasks | Claude Opus | devstral-small-2:24b | 100% |

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

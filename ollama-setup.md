# Ollama Setup

Local LLM inference on Mac Mini and MacBook Pro via Ollama.

## 🖥️ Hardware Overview

### Mac Mini (24/7 Server)
- **RAM**: 16 GB
- **OS**: macOS Sequoia
- **Tailscale IP**: 100.115.10.14
- **Hostname**: felipes-mac-mini.local
- **Ollama URL**: http://felipes-mac-mini.local:11434
- **Role**: Primary inference server (heartbeats, always-on)

### MacBook Pro (On-Demand)
- **RAM**: 48 GB
- **OS**: macOS Sequoia
- **Tailscale IP**: 100.125.165.107
- **Hostname**: felipes-macbook-pro-2.local
- **Ollama URL**: http://felipes-macbook-pro-2.local:11434
- **Role**: Primary for coding sub-agents (devstral-24b)

## 📦 Installation

Both machines use Homebrew:

```bash
brew install ollama
```

## 🔧 Configuration

### Environment Variables

Add to `~/.zshrc` or `~/.bash_profile`:

```bash
# Ollama Server Config
export OLLAMA_HOST=0.0.0.0              # Listen on all interfaces
export OLLAMA_FLASH_ATTENTION=1          # Enable flash attention
export OLLAMA_KV_CACHE_TYPE=q8_0         # 8-bit quantized KV cache
```

Then reload:
```bash
source ~/.zshrc
```

### Launchd Service (MacBook Pro Only)

MacBook runs Ollama via launchd for auto-start.

**File**: `~/Library/LaunchAgents/com.ollama.serve.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.ollama.serve</string>
    <key>ProgramArguments</key>
    <array>
        <string>/opt/homebrew/bin/ollama</string>
        <string>serve</string>
    </array>
    <key>EnvironmentVariables</key>
    <dict>
        <key>OLLAMA_HOST</key>
        <string>0.0.0.0</string>
        <key>OLLAMA_FLASH_ATTENTION</key>
        <string>1</string>
        <key>OLLAMA_KV_CACHE_TYPE</key>
        <string>q8_0</string>
    </dict>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/ollama.out.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/ollama.err.log</string>
</dict>
</plist>
```

**Load the service:**
```bash
launchctl load ~/Library/LaunchAgents/com.ollama.serve.plist
launchctl start com.ollama.serve
```

**Check status:**
```bash
launchctl list | grep ollama
```

### Mac Mini Service

Mac Mini uses Homebrew services:

```bash
brew services start ollama
brew services list  # Verify running
```

## 🤖 Models

### Mac Mini (16 GB RAM)

| Model | Size | Purpose |
|-------|------|---------|
| gpt-oss:20b | 13 GB | Primary model (DeepSeek-V3), heartbeats |
| qwen3:8b | 5.2 GB | Fast reasoning tasks |

**Pull models:**
```bash
ollama pull gpt-oss:20b
ollama pull qwen3:8b
```

### MacBook Pro (48 GB RAM)

| Model | Size | Purpose |
|-------|------|---------|
| devstral-small-2:24b | 15 GB | **PRIMARY for coding** (Mistral) |
| gpt-oss:20b | 13 GB | General tasks fallback |
| qwen3:8b | 5.2 GB | Fast reasoning |

**Pull models:**
```bash
ollama pull devstral-small-2:24b
ollama pull gpt-oss:20b
ollama pull qwen3:8b
```

### Removed Models
- ❌ **qwen2.5-coder:7b** — Deleted from both machines (2025-07-27). Was causing credit leaks when configs referenced it after removal. Replaced by qwen3:8b (better reasoning) and gpt-oss:20b (better quality).

### Windows MSI — NO Ollama
- ❌ **No Ollama installed** on Windows MSI
- All tasks run 100% on Claude API (credit leak risk)
- **Future**: Install Ollama or route through Mac Mini (`http://100.115.10.14:11434`)

## 🎯 Sub-Agent Priority Chain

When spawning sub-agents for coding tasks, models cascade:

```
1. devstral-small-2:24b (MacBook)  ← PRIMARY for coding
2. gpt-oss:20b (Mac Mini)          ← always-on fallback
3. gpt-oss:20b (MacBook)           ← secondary fallback
4. qwen3:8b (either machine)       ← fast/light tasks
5. Claude Sonnet (API)             ← if all local fail
6. Claude Opus (API)               ← critical tasks only
```

### Heartbeat Model
- **gpt-oss:20b on Mac Mini** — Always-on, free, good enough for periodic checks

## 🌐 Network Access

Both machines reachable via **hostname** or **Tailscale IP**.

### Hostname Access (Local Network)
```bash
# Mac Mini
curl http://felipes-mac-mini.local:11434/api/tags

# MacBook
curl http://felipes-macbook-pro-2.local:11434/api/tags
```

### Tailscale Access (Remote/VPN)
```bash
# Mac Mini
curl http://100.115.10.14:11434/api/tags

# MacBook
curl http://100.125.165.107:11434/api/tags
```

### Cross-Machine Ollama Access (Bidirectional)

Both Macs can use each other's Ollama instances for load balancing and failover:

```bash
# MacBook → Mac Mini (always-on, heartbeats)
curl http://felipes-mac-mini.local:11434/api/tags

# Mac Mini → MacBook (coding models, devstral-24b)
curl http://felipes-macbook-pro-2.local:11434/api/tags
```

**In Clawdbot config**, two providers are defined:
- `ollama` → Mac Mini (always-on)
- `ollama-macbook` → MacBook Pro (coding-focused)

Sub-agents cascade across both machines automatically.

### Tailscale CLI Fix

Tailscale userspace mode requires a socket flag for CLI:

```bash
# Add to ~/.zshrc
alias tailscale='tailscale --socket=~/.tailscale/tailscaled.sock'
```

## ⚡ Performance Tuning

### Flash Attention
- **What**: Optimized attention mechanism for Transformers
- **Benefit**: 2-3x faster inference, 40% less memory
- **Enabled**: `OLLAMA_FLASH_ATTENTION=1`

### Q8_0 KV Cache
- **What**: 8-bit quantized key-value cache
- **Benefit**: 4x memory reduction vs f16 (16-bit float)
- **Trade-off**: Negligible quality loss (<1% perplexity increase)
- **Enabled**: `OLLAMA_KV_CACHE_TYPE=q8_0`

### Why It Matters
- **Mac Mini (16 GB)**: Can run gpt-oss:20b (13 GB) with headroom
- **MacBook (48 GB)**: Can run devstral-small-2:24b (15 GB) + multiple contexts

## 🛠️ Management Commands

### List Models
```bash
ollama list
```

### Pull/Update Models
```bash
ollama pull gpt-oss:20b
```

### Remove Models
```bash
ollama rm qwen2.5-coder:7b  # Removed legacy model
```

### Check Running Models
```bash
curl http://localhost:11434/api/tags
```

### Stop Model (Free Memory)
```bash
# Models auto-unload after 5 minutes of inactivity
# Or restart service
brew services restart ollama
```

## 🔥 Firewall & Security

### Allow Ollama Port

**macOS Firewall:**
```bash
# Ollama runs on port 11434
# Add firewall rule if needed
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /opt/homebrew/bin/ollama
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp /opt/homebrew/bin/ollama
```

### Tailscale Security
- Only Tailscale network can access (private mesh VPN)
- No public internet exposure
- All traffic encrypted end-to-end

## 🐛 Troubleshooting

### Service Not Starting
```bash
# Check logs (launchd on MacBook)
tail -f /tmp/ollama.err.log

# Check logs (Homebrew on Mac Mini)
brew services info ollama

# Restart
launchctl stop com.ollama.serve && launchctl start com.ollama.serve  # MacBook
brew services restart ollama  # Mac Mini
```

### Port Already in Use
```bash
# Find process using port 11434
lsof -i :11434

# Kill it
kill -9 <PID>
```

### Model Not Found
```bash
# List available models
ollama list

# Pull missing model
ollama pull gpt-oss:20b
```

### Out of Memory
```bash
# Check memory usage
ollama ps

# Stop all models
brew services restart ollama

# Use smaller model or different machine
```

### Connection Refused (Remote)
```bash
# Verify Ollama is listening on 0.0.0.0
echo $OLLAMA_HOST  # Should be 0.0.0.0

# Test local
curl http://localhost:11434/api/tags

# Test via hostname
curl http://felipes-mac-mini.local:11434/api/tags

# Test Tailscale IP
curl http://100.115.10.14:11434/api/tags

# Check Tailscale status
tailscale status
```

## 📊 Monitoring

### Check Inference Speed
```bash
time ollama run gpt-oss:20b "What is 2+2?"
```

### Memory Usage
```bash
# Active model memory
ollama ps

# System memory
vm_stat

# Or use Activity Monitor
```

### GPU Usage (Apple Silicon)
```bash
# Metal GPU usage
sudo powermetrics --samplers gpu_power -i 1000 -n 1
```

## 📚 References

- [Ollama Docs](https://ollama.ai/docs)
- [Flash Attention Paper](https://arxiv.org/abs/2205.14135)
- [Clawdbot Config](clawdbot-config.md) — Model routing
- [Tailscale Setup](tailscale.md) — Network configuration

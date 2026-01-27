# Ollama Setup

Local LLM inference on Mac Mini and MacBook Pro via Ollama.

## 🖥️ Hardware Overview

### Mac Mini (24/7 Server)
- **RAM**: 16 GB
- **OS**: macOS Sequoia
- **Tailscale IP**: 100.115.10.14
- **Role**: Primary inference server

### MacBook Pro (On-Demand)
- **RAM**: 48 GB
- **OS**: macOS Sequoia
- **Tailscale IP**: 100.125.165.107
- **Role**: Heavy task overflow

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
| gpt-oss:20b | 13 GB | Primary model (DeepSeek-V3) |
| qwen3:8b | 5.2 GB | Fast reasoning tasks |

**Pull models:**
```bash
ollama pull gpt-oss:20b
ollama pull qwen3:8b
```

### MacBook Pro (48 GB RAM)

| Model | Size | Purpose |
|-------|------|---------|
| devstral-small-2:24b | 15 GB | Heavy tasks (Mistral) |
| gpt-oss:20b | 13 GB | Primary fallback |
| qwen3:8b | 5.2 GB | Fast reasoning |

**Pull models:**
```bash
ollama pull devstral-small-2:24b
ollama pull gpt-oss:20b
ollama pull qwen3:8b
```

## 🌐 Network Access

Both machines use **Tailscale** in userspace networking mode.

### Tailscale CLI Fix

Tailscale userspace mode requires a socket flag for CLI:

```bash
# Add to ~/.zshrc
alias tailscale='tailscale --socket=~/.tailscale/tailscaled.sock'
```

### Accessing Ollama Remotely

**From MacBook to Mac Mini:**
```bash
curl http://100.115.10.14:11434/api/generate -d '{
  "model": "gpt-oss:20b",
  "prompt": "Hello, world!"
}'
```

**From Mac Mini to MacBook:**
```bash
curl http://100.125.165.107:11434/api/generate -d '{
  "model": "devstral-small-2:24b",
  "prompt": "Hello, world!"
}'
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

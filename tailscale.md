# Tailscale Configuration

Private mesh VPN connecting all devices.

## Network Overview

| Device | IP | OS | Mode |
|--------|-----|-----|------|
| **MacBook Pro** | 100.125.165.107 | macOS | Userspace networking |
| **Mac Mini** | 100.115.10.14 | macOS | Userspace networking |
| **iPhone** | 100.89.50.26 | iOS | Standard |
| **MSI** | 100.67.241.32 | Windows | Standard |

---

## Installation

### macOS (MacBook & Mac Mini)
```bash
# Install via Homebrew
brew install tailscale

# Start Tailscale in userspace mode
sudo tailscale up --accept-routes --operator=$USER

# Verify
tailscale status
```

### iOS (iPhone)
1. Download Tailscale app from App Store
2. Log in with account
3. Enable VPN profile

### Windows (MSI)
1. Download Tailscale from [tailscale.com](https://tailscale.com/download)
2. Install and log in
3. Enable "Run at startup"

---

## Userspace Networking Mode

Both Macs run Tailscale in **userspace networking mode**.

### What Is Userspace Mode?
- Tailscale runs as a user process (no system-level network changes)
- Uses SOCKS5 proxy instead of routing table modifications
- More secure, but requires proxy for network access

### Proxy Configuration
- **SOCKS5**: `localhost:1055`
- **HTTP**: `localhost:1056`

### Why Userspace?
- [OK] No need for root/admin privileges
- [OK] Doesn't interfere with local network
- [OK] Easier to debug connection issues
- [NO] Requires proxy configuration for apps

---

## CLI Alias Fix

Tailscale CLI in userspace mode requires a socket flag.

### Add to `~/.zshrc` or `~/.bash_profile`

```bash
# Tailscale CLI Alias (userspace mode)
alias tailscale='tailscale --socket=~/.tailscale/tailscaled.sock'
```

### Apply Changes
```bash
source ~/.zshrc
```

### Verify
```bash
tailscale status
```

---

## Network Topology

```

         Tailscale Mesh VPN

  MacBook Pro (100.125.165.107)
   Ollama: port 11434
   SSH: port 22 (disabled)

  Mac Mini (100.115.10.14)
   Ollama: port 11434
   SSH: port 22 [OK]
   Aphos Prod: port 2567
   Aphos Dev: port 2568

  iPhone (100.89.50.26)
   Aphos game client

  MSI (100.67.241.32)
   SSH: port 22 [OK]

```

---

## Usage Examples

### Ping Device
```bash
ping 100.115.10.14 # Mac Mini
ping 100.67.241.32 # MSI
```

### SSH via Tailscale
```bash
# Mac Mini
ssh felipemacmini@100.115.10.14

# MSI (via SOCKS proxy)
ssh -o "ProxyCommand nc -X 5 -x localhost:1055 %h %p" felip@100.67.241.32
```

### Access Ollama Remotely
```bash
# MacBook -> Mac Mini Ollama
curl http://100.115.10.14:11434/api/tags

# Mac Mini -> MacBook Ollama
curl http://100.125.165.107:11434/api/generate -d '{
  "model": "devstral-small-2:24b",
  "prompt": "Hello"
}'
```

### Access Aphos Game Server (from iPhone)
```
http://100.115.10.14:2567
```

---

## Firewall & Security

### macOS Firewall
```bash
# Allow Tailscale
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /Applications/Tailscale.app/Contents/MacOS/Tailscale
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp /Applications/Tailscale.app/Contents/MacOS/Tailscale
```

### Security Features
- **End-to-end encryption** — All traffic encrypted with WireGuard
- **Zero trust** — No device trusts any other by default
- **ACLs** — Can restrict which devices talk to which
- **Private IPs** — 100.x.x.x range (not routable on internet)

---

## Testing Connectivity

### Check Tailscale Status
```bash
tailscale status
```

### Test SOCKS Proxy (macOS only)
```bash
# Test SOCKS5 proxy
curl --socks5 localhost:1055 http://100.115.10.14:11434/api/tags

# Test HTTP proxy
curl --proxy localhost:1056 http://100.115.10.14:11434/api/tags
```

### Ping All Devices
```bash
ping -c 3 100.125.165.107 # MacBook
ping -c 3 100.115.10.14 # Mac Mini
ping -c 3 100.89.50.26 # iPhone
ping -c 3 100.67.241.32 # MSI
```

---

## Advanced Configuration

### Exit Node (Optional)
Route all internet traffic through a device:

```bash
# Enable exit node on Mac Mini
sudo tailscale up --advertise-exit-node

# Use Mac Mini as exit node from MacBook
sudo tailscale up --exit-node=100.115.10.14
```

### Subnet Routes (Optional)
Share local network access:

```bash
# Advertise local network (192.168.1.0/24)
sudo tailscale up --advertise-routes=192.168.1.0/24

# Accept routes on other devices
sudo tailscale up --accept-routes
```

### MagicDNS
Access devices by name instead of IP:

```bash
# Enable MagicDNS (in Tailscale admin console)
# Then use:
ssh felipemacmini@mac-mini
curl http://mac-mini:11434/api/tags
```

---

## Troubleshooting

### Cannot Connect to Device
```bash
# Check Tailscale status
tailscale status

# Restart Tailscale
# macOS
sudo tailscale down
sudo tailscale up

# Windows
# Restart from system tray

# iOS
# Disable/enable in app
```

### SOCKS Proxy Not Working
```bash
# Verify Tailscale is running in userspace mode
ps aux | grep tailscale

# Check socket file exists
ls -l ~/.tailscale/tailscaled.sock

# Restart Tailscale
sudo tailscale down
sudo tailscale up
```

### Ping Works, but SSH/HTTP Doesn't
```bash
# Firewall blocking ports
# Check macOS firewall settings
# Or temporarily disable:
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate off
```

### CLI Commands Not Working
```bash
# Use full path
/Applications/Tailscale.app/Contents/MacOS/Tailscale status

# Or fix alias in ~/.zshrc
alias tailscale='tailscale --socket=~/.tailscale/tailscaled.sock'
source ~/.zshrc
```

---

## Monitoring

### Check Connection Quality
```bash
tailscale ping 100.115.10.14
```

### View Network Routes
```bash
tailscale status --peers
```

### Check for Updates
```bash
# macOS
brew upgrade tailscale

# Windows
# Update from system tray
```

---

## Maintenance

### Update Tailscale
```bash
# macOS
brew upgrade tailscale

# Then restart
sudo tailscale down
sudo tailscale up
```

### Remove Device
```bash
# From Tailscale admin console
# Or via CLI
tailscale logout
```

### Reset Configuration
```bash
sudo tailscale down
sudo tailscale up --reset
```

---

## References

- [Tailscale Docs](https://tailscale.com/kb/)
- [WireGuard Protocol](https://www.wireguard.com/)
- [SSH Config](ssh-config.md) — SSH via Tailscale
- [Ollama Setup](ollama-setup.md) — Remote Ollama access
- [Aphos Servers](aphos-servers.md) — Game server access

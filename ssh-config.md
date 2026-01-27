# SSH Configuration

Multi-machine SSH setup for seamless remote access.

## Machine Overview

| Machine | Hostname | User | IP (Tailscale) |
|---------|----------|------|----------------|
| **Mac Mini** | felipes-mac-mini.local | felipemacmini | 100.115.10.14 |
| **MacBook Pro** | felipes-macbook-pro.local | felipevieira | 100.125.165.107 |
| **MSI (Windows)** | (Tailscale only) | felip | 100.67.241.32 |
| **iPhone** | (Tailscale only) | N/A | 100.89.50.26 |

---

## NOTE: SSH Config File

**Location**: `~/.ssh/config`

```ssh-config
# GitHub SSH Config
Host github.com
    HostName github.com
    User git
    PreferredAuthentications publickey
    IdentityFile ~/.ssh/id_ed25519
    UseKeychain yes
    AddKeysToAgent yes

# Mac Mini (Always On Server)
Host mac-mini
    HostName felipes-mac-mini.local
    User felipemacmini
    IdentityFile ~/.ssh/id_ed25519
    ServerAliveInterval 60
    ServerAliveCountMax 3

# Mac Mini (via Tailscale - for remote access)
Host mac-mini-tailscale
    HostName 100.115.10.14
    User felipemacmini
    IdentityFile ~/.ssh/id_ed25519
    ProxyCommand nc -X 5 -x localhost:1055 %h %p
    ServerAliveInterval 60
    ServerAliveCountMax 3

# MacBook Pro (from Mac Mini)
Host macbook
    HostName felipes-macbook-pro.local
    User felipevieira
    IdentityFile ~/.ssh/id_ed25519

# MSI (Windows via Tailscale SOCKS proxy)
Host msi
    HostName 100.67.241.32
    User felip
    IdentityFile ~/.ssh/id_ed25519
    ProxyCommand nc -X 5 -x localhost:1055 %h %p
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

---

## SSH Key Setup

### Generate SSH Key (if needed)
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

### Copy Public Key to Remote Machine
```bash
# Mac Mini -> MacBook
ssh-copy-id felipevieira@felipes-macbook-pro.local

# MacBook -> Mac Mini
ssh-copy-id felipemacmini@felipes-mac-mini.local

# To MSI (Windows, via Tailscale)
ssh-copy-id -o "ProxyCommand nc -X 5 -x localhost:1055 %h %p" felip@100.67.241.32
```

### Add Key to SSH Agent
```bash
ssh-add ~/.ssh/id_ed25519
```

---

## Tailscale SOCKS Proxy

Both Macs use **Tailscale in userspace networking mode**, which requires a SOCKS proxy for SSH.

### SOCKS Proxy Details
- **SOCKS5**: `localhost:1055`
- **HTTP**: `localhost:1056`

### Using ProxyCommand

For Tailscale IPs, use `ProxyCommand` with `nc` (netcat):

```ssh-config
ProxyCommand nc -X 5 -x localhost:1055 %h %p
```

This routes SSH traffic through the Tailscale SOCKS proxy.

---

## [OK] Connection Status

| From | To | Status | Method |
|------|-----|--------|--------|
| MacBook | Mac Mini | [OK] Working | Local (.local) or Tailscale |
| Mac Mini | MacBook | [NO] Not Working | MacBook Remote Login disabled |
| MacBook | MSI | [OK] Working | Tailscale SOCKS proxy |
| Mac Mini | MSI | [OK] Working | Tailscale SOCKS proxy |

### MacBook Remote Login Disabled
- Mac Mini **cannot** SSH into MacBook
- **Why**: Remote Login is disabled on MacBook for security
- **Workaround**: Use git for code sync (Mac Mini pushes, MacBook pulls)

---

## Usage Examples

### SSH into Mac Mini
```bash
# From MacBook (local network)
ssh mac-mini

# From anywhere (via Tailscale)
ssh mac-mini-tailscale
```

### SSH into MSI (Windows)
```bash
# From MacBook or Mac Mini
ssh msi
```

### Run Remote Command
```bash
# Check disk space on Mac Mini
ssh mac-mini "df -h"

# Restart Ollama on MacBook (if Remote Login was enabled)
ssh macbook "brew services restart ollama"
```

### SCP File Transfer
```bash
# Copy file from Mac Mini to MacBook
scp mac-mini:~/file.txt ~/Downloads/

# Copy file to MSI
scp ~/file.txt msi:~/
```

---

## Troubleshooting

### Permission Denied (Public Key)
```bash
# Verify SSH key is added
ssh-add -l

# Add key if missing
ssh-add ~/.ssh/id_ed25519

# Copy key to remote machine
ssh-copy-id mac-mini
```

### Connection Timeout (Tailscale)
```bash
# Verify Tailscale is running
tailscale status

# Check SOCKS proxy
curl --socks5 localhost:1055 http://100.115.10.14:11434/api/tags
```

### Host Key Verification Failed
```bash
# Remove old host key
ssh-keygen -R felipes-mac-mini.local
ssh-keygen -R 100.115.10.14

# Reconnect (will add new key)
ssh mac-mini
```

### ProxyCommand Error
```bash
# Install netcat if missing
brew install netcat

# Test SOCKS proxy
nc -zv -X 5 -x localhost:1055 100.67.241.32 22
```

---

## Removed Configurations

### Duplicate Entry (Fixed)
- [NO] Removed duplicate `windows-msi` entry
- [OK] Now only `msi` entry exists

---

## References

- [Tailscale Setup](tailscale.md) — Tailscale network configuration
- [Mac Mini README](mac-mini/README.md) — Server setup
- [Aphos Servers](aphos-servers.md) — Game server access

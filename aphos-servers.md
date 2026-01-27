# Aphos Game Servers

Colyseus game servers running on Mac Mini via pm2.

## Server Overview

**Host**: Mac Mini (24/7)
**Manager**: pm2 (process manager)
**Location**: `~/repos/aphos/`

### Why Mac Mini?
- [OK] Always on (24/7 uptime)
- [OK] 16GB RAM (enough for game servers)
- [OK] Local network access for testing
- [NO] MacBook (orchestration only, not for servers)

---

## pm2 Configuration

**File**: `~/repos/aphos/ecosystem.config.cjs`

```javascript
module.exports = {
  apps: [
    {
      name: 'aphos-prod',
      script: 'npm',
      args: 'start',
      cwd: '/Users/felipemacmini/repos/aphos',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'production',
        PORT: 2567
      }
    },
    {
      name: 'aphos-dev',
      script: 'npm',
      args: 'run dev',
      cwd: '/Users/felipemacmini/repos/aphos',
      instances: 1,
      autorestart: true,
      watch: true,
      ignore_watch: ['node_modules', 'logs'],
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'development',
        PORT: 2568
      }
    }
  ]
};
```

---

## Port Assignment

| Server | Port | Purpose |
|--------|------|---------|
| **aphos-prod** | 2567 | Production game server |
| **aphos-dev** | 2568 | Development/testing server |

### Why These Ports?
- **2567**: Colyseus default port (standard convention)
- **2568**: Dev port (avoids conflicts with prod)

---

## Management Commands

### Start Servers
```bash
cd ~/repos/aphos
pm2 start ecosystem.config.cjs
```

### Stop Servers
```bash
pm2 stop aphos-prod aphos-dev
```

### Restart Servers
```bash
pm2 restart aphos-prod aphos-dev
```

### Status Check
```bash
pm2 status
pm2 list
```

### Logs
```bash
# View logs
pm2 logs aphos-prod
pm2 logs aphos-dev

# Clear logs
pm2 flush
```

### Delete/Remove
```bash
pm2 delete aphos-prod aphos-dev
```

---

## Auto-Start on Boot

pm2 can auto-start servers on Mac Mini reboot.

### Setup (Run Once)
```bash
# Generate startup script
pm2 startup

# This will output a command like:
# sudo env PATH=$PATH:/opt/homebrew/bin pm2 startup launchd -u felipemacmini --hp /Users/felipemacmini

# Copy and run that command with sudo
sudo env PATH=$PATH:/opt/homebrew/bin pm2 startup launchd -u felipemacmini --hp /Users/felipemacmini
```

### Save Current Process List
```bash
pm2 save
```

### Verify Auto-Start
```bash
# Reboot Mac Mini
sudo reboot

# After reboot, check pm2
pm2 list # Should show aphos-prod and aphos-dev running
```

### Disable Auto-Start
```bash
pm2 unstartup launchd
```

---

## TypeScript Fixes

### TS7053 Error (EnhancementSystem.ts)

**Error:**
```
Element implicitly has an 'any' type because expression of type 'string' can't be used to index type 'Player'.
```

**Fix Applied:**
Use type-safe property access instead of string indexing.

**Before:**
```typescript
player[statKey] += enhancement.value;
```

**After:**
```typescript
if (statKey === 'attack') player.attack += enhancement.value;
else if (statKey === 'defense') player.defense += enhancement.value;
// ... etc
```

Or use a type guard:
```typescript
type PlayerStat = 'attack' | 'defense' | 'hp' | 'mp';

function isPlayerStat(key: string): key is PlayerStat {
  return ['attack', 'defense', 'hp', 'mp'].includes(key);
}

if (isPlayerStat(statKey)) {
  player[statKey] += enhancement.value;
}
```

---

## Network Access

### Local Network
- **MacBook -> Mac Mini**: `http://felipes-mac-mini.local:2567`
- **iPhone -> Mac Mini**: `http://100.115.10.14:2567` (Tailscale)

### Firewall Rules
```bash
# Allow Colyseus ports
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /opt/homebrew/bin/node
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp /opt/homebrew/bin/node
```

---

## Monitoring

### pm2 Monitoring
```bash
# Real-time monitoring
pm2 monit

# Web UI (optional)
pm2 install pm2-server-monit
```

### Check Resource Usage
```bash
# Memory & CPU
pm2 status

# Detailed info
pm2 show aphos-prod
```

### Health Checks
```bash
# Test prod server
curl http://localhost:2567/

# Test dev server
curl http://localhost:2568/
```

---

## Maintenance

### Update Dependencies
```bash
cd ~/repos/aphos
npm install
pm2 restart aphos-prod aphos-dev
```

### Clear Logs
```bash
pm2 flush
```

### Rebuild TypeScript
```bash
cd ~/repos/aphos
npm run build
pm2 restart aphos-prod
```

---

## Troubleshooting

### Port Already in Use
```bash
# Find process using port
lsof -i :2567
lsof -i :2568

# Kill it
kill -9 <PID>

# Restart pm2
pm2 restart aphos-prod aphos-dev
```

### Server Not Starting
```bash
# Check logs
pm2 logs aphos-prod --lines 100

# Check TypeScript errors
cd ~/repos/aphos
npm run build
```

### Out of Memory
```bash
# Check memory usage
pm2 status

# Increase max memory (in ecosystem.config.cjs)
max_memory_restart: '2G' # Default is 1G

# Restart
pm2 restart aphos-prod aphos-dev
```

### Auto-Start Not Working
```bash
# Re-run startup command
pm2 startup
# Copy and run the sudo command it outputs

# Save current processes
pm2 save

# Reboot to test
sudo reboot
```

---

## References

- [pm2 Docs](https://pm2.keymetrics.io/docs/usage/quick-start/)
- [Colyseus Docs](https://docs.colyseus.io/)
- [Dev Teams](dev-teams.md) — Aphos bot roles
- [SSH Config](ssh-config.md) — Mac Mini access

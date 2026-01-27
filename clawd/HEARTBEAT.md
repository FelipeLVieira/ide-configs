# HEARTBEAT.md - Orchestrator Status Report

## Every Heartbeat: Status Dashboard + Quick Checks

### 1. Collect System Status (always)
Run these checks and build a compact status report:

```bash
# MacBook Pro
echo "=== MacBook ==="
df -h /System/Volumes/Data | awk 'NR==2{print "Disk: "$4" free ("$5" used)"}'
echo "Node procs: $(ps aux | grep node | grep -v grep | wc -l | xargs)"
echo "Ollama: $(curl -sf http://localhost:11434/api/version 2>/dev/null | python3 -c 'import sys,json;print(json.load(sys.stdin)["version"])' 2>/dev/null || echo 'DOWN')"

# Mac Mini
echo "=== Mac Mini ==="
ssh felipemacmini@felipes-mac-mini.local '
  echo "Status: online"
  df -h /System/Volumes/Data | awk "NR==2{print \"Disk: \"\$4\" free (\" \$5 \" used)\"}"
  sysctl vm.swapusage 2>/dev/null | awk -F"= " "{print \"Swap: \" \$3}" | head -1
  echo "Ollama: $(ollama --version 2>/dev/null | awk "{print \$4}")"
  echo "Models loaded: $(curl -sf http://localhost:11434/api/ps | python3 -c "import sys,json;ms=json.load(sys.stdin).get(\"models\",[]);print(\", \".join([m[\"name\"] for m in ms]) if ms else \"none\")" 2>/dev/null)"
  echo "Tmux sessions: $(tmux list-sessions 2>/dev/null | wc -l | xargs)"
' 2>/dev/null || echo "Status: WARNING: OFFLINE"

# Windows (optional, skip if unreachable after 3s)
echo "=== Windows ==="
timeout 3 ssh msi 'echo "Status: online"' 2>/dev/null || echo "Status: offline (normal if sleeping)"
```

### 2. Check Context Usage
- If above 50%, run /compact before next task

### 3. Format Response
**Always respond with a status card, NOT just "HEARTBEAT_OK".**

Format:
```
 Heartbeat — [timestamp]
 Source: MacBook Pro (main orchestrator)
 Model: [current model]

MacBook Pro: [OK] | Disk [X] free ([Y]% used) | [N] node procs
Mac Mini: [OK]/WARNING: | Disk [X] free ([Y]% used) | Swap [X] | Ollama [ver] | [models loaded] | [N] tmux
Windows: [OK]//WARNING:

 Context: [X]% used
[Any alerts or notable findings]
```

If everything is normal, keep it to this compact card.
If something needs attention, add a WARNING: section below with details.

## What's Automated (DON'T duplicate)
All of these are handled by dedicated cron jobs (Sonnet, isolated sessions):
- [OK] Cleaner Bot (hourly) — simulators, zombies, temp files, disk, browser tabs on BOTH machines
- [OK] Healer Bot (hourly) — reconciler pattern, circuit breakers, Ollama, pm2, Tailscale on BOTH machines
- [OK] App Store Manager (3x/day) — reviews, builds, rejections, policy compliance
- [OK] Session cleanup (weekly Sunday midnight)

## Architecture
```
Cron Jobs (Sonnet 4.5, isolated sessions, maxConcurrentRuns=6):
 Cleaner Bot -> hourly (MacBook + Mac Mini cleanup)
 Healer Bot -> hourly (reconciler + circuit breakers, both machines)
 App Store Mgr -> 9am/3pm/9pm (reviews, builds, compliance)
 R&D Research -> every 6h (AI improvements, X/Reddit/Google)
 Clear Sessions -> Sunday midnight (weekly cleanup)

Heartbeat (qwen3-coder:30b, thinkingDefault=off, main session):
 System status dashboard + connectivity + context management
 Model: ollama-macbook/qwen3-coder:30b (30B params, FREE)
```

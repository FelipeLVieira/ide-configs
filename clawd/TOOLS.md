# TOOLS.md - Local Notes

Skills define *how* tools work. This file is for *your* specifics — the stuff that's unique to your setup.

## ⚠️ CRITICAL: Cloud Storage

**Felipe uses MEGA, NOT Google Drive.**
- ❌ NEVER access Google Drive
- ❌ NEVER suggest Google Drive
- ✅ Use MEGA for all cloud storage needs

## ⚠️ CRITICAL: iOS Work on Mac Mini ONLY

**All iOS simulator/Xcode work must happen on Mac Mini!**
- ❌ NEVER open simulators on MacBook
- ❌ NEVER run xcodebuild on MacBook
- ✅ Use SSH: `ssh felipemacmini@felipes-mac-mini.local '<command>'`
- ✅ Use nodes.run: `nodes.run(mac-mini, [...])`
- MacBook = orchestration only, Mac Mini = iOS builds

## ⚠️ CRITICAL: iOS Builds - LOCAL ONLY, NO EAS CLOUD

**Build iOS apps LOCALLY with Xcode, NOT EAS Cloud!**
- ❌ NEVER use `eas build` for iOS
- ❌ NEVER use EAS cloud builds
- ✅ Use `xcodebuild` locally on Mac Mini
- ✅ Use `npx expo run:ios` for dev builds
- ✅ Archive with Xcode for App Store submission

**Why:** EAS Cloud has build quotas and costs money. Local builds are free and faster.

**Build commands (on Mac Mini):**
```bash
# Dev build
cd ~/repos/app-name
npx expo run:ios --device "iPhone 17 Pro Max"

# Production archive for App Store
xcodebuild -workspace ios/AppName.xcworkspace -scheme AppName -configuration Release -archivePath build/AppName.xcarchive archive
xcodebuild -exportArchive -archivePath build/AppName.xcarchive -exportPath build/AppStore -exportOptionsPlist ios/ExportOptions.plist
```

## 🤖 Grok (X/Twitter AI) - USE THIS TO SAVE CREDITS!

Felipe is logged into his X account with Grok access. **Use Grok for:**
- Research tasks (market analysis, news, trends)
- Getting a second opinion on complex problems
- Quick fact-checking or information gathering
- Saving Claude API credits on routine queries

**How to use:**
1. Open browser to x.com/i/grok or use the Grok sidebar on X
2. Ask Grok your question
3. Use the response to inform your work

**When to use Grok vs Claude:**
- Grok: Research, news, market data, quick queries, second opinions
- Claude: Complex reasoning, code, file operations, tool use

This saves money AND gives you diverse perspectives!

## 🖥️ Mac Mini Remote Control (Full Access)
- **Screen capture**: `screencapture -x /tmp/screen.png` via nodes.run ✅
- **Peekaboo**: Screen Recording permission granted ✅
- **Mouse control**: `cliclick` installed, Accessibility granted ✅
  - Click: `cliclick c:x,y`
  - Type: `cliclick t:text`
  - Move: `cliclick m:x,y`
  - Position: `cliclick p`
- **AppleScript**: `osascript` works ✅ (dialogs, app control, UI scripting)
- **Keyboard**: via cliclick ✅
- **File system**: full read/write ✅
- **SSH**: MacBook → Mac Mini (passwordless) ✅
- **SSH**: Mac Mini → MacBook: NOT working (MacBook Remote Login disabled)
- **Code sync**: Mac Mini pushes to git, MacBook pulls
- **Felipe's remote access**: Chrome Remote Desktop (internet)

### How to check Mac Mini screen:
```bash
# Via nodes.run (from MacBook orchestrator)
nodes.run(mac-mini, ["bash", "-c", "cd /tmp && /usr/sbin/screencapture -x screen.png && echo done"])
# Then scp to MacBook and analyze
```

### How to click a dialog:
```bash
# 1. Capture screen
# 2. Analyze with image tool to find button coordinates
# 3. Click
nodes.run(mac-mini, ["cliclick", "c:500,400"])
```

## 🖥️ Windows MSI (via Tailscale SSH)
- **SSH**: `ssh msi` (configured in ~/.ssh/config with SOCKS proxy)
- **User**: felip
- **Tailscale IP**: 100.67.241.32
- **Note**: Both Macs use Tailscale in userspace-networking mode (SOCKS5 on localhost:1055)
- **From Mac Mini**: same `ssh msi` works

## 🤖 QWEN Local LLM (Mac Mini)
- **Model**: qwen2.5-coder:7b-instruct-q5_K_M (5.4 GB)
- **Ollama**: http://localhost:11434 on Mac Mini
- **Cost**: FREE — use for all automated/cron tasks
- **Mac Mini Clawdbot config**: Primary model = QWEN, fallback = Sonnet → Opus
- **Cron jobs on Mac Mini**: Shitcoin Brain (10min), Quant (15min), Health (30min) — all QWEN

## What Goes Here

Things like:
- Camera names and locations
- SSH hosts and aliases  
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras
- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH
- home-server → 192.168.1.100, user: admin

### TTS
- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

Add whatever helps you do your job. This is your cheat sheet.
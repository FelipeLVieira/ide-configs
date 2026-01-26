# HEARTBEAT.md - System Monitoring

## 🔍 Quick Health Check (every heartbeat)
- Check `sessions_list` for any active sub-agents — if they completed, note it
- If any critical sub-agent died (0 tokens, never started), re-spawn it
- Check cron jobs are running: `cron action=list`

## 🎮 Aphos Game
- Game servers on Mac Mini (ports 2567, 2568, 4000, 4001)
- Dual environment: prod (2567/4000) and dev (2568/4001)

## 💰 Shitcoin Bot
- Running on both MacBook and Mac Mini
- Research-only mode: check `data/research_opportunities.json` for new finds
- If high-conviction opportunity found, review and consider approving

## 📱 iOS Apps (3 apps)
- BMI Calculator, Bills Tracker, Screen Translator
- Cron job monitors App Store Connect 3x/day (9am, 3pm, 9pm)
- If build expired/rejected, fix and resubmit

## 🖥️ Clawd Monitor
- Dev server on port 9000
- React errors in console = fix immediately

## 🔗 LinkLounge & EZ-CRM
- Supabase issues being fixed by sub-agents
- Monitor for completion

## Schedule
- Cron handles iOS monitoring (3x/day) and project health (3x/day)
- Heartbeat handles quick sub-agent checks and ad-hoc tasks
- Don't duplicate cron work in heartbeat

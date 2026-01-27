# R&D Research Team

Autonomous AI research and monitoring system for staying current with AI improvements and tools.

> **Last updated**: 2026-01-27 — Initial documentation

---

## Overview

The R&D Research Team is a cron-based system that continuously monitors AI developments, tools, and improvements across multiple platforms. It operates autonomously to surface relevant findings for Felipe and the bot ecosystem.

---

## Cron Job Configuration

### R&D AI Research
- **Schedule**: Every 6 hours (0 */6 * * *)
- **Machine**: MacBook Pro
- **Model**: Claude Sonnet 4.5
- **Session**: Isolated (not main session)
- **Purpose**: Monitor X/Twitter, Reddit, Google for AI improvements

### Why Sonnet?
- Research requires web browsing, summarization, and context synthesis
- Isolated sessions prevent memory pollution
- ~$0.05-0.15 per run (~$7-22/month for 4x daily)
- Cost justified by quality of research findings

---

## Monitoring Sources

### X/Twitter
- AI researcher accounts
- Latest model releases (Claude, GPT, Gemini, local models)
- Tool announcements
- Developer discussions
- **Action**: Bookmarks/likes relevant posts for Felipe to review

### Reddit
- r/LocalLLaMA — Local model news and benchmarks
- r/StableDiffusion — Image generation updates
- r/ClaudeAI — Claude API updates
- r/MachineLearning — Research papers and breakthroughs

### Google Search
- "AI model releases 2026"
- "Ollama new models"
- "Claude API updates"
- "Local LLM benchmarks"
- "Apple Silicon AI tools"

---

## Output

### Findings Storage
**File**: `memory/rd-findings.md`
- Structured markdown with date headers
- Links to sources
- Brief summaries
- Relevance tags (local-llm, api, tools, image-gen, etc.)

### Example Entry
```markdown
## 2026-01-27

### phi4:14b Released
- **Source**: [Ollama Blog](https://ollama.ai/blog/phi4)
- **Summary**: Microsoft Phi-4 14B with native reasoning support
- **Relevance**: [local-llm, reasoning, mac-mini]
- **Action**: Download and test on Mac Mini (16GB safe)

### Flux.1 Turbo Update
- **Source**: Reddit r/StableDiffusion
- **Summary**: 2x faster inference, same quality
- **Relevance**: [image-gen, apple-silicon]
- **Action**: Update Draw Things settings
```

---

## Image Generation Guide

Comprehensive guide for generating game assets, UI mockups, and artwork on Apple Silicon.

### Primary Tool: Draw Things + Flux.1

**Draw Things** is a native Mac/iOS app for Stable Diffusion and Flux models.
- **App Store**: Free download
- **Models**: Flux.1 Schnell, Flux.1 Dev, SDXL, SD1.5
- **Performance**: Optimized for Apple Silicon (Metal)

### Flux.1 Models

| Model | Speed | Quality | Machines | Use Cases |
|-------|-------|---------|----------|-----------|
| **Flux.1 Schnell** | Fast (4-8 steps) | Good | Both Macs | Quick iterations, concept art |
| **Flux.1 Dev** | Slow (20-50 steps) | Best | MacBook ONLY (48GB) | Final assets, marketing |

**Why Flux?**
- Superior prompt adherence vs Stable Diffusion
- Better text rendering in images
- Excellent for UI mockups and dashboards
- Native support in Draw Things

### Pixel Art

#### LoRAs on Flux
- **Pixel-Art-XL** LoRA for Flux.1
- Trigger word: "pixel art style"
- Settings: CFG 3-5, steps 25-35

#### ComfyUI Pipelines
- [ComfyUI](https://github.com/comfyanonymous/ComfyUI) — Node-based workflow
- Flux + LoRA + ControlNet for pixel sprites
- Character sheet generators
- Tile set automation

### 3D Asset Generation

#### App Store Apps
- **Prisma3D** — Sculpting and modeling
- **Shapr3D** — CAD for game props
- **Nomad Sculpt** — Organic modeling

#### TripoSR (Experimental)
- Open-source 2D → 3D model
- Runs on Apple Silicon via PyTorch
- Quality: Decent for prototyping, not production-ready
- Use case: Quick 3D concepts from 2D sketches

### UI Mockups

**Flux excels at dashboard/app designs:**
- Prompt: "Clean dashboard UI, dark mode, glassmorphism, modern"
- Add specifics: "health tracking app", "game inventory screen", "CRM dashboard"
- ControlNet: Use wireframes for precise layouts
- Tools: Figma for refinement after generation

### Best Practices

1. **Iterate locally first** — Flux Schnell on Mac Mini for speed
2. **Refine on MacBook** — Flux Dev for final quality (48GB needed)
3. **Use LoRAs** — Pixel art, anime, specific art styles
4. **ControlNet for precision** — Layouts, poses, compositions
5. **Post-process in Figma** — Clean up, add text, finalize

---

## Workflow

### Every 6 Hours (Automated)
1. **Web Search** — Check X/Twitter, Reddit, Google for AI news
2. **Filter Relevance** — Focus on: local LLMs, Ollama, Claude API, image gen tools, Apple Silicon optimizations
3. **Summarize Findings** — Append to `memory/rd-findings.md`
4. **Bookmark X Posts** — Like/bookmark relevant X posts for Felipe
5. **Actionable Items** — Note downloads, updates, or tests needed

### Weekly Review (Manual)
- Felipe reviews `memory/rd-findings.md`
- Prioritizes actionable items (new models, tool updates)
- Deletes outdated entries

---

## Integration with Bot Ecosystem

### Model Updates
When a new Ollama model is found:
1. R&D bot documents in findings
2. Healer Bot or main agent tests on Mac Mini
3. If stable → add to `ollama-setup.md` and `clawdbot-config.md`

### Tool Discoveries
When a new tool is found:
1. R&D bot documents in findings
2. Main agent evaluates relevance
3. If useful → add to `TOOLS.md` or create new skill

### API Changes
When Claude/Anthropic announces API changes:
1. R&D bot documents in findings
2. Alert main agent immediately
3. Update configs if needed

---

## Cost Analysis

| Item | Cost |
|------|------|
| **Cron job** | ~$0.05-0.15 per run (Sonnet isolated session) |
| **Frequency** | 4x per day |
| **Monthly** | ~$6-18 USD |
| **Value** | Early awareness of model releases, API changes, tool improvements |

**ROI**: Discovering a better local model (e.g., phi4:14b) saves $50+/month in API costs. Cron pays for itself 3-10x.

---

## Example Findings (Recent)

### 2026-01-27: phi4:14b Discovery
- Microsoft released Phi-4 14B with native reasoning
- 9.1GB model, safe for Mac Mini 16GB RAM
- contextWindow: 16384 tokens
- Downloaded and integrated into Mac Mini config

### 2026-01-26: Flux.1 Turbo Update
- 2x faster inference, same quality as Flux.1 Dev
- Available in Draw Things latest update
- Testing on MacBook Pro

### 2026-01-25: Claude Opus 4.5 Thinking Levels
- Anthropic clarified valid thinking levels: off/minimal/low/medium/high/xhigh
- "low" was causing 400 errors with Opus 4.5
- Fixed by changing thinkingDefault to "medium"

---

## Future Enhancements

### Auto-Download Models
- When Ollama model announced, auto-pull to Mac Mini
- Run quick benchmark
- Report results to main agent

### Image Gen Pipeline
- Auto-test new Flux LoRAs
- Benchmark on Mac Mini vs MacBook
- Generate sample outputs

### API Change Detection
- Monitor Anthropic docs for changes
- Auto-update configs when needed
- Test changes in isolated session

---

## References

- [Clawdbot Config](clawdbot-config.md) — Model routing
- [Ollama Setup](ollama-setup.md) — Local LLM configuration
- [Dev Teams](dev-teams.md) — Bot roles per project
- [MEMORY.md](MEMORY.md) — Long-term findings storage

---

**Status**: ✅ Active — Running every 6 hours on MacBook Pro

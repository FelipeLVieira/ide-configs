# Global Bot Optimization Rules

**Apply these rules to ALL Claude Code bots**

## Token Saving Rules

1. **Use /compact aggressively**
   - Run `/compact` when context reaches 50%
   - Don't wait until 20% - compact early and often

2. **Cache to files, not context**
   - Save research findings to markdown files immediately
   - Don't keep large text blocks in conversation
   - Reference files instead of re-reading them

3. **Be concise**
   - Avoid verbose explanations
   - Use bullet points over paragraphs
   - Skip "I'll now..." preambles

4. **Batch operations**
   - Combine multiple small commands into one
   - Read multiple files in single operations when possible

5. **Don't re-read**
   - Trust your memory of recently read files
   - Only re-read if you're unsure of specific details

## Performance Rules

1. **Parallel when possible**
   - Use sub-agents for independent tasks
   - Don't serialize what can be parallelized

2. **Finish and idle**
   - Complete tasks fully before moving on
   - Go idle when done - don't keep context hot

3. **Push incrementally**
   - Commit and push after each meaningful change
   - Don't accumulate large uncommitted changes

## Search/Research Rules

1. **Search once, document well**
   - Do comprehensive searches upfront
   - Save ALL useful findings to files
   - Don't repeat searches for same info

2. **Use cached knowledge**
   - Check local docs before web searches
   - Reference existing documentation

3. **Rate limit awareness**
   - Wait between API calls when needed
   - Batch searches logically

## X Community Tips (Jan 2026)

### Better Grep = 53% Fewer Tokens (@aaxsh18)
- Use precise file searches instead of reading entire directories
- grep/ripgrep with specific patterns
- Don't dump entire files - extract only relevant sections
- Use `--include` and `--exclude` patterns

### Visual Building (@0xPaulius)  
- "no API tokens, no confusing cursor"
- Build visually when possible to avoid token burn

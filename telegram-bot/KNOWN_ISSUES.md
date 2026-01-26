# Known Issues and Fixes

This document covers issues encountered with the claude-code-telegram bot and their solutions.

## Issue 1: "No result message received from Claude Code"

**Symptoms:**
- Bot returns error when Claude gives text-only responses
- Works fine when Claude uses tools, fails on simple text answers

**Cause:**
The bot expects JSON output from `--output-format stream-json`, but Claude CLI sometimes outputs plain markdown text when giving conversational responses.

**Fix:**
Modify `src/claude/integration.py` to handle non-JSON output as fallback:

1. In `_handle_process_output()`, add variables to collect fallback content:
```python
fallback_text_lines = []
assistant_text_content = []
```

2. In the JSON parsing loop, store non-JSON lines:
```python
except json.JSONDecodeError as e:
    if line.strip():
        fallback_text_lines.append(line)
    continue
```

3. Before raising the "No result" error, create synthetic result from fallback:
```python
if not result:
    fallback_content = None
    if assistant_text_content:
        fallback_content = "\n".join(assistant_text_content)
    elif fallback_text_lines:
        fallback_content = "\n".join(fallback_text_lines)

    if fallback_content:
        result = {
            "type": "result",
            "result": fallback_content,
            "session_id": "",
            "cost_usd": 0.0,
            "duration_ms": 0,
            "num_turns": 1,
            "is_error": False,
        }
```

---

## Issue 2: WinError 2 - File Not Found (Windows)

**Symptoms:**
- `[WinError 2] The system cannot find the file specified`
- Bot crashes when trying to execute Claude

**Cause:**
The bot uses `CLAUDE_BINARY_PATH` internally, not `CLAUDE_CLI_PATH`.

**Fix:**
Set BOTH variables in `.env`:
```env
CLAUDE_CLI_PATH=C:\Users\YourName\AppData\Roaming\npm\claude.cmd
CLAUDE_BINARY_PATH=C:\Users\YourName\AppData\Roaming\npm\claude.cmd
```

---

## Issue 3: Wrong Model (Sonnet instead of Opus)

**Symptoms:**
- Bot uses Sonnet even when configured for Opus
- Model setting appears to be ignored

**Cause:**
Short model names don't work; full model IDs are required.

**Fix:**
Use the full model ID in `.env`:
```env
CLAUDE_MODEL=claude-opus-4-5-20251101
```

---

## Issue 4: ALLOWED_USERS Validation Error

**Symptoms:**
- `validation error for Settings` on startup
- Error mentions `allowed_users` field

**Cause:**
The settings parser expects a list but receives a single integer.

**Fix:**
Add validator to `src/config/settings.py`:
```python
@field_validator("allowed_users", mode="before")
@classmethod
def parse_allowed_users(cls, v: Any) -> Optional[List[int]]:
    """Parse comma-separated user IDs."""
    if isinstance(v, str):
        return [int(uid.strip()) for uid in v.split(",") if uid.strip()]
    if isinstance(v, int):
        return [v]
    return v
```

---

## Issue 5: CLAUDE_ALLOWED_TOOLS Validation Error

**Symptoms:**
- `validation error for Settings` on startup
- Error mentions `claude_allowed_tools` field

**Cause:**
The settings parser doesn't handle comma-separated strings for tools.

**Fix:**
Add validator to `src/config/settings.py`:
```python
@field_validator("claude_allowed_tools", mode="before")
@classmethod
def parse_allowed_tools(cls, v: Any) -> Optional[List[str]]:
    """Parse comma-separated tool names."""
    if isinstance(v, str):
        return [tool.strip() for tool in v.split(",") if tool.strip()]
    return v
```

---

## Issue 6: Shell Commands Blocked

**Symptoms:**
- Claude can't use shell operators like `>`, `|`, `&`, `;`
- Commands fail with "Invalid argument: contains forbidden pattern"

**Cause:**
Security validator blocks shell operators by default.

**Fix:**
For personal/trusted setups, add to `.env`:
```env
DISABLE_COMMAND_VALIDATION=true
```

And modify `src/security/validators.py`:
1. Add `disable_command_validation` parameter to `__init__`
2. Create `PATH_ONLY_PATTERNS` for minimal validation
3. Check `disable_command_validation` in validation methods

---

## Applying Fixes

If you encounter these issues, you can either:
1. Apply the fixes manually to your clone
2. Wait for upstream fixes in the original repo
3. Use a fork with these fixes applied

The full patched files are available in this repository for reference.

# context-window-status-line

A [Claude Code](https://claude.com/claude-code) status line that shows the model name and
context-window usage as a color-coded progress bar with absolute token counts.

```
Claude Fable 5  [████░░░░░░░░░░░░░░░░] 42,301 / 400,000  (10%)
```

- Model display name on the left
- 20-character progress bar (`█` filled, `░` empty)
- Absolute tokens used / context window size, with thousands separators
- Percentage of the window used

The bar and the percentage change color with **absolute** tokens used:

| Tokens used | Color |
|---|---|
| < 100k | green |
| 100k–150k | pale green |
| 150k–200k | orange |
| 200k–300k | light red |
| > 300k | red |

Before the first message of a session, it shows the model name, an empty bar, and the
window size (`ctx: 400,000`).

## Requirements

- `bash`, `jq`, and `bc` (all preinstalled on macOS; on Linux install `jq` if missing)

## Install

1. Copy the script to your Claude config directory and make it executable:

   ```bash
   cp statusline-command.sh ~/.claude/statusline-command.sh
   chmod +x ~/.claude/statusline-command.sh
   ```

2. Wire it into `~/.claude/settings.json` by adding the `statusLine` key:

   ```json
   {
     "statusLine": {
       "type": "command",
       "command": "bash /Users/YOUR_USERNAME/.claude/statusline-command.sh"
     }
   }
   ```

   Replace `YOUR_USERNAME` with your username (or use the absolute path to wherever you
   put the script — `~` is not expanded here). If your `settings.json` already has other
   keys (model, theme, …), just add `statusLine` alongside them.

3. Restart Claude Code (or start a new session). The status line appears at the bottom.

## Customizing

- **Colors / thresholds** — edit the `if/elif` chain at the top of the script. Colors are
  ANSI 256-color escape codes (`\033[38;5;<n>m`); thresholds are absolute token counts.
- **Bar width** — change the hard-coded `20` (bar build loop and the `empty=$((20 - filled))`
  line).

## How it works

Claude Code pipes a JSON payload to the status line command on every refresh. The script
reads `model.display_name`, `context_window.total_input_tokens`,
`context_window.context_window_size`, and `context_window.used_percentage` with `jq` and
renders the line with `printf`.

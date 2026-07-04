#!/usr/bin/env bash
# ~/.claude/statusline-command.sh
# Displays: model name | progress bar | used/total tokens | percentage

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Unknown model"')
used=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total=$(echo "$input" | jq -r '.context_window.context_window_size // 0')
pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Pick color by absolute tokens used: green <100k, pale green 100k-150k,
# orange 150k-200k, light red 200k-300k, red >300k
if   [ "$used" -lt 100000 ]; then color='\033[38;5;40m'   # green
elif [ "$used" -lt 150000 ]; then color='\033[38;5;114m'  # pale green
elif [ "$used" -lt 200000 ]; then color='\033[38;5;208m'  # orange
elif [ "$used" -lt 300000 ]; then color='\033[91m'        # light red
else                              color='\033[31m'        # red
fi
reset='\033[0m'

# Build progress bar (20 chars wide)
if [ -n "$pct" ] && [ "$total" -gt 0 ]; then
  filled=$(printf "%.0f" "$(echo "$pct * 20 / 100" | bc -l)")
  empty=$((20 - filled))
  bar=""
  for i in $(seq 1 "$filled"); do bar="${bar}█"; done
  for i in $(seq 1 "$empty");  do bar="${bar}░"; done
  printf "%s  [${color}%s${reset}] %'d / %'d  (${color}%.0f%%${reset})" \
    "$model" \
    "$bar" \
    "$used" \
    "$total" \
    "$pct"
else
  # No messages yet — show model and window size only
  printf "%s  [%s]  ctx: %'d" "$model" "░░░░░░░░░░░░░░░░░░░░" "$total"
fi

#!/usr/bin/env bash
input=$(cat)
model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

if [ -n "$used" ]; then
    printf "%s | ctx: %s%% used" "$model" "$used"
else
    printf "%s" "$model"
fi

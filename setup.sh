#!/bin/bash
# Quick setup script — copies Claude config to ~/.claude/
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "Installing Claude Code environment to $CLAUDE_DIR"

mkdir -p "$CLAUDE_DIR"

# Directory payloads
for dir in rules commands docs agents skills scripts; do
  if [ -d "$SCRIPT_DIR/$dir" ]; then
    mkdir -p "$CLAUDE_DIR/$dir"
    cp -r "$SCRIPT_DIR/$dir/." "$CLAUDE_DIR/$dir/"
    echo "  ✓ $dir/"
  fi
done

# Root-level assets
for file in AGENTS.md statusline.sh statusline.conf statusline-command.sh ccusage-cache.sh; do
  if [ -f "$SCRIPT_DIR/$file" ]; then
    cp "$SCRIPT_DIR/$file" "$CLAUDE_DIR/$file"
    echo "  ✓ $file"
  fi
done

# settings.json: rewrite hardcoded absolute paths to $HOME so it works on any user
if [ -f "$SCRIPT_DIR/settings.json" ]; then
  sed "s|/home/youngwoo.jeong|$HOME|g" "$SCRIPT_DIR/settings.json" > "$CLAUDE_DIR/settings.json"
  echo "  ✓ settings.json (paths rewritten to \$HOME)"
fi

# Make scripts + statusline executables runnable
chmod +x "$CLAUDE_DIR/statusline.sh" "$CLAUDE_DIR/statusline-command.sh" "$CLAUDE_DIR/ccusage-cache.sh" 2>/dev/null || true
if [ -d "$CLAUDE_DIR/scripts" ]; then
  chmod +x "$CLAUDE_DIR/scripts/"* 2>/dev/null || true
fi

echo ""
echo "Done."
echo "Next steps (optional):"
echo "  - Memory: see README.md for per-project memory setup"
echo "  - Research pipeline: see README.md for research/ setup"
echo "  - Git wrappers (claude-git, git block): bash \"\$CLAUDE_DIR/scripts/install.sh\""

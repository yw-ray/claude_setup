#!/bin/bash
# Quick setup script — copies Claude config to ~/.claude/
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "Installing Claude Code environment to $CLAUDE_DIR"

mkdir -p "$CLAUDE_DIR"

for dir in rules commands docs agents skills; do
  if [ -d "$SCRIPT_DIR/$dir" ]; then
    cp -r "$SCRIPT_DIR/$dir/" "$CLAUDE_DIR/$dir/"
    echo "  ✓ $dir/"
  fi
done

for file in AGENTS.md settings.json; do
  if [ -f "$SCRIPT_DIR/$file" ]; then
    cp "$SCRIPT_DIR/$file" "$CLAUDE_DIR/$file"
    echo "  ✓ $file"
  fi
done

echo ""
echo "Done. Memory and research config need manual setup — see README.md"

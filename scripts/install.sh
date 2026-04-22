#!/bin/bash
# Installation script for git claude alias, claude-git wrapper, and git wrapper
# This script installs:
# 1. claude-git wrapper for personal Claude settings repository
# 2. git wrapper to block Cursor Agent's git commands
# 3. git alias 'claude' for convenient access

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALL_DIR="/usr/local/bin"
GIT_WRAPPER_PATH="$INSTALL_DIR/git"
REAL_GIT_PATH="/usr/bin/git"

echo "Installing scripts..."

# 1. Install claude-git wrapper
echo "1. Installing claude-git wrapper..."
sudo cp "$SCRIPT_DIR/claude-git" "$INSTALL_DIR/claude-git"
sudo chmod +x "$INSTALL_DIR/claude-git"
echo "   ✓ claude-git installed to $INSTALL_DIR/claude-git"

# 2. Install git wrapper (if not already installed or different)
if [[ ! -f "$GIT_WRAPPER_PATH" ]] || ! cmp -s "$SCRIPT_DIR/git-wrapper" "$GIT_WRAPPER_PATH"; then
    echo "2. Installing git wrapper..."
    
    # Backup existing git wrapper if it exists and is different
    if [[ -f "$GIT_WRAPPER_PATH" ]]; then
        echo "   Backing up existing git wrapper..."
        sudo cp "$GIT_WRAPPER_PATH" "$GIT_WRAPPER_PATH.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    sudo cp "$SCRIPT_DIR/git-wrapper" "$GIT_WRAPPER_PATH"
    sudo chmod +x "$GIT_WRAPPER_PATH"
    echo "   ✓ git wrapper installed to $GIT_WRAPPER_PATH"
    echo "   Note: This wrapper blocks git add/commit/push in Cursor Agent environment"
else
    echo "2. Git wrapper already installed (skipping)"
fi

# 3. Set up git alias
echo "3. Setting up git alias 'claude'..."
git config --global alias.claude '!claude-git'
echo "   ✓ Git alias 'claude' configured"

echo ""
echo "Installation complete!"
echo ""
echo "Installed components:"
echo "  - claude-git: Git wrapper for personal Claude settings repository"
echo "  - git wrapper: Blocks Cursor Agent from auto-executing git add/commit/push"
echo "  - git alias 'claude': Convenient access via 'git claude'"
echo ""
echo "Usage:"
echo "  git claude status"
echo "  git claude add ."
echo "  git claude commit -m 'message'"
echo "  git claude push"
echo ""
echo "Or use claude-git directly:"
echo "  claude-git status"
echo "  claude-git push"
echo ""
echo "Note: In Cursor Agent environment, git add/commit/push are blocked."
echo "      Use terminal directly or claude-git for manual operations."

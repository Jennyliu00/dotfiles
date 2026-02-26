#!/bin/bash
# Claude dotfiles installation script
# Creates symlinks from ~/.claude/ to ~/dotfiles/claude/

set -e  # Exit on error

DOTFILES_DIR="$HOME/dotfiles/claude"
CLAUDE_DIR="$HOME/.claude"

echo "🚀 Setting up Claude dotfiles..."
echo ""

# Ensure .claude directory exists
mkdir -p "$CLAUDE_DIR"

# Symlink skills directory
if [ -d "$DOTFILES_DIR/skills" ]; then
    echo "→ Setting up skills..."

    # Remove existing skills directory/symlink
    if [ -L "$CLAUDE_DIR/skills" ]; then
        echo "  Removing existing symlink"
        rm "$CLAUDE_DIR/skills"
    elif [ -d "$CLAUDE_DIR/skills" ]; then
        echo "  ⚠️  Existing skills directory found, backing up..."
        mv "$CLAUDE_DIR/skills" "$CLAUDE_DIR/skills.backup.$(date +%Y%m%d-%H%M%S)"
    fi

    # Create symlink
    ln -s "$DOTFILES_DIR/skills" "$CLAUDE_DIR/skills"
    echo "  ✓ Symlinked: ~/.claude/skills → ~/dotfiles/claude/skills"
else
    echo "  ⚠️  No skills directory found in dotfiles"
fi

# Symlink keybindings.json
if [ -f "$DOTFILES_DIR/keybindings.json" ]; then
    echo "→ Setting up keybindings..."

    # Backup existing keybindings if it's a regular file
    if [ -f "$CLAUDE_DIR/keybindings.json" ] && [ ! -L "$CLAUDE_DIR/keybindings.json" ]; then
        echo "  ⚠️  Existing keybindings found, backing up..."
        mv "$CLAUDE_DIR/keybindings.json" "$CLAUDE_DIR/keybindings.json.backup.$(date +%Y%m%d-%H%M%S)"
    fi

    # Remove existing symlink
    if [ -L "$CLAUDE_DIR/keybindings.json" ]; then
        rm "$CLAUDE_DIR/keybindings.json"
    fi

    # Create symlink
    ln -s "$DOTFILES_DIR/keybindings.json" "$CLAUDE_DIR/keybindings.json"
    echo "  ✓ Symlinked: ~/.claude/keybindings.json → ~/dotfiles/claude/keybindings.json"
else
    echo "  ⚠️  No keybindings.json found in dotfiles"
fi

echo ""
echo "✅ Claude dotfiles installed!"
echo ""
echo "Symlinks created:"
echo "  ~/.claude/skills → ~/dotfiles/claude/skills"
echo "  ~/.claude/keybindings.json → ~/dotfiles/claude/keybindings.json"
echo ""
echo "Note: MCP servers must be configured separately in ~/.claude/mcp-servers.json"
echo "      (This file contains sensitive tokens and is not in dotfiles)"

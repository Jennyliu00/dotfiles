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

# Merge permissions into settings.json
if [ -f "$DOTFILES_DIR/permissions.json" ]; then
    echo "→ Setting up permissions..."

    if [ -f "$CLAUDE_DIR/settings.json" ]; then
        # Backup existing settings
        cp "$CLAUDE_DIR/settings.json" "$CLAUDE_DIR/settings.json.backup.$(date +%Y%m%d-%H%M%S)"

        # Merge permissions using jq
        jq -s '.[0] * .[1]' "$CLAUDE_DIR/settings.json" "$DOTFILES_DIR/permissions.json" > "$CLAUDE_DIR/settings.json.tmp"
        mv "$CLAUDE_DIR/settings.json.tmp" "$CLAUDE_DIR/settings.json"
        echo "  ✓ Merged permissions into settings.json"
    else
        # No existing settings, just copy permissions structure
        cp "$DOTFILES_DIR/permissions.json" "$CLAUDE_DIR/settings.json"
        echo "  ✓ Created settings.json with permissions"
    fi
else
    echo "  ⚠️  No permissions.json found in dotfiles"
fi

# Install Claude plugins
echo "→ Installing Claude plugins..."
if command -v claude &> /dev/null; then
    # Add marketplaces
    echo "  → Adding plugin marketplaces..."
    claude plugin marketplace add anthropics/claude-plugins-official 2>/dev/null || true
    claude plugin marketplace add DataDog/mat-brown-claude-plugins 2>/dev/null || true
    claude plugin marketplace add DataDog/claude-marketplace 2>/dev/null || true

    # Install official Anthropic plugins
    echo "  → Installing Anthropic plugins..."
    claude plugin install commit-commands@claude-plugins-official 2>/dev/null || true
    claude plugin install feature-dev@claude-plugins-official 2>/dev/null || true
    claude plugin install pr-review-toolkit@claude-plugins-official 2>/dev/null || true

    # Install DataDog plugins
    echo "  → Installing DataDog plugins..."
    claude plugin install dd@datadog-claude-plugins 2>/dev/null || true
    claude plugin install osx-notifications@datadog-claude-plugins 2>/dev/null || true

    # Install permissions guard
    echo "  → Installing permissions guard..."
    claude plugin install permissions@mat-brown-contrib 2>/dev/null || true

    echo "  ✓ All plugins installed"
else
    echo "  ⚠️  Claude not found, skipping plugin installation"
fi

echo ""
echo "✅ Claude dotfiles installed!"
echo ""
echo "Symlinks created:"
echo "  ~/.claude/skills → ~/dotfiles/claude/skills"
echo "  ~/.claude/keybindings.json → ~/dotfiles/claude/keybindings.json"
echo ""
echo "Permissions merged into:"
echo "  ~/.claude/settings.json"
echo ""
echo "Plugins installed:"
echo "  commit-commands@claude-plugins-official - Git commit helpers"
echo "  feature-dev@claude-plugins-official - Feature development workflow"
echo "  pr-review-toolkit@claude-plugins-official - PR review tools"
echo "  dd@datadog-claude-plugins - DataDog integration"
echo "  osx-notifications@datadog-claude-plugins - macOS notifications"
echo "  permissions@mat-brown-contrib - Permission guard"
echo ""
echo "Note: MCP servers must be configured separately in ~/.claude/mcp-servers.json"
echo "      (This file contains sensitive tokens and is not in dotfiles)"

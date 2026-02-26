#!/usr/bin/env bash
# Dotfiles installation script
# Sets up development environment, tools, and symlinks configuration files

set -euo pipefail

DOTFILES_PATH="$HOME/dotfiles"
CLAUDE_DIR="$HOME/.claude"

echo "🚀 Installing dotfiles and tools..."
echo ""

# =============================================================================
# Install Homebrew and Tools
# =============================================================================

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "📦 Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "✓ Homebrew already installed"
fi

echo ""
echo "📦 Installing essential tools..."

# CLI tools
TOOLS=(
    "vim"           # Text editor
    "tmux"          # Terminal multiplexer
    "curl"          # HTTP client
    "jq"            # JSON processor
    "gh"            # GitHub CLI
    "git"           # Version control
    "fzf"           # Fuzzy finder
    "ripgrep"       # Fast grep alternative (rg)
    "fd"            # Fast find alternative
    "bat"           # Better cat with syntax highlighting
    "tree"          # Directory visualization
    "htop"          # Process viewer
    "watch"         # Execute command periodically
    "grpcurl"       # gRPC curl
    "go"            # Go programming language
    "node"          # Node.js
)

for tool in "${TOOLS[@]}"; do
    if brew list "$tool" &>/dev/null; then
        echo "  ✓ $tool already installed"
    else
        echo "  → Installing $tool..."
        brew install "$tool"
    fi
done

# Install Claude Code if not present
if ! command -v claude &> /dev/null; then
    echo ""
    echo "🤖 Installing Claude Code..."
    curl -fsSL https://claude.ai/install.sh | bash
else
    echo ""
    echo "✓ Claude Code already installed"
fi

# =============================================================================
# Symlink Dotfiles to Home Directory
# =============================================================================

echo ""
echo "🔗 Symlinking shell configuration files..."

# Symlink dotfiles to home directory (shell configs, git config, etc.)
find "$DOTFILES_PATH" -maxdepth 1 -type f -name ".*" ! -name ".git*" |
while read -r df; do
    filename=$(basename "$df")
    link="$HOME/$filename"

    # Backup existing file if it's not already a symlink
    if [ -f "$link" ] && [ ! -L "$link" ]; then
        echo "  ⚠️  Backing up existing $filename"
        mv "$link" "$link.backup.$(date +%Y%m%d-%H%M%S)"
    fi

    # Remove existing symlink
    [ -L "$link" ] && rm "$link"

    # Create symlink
    ln -s "$df" "$link"
    echo "  ✓ Symlinked: ~/$filename"
done

# =============================================================================
# Set Up Claude Configuration
# =============================================================================

echo ""
echo "🤖 Setting up Claude configuration..."

# Ensure .claude directory exists
mkdir -p "$CLAUDE_DIR"

# Symlink skills directory
if [ -d "$DOTFILES_PATH/claude/skills" ]; then
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
    ln -s "$DOTFILES_PATH/claude/skills" "$CLAUDE_DIR/skills"
    echo "  ✓ Symlinked: ~/.claude/skills → ~/dotfiles/claude/skills"
else
    echo "  ⚠️  No skills directory found in dotfiles"
fi

# Symlink keybindings.json
if [ -f "$DOTFILES_PATH/claude/keybindings.json" ]; then
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
    ln -s "$DOTFILES_PATH/claude/keybindings.json" "$CLAUDE_DIR/keybindings.json"
    echo "  ✓ Symlinked: ~/.claude/keybindings.json → ~/dotfiles/claude/keybindings.json"
else
    echo "  ⚠️  No keybindings.json found in dotfiles"
fi

# Merge permissions into settings.json
if [ -f "$DOTFILES_PATH/claude/permissions.json" ]; then
    echo "→ Setting up permissions..."

    if [ -f "$CLAUDE_DIR/settings.json" ]; then
        # Backup existing settings
        cp "$CLAUDE_DIR/settings.json" "$CLAUDE_DIR/settings.json.backup.$(date +%Y%m%d-%H%M%S)"

        # Merge permissions using jq
        jq -s '.[0] * .[1]' "$CLAUDE_DIR/settings.json" "$DOTFILES_PATH/claude/permissions.json" > "$CLAUDE_DIR/settings.json.tmp"
        mv "$CLAUDE_DIR/settings.json.tmp" "$CLAUDE_DIR/settings.json"
        echo "  ✓ Merged permissions into settings.json"
    else
        # No existing settings, just copy permissions structure
        cp "$DOTFILES_PATH/claude/permissions.json" "$CLAUDE_DIR/settings.json"
        echo "  ✓ Created settings.json with permissions"
    fi
else
    echo "  ⚠️  No permissions.json found in dotfiles"
fi

# =============================================================================
# Install Claude Plugins
# =============================================================================

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

# =============================================================================
# Set Up MCP Servers
# =============================================================================

# Set up MCP servers template if not exists
if [ ! -f "$CLAUDE_DIR/mcp-servers.json" ]; then
    echo "→ Setting up MCP servers template..."
    if [ -f "$DOTFILES_PATH/claude/mcp-servers.template.json" ]; then
        cp "$DOTFILES_PATH/claude/mcp-servers.template.json" "$CLAUDE_DIR/mcp-servers.json"
        echo "  ✓ MCP template copied to ~/.claude/mcp-servers.json"
        echo "  ⚠️  Run 'claude mcp' to authorize Atlassian access"
    fi
else
    echo "→ MCP servers already configured"
fi

# =============================================================================
# Installation Complete
# =============================================================================

echo ""
echo "✅ Installation complete!"
echo ""
echo "📁 Symlinks created:"
echo "  ~/.zshrc → ~/dotfiles/.zshrc"
echo "  ~/.zprofile → ~/dotfiles/.zprofile"
echo "  ~/.bash_profile → ~/dotfiles/.bash_profile"
echo "  ~/.gitconfig → ~/dotfiles/.gitconfig"
echo "  ~/.claude/skills → ~/dotfiles/claude/skills"
echo "  ~/.claude/keybindings.json → ~/dotfiles/claude/keybindings.json"
echo ""
echo "🔧 Permissions merged:"
echo "  ~/.claude/settings.json"
echo ""
echo "🔌 Plugins installed:"
echo "  commit-commands@claude-plugins-official - Git commit helpers"
echo "  feature-dev@claude-plugins-official - Feature development"
echo "  pr-review-toolkit@claude-plugins-official - PR reviews"
echo "  dd@datadog-claude-plugins - DataDog integration"
echo "  osx-notifications@datadog-claude-plugins - macOS notifications"
echo "  permissions@mat-brown-contrib - Permission guard"
echo ""
echo "🔗 MCP Setup:"
echo "  Config: ~/.claude/mcp-servers.json"
echo "  Next: Run 'claude mcp' to authorize Atlassian access"
echo ""
echo "✨ Next steps:"
echo "  1. Restart your shell or run: source ~/.zshrc"
echo "  2. Authorize MCP servers: claude mcp"
echo "  3. Test Claude skills: /jira-ticket GRACE-1234"
echo ""

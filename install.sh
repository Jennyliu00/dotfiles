#!/usr/bin/env bash
# Dotfiles installation script
# Sets up development environment and symlinks configuration files

set -euo pipefail

DOTFILES_PATH="$HOME/dotfiles"

echo "🚀 Installing dotfiles and tools..."
echo ""

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

echo ""
echo "🔗 Symlinking dotfiles..."

# Symlink dotfiles to home directory
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

echo ""
echo "🤖 Setting up Claude configuration..."
if [ -x "$DOTFILES_PATH/claude/install.sh" ]; then
    bash "$DOTFILES_PATH/claude/install.sh"
else
    echo "  ⚠️  Claude install script not found or not executable"
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "Next steps:"
echo "  1. Restart your shell or run: source ~/.bashrc (or ~/.zshrc)"
echo "  2. Configure Claude MCP servers: claude mcp"
echo "  3. Test Claude skills: /jira-ticket"
echo ""

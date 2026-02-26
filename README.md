# Dotfiles

Personal development environment configuration files.

## Contents

- **Shell Configuration** - `.zshrc`, `.zprofile`, `.bash_profile`
- **Git Configuration** - `.gitconfig`, `.gitignore`
- **Claude Configuration** - `claude/` directory with skills, keybindings, permissions
- **Installation Script** - `install.sh` for automated setup

## Quick Start

On a new machine or workspace:

```bash
cd ~/dotfiles
./install.sh
```

This will:
- Install Homebrew and essential tools
- Install Claude Code
- Symlink shell configurations to home directory
- Symlink Claude configurations to `~/.claude/`
- Install Claude plugins
- Set up MCP servers template
- Merge permissions into Claude settings

## Structure

```
dotfiles/
├── README.md              # This file
├── install.sh             # Installation script
├── .gitconfig             # Git configuration
├── .gitignore             # Git ignore patterns
├── .zshrc                 # Zsh shell configuration
├── .zprofile              # Zsh profile
├── .bash_profile          # Bash profile
└── claude/
    ├── README.md          # Claude-specific documentation
    ├── keybindings.json   # Keyboard shortcuts
    ├── permissions.json   # Tool permissions
    ├── mcp-servers.template.json  # MCP server config template
    ├── work/              # Task work directories
    └── skills/
        ├── jira-ticket/   # Jira ticket implementation workflow
        ├── senior-swe/    # Senior software engineer guidance
        └── self-improvement/  # Skill self-improvement system
```

## Skills

- **`/jira-ticket`** - Complete Jira ticket implementation with multi-agent workflow
- **`/write-ticket`** - Enhance Jira ticket with accurate context for implementation
- **`/review-pr`** - Comprehensive multi-agent PR review with senior engineer perspective
- **`/senior-swe`** - Senior engineer guidance on Go, Zoltron, systems, code review
- **`/self-improvement`** - Reflect and update skills based on learnings

See `claude/README.md` for detailed skill documentation.

## Development

### Making Changes

When adding, modifying, or removing files in this repository:

**⚠️ IMPORTANT: Always update the appropriate README files**
- Update `README.md` for top-level changes (shell configs, git, structure)
- Update `claude/README.md` for Claude-specific changes (skills, keybindings, permissions)
- Keep documentation in sync with actual file structure
- Document new skills, tools, or configuration options

### Adding New Skills

1. Create skill directory: `mkdir -p claude/skills/skill-name`
2. Create `SKILL.md` with skill definition
3. Add to permissions: Edit `claude/permissions.json` to include `Skill(skill-name)`
4. **Update `claude/README.md`** with skill description and usage
5. Commit and push

### Testing Changes

Test your dotfiles setup:
1. Make changes in dotfiles repo
2. Run `./install.sh` to apply changes
3. Verify symlinks: `ls -la ~/ | grep -E "zshrc|gitconfig"`
4. Verify Claude setup: `ls -la ~/.claude/ | grep -E "skills|keybindings"`
5. Test skills: `/jira-ticket --help`

## Notes

- Shell configurations are synced across machines via this repo
- Claude configurations use symlinks for live updates
- `~/.claude/mcp-servers.json` is NOT in repo (contains auth tokens)
- `~/.claude/settings.local.json` is NOT in repo (local overrides)
- Work artifacts go in `claude/work/<ticket>/` (gitignored)

## Resources

- [Claude Code Documentation](https://code.claude.com/docs)
- [Dotfiles Guide](https://dotfiles.github.io/)
- [Homebrew](https://brew.sh/)

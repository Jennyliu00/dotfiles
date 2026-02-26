# Claude Configuration

Personal Claude Code configuration files.

## Quick Start

```bash
cd ~/dotfiles/claude
./install.sh
```

## What's Included

- **Skills** - Custom task automation (`/jira-ticket`)
- **Keybindings** - Keyboard shortcuts
- **Permissions** - Pre-configured tool permissions
- **Documentation** - See `CLAUDE.md` for full details
- **Work** - Work-specific configurations

## Files

```
claude/
├── CLAUDE.md              # Global Claude instructions
├── README.md              # This file
├── install.sh             # Setup script
├── .gitignore             # Exclude sensitive files
├── keybindings.json       # Keyboard shortcuts
├── permissions.json       # Permission settings
├── work/                  # Work-specific configs
└── skills/
    └── jira-ticket/
        └── SKILL.md       # Task loader with multi-agent orchestration
```

## Usage

Start a task:
```bash
/jira-ticket <task-id, page-id, or confluence-url>
```

The skill will:
1. Load task from Confluence
2. Fetch Jira ticket details
3. Orchestrate agents to implement the task
4. Create PR automatically

See `CLAUDE.md` for complete documentation.

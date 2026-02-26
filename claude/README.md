# Claude Configuration

Personal Claude Code configuration files.

## Quick Start

```bash
cd ~/dotfiles/claude
./install.sh
```

## What's Included

- **Skills** - Custom task automation (`/mytask`)
- **Keybindings** - Keyboard shortcuts
- **Documentation** - See `CLAUDE.md` for full details

## Files

```
claude/
├── CLAUDE.md              # Full documentation
├── README.md              # This file
├── install.sh             # Setup script
├── .gitignore             # Exclude sensitive files
├── keybindings.json       # Keyboard shortcuts
└── skills/
    └── mytask/
        └── SKILL.md       # Task loader with multi-agent orchestration
```

## Usage

Start a task:
```bash
/mytask <task-id, page-id, or confluence-url>
```

The skill will:
1. Load task from Confluence
2. Fetch Jira ticket details
3. Orchestrate agents to implement the task
4. Create PR automatically

See `CLAUDE.md` for complete documentation.

# Claude Configuration

Personal Claude Code configuration files.

## Quick Start

```bash
cd ~/dotfiles/claude
./install.sh
```

## What's Included

- **Skills** - Custom task automation (`/jira-ticket`, `/write-ticket`, `/senior-swe`, `/self-improvement`)
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

### Enhance a Jira Ticket
```bash
/write-ticket GRACE-1234
```
Analyzes ticket, adds context, acceptance criteria, and references.

### Implement a Jira Ticket
```bash
/jira-ticket GRACE-1234
```
Complete multi-agent workflow from analysis to draft PR.

### Get Senior Engineer Guidance
```bash
/senior-swe
```
Expert advice on Go, Zoltron, systems design, code review.

### Improve Skills
```bash
/self-improvement
```
Reflect on learnings and update skills.

See `CLAUDE.md` for complete documentation.

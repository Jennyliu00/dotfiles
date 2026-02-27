# Claude Configuration

Personal Claude Code configuration files.

## Quick Start

```bash
cd ~/dotfiles
./install.sh
```

## What's Included

- **Skills** - Custom task automation (`/deploy-to-staging`, `/jira-ticket`, `/write-ticket`, `/review-pr`, `/senior-swe`, `/self-improvement`)
- **Keybindings** - Keyboard shortcuts
- **Permissions** - Pre-configured tool permissions
- **Documentation** - See `CLAUDE.md` for full details
- **Work** - Work-specific configurations

## Files

```
claude/
├── CLAUDE.md              # Global Claude instructions
├── README.md              # This file
├── .gitignore             # Exclude sensitive files
├── keybindings.json       # Keyboard shortcuts
├── permissions.json       # Permission settings
├── mcp-servers.template.json  # MCP server config template
├── work/                  # Work-specific configs
└── skills/
    ├── deploy-to-staging/ # Deploy to zoltron staging with conflict resolution
    ├── jira-ticket/       # Multi-agent workflow for ticket implementation
    ├── write-ticket/      # Enhance Jira tickets with context
    ├── review-pr/         # Comprehensive PR review
    ├── senior-swe/        # Senior engineer guidance
    └── self-improvement/  # Skill self-improvement system
```

## Usage

### Deploy to Staging
```bash
/deploy-to-staging 365040
```
Integrates PR into zoltron/staging with automatic conflict resolution.

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

### Review a Pull Request
```bash
/review-pr 12345
```
Multi-agent comprehensive code review looking for bugs, security issues, and code quality.

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

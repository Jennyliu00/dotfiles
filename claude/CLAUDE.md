# Claude Configuration

This directory contains my Claude Code configuration files.

## Contents

- **`skills/`** - Custom Claude skills for task automation
- **`keybindings.json`** - Keyboard shortcuts
- **`install.sh`** - Installation script for new machines
- **`.gitignore`** - Files to exclude from version control

## Installation

On a new machine:

```bash
cd ~/dotfiles/claude
./install.sh
```

This will create symlinks from `~/.claude/` to your dotfiles directory.

## Skills

### mytask

Load tasks from personal Confluence with Jira ticket context.

**Usage:**
```bash
/mytask <task-id, page-id, or url>
```

**What it does:**
1. Loads task from Confluence (Dawg space)
2. Extracts linked Jira ticket
3. Fetches Jira details (title, description, status)
4. Orchestrates multi-agent workflow to completion
5. Creates PR automatically

**Multi-Agent Workflow:**
- Manager Agent: Coordinates entire workflow
- Exploration Agents: Study patterns, codebase, tests (parallel)
- Implementation Agent: Writes code following patterns
- Review Agent: Reviews code quality and correctness
- PR Agent: Creates PR and pushes to GitHub

**Critical:** The workflow runs to completion automatically - it doesn't stop until PR is created and ready.

## Keybindings

- **Shift+Enter**: Submit message in chat

## MCP Servers

This setup uses two Atlassian MCP servers:

### Personal Confluence (`atlassian-mcp-server-personal`)
- **Instance**: jennyliu887.atlassian.net
- **Cloud ID**: `2cd08c26-b6ca-47ed-8c8b-74a153f0bc80`
- **Space**: "Dawg" (KB, space ID: 98536)
- **Tasks parent page**: ID `287244312`

### Work Jira/Confluence (`atlassian-mcp-server`)
- **Instance**: datadoghq.atlassian.net
- **Cloud ID**: `66c05bee-f5ff-4718-b6fc-81351e5ef659`

**Setup:** MCP servers are configured in `~/.claude/mcp-servers.json` (not in dotfiles - contains sensitive tokens).

## Directory Structure

```
~/.claude/                          # Claude's config directory
├── config.json                     # ⚠️ Not in dotfiles (API keys)
├── mcp-servers.json                # ⚠️ Not in dotfiles (auth tokens)
├── skills/ ──────────> symlink ──> ~/dotfiles/claude/skills/
└── keybindings.json ──> symlink ──> ~/dotfiles/claude/keybindings.json

~/dotfiles/claude/                  # This directory (in git)
├── CLAUDE.md
├── skills/
│   └── mytask/
│       └── SKILL.md
├── keybindings.json
├── install.sh
└── .gitignore
```

## What NOT to Commit

Never commit these to git:
- `config.json` - Contains Claude API keys
- `mcp-servers.json` - Contains OAuth tokens for Atlassian
- `projects/` - Conversation history (may contain sensitive data)
- `*.log` files

These are excluded via `.gitignore`.

## Workflow

### Daily Usage

1. **Start task:**
   ```bash
   /mytask 123  # Or page ID, or URL
   ```

2. **Agent orchestration happens automatically:**
   - Task context loaded
   - Codebase explored
   - Implementation written
   - Code reviewed
   - PR created

3. **Result:**
   - PR URL provided
   - Confluence page updated with progress
   - Ready for review

### Adding New Skills

1. Create skill directory:
   ```bash
   mkdir -p ~/dotfiles/claude/skills/newskill
   ```

2. Create `SKILL.md` with frontmatter:
   ```markdown
   ---
   name: newskill
   description: What this skill does
   context: fork
   agent: general-purpose
   ---

   # Skill content here
   ```

3. Commit:
   ```bash
   cd ~/dotfiles
   git add claude/skills/newskill/
   git commit -m "Add newskill"
   git push
   ```

4. Symlinks already created by `install.sh`, so skill is immediately available!

## Tips

- **Check symlinks:** `ls -la ~/.claude/` to verify symlinks are working
- **Test skill:** `/mytask` should work immediately after install
- **Re-run install:** If symlinks break, just run `./install.sh` again
- **Update from anywhere:** Edit files in either `~/.claude/` or `~/dotfiles/claude/` - they're the same files via symlinks

## Troubleshooting

### "Skill not found"
- Check symlink: `ls -la ~/.claude/skills`
- Should show: `skills -> /Users/jing.liu/dotfiles/claude/skills`
- Re-run: `cd ~/dotfiles/claude && ./install.sh`

### "MCP server requires re-authorization"
- MCP tokens expire periodically
- Run: `/mcp` to re-authenticate
- This is normal, happens every few weeks

### "Cloud id isn't explicitly granted"
- MCP authentication issue
- Run: `/mcp` to re-authorize both servers

## References

- [Claude Code Documentation](https://code.claude.com/docs)
- [MCP Documentation](https://modelcontextprotocol.io)
- [Atlassian MCP Server](https://github.com/modelcontextprotocol/servers/tree/main/src/atlassian)

---

**Note:** This configuration is personal and contains references to my Confluence/Jira instances. When sharing or using as inspiration, update Cloud IDs, space IDs, and instance URLs to match your own setup.

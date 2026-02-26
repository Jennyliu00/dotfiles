# Atlassian MCP Setup

This guide explains how to set up Atlassian MCP servers for Claude Code.

## Prerequisites

- Node.js and npm installed
- Atlassian account with access to Confluence/Jira

## Setup Steps

### 1. Create OAuth App in Atlassian

1. Go to https://developer.atlassian.com/console/myapps/
2. Click "Create" → "OAuth 2.0 integration"
3. Fill in the details:
   - **App name**: Claude MCP (Personal) / Claude MCP (Work)
   - **Redirect URL**: `http://localhost:3000/oauth/callback`
4. Click "Create"
5. Note down:
   - **Client ID**
   - **Client Secret**
6. Add permissions (scopes):
   - `read:confluence-content.all`
   - `write:confluence-content`
   - `read:confluence-space.summary`
   - `read:jira-work`
   - `write:jira-work`

### 2. Configure MCP Servers

Copy the template and fill in your OAuth credentials:

```bash
cp ~/dotfiles/claude/mcp-servers.template.json ~/.claude/mcp-servers.json
```

Edit `~/.claude/mcp-servers.json` and replace:
- `<YOUR_OAUTH_CLIENT_ID>` with your actual OAuth Client ID
- `<YOUR_OAUTH_CLIENT_SECRET>` with your actual OAuth Client Secret

**Important**: Do NOT commit this file to git - it contains secrets!

### 3. Authorize Access

Run Claude MCP authorization:

```bash
claude mcp
```

Follow the prompts to authorize both:
1. `atlassian-mcp-server-personal` (for jennyliu887.atlassian.net)
2. `atlassian-mcp-server` (for datadoghq.atlassian.net)

### 4. Verify Setup

Test the connection:

```bash
claude mcp list-servers
```

You should see both Atlassian MCP servers listed and connected.

## Configuration Details

### Personal Confluence (atlassian-mcp-server-personal)
- **Cloud ID**: `2cd08c26-b6ca-47ed-8c8b-74a153f0bc80`
- **Instance**: https://jennyliu887.atlassian.net
- **Space**: "Dawg" (KB, space ID: 98536)
- **Access**: Only "Dawg" space, never "Life" (JL) or "carmelodd123"

### Work Jira/Confluence (atlassian-mcp-server)
- **Cloud ID**: `66c05bee-f5ff-4718-b6fc-81351e5ef659`
- **Instance**: https://datadoghq.atlassian.net
- **Access**: Work Jira and Confluence

## Troubleshooting

### "Cloud id isn't explicitly granted"
- MCP authentication expired
- Run: `claude mcp` to re-authorize

### "MCP server requires re-authorization"
- Tokens expire periodically (every few weeks)
- Run: `claude mcp` to re-authenticate
- This is normal behavior

### Connection timeout
- Check internet connection
- Verify OAuth credentials are correct
- Ensure redirect URI is exactly: `http://localhost:3000/oauth/callback`

## Security Notes

- **Never commit** `~/.claude/mcp-servers.json` to version control
- OAuth secrets should be kept private
- Tokens expire and need periodic re-authorization
- The template file (`mcp-servers.template.json`) is safe to commit (no secrets)

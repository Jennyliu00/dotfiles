---
name: mytask
description: Load a task from personal Confluence with Jira ticket context. Use when starting work on a task, need task context, or want to resume previous work.
argument-hint: "[task-id, page-id, or confluence-url]"
context: fork
agent: general-purpose
allowed-tools: Bash, Read, Grep, WebFetch, Glob, Edit, Write
---

# Load Task from Confluence

Load task from personal Confluence and fetch related Jira ticket details.

## Input

You'll receive a task identifier as an argument:
- **Task ID**: Numeric identifier (e.g., `123`)
- **Page ID**: Confluence page ID (e.g., `287244312`)
- **URL**: Full Confluence page URL

## Process

1. **Parse the input** to identify the task source (ID, page ID, or URL)

2. **Load from Confluence** using the `atlassian-mcp-server-personal` MCP server:
   - Cloud ID: `2cd08c26-b6ca-47ed-8c8b-74a153f0bc80`
   - Space: "Dawg" (KB) - Space ID: `98536`
   - Tasks parent page: ID `287244312`
   - Instance: jennyliu887.atlassian.net
   - Call `mcp__atlassian-mcp-server-personal__getConfluencePage` to fetch the page with contentFormat: "markdown"

3. **Extract Jira ticket links** from the page content:
   - Look for patterns: `[JIRA-123](url)` or `JIRA-123` or datadoghq.atlassian.net links
   - Extract the ticket key (e.g., `ACCESS-123`, `JIRA-123`)

4. **Fetch Jira details** using the `atlassian-mcp-server` MCP server:
   - Cloud ID: `66c05bee-f5ff-4718-b6fc-81351e5ef659`
   - Instance: datadoghq.atlassian.net
   - Call `mcp__atlassian-mcp-server__getJiraIssue` with the extracted ticket key
   - Fetch: title, description, status, assignee, priority, linked issues

5. **Update Confluence page** with task details:
   - Call `mcp__atlassian-mcp-server-personal__updateConfluencePage` to populate the page
   - Include: objective, implementation plan, testing commands, progress checklist
   - Use markdown format with clear structure

6. **Output both contexts** in a structured format:
   ```
   ## Task: [Task Title]
   Page ID: [ID]
   URL: [Confluence URL]

   ### Context
   [Confluence page content - summary]

   ### Related Jira Ticket
   - **Key**: [JIRA-KEY]
   - **Title**: [Issue title]
   - **Status**: [Status]
   - **Priority**: [Priority]
   - **Description**: [Summary of description]
   - **Link**: [URL to ticket]

   ### Next Steps
   [Parse task requirements and suggest first actions]
   ```

7. **Automatically orchestrate multi-agent workflow to completion**:
   - DO NOT ask user - automatically proceed with full implementation
   - Spawn multiple specialized agents in parallel
   - Continue until PR is created, reviewed, and ready
   - **CRITICAL**: Do not stop until PR is complete

## Multi-Agent Orchestration

After loading task context, AUTOMATICALLY spawn these agents:

### Manager Agent (Primary Coordinator)
- **Role**: Oversee entire workflow, coordinate other agents, ensure PR completion
- **Subagent type**: general-purpose
- **Responsibilities**:
  - Track progress of all sub-agents
  - Make decisions on next steps
  - Ensure PR is created and passes review
  - Update Confluence page with progress
  - **DO NOT STOP until PR is created and reviewed**

### Exploration Agents (Run in Parallel)
Spawn 2-3 exploration agents depending on task complexity:
- **Pattern Explorer**: Study existing code patterns and reference implementations
- **Codebase Explorer**: Understand current implementation and dependencies
- **Test Explorer**: Understand test patterns and coverage requirements

### Implementation Agent
- **Role**: Write code following discovered patterns
- **Waits for**: Exploration agents to complete
- **Responsibilities**:
  - Implement changes in small, logical commits
  - Run `goimports -w` on changed files
  - Run tests after each commit
  - Follow git practices (specific file staging, proper commit messages)

### Review Agent
- **Role**: Review implementation for quality, correctness, and completeness
- **Waits for**: Implementation agent to complete
- **Responsibilities**:
  - Run code review (use `/go-review` for Go code)
  - Check backwards compatibility
  - Verify test coverage
  - Apply feedback and re-commit if needed

### PR Agent
- **Role**: Create and manage pull request
- **Waits for**: Review agent approval
- **Responsibilities**:
  - Create stacked PR if applicable (using Graphite)
  - Write PR title following format: `[TICKET-KEY] description`
  - Write PR description (no "Test Results" or "Files Changed" sections)
  - Push to GitHub
  - Update Confluence with PR link

## Workflow Execution

The Manager Agent orchestrates this flow:

```
1. Load Task Context
   ↓
2. Update Confluence Page
   ↓
3. Spawn Exploration Agents (parallel)
   ↓
4. Wait for exploration complete
   ↓
5. Spawn Implementation Agent
   ↓
6. Monitor implementation progress
   ↓
7. Spawn Review Agent
   ↓
8. Apply review feedback if needed
   ↓
9. Spawn PR Agent
   ↓
10. Verify PR created
   ↓
11. Update Confluence with completion status
   ↓
12. DONE - Report PR URL to user
```

**CRITICAL RULES**:
- Manager agent runs continuously until PR is created
- If any agent fails, Manager spawns replacement or adjusts plan
- Manager updates Confluence page at each major milestone
- **NEVER stop before PR is created and ready for review**

## Argument Parsing

Handle three input formats:
- **Numeric (task ID)**: `123` → Search tasks parent page for child with ID `123`
- **Page ID**: `287244312` → Direct fetch of that page
- **URL**: `https://jennyliu887.atlassian.net/wiki/spaces/KB/pages/123456` → Extract page ID and fetch

## Important Notes

- **Only access "Dawg" space** in personal Confluence - never "Life" (JL) or "carmelodd123"
- Always fetch both Confluence context AND Jira details together
- Preserve page ID for agents to write updates using `updateConfluencePage`
- Keep formatting clear and structured for easy reading and reference

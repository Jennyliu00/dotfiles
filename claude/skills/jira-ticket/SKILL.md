---
name: jira-ticket
description: Orchestrate complete implementation of Jira ticket from analysis to draft PR using multi-agent workflow
argument-hint: "[jira-ticket-number or jira-url]"
context: fork
agent: general-purpose
allowed-tools: Bash, Read, Grep, WebFetch, Glob, Edit, Write, Task, AskUserQuestion
---

# Jira Ticket Implementation Workflow

Fully automated multi-agent workflow that takes a Jira ticket from requirements to draft PR.

## Input

You'll receive a Jira ticket identifier:
- **Ticket number**: `GRACE-1234` or `1234`
- **Jira URL**: `https://datadoghq.atlassian.net/browse/GRACE-1234`

## Workflow Overview

```
1. Load Jira ticket → 2. Create work directory → 3. Understand context
   ↓
4. Generate PM agent → 5. Study codebase → 6. Create implementation plan
   ↓
7. User reviews plan → 8. User confirms/updates plan
   ↓
9. PM spawns senior SWE agents → 10. Agents implement in parallel
   ↓
11. Agents review each other → 12. Continue until acceptance criteria met
   ↓
13. Create draft PR → 14. Report completion
```

## Phase 1: Load Context

### Step 1: Parse Jira Ticket

**Extract ticket key**:
```bash
# From ticket number
TICKET="GRACE-1234"

# From URL
TICKET=$(echo "https://datadoghq.atlassian.net/browse/GRACE-1234" | grep -oE '[A-Z]+-[0-9]+')
```

### Step 2: Create Work Directory

**Create ticket workspace**:
```bash
WORK_DIR="$HOME/.claude/projects/-Users-jing-liu/work/$TICKET"
mkdir -p "$WORK_DIR"
```

**Files in work directory**:
- `context.md` - Jira ticket details, linked docs, acceptance criteria
- `plan.md` - Implementation plan with task breakdown
- `notes.md` - Research notes, findings, decisions
- `review-notes.md` - Code review feedback and tracking

### Step 3: Load Jira Ticket Details

**Fetch ticket using MCP**:
```bash
# Use atlassian-mcp-server (work Jira)
# Cloud ID: 66c05bee-f5ff-4718-b6fc-81351e5ef659
# Instance: datadoghq.atlassian.net
```

Call: `mcp__atlassian-mcp-server__getJiraIssue` with ticket key

**Extract**:
- Title
- Description (parse for requirements, context, acceptance criteria)
- Status
- Assignee
- Priority
- Labels
- Linked issues (depends on, blocks, relates to)
- Linked PRs (if any)
- Attachments (specs, diagrams)
- Comments (important context from team)

### Step 4: Understand Linked Context

**For each linked issue**:
- Fetch linked Jira tickets
- Read linked PR descriptions and code
- Extract relevant patterns and decisions

**For linked documentation**:
- Fetch Confluence pages referenced in description
- Read design docs, RFCs, technical specs
- Extract requirements and constraints

**Create context.md**:
```markdown
# Jira Ticket: <TICKET-KEY> - <Title>

**URL**: <jira-url>
**Status**: <status>
**Priority**: <priority>
**Assignee**: <assignee>

## Description

<ticket description>

## Acceptance Criteria

1. <criterion 1>
2. <criterion 2>
...

## Linked Issues

- **Depends on**: <TICKET-123> - <title>
- **Blocks**: <TICKET-456> - <title>
- **Related**: <TICKET-789> - <title>

## Linked PRs

- PR #12345: <title> - <url>
  - Pattern: <what pattern this demonstrates>
  - Key learnings: <relevant insights>

## Reference Documentation

- <Confluence page 1>: <summary>
- <Confluence page 2>: <summary>

## Key Requirements

1. <requirement extracted from description>
2. <requirement extracted from comments>
...

## Technical Constraints

- <constraint 1>
- <constraint 2>
...

## Open Questions

- <question 1>
- <question 2>
...
```

**Present context to user**:
Show a summary of what was loaded and ask if any additional context is needed.

## Phase 2: Generate Implementation Plan

### Step 5: Spawn Project Manager Agent

**Create PM agent** with Task tool:

```markdown
You are a project manager tasked with planning the implementation of Jira ticket <TICKET-KEY>.

**Work Directory**: <work-dir>
**Context**: Read context.md for full ticket details

**Your Responsibilities**:
1. Study existing codebase patterns
2. Find reference implementations for similar features
3. Understand testing patterns and requirements
4. Break down work into logical, independent subtasks
5. Create detailed implementation plan
6. Identify files to be modified/created
7. Determine optimal work division for parallel implementation

**Study the Codebase**:
- Use Grep/Glob to find similar implementations
- Read key files in domains/aaa/apps/zoltron
- Understand repository patterns, handler patterns, testing patterns
- Find reference PRs for similar work
- Consult reference docs: ~/dotfiles/claude/skills/senior-swe/references/

**Create Plan**:
Write a detailed plan to <work-dir>/plan.md with:
1. Overview of approach
2. Architecture decisions
3. File-by-file breakdown
4. Task division for parallel work
5. Testing strategy
6. Acceptance criteria mapping

**Use senior-swe knowledge**:
- Reference: ~/dotfiles/claude/skills/senior-swe/references/zoltron.md
- Follow existing patterns in the codebase
- Consider backward compatibility
- Plan for error handling, metrics, testing
```

**PM Agent Activities**:

1. **Study Patterns**:
   - Search for similar features in codebase
   - Read existing handlers, repositories, services
   - Understand Frames integration patterns
   - Find testing examples

2. **Analyze Requirements**:
   - Break down acceptance criteria into technical tasks
   - Identify dependencies between tasks
   - Determine critical path
   - Estimate complexity

3. **Design Approach**:
   - Choose architecture pattern (following existing conventions)
   - Plan database changes (migrations, queries)
   - Plan API changes (handlers, validators)
   - Plan Frames integration (if needed)
   - Plan testing approach

4. **Divide Work**:
   - Create subtasks that can be worked in parallel
   - Ensure subtasks are independent (no file conflicts)
   - Assign clear boundaries for each subtask
   - Identify integration points

### Step 6: Create Implementation Plan

**PM writes plan.md**:

```markdown
# Implementation Plan: <TICKET-KEY>

## Overview

<High-level description of approach>

## Architecture Decisions

### Decision 1: <Name>
**Choice**: <what we chose>
**Rationale**: <why this approach>
**Alternatives Considered**: <other options>

[Repeat for each decision]

## Reference Implementations

- **Similar Feature**: <file>:<lines> - <description>
- **Pattern to Follow**: <file>:<lines> - <description>

## Files to Modify

### New Files
1. `path/to/file.go` - <purpose>
2. `path/to/file_test.go` - <purpose>

### Modified Files
1. `path/to/existing.go` - <what changes>
2. `path/to/another.go` - <what changes>

## Task Breakdown

### Task 1: <Name> (Agent: SWE-1)
**Files**: <list of files this agent owns>
**Responsibilities**:
- <specific task 1>
- <specific task 2>
**Dependencies**: None
**Acceptance**: <how to verify completion>

### Task 2: <Name> (Agent: SWE-2)
**Files**: <list of files this agent owns>
**Responsibilities**:
- <specific task 1>
- <specific task 2>
**Dependencies**: None (can work in parallel with Task 1)
**Acceptance**: <how to verify completion>

### Task 3: <Name> (Agent: SWE-3)
**Files**: <list of files this agent owns>
**Responsibilities**:
- <specific task 1>
- <specific task 2>
**Dependencies**: Task 1, Task 2 (must complete first)
**Acceptance**: <how to verify completion>

[Continue for all tasks]

## Integration Points

Where tasks come together:
1. <Integration point 1>: <how tasks 1 and 2 connect>
2. <Integration point 2>: <how tasks 2 and 3 connect>

## Testing Strategy

### Unit Tests
- <what to test>
- <which files>

### Integration Tests
- <what to test>
- <test scenarios>

### Manual Testing
- <steps to verify>

## Database Changes

### Migrations
- <migration 1>
- <migration 2>

### Queries
- <new queries needed>

## Metrics & Observability

- <metrics to add>
- <logs to add>
- <traces to add>

## Deployment Considerations

- <rollout strategy>
- <feature flags>
- <rollback plan>

## Acceptance Criteria Mapping

1. ✓ <Criterion 1> - Satisfied by Task 1 + Task 3
2. ✓ <Criterion 2> - Satisfied by Task 2
...

## Estimated Complexity

- **Total Tasks**: <number>
- **Parallel Tasks**: <number>
- **Sequential Tasks**: <number>
- **Critical Path**: Task 1 → Task 3 → Task 5
```

### Step 7: Request User Review

**Present plan to user**:
```markdown
I've created an implementation plan for <TICKET-KEY>.

**Overview**:
- <brief summary of approach>
- <key architecture decisions>

**Work Division**:
- <N> tasks that can run in parallel
- <M> tasks that are sequential
- Estimated <X> senior SWE agents needed

**Plan Details**: <work-dir>/plan.md

Please review the plan. You can:
1. Approve as-is → I'll proceed with implementation
2. Request changes → Edit plan.md or tell me what to change
3. Ask questions → I'll clarify or investigate further

Would you like me to proceed with this plan?
```

### Step 8: User Confirmation

**Wait for user response**:
- User approves → Proceed to Phase 3
- User requests changes → PM updates plan, repeat Step 7
- User has questions → Answer, clarify, update plan as needed

**If user edits plan.md directly**:
- Re-read plan.md
- Acknowledge changes
- Ask for confirmation to proceed

## Phase 3: Implementation

### Step 9: Spawn Senior SWE Agents

**PM spawns multiple agents** based on task breakdown:

**For each independent task**, spawn an agent:

```markdown
You are Senior SWE Agent <N> implementing <Task Name> for <TICKET-KEY>.

**Work Directory**: <work-dir>
**Your Task**: Read plan.md - you own Task <N>
**Context**: Read context.md for full requirements

**Your Files** (you own these - no conflicts with other agents):
- <file 1>
- <file 2>
- <file 3>

**Your Responsibilities**:
1. <responsibility 1>
2. <responsibility 2>
...

**Implementation Guidelines**:
- Read plan.md for architecture decisions and patterns to follow
- Reference ~/dotfiles/claude/skills/senior-swe/references/zoltron.md
- Follow existing codebase patterns
- Write tests alongside code
- Run `goimports -w` on changed Go files
- Create small, logical commits (one per feature/fix)
- Commit message format: `<TICKET-KEY>: <description>`
- Do NOT include Co-Authored-By in commits

**Testing**:
- Write unit tests for your code
- Run tests after each change: `bzl test //path/to:test`
- Ensure tests pass before marking task complete

**Code Review**:
- Review your own code before completing
- Check for: correctness, error handling, test coverage
- Use checklist from senior-swe/references/review.md

**When Complete**:
- Mark your task as done
- Report back: files changed, tests added, commits created
- Code is ready for peer review

**CRITICAL**:
- Stay within your assigned files
- Follow the architecture from plan.md
- Maintain backward compatibility
- Add appropriate metrics/logging
```

**Spawn agents in parallel** for independent tasks:
```typescript
// Example: 3 parallel agents
Task({ subagent_type: "general-purpose", description: "Implement Task 1", prompt: <prompt1> })
Task({ subagent_type: "general-purpose", description: "Implement Task 2", prompt: <prompt2> })
Task({ subagent_type: "general-purpose", description: "Implement Task 3", prompt: <prompt3> })
```

### Step 10: Monitor Implementation

**PM tracks agent progress**:
- Wait for agents to complete
- Handle questions/blockers
- Resolve conflicts if any arise
- Update notes.md with decisions made

**For sequential tasks**:
- Wait for dependencies to complete
- Spawn next agent when dependencies satisfied

### Step 11: Cross-Agent Code Review

**After all implementation complete**, spawn review agents:

**Each agent reviews another's code**:

```markdown
You are reviewing Agent <N>'s implementation of <Task Name>.

**Work Directory**: <work-dir>
**Files to Review**: <list of files Agent N modified>
**Context**: Read plan.md and context.md

**Review Checklist**:
Use ~/dotfiles/claude/skills/senior-swe/references/review.md

**Focus Areas**:
1. Correctness - does it meet acceptance criteria?
2. Code quality - follows patterns? readable?
3. Error handling - all cases handled?
4. Testing - adequate coverage?
5. Performance - any concerns?
6. Security - any vulnerabilities?
7. Backward compatibility - safe to deploy?

**Provide Feedback**:
Write feedback to <work-dir>/review-notes.md:
- 🔴 Critical issues (must fix)
- 🟡 Important suggestions (should fix)
- 💡 Nice to have

**If issues found**:
Report critical issues immediately for fixing.

**If no issues**:
Approve and mark review complete.
```

**If issues found**:
- PM coordinates fixes
- Original agent fixes their code
- Re-review if needed

### Step 12: Continue Until Acceptance Criteria Met

**PM verifies**:
- All tasks complete
- All tests passing
- All acceptance criteria satisfied
- Code reviewed and approved
- No critical issues remaining

**If not complete**:
- Identify gaps
- Spawn additional agents to address gaps
- Continue until done

## Phase 4: Create PR

### Step 13: Create Draft PR

**PM spawns PR agent**:

```markdown
Create a draft pull request for <TICKET-KEY>.

**Work Directory**: <work-dir>
**Branch**: Should be `jing.liu/<ticket-key-description>`

**Steps**:
1. Ensure all commits are made
2. Create branch if not exists: `git checkout -b jing.liu/<ticket-key>`
3. Push to remote: `git push -u origin <branch>`
4. Create draft PR using gh:
   ```bash
   gh pr create --draft \
     --title "[<TICKET-KEY>] <title>" \
     --body "<pr-description>"
   ```

**PR Title Format**:
`[<TICKET-KEY>] <concise description>`

**PR Description**:
```markdown
## Summary
<Brief overview of changes>

## Changes
- <change 1>
- <change 2>
...

## Implementation Details
<Architecture decisions from plan.md>
<Key technical details>

## Testing
- Unit tests added: <files>
- Integration tests: <scenarios>
- Manual testing: <steps>

## Acceptance Criteria
- ✓ <criterion 1>
- ✓ <criterion 2>
...

## References
- Jira: <ticket-url>
- Design Doc: <confluence-url> (if applicable)
- Related PRs: <pr-links> (if applicable)
```

**IMPORTANT**:
- PR should be in DRAFT status
- Do NOT include "Test Results" section with output
- Do NOT include "Files Changed" section
- Do NOT include "Testing Guidelines" checkboxes
- Keep focused on: Summary, Changes, Implementation, Testing, Acceptance Criteria, References

**After PR created**:
Report PR URL back to PM.
```

### Step 14: Report Completion

**PM presents final summary**:

```markdown
## ✅ Jira Ticket <TICKET-KEY> Implementation Complete

### Summary
<Brief description of what was implemented>

### Implementation Stats
- **Tasks Completed**: <N>
- **Agents Used**: <M>
- **Files Modified**: <X>
- **Files Created**: <Y>
- **Tests Added**: <Z>
- **Commits**: <total>

### Acceptance Criteria
- ✓ <criterion 1>
- ✓ <criterion 2>
...

### Draft PR Created
**PR**: <pr-url>
**Branch**: `jing.liu/<branch-name>`
**Status**: Draft (ready for your review)

### Work Artifacts
All plans, notes, and reviews saved in: <work-dir>
- `context.md` - Ticket context and requirements
- `plan.md` - Implementation plan
- `notes.md` - Research and decisions
- `review-notes.md` - Code review feedback

### Next Steps
1. Review the draft PR
2. Test the implementation locally
3. Mark PR as ready for review when satisfied
4. Address any feedback from team review
```

## Key Principles

### Multi-Agent Orchestration

**Manager Agent**:
- Coordinates all other agents
- Makes strategic decisions
- Ensures work stays on track
- Handles blockers and conflicts

**Senior SWE Agents**:
- Each owns specific files (no conflicts)
- Implements following architecture from plan
- Writes tests alongside code
- Reviews own code before completion
- Expert knowledge of codebase patterns

**Peer Review**:
- Agents review each other's code
- Catch bugs, bad practices, issues
- Ensure quality and consistency

### Parallel Execution

**Maximize parallelism**:
- Independent tasks run simultaneously
- Sequential tasks wait for dependencies
- Reduces total time to completion

**Avoid conflicts**:
- Each agent owns specific files
- No two agents modify same file
- Clear boundaries in plan

### Continuous Progress

**Don't stop until done**:
- Automatically continue through all phases
- Handle errors and retry
- Only stop when acceptance criteria met
- No manual intervention required (except plan approval)

### Quality Focus

**Code quality maintained**:
- Follow existing patterns
- Comprehensive testing
- Peer code review
- Error handling
- Metrics and logging
- Backward compatibility

## Important Notes

- **Work directory**: `~/.claude/projects/-Users-jing-liu/work/<TICKET-KEY>/`
- **Branch naming**: `jing.liu/<ticket-key-description>`
- **Commit format**: `<TICKET-KEY>: <description>` (no Co-Authored-By)
- **PR status**: Draft (user reviews before marking ready)
- **MCP server**: atlassian-mcp-server (work Jira)
- **Repository**: ~/go/src/github.com/DataDog/dd-source

## Error Handling

**If plan approval times out**:
- Present plan again
- Ask specific questions
- Offer to proceed with sensible defaults

**If agent fails**:
- PM spawns replacement agent
- Continues from where failed agent left off

**If tests fail**:
- Identify failing tests
- Spawn agent to fix
- Re-run tests
- Continue until passing

**If acceptance criteria not met**:
- Identify gaps
- Create additional tasks
- Spawn agents to address
- Verify completion

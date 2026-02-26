---
name: write-ticket
description: Analyze and enhance Jira ticket with accurate context needed for implementation
argument-hint: "[jira-ticket-number or jira-url]"
context: fork
agent: general-purpose
allowed-tools: Bash, Read, Grep, Glob, WebFetch, Edit, Write
---

# Write Jira Ticket

Enhance existing Jira ticket with accurate, concise context needed for the `jira-ticket` skill to successfully implement.

## Purpose

Many Jira tickets lack sufficient context for automated implementation:
- Missing acceptance criteria
- Unclear requirements
- No reference to similar work
- Missing technical constraints
- Vague descriptions

This skill analyzes the ticket, identifies gaps, and adds accurate information to enable successful implementation.

## Input

You'll receive a Jira ticket identifier:
- **Ticket number**: `GRACE-1234` or `1234`
- **Jira URL**: `https://datadoghq.atlassian.net/browse/GRACE-1234`

## Workflow

### Phase 1: Analyze Current Ticket

**Step 1: Load Ticket**

Fetch ticket using MCP:
```bash
# Use atlassian-mcp-server (work Jira)
# Cloud ID: 66c05bee-f5ff-4718-b6fc-81351e5ef659
# Instance: datadoghq.atlassian.net
```

Call: `mcp__atlassian-mcp-server__getJiraIssue` with ticket key

**Step 2: Assess Completeness**

Analyze what's present and what's missing:

**Required Information Checklist**:
- [ ] Clear, specific title
- [ ] Problem statement (what needs to be solved)
- [ ] User story or use case (why this matters)
- [ ] Acceptance criteria (how to verify completion)
- [ ] Technical approach or constraints
- [ ] Reference to similar implementations (PRs, tickets)
- [ ] API contracts or interfaces (if applicable)
- [ ] Testing requirements
- [ ] Success metrics (if applicable)

**Common Gaps**:
- Vague descriptions ("improve X", "add Y")
- Missing acceptance criteria
- No technical context
- No reference implementations
- Unclear scope

**Present summary to user**:
```
Ticket: <TICKET-KEY> - <Title>

Current Status:
✓ Has description
✓ Has linked issues
✗ Missing acceptance criteria
✗ Missing reference implementations
✗ Vague technical approach

Completeness: 40% - Needs enhancement

Would you like me to enhance this ticket?
```

### Phase 2: Research Context

**Step 3: Find Similar Work**

Search for relevant context:

**In Codebase** (`~/go/src/github.com/DataDog/dd-source`):
```bash
# Search for related features
grep -r "<feature-keyword>" domains/aaa/apps/zoltron

# Find similar implementations
grep -r "<pattern-keyword>" --include="*.go"
```

**In Jira**:
- Search for related tickets using MCP
- Find tickets with similar features
- Extract patterns from completed work

**In GitHub**:
```bash
# Find related PRs
gh pr list --repo DataDog/dd-source --search "<keyword>" --state closed --limit 10
```

**In Confluence**:
- Search for design docs, RFCs, technical specs
- Find architecture documentation
- Extract relevant patterns and decisions

**Step 4: Identify Patterns**

From research, extract:
- **Reference implementations**: PR links, file paths
- **Patterns to follow**: Code patterns, architecture decisions
- **Technical constraints**: Performance, backward compatibility, security
- **Testing patterns**: How similar features are tested
- **Success metrics**: How impact is measured

### Phase 3: Enhance Ticket

**Step 5: Draft Enhancement**

Create comprehensive but concise additions:

**Enhanced Description Template**:

```markdown
## Problem Statement
<Clear description of what needs to be solved>
<Why current state is insufficient>

## Use Case
<Who needs this>
<How they will use it>
<What value it provides>

## Acceptance Criteria
1. <Specific, testable criterion>
2. <Specific, testable criterion>
3. <Specific, testable criterion>
...

## Technical Context

### Similar Implementations
- PR #12345: <Title> - <url>
  - Pattern: <what pattern this uses>
- <TICKET-123>: <Related work>

### Architecture
<Concise description of approach>
<Key components involved>

### Files Likely Affected
- `path/to/file.go` - <what changes>
- `path/to/test.go` - <what tests>

### Technical Constraints
- <Backward compatibility requirements>
- <Performance considerations>
- <Security requirements>

## Testing Requirements
- Unit tests: <what to test>
- Integration tests: <what scenarios>
- Manual testing: <verification steps>

## Success Metrics
- <How to measure success>

## References
- Design Doc: <confluence-url>
- Related RFC: <url>
- Codebase reference: `<file:lines>`
```

**Guidelines for Content**:

**Be Specific**:
```
❌ Bad: "Add validation for user input"
✅ Good: "Validate product field is one of [rum, logs, apm] and org_uuid is valid UUID format"
```

**Be Concise**:
```
❌ Bad: "We need to implement a new feature that allows users to configure
         dataset access restrictions at a granular level, which will enable
         them to control who can access what data..."
✅ Good: "Add API endpoint to configure per-dataset product restrictions"
```

**Be Accurate**:
```
❌ Bad: "Use the standard pattern" (what standard?)
✅ Good: "Follow repository pattern in internal/datastore/restriction_policy.go"
```

**Be Actionable**:
```
❌ Bad: "Improve performance"
✅ Good: "Reduce P95 latency from 500ms to <100ms using caching"
```

**Step 6: Review with User**

Present draft to user:
```markdown
I've enhanced the ticket with:

## Added Sections:
- ✓ Acceptance criteria (5 specific criteria)
- ✓ Similar implementations (2 PRs, 1 related ticket)
- ✓ Technical context (architecture approach, files affected)
- ✓ Testing requirements
- ✓ References to design docs

## Changes Summary:
**Before**: Vague description, no acceptance criteria
**After**: Clear requirements, references to patterns, testable criteria

Preview: <work-dir>/enhanced-description.md

Would you like me to update the Jira ticket with this enhancement?
```

**Step 7: Update Ticket**

Once approved, update the Jira ticket:

Use MCP: `mcp__atlassian-mcp-server__editJiraIssue`

```json
{
  "issueKey": "GRACE-1234",
  "fields": {
    "description": "<enhanced-description-in-jira-markdown>"
  }
}
```

**IMPORTANT: Format for Jira**:
- Use Jira markdown format (not GitHub markdown)
- Headers: `h2. Header`, `h3. Subheader`
- Bold: `*text*`
- Code: `{{code}}` or `{code:language}...{code}`
- Links: `[text|url]`
- Bullets: `* item` or `# numbered`

**Step 8: Verify Update**

Re-fetch ticket to confirm:
```markdown
✅ Ticket successfully updated

Enhanced sections:
- Acceptance criteria (5 items)
- Technical context with references
- Testing requirements
- Success metrics

The ticket is now ready for /jira-ticket to implement.

Next steps:
1. Review the updated ticket: <jira-url>
2. Run `/jira-ticket <TICKET-KEY>` when ready to implement
```

## Quality Standards

### Information Accuracy

**Verify before adding**:
- [ ] File paths are correct (use Glob to verify)
- [ ] PR links are valid (use gh to verify)
- [ ] Patterns exist in codebase (use Grep to confirm)
- [ ] Confluence docs are accessible (use MCP to verify)
- [ ] Technical constraints are real (not assumed)

**Never guess or assume**:
```
❌ Bad: "Probably uses the standard handler pattern"
✅ Good: "Uses handler decorator pattern from internal/http/handlers/decorator.go:15-30"
```

### Conciseness

**One sentence when possible**:
```
❌ Bad: "We need to add a new field to the API that will allow users to
         specify the product type, which should be one of the following
         values: rum, logs, apm, or synthetics"
✅ Good: "Add `product` field to API (enum: rum, logs, apm, synthetics)"
```

**Remove fluff**:
```
❌ Bad: "It would be beneficial to implement..."
✅ Good: "Implement..."

❌ Bad: "We should probably consider..."
✅ Good: "Add..."
```

**Use lists for multiple items**:
```
✅ Good:
Files affected:
- handler.go - Add validation
- repository.go - Add query
- handler_test.go - Add tests
```

### Completeness vs Verbosity

**Include what's needed, nothing more**:

**Essential**:
- Acceptance criteria
- Reference implementations
- Technical constraints
- Testing requirements

**Optional** (only if adds value):
- Success metrics (if measurable)
- Design rationale (if non-obvious)
- Migration plan (if breaking change)

**Never include**:
- Speculation about implementation details
- Obvious information ("write tests")
- Redundant explanations
- Personal opinions

## Example Enhancement

### Before
```
Title: Add dataset config

Description:
Need to add dataset config support for product restrictions.
```

### After
```
Title: Add dataset config API for product-level restrictions

Description:

## Problem Statement
Need API to configure product-level restrictions for datasets (currently only org/user level).

## Acceptance Criteria
1. API endpoint POST /api/unstable/dataset_config accepts org_uuid and product fields
2. Stores config in datasets_config table
3. Returns 400 if product not in [rum, logs, apm]
4. Integrates with existing restriction policy flow
5. Unit and integration tests cover CRUD operations

## Technical Context

### Similar Implementations
- PR #365935: Restriction policy CRUD - https://github.com/DataDog/dd-source/pull/365935
  - Pattern: Repository + handler + validator pattern
- GRACE-2946: Datasets API - Follow same structure

### Architecture
Follows existing pattern:
1. Proto: domains/aaa/apps/zoltron/internal/frames/proto/dataset_config.proto
2. Repository: internal/datastore/dataset_config_repository.go
3. Handler: internal/http/handlers/dataset_config_handler.go
4. Validator: internal/validation/dataset_config_validator.go

### Files to Create/Modify
- proto/dataset_config.proto - Define message structure
- datastore/dataset_config_repository.go - CRUD operations
- http/handlers/dataset_config_handler.go - API endpoint
- validation/dataset_config_validator.go - Input validation
- *_test.go - Unit and integration tests

### Technical Constraints
- Must maintain backward compatibility with existing restriction policies
- Product enum must match product types in restriction_policy table
- Requires database migration for datasets_config table

## Testing Requirements
- Unit tests: Repository CRUD, handler validation, validator edge cases
- Integration tests: End-to-end API calls with database
- Manual: curl commands in ticket comments

## References
- Design Doc: [Context Platform RFC](https://datadoghq.atlassian.net/wiki/spaces/FRAMES/pages/5147922742)
- Reference: internal/datastore/restriction_policy_repository.go
```

## Error Handling

**If ticket is already complete**:
```
This ticket already has:
✓ Clear acceptance criteria
✓ Technical context
✓ Reference implementations
✓ Testing requirements

Completeness: 95% - Ready for implementation

No enhancement needed. You can run /jira-ticket directly.
```

**If can't find context**:
```
⚠️ Limited context available for this feature.

Found:
- Similar pattern in <file>

Could not find:
- Related PRs (new feature area)
- Design docs (check with team?)

I can still enhance the ticket with:
- Clear acceptance criteria
- File structure based on existing patterns
- Testing requirements

Proceed with available context?
```

**If information is ambiguous**:
```
❓ Need clarification on scope:

Option 1: Add config at product level only
Option 2: Add config at product + tag level
Option 3: Full hierarchy (org → team → user → product)

Which approach should the ticket specify?
```

## Success Criteria

A well-enhanced ticket should:
- [ ] Have 3-7 specific, testable acceptance criteria
- [ ] Reference at least 1 similar implementation
- [ ] Specify files/components likely affected
- [ ] Include testing requirements
- [ ] Be implementable by `jira-ticket` skill without additional input
- [ ] Contain no speculation or assumptions
- [ ] Be concise (< 1000 words)
- [ ] Have verified references (all links/paths are valid)

## Important Notes

- **Work directory**: Create work dir at `~/.claude/projects/-Users-jing-liu/work/<TICKET-KEY>/` for drafts
- **MCP server**: Use atlassian-mcp-server for work Jira
- **Format**: Use Jira markdown format when updating ticket
- **Accuracy over completeness**: Better to have less information that's accurate than more that's speculative
- **Verify everything**: Check file paths, PR links, confluence docs before adding
- **User approval**: Always show draft before updating ticket

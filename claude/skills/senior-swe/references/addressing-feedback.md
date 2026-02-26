# Addressing PR Feedback - Systematic Workflow

Inspired by [address-pr-feedback skill](https://github.com/DataDog/experimental/tree/main/users/vickie.boettcher/skills/address-pr-feedback)

## Overview

A structured workflow for systematically processing and addressing pull request review feedback.

## Workflow Phases

### Phase 1: Fetch and Organize Feedback

**Extract PR Information**:
- Get PR number or URL
- Note specific reviewer if mentioned
- Examples: "Address feedback from PR 332190", "Read comments from reviewer on PR 12345"

**Fetch PR Comments**:
```bash
# Get all comments
gh pr view <PR_NUMBER> --json comments

# Filter by reviewer
gh pr view <PR_NUMBER> --json comments | jq '[.[] | select(.author.login == "username")]'
```

**Create Review Notes Document**:

```markdown
# PR Review Notes - <Reviewer>'s Comments

PR: #<NUMBER> - <Title>
Branch: <branch_name>
Date: <date>

---

## Comment 1: <Brief Description>
**File**: `<file_path>:<line>`
**Status**: ❌ NEEDS FIX / ✅ RESOLVED / ❓ NEEDS INVESTIGATION
**Priority**: P0 (Critical) / P1 (High) / P2 (Medium)

### Comment
> <Original reviewer comment>

### Analysis
- What the issue is about
- Why it matters
- Context from codebase or design docs

### Action Plan
<Specific steps to fix, for code changes>
OR
### Response
<Explanation for why no code change is needed>

---

## Summary of Actions Required

### Priority P0 (Critical - Must Fix)
1. Comment X: Description

### Priority P1 (Should Fix)
1. Comment Y: Description

### Priority P2 (Nice to Have)
1. Comment Z: Description
```

**Analyze Each Comment**:
- **Status**: Fix, investigation, or explanation?
- **Priority**: P0 (critical) / P1 (should fix) / P2 (nice to have)
- **Analysis**: Underlying issue and context
- **Action plan**: Specific steps to address

### Phase 2: Get User Direction

**Present Summary**:
```
Summary:
- 10 comments total from <reviewer>
- 1 critical (P0): <description>
- 4 high priority (P1): <descriptions>
- 5 medium priority (P2): <descriptions>

Proposed actions:
- Code fixes: 5 items
- Need investigation: 2 items
- Explanation/documentation: 3 items
```

**Get Specific Instructions**:
- Which comments to fix (and specific approaches)
- Which need explanation (and key points)
- Which need investigation first
- Any already handled

### Phase 3: Execute Fixes

**Work Through Comments in Priority Order**:

For each comment:

**If code change needed**:
1. Make the fix
2. Run `goimports -w` on changed files
3. Run tests
4. Create a separate commit:
   ```bash
   git add <specific-files>
   git commit -m "fix(area): description

   Addresses review comment: <brief description>

   Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
   ```

**If explanation needed**:
1. Update review notes with response
2. No commit needed

**If investigation needed**:
1. Explore codebase
2. Document findings
3. Present options to user
4. Get direction, then proceed

### Phase 4: Post Responses to GitHub

**Reply directly to each review comment**:

```bash
# Get comment ID from gh pr view output
# Reply to specific comment thread
gh api repos/<owner>/<repo>/pulls/comments/<comment_id>/replies \
  -X POST \
  -f body="✅ Fixed in <commit_hash> - <brief description>"
```

**Response formats**:
- ✅ Fixes: "✅ Fixed in abc123 - <description>"
- 📝 Explanations: "📝 <explanation with links>"
- ❓ Questions: "❓ <clarifying question>"

**IMPORTANT**: Always reply to the specific review comment, not as an unattached PR comment.

### Phase 5: Finalize

**Verify Results**:
- Check git log for created commits
- Verify all review comment threads have replies
- Ensure tests pass

**Present Summary**:
```markdown
## 📋 All Review Comments Addressed (X/X)

### ✅ Code Changes - Y Commits Created
1. **Comment N** - Description
   - Commit: <hash> - <message>

### ✅ Documentation - Z Explanations Added
1. **Comment N** - Description
   - Response: <brief summary>

### ❓ Items Needing Follow-Up
1. **Comment N** - Description
   - Options: <alternatives>

## 📁 Files Modified
- <list>

## 🎯 Next Steps
- All commits pushed
- All threads replied to
- Ready for re-review
```

## Prioritization

### P0 (Critical) - Address Immediately
- Bugs causing incorrect behavior
- Security vulnerabilities
- Breaking API changes
- Crashes or 500 errors

### P1 (High Priority) - Should Fix
- Major refactoring with clear benefits
- Naming/clarity affecting maintainability
- Type safety improvements
- Missing error handling

### P2 (Medium Priority) - Nice to Have
- Nits and style preferences
- Minor optimizations
- Documentation improvements
- "Next time" suggestions

## Commit Guidelines

**For code changes**:
- ✅ One commit per logical fix
- ✅ Descriptive messages following conventions
- ✅ Reference comment in commit message
- ✅ Include Co-Authored-By attribution
- ✅ Run linting/formatting before commit
- ✅ Run tests after changes

**Example commit message**:
```
fix(auth): handle null user tokens gracefully

Addresses review comment about missing null check.
Added validation before token processing.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

## Response Guidelines

**Good explanations**:
- Focus on technical reasoning
- Reference standards, patterns, constraints
- Provide examples or doc links
- Acknowledge trade-offs

**Avoid**:
- Defensive language
- Arguments without technical backing
- Ignoring valid concerns

**Example good response**:
```
📝 We're using pattern X here because it matches the existing
authorization pattern used in auth_service.go (lines 45-60).
This ensures consistency across the codebase and makes it
easier for other engineers to understand the flow.

Alternative approaches were considered (pattern Y, pattern Z)
but would require refactoring the entire auth layer. We can
revisit this in a future refactor if needed.

Related doc: [Authorization Patterns](link)
```

## Error Handling

**If tests fail after fixes**:
1. Report failure immediately
2. Don't mark as complete
3. Ask user how to proceed
4. Don't commit broken code

**If unclear how to fix**:
1. Investigate and present options
2. Get user direction
3. Don't guess

**If reviewer comment is unclear**:
1. Ask for clarification in the comment thread
2. Wait for response before proceeding

## Success Criteria

A successful PR feedback session should have:
- ✅ All comments organized with clear priorities
- ✅ Action plans for each comment
- ✅ Commits created for all code fixes
- ✅ Explanations documented for no-change items
- ✅ All review comment threads have replies
- ✅ Tests passing
- ✅ Clear next steps for user

## Example Workflow

**User**: "Address feedback from reviewer on PR 12345"

**You**:
1. Fetch 8 comments from PR
2. Create review notes with analysis
3. Identify: 1 P0, 3 P1, 4 P2
4. Present summary
5. User: "Fix P0 and P1, explain P2"
6. Execute fixes:
   - Fix P0: Create commit
   - Fix 3 P1 items: Create 3 separate commits
   - Document explanations for P2 items
7. Reply to all comment threads on GitHub
8. Present summary with 4 commits, 4 responses
9. Confirm all tests pass
10. PR ready for re-review

## Tips

- **Stay organized**: Use review notes to track progress
- **Communicate**: Reply to every comment thread
- **Be thorough**: Don't skip analysis or testing
- **Be collaborative**: Explain reasoning, don't argue
- **Be efficient**: Group related changes, but keep commits focused
- **Be responsive**: Address feedback promptly

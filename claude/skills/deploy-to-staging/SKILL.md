---
name: deploy-to-staging
description: Deploy changes to zoltron staging branch and handle integration conflicts
argument-hint: "[pr-number or branch-name]"
context: fork
agent: general-purpose
allowed-tools: Bash, Read, Grep, Glob, Task
---

# Deploy to Staging

Automates deployment to zoltron staging branch, including handling integration conflicts and ensuring successful merge.

## Purpose

Zoltron uses **ephemeral integration branches** (not traditional staging branches). This means:
- Manual pushes to `zoltron/staging` are automatically overwritten
- Changes must go through `/integrate` workflow
- Conflicts must be resolved through fix PRs, never by resetting the branch

This skill automates the entire flow from integration command to successful staging deployment.

## Input

You'll receive one of:
- **PR number**: `365040` or `#365040`
- **Branch name**: `jing.liu/grace-2982-datasets-config`
- **No input**: Uses current branch

## Key Concepts

### Ephemeral Integration Branches

**What they are:**
- Automatically rebuilt from integrated PRs (not manually maintained)
- Reset and rebuilt every ~1 minute when there are changes
- No weekly staging resets needed (unlike old integration branches)

**Critical rules:**
- ❌ **NEVER manually push to `zoltron/staging`** - changes will be overwritten
- ❌ **NEVER reset the integration branch** - deletes all commits irreversibly
- ✅ Always use `/integrate -s zoltron` command
- ✅ Fix conflicts through automated fix PRs

**Reference**: [Integration Branches - Ephemeral branches](https://datadoghq.atlassian.net/wiki/spaces/DEVX/pages/3127904638/Integration+Branches#6.-Ephemeral-branches)

### How Long Do Changes Persist?

✅ **Indefinitely** - until:
- Your PR is closed or merged to main
- You manually remove it via `/integrate -s zoltron -r` (remove)
- ❌ **NOT** when someone else integrates (unlike old mode)

## Workflow

### Phase 1: Pre-Integration Checks

**Step 1: Identify the PR**

If no input provided, detect current branch and find its PR:
```bash
# Get current branch
git rev-parse --abbrev-ref HEAD

# Find PR for branch
gh pr list --head <branch-name> --json number,url
```

**Step 2: Verify PR is ready for staging**

Check that:
- [ ] PR has no conflicts with `main` (must be resolved first)
- [ ] CI checks are passing or in progress
- [ ] PR is not in draft state (unless intentional)

```bash
gh pr view <pr-number> --json mergeable,statusCheckRollup,isDraft
```

**If conflicts with main exist:**
```
❌ This PR has conflicts with main. Staging integration requires main conflicts to be resolved first.

To fix:
1. Rebase your branch: git rebase origin/main
2. Resolve conflicts
3. Force push: git push --force-with-lease
4. Then retry: /integrate -s zoltron
```

**Step 3: Comment integration command**

```bash
gh pr comment <pr-number> --body "/integrate -s zoltron"
```

Inform user:
```
✅ Integration command posted to PR #<number>

Monitoring devflow bot for response...
```

### Phase 2: Monitor Integration Status

**Step 4: Watch for devflow bot response**

Poll PR comments for response from `gh-worker-devflow-routing-*` bots:

```bash
# Poll every 30 seconds for up to 5 minutes
gh pr view <pr-number> --json comments --jq '.comments[] | select(.author.login | startswith("gh-worker-devflow-routing")) | {author: .author.login, body: .body, createdAt: .createdAt}' | tail -20
```

**Expected responses:**

**Success response:**
```
✅ Branch Integration: commit 9a5dd413ea has been integrated into zoltron/staging
```

**Conflict response:**
```
🚨 Branch Integration: this integration has conflicts which couldn't be solved automatically

We couldn't automatically merge the commit 9a5dd413ea into zoltron/staging!

To solve the conflicts directly in Github, click here to create a fix pull request.
```

**Step 5: Handle integration result**

**If success:**
```
✅ Successfully integrated into zoltron/staging!

Your changes are now deployed to staging and will persist until:
- PR is merged to main
- PR is closed
- You manually remove with: /integrate -s zoltron -r

Staging branch: https://github.com/DataDog/dd-source/tree/zoltron/staging
```

**If conflicts detected:**
Proceed to Phase 3 (Conflict Resolution)

### Phase 3: Conflict Resolution (Multi-Agent)

**CRITICAL**: When conflicts occur, you must:
1. ✅ Create a fix PR (do NOT reset the integration branch)
2. ✅ Preserve all existing functionality from staging
3. ✅ Apply all changes from your PR
4. ✅ Combine conflicting changes intelligently
5. ❌ NEVER use `/integrate -s zoltron --reset` or reset commands

**Step 6: Extract fix PR URL from devflow comment**

Parse the devflow bot comment to find the fix PR creation link:

```bash
# Extract "click here to create a fix pull request" URL
gh pr view <pr-number> --json comments --jq '.comments[] | select(.body | contains("create a fix pull request")) | .body'
```

The URL format is typically:
```
https://github.com/DataDog/dd-source/compare/zoltron/staging...fix-merge-<commit-sha>-into-zoltron/staging?quick_pull=1
```

**Step 7: Launch conflict resolution agents**

**CRITICAL - Multi-Agent Workflow**:

Use multiple agents working continuously until conflicts are fully resolved and merged:

1. **Agent 1: Conflict Analysis Agent**
   - Fetch both branches involved in conflict
   - Identify conflicting files
   - Analyze the nature of conflicts (code, imports, merge markers)
   - Assess complexity and risk

2. **Agent 2: Resolution Strategy Agent**
   - Read conflicting files from both sides
   - Determine resolution strategy for each conflict
   - Identify which changes are from your PR vs existing staging
   - Plan how to combine changes intelligently

3. **Agent 3: Implementation Agent**
   - Check out fix merge branch
   - Resolve conflicts preserving both sets of changes
   - Run formatting (goimports for Go files)
   - Verify compilation
   - Commit resolved conflicts

4. **Agent 4: Verification Agent**
   - Run tests on resolved code
   - Check for missed conflicts
   - Verify no functionality was lost
   - Ensure your PR changes are present

5. **Agent 5: PR Management Agent**
   - Push resolved changes
   - Monitor CI status
   - Verify integration success
   - Confirm merge into staging

**Conflict Resolution Guidelines:**

**Preserve existing functionality:**
```markdown
When resolving conflicts:
1. Read BOTH sides of the conflict carefully
2. If the existing staging code has functionality unrelated to your changes → KEEP IT
3. If your PR introduces new functionality → ADD IT
4. If both sides modified the same function → COMBINE intelligently
5. When in doubt → ASK the user before making destructive changes
```

**Example conflict resolution:**

```go
// CONFLICT in domains/aaa/apps/zoltron/internal/provider/datasets_test.go

<<<<<<< HEAD (existing staging)
			mockExperiment := experimentmock.NewMockClient(ctrl)
			mockExperiment.EXPECT().
				IsEnabledForContextType(gomock.Any(), "validation-killswitch", gomock.Any()).
				Return(false).
				AnyTimes()

			service := NewProviderService(mockExperiment, mockRepo, nil, nil, nil, nil, nil)
=======
			service := NewProviderService(nil, mockRepo, nil, nil, nil, nil, nil, nil)
>>>>>>> origin/your-branch

// CORRECT RESOLUTION:
// Your PR added a parameter (8 params instead of 7)
// Staging has experiment mock setup
// Resolution: Keep experiment mock + use 8 params

			mockExperiment := experimentmock.NewMockClient(ctrl)
			mockExperiment.EXPECT().
				IsEnabledForContextType(gomock.Any(), "validation-killswitch", gomock.Any()).
				Return(false).
				AnyTimes()

			service := NewProviderService(mockExperiment, mockRepo, nil, nil, nil, nil, nil, nil)
```

**Step 8: Execute continuous resolution workflow**

```bash
# Launch resolution agents in parallel
/task "Agent 1: Analyze conflicts in fix PR"
/task "Agent 2: Plan resolution strategy"
/task "Agent 3: Implement resolution"
/task "Agent 4: Verify resolution"
/task "Agent 5: Push and monitor merge"
```

**Agents should continue working until:**
- [ ] All conflicts resolved
- [ ] Tests passing
- [ ] Fix PR merged
- [ ] Original PR successfully integrated into `zoltron/staging`

**Step 9: Verify final integration**

Once fix PR is merged, verify the original PR is now in staging:

```bash
# Check if commit is in staging
git fetch origin zoltron/staging
git log origin/zoltron/staging --oneline | grep -i <commit-message-keyword>

# Verify PR is listed in staging integrations
gh pr view <pr-number> --json comments | grep "has been integrated into zoltron/staging"
```

**Success message:**
```
✅ Conflicts resolved and successfully integrated into zoltron/staging!

Fix PR: https://github.com/DataDog/dd-source/pull/<fix-pr-number> (merged)
Original PR: https://github.com/DataDog/dd-source/pull/<original-pr-number>

Your changes are now in staging and will persist until the PR is merged or closed.
```

## Error Handling

### "This PR has conflicts with main"

**Symptom:** Devflow bot reports conflicts with main, or integration is skipped
**Fix:**
```bash
# Rebase with latest main
cd ~/go/src/github.com/DataDog/dd-source
git fetch origin
git checkout <your-branch>
git rebase origin/main

# Resolve conflicts if any
# Then force push
git push --force-with-lease

# Retry integration
gh pr comment <pr-number> --body "/integrate -s zoltron"
```

### "Integration is taking too long"

**Symptom:** No devflow bot response after 5+ minutes
**Possible causes:**
- Devflow is experiencing issues
- PR has conflicts with main (silently skipped)
- Bot is rate limited

**Actions:**
1. Check [Devflow status](https://devflow.ddbuild.io)
2. Verify no main conflicts: `gh pr view <pr-number> --json mergeable`
3. Check devflow bot comments for errors
4. If stuck, ask in #devflow-support Slack channel

### "Accidentally reset the staging branch"

**If someone ran `/integrate -s zoltron --reset` or reset command:**

⚠️ **This is bad** - all commits on `zoltron/staging` are deleted and cannot be undone.

**Recovery:**
1. All teams must re-integrate their PRs using `/integrate -s zoltron`
2. Coordinate in #aaa-granular-access Slack channel
3. This is why we NEVER reset the branch

### "Fix PR conflicts are too complex"

**If you're uncertain about conflict resolution:**

**DO:**
- ✅ Ask the user which version to keep
- ✅ Read both sides of the conflict carefully
- ✅ Test the resolution locally before pushing
- ✅ Preserve all unrelated functionality from staging

**DON'T:**
- ❌ Make destructive changes without asking
- ❌ Blindly accept one side of the conflict
- ❌ Remove code you don't understand
- ❌ Skip testing the resolution

## Testing

Before considering the deployment complete:

**If your changes include code:**
```bash
# Checkout staging branch
git fetch origin zoltron/staging
git checkout zoltron/staging

# Run relevant tests
cd domains/aaa/apps/zoltron
bzl test //domains/aaa/apps/zoltron/internal/provider:go_default_test
```

**Verify your changes are present:**
```bash
# Check for specific files or functions from your PR
git log origin/zoltron/staging --oneline -20
git show origin/zoltron/staging:path/to/your/changed/file.go
```

## Success Criteria

A successful staging deployment means:
- [ ] `/integrate -s zoltron` command posted to PR
- [ ] Devflow bot confirmed integration (no conflicts) OR conflicts resolved via fix PR
- [ ] Your commit is visible in `zoltron/staging` branch
- [ ] Tests pass on staging (if applicable)
- [ ] No functionality lost from existing staging

## Important Notes

- **Work directory**: Not needed - all operations are direct git/gh commands
- **Ephemeral branches**: Changes persist until PR is merged/closed, not until next integration
- **Conflict resolution**: Always preserve existing functionality, add your changes, never reset
- **Multi-agent**: Use parallel agents for complex conflict resolution
- **Ask questions**: When conflict resolution is ambiguous, ASK the user
- **Never reset**: Resetting `zoltron/staging` deletes all commits irreversibly

## Common Commands Quick Reference

```bash
# Integrate to staging
gh pr comment <pr-number> --body "/integrate -s zoltron"

# Remove from staging
gh pr comment <pr-number> --body "/integrate -s zoltron -r"

# Check what's in staging
gh pr list --json number,title,headRefName,url | jq '.[] | select(.headRefName | contains("staging"))'

# Monitor devflow bot responses
gh pr view <pr-number> --json comments --jq '.comments[] | select(.author.login | startswith("gh-worker-devflow")) | {author: .author.login, body: .body, createdAt: .createdAt}'

# Verify commit in staging
git log origin/zoltron/staging --oneline --grep="<keyword>"
```

## Related Documentation

- [Ephemeral Integration Branches](https://datadoghq.atlassian.net/wiki/spaces/DEVX/pages/3127904638/Integration+Branches#6.-Ephemeral-branches)
- [Devflow Documentation](https://datadoghq.atlassian.net/wiki/spaces/DEVX/pages/3127904638)
- #devflow-support Slack channel for issues

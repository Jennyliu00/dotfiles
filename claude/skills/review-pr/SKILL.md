---
name: review-pr
description: Comprehensive multi-agent PR review with senior engineer perspective
argument-hint: "[pr-number or pr-url or owner/repo#number]"
context: fork
agent: general-purpose
allowed-tools: Bash, Read, Grep, Glob, WebFetch, Task, Skill
---

# Review Pull Request

Multi-agent comprehensive code review that analyzes PRs from multiple perspectives simultaneously, looking for bugs, security issues, performance problems, and code quality concerns.

## Purpose

Provide thorough, actionable PR reviews that catch issues early and help maintain code quality. Uses parallel agent exploration to understand the PR deeply, then synthesizes findings into a structured review.

## Input

You'll receive a PR identifier in one of these formats:
- **PR number**: `12345` (uses current repo)
- **PR URL**: `https://github.com/DataDog/dd-source/pull/12345`
- **Owner/repo format**: `DataDog/dd-source#12345`

## Output Format

```markdown
# PR Review: [PR Title]

## 🎯 Summary
[2-3 sentence high-level overview of what this PR does and its impact]

## 🔴 Critical Issues (Must Address)
[Issues that would cause bugs, security vulnerabilities, or break existing functionality]

## 🟡 Important Feedback (Should Address)
[Significant concerns about code quality, maintainability, or performance]

## 💡 Suggestions (Consider)
[Improvements and alternative approaches worth considering]

## ✏️ Nits (Optional)
[Minor style, naming, or formatting issues]

## ✅ Positive Notes
[Things done well worth highlighting]
```

## Workflow

### Phase 1: Fetch PR Context

**Step 1: Parse PR Identifier**

Extract owner, repo, and PR number from input.

**Step 2: Fetch PR Information**

```bash
# Get comprehensive PR data
gh pr view <number> --json \
  title,body,author,state,isDraft,\
  additions,deletions,changedFiles,\
  commits,reviews,reviewDecision,\
  statusCheckRollup,files

# Get PR diff
gh pr diff <number>

# Get changed files list
gh pr diff <number> --name-only

# Check CI/CD status
gh pr checks <number>

# Get existing reviews and comments
gh pr view <number> --json reviews,comments
```

### Phase 2: Multi-Agent Analysis

**Launch parallel exploration agents to understand the PR from different perspectives:**

**Agent 1: Architecture & Design Reviewer**
- Analyze overall design and architecture decisions
- Check if changes align with existing patterns
- Verify API design and interface contracts
- Assess backwards compatibility
- Look for over-engineering or premature optimization

**Agent 2: Security & Correctness Reviewer**
- Scan for security vulnerabilities (OWASP Top 10)
- Check input validation and sanitization
- Verify error handling and edge cases
- Look for resource leaks or race conditions
- Check for hardcoded secrets or credentials
- Verify proper authentication/authorization

**Agent 3: Performance Reviewer**
- Identify potential performance bottlenecks
- Check for inefficient algorithms or data structures
- Look for excessive memory allocations
- Verify proper use of caching and connection pooling
- Check database query efficiency
- Assess impact on critical paths

**Agent 4: Testing & Maintainability Reviewer**
- Verify test coverage for new/changed code
- Check test quality (table-driven tests, edge cases)
- Assess code readability and documentation
- Look for code smells and anti-patterns
- Verify proper use of comments and documentation
- Check for dead code or unused imports

**Agent 5: Go-Specific Reviewer** (if Go code)
- Check Go idioms and best practices
- Verify error handling patterns (`%w`, proper wrapping)
- Check concurrency safety (goroutines, channels, mutexes)
- Verify proper use of context
- Check for goroutine leaks
- Verify proper resource cleanup (`defer`)
- Check package design and API conventions

**All agents should:**
- Reference the senior-swe skill's knowledge base
- Read changed files thoroughly
- Check for usage of modified symbols in the codebase
- Consider the specific context of the codebase (e.g., Zoltron patterns)

### Phase 3: Synthesize Findings

**Step 1: Collect Agent Findings**

Gather all findings from parallel agents.

**Step 2: Categorize Issues**

Group findings by severity:
- **🔴 Critical (Must Address)**: Bugs, security issues, breaking changes, correctness problems
- **🟡 Important (Should Address)**: Performance concerns, maintainability issues, significant code quality problems
- **💡 Suggestions (Consider)**: Alternative approaches, refactoring opportunities, minor improvements
- **✏️ Nits (Optional)**: Style issues, naming, minor formatting (only if not handled by linters)

**Step 3: Deduplicate and Prioritize**

Remove duplicate findings from multiple agents and prioritize by impact.

**Step 4: Add Specific File/Line References**

For each issue, include:
- File path and line number (e.g., `internal/handler.go:42`)
- Code snippet showing the problem
- Specific suggestion for fixing
- Explanation of why it's an issue

### Phase 4: Generate Review

**Step 1: Write High-Level Summary**

2-3 sentences covering:
- What the PR does
- Overall assessment of code quality
- Major changes or impact areas

**Step 2: Document Findings by Category**

For each issue, use this format:

```markdown
### File: `path/to/file.go:42`

**Issue**: [Brief description of the problem]

**Code**:
```go
// Problematic code snippet
```

**Problem**: [Detailed explanation of why this is an issue]

**Suggestion**: [Specific, actionable fix]
```

**Step 3: Highlight Positive Aspects**

Note things done well:
- Good test coverage
- Clear documentation
- Following existing patterns
- Smart solutions to complex problems

### Phase 5: Present Review

Show the complete review to the user in the structured format.

If the user approves, offer to:
1. Post review comments to GitHub (if credentials available)
2. Save review to file for manual posting
3. Create follow-up tasks for addressing issues

## Review Principles

### Be Specific and Actionable

```markdown
❌ Bad: "This could be better"
✅ Good: "This function could panic if input is nil. Add nil check: `if req == nil { return nil, fmt.Errorf(\"request is nil\") }`"
```

### Focus on Impact

Prioritize issues by their potential impact:
- **Critical**: Would cause bugs, security issues, or data loss
- **Important**: Significantly affects maintainability or performance
- **Suggestions**: Improvements that add value but aren't urgent
- **Nits**: Minor issues (avoid nitpicking unless asked)

### Teach, Don't Just Critique

```markdown
✅ Good: "This could cause a goroutine leak because the channel is never closed.
In Go, the goroutine that creates a channel should be responsible for closing it.
Consider adding `defer close(ch)` after creating the channel."
```

### Recognize Good Work

Always include positive feedback for:
- Well-written tests
- Clear documentation
- Following existing patterns
- Solving complex problems elegantly

### Consider Context

- **New code**: Higher standards, more thorough review
- **Bug fix**: Focus on correctness and minimal changes
- **Refactor**: Ensure behavior preservation, no feature creep
- **Infrastructure**: Verify safety and rollback plans

## Language-Specific Checklists

### Go Code Review Checklist

When reviewing Go code, verify:

**Idioms & Style**
- [ ] Code formatted with `gofmt` and `goimports`
- [ ] No unused imports or variables
- [ ] Clear, concise naming following Go conventions
- [ ] No stuttering in names

**Error Handling**
- [ ] No ignored errors (except when explicitly justified)
- [ ] Errors wrapped with context using `%w`
- [ ] Proper sentinel error usage with `errors.Is()`
- [ ] No panic for regular errors

**Concurrency**
- [ ] No goroutine leaks (every goroutine has exit path)
- [ ] Proper channel closure (owner closes)
- [ ] Context propagated through call stack
- [ ] No data races (suggest running with `-race`)
- [ ] Proper synchronization (mutex, WaitGroup, etc.)

**Performance**
- [ ] No excessive allocations in hot paths
- [ ] Slices pre-allocated when size known
- [ ] Strings not concatenated in loops (use `strings.Builder`)
- [ ] Proper pointer vs value usage

**Testing**
- [ ] Table-driven tests for complex functions
- [ ] Tests use `t.Run()` for subtests
- [ ] Tests can run in parallel where appropriate
- [ ] Good error messages in test failures
- [ ] Edge cases and error paths tested

**Database (PostgreSQL)**
- [ ] No unnecessary `SCROLL CURSOR` (use only for backward/absolute fetch)
- [ ] Proper transaction boundaries
- [ ] Timeout settings for long queries
- [ ] Proper error handling including `sql.ErrNoRows`
- [ ] `ORDER BY` for deterministic cursor results

**API Design**
- [ ] "Accept interfaces, return structs" pattern
- [ ] Minimal public API surface
- [ ] Clear separation of public and private
- [ ] Backwards compatibility maintained

### General Code Review Checklist

**Design & Architecture**
- [ ] Changes align with existing patterns
- [ ] No over-engineering or premature optimization
- [ ] Proper separation of concerns
- [ ] Backwards compatible or breaking changes documented

**Security**
- [ ] Input validation and sanitization
- [ ] No SQL injection vulnerabilities
- [ ] No hardcoded secrets
- [ ] Proper authentication/authorization
- [ ] Sensitive data not logged

**Correctness**
- [ ] Logic handles edge cases
- [ ] Error paths tested
- [ ] No resource leaks
- [ ] Proper null/nil handling

**Maintainability**
- [ ] Code is readable and clear
- [ ] Complex logic has explanatory comments
- [ ] Functions are reasonably sized
- [ ] No code duplication without reason

**Testing**
- [ ] New code has tests
- [ ] Tests are clear and maintainable
- [ ] Critical paths covered
- [ ] Tests are independent

**Documentation**
- [ ] Public APIs documented
- [ ] Complex algorithms explained
- [ ] Breaking changes noted in description
- [ ] README updated if needed

## Backwards Compatibility Verification

**Critical for shared libraries and public APIs:**

1. Use `Grep` to search for usages of modified symbols:
   ```bash
   # Search for function/type usage
   grep -r "ModifiedFunctionName" --include="*.go"

   # Search for interface implementations
   grep -r "implements.*ModifiedInterface" --include="*.go"
   ```

2. Check impact areas:
   - [ ] Public API changes
   - [ ] Exported types or functions
   - [ ] Protobuf contracts
   - [ ] Configuration formats
   - [ ] Database schemas

3. Document breaking changes clearly with:
   - What changed
   - Why it changed
   - Migration path for users
   - Affected downstream consumers

## Example Review

```markdown
# PR Review: Add dataset config API for product-level restrictions

## 🎯 Summary
This PR adds a new API endpoint for configuring product-level restrictions on datasets. The implementation follows existing repository + handler patterns and includes comprehensive tests. Overall code quality is good, with a few important items to address around error handling and validation.

## 🔴 Critical Issues (Must Address)

### File: `internal/http/handlers/dataset_config_handler.go:45`

**Issue**: Missing input validation could cause panic

**Code**:
```go
func (h *Handler) CreateConfig(ctx context.Context, req *DatasetConfigRequest) error {
    return h.repo.Create(ctx, req.OrgUUID, req.Product)
}
```

**Problem**: If `req` is nil, this will panic. The handler should validate input before using it.

**Suggestion**: Add validation at the start of the function:
```go
if req == nil {
    return fmt.Errorf("request cannot be nil")
}
if req.OrgUUID == "" {
    return fmt.Errorf("org_uuid is required")
}
```

---

### File: `internal/datastore/dataset_config_repository.go:78`

**Issue**: SQL injection vulnerability in dynamic query

**Code**:
```go
query := fmt.Sprintf("SELECT * FROM configs WHERE product = '%s'", product)
```

**Problem**: String interpolation in SQL queries allows SQL injection. An attacker could pass `'; DROP TABLE configs; --` as the product.

**Suggestion**: Use parameterized queries:
```go
query := "SELECT * FROM configs WHERE product = $1"
rows, err := db.Query(query, product)
```

## 🟡 Important Feedback (Should Address)

### File: `internal/http/handlers/dataset_config_handler.go:89`

**Issue**: Error not wrapped with context

**Code**:
```go
if err := h.repo.Delete(ctx, id); err != nil {
    return err
}
```

**Problem**: When this error bubbles up, there's no context about what operation failed or what ID was involved.

**Suggestion**: Wrap the error with context:
```go
if err := h.repo.Delete(ctx, id); err != nil {
    return fmt.Errorf("failed to delete dataset config %s: %w", id, err)
}
```

---

### File: `internal/datastore/dataset_config_repository_test.go:1-200`

**Issue**: Tests not using table-driven pattern

**Problem**: The test file has 15 separate test functions that are very similar. This makes the tests verbose and harder to maintain.

**Suggestion**: Refactor to table-driven tests:
```go
func TestRepository_Create(t *testing.T) {
    tests := []struct {
        name    string
        orgUUID string
        product string
        wantErr bool
    }{
        {"valid config", "uuid-1", "rum", false},
        {"empty org", "", "rum", true},
        {"invalid product", "uuid-1", "invalid", true},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            // Test logic here
        })
    }
}
```

## 💡 Suggestions (Consider)

### File: `internal/validation/dataset_config_validator.go:23`

**Suggestion**: Consider using a product enum

Currently products are validated against a string slice. Consider defining a `ProductType` enum to make this more type-safe and prevent typos:

```go
type ProductType string

const (
    ProductRUM  ProductType = "rum"
    ProductLogs ProductType = "logs"
    ProductAPM  ProductType = "apm"
)

func (p ProductType) IsValid() bool {
    switch p {
    case ProductRUM, ProductLogs, ProductAPM:
        return true
    default:
        return false
    }
}
```

## ✏️ Nits (Optional)

- `internal/http/handlers/dataset_config_handler.go:12`: Variable name `dch` could be more descriptive, consider `handler` or `h`
- `internal/datastore/dataset_config_repository.go:5`: Unused import `"time"` should be removed

## ✅ Positive Notes

- ✅ Excellent test coverage - all major paths tested including error cases
- ✅ Clear separation of concerns with repository pattern
- ✅ Good use of context throughout for cancellation
- ✅ API design follows existing patterns in the codebase
- ✅ Documentation is clear and comprehensive
```

## Error Handling

**If PR number is invalid:**
```markdown
❌ Could not find PR #12345 in DataDog/dd-source

Please verify:
- PR number is correct
- You have access to the repository
- PR hasn't been deleted

Try: `gh pr list` to see available PRs
```

**If PR is too large (>1000 lines):**
```markdown
⚠️ This PR is very large (2,500 lines changed)

Large PRs are difficult to review thoroughly and more likely to have issues. Consider:
1. Reviewing in smaller chunks (by file or component)
2. Requesting the author split into smaller PRs
3. Focusing on critical/high-risk areas first

Proceeding with review, but thoroughness may be limited.
```

**If can't access repository:**
```markdown
❌ Cannot access repository DataDog/dd-source

This could mean:
- You don't have repository access
- GitHub authentication expired (run `gh auth login`)
- Repository is private and gh CLI isn't configured

Fix: `gh auth login` and ensure you have repo access
```

## Success Criteria

A good PR review should:
- [ ] Provide a clear high-level summary
- [ ] Identify actual bugs or security issues (if any exist)
- [ ] Offer specific, actionable feedback with code examples
- [ ] Prioritize issues by severity
- [ ] Explain WHY something is a problem, not just WHAT
- [ ] Recognize good work and positive aspects
- [ ] Be respectful and constructive
- [ ] Include file paths and line numbers for all issues
- [ ] Verify backwards compatibility for public APIs
- [ ] Check test coverage and quality

## Important Notes

- **Multi-agent analysis**: Always launch parallel agents to review from different perspectives
- **Senior-swe integration**: Reference the senior-swe skill's knowledge base for best practices
- **Be thorough**: Read changed files, understand context, check for impact
- **Focus on value**: Prioritize high-impact issues over nitpicks
- **Be specific**: Every issue should have a concrete, actionable suggestion
- **Teach, don't just critique**: Explain why something is a problem
- **Backwards compatibility**: Always verify for shared code and public APIs
- **Testing is critical**: Verify test coverage and quality for all changes

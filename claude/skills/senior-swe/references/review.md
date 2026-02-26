# Code Review Best Practices

## What Makes a Good Code Reviewer

### Core Qualities

**Technical Excellence**:
- Deep understanding of the codebase
- Knowledge of language idioms and best practices
- Awareness of common pitfalls and anti-patterns
- Understanding of architecture and design patterns

**Communication Skills**:
- Clear, constructive feedback
- Explain the "why" behind suggestions
- Ask questions instead of making demands
- Balance between being thorough and being pragmatic

**Mindset**:
- Collaborative, not combative
- Focus on code quality, not ego
- Assume good intent from author
- Willing to learn from others

## Review Goals

### Primary Goals

1. **Correctness**: Does the code do what it's supposed to?
2. **Maintainability**: Can others understand and modify it?
3. **Performance**: Are there efficiency concerns?
4. **Security**: Are there vulnerabilities?
5. **Testing**: Is there adequate test coverage?

### Secondary Goals

6. **Consistency**: Does it follow codebase conventions?
7. **Documentation**: Are complex parts explained?
8. **Error Handling**: Are edge cases handled?
9. **Backward Compatibility**: Will this break existing functionality?
10. **Knowledge Sharing**: Teach and learn through review

## Review Checklist

### Functionality

**Does it work?**
- [ ] Logic is correct
- [ ] Edge cases handled
- [ ] Error conditions handled
- [ ] No regressions introduced
- [ ] Requirements met

**Tests**:
- [ ] New tests added for new code
- [ ] Tests cover happy path
- [ ] Tests cover error cases
- [ ] Tests are clear and maintainable
- [ ] All tests pass

### Code Quality

**Readability**:
- [ ] Code is self-documenting
- [ ] Variable/function names are clear
- [ ] Comments explain "why", not "what"
- [ ] Code is easy to follow
- [ ] No overly complex logic

**Structure**:
- [ ] Functions are small and focused
- [ ] Single responsibility principle followed
- [ ] No code duplication
- [ ] Appropriate abstractions used
- [ ] Consistent with existing patterns

**Error Handling**:
- [ ] Errors are handled appropriately
- [ ] Error messages are helpful
- [ ] No swallowed errors
- [ ] Context added to errors
- [ ] Resources cleaned up properly

### Performance

- [ ] No obvious performance issues
- [ ] Efficient algorithms used
- [ ] Database queries optimized
- [ ] No N+1 query problems
- [ ] Caching used where appropriate
- [ ] Resource usage reasonable

### Security

- [ ] Input validated at boundaries
- [ ] No SQL injection vulnerabilities
- [ ] No XSS vulnerabilities
- [ ] No sensitive data in logs
- [ ] Authentication/authorization checked
- [ ] Secrets not hardcoded

### Backward Compatibility

- [ ] Public APIs unchanged (or versioned)
- [ ] Database migrations are safe
- [ ] Configuration changes documented
- [ ] Deployment plan considered
- [ ] Rollback plan exists

## How to Review Code

### Before Reviewing

**Understand context**:
1. Read the PR description
2. Check linked tickets/issues
3. Understand the problem being solved
4. Review related code if unfamiliar

**Set aside time**:
- Block 30-60 minutes for thorough review
- Don't rush - quality over speed
- Review when you're fresh, not tired

### During Review

**Start high-level**:
```
1. Overall architecture
   ├── Does the approach make sense?
   ├── Are there simpler alternatives?
   └── Does it fit the codebase architecture?

2. API design
   ├── Are interfaces clear?
   ├── Is naming intuitive?
   └── Is backward compatibility maintained?

3. Test coverage
   ├── Are tests comprehensive?
   ├── Do tests verify behavior, not implementation?
   └── Are edge cases covered?

4. Implementation details
   ├── Logic correctness
   ├── Error handling
   ├── Performance
   └── Code style
```

**Review process**:

**First pass** (10-15 minutes):
- Read PR description
- Skim all changed files
- Get overall picture
- Note major concerns

**Second pass** (20-30 minutes):
- Deep dive into each file
- Check logic carefully
- Look for edge cases
- Consider error scenarios
- Think about testing

**Third pass** (10-15 minutes):
- Review tests thoroughly
- Check documentation
- Verify backward compatibility
- Look for security issues

### Providing Feedback

**Be specific**:
```
❌ Bad: "This function is confusing"
✅ Good: "This function does three things: validation,
         transformation, and persistence. Consider
         splitting into three focused functions."
```

**Explain reasoning**:
```
❌ Bad: "Use a map here"
✅ Good: "Using a map would reduce lookup time from O(n)
         to O(1). Since this is called in a loop, it could
         significantly improve performance."
```

**Ask questions**:
```
❌ Bad: "This is wrong"
✅ Good: "I'm seeing X behavior here - is that intended?
         I expected Y because of Z."
```

**Offer alternatives**:
```
❌ Bad: "Don't do it this way"
✅ Good: "Have you considered using pattern X? Here's an
         example: [link to similar code]. Benefits: Y and Z."
```

**Distinguish between blocking and non-blocking**:
```
🔴 Blocking: "This will cause data loss if X happens"
🟡 Suggestion: "Consider renaming for clarity"
💡 Nit: "Typo in comment"
```

**Use positive feedback**:
```
✅ "Nice use of the builder pattern here!"
✅ "This error handling is very thorough"
✅ "Great test coverage!"
```

## Comment Categories

### Critical (Must Fix)

**Correctness issues**:
```
🔴 "This will panic if items is empty"
🔴 "Race condition: both goroutines write to shared variable"
🔴 "SQL injection vulnerability: user input not sanitized"
```

**Security issues**:
```
🔴 "API key is hardcoded - use environment variable"
🔴 "User input directly interpolated in HTML - XSS risk"
🔴 "Password stored in plaintext - must be hashed"
```

**Breaking changes**:
```
🔴 "This changes public API - will break existing clients"
🔴 "Database migration drops column - data loss"
🔴 "Removes configuration option - breaking change"
```

### Important (Should Fix)

**Performance issues**:
```
🟡 "N+1 query - fetch all orders in one query"
🟡 "This loads entire table into memory - use pagination"
🟡 "Creating new regex on every call - move to global"
```

**Maintainability**:
```
🟡 "This function is 200 lines - consider breaking down"
🟡 "Variable name 'x' is unclear - suggest 'userCount'"
🟡 "Complex logic - add comment explaining algorithm"
```

**Testing gaps**:
```
🟡 "Missing test for error case when API returns 500"
🟡 "No test for concurrent access scenario"
🟡 "Integration test needed for database migration"
```

### Suggestions (Nice to Have)

**Style/consistency**:
```
💡 "Consider using early return to reduce nesting"
💡 "Could use table-driven test here for clarity"
💡 "Naming: 'GetUser' more idiomatic than 'FetchUser'"
```

**Optimizations**:
```
💡 "Could use string builder for better performance"
💡 "Consider caching this result - it's called frequently"
💡 "sync.Pool could reduce allocations here"
```

**Documentation**:
```
💡 "Add docstring explaining what this function does"
💡 "Link to RFC explaining this algorithm"
💡 "Add example usage in comment"
```

### Nits (Optional)

**Minor style issues**:
```
✏️ "Typo: 'recieve' → 'receive'"
✏️ "Extra whitespace"
✏️ "Inconsistent indentation"
```

## Common Reviewer Mistakes

### Being Too Nitpicky

**Problem**:
```
❌ "Add space after comma"
❌ "Use single quotes instead of double"
❌ "Rename 'data' to 'userData'"
```

**Solution**:
- Use automated formatters/linters
- Focus on substance, not style
- Only mention style if it significantly hurts readability

### Being Vague

**Problem**:
```
❌ "This is bad"
❌ "Fix this"
❌ "Why did you do it this way?"
```

**Solution**:
- Be specific about what's wrong
- Explain why it's a problem
- Suggest concrete improvements

### Bikeshedding

**Problem**: Spending too much time on trivial details while missing important issues

**Solution**:
- Review in priority order: correctness → security → performance → style
- Set time limits for review discussions
- Use "agree to disagree" for low-impact decisions

### Not Considering Context

**Problem**:
```
❌ "This should use pattern X"
   (But rest of codebase uses pattern Y)

❌ "This isn't perfect"
   (But it's a significant improvement and perfect is enemy of good)
```

**Solution**:
- Understand the constraints and trade-offs
- Consider codebase consistency
- Balance idealism with pragmatism

### Asking for Too Many Changes

**Problem**: Author feels overwhelmed, discouraged

**Solution**:
- Prioritize feedback (critical → important → nice to have)
- Consider suggesting follow-up PRs for larger refactors
- Approve if core issues are addressed, even if not perfect

## Review Workflow

### Initial Review

**Author submits PR**:
1. Self-review code
2. Write clear description
3. Link to tickets/docs
4. Mark reviewers
5. Run CI/tests

**Reviewer reviews**:
1. Check description and context
2. Review code (see process above)
3. Leave comments
4. Set status:
   - ✅ Approve (ready to merge)
   - 💬 Comment (minor issues, no changes required)
   - ⚠️ Request Changes (must be addressed)

### Addressing Feedback

**Author responds**:
- Fix critical issues immediately
- Discuss important issues if disagree
- Optional: address suggestions
- Mark conversations as resolved
- Re-request review

**Reviewer re-reviews**:
- Focus on changed code
- Verify issues addressed
- Approve or continue discussion

### Approval

**Before merging**:
- [ ] All required reviews approved
- [ ] CI passing
- [ ] Conflicts resolved
- [ ] Documentation updated
- [ ] Deployment plan ready

## Tips for Effective Reviews

### For Reviewers

**Be timely**:
- Review within 24 hours
- Prioritize blocking others
- Set aside dedicated review time

**Be thorough but efficient**:
- Focus on what matters most
- Use checklists
- Leverage automated tools
- Don't review for more than 60 minutes continuously

**Be respectful**:
- Assume competence
- Ask questions, don't accuse
- Praise good work
- Focus on code, not person

**Be a teacher**:
- Explain reasoning
- Share knowledge
- Link to resources
- Discuss trade-offs

### For Authors

**Make reviewers' jobs easier**:
- Keep PRs small (< 400 lines)
- Write clear descriptions
- Self-review before submitting
- Respond to comments promptly

**Be open to feedback**:
- Don't take it personally
- Ask for clarification if confused
- Discuss disagreements professionally
- Thank reviewers for their time

**Learn from reviews**:
- Take notes on common feedback
- Improve for next PR
- Update documentation if needed
- Share learnings with team

## Tools and Automation

### Linters and Formatters

**Automate style enforcement**:
- `golangci-lint` - Comprehensive Go linter
- `gofmt` / `goimports` - Formatting
- `prettier` - JavaScript/TypeScript
- `black` - Python

**Benefits**:
- Removes style debates from reviews
- Consistent codebase
- Catches common mistakes
- Saves reviewer time

### Static Analysis

**Security scanning**:
- `gosec` - Go security checker
- `snyk` - Dependency vulnerabilities
- `trivy` - Container scanning

**Code quality**:
- `SonarQube` - Code quality metrics
- `CodeClimate` - Maintainability scores
- `Codecov` - Coverage tracking

### CI/CD Integration

**Automated checks**:
```yaml
# .github/workflows/pr.yml
- name: Lint
  run: golangci-lint run

- name: Test
  run: go test -v -race -coverprofile=coverage.out

- name: Security Scan
  run: gosec ./...

- name: Coverage
  run: go tool cover -html=coverage.out
```

## Resources

- [Google's Code Review Developer Guide](https://google.github.io/eng-practices/review/)
- [Thoughtbot Code Review Guide](https://github.com/thoughtbot/guides/tree/main/code-review)
- [Code Review Best Practices (SmartBear)](https://smartbear.com/learn/code-review/best-practices-for-peer-code-review/)
- [The Art of Code Review (Alex Hill)](https://www.alexandra-hill.com/2018/06/25/the-art-of-giving-and-receiving-code-reviews/)
- [How to Review Code as a Junior Developer](https://medium.com/pinterest-engineering/how-to-review-code-as-a-junior-developer-10ffb7846958)

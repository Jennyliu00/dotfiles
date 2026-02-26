# Global Claude Instructions

## Documentation Maintenance

**⚠️ CRITICAL: Always update `claude/README.md` when making changes to the Claude configuration**

When you:
- Add, modify, or remove skills
- Change keybindings
- Update permissions
- Modify any files in `claude/` directory

You MUST also update `claude/README.md` to reflect those changes. Keep documentation in sync with actual configuration.

## Skills Usage Guide

### When to Use Each Skill

**`/write-ticket GRACE-1234`**
- Use when a Jira ticket lacks sufficient context for implementation
- Enhances tickets with: acceptance criteria, technical context, reference implementations, testing requirements
- Always run this BEFORE `/jira-ticket` if the ticket seems incomplete or vague
- Example: "This ticket just says 'add validation' - what kind? Where? How?"

**`/jira-ticket GRACE-1234`**
- Use when you're ready to implement a well-defined Jira ticket
- Multi-agent workflow: analysis → plan → implementation → review → draft PR
- Requires: clear acceptance criteria, technical context, reference implementations
- If ticket lacks context, run `/write-ticket` first

**`/review-pr 12345`**
- Use to get comprehensive code review of a pull request
- Multi-agent analysis from multiple perspectives (security, performance, testing, Go idioms)
- Outputs: high-level summary, critical issues, important feedback, suggestions, nits
- Looks for bugs, security vulnerabilities, bad practices, and code quality issues
- References senior-swe knowledge base for best practices

**`/senior-swe`**
- Use for expert guidance on Go programming, Zoltron codebase, systems design
- Code review feedback and best practices
- Architecture decisions and design patterns
- Has extensive reference documentation (2,237+ lines covering coding, systems, review practices, Zoltron patterns)
- Example: "How should I structure this new API?" or "Review this database query pattern"

**`/self-improvement`**
- Use after completing significant work to reflect and improve
- Updates skills, memory files, and documentation based on learnings
- Detects and fixes inconsistencies across configuration files
- Example: After a complex multi-agent ticket implementation, run this to capture learnings

## Work Style Preferences

- Be concise and direct in responses
- Focus on practical solutions
- Ask clarifying questions when requirements are unclear

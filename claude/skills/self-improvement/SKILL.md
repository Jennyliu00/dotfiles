---
name: self-improvement
description: Reflect on learnings and update skills to be smarter and more accurate over time
context: fork
agent: general-purpose
allowed-tools: Bash, Read, Grep, Glob, Edit, Write, WebFetch
---

# Self-Improvement Skill

Reflect on interactions, identify learnings, and update skills and documentation to improve future performance.

## Purpose

This skill enables continuous improvement by:
1. **Reflecting** on what happened in recent interactions
2. **Identifying** patterns, mistakes, or learnings
3. **Updating** skills, memory files, and documentation
4. **Removing** outdated or incorrect information
5. **Asking** clarifying questions to improve understanding

## Process

### 1. Reflection Phase

**Review recent context:**
- Read conversation history or task outcomes
- Identify what worked well and what didn't
- Note user corrections, feedback, or preferences
- Look for patterns in mistakes or inefficiencies

**Key questions to ask:**
- What did the user correct me on?
- What information was outdated or incorrect?
- What patterns or preferences emerged?
- What could I have done more efficiently?
- What knowledge gaps did I encounter?

### 2. Analysis Phase

**Categorize learnings:**

**User Preferences:**
- Communication style (concise, detailed, format)
- Workflow preferences (tools, commit patterns, naming)
- Technical preferences (languages, frameworks, patterns)

**Technical Learnings:**
- New patterns discovered in codebase
- Better approaches to common tasks
- Tool usage improvements
- Error patterns and solutions

**Mistakes to Avoid:**
- Incorrect assumptions made
- Outdated information used
- Missing context or requirements
- Inefficient approaches taken

**Process Improvements:**
- Better ways to break down tasks
- More efficient tool usage
- Better question-asking strategies

### 3. Update Phase

**Identify what to update:**

**Skills (`~/dotfiles/claude/skills/*/SKILL.md`):**
- Add new patterns or best practices
- Update outdated information
- Add reference documentation links
- Improve workflow descriptions
- Remove incorrect guidance

**Memory Files (`~/.claude/projects/-Users-jing-liu/memory/*.md`):**
- Update MEMORY.md with stable patterns
- Create/update topic-specific files
- Remove outdated learnings
- Add user preferences
- Document recurring solutions

**Documentation:**
- Add new reference documents
- Update existing references
- Remove broken or outdated links

### 4. Verification Phase

**Check for consistency:**
- Search for contradicting information across files
- Verify claims against documentation or code
- Test updated patterns if possible
- Ensure changes align with user preferences

**Ask clarifying questions if:**
- Uncertain about user preference
- Need to verify a pattern is correct
- Found contradicting information
- Want to confirm before making changes

## Skill Update Strategy

### When to Update a Skill

**Add information when:**
- New patterns or best practices emerge
- User provides specific guidance or corrections
- Reference documentation is identified
- Workflow improvements are discovered

**Update information when:**
- User corrects an assumption or approach
- Better patterns are found in codebase
- Documentation links are outdated
- Process descriptions are unclear

**Remove information when:**
- Information is proven incorrect
- Guidance is outdated or no longer relevant
- Contradicts user preferences
- Duplicate or redundant with other sections

### Update Guidelines

**Be specific:**
- Add concrete examples, not vague guidance
- Include file paths, function names, patterns
- Link to reference documentation
- Show before/after when relevant

**Be concise:**
- Remove redundant information
- Consolidate similar points
- Keep skills focused and scannable
- Use bullet points and clear headers

**Be accurate:**
- Verify information before adding
- Test patterns when possible
- Cite sources (docs, code, user feedback)
- Mark uncertain information clearly

## Memory File Strategy

### MEMORY.md (Primary)

**Keep concise (under 200 lines):**
- High-level patterns and principles
- Critical user preferences
- Links to topic files
- Quick reference information

**Update when:**
- Stable patterns confirmed across multiple interactions
- User explicitly requests remembering something
- Critical preferences identified
- Important architectural decisions made

### Topic Files (Detailed)

**Create separate files for:**
- Codebase-specific patterns (`zoltron-patterns.md`)
- Tool-specific guidance (`go-development.md`)
- Workflow processes (`code-review.md`)
- Reference documentation (`links.md`)

**Keep organized:**
- One topic per file
- Clear headers and structure
- Examples and code snippets
- Links to relevant resources

## Inconsistency Detection

**Look for contradictions:**
- Different guidance in different skills
- Outdated information vs current reality
- User preferences vs documented patterns
- Multiple "correct" approaches to same task

**When found:**
1. Verify which information is correct
2. Update all affected files consistently
3. Remove or correct outdated information
4. Document the correction in memory

## Reference Document Management

### Adding References

**Good references to add:**
- Official documentation (language, framework, tools)
- Internal company documentation (Confluence, wikis)
- Code examples or reference implementations
- Architecture decision records (ADRs)
- Style guides and best practices

**How to add:**
1. Verify the link is accessible and current
2. Add to relevant skill under "References" section
3. Include brief description of what the doc covers
4. Update memory file if broadly applicable

### Removing References

**Remove when:**
- Link is broken or inaccessible
- Documentation is outdated or deprecated
- Better reference found
- No longer relevant to current work

## Execution

### When Invoked Without Arguments

1. **Ask for context:**
   - "What would you like me to reflect on and improve?"
   - "Any specific feedback or learnings to incorporate?"
   - "Any skills or documentation that need updating?"

2. **Offer options:**
   - Review recent conversation for learnings
   - Update specific skill based on feedback
   - Check for inconsistencies across files
   - Add new reference documentation

### When Invoked With Specific Feedback

1. **Acknowledge feedback:**
   - Summarize what you understood
   - Ask clarifying questions if needed

2. **Identify affected files:**
   - Which skills need updating?
   - Which memory files need changes?
   - What documentation needs adding/updating?

3. **Make updates:**
   - Edit skills with new information
   - Update memory files appropriately
   - Add or update reference links
   - Remove outdated information

4. **Verify changes:**
   - Check for consistency across files
   - Ensure no contradictions introduced
   - Confirm updates align with feedback

5. **Summarize changes:**
   - List files updated
   - Describe what was changed
   - Note any clarifying questions

## Example Interactions

### Example 1: User Correction

**User:** "Actually, we use `git add <specific-files>` not `git add .` to avoid accidentally staging sensitive files."

**Response:**
1. Acknowledge: "Got it - always stage specific files for safety."
2. Identify: Need to update memory/MEMORY.md and any skills mentioning git staging
3. Update:
   - Add to MEMORY.md under "Git Practices"
   - Update any skills that mention `git add`
   - Remove or correct `git add .` references
4. Verify: Search for other mentions of git staging
5. Summarize: "Updated MEMORY.md and searched for git staging references - changed 2 instances."

### Example 2: New Pattern Discovered

**User:** "I noticed the senior-swe skill should mention Graphite for stacked PRs."

**Response:**
1. Ask: "Should this be added to the PR creation workflow section?"
2. Update: Add Graphite stacked PR pattern to senior-swe skill
3. Check: Search for other PR-related skills to keep consistent
4. Add reference: Link to Graphite documentation if available
5. Summarize: "Added Graphite stacked PR pattern to senior-swe skill under PR workflow section."

### Example 3: Inconsistency Found

**User:** "The jira-ticket skill mentions mytask but it should be jira-ticket."

**Response:**
1. Identify: Old skill name reference still present
2. Search: Grep for "mytask" across all skills and memory files
3. Update: Replace with "jira-ticket" in all locations
4. Verify: Check for any other old references
5. Summarize: "Fixed 3 references to old 'mytask' name across skills and memory files."

## Important Notes

- **Always ask when uncertain**: Better to clarify than guess
- **Verify before updating**: Check information is correct
- **Keep changes focused**: One logical improvement per update
- **Document reasoning**: Note why changes were made
- **Test when possible**: Verify patterns work as described
- **Respect user preferences**: User's way is the right way
- **Stay organized**: Keep skills focused, memory files structured
- **Remove cruft**: Delete outdated or incorrect information
- **Link generously**: Add references to documentation and examples

## Checklist Before Completing

- [ ] Identified specific learnings or feedback
- [ ] Determined which files need updating
- [ ] Made updates consistently across all affected files
- [ ] Checked for contradictions or inconsistencies
- [ ] Added relevant reference documentation
- [ ] Removed outdated or incorrect information
- [ ] Asked clarifying questions if uncertain
- [ ] Summarized changes made
- [ ] Verified updates align with user preferences

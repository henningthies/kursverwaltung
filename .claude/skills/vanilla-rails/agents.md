# Rails Development Agents

Reference documentation for using Rails development agents in your workflow.

## Architecture

```
┌─────────────────────────────────────────────────┐
│              vanilla-rails SKILL                │
│  (patterns, conventions, best practices)        │
└─────────────────────────────────────────────────┘
                      ▲
          ┌───────────┴───────────┐
          │                       │
┌─────────┴─────────┐   ┌────────┴────────┐
│  rails-developer  │   │  rails-reviewer │
│  (implementation) │   │  (code review)  │
└───────────────────┘   └─────────────────┘
```

- **Skill** = the knowledge (patterns, conventions)
- **Agents** = the workers (reference the skill, do the work)

## Available Agents

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| `rails-developer` | Feature implementation | New features, bug fixes, refactoring |
| `rails-reviewer` | Code review | PR reviews, auditing code |

## rails-developer

The main workhorse agent. Works in phases:

1. **Understand** - Read task, explore codebase, identify patterns
2. **Implement** - Models, controllers, views following conventions
3. **Test** - Write fixtures and tests
4. **Review** - Self-check before committing

### Usage with Tasks

```bash
# Create a task
/task:new Add user profile editing

# Run with background agent (uses rails-developer)
/task:bg x7k2

# Check progress
/task:check x7k2

# Review and merge
/task:finish x7k2
```

### Direct Invocation

```
Task(
  subagent_type: "rails-developer",
  prompt: "Implement user profile editing with avatar upload.
           Working directory: /path/to/project"
)
```

## rails-reviewer

Standalone code review agent. Use for:

- Reviewing PRs before merge
- Reviewing completed task branches
- Auditing existing code

### Usage

```bash
# Review current branch vs main
Task(
  subagent_type: "rails-reviewer",
  prompt: "Review the changes in branch task-x7k2.
           Working directory: /path/to/project
           Run: git diff main..task-x7k2"
)
```

### Output

Provides structured review with:
- Summary of changes
- What's good
- Issues (must fix / should fix / consider)
- Test coverage assessment
- Verdict (approve / request changes)

## Parallel Review Pattern (Loki Mode inspired)

For critical code, dispatch 3 reviewers simultaneously in a **single message** with different lenses:

```
IMPLEMENT → DISPATCH 3 REVIEWERS (one message) → AGGREGATE → FIX → REPEAT
```

### The Three Reviewers

| Reviewer | Focus | Checks |
|----------|-------|--------|
| **Code Quality** | Patterns, readability | Rails conventions, N+1s, complexity |
| **Business Logic** | Correctness | Edge cases, requirements match, data integrity |
| **Security** | Vulnerabilities | Auth/authz, injection, OWASP top 10 |

### Invocation (MUST be single message with 3 Task calls)

```ruby
# In orchestrator - all 3 in ONE response
Task(
  subagent_type: "rails-reviewer",
  model: "opus",
  prompt: "CODE QUALITY REVIEW. Focus on Rails patterns, N+1 queries, complexity.
           Working directory: #{project_path}
           Branch: #{branch}"
)

Task(
  subagent_type: "rails-reviewer",
  model: "opus",
  prompt: "BUSINESS LOGIC REVIEW. Focus on edge cases, requirements, data integrity.
           Working directory: #{project_path}
           Branch: #{branch}"
)

Task(
  subagent_type: "rails-reviewer",
  model: "opus",
  prompt: "SECURITY REVIEW. Focus on auth, injection, OWASP top 10.
           Working directory: #{project_path}
           Branch: #{branch}"
)
```

### Severity Triage

After collecting all 3 reviews:

| Severity | Action |
|----------|--------|
| **Critical/High** | BLOCK - dispatch fix agent, re-run ALL 3 reviewers |
| **Medium** | BLOCK - dispatch fix agent, re-run ALL 3 reviewers |
| **Low** | PASS - add TODO comment, continue |
| **Cosmetic** | PASS - add FIXME comment, continue |

### When to Use Parallel Review

- Launching new ventures to production
- Security-sensitive features (auth, payments)
- Data model changes
- API endpoints handling external input

### When Single Reviewer Suffices

- Internal refactoring
- Bug fixes in existing patterns
- Test additions
- Documentation changes

## Workflow: Feature in Worktree

### 1. Create Task

```bash
/task:new Add card closing functionality
```

Creates: `.tasks/feat-x7k2--add-card-closing.md`

### 2. Start Agent

**Background (fire-and-forget):**
```bash
/task:bg x7k2
```

**Interactive (tmux window):**
```bash
/task:parallel x7k2
```

### 3. Monitor

```bash
/task:check x7k2
```

### 4. Review

```bash
# See what changed
git diff main..task-x7k2

# Optionally run reviewer agent
# (or just review yourself)
```

### 5. Finish

```bash
# Merge and cleanup
/task:finish x7k2

# Or discard
/task:abandon x7k2
```

## Parallel Development

Run multiple features simultaneously:

```bash
# Start multiple agents
/task:bg x7k2   # User profiles
/task:bg y8m3   # Payment integration
/task:bg z9n4   # Email notifications

# Each works in isolated worktree
# No conflicts between agents
```

## Project Setup

For best results, ensure your Rails project has:

### CLAUDE.md or AGENTS.md

```markdown
# Project Name

## Commands
- `bin/dev` - Start development server
- `bin/rails test` - Run tests

## Architecture Notes
- Multi-tenant via Current.account
- etc.
```

### STYLE.md (optional)

Project-specific style overrides.

### Test Fixtures

```yaml
# test/fixtures/users.yml
admin:
  email: admin@example.com
  role: admin
```

## Tips

1. **Be specific** - "Add card closing with notification" > "improve cards"
2. **One feature per task** - Don't combine unrelated work
3. **Review before merge** - Always check the diff
4. **Use reviewer for PRs** - Get a second opinion on complex changes

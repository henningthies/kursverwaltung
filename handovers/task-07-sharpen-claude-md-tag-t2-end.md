# Task 07 — Sharpen CLAUDE.md and tag t2-end

> Read `_SHARED.md` first. Harness task #7. Blocked by: #4, #5, #6.

## Goal

Tighten `CLAUDE.md` now that the review skill, MCP, and secrets hook exist, then set `t2-end`.

## Steps

1. Update `CLAUDE.md` to reference the new tooling:
   - the `review` skill and when to use it,
   - the Playwright MCP for browser-driven checks,
   - the secrets hook (never put real credentials in tracked files).
2. Sharpen any vague convention wording (positive imperatives, concrete conditions).
3. Verify: `bin/rails test` green, `db:reset` clean, `GET /` → 200.
4. Commit (footer per `_SHARED.md`), then `git tag t2-end`.

## Acceptance criteria

- `CLAUDE.md` mentions review skill + MCP + secrets hook and matches what's actually in `.claude/`.
- Tests green; `t2-end` tag set.

## Files

- `CLAUDE.md`

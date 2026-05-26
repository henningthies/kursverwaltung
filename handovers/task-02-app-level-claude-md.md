# Task 02 — Add app-level CLAUDE.md (t1-end)

> Read `_SHARED.md` first. Harness task #2. Blocks: #3. Blocked by: none.

## Goal

Write the **app's own** `CLAUDE.md` — the "with CLAUDE.md" state that contrasts with the
context-free `t1-start`. It should let a fresh Claude session work on this app correctly.

Note: a `CLAUDE.md` already exists in the repo root, but it is the *course-building* context
(it describes how to build the demo across termins). The t1-end `CLAUDE.md` is the *app's*
working context. Reconcile: either replace the root file with an app-focused one, or make the
root file clearly the app's CLAUDE.md. Confirm intent if unsure — the briefing file is valuable.

## Contents (adapt from the briefing CLAUDE.md, trimmed to the real app)

- **Purpose**: 1–2 lines on what the app is.
- **Stack**: Rails 8.1, Ruby 3.4, SQLite, Minitest+fixtures, **Tailwind** (reflect reality).
- **Domain**: Course / Session table (fields + associations as currently built).
- **Conventions**: thin controllers, `STATUSES` pattern (not enum), `params.expect`,
  German UI / English code, idempotent seeds, tests for new logic.
- **How to run/verify**: `bin/rails test`, `bin/rails db:reset`, server boot.

Keep it short and literal (it's read by Claude every session). Write for a literal reader:
positive imperatives, concrete conditions.

## Acceptance criteria

- `CLAUDE.md` describes the *actual* app (including Tailwind), not the course-build plan.
- No invented files/conventions — everything stated matches the codebase.
- App still green (`bin/rails test`); this task adds no code, only the doc.

## Files

- `CLAUDE.md`

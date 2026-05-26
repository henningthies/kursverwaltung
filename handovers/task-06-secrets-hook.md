# Task 06 — Add Secrets-Hook (PreToolUse) blocking .env/credentials

> Read `_SHARED.md` first. Harness task #6. Part of t2-end. Blocked by: #3.

## Goal

Add a `PreToolUse` hook that blocks Claude from reading or writing secret files
(`.env`, `.env.*`, `config/master.key`, `config/credentials*`, `.kamal/secrets`). Carries the
T2 secrets-hook demo.

## Steps

1. Use the **update-config** skill to add the hook to `.claude/settings.json`
   (the harness runs hooks, not the model — it must live in settings).
2. Configure a `PreToolUse` matcher on file tools (e.g. Read/Edit/Write/Bash) that inspects the
   target path and **denies** when it matches the secret patterns, with a clear German/English message.
3. Implement the hook as a small script (e.g. `.claude/hooks/block-secrets.sh`) that exits non-zero
   / returns a deny decision on a match. Keep it readable — it's demo material.

## Acceptance criteria

- Attempting to read/write a matched secret path is blocked with an explanatory message.
- Normal file operations are unaffected.
- `bin/rails test` still green (no app code changed).

## Verify

- Try `Read` on `config/master.key` → blocked.
- Try `Read` on `app/models/course.rb` → allowed.

## Files

- `.claude/settings.json`
- `.claude/hooks/block-secrets.sh` (or inline command)

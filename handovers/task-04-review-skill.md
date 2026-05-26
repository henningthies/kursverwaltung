# Task 04 — Add `review` skill under .claude/skills/

> Read `_SHARED.md` first. Harness task #4. Part of t2-end. Blocked by: #3.

## Goal

Create a project-local `review` skill that reviews a diff against **this app's** conventions,
so a `/review` in the demo produces relevant, opinionated feedback. Carries the T2 skill demo.

## Steps

1. Create `.claude/skills/review/SKILL.md` with YAML frontmatter (`name: review`,
   a `description:` that triggers on "review the diff / PR / changes").
2. Body: a checklist tuned to this project —
   - vanilla Rails: thin controllers, no service objects, logic in models;
   - `STATUSES` constant + `inclusion` (flag any `enum:` usage);
   - `params.expect(...)` (flag `require.permit`);
   - German UI texts, English code names;
   - Minitest + fixtures, new logic/actions have tests with precise assertions;
   - seeds idempotent.
3. Keep instructions literal and positive (see `_SHARED.md` writing note).

## Acceptance criteria

- `.claude/skills/review/SKILL.md` exists with valid frontmatter and a usable checklist.
- Running the skill on a sample diff yields convention-specific findings.
- No app code changed; tests still green.

## Files

- `.claude/skills/review/SKILL.md`

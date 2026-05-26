# Task 03 — Tag t1-end

> Read `_SHARED.md` first. Harness task #3. Blocked by: #1, #2.

## Goal

Land the `t1-end` state: app-level `CLAUDE.md` present **and** the Termin-Zähler in the course
overview (the small visible change of demo T1 04-projekt-erkunden), then set the `t1-end` tag.

## Steps

1. Ensure task #1 (deviations) and task #2 (CLAUDE.md) are done.
2. If task #1 reverted the Termin-Zähler, re-add it now to `app/views/courses/index.html.erb`:
   show `pluralize(course.sessions.size, "Termin", plural: "Termine")` per course.
3. Update/keep the controller test asserting the count appears in the overview.
4. Verify: `bin/rails test` green, `bin/rails db:reset` clean, `GET /` → 200.
5. Commit (footer per `_SHARED.md`), then `git tag t1-end`.

## Acceptance criteria

- Overview shows the session count per course.
- `CLAUDE.md` present and app-focused.
- Tests green; `t1-end` tag points at the commit with both changes.

## Files

- `app/views/courses/index.html.erb`
- `test/controllers/courses_controller_test.rb`

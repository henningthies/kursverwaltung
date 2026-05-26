# Task 12 — Build count-heavy overview with deliberate N+1

> Read `_SHARED.md` first. Harness task #12. Blocked by: #9. Blocks: #14.
> **Intentional anti-pattern.** This builds the *problem*; the fix is the live T3 performance demo.

## Goal

Extend the course index to show **"X Anmeldungen · Y Termine"** per course, written so it triggers
an **N+1 query** — i.e. iterate `Course.ordered` and call `course.enrollments.count` /
`course.sessions.count` (or `.size` on unloaded associations) per row, with **no** `includes`
and **no** `counter_cache`.

## Steps

1. In `CoursesController#index`, keep the simple `Course.ordered` (no eager loading).
2. In `courses/index.html.erb`, render per course: confirmed enrollments count + sessions count,
   in German (e.g. `pluralize(course.enrollments.confirmed.count, "Anmeldung", plural: "Anmeldungen")`).
3. Add a short comment marking the N+1 as **deliberate demo ground** so a reviewer doesn't "fix" it
   prematurely.
4. Optionally add a test asserting the counts render (don't assert query counts here).

## Do NOT

- Do **not** add `includes(:enrollments, :sessions)`, `counter_cache`, or caching. That fix is the
  live demo (T3 Rails-Performance).

## Acceptance criteria

- Overview shows enrollment + session counts per course.
- The N+1 is present and clearly commented as intentional.
- `bin/rails test` green.

## Files

- `app/controllers/courses_controller.rb`, `app/views/courses/index.html.erb`

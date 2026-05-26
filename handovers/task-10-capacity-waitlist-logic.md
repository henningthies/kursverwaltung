# Task 10 — Implement capacity + waitlist logic (TDD)

> Read `_SHARED.md` first. Harness task #10. Blocked by: #9. Blocks: #11, #14.
> **This is the t3-feature centerpiece** (T3 demo `01-feature-zu-pr`). Build it **test-first**.

## Goal

When a participant enrolls:
- if the course has free capacity → enrollment is **confirmed**;
- if the course is full → enrollment is **waitlisted**.

When a confirmed enrollment is **cancelled**:
- the next waitlisted participant (oldest first) is **promoted** to confirmed.

Logic lives in **rich domain methods** on `Course`/`Enrollment` — no service objects, no callbacks
for business logic (use explicit methods).

## Suggested API (adjust as tests demand)

- `Course#enroll(participant)` → creates an Enrollment, confirmed or waitlisted by capacity.
- `Course#full?` / `Course#confirmed_count`.
- `Enrollment#cancel` → sets status cancelled, then triggers promotion of the next waitlisted.
- `Course#promote_next_waitlisted` (or similar), oldest waitlisted first.

## Edge cases — write tests for ALL of these first

- Course with free capacity → confirmed.
- Course exactly full → next enroll is waitlisted.
- Cancel a confirmed spot → oldest waitlisted promoted; counts correct.
- Cancel when **no** waitlist → just cancelled, no error.
- All enrollments cancelled → course empty, re-enroll works.
- `capacity` nil/0 boundary (define and test the intended behavior).
- Double-enroll same participant → blocked by the unique index/validation.

> This promotion path is intentionally a place where over-engineering / edge-case bugs can creep
> in (T3 demo `03-wenn-es-schiefgeht`). Keep the real implementation correct and minimal.

## Acceptance criteria

- Tests written first, covering every edge case above with precise assertions
  (`assert_equal`, `assert_difference`, `assert_changes`).
- Logic in models; controllers stay thin (controller wiring is task #11).
- `bin/rails test` green.

## Files

- `app/models/course.rb`, `app/models/enrollment.rb`
- `test/models/{course,enrollment}_test.rb`

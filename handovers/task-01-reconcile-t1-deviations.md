# Task 01 — Reconcile t1-start deviations (Termin-Zähler + Tailwind)

> Read `_SHARED.md` first. Harness task #1. Blocks: #3. Blocked by: none.

## Type

**Decision task** (needs a human call), not pure build. If running as an autonomous agent,
surface the decision and recommended default rather than guessing silently.

## The situation

1. **Termin-Zähler already present.** `app/views/courses/index.html.erb` already shows
   `pluralize(course.sessions.size, "Termin", plural: "Termine")` per course. But FEATURES.md
   reserves "Termin-Zähler in der Übersicht" as the **live** change for demo **T1 04-projekt-erkunden**
   (the first change Claude makes in the "foreign" project). If it's already there, that demo loses
   its payload.
2. **Tailwind used in t1-start.** The original spec said scaffold-level UI, *no CSS framework*.
   Tailwind was used by explicit request. This means the committed `t1-start` deviates from the
   documented spec, which matters if `t1-start` is meant to match the briefing exactly.

## Decision needed

- **Termin-Zähler**: keep it in t1-start (and drop/adjust the 04-projekt-erkunden demo payload),
  OR revert it from the overview so it can be added live and lands in `t1-end`.
- **Tagging**: whether to set the `t1-start` tag on the current commit, given the Tailwind deviation,
  or treat the current build as "t1-start (Tailwind variant)".

## Recommended default

- **Revert the Termin-Zähler** from `courses/index.html.erb` (show only title, instructor, status badge)
  so the T1 live demo keeps its payload; re-add it as part of task #3 (t1-end).
- Accept Tailwind as the real `t1-start`; set the tag (or a `demo/t1-start-tailwind` branch) once the
  Termin-Zähler is reverted.

## Acceptance criteria

- Decision recorded (commit message or a note in this file).
- If reverting: overview no longer shows the session count; `bin/rails test` still green
  (adjust the controller test that asserts overview content if needed).
- `t1-start` tag set or intentionally skipped, with rationale.

## Files

- `app/views/courses/index.html.erb`
- `test/controllers/courses_controller_test.rb` (if assertions touch the count)

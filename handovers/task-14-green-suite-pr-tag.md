# Task 14 — Green suite + open PR + tag t3-feature

> Read `_SHARED.md` first. Harness task #14. Blocked by: #10, #11, #12, #13.

## Goal

Finalize the t3-feature increment: everything green, the feature opened as a PR (the T3 deliverable),
and the `t3-feature` tag set once landed.

## Steps

1. Full verify:
   - `bin/rails test` fully green.
   - `bin/rails db:reset` clean; seeds idempotent and showing a populated course incl. a waitlist.
   - Server boots; `GET /` → 200; enroll/cancel work in the browser.
2. Ensure the deliberate demo grounds are intact: the N+1 (task #12) and PII endpoint (task #13)
   are present and **not** "fixed".
3. Open a PR from the feature branch to `main` (use `gh`). PR body: summary of the enrollment
   feature, capacity/waitlist behavior, and an explicit note that the N+1 and PII endpoint are
   intentional demo ground. Include the PR-body footer from repo guidance.
4. After it lands, `git tag t3-feature`.

## Acceptance criteria

- All green; demo grounds preserved; PR opened with a clear body; `t3-feature` tag set.

## Notes

- Branch from `main` for the feature work (do this back at task #8 if not already).
- Commit/PR footer per `_SHARED.md`. Open the PR only when the human asks / confirms.

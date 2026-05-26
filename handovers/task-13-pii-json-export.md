# Task 13 — Add PII JSON/export endpoint

> Read `_SHARED.md` first. Harness task #13. Blocked by: #9. Blocks: #14.
> **Intentional anti-pattern.** This builds the *problem*; the redaction is the live T3 security demo.

## Goal

Add a small, realistic JSON/export endpoint that exposes participant **name + email** (PII) — the
ground for the T3 Security-PR-Review demo. Do **not** redact, filter, or auth-gate it here.

## Steps

1. Add a route + action, e.g. `GET /courses/:id/participants.json` (or an `export` action on courses)
   returning the course's participants with `name` and `email` as JSON.
2. Keep it small: `render json: @course.participants.select(:id, :name, :email)` or a plain hash.
3. Optionally have the action also log/inspect the payload in a way a reviewer should flag
   (e.g. `Rails.logger.info(@course.participants.to_json)`) — a realistic PII-in-logs slip.
4. A minimal request test asserting JSON shape (so it's exercised), without "fixing" the exposure.

## Do NOT

- Do **not** add `filter_parameter_logging`, serializers that drop email, authentication, or
  redaction. Those are the live demo (T3 Security).

## Acceptance criteria

- Endpoint returns participant name + email as JSON.
- A comment marks the PII exposure as deliberate demo ground.
- `bin/rails test` green.

## Files

- `config/routes.rb`, `app/controllers/courses_controller.rb` (or a small new controller)
- `test/controllers/*_test.rb`

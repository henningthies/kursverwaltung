# Task 08 — Add Participant model (name, email — PII)

> Read `_SHARED.md` first. Harness task #8. Start of t3-feature. Blocked by: #7.

## Goal

Introduce `Participant` — a person who can enroll in courses. `email` is deliberately PII
(ground for the later T3 security demo; do **not** redact here).

## Steps

1. `bin/rails g model Participant name:string email:string` (then `--no-test-framework` if you
   prefer hand-written tests, matching the existing style).
2. Migration: `null: false` on name and email; add `add_index :participants, :email, unique: true`.
3. Model:
   - `has_many :enrollments, dependent: :destroy`
   - `has_many :courses, through: :enrollments`
   - `validates :name, presence: true`
   - `validates :email, presence: true, uniqueness: true` (simple format check is fine)
4. Fixtures `test/fixtures/participants.yml` (2–3 realistic German names + emails).
5. Model tests: presence/uniqueness validations, association wiring.

> The `has_many :enrollments`/`:courses` lines depend on the Enrollment model (task #9). It is
> fine to add them now and let task #9 create the join; ensure tests stay green at each step
> (you may stub the association test until #9 lands, or do #8 and #9 together).

## Acceptance criteria

- `Participant` migrates, validates name + unique email.
- Fixtures + model tests added; `bin/rails test` green.

## Files

- `db/migrate/*_create_participants.rb`, `app/models/participant.rb`
- `test/fixtures/participants.yml`, `test/models/participant_test.rb`

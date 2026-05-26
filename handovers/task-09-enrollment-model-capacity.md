# Task 09 — Add Enrollment model + Course capacity/associations

> Read `_SHARED.md` first. Harness task #9. Blocked by: #8. Blocks: #10, #12, #13.

## Goal

Add the join between Course and Participant, with an enrollment status and a course capacity.
This is structure only — the **promotion logic** is task #10.

## Steps

1. `bin/rails g model Enrollment course:references participant:references status:string`.
2. Migration: `null: false` on the references and on status with `default: "confirmed"`;
   add a unique index `add_index :enrollments, [:course_id, :participant_id], unique: true`.
3. `Enrollment` model (use the **STATUSES pattern, not enum**):
   ```ruby
   STATUSES = %w[confirmed waitlisted cancelled].freeze
   belongs_to :course
   belongs_to :participant
   validates :status, inclusion: { in: STATUSES }
   scope :confirmed,  -> { where(status: "confirmed") }
   scope :waitlisted, -> { where(status: "waitlisted") }
   ```
4. Add to `Course`: a `capacity:integer` column (migration), plus
   `has_many :enrollments, dependent: :destroy` and `has_many :participants, through: :enrollments`.
   Decide a sensible capacity validation (e.g. allow nil = unlimited, or `numericality`); keep simple.
5. Fixtures `test/fixtures/enrollments.yml` and capacity values in `courses.yml`.
6. Model tests: associations, status inclusion, scopes, `dependent: :destroy` from both sides.
7. Seeds: give one course a small capacity so a waitlist can be demoed later (task #11).

## Acceptance criteria

- Enrollment + capacity migrate; associations and STATUSES validated.
- Unique enrollment per (course, participant).
- Fixtures + model tests added; `bin/rails test` green; `db:reset` clean.

## Files

- migrations for `enrollments` and `courses.capacity`
- `app/models/enrollment.rb`, `app/models/course.rb`, `app/models/participant.rb`
- `test/fixtures/{enrollments,courses}.yml`, `test/models/enrollment_test.rb`

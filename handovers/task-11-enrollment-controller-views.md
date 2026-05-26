# Task 11 — Add Enrollment controller + views (anmelden/abmelden)

> Read `_SHARED.md` first. Harness task #11. Blocked by: #10. Blocks: #14.

## Goal

Expose enrollment in the UI: enroll a participant into a course (anmelden) and cancel (abmelden),
showing confirmed vs waitlisted on the course page. Thin controller calling the task-#10 domain methods.

## Steps

1. Routes: nest under course, RESTful —
   ```ruby
   resources :courses do
     resources :sessions, only: %i[create destroy]
     resources :enrollments, only: %i[create destroy]
   end
   ```
2. `EnrollmentsController`:
   - `create` → find/build participant (by name + email), call `@course.enroll(participant)`,
     redirect with a German notice that reflects confirmed vs waitlisted.
   - `destroy` → `@enrollment.cancel`, redirect with notice. `params.expect(...)`.
3. Course show view: list confirmed participants and the waitlist separately; an "Anmelden" form
   (name + email) and a "Abmelden" button per enrollment. German labels.
4. Controller tests: successful enroll (confirmed), enroll into a full course (waitlisted),
   cancel → promotion reflected, and a sad path (blank name/email → unprocessable_entity).
5. Seeds: add a few enrollments incl. a full course so the waitlist is visible on first load.

## Acceptance criteria

- Enroll/cancel work end-to-end through the UI; confirmed/waitlist shown distinctly.
- German notices; thin controller; `params.expect`.
- Controller tests incl. sad path; `bin/rails test` green; `db:reset` clean.

## Files

- `config/routes.rb`, `app/controllers/enrollments_controller.rb`
- `app/views/courses/show.html.erb` (+ partials), `db/seeds.rb`
- `test/controllers/enrollments_controller_test.rb`

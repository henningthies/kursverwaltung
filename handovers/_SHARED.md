# Shared context — Kursverwaltung handovers

**Read this first, then your task file (`task-NN-*.md`).** Every handover assumes this context.

## What this project is

A small Rails app to manage **Kurse** (courses) and their **Termine** (sessions), later
**Anmeldungen** (enrollments). It is the running demo app for the Rheinwerk course
*„Claude Code im Projektalltag"*. The code is teaching material: keep it small and readable.
See `CLAUDE.md` (domain + conventions) and `FEATURES.md` (build target) in the repo root.

## Stack

- Rails 8.1, Ruby 3.4, SQLite (file DB), Minitest + Fixtures (no RSpec/FactoryBot)
- **Tailwind CSS** (tailwindcss-rails) for the UI — note this deviates from the original
  spec ("no CSS framework"); it was a deliberate request and is the current reality.
- German UI texts; English model/method/variable names.

## Conventions (binding — vanilla Rails / 37signals)

- Thin controllers, seven standard actions, **no service objects**, no extra abstraction gems.
- Enum-like fields use the **`STATUSES` constant + `inclusion` validation** pattern, **not** `enum`:
  ```ruby
  STATUSES = %w[draft active done].freeze
  validates :status, inclusion: { in: STATUSES }
  ```
  In views: `form.select :status, Course::STATUSES`.
- Strong params with **`params.expect(...)`** (Rails-8 style), not `require.permit`.
- German labels and flash notices. Rich domain models, logic in models not controllers.
- Minitest + fixtures; **new logic/actions get tests**. `bin/rails test` must stay green.
- Seeds idempotent (`destroy_all` first) → reproducible demo start state.

## Current state (t1-start, committed on `main`)

- **Models**: `Course` (`title`, `status` draft/active/done, `description:text`, `instructor`;
  `has_many :sessions, dependent: :destroy`; `scope :ordered` by title).
  `Session` (`belongs_to :course`, `title`, `starts_at:datetime`; `scope :ordered` by starts_at).
- **Controllers**: `CoursesController` (full CRUD), `SessionsController` (create/destroy, nested).
- **Routes**: `resources :courses do resources :sessions, only: %i[create destroy] end`; root → `courses#index`.
- **Views**: Tailwind ERB. Layout `app/views/layouts/application.html.erb` (header + flash).
  `courses/{index,show,new,edit,_form}`. `CoursesHelper` has `course_status_label/badge`.
- **i18n**: `config/locales/de.yml`, `default_locale = :de`, `time_zone = "Berlin"`.
- **Seeds**: `db/seeds.rb` (4 courses). `demo:reset` rake task wraps `db:reset`.
- **Tests**: `test/models/{course,session}_test.rb`, `test/controllers/{courses,sessions}_controller_test.rb`,
  fixtures `courses.yml`/`sessions.yml`. 17 runs green.

## Progression tags (roadmap)

`t1-start` (done) → `t1-end` (CLAUDE.md + Termin-Zähler) → `t2-end` (review skill, MCP, secrets hook,
sharpened CLAUDE.md) → `t3-feature` (Participant + Enrollment + capacity/waitlist, feature→PR).

## Definition of done (every build task)

1. `bin/rails test` green.
2. `bin/rails db:reset` runs clean (seeds idempotent).
3. Server boots, `GET /` → 200.
4. Follows the conventions above. New behavior has tests.

## Git

- Commit only when the human asks. Branch from `main` for feature work.
- Commit footer: `Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>`

## Important: live-demo payloads — do NOT pre-build

Some FEATURES.md items are added **live** during the course and must stay absent until then:
the `level` field (T1), the Course status-workflow refactor (T3), the **N+1 fix**, and the
**PII redaction**. Tasks 12 and 13 build the *problems* on purpose; the fixes are live demos.

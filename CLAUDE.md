# Kursverwaltung

Kleine Rails-App zum Verwalten von **Kursen** (`Course`) und ihren **Terminen** (`Session`).
Demo-App für den Rheinwerk-Kurs *Claude Code im Projektalltag* — der Code ist Lehrmaterial,
also **klein und lesbar** halten. (Bau- und Kurskontext: `doc/course-build-context.md`,
`FEATURES.md`, `prompt.md`.)

## Stack

- Rails 8.1, Ruby 3.4, SQLite (Datei-DB)
- Minitest + Fixtures (kein RSpec, kein FactoryBot)
- Tailwind CSS (`tailwindcss-rails`), Akzentfarbe **`violet-600`** — UI-Tokens in `doc/design/ui-style-guide.md`
- Deutsche UI-Texte; englische Modell-/Methoden-/Variablennamen

## Domäne

| Modell | Felder | Beziehungen |
|--------|--------|-------------|
| `Course` | `title`, `status` (draft/active/done), `description:text`, `instructor` | `has_many :sessions, dependent: :destroy`; `scope :ordered` (nach `title`) |
| `Session` | `title`, `starts_at:datetime` | `belongs_to :course`; `scope :ordered` (nach `starts_at`) |

CRUD für Courses (`index`/`show`/`new`/`edit`); Termine werden auf der Course-Show-Seite
angelegt und gelöscht. Status als Select über `Course::STATUSES`.

## Konventionen (verbindlich — vanilla Rails / 37signals)

- **Schlanke Controller**, sieben Standard-Actions, **keine** Service-Objekte, keine
  Abstraktions-Gems. Logik lebt in den Modellen, nicht in Controllern.
- **Status-Felder über das `STATUSES`-Muster** (Konstante + `inclusion`-Validierung), **nicht** `enum`:
  ```ruby
  STATUSES = %w[draft active done].freeze
  validates :status, inclusion: { in: STATUSES }
  ```
  In Views: `form.select :status, Course::STATUSES`. Neue Status-Felder genau so.
- **Strong Parameters mit `params.expect(...)`** (Rails-8-Stil), nicht `require.permit`.
- **Deutsche Labels und Flash-Notices**; englische Bezeichner im Code.
- **Minitest + Fixtures**; neue Logik/Actions bekommen Tests mit präzisen Assertions.
- **Seeds idempotent** (`destroy_all` vorab) → reproduzierbarer Startzustand.
- **Views folgen `doc/design/ui-style-guide.md`**: violet-Akzent, runde Karten, Pill-Badges,
  Status-Badges zentral im Helper, nur Tailwind-Skalen (kein blauer Akzent, keine eigenen Hex-Werte).

## Ausführen & prüfen

- Tests: `bin/rails test` (muss grün sein)
- DB zurücksetzen: `bin/rails db:reset` (läuft sauber durch; oder `bin/rails demo:reset`)
- Server: `bin/dev` (mit Tailwind-Watch) oder `bin/rails server` — `GET /` liefert 200

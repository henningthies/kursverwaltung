# Kurs-Bau-Kontext — Kursverwaltung

> Diese Datei war ursprünglich die Wurzel-`CLAUDE.md`. Sie beschreibt den **Entwicklungs-/
> Kurskontext** für den Aufbau der Demo-App über die Termine. Ab Stand `t1-end` ist die
> Wurzel-`CLAUDE.md` der *App-Arbeitskontext* (von Claude in jeder Session geladen); dieser
> Bau-Kontext lebt seither hier. Die konkreten Bau-Anweisungen stehen in [`prompt.md`](../prompt.md),
> das Bau-Ziel in [`FEATURES.md`](../FEATURES.md).

## Zweck der App im Kurs

Eine kleine Rails-App zum Verwalten von **Kursen** und ihren **Terminen** (und später
**Anmeldungen**). Sie ist die durchgehende Demo-App („roter Faden") für den Rheinwerk-Kurs
*„Claude Code im Projektalltag"* — und verwaltet selbstreferenziell genau solche Kurse
wie den, in dem sie gezeigt wird. Der Anschluss für die Teilnehmer ist sofort da:
jeder versteht „Kurs hat Termine und Anmeldungen", ohne dass man die Domäne erklären muss.

- Lesbar genug, um in einer Live-Demo komplett am Bildschirm überblickt zu werden.
- Reich genug für Migration, Validierung, Assoziationen, Tests und ein echtes Feature.
- Wächst über drei Termine als derselbe Code (Teilnehmer sehen ihn reifen).

## Stack (Ziel)

- Rails 8.1, Ruby 3.4, SQLite (Datei-DB, kein externer Server)
- Minitest + Fixtures (kein RSpec, kein FactoryBot)
- UI: Tailwind CSS (bewusste Abweichung vom ursprünglichen „kein CSS-Framework"), deutsche Texte

## Domänenmodell (Zielzustand)

| Modell | Felder | Beziehungen |
|--------|--------|-------------|
| **Course** (Kurs) | `title`, `status` (draft/active/done), `description:text`, `instructor` | `has_many :sessions, dependent: :destroy` |
| **Session** (Termin) | `title`, `starts_at:datetime` | `belongs_to :course` |
| **Enrollment** (Anmeldung) | *(erst Termin 3)* `participant_name`, `email`, `status` | `belongs_to :course` |

## Konventionen (verbindlich — vanilla Rails / 37signals)

- **Schlanke Controller**, sieben Standard-Actions, keine Service-Objekte, keine
  zusätzlichen Abstraktions-Gems. Keine Architektur, die hier sonst nirgends vorkommt.
- **Enum-artige Felder über das `STATUSES`-Muster** — *nicht* über `enum`:
  ```ruby
  class Course < ApplicationRecord
    STATUSES = %w[draft active done].freeze
    validates :status, inclusion: { in: STATUSES }
  end
  ```
  In der View per `form.select :status, Course::STATUSES`. Neue enum-artige Felder genau so.
- **Strong Parameters mit `params.expect(...)`** (Rails-8-Stil), nicht `require.permit`.
- **Deutsche UI-Texte** (Labels, Flash-Notices). Modell-/Methoden-/Variablennamen **englisch**.
- **Minitest + Fixtures**, neue Logik/Actions bekommen Tests. `bin/rails test` muss grün sein.
- **Seeds idempotent** (`Course.destroy_all` vorab) → reproduzierbarer Demo-Startzustand.

## So wächst die App über die Termine (Progressions-Tags)

| Tag | Stand | Inhalt |
|-----|-------|--------|
| `t1-start` | roh, **ohne** App-CLAUDE.md | Course + Session, Seeds, Tests |
| `t1-end` | nach T1 | + App-CLAUDE.md, kleine Änderung (Termin-Zähler in der Übersicht) |
| `t2-end` | nach T2 | + `review`-Skill, MCP-Anbindung, Secrets-Hook, geschärfte CLAUDE.md |
| `t3-feature` | nach T3 | + **Enrollment**-Feature (Anmeldung mit Kapazität/Warteliste) bis zum PR |

Demo-Varianten/Fallbacks als Branches: `demo/t<N>-<nr>-<slug>`.
Reset überall: `git checkout <tag/branch> && bin/rails db:reset`.

# Features — Bau-Ziel für die Kursverwaltung

Leitfaden für den Ausbau zu einer App, die im Kurs *genug zu zeigen* hat. **Jedes Feature
zahlt auf eine konkrete Demo ein** — nichts wird „nur so" gebaut. Ergänzt `CLAUDE.md`
(Domäne/Konventionen) und `prompt.md` (Bau-Reihenfolge).

## Leitplanke (nicht überschreiten)

Reich heißt *mehr Substanz zum Navigieren*, nicht *mehr zum Erklären*.

- **Am Bildschirm in Sekunden überblickbar.** Sobald man die Domäne erklären muss, lenkt sie ab.
- **3–5 Modelle, vanilla Rails.** Keine Service-Layer, keine Engines, kein schweres JS, keine Auth-Tiefe, keine Zahlungs-/Mandanten-Logik.
- **Echte Logik an wenigen Stellen** (Kapazität/Warteliste, Status-Übergänge) — dort, wo eine Demo sie braucht. Sonst schlicht.
- Faustregel beim Hinzufügen: *„Welche Demo trägt das?"* Keine Antwort → weglassen.

## Modell (Zielzustand)

| Modell | Felder (Kern) | Beziehungen |
|--------|---------------|-------------|
| **Course** | `title`, `status` (draft/active/done), `description`, `instructor`, `capacity:integer` | `has_many :sessions`, `has_many :enrollments`, `has_many :participants, through: :enrollments` |
| **Session** | `title`, `starts_at:datetime` | `belongs_to :course` |
| **Participant** | `name`, `email` *(PII!)* | `has_many :enrollments`, `has_many :courses, through:` |
| **Enrollment** | `status` (confirmed/waitlisted/cancelled) | `belongs_to :course`, `belongs_to :participant` |

`STATUSES`-Muster für jedes Status-Feld (Konstante + `inclusion`), nicht `enum`.

## Features → welche Demo sie tragen

| Feature | Was es bringt | Trägt Demo |
|---------|---------------|------------|
| **Kapazität + Warteliste** bei Enrollment | Voller Kurs → `waitlisted`; Absage → nächste:r von der Warteliste nachrücken. Echte Logik mit Edge Cases (voll / leer / alle abgesagt). | **T3 `01-feature-zu-pr`** (das zentrale Feature→PR mit TDD) und **T3 `03-wenn-es-schiefgeht`** (Promotion-Logik ist eine perfekte Stelle für Over-Engineering / Edge-Case-Fehler) |
| **Zähl-lastige Kursübersicht** („X Anmeldungen · Y Termine" pro Kurs) | Eingebaute **N+1-Falle** in der Index-Query. | **T3 Rails-Performance** *(offener Punkt im Overview)* — Claude findet & fixt N+1 via `includes` / `counter_cache` |
| **Teilnehmer mit E-Mail/Name (PII)** + ein JSON-/Export-Endpoint | Realistische personenbezogene Daten + eine Stelle, an der PII versehentlich in Logs/JSON landet. | **T3 Security-PR-Review** *(offener Punkt im Overview)* — PII-Exposure im PR erkennbar machen |
| **Status-Workflow Course** (draft→active→done, geordnete Übergänge) | Validierung mit Regeln statt freiem Feld. | **T3 `02-refactor-review`** (Logik refactoren + `/review`) und T2-Skill-Demo |
| **Course-Level-Feld** (z. B. `level` low/medium/high) | Einfaches enum-artiges Feld nach `STATUSES`-Muster. | **T1 `01-llm-vs-agent`** („Feld hinzufügen") und **T1 `03-claude-md-wirkung`** (ohne/mit CLAUDE.md) |
| **Termin-Zähler in der Übersicht** | Kleine, sichtbare Änderung über eine Assoziation. | **T1 `04-projekt-erkunden`** (erste Änderung im fremden Projekt) |

## Was bewusst NICHT rein soll

Auth/Login, Bezahlung, Mehrmandanten, Kalender-JS-Libs, E-Mail-Versand-Infrastruktur
(höchstens ein Job-Stub), Admin-Frameworks, API-Versionierung. Alles davon kostet
Überblickbarkeit, ohne eine Demo zu tragen.

## Staffelung auf die Progressions-Tags

- **`t1-start`** (siehe `prompt.md`): nur **Course + Session**, roh, ohne CLAUDE.md. Bewusst schlicht — das „fremde Projekt".
- **`t1-end`**: + CLAUDE.md, + Termin-Zähler in der Übersicht.
- **`t2-end`**: + `review`-Skill, MCP, Secrets-Hook, geschärfte CLAUDE.md.
- **`t3-feature`**: + **Participant + Enrollment + Kapazität/Warteliste** (das Feature→PR). Hier kommen N+1-Übersicht und PII-Stelle dazu — als Boden für die Performance- und Security-Demos.

> Heißt für den Ausbau: Course/Session reich genug machen, dass T1/T2 etwas zu zeigen
> haben — aber **Participant/Enrollment/Kapazität bewusst für T3 aufsparen**, damit das
> Herzstück-Feature live entsteht und nicht schon da ist.

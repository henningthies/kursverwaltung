# Bau-Anweisungen — Kursverwaltung (Stand `t1-start`)

Diese Datei ist der **Prompt zum Loslegen**. Öffne Claude Code in diesem Ordner
(`cd ~/dev/kursverwaltung && claude`) und gib den Block unter „Prompt" ein — oder
übergib ihn dem `rails-demo-builder`-Agenten. Lies vorher `CLAUDE.md` (Domäne + Konventionen).

Ziel dieses ersten Schrittes: der lauffähige, **unkonfigurierte** Startzustand `t1-start`
— die App, die in Termin 1 als „fremdes Projekt" erkundet wird.

---

## Prompt (so an Claude Code geben)

> Baue das Grundgerüst der Kursverwaltungs-App im Zustand `t1-start`. Lies `CLAUDE.md`
> für Domäne und Konventionen (vanilla Rails / 37signals, deutsche UI, Minitest, das
> `STATUSES`-Muster). Halte alles klein und lesbar — der Code ist Lehrmaterial.
>
> **Tech:** Rails 8.1, Ruby 3.4, SQLite, Minitest. `rails new .` mit sinnvollen Defaults,
> UI minimal (Scaffold-Niveau reicht, aufgeräumt).
>
> **Domäne (klein halten):**
> - `Course`: `title:string`, `status:string` (Validierung: inclusion in `STATUSES = %w[draft active done]`, DB-Default `"draft"`), `description:text`, `instructor:string`. `has_many :sessions, dependent: :destroy`. Validierung: `title` presence.
> - `Session`: `belongs_to :course`, `title:string` (presence), `starts_at:datetime`. Scope `ordered` nach `starts_at`.
> - Schlichte CRUD-Oberfläche für Courses (Index/Show/New/Edit). Sessions auf der Course-Show-Seite anlegbar/löschbar. Status als Select über `Course::STATUSES`.
> - Strong Params mit `params.expect(...)`. Deutsche Labels und Flash-Notices.
>
> **Seeds (`db/seeds.rb`, idempotent):** 3–4 realistische, gern selbstreferenzielle Kurse
> mit je ein paar Terminen — z. B. „Claude Code im Projektalltag" (3 Termine), „Rails
> Performance", „Git für Teams". Deutsche Beispieldaten.
>
> **Tests:** Modelltests (Validierungen, Assoziationen, `dependent: :destroy`) und ein
> Controller-Test für die Course-Index. `bin/rails test` muss grün sein.
>
> **Reproduzierbarkeit:** `bin/rails db:reset` läuft sauber durch; optional ein
> `demo:reset`-Rake-Task als Wrapper.
>
> **Bewusst NICHT:** keine `CLAUDE.md`, kein `.claude/`, keine Auth, keine API, kein
> Enrollment (das kommt in Termin 3). `t1-start` ist absichtlich unkonfiguriert.
>
> **Git:** `git init`, Standard-Rails-`.gitignore`. Ein sauberer initialer Commit **ohne
> CLAUDE.md**, dann Tag `t1-start` setzen. Commit-Footer:
> `Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>`
>
> **Verifikation (ausführen & berichten):** `bin/rails db:prepare && bin/rails db:seed`
> fehlerfrei · `bin/rails test` grün · Server bootet (`GET /` liefert 200).

---

## Danach (Roadmap der weiteren Stände)

Erst wenn `t1-start` steht und läuft:

1. **`t1-end`** — erste `CLAUDE.md` (Inhalt ≈ die hier im Ordner, an die App angepasst)
   + kleine Änderung: Anzahl der Termine pro Kurs in der Übersicht. Tag `t1-end`.
2. **`t2-end`** — `review`-Skill (`.claude/skills/`), MCP-Anbindung (`.mcp.json`, Playwright),
   Secrets-Hook (PreToolUse, blockt `.env`/credentials), CLAUDE.md schärfen. Tag `t2-end`.
3. **`t3-feature`** — Feature **Enrollment** (Anmeldung): `belongs_to :course`,
   `participant_name`, `email`, `status` (confirmed/waitlisted); Kapazität pro Kurs mit
   **Warteliste als Edge Case**; TDD bis zum PR. Tag `t3-feature`.

Die ausgearbeiteten Demo-Runbooks im Kurs-Repo (`~/online-kurs/kurs/termin-*/demos/`)
beschreiben, was an jedem Stand live passiert — sie sind aktuell noch auf die alte
`briefing-app` formuliert und werden auf diese Domäne gezogen, sobald die App steht.

## Separates Repo / Remote

Dieser Ordner ist ein **eigenes Git-Repo** (nicht im Kurs-Repo verschachtelt). Ein
GitHub-Remote anlegen und pushen, sobald `t1-start` steht — dann ist die App inkl. aller
Tags gesichert (das war beim alten `briefing-app`-Setup das offene Problem).

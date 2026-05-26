---
name: feature-plan
description: Stufe 1 der Software-Factory für die Kursverwaltung. Nutze dies, wenn ein Feature aus FEATURES.md geplant werden soll, bevor Code entsteht — Feature wählen, Feature-Branch anlegen, eine geordnete TDD-Task-Liste erstellen und einen ADR-Entwurf (Architecture Decision Record) für die Kern-Entscheidung schreiben. Auslöser: "plane Feature X", "baue Feature Y" (dann startet hier), "lass uns das nächste Feature angehen".
---

# Feature-Plan (Factory-Stufe 1)

Du planst — du schreibst **keinen** Anwendungscode (das macht `feature-build`). Ziel:
ein Feature aus `FEATURES.md` so vorbereiten, dass es **einfach, vanilla-Rails und
demo-tragend** umgesetzt werden kann, und die Kern-Entscheidung als ADR festhalten.

## Vorgehen

1. **Feature bestimmen.** Lies `FEATURES.md` und `CLAUDE.md`. Matche den Auftrag (Slug
   *oder* Beschreibung) fuzzy gegen die Feature-Tabelle. Kein Treffer / mehrdeutig / kein
   Argument → die offenen Features mit Slug-Vorschlägen auflisten und nachfragen, nicht raten.

2. **Slug ableiten.** kebab-case, knapp (z. B. `kapazitaet-warteliste`, `level-feld`,
   `status-workflow`, `kursuebersicht-zaehler`, `participant-pii-export`).

3. **Branch anlegen.** Auf `main`/sauber → `git checkout -b feature/<slug>`. Branch
   existiert → `git switch feature/<slug>`. Fremde uncommittete Änderungen → stoppen und
   nachfragen. **Nie** auf `main` arbeiten.

4. **Best-practice-Leitplanke verankern** (aus FEATURES.md, verbindlich):
   - Reich heißt *mehr Substanz zum Navigieren*, nicht *mehr zum Erklären*.
   - Einfachste vanilla-Rails-Lösung, die die Demo trägt. Keine Service-Layer, keine
     Zusatz-Gems, kein schweres JS, keine Auth/Zahlung/Mandanten.
   - `STATUSES`-Muster statt `enum`; `params.expect(...)`; deutsche UI / englische Bezeichner.
   - Faustregel beim Hinzufügen: *„Welche Demo trägt das?"* — keine Antwort → weglassen.

5. **Planung an den `planner`-Agenten delegieren** (Task-Tool, subagent_type `planner`).
   Gib ihm: den Feature-Eintrag aus FEATURES.md (inkl. getragener Demo + Edge Cases), die
   Leitplanke aus Schritt 4, die Konventionen aus CLAUDE.md. Auftrag:
   - Feature in eine **geordnete Task-Liste** zerlegen, je Task: berührte Dateien
     (Migration, Modell, Controller, Views, Fixtures, Tests), Validierung/Logik, und
     **welcher Test zuerst** (TDD).
   - Edge Cases aus FEATURES.md explizit als eigene Test-Fälle (z. B. voll / leer /
     alle abgesagt).
   - Plan schreiben nach `.claude/factory/plans/<slug>.md` mit den Abschnitten:
     `# <Titel> (feature/<slug>)` · `## Trägt Demo` · `## Domänen-Änderung` · `## Tasks`
     · `## Edge Cases / Tests` · `## Bewusst NICHT`.

6. **ADR-Entwurf schreiben.** Lege `doc/adr/NNNN-<slug>.md` an — NNNN = nächste freie
   4-stellige Nummer in `doc/adr/` (höchste vorhandene + 1, mit führenden Nullen).
   Nutze `.claude/skills/feature-plan/templates/adr-template.md` als Vorlage, **Status:
   Proposed**. Der ADR hält die *eine* Kern-Entscheidung fest (z. B. „Warteliste über
   `position`-Spalte statt sortiert nach `created_at`") **inklusive der verworfenen,
   komplexeren Alternative** — so wird die Einfachheit explizit begründet.

7. **Zusammenfassen.** Melde: erkanntes Feature, Slug, Branch, Plan-Pfad, ADR-Pfad,
   Anzahl Tasks. Nächste Stufe: `feature-build`. Nicht committen, nicht bauen.

---
name: feature-review
description: Stufe 3 der Software-Factory für die Kursverwaltung. Nutze dies, wenn ein gebautes Feature geprüft werden soll — Diff gegen main von rails-reviewer gegen vanilla-Rails-Stil, Plan und ADR reviewen, Tests gegenprüfen, Doku-Vollständigkeit (ADR Accepted + Produkt-Doc vorhanden) und absichtliche Demo-Schwachstellen bestätigen. Auslöser: "review Feature X", "prüf den feature-Branch", "ist das Feature fertig".
---

# Feature-Review (Factory-Stufe 3)

Prüft das Gebaute gegen Plan, ADR und Konventionen. Ändert **keinen** Code (Fixes gehen
zurück über `feature-build`), committet nicht, pusht nicht.

## Vorgehen

1. **Scope.** Slug aus Argument, sonst aus aktuellem Branch `feature/<slug>`. Diff gegen
   `main` ermitteln (`git diff main...HEAD --stat` + voller Diff). Kein feature-Branch →
   Hinweis und stoppen.

2. **Soll-Maßstab laden.** `.claude/factory/plans/<slug>.md` und `doc/adr/NNNN-<slug>.md`.
   Das Review prüft auch: Erfüllt das Gebaute Plan + ADR (alle Edge Cases da, Entscheidung
   so umgesetzt)?

3. **An `rails-reviewer` delegieren** (Task-Tool, subagent_type `rails-reviewer`) mit Diff,
   Plan und ADR. Prüf-Fokus aus CLAUDE.md: `STATUSES`-Muster (kein `enum`),
   `params.expect(...)`, schlanke Controller / 7 Actions, keine Service-Objekte/Zusatz-Gems,
   deutsche UI / englische Bezeichner, Minitest + Fixtures, idempotente Seeds. Befunde nach
   Schweregrad (Blocker / Sollte / Nice-to-have), je mit `datei:zeile` + konkretem Fix.

4. **Tests gegenprüfen.** `bin/rails test` laufen lassen, Ergebnis ins Review aufnehmen.

5. **Doku-Check.** ADR auf **Accepted**? Produkt-Doc `doc/product/<slug>.md` vorhanden und
   inhaltlich passend? Fehlt etwas → als Befund melden.

6. **Demo-Haken bestätigen** (Besonderheit dieses Projekts): Trägt das Feature laut
   FEATURES.md eine *absichtliche* Schwachstelle als Demo-Boden (N+1 in der Kursübersicht,
   PII im Export), dann **bestätigen, dass sie vorhanden ist** — als „Demo-Haken ✓", nicht
   als Bug. Echte, ungeplante Fehler bleiben Befunde.

7. **Berichten.** Strukturiert im Chat: Test-Status, Befunde nach Schweregrad,
   Plan-/ADR-Erfüllung, Doku-Check, Demo-Haken. Keine Änderung, kein Commit.

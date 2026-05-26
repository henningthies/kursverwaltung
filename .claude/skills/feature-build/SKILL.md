---
name: feature-build
description: Stufe 2 der Software-Factory für die Kursverwaltung. Nutze dies, wenn ein in feature-plan geplantes Feature umgesetzt werden soll — TDD-Implementierung nach vanilla-Rails-Best-Practices, Tests grün, ADR auf Accepted setzen, Produkt-Dokumentation für den Human-in-the-Loop schreiben und lokal committen (kein Push). Auslöser: "implementiere/baue Feature X", "setz den Plan für X um".
---

# Feature-Build (Factory-Stufe 2)

Setzt den Plan aus Stufe 1 um — **einfach, getestet, dokumentiert**.

## Vorbedingungen

1. Plan `.claude/factory/plans/<slug>.md` muss existieren — sonst auf `feature-plan`
   verweisen und stoppen.
2. Aktueller Branch = `feature/<slug>`; sonst `git switch feature/<slug>`. **Nie** auf `main`.

## Implementierung an den `rails-developer`-Agenten delegieren

Task-Tool, subagent_type `rails-developer`. Gib ihm den vollständigen Plan *und* den ADR
`doc/adr/NNNN-<slug>.md` (die Entscheidung ist bindend) mit. Verbindlich:

- **Best practices / einfach halten:** die im ADR beschlossene, einfachste Lösung — keine
  Erweiterung über den Plan hinaus. vanilla Rails / 37signals, schlanke Controller, 7
  Standard-Actions, keine Service-Objekte, keine Zusatz-Gems.
- **`STATUSES`-Muster statt `enum`**, `params.expect(...)`, deutsche UI / englische Bezeichner.
- **TDD:** pro Task erst der Test (rot), dann Implementierung (grün). Jeder Edge Case aus
  Plan/ADR ist ein eigener Test. Minitest + Fixtures (kein RSpec/FactoryBot). Stil-Referenz:
  der `vanilla-rails`-Skill.
- **Gate:** `bin/rails test` am Ende **grün**; Migrationen laufen; `bin/rails db:reset` sauber.

## Verifizieren

Nach Rückkehr **selbst** `bin/rails test` laufen lassen und Ausgabe prüfen. Rot → an den
`rails-developer` zurückgeben (Folge-Nachricht im selben Task) bis grün. Niemals einen
roten Stand dokumentieren oder committen.

## Dokumentieren (zwei Ebenen)

1. **Technisch — ADR finalisieren.** In `doc/adr/NNNN-<slug>.md` Status auf **Accepted**
   setzen. Wenn beim Bauen vom geplanten Ansatz abgewichen wurde: Entscheidung + Begründung
   im ADR nachtragen, statt sie verschwinden zu lassen.

2. **Produkt — für den Human-in-the-Loop.** Schreib `doc/product/<slug>.md` aus der Vorlage
   `.claude/skills/feature-build/templates/product-doc-template.md`: was das Feature für
   Nutzer:innen tut, wie man es bedient (Klick-Pfad), welche Regeln sichtbar werden (z. B.
   „voller Kurs → Warteliste"). Deutsch, ohne Code, für jemanden der die App *benutzt* und
   das Ergebnis abnimmt — nicht für Entwickler:innen.

## Committen (lokal, kein Push)

Erst bei grünen Tests: `git add -A` (Code + Plan + ADR + Produkt-Doc), ein sauberer Commit.
Deutscher Betreff mit Feature + getragener Demo; Body listet Kern-Tasks und nennt ADR-Nummer.
Footer:

```
Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
```

**Kein** `git push`, **kein** PR.

## Zusammenfassen

Melde: Branch, geänderte Dateien (Kurzliste), Test-Ergebnis (Zahlen), ADR-Status,
Produkt-Doc-Pfad, Commit-Hash. Nächste Stufe: `feature-review`.

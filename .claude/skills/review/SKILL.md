---
name: review
description: Reviewt einen Diff/Branch/PR der Kursverwaltung gegen die vanilla-Rails-Konventionen dieses Projekts. Nutze dies bei "review den Diff", "prüf die Änderungen", "review den PR", "schau dir den Branch an". Liefert konkrete, an dieses Projekt angelehnte Befunde (kein generisches Review).
---

# Review (Kursverwaltung)

Du reviewst Änderungen gegen die **verbindlichen Konventionen dieser App** (siehe `CLAUDE.md`).
Du änderst **keinen** Code — du meldest Befunde. Sei konkret: jede Anmerkung nennt Datei,
Zeile und die verletzte Regel. Stil-Referenz ist der `vanilla-rails`-Skill.

## Diff holen

1. Branch gegen `main`: `git diff main...HEAD` (oder `git diff` für ungestagte Änderungen).
2. Geänderte Dateien überblicken, dann je Datei prüfen.

## Checkliste (an dieses Projekt angelehnt)

**Architektur / vanilla Rails**
- Controller schlank, nur die sieben Standard-Actions. **Kein** Service-Objekt, keine
  zusätzlichen Abstraktions-Gems, keine Architektur, die sonst nirgends vorkommt.
- Geschäftslogik in den **Modellen** (reiche Domänen-Methoden), nicht im Controller, nicht
  in Callbacks für fachliche Abläufe.

**Status-Felder**
- Status-/enum-artige Felder über das **`STATUSES`-Muster** (Konstante + `inclusion`-Validierung).
  → **Flagge jede Verwendung von `enum`**.
- In Views als `form.select :feld, Modell::STATUSES`.

**Strong Parameters**
- **`params.expect(...)`** (Rails-8-Stil). → **Flagge `params.require(...).permit(...)`**.

**Sprache**
- **Deutsche** UI-Texte (Labels, Flash-Notices, Buttons). → Flagge englische UI-Strings.
- **Englische** Bezeichner im Code (Modelle, Methoden, Variablen). → Flagge deutsche Bezeichner.

**Tests**
- Neue Logik/Actions haben **Minitest + Fixtures**-Tests (kein RSpec, kein FactoryBot).
- Assertions präzise: `assert_equal`, `assert_difference`, `assert_changes` statt nur
  `assert` / `assert_response :success` allein. Edge Cases als eigene Test-Fälle.

**Seeds**
- `db/seeds.rb` idempotent (`destroy_all` vorab), bleibt reproduzierbar.

**UI**
- Views folgen `doc/design/ui-style-guide.md`: Akzent **`violet-600`** (kein `blue-*`),
  runde Karten (`rounded-xl`), Pill-Badges, Status-Badge-Logik zentral im Helper, nur
  Tailwind-Skalen (keine eigenen Hex-Werte).

**Leitplanke (FEATURES.md)**
- Reich = mehr Substanz zum Navigieren, nicht mehr zum Erklären. Bei neuem Code fragen:
  *„Welche Demo trägt das?"* — keine Antwort → als Over-Engineering anmerken.

## Ausgabe

- Befunde nach Schweregrad gruppieren: **muss** (Konventionsverstoß), **sollte**, **nice-to-have**.
- Pro Befund: `datei:zeile` · Regel · konkreter Vorschlag.
- Wenn alles passt: das ausdrücklich bestätigen, keine Befunde erfinden.
- Hinweis: Manche Schwachstellen sind **absichtliche Demo-Grundlage** (N+1 in der
  Kursübersicht, PII im Export-Endpoint). Diese als „bewusst, nicht fixen" kennzeichnen,
  nicht als Fehler melden.

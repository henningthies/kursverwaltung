---
name: feature-build
description: >-
  Setzt ein geplantes Feature dieser App (kursverwaltung) TDD-first um — Tests
  VOR Code, Minitest + Fixtures, vanilla Rails / 37signals. Liest das ADR
  (doc/adr/NNNN-slug.md), PRD (doc/prd/slug.md) und die Mockups (mockups/slug-*.html)
  als verbindliche Spec, legt den Feature-Branch (feature/<slug>) an und
  implementiert Migration → Modell → Controller/Routes → Views, bis bin/rails test
  grün ist. Nimmt einen Slug (oder eine Feature-Beschreibung, aus der der Slug
  abgeleitet wird) entgegen. Nutzen, sobald jemand ein geplantes Feature bauen/
  implementieren will, sagt "bau Feature X", "implementier slug Y", "setz das PRD
  um", "leg den Feature-Branch an und fang an". Zweiter Schritt der Feature-Factory
  (feature-plan → feature-build → feature-review).
---

# Feature-Build (kursverwaltung)

Implementiert ein in `feature-plan` spezifiziertes Feature **strikt TDD-first**: erst
Tests aus den Akzeptanzkriterien + Edge-Cases, dann der minimale Code, der sie grün
macht. ADR/PRD/Mockup sind die **Spec** — nicht neu interpretieren, sondern umsetzen;
weicht die Realität ab, kurz rückfragen statt raten.

## Eingaben

- **Slug** (Pflicht) — z. B. `kursbewertungen`. Wird zu Branch + Spec-Pfaden aufgelöst.
- Wird statt eines Slugs nur eine **Beschreibung** genannt: passenden Slug ableiten und
  prüfen, ob `doc/adr/*-<slug>.md` / `doc/prd/<slug>.md` existieren. Fehlt die Spec,
  zuerst auf `feature-plan` verweisen (nicht ungeplant losbauen).

## Ablauf

### 1. Spec laden
- `doc/prd/<slug>.md` (Was + Akzeptanzkriterien + **Test-Edge-Cases** + Umsetzungsplan),
- `doc/adr/NNNN-<slug>.md` (Warum + Entscheidungen, inkl. Datenmodell/Bereich/Auth),
- `mockups/<slug>-*.html` (UI-Ziel) und `doc/design/ui-style-guide.md` (Tokens).
- `CLAUDE.md` für die verbindlichen Konventionen gegenwärtig halten.

### 2. Branch anlegen
Branch-Namens-Konvention des Projekts: **`feature/<slug>`** (z. B. `feature/kursbewertungen`).
```bash
git checkout -b feature/<slug>
```
Existiert der Branch schon, darauf wechseln und fortsetzen. Nicht direkt auf
`main`/`public-main` bauen.

### 3. Tests zuerst (TDD)
Aus den **Akzeptanzkriterien** und **Test-Edge-Cases** des PRD die Tests schreiben,
**bevor** Produktivcode entsteht:
- **Minitest + Fixtures** — kein RSpec, kein FactoryBot. Testdaten als Fixtures in
  `test/fixtures/*.yml` ergänzen (nicht inline erzeugen).
- Pro Edge-Case eine Assertion mit präziser Erwartung — leere Liste, voller Kurs →
  Warteliste, fehlende Berechtigung (`require_login`/`require_admin`), Validierungs-
  fehler, Geld-Rundung, Webhook-Idempotenz, je nach Feature.
- `auth_test_helper` für Login-Setups nutzen (Projekt-Konvention).
- Tests laufen lassen — sie **müssen zunächst rot** sein (beweist, dass sie greifen):
  ```bash
  bin/rails test test/<pfad>      # neue Tests gezielt
  ```

### 4. Implementieren bis grün — vanilla Rails
In der Reihenfolge des Umsetzungsplans, mit dem **kleinsten** Code je Test:
- **Migration/Modell zuerst** — Logik gehört ins **Modell**, nicht in Service-/Form-/
  Query-Objekte. Status/Rollen über `STATUSES`/`ROLES`-Konstante + `inclusion`,
  **nie `enum`**. Geld als Integer-`*_cents`.
- **Schlanke Controller** — Standard-CRUD-Actions, Strong Params via `params.expect(...)`
  (nicht `require.permit`), `role` **nie** massenzuweisbar. Lernenden- vs. Admin-Bereich
  trennen, passende Gates setzen.
- **Views** nach Mockup + `ui-style-guide.md` — violet-Akzent, runde Karten, Pill-Badges,
  **kein Blau**. **Deutsche** UI-Texte (Notices/Buttons/Labels), **englische** Code-Bezeichner.
- **Seeds** bei Bedarf erweitern — idempotent (`destroy_all` vorab, Kinder vor Eltern).
- Nach jeder Einheit Tests laufen lassen, bis die ganze Suite grün ist:
  ```bash
  bin/rails test
  ```

### 5. Selbst-Gegencheck
Vor der Übergabe an `feature-review`:
- **Alle Akzeptanzkriterien** des PRD abgehakt? Jeder Edge-Case getestet?
- `bin/rails test` vollständig grün.
- Keine bewussten **Demo-Schwachstellen** „mitrepariert" (N+1 in Übersicht/Katalog/
  Dashboard, PII-Export `GET /courses/:id/participants`) — die bleiben absichtlich drin.

## Schluss-Ausgabe
Knapp halten:
```
## Feature gebaut — <slug>  (Branch feature/<slug>)

Tests: <N> neu · bin/rails test grün ✅
Geänderte/neue Dateien:
- <Modell/Migration/Controller/Views/Tests …>

Akzeptanzkriterien aus PRD: <alle erfüllt | offen: …>
Nächster Schritt: `feature-review <slug>` (Konventionen + Tests + verifiziert → PR).
```

Keine Einleitung, kein Code-Dump. Wenn die Spec an einer Stelle nicht aufgeht, das
**vor** dem Weiterbauen melden — nicht stillschweigend abweichen.

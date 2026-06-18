---
name: feature-plan
description: >-
  Plant ein Feature für diese App (kursverwaltung) von Grund auf: vergibt einen
  Feature-Slug, erstellt ein nummeriertes ADR (doc/adr/NNNN-slug.md), ein PRD
  (doc/prd/slug.md), statische HTML-Mockups (mockups/slug-*.html im Tailwind-CDN-
  Stil) und einen Umsetzungsplan inkl. Test-Edge-Cases. Vorher wird der User
  relentless im grill-me-Stil interviewt — eine Frage nach der anderen, mit
  empfohlener Antwort — bis JEDE offene Entscheidung getroffen ist; ein
  Screenshot/Bild kann als visuelle Referenz mitgegeben werden. Nutzen, sobald
  jemand ein neues Feature planen/konzipieren/durchdenken will, ein ADR/PRD/
  Mockup braucht, oder sagt "plane Feature X", "lass uns Feature Y durchdenken",
  "konzipier mir …", "ich will ein Feature grillen". Erster Schritt der Feature-
  Factory (feature-plan → feature-build → feature-review).
---

# Feature-Plan (kursverwaltung)

Verwandelt eine Feature-Idee in eine **umsetzungsreife Spec**: ein ADR (das *Warum* +
die getroffenen Entscheidungen), ein PRD (das *Was* + Akzeptanzkriterien), HTML-Mockups
(das *Wie es aussieht*) und einen Umsetzungsplan mit Test-Edge-Cases. Davor steht ein
**relentless Interview** im `grill-me`-Stil: erst wenn jede offene Entscheidung geklärt
ist, werden Artefakte geschrieben.

Ziel ist eine Spec, die `feature-build` ohne Rückfragen umsetzen kann. Keine offenen
„TBD"-Stellen in den Artefakten — was offen ist, wird im Interview geklärt, nicht in die
Dokumente verschoben.

## Eingaben

- **Feature-Beschreibung** (Pflicht) — die Idee in einem Satz oder Absatz.
- **Slug** (optional) — wenn der User keinen nennt, einen kebab-case-Slug aus dem Kern
  des Features ableiten (z. B. „Kurs-Bewertungen mit Sternen" → `kursbewertungen`).
  Slug bestätigen lassen, bevor Dateien angelegt werden.
- **Screenshot/Bild** (optional) — eine mitgegebene Datei oder URL als **visuelle
  Referenz**. Per `Read` (Bild) ansehen bzw. die `screenshot`-Skill nutzen und die
  abgelesenen Layout-/Komponenten-Entscheidungen ins Mockup übernehmen.

## Ablauf

### 1. Kontext lesen (bevor gefragt wird)
Erst den Boden verstehen, damit das Interview keine Fragen stellt, die der Code schon
beantwortet:
- `CLAUDE.md` (Konventionen, Domäne), `FEATURES.md` (Feature-Landkarte),
  `doc/design/ui-style-guide.md` (UI-Tokens), `mockups/README.md` (Mockup-Stil).
- Verwandte bestehende Modelle/Controller/Views per `rg`/`Glob` — was ist schon da,
  was wird erweitert vs. neu gebaut?
- Bestehende ADRs in `doc/adr/` (Nummernkreis + Format) und PRDs in `doc/prd/`.

### 2. Grillen bis entschieden (grill-me-Loop)
Interviewe den User **relentless, eine Frage nach der anderen**, und arbeite den
Entscheidungsbaum Ast für Ast ab — Abhängigkeiten zwischen Entscheidungen zuerst.
**Regeln (wie `grill-me`):**
- **Eine Frage pro Runde.** Zu jeder Frage eine **empfohlene Antwort** mitgeben
  (mit kurzer Begründung), damit der User nur bestätigen oder korrigieren muss.
- Lässt sich eine Frage durch den **Code beantworten**, den Code prüfen statt fragen.
- Nicht aufhören, solange ein Ast offen ist. Erst wenn **alle** Entscheidungen
  getroffen sind, in Schritt 3 übergehen. Bei Bedarf kurz den offenen Restbaum nennen.
- Für Auswahl-Entscheidungen die `AskUserQuestion`-Frageform nutzen, wenn sie das
  Bestätigen erleichtert; sonst normale Prosa-Fragen.

**Pflicht-Äste, die geklärt sein müssen:**
- **Scope & Nicht-Scope** — was gehört rein, was bewusst nicht (MVP-Schnitt).
- **Datenmodell** — neue Modelle/Spalten/Beziehungen? Migrationen? `STATUSES`/`ROLES`-
  Konstanten statt `enum`. Geld als `*_cents`.
- **Bereich & Auth** — Lernenden/öffentlich (`CatalogController` & Co.) vs. Admin
  (`require_admin`)? Welche Gates?
- **UI/Flows** — welche Screens, welche Zustände (leer / voll / Fehler / Warteliste),
  Einstieg von wo? Stil nach `ui-style-guide.md` (violet, runde Karten, kein Blau).
- **Logik-Ort** — was gehört ins Modell (vanilla Rails, keine Service-Objekte)?
- **Edge-Cases & Risiken** — Kapazität/Warteliste, leere Listen, Berechtigung,
  Idempotenz, Geld-Rundung — was kann schiefgehen?
- **Test-Strategie** — welche Modell-/Controller-/Integrationstests, welche Fixtures.

### 3. Slug fixieren & Nummer ziehen
- Slug final bestätigen (kebab-case, englisch, knapp).
- Nächste ADR-Nummer ermitteln: höchste vorhandene `doc/adr/NNNN-*.md` + 1,
  vierstellig null-gepaddet (erste ADR → `0001`).

### 4. Artefakte schreiben
Alle vier erzeugen — **nicht aus dem Kopf, sondern aus den Vorlagen in `templates/`**
dieser Skill: Vorlage lesen, Platzhalter (`<…>`, `NNNN`, Kommentare) durch die
Interview-Ergebnisse ersetzen, an den Zielort schreiben.
1. **ADR** → `doc/adr/NNNN-<slug>.md` (Vorlage `templates/adr.md`) — die Entscheidungen
   aus dem Interview, `NNNN` aus Schritt 3, Datum = heutiges Datum.
2. **PRD** → `doc/prd/<slug>.md` (Vorlage `templates/prd.md`) — Was + Akzeptanzkriterien
   + Test-Edge-Cases + Umsetzungsplan (TDD-first; kein eigenes File).
3. **Mockups** → `mockups/<slug>-<screen>.html` (Vorlage `templates/mockup.html`) — je
   relevantem Screen eine Datei; Header/Komponenten aus den bestehenden `mockups/*.html`
   ziehen, bei mehreren Screens untereinander verlinken. Liegt ein Referenz-Screenshot
   vor, dessen Layout übernehmen. Stil verbindlich nach `doc/design/ui-style-guide.md`.

### 5. Übergabe melden
Knapp ausgeben, welche Dateien entstanden sind und wie es weitergeht (siehe Schluss).

## Vorlagen

Die Artefakt-Formate liegen **als Dateien** in `templates/` neben dieser Skill — nicht
inline hier, damit Skill und Format getrennt pflegbar sind:

| Artefakt | Vorlage | Zielort |
|----------|---------|---------|
| ADR | `templates/adr.md` | `doc/adr/NNNN-<slug>.md` |
| PRD (+ Umsetzungsplan) | `templates/prd.md` | `doc/prd/<slug>.md` |
| Mockup (je Screen) | `templates/mockup.html` | `mockups/<slug>-<screen>.html` |

Vor dem Schreiben die jeweilige Vorlage lesen und die Platzhalter füllen. Passt eine
Vorlage strukturell nicht zum Feature, anpassen — aber Stil-/Format-Konventionen wahren.

## Schluss-Ausgabe
Kurz, ohne Fließtext-Gutachten:
```
## Feature geplant — <slug>

Entscheidungen geklärt: <N>. Artefakte:
- doc/adr/NNNN-<slug>.md
- doc/prd/<slug>.md
- mockups/<slug>-<screen>.html (· weitere)

Nächster Schritt: `feature-build <slug>` (liest ADR/PRD/Mockup als Spec, TDD-first).
```

Halte das Interview straff und die Artefakte konkret. Keine offenen „TBD" in ADR/PRD —
ungeklärtes wird gefragt, nicht dokumentiert.

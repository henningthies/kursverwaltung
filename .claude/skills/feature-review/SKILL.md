---
name: feature-review
description: >-
  Abschluss-Check für ein fertig gebautes Feature dieser App (kursverwaltung),
  analog zu kr, aber umfassender: prüft (1) Projekt-Konventionen (vanilla Rails /
  37signals, STATUSES/ROLES statt enum, params.expect, deutsche UI / englische
  Bezeichner, Minitest + Fixtures), (2) bin/rails test grün, (3) Feature complete
  gegen die Akzeptanzkriterien des PRD und (4) im laufenden Server verifiziert —
  und gibt eine knappe, nach Schweregrad sortierte Befund-Liste aus. Bei sauberem
  Befund wird automatisch ein Pull Request (gh) erstellt. Nimmt einen Slug entgegen.
  Nutzen, sobald jemand ein Feature abschließen/freigeben will, sagt "review Feature
  X", "ist slug Y fertig?", "Abschluss-Check", "kann das in den PR?", "schließ das
  Feature ab". Dritter und letzter Schritt der Feature-Factory (feature-plan →
  feature-build → feature-review).
---

# Feature-Review (kursverwaltung)

Der **Gate vor dem PR**: prüft ein gebautes Feature gegen vier Tore und gibt — wie `kr` —
eine **knappe, nach Schweregrad sortierte Befund-Liste** mit `Datei:Zeile` aus. Sind alle
Tore grün, wird automatisch ein Pull Request erstellt. Kein Fließtext-Gutachten.

Geltungsbereich sind die Änderungen des Feature-Branches (`feature/<slug>` gegen `main`).
Bewusste Demo-Schwachstellen werden **nie** als Befund gemeldet (siehe unten).

## Eingaben

- **Slug** (Pflicht) — z. B. `kursbewertungen`. Löst Branch (`feature/<slug>`) und Spec
  (`doc/adr/*-<slug>.md`, `doc/prd/<slug>.md`) auf. Ohne Slug den aktuellen Branch nehmen.

## Ablauf

### 0. Umfang bestimmen
```bash
git branch --show-current                       # sollte feature/<slug> sein
git diff --name-only main...HEAD                 # geänderte Dateien des Features
git diff main...HEAD -- <datei>                  # konkrete Zeilen
```
PRD/ADR des Slugs laden — die **Akzeptanzkriterien** sind das Maß für „complete".
Nur die Feature-Änderungen bewerten; Zeilennummern aus dem aktuellen Dateistand.

### Tor 1 — Konventionen (wie kr)
Geänderten Code gegen die `CLAUDE.md`-Konventionen prüfen. **Direkt die `kr`-Skill
aufrufen** statt die Regeln zu duplizieren; deren Befunde in die Liste unten übernehmen.
Kurz-Erinnerung an die Regeln (Default-Schweregrad in Klammern):
- **Vanilla Rails / 37signals** — keine Service-/Form-/Query-Objekte, Logik im Modell,
  schlanke Controller, keine neuen Abstraktions-Gems (**muss** bei Architektur-Bruch).
- **`STATUSES`/`ROLES`-Konstante + `inclusion` statt `enum`** (**muss**).
- **`params.expect(...)`** statt `require.permit`; **`role` nie massenzuweisbar** (**muss**).
- **Deutsche UI-Texte / englische Code-Bezeichner** (UI **sollte**, Bezeichner **muss**).
- **Minitest + Fixtures** — kein RSpec/FactoryBot (**muss**); neue Logik ohne Test (**sollte**).
- Geld als `*_cents`; Seeds idempotent; Views nach `ui-style-guide.md` (**sollte**, sofern berührt).

### Tor 2 — Tests grün
```bash
bin/rails test
```
Muss vollständig grün sein. Rote/übersprungene Tests oder fehlende Tests für neue
Akzeptanzkriterien → **muss**-Befund. Knapp die relevante Fehlausgabe zitieren.

### Tor 3 — Feature complete (gegen PRD)
Jedes **Akzeptanzkriterium** aus `doc/prd/<slug>.md` gegen den Code prüfen: ist es
umgesetzt? Nicht erfülltes oder nur teilweise umgesetztes Kriterium → **muss**-Befund
mit Verweis auf das Kriterium. Scope-Abweichungen (zu viel/zu wenig gebaut) nennen.

### Tor 4 — Verifiziert im laufenden Server
Das Feature im laufenden `bin/dev` (`http://localhost:3000`) per Playwright ansteuern
und das **erwartete Verhalten** aus den User Flows des PRD beobachten (Demo-Logins:
`admin@example.com` / `lena@example.com`, Passwort `geheim123`). Läuft der Server nicht,
kurz melden und um Start bitten statt zu raten. Abweichung Soll/Ist → **muss**-Befund.
Für die PR-Beschreibung optional einen Screenshot des fertigen Features aufnehmen
(`screenshot`-Skill).

## Report-Format

Genau diese Struktur, kurz halten. Befunde nach Schweregrad gruppiert (muss → sollte →
optional), je Befund **eine Zeile**: `Datei:Zeile` (oder Tor) + Kurzname + was zu tun ist.

```
## Feature-Review — <slug> — <N> Befunde (X muss · Y sollte · Z optional)

Tore: Konventionen <✅/✗> · Tests <✅/✗> · Complete <✅/✗> · Verifiziert <✅/✗>

### muss
- `app/models/review.rb:14` — enum statt STATUSES: auf Konstante + `inclusion` umstellen.
- Tor 3 (complete) — Akzeptanzkriterium „Lernende sehen Ø-Bewertung" fehlt in der Detail-View.

### sollte
- `app/controllers/reviews_controller.rb:8` — englischer Flash "Saved": auf deutsch.

### optional
- …

Übersprungen (bewusste Demo-Schwachstellen): <falls berührt: N+1 / PII-Export>.
```

### Bei sauberem Abschluss → Pull Request
Sind **alle vier Tore grün und keine `muss`-Befunde** offen, automatisch einen PR erstellen:
```bash
git push -u origin feature/<slug>
gh pr create --base main --head feature/<slug> \
  --title "<Feature-Titel>" \
  --body "<siehe Vorlage>"
```
PR-Body-Vorlage (deutsch, knapp):
```
## <Feature-Titel>

<1–2 Sätze: was das Feature tut.>

**Spec:** doc/adr/NNNN-<slug>.md · doc/prd/<slug>.md · mockups/<slug>-*.html

### Erfüllte Akzeptanzkriterien
- [x] …

### Tests
bin/rails test grün (<N> neu).

### Verifiziert
<Kurz: im Server geprüft. Screenshot anhängen, falls aufgenommen.>
```
PR-Body endet mit:
```
🤖 Generated with [Claude Code](https://claude.com/claude-code)
```
Nach dem Anlegen die **PR-URL** ausgeben.

**Gibt es offene `muss`-Befunde**, keinen PR erstellen — stattdessen die Befund-Liste
ausgeben und auf `feature-build` zum Nachbessern verweisen.

Halte dich kurz: keine Einleitung, kein Code-Dump, keine Lob-Absätze. Jede Befund-Zeile
muss ohne weiteren Kontext umsetzbar sein.

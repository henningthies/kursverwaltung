---
name: kr
description: >-
  Reviewt geänderten Rails-Code dieser App (kursverwaltung) gegen die
  verbindlichen Projekt-Konventionen aus CLAUDE.md: vanilla Rails / 37signals
  (keine Service-Objekte/Abstraktions-Gems), STATUSES/ROLES-Konstanten-Muster
  statt enum, params.expect statt require.permit (role nie massenzuweisbar),
  deutsche UI-Texte mit englischen Code-Bezeichnern, Minitest + Fixtures.
  Unbedingt nutzen, sobald jemand nach einem Konventions-Review, Style-Check,
  Self-Review oder PR-Review für Rails-Änderungen fragt — auch formuliert als
  "passt das zu unseren Konventionen?", "review meinen Code", "check vor dem
  Commit/Push", "ist das vanilla Rails?", oder vor einem Commit/PR. Greift auf
  geänderte/ungestagte Dateien (Diff) ebenso wie auf konkret genannte Dateien.
---

# Konventionen-Review (kursverwaltung)

Prüft Rails-Änderungen gegen die in `CLAUDE.md` festgelegten Projekt-Konventionen
und gibt eine **knappe**, nach Schweregrad sortierte Befund-Liste mit `Datei:Zeile` aus.

Das Ziel ist ein schneller Self-Review vor Commit/PR — kein Fließtext-Gutachten.
Die Konvention ist das Maß, nicht persönlicher Geschmack: melde nur, was wirklich
gegen eine dokumentierte Regel verstößt oder sie gefährdet.

## Ablauf

0. **Demo (Hello World).** 
<diff>
    !`.claude/skills/kr/scripts/hello_world.sh`
</diff>


1. **Umfang bestimmen.** Standard ist der Diff der noch nicht committeten Änderungen:
   ```bash
   git diff --name-only HEAD            # geänderte Dateien
   git diff HEAD -- <datei>             # konkrete Änderungen mit Zeilen
   ```
   Nennt der User konkrete Dateien/einen Branch/Commit-Range, prüfe genau die.
   **Nur geänderte Zeilen bewerten** — bestehender Code drumherum ist nicht Gegenstand
   des Reviews (außer eine Änderung verschärft dort ein Problem). Zeilennummern aus dem
   aktuellen Dateistand nehmen, damit `Datei:Zeile` anklickbar stimmt.

2. **Gegen die Checkliste prüfen** (siehe unten). Bei Unsicherheit, ob ein Muster
   etabliert ist, kurz im Code gegenprüfen (`rg` nach Vergleichsstellen), statt zu raten.

3. **Knapp ausgeben** im Report-Format unten.

## Checkliste

Jede Regel hat einen Default-Schweregrad. **muss** = klarer Konventionsbruch;
**sollte** = Abweichung, die man fast immer beheben will; **optional** = Hinweis/Geschmack.
Schweregrad im Einzelfall hochstufen, wenn der Verstoß echten Schaden anrichtet
(z. B. `role` massenzuweisbar = Sicherheitsproblem → **muss**).

### 1. Vanilla Rails / 37signals (**muss** bei Architektur-Bruch)
- **Keine Service-Objekte, Form-Objekte, Interactors, Query-Objekte** oder Abstraktions-Gems.
  Geschäftslogik gehört ins **Modell**, nicht in `app/services/`, `app/forms/`, `app/lib/`-Logikklassen.
- **Schlanke Controller**: Standard-CRUD-Actions, keine fette Orchestrierung im Controller.
  Logik, die mehr als HTTP-Glue ist, ins Modell verschieben.
- Kein Einführen neuer Dependencies/Gems für etwas, das vanilla Rails kann.

### 2. STATUSES/ROLES-Konstante statt enum (**muss**)
- Status/Rollen über das **Konstanten-Muster** mit `inclusion`-Validierung, **nie** `enum`:
  ```ruby
  STATUSES = %w[draft active done].freeze
  validates :status, inclusion: { in: STATUSES }
  ```
- Treffer auf `enum ` in Modellen → **muss**-Befund.

### 3. Strong Params: params.expect (**muss**; role-Leak **muss**)
- **`params.expect(...)`** verwenden, **nicht** `params.require(...).permit(...)`.
- **`role` (User) niemals** in den permittten Params — nicht massenzuweisbar. Falls doch → **muss** (Security).

### 4. Sprache: deutsche UI / englische Bezeichner (**sollte**; im Code-Bezeichner **muss**)
- **Sichtbare UI-Texte deutsch**: Flash-`notice`/`alert`, Button-/Label-Texte, Validierungs-Messages
  in Views und Controllern. Englische User-facing-Strings → **sollte**.
- **Code-Bezeichner englisch**: Klassen-, Methoden-, Variablen-, Spaltennamen. Deutsche Bezeichner
  (z. B. `def anmelden`, `kurs_liste`) → **muss** (bricht die Code-Sprache des Projekts).
- Kommentare dürfen deutsch sein (Projekt-Konvention) — kein Befund.

### 5. Minitest + Fixtures (**muss** bei RSpec/FactoryBot; **sollte** bei fehlendem Test)
- Tests in **Minitest**, Testdaten über **Fixtures** (`test/fixtures/*.yml`).
  RSpec (`describe`/`it`/`expect(...)`) oder FactoryBot (`create(:...)`, `build(:...)`) → **muss**.
- Neue Logik/Action **ohne Test** → **sollte** (Projekt-Konvention: TDD, mit dem Test anfangen).

### 6. Weitere dokumentierte Konventionen (**sollte**, sofern berührt)
- **Geld als Integer-`*_cents`** (Helper `price_display`), keine Floats für Beträge.
- **Seeds idempotent** (`destroy_all` vorab, Kinder vor Eltern) — bei Änderungen an `db/seeds.rb`.
- **Views nach `doc/design/ui-style-guide.md`**: violet-Akzent, runde Karten, Pill-Badges, **kein Blau**.

### Nicht melden (bewusst so gewollt)
Diese sind **absichtliche Demo-Schwachstellen** — niemals als Befund ausgeben:
- **N+1** in Kursübersicht/Katalog/Admin-Dashboard (Performance-Demo).
- **PII-Export** `GET /courses/:id/participants` in `CoursesController#participants` (Security-Demo).

## Report-Format

Immer genau diese Struktur, kurz halten. Befunde nach Schweregrad gruppiert
(muss → sollte → optional), innerhalb der Gruppe nach Datei. Pro Befund **eine Zeile**:
`Datei:Zeile` + Regel-Kurzname + was zu tun ist.

```
## Konventions-Review — <N> Befunde (X muss · Y sollte · Z optional)

### muss
- `app/models/order.rb:14` — enum statt STATUSES: `enum status:` → `STATUSES`-Konstante + `inclusion`.
- `app/controllers/registrations_controller.rb:22` — params.require/permit + `role` leakt: auf `params.expect(user: [...])` ohne `:role` umstellen.

### sollte
- `app/controllers/carts_controller.rb:8` — englischer Flash-Text "Added to cart": auf deutsch ("In den Warenkorb gelegt").

### optional
- `app/models/course.rb:30` — Logik im Controller wäre hier knapper als Modell-Methode (Geschmack).

Keine Befunde zu: <falls relevant: bewusste Demo-Schwachstellen übersprungen>.
```

Wenn alles sauber ist:
```
## Konventions-Review — keine Befunde ✅
<M> geänderte Dateien gegen die Konventionen geprüft, nichts zu beanstanden.
```

Halte dich kurz: keine Einleitung, keine Wiederholung des Codes, keine Lob-Absätze.
Jede Befund-Zeile muss ohne weiteren Kontext umsetzbar sein.

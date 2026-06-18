# 0007 — Kurs-Bewertungen mit Sternen

- **Status:** Accepted
- **Datum:** 2026-06-16
- **Slug:** course-reviews

## Kontext

Die Kurs-Detailseite (`CatalogController#show`) zeigt bisher zwei **hartkodierte
Testimonials** (`app/views/catalog/_testimonials.html.erb`, bewusst modellos). Es gibt keine
Möglichkeit für Lernende, einen Kurs selbst zu bewerten, und keine Kennzahl, die Kaufinteressierten
soziale Bewährtheit signalisiert. Vorbild ist das im Screenshot gezeigte „End-of-Term Review"-Modal
(Sterne, optionaler Kommentar, Anonym-/Öffentlich-Schalter).

Berührter Bestand: Kurs-Detailseite und ihre Partials (`catalog/show`, `_testimonials`), die
Marketplace-Karten (`catalog/index`), die Admin-Kurs-Detailseite (`CoursesController#show`), das
Auth-Concern (`current_user`, `require_login`, `require_admin`) und das Datenmodell (`User`, `Course`).

## Entscheidung

Ein neues Modell **`Review`** trägt Bewertungen **auf Kurs-Ebene** (nicht je Session).

**Datenmodell** — neue Tabelle `reviews`:

| Spalte | Typ | Regeln |
|--------|-----|--------|
| `user_id` | references, `null: false` | Autor; **nie massenzuweisbar** (aus `current_user`) |
| `course_id` | references, `null: false` | bewerteter Kurs |
| `rating` | integer, `null: false` | 1–5 (Pflicht) |
| `comment` | text | optionaler Freitext |
| `anonymous` | boolean, `null: false`, default `false` | öffentliche Anzeige ohne Klarnamen |
| `visible` | boolean, `null: false`, default `true` | „öffentlich anzeigen" — `false` = nur Admin |
| timestamps | | |

- **Unique-Index** `[user_id, course_id]` → genau **eine Bewertung pro Person pro Kurs**.
- Index auf `[course_id, visible]` für die Listen-/Durchschnitts-Abfragen.
- Kein `enum`/keine STATUSES-Konstante nötig — `rating` ist eine reine Zahl, `anonymous`/`visible`
  sind Booleans. Spaltenname `visible` statt `public` (kein Konflikt mit Ruby-`public`).

**Logik im Modell** (vanilla Rails, keine Service-Objekte):
- `Review`: `belongs_to :user, :course`; `validates :rating, presence + inclusion: 1..5`;
  `validates :user_id, uniqueness: { scope: :course_id }` (deutsche Meldung „bereits bewertet");
  `scope :visible, -> { where(visible: true) }`; Anzeige-Name `display_name` → `"Anonym"` bei
  `anonymous?`, sonst `user.name`.
- `Course`: `has_many :reviews, dependent: :destroy`; `average_rating` (nur sichtbare,
  `reviews.visible.average(:rating)`), `reviews_count` (nur sichtbare), `reviewed_by?(user)`.

**Bereich & Auth:**
- **Abgeben:** jede:r **eingeloggte** Nutzer:in (`require_login`) — **keine** Enrollment-Prüfung.
  (Bewusst einfach gehalten; das „End-of-Term"-Framing ist Deko, kein Gate.)
- **Moderieren/Lesen privater Bewertungen:** **Admin** (`require_admin`).
- `role`/`user`/`course` nie über Strong Params; `params.expect(review: [:rating, :comment,
  :anonymous, :visible])`.

**Controller & Routen** — neuer `ReviewsController`, nested unter `resources :courses`:
- `create` (before_action `require_login`): baut Review für `current_user` am
  `Course.published.find(params[:course_id])`; Erfolg → Redirect zur Detailseite mit Notice,
  Fehler → Redirect zurück mit Alert.
- `destroy` (before_action `require_admin`): löscht eine Bewertung des Kurses → Redirect zur
  Admin-Kurs-Detailseite mit Notice.
- Routen: `resources :reviews, only: %i[create destroy]` innerhalb des bestehenden
  `resources :courses`-Blocks.

**UI/Flows:**
- **Detailseite (öffentlich):** Die hartkodierte Testimonials-Sektion wird **ersetzt** durch eine
  echte Bewertungs-Sektion: ⭐-Durchschnitt + „N Bewertungen" im Kopf, Liste der **sichtbaren**
  Bewertungen (anonyme als „Anonym"), Leerzustand „Noch keine Bewertungen". Für eingeloggte
  Nutzer:innen ein Button **„Kurs bewerten"**, der ein **Modal** öffnet (Stimulus + `<dialog>`):
  Sterne-Eingabe (Stimulus), Kommentar-Textarea, Checkboxen „Ich möchte anonym bewerten" und
  „Meine Bewertung öffentlich anzeigen" (letztere **vorausgewählt**). Wer den Kurs bereits bewertet
  hat, sieht statt des Buttons den Hinweis „Du hast diesen Kurs bereits bewertet" (keine Bearbeitung).
- **Marketplace-Karten (`catalog/index`):** zeigen ⭐-Durchschnitt + Anzahl, sofern öffentliche
  Bewertungen existieren; sonst kein Rating.
- **Admin-Kurs-Detailseite (`CoursesController#show`):** Sektion mit **allen** Bewertungen des
  Kurses (öffentlich **und** privat, mit Klarnamen) und einem **Löschen**-Button pro Bewertung.
- Stil nach `doc/design/ui-style-guide.md`: violet-Akzent, `rounded-xl`-Karten, Pill-Badges,
  Sterne in `amber-400`, kein Blau. Sterne-Helper zentral (`star_rating`), nicht inline je View.

## Alternativen (verworfen)

- **Bewertung je Session/Termin** — verworfen: Sessions haben kein Done-Konzept, Aggregation je
  Termin = mehr Komplexität ohne Demo-Mehrwert.
- **Gate auf bestätigte Teilnehmer:innen abgeschlossener Kurse** — verworfen zugunsten der
  einfachsten Variante (nur Login); bewusst gewählt, obwohl das „End-of-Term"-Copy mehr suggeriert.
- **Bearbeitbare Bewertung** — verworfen: genau eine, **nicht** änderbar (einfacher, klare
  Test-Edge-Cases).
- **Private Bewertungen zählen in den öffentlichen Durchschnitt** — verworfen: Durchschnitt würde
  nicht zur sichtbaren Liste passen. Nur sichtbare zählen.
- **Eigener `/admin/reviews`-Bereich** — verworfen (Scope): Moderation läuft über die bestehende
  Admin-Kurs-Detailseite.
- **Spaltenname `public`** — verworfen wegen Kollision mit Ruby-Sichtbarkeitsmethode; `visible`.

## Konsequenzen

- **Migration** `create_reviews` (FK auf users/courses, Unique-Index user+course, Index course+visible).
- `_testimonials.html.erb` entfällt; bestehende Tests/Asserts auf „Was Teilnehmer sagen" werden auf
  die neue Sektion umgestellt. **FAQ bleibt hartkodiert.**
- Neue Stimulus-Controller (`rating` für Sterne-Eingabe, kleiner `dialog`/Modal-Controller).
- **N+1-Hinweis:** Durchschnitt/Anzahl auf den Marketplace-Karten über eine gruppierte Abfrage
  (`Review.visible.group(:course_id).average(:rating)` / `.count`) berechnen, **kein** neues N+1
  einführen (die bewussten N+1-Demos bleiben unberührt).
- Bewusste Nicht-Ziele: keine Bearbeitung, keine Antwort/Reply durch Trainer, keine Foto-Avatare,
  keine Sortier-/Filter-Optionen der Bewertungsliste, keine Halbstern-Eingabe (Display darf runden).

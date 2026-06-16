# PRD — Kurs-Bewertungen mit Sternen

- **Slug:** course-reviews  ·  **ADR:** doc/adr/0007-course-reviews.md  ·  **Mockups:** mockups/course-reviews-*.html

## Ziel & Nutzer

Eingeloggte Lernende sollen einen Kurs mit **1–5 Sternen** und optionalem Kommentar bewerten und
entscheiden, ob die Bewertung **anonym** und/oder **öffentlich** erscheint. Kaufinteressierte sehen
auf der Detailseite und den Marketplace-Karten einen **⭐-Durchschnitt + Anzahl** sowie die
öffentlichen Bewertungen (statt der bisher hartkodierten Testimonials). Admins können alle
Bewertungen (auch private, mit Klarnamen) je Kurs einsehen und moderieren (löschen).

## Scope / Nicht-Scope

- **Drin:**
  - `Review`-Modell (Kurs-Ebene), Migration, Validierungen, Modell-Logik.
  - Öffentliche Detailseite: ⭐-Schnitt + Anzahl im Kopf, sichtbare Bewertungsliste mit Leerzustand,
    „Kurs bewerten"-Button (nur eingeloggt) → Modal mit Sterne-Eingabe, Kommentar, Anonym-/Öffentlich-Checkbox.
  - Marketplace-Karten: ⭐-Schnitt + Anzahl, sofern öffentliche Bewertungen existieren.
  - Admin-Kurs-Detailseite: alle Bewertungen (öffentlich + privat, Klarnamen) + Löschen.
  - Ersetzen des hartkodierten `_testimonials`-Partials.
  - Sterne-Helper, Stimulus-Controller (Sterne-Eingabe + Modal).
- **Bewusst nicht:** Bewertung je Session; Enrollment-/Done-Gate; Bearbeiten einer Bewertung;
  Trainer-Antworten; Avatare/Fotos; Sortier-/Filter-Optionen; Halbstern-**Eingabe**;
  eigener `/admin/reviews`-Bereich. FAQ bleibt hartkodiert.

## User Flows

**1. Bewerten (eingeloggt, noch nicht bewertet)**
1. Nutzer:in öffnet `/kurse/:id` → in der Bewertungs-Sektion erscheint Button **„Kurs bewerten"**.
2. Klick öffnet das Modal („End-of-Term Review"): Sterne (Pflicht), Kommentar (optional),
   ☐ „Ich möchte anonym bewerten", ☑ „Meine Bewertung öffentlich anzeigen" (vorausgewählt).
3. „Bewertung absenden" → `POST /courses/:course_id/reviews`. Erfolg → zurück zur Detailseite,
   Notice „Danke für deine Bewertung!". Die Sektion zeigt jetzt statt des Buttons „Du hast diesen
   Kurs bereits bewertet". Öffentliche Bewertung erscheint in der Liste / fließt in den Schnitt.
4. „Vielleicht später" schließt das Modal ohne Speichern.

**2. Lesen (Gast oder eingeloggt)**
- Detailseite zeigt ⭐-Schnitt + „N Bewertungen" und die Liste der **sichtbaren** Bewertungen
  (anonyme als „Anonym"). Gäste sehen **keinen** „Kurs bewerten"-Button.
- **Leerzustand:** keine sichtbaren Bewertungen → „Noch keine Bewertungen — sei die:der Erste."
  (kein Schnitt im Kopf).

**3. Moderieren (Admin)**
- Admin-Kurs-Detailseite (`/courses/:id`) zeigt eine Sektion „Bewertungen" mit **allen**
  Bewertungen (öffentlich + privat, Klarnamen, Privat-Pill). „Löschen" pro Eintrag →
  `DELETE /courses/:course_id/reviews/:id` → Notice, Eintrag verschwindet.

## Datenmodell

Neue Tabelle `reviews` (siehe ADR 0007 für die Spalten-Tabelle):
`user_id` (fk, not null), `course_id` (fk, not null), `rating` (int, not null), `comment` (text),
`anonymous` (bool, not null, default false), `visible` (bool, not null, default true), timestamps.
Unique-Index `[user_id, course_id]`; Index `[course_id, visible]`.

- `Review`: `belongs_to :user, :course`; `validates :rating, presence: true, inclusion: { in: 1..5 }`;
  `validates :user_id, uniqueness: { scope: :course_id, message: "hat diesen Kurs bereits bewertet" }`;
  `scope :visible, -> { where(visible: true) }`; `display_name` → `"Anonym"` bei `anonymous?`, sonst `user.name`.
- `Course`: `has_many :reviews, dependent: :destroy`; `average_rating` (= `reviews.visible.average(:rating)`,
  nil wenn keine), `reviews_count` (= `reviews.visible.count`), `reviewed_by?(user)`
  (= `user.present? && reviews.exists?(user_id: user.id)`).
- `User`: `has_many :reviews, dependent: :destroy`.
- Keine `role`-/`user`-/`course`-Massenzuweisung; `params.expect(review: [:rating, :comment, :anonymous, :visible])`.

## Akzeptanzkriterien

- [ ] Migration legt `reviews` mit Unique-Index `[user_id, course_id]` an; `bin/rails db:migrate` läuft sauber.
- [ ] `Review` validiert `rating` (Pflicht, 1–5) und Eindeutigkeit pro `user`+`course`.
- [ ] Eingeloggte:r Nutzer:in kann über das Modal eine Bewertung absenden (`POST .../reviews`).
- [ ] Ohne/with ungültigem `rating` wird **kein** Datensatz gespeichert (Validierungsfehler, Alert).
- [ ] Zweite Bewertung desselben Users für denselben Kurs wird verhindert; Sektion zeigt „bereits bewertet".
- [ ] `Course#average_rating`/`#reviews_count` berücksichtigen **nur** `visible: true`.
- [ ] Detailseite zeigt ⭐-Schnitt + Anzahl und die sichtbaren Bewertungen; anonyme als „Anonym".
- [ ] Private Bewertung (`visible: false`) erscheint **nicht** öffentlich, aber in der Admin-Liste.
- [ ] Gast sieht **keinen** „Kurs bewerten"-Button; eingeloggte:r ohne Bewertung sieht ihn.
- [ ] Leerzustand „Noch keine Bewertungen" bei null sichtbaren Bewertungen.
- [ ] Marketplace-Karte zeigt ⭐-Schnitt + Anzahl für Kurse mit öffentlichen Bewertungen, sonst nichts.
- [ ] Admin kann eine Bewertung löschen (`DELETE`), Nicht-Admin nicht (`require_admin`).
- [ ] Hartkodiertes `_testimonials`-Partial entfernt; betroffene Tests umgestellt.
- [ ] `bin/rails test` grün; `kr`-Review ohne Befunde; Playwright-Validierung + Screenshot.

## Test-Edge-Cases

| Fall | Erwartetes Verhalten |
|------|----------------------|
| `rating` fehlt | invalid, kein Record, Alert; Modal-Flow bleibt nutzbar |
| `rating` = 0 oder 6 | invalid (inclusion 1..5) |
| Gleiche:r User bewertet Kurs erneut | invalid (uniqueness), Sektion zeigt „bereits bewertet" |
| `visible: false` | nicht in Liste/Schnitt/Anzahl der Detailseite; sichtbar in Admin-Liste |
| `anonymous: true` | öffentliche Liste zeigt „Anonym", nicht `user.name` |
| Keine sichtbaren Bewertungen | Leerzustand-Text, kein ⭐-Schnitt im Kopf |
| Durchschnitt mehrerer Bewertungen | korrekt gemittelt (nur sichtbare), Anzeige gerundet (z. B. „4,7") |
| Gast (nicht eingeloggt) | sieht Liste/Schnitt, **kein** „Kurs bewerten"-Button; `create` → `require_login` |
| `create` für Draft-/nicht-published Kurs | `Course.published.find` → 404 (nur öffentliche Kurse bewertbar) |
| Admin `destroy` | Record weg, Redirect Admin-Kurs-Detail mit Notice |
| Nicht-Admin `destroy` | `require_admin` greift (Redirect/Block) |
| Marketplace-Karte ohne Bewertungen | kein Rating; keine N+1 (gruppierte Abfrage) |

**Fixtures** (`test/fixtures/reviews.yml`): mind. eine **öffentliche** Bewertung (`learner` →
`claude_code`, rating 5, visible true), eine **anonyme öffentliche** (z. B. anderer User → `claude_code`),
eine **private** (`visible: false`, für Admin-/Schnitt-Tests). Ggf. zweiten Lerner-User in
`users.yml` ergänzen, damit mehrere Bewertungen je Kurs ohne Unique-Konflikt möglich sind.

## Umsetzungsplan (TDD-first)

1. **Test zuerst:**
   - `test/models/review_test.rb` — rating-Pflicht/Range, Uniqueness user+course, `display_name`
     (anonym), `scope :visible`.
   - `test/models/course_test.rb` (Ergänzung) — `average_rating`/`reviews_count` nur sichtbar,
     `reviewed_by?`.
   - `test/controllers/reviews_controller_test.rb` — `create` eingeloggt (Erfolg + Validierungsfehler),
     `create` als Gast → `require_login`, `create` für Draft-Kurs → 404, Duplikat verhindert;
     `destroy` als Admin (Erfolg), als Nicht-Admin (geblockt).
   - `test/integration/...` (oder catalog-controller-Test) — Detailseite zeigt Schnitt/Liste/Leerzustand,
     Button nur eingeloggt; Admin-Kurs-Detail zeigt private Bewertung + Löschen.
   - `test/fixtures/reviews.yml` (+ ggf. zweiter User).
2. **Migration/Modell:** `create_reviews` (FK, Indizes); `Review`-Modell; `Course`/`User`-Assoziationen
   + `average_rating`/`reviews_count`/`reviewed_by?`/`display_name`.
3. **Controller/Routes:** `ReviewsController` (`create` require_login, `destroy` require_admin);
   `resources :reviews, only: %i[create destroy]` im `resources :courses`-Block; `params.expect`.
4. **Views:** (nach `mockups/course-reviews-*.html` + `ui-style-guide.md`)
   - `app/helpers/application_helper.rb`: `star_rating(value, count: nil)` (amber-400-Sterne, gerundet,
     optional Zahl + „N Bewertungen").
   - `catalog/show`: `_testimonials`-Render durch neue Bewertungs-Sektion ersetzen
     (`_reviews.html.erb` Liste/Leerzustand, `_review_form.html.erb` Modal); Schnitt im Kopf.
   - `catalog/index`: Sterne auf der Kurs-Karte (gruppierte Schnitt-/Count-Abfrage im Controller).
   - `courses/show` (Admin): Bewertungs-Sektion mit allen Reviews + Löschen-Button.
   - `_testimonials.html.erb` löschen.
   - Stimulus: `app/javascript/controllers/rating_controller.js` (Sterne-Eingabe → hidden field),
     `dialog_controller.js` (Modal öffnen/schließen via `<dialog>`).
5. **Review:** `feature-review course-reviews` (Tests grün, Konventionen, Akzeptanzkriterien,
   Playwright-Validierung, Screenshot, PR).

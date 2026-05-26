# Kapazität + Warteliste (feature/kapazitaet-warteliste)

## Trägt Demo

- **T3 `01-feature-zu-pr`** — das zentrale Feature-zu-PR mit TDD. Die Promotions-Logik
  (`enroll` → confirmed/waitlisted, `cancel` → Nachrücker) entsteht live, Test-first.
- **T3 `03-wenn-es-schiefgeht`** — die Promotions-Logik ist eine bewusst gewählte
  Stelle für Over-Engineering und Edge-Case-Fehler; korrekte, minimale Implementierung
  macht Abweichungen sichtbar.

## Domänen-Änderung

### Neue Modelle

| Modell | Tabelle | Kern-Felder |
|--------|---------|-------------|
| `Participant` | `participants` | `name:string NOT NULL`, `email:string NOT NULL UNIQUE` |
| `Enrollment` | `enrollments` | `course_id NOT NULL`, `participant_id NOT NULL`, `status:string NOT NULL DEFAULT confirmed`, UNIQUE(course_id, participant_id) |

### Änderungen an bestehenden Modellen

| Modell | Änderung |
|--------|----------|
| `Course` | + `capacity:integer` (nullable = unbegrenzt); `has_many :enrollments`, `has_many :participants, through: :enrollments` |

### Beziehungen (Zielzustand)

```
Course  →  has_many :sessions (besteht)
       →  has_many :enrollments, dependent: :destroy
       →  has_many :participants, through: :enrollments

Participant  →  has_many :enrollments, dependent: :destroy
             →  has_many :courses, through: :enrollments

Enrollment  →  belongs_to :course
            →  belongs_to :participant
```

### Domain-Methoden (logic in models, no service objects)

```ruby
# Course
Course#full?                  # confirmed_count >= capacity (false wenn capacity nil)
Course#confirmed_count        # enrollments.confirmed.count
Course#enroll(participant)    # → Enrollment confirmed oder waitlisted
Course#promote_next_waitlisted # ältesten waitlisted → confirmed

# Enrollment
Enrollment#cancel             # → status=cancelled, then course.promote_next_waitlisted
```

### Kern-Entscheidung (→ ADR 0002)

Warteliste geordnet nach `created_at ASC` — kein extra `position`-Integer. Älteste
Anmeldung rückt als erste nach. Detailbegründung in `doc/adr/0002-kapazitaet-warteliste.md`.

## Tasks

Tasks sind sequenziell geordnet (jede Aufgabe blockiert die nächste). TDD-Reihenfolge:
Test zuerst, dann minimale Implementierung.

---

### Task 08 — Participant-Modell (Migration + Model + Tests)

**Berührte Dateien:**
- `db/migrate/*_create_participants.rb`
- `app/models/participant.rb`
- `test/fixtures/participants.yml`
- `test/models/participant_test.rb`

**Test zuerst:** Validierungstests schreiben, dann Modell implementieren.

**Schritte:**
1. Migration erzeugen: `name:string email:string`, beide `null: false`, unique index auf `email`.
2. Modell: `validates :name, presence: true`; `validates :email, presence: true, uniqueness: true`.
   Assoziationen (`has_many :enrollments`, `has_many :courses, through: :enrollments`) als
   Platzhalter eintragen — testen erst vollständig in Task 09.
3. Fixtures: 3 realistische deutsche Namen + E-Mail-Adressen.
4. Tests: Präsenz-Validierungen, Eindeutigkeit der E-Mail.

**Zuerst geschriebene Tests:**
```ruby
test "requires a name"
test "requires an email"
test "rejects a duplicate email"
```

---

### Task 09 — Enrollment-Modell + Course#capacity (Struktur, keine Logik)

**Berührte Dateien:**
- `db/migrate/*_create_enrollments.rb`
- `db/migrate/*_add_capacity_to_courses.rb`
- `app/models/enrollment.rb`
- `app/models/course.rb`
- `app/models/participant.rb` (Assoziationen vervollständigen)
- `test/fixtures/enrollments.yml`
- `test/fixtures/courses.yml` (capacity-Werte ergänzen)
- `test/models/enrollment_test.rb`

**Test zuerst:** Associations, STATUSES-Validierung und Scopes testen, bevor Logik existiert.

**Schritte:**
1. Migration Enrollments: `course:references NOT NULL`, `participant:references NOT NULL`,
   `status:string NOT NULL DEFAULT "confirmed"`, unique index auf `[course_id, participant_id]`.
2. Migration Courses: `add_column :courses, :capacity, :integer` (nullable → unbegrenzt).
3. Enrollment-Modell:
   ```ruby
   STATUSES = %w[confirmed waitlisted cancelled].freeze
   belongs_to :course
   belongs_to :participant
   validates :status, inclusion: { in: STATUSES }
   scope :confirmed,  -> { where(status: "confirmed") }
   scope :waitlisted, -> { where(status: "waitlisted") }
   scope :oldest_first, -> { order(:created_at) }
   ```
4. Course ergänzen: `has_many :enrollments, dependent: :destroy`,
   `has_many :participants, through: :enrollments`.
   Capacity-Validierung: `validates :capacity, numericality: { greater_than: 0, allow_nil: true }`.
5. Participant: Assoziationen vervollständigen.
6. Fixtures: 2–3 Enrollments in bestehenden Kursen, mind. 1 `waitlisted`.
   courses.yml: einem Kurs `capacity: 2` geben.
7. Seeds: `Enrollment.destroy_all`, `Participant.destroy_all` vorab.

**Zuerst geschriebene Tests:**
```ruby
test "STATUSES enthält confirmed, waitlisted, cancelled"
test "rejects a status outside STATUSES"
test "scope confirmed returns only confirmed"
test "scope waitlisted returns only waitlisted"
test "dependent destroy: removing course removes enrollments"
test "dependent destroy: removing participant removes enrollments"
test "unique index: double-enroll same participant blocked"
```

---

### Task 10 — Kapazitäts- und Wartelisten-Logik (TDD, Herzstück)

**Berührte Dateien:**
- `app/models/course.rb`
- `app/models/enrollment.rb`
- `test/models/course_test.rb`
- `test/models/enrollment_test.rb`

**Test zuerst:** ALLE Edge-Case-Tests schreiben (siehe Abschnitt `## Edge Cases / Tests`),
dann die minimale Implementierung, die sie grün macht.

**Schritte:**
1. Alle Edge-Case-Tests aus dem nächsten Abschnitt schreiben — sie scheitern.
2. `Course#confirmed_count` implementieren.
3. `Course#full?` implementieren (`capacity.nil?` → immer false).
4. `Course#enroll(participant)` implementieren:
   ```ruby
   def enroll(participant)
     status = full? ? "waitlisted" : "confirmed"
     enrollments.create!(participant: participant, status: status)
   end
   ```
5. `Course#promote_next_waitlisted` implementieren:
   ```ruby
   def promote_next_waitlisted
     next_one = enrollments.waitlisted.oldest_first.first
     next_one&.update!(status: "confirmed")
   end
   ```
6. `Enrollment#cancel` implementieren:
   ```ruby
   def cancel
     update!(status: "cancelled")
     course.promote_next_waitlisted
   end
   ```
7. Tests grün; kein Callback für Business-Logik — nur explizite Methodenaufrufe.

**Zuerst geschriebene Tests:** (vollständige Liste im Abschnitt `## Edge Cases / Tests`)

---

### Task 11 — EnrollmentsController + Course-Show-UI (Anmelden/Abmelden)

**Berührte Dateien:**
- `config/routes.rb`
- `app/controllers/enrollments_controller.rb`
- `app/views/courses/show.html.erb` (+ ggf. Partials)
- `app/helpers/application_helper.rb` (enrollment_status_badge)
- `db/seeds.rb`
- `test/controllers/enrollments_controller_test.rb`

**Test zuerst:** Controller-Integrationstests schreiben, dann Controller + Views.

**Schritte:**
1. Route ergänzen:
   ```ruby
   resources :courses do
     resources :sessions,   only: %i[create destroy]
     resources :enrollments, only: %i[create destroy]
   end
   ```
2. `EnrollmentsController`:
   - `create`: Participant per Email suchen oder anlegen (find_or_initialize_by email),
     `@course.enroll(participant)` aufrufen, Redirect mit deutschem Notice
     (`„Anmeldung bestätigt"` / `„Sie stehen auf der Warteliste"`). `params.expect(...)`.
   - `destroy`: Enrollment laden, `@enrollment.cancel`, Redirect mit Notice
     `„Abmeldung gespeichert"`.
3. Course-Show-View: Abschnitt `Anmeldungen` mit zwei Listen —
   `Bestätigt (N / capacity)` und `Warteliste (M)`. Je Enrollment ein
   Abmelden-Button (DELETE). Formular „Anmelden" mit Feldern Name + E-Mail.
   German Labels durchgehend.
4. Badge-Helper: `enrollment_status_badge(enrollment)` — delegiert an vorhandenes
   `badge`-Muster im Helper; Farben aus ui-style-guide.md
   (confirmed: `green-100/green-800`, waitlisted: `amber-100/amber-800`,
   cancelled: `gray-100/gray-500`).
5. Seeds: 1 vollen Kurs (2/2 confirmed) + 1 waitlisted Eintrag sichtbar beim ersten
   `db:reset`.

**Zuerst geschriebene Tests:**
```ruby
test "create enrolls a new participant as confirmed"
test "create enrolls into a full course as waitlisted"
test "create with blank name returns unprocessable_entity"
test "destroy cancels enrollment and promotes waitlisted"
test "destroy with no waitlist just cancels, no error"
```

## Edge Cases / Tests

Alle sieben Fälle sind explizite Tests in `test/models/course_test.rb` oder
`test/models/enrollment_test.rb`. Kein Fall darf fehlen.

---

**EC-01 — Freie Kapazität → confirmed**

```ruby
test "enroll into course with free capacity creates confirmed enrollment" do
  course = courses(:rails_performance)   # capacity: 2, 0 confirmed
  participant = participants(:alice)
  enrollment = course.enroll(participant)
  assert_equal "confirmed", enrollment.status
  assert_equal 1, course.confirmed_count
end
```

---

**EC-02 — Kurs genau voll → nächste Anmeldung ist waitlisted**

```ruby
test "enroll into full course creates waitlisted enrollment" do
  course = courses(:rails_performance)   # capacity: 2
  course.enroll(participants(:alice))
  course.enroll(participants(:bob))
  # Kurs jetzt voll
  enrollment = course.enroll(participants(:carol))
  assert_equal "waitlisted", enrollment.status
  assert course.full?
end
```

---

**EC-03 — Bestätigte Anmeldung stornieren → älteste Warteliste-Anmeldung nachrücken, Zähler stimmt**

```ruby
test "cancel confirmed spot promotes oldest waitlisted" do
  course = courses(:rails_performance)   # capacity: 2
  alice = course.enroll(participants(:alice))   # confirmed
  bob   = course.enroll(participants(:bob))     # confirmed (voll)
  carol = course.enroll(participants(:carol))   # waitlisted
  dave  = course.enroll(participants(:dave))    # waitlisted (später)
  alice.cancel
  assert_equal "cancelled",  alice.reload.status
  assert_equal "confirmed",  carol.reload.status   # ältester wartet
  assert_equal "waitlisted", dave.reload.status
  assert_equal 2, course.confirmed_count
end
```

---

**EC-04 — Stornierung ohne Warteliste → nur cancelled, kein Fehler**

```ruby
test "cancel confirmed enrollment with no waitlist does not raise" do
  course = courses(:rails_performance)
  enrollment = course.enroll(participants(:alice))
  assert_nothing_raised { enrollment.cancel }
  assert_equal "cancelled", enrollment.reload.status
  assert_equal 0, course.confirmed_count
end
```

---

**EC-05 — Alle storniert → Kurs leer, erneutes Anmelden funktioniert**

```ruby
test "re-enroll after all cancellations works" do
  course = courses(:rails_performance)   # capacity: 2
  e1 = course.enroll(participants(:alice))
  e2 = course.enroll(participants(:bob))
  e1.cancel
  e2.cancel
  assert_equal 0, course.confirmed_count
  assert_not course.full?
  new_enrollment = course.enroll(participants(:carol))
  assert_equal "confirmed", new_enrollment.status
end
```

---

**EC-06 — capacity nil/0 (Boundary)**

Definiertes Verhalten: `capacity: nil` bedeutet unbegrenzt — `full?` gibt immer `false`
zurück. `capacity: 0` ist durch die Validierung (`greater_than: 0`) ungültig und wird
abgewiesen. Tests:

```ruby
test "full? returns false when capacity is nil" do
  course = courses(:claude_code)   # capacity: nil
  3.times { course.enroll(Participant.create!(name: "X#{_1}", email: "x#{_1}@example.com")) }
  assert_not course.full?
end

test "capacity 0 is invalid" do
  course = courses(:claude_code)
  course.capacity = 0
  assert_not course.valid?
end
```

---

**EC-07 — Doppeltes Anmelden desselben Teilnehmers → blockiert**

```ruby
test "enrolling the same participant twice raises a record invalid error" do
  course = courses(:rails_performance)
  participant = participants(:alice)
  course.enroll(participant)
  assert_raises(ActiveRecord::RecordInvalid) do
    course.enroll(participant)
  end
end
```

Der unique index auf `[course_id, participant_id]` greift auf DB-Ebene; die Validierung
`uniqueness` in `Enrollment` fängt es zuvor ab.

## Bewusst NICHT

Die folgenden Features aus `FEATURES.md` sind eigene spätere Inkremente. Sie werden hier
bewusst nicht geplant und nicht gebaut:

- **Zähl-lastige Kursübersicht (N+1-Falle)** — die N+1-Query im `index` entsteht als
  Nebeneffekt der Enrollment-Zähler; die Demo-Aufgabe ist, sie *zu finden und zu fixen*,
  nicht sie zu bauen. Kein `includes` im `index` und kein `counter_cache` in diesem Feature.
- **Teilnehmer-PII JSON-Export** — ein eigener Endpoint, der PII (Email) sichtbar nach
  außen gibt. Wird als Security-Demo-Boden in einem separaten Increment gebaut.
- E-Mail-Versand (Bestätigungs-Mail), Admin-Ansicht für Wartelisten, Zahlungslogik,
  Mandanten, Auth/Login — alles außerhalb der Demo-Leitplanke.

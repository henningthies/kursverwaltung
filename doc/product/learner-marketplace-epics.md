# Learner-Marketplace — Epic-/Feature-Breakdown

> Architektur-Plan für den Ausbau der Kursverwaltung von einem internen Admin-CRUD zu einer
> **lernenden-zugewandten Kurs-Plattform mit echtem E-Commerce** (Skillery-Stil), bei
> gleichzeitigem Erhalt des bestehenden Verwaltungsbereichs.
>
> Diese Phase **ignoriert bewusst** die „kein Auth / keine Zahlung“-Leitplanke aus
> `FEATURES.md` — siehe Begründung unten. Stil bleibt vanilla Rails / 37signals:
> dünne Controller, `STATUSES`-Muster (kein `enum`), `params.expect`, Logik in Modellen,
> Minitest + Fixtures. Visuelle Ziele: `mockups/` + `doc/design/ui-style-guide.md`.

## Ausgangslage (heute)

| Modell | Felder | Beziehungen |
|--------|--------|-------------|
| `Course` | `title`, `status` (draft/active/done), `description`, `instructor`, `capacity` | `has_many :sessions`, `has_many :enrollments`, `has_many :participants, through:` |
| `Session` | `title`, `starts_at` | `belongs_to :course` |
| `Participant` | `name`, `email` | `has_many :enrollments`, `has_many :courses, through:` |
| `Enrollment` | `status` (confirmed/waitlisted/cancelled) | `belongs_to :course`, `belongs_to :participant` |

Bereits vorhandene Kern-Logik (nicht neu bauen, sondern **anbinden**): `Course#enroll`,
`Course#full?`, `Course#promote_next_waitlisted`, `Enrollment#cancel`. Routen liegen unter
`resources :courses` mit verschachtelten `sessions` und `enrollments`.

## Bewusste Abweichung von der FEATURES.md-Leitplanke

`FEATURES.md` schließt Auth/Login, Bezahlung und Mehrmandanten aus, weil sie für die
Lehr-Demo Überblickbarkeit kosten, ohne eine Demo zu tragen. Diese Marketplace-Phase ist
ein **eigenständiges Ausbau-Ziel** mit eigener Demo-Erzählung (echter Kauf-Flow als
realistisches Rails-8-Feature). Sie läuft additiv: der Admin-CRUD bleibt unverändert
nutzbar. Wer die reine Lehr-Demo will, bleibt auf den Progressions-Tags `t1`–`t3`.
**Empfehlung:** Diese Phase auf einem eigenen Branch (`feature/learner-marketplace`) und
hinter einem klaren Tag (`marketplace`) führen, damit die schlanken Kurs-Tags sauber bleiben.

---

## Ziel-Datenmodell (Änderungen)

Neue und geänderte Modelle. Alle Status-Felder folgen dem `STATUSES`-Konstanten-Muster.

### Neu: `User` (Account mit Rolle)
| Feld | Typ | Hinweis |
|------|-----|---------|
| `name` | string | |
| `email` | string, unique | Login-Identität |
| `password_digest` | string | über `has_secure_password` (bcrypt) |
| `role` | string | `ROLES = %w[learner admin].freeze`, `inclusion` |

- `has_many :enrollments` (über `participant`-Brücke, s. u.), `has_many :orders`.
- Rolle steuert Zugriff: `learner` → Marketplace + Meine Kurse; `admin` → Verwaltung.

### Geändert: `Participant` → an `User` koppeln
Heute trägt `Participant` Name + E-Mail (die PII-Stelle der T3-Demo). Statt eines zweiten
Identitäts-Begriffs bekommt `Participant` ein optionales `belongs_to :user` (nullable),
sodass Alt-Anmeldungen ohne Konto bestehen bleiben und neue Käufe einen `User` referenzieren.
`Enrollment` bleibt unverändert die Verbindung Kurs↔Teilnehmer.
**ADR-Entscheidung:** Ein Modell (User trägt Auth, Participant trägt die Anmelde-Identität)
vs. Verschmelzung. Empfehlung: getrennt lassen, `Participant.belongs_to :user, optional: true`.

### Geändert: `Course` → Preis + Kategorie
| Feld | Typ | Hinweis |
|------|-----|---------|
| `price_cents` | integer, default 0 | Geld als Integer-Cents (keine Floats) |
| `category_id` | references, nullable | |

- `0` Cents = kostenloser Kurs (Badge „Gratis“, Buchung ohne Checkout).
- `monetize`-Gems vermeiden — ein schlanker `price_euros`-Helper reicht (vanilla).

### Neu: `Category`
| Feld | Typ |
|------|-----|
| `name` | string, unique |
| `slug` | string, unique |

- `has_many :courses`. Dient Filter-Pills im Marketplace.

### Neu: `Order` (Kauf)
| Feld | Typ | Hinweis |
|------|-----|---------|
| `user_id` | references | |
| `status` | string | `STATUSES = %w[pending paid failed]` |
| `total_cents` | integer | Snapshot bei Bestellung |
| `stripe_session_id` | string, nullable | Stripe-Checkout-Session |
| `paid_at` | datetime, nullable | |

- `has_many :order_items`, `belongs_to :user`.

### Neu: `OrderItem`
| Feld | Typ | Hinweis |
|------|-----|---------|
| `order_id` | references | |
| `course_id` | references | |
| `price_cents` | integer | Preis-Snapshot zum Kaufzeitpunkt |

- `belongs_to :order`, `belongs_to :course`.

### Cart — bewusst **kein eigenes Modell**
Der Warenkorb lebt in der Session (`session[:cart_course_ids]`), nicht in der DB.
**ADR-Entscheidung:** Session-Cart vs. persistentes `Cart`-Modell. Empfehlung: Session,
weil der Kauf-Flow kurzlebig ist und ein DB-Cart Aufräum-Logik (verwaiste Carts) kostet,
die hier keine Demo trägt. Bei Bedarf später nachrüstbar.

```
User 1—* Order 1—* OrderItem *—1 Course *—1 Category
User 1—* Participant 1—* Enrollment *—1 Course
Course 1—* Session
```

---

## Epics (in strenger Abhängigkeits-Reihenfolge)

Jedes Epic ist auf eine Factory-Feature-Stufe (`feature-plan` → `feature-build` →
`feature-review`) zugeschnitten und erzeugt einen ADR + eine Produkt-Doc.

### Epic 1 — Authentifizierung + Rollen
**Ziel:** Besucher können sich registrieren, anmelden, abmelden. Jeder User ist `learner`
oder `admin`. Verwaltungs-Routen sind nur für `admin` erreichbar.

- **Modelle:** `User` (neu, `has_secure_password`, `role` per `STATUSES`-Muster).
  `Participant` bekommt `belongs_to :user, optional: true`.
- **Controller:** `RegistrationsController`, `SessionsController` (Rails-8-Auth-Generator
  als Basis: `bin/rails generate authentication`), `ApplicationController#require_login` /
  `#require_admin` als `before_action`-Helfer.
- **Views:** `auth.html` (Registrieren + Anmelden), Header-Variante mit Avatar/Abmelden.
- **Demo/Wert:** Realistische Rails-8-Authentifizierung **ohne Devise** — zeigt den
  eingebauten Generator und das Rollen-Gate. Fundament für alles Weitere.
- **Abhängigkeiten:** keine (Wurzel-Epic).
- **ADR:** Rails-8-Auth-Generator + `has_secure_password` vs. Devise; warum
  `Participant.user` optional statt User/Participant-Verschmelzung; Session-basierte
  Authentifizierung (signiertes Cookie) statt Token.

### Epic 2 — Kurs-Preise + Kategorien + Marketplace-Übersicht
**Ziel:** Kurse haben Preis und Kategorie. Besucher sehen eine öffentliche, gefilterte
Kurs-Übersicht (Landing) mit Karten.

- **Modelle:** `Course` + `price_cents`, `category_id`; `Category` (neu) mit `has_many :courses`.
- **Controller:** öffentlicher `CatalogController#index` (oder `MarketplaceController`) —
  getrennt vom bestehenden Admin-`CoursesController`, damit Lern- und Verwaltungssicht
  sauber getrennt bleiben. Filter über `?category=`.
- **Views:** `marketplace.html` (Hero, Filter-Pills, Kurs-Grid), Status-Badge-Helper
  erweitern (Gratis / Fast ausgebucht).
- **Demo/Wert:** Die lernende-zugewandte Startseite — erster sichtbarer „Marketplace“-Moment.
  Trägt zugleich die bestehende **N+1-Falle** (Zähler pro Karte) weiter.
- **Abhängigkeiten:** Epic 1 (Rollen-Gate für „eigene/Entwurf“-Kurse; öffentlich nur `active`).
- **ADR:** Geld als `price_cents`-Integer (kein `monetize`-Gem, keine Floats);
  `price_cents = 0` = kostenlos; getrennter `CatalogController` vs. Erweiterung des
  Admin-Controllers.

### Epic 3 — Einzel-Kursseite (Detail / Verkauf)
**Ziel:** Öffentliche Kursdetailseite zum Kaufen, im Skillery-Layout — mit Preis,
Trainer, Beschreibung, Lehrplan (Sessions), Kapazitäts-/Wartelisten-Zustand, „In den
Warenkorb“ / „Jetzt buchen“.

- **Modelle:** keine neuen; liest `Course`, `Session`, nutzt `Course#full?` für die
  Kapazitäts-Anzeige.
- **Controller:** `CatalogController#show`.
- **Views:** `course-detail.html` (klebrige Preis-Karte, Akkordeon-Lehrplan, FAQ —
  FAQ/Testimonials als statisches Markup, keine Modelle).
- **Demo/Wert:** Die zentrale Verkaufsseite. Verbindet vorhandene Kapazitäts-Logik sichtbar
  mit dem Kauf-Einstieg.
- **Abhängigkeiten:** Epic 2 (Preis/Kategorie müssen existieren).
- **ADR:** FAQ/Testimonials hartkodiert vs. eigenes Modell (Empfehlung: hartkodiert/seed,
  keine Demo trägt ein eigenes Modell); wie der „Warenkorb hinzufügen“-Button an den
  Session-Cart aus Epic 4 andockt.

### Epic 4 — Warenkorb + Stripe-Checkout + Order
**Ziel:** Lernende legen Kurse in den (Session-)Warenkorb, gehen zur Kasse und bezahlen
über **Stripe Checkout** (Testmodus). Erfolgreiche Zahlung erzeugt einen `Order` mit
`OrderItem`s und Status `paid`.

- **Modelle:** `Order`, `OrderItem` (neu, `STATUSES` an `Order`).
- **Controller:** `CartsController` (Session-Cart: add/remove/show), `CheckoutsController`
  (`#create` → Stripe-Checkout-Session, `#success` / `#cancel`), `WebhooksController`
  (`checkout.session.completed` → `Order` auf `paid`).
- **Views:** `checkout.html` (Warenkorb + Stripe-Übergabe + Bestellübersicht).
- **Demo/Wert:** Echter Bezahl-Flow als realistisches Rails-8-Feature. Zeigt
  Credentials-Handling, Webhooks und Idempotenz.
- **Abhängigkeiten:** Epic 1 (User für Order), Epic 3 (Detailseite als Einstieg).
- **ADR:** Stripe **Checkout** (gehostete Seite) statt Payment-Intents-im-eigenen-Frontend
  (weniger PCI-Fläche, weniger JS); Order-Statusübergang über **Webhook** (`paid_at`)
  statt nur über den Success-Redirect (Redirect kann ausbleiben); CI-Strategie für
  fehlende Stripe-Keys (s. Risiken); Geld-Snapshot in `OrderItem.price_cents`.

### Epic 5 — Buchung an Enrollment koppeln + „Meine Kurse“
**Ziel:** Eine bezahlte (oder kostenlose) Buchung erzeugt die `Enrollment` über die
**vorhandene** `Course#enroll`-Logik (inkl. Kapazität/Warteliste). Lernende sehen ihre
Kurse mit Status und Fortschritt unter „Meine Kurse“.

- **Modelle:** keine neuen; `Order`/`Payment` → `Course#enroll(participant)` aufrufen, wobei
  `participant` aus dem `User` abgeleitet/erstellt wird (`Participant.find_or_create_by`).
- **Controller:** `MyCoursesController#index` (nur eingeloggte Lernende),
  Buchungs-Verknüpfung in `CheckoutsController#success` / Webhook.
- **Views:** `my-courses.html` (Tabs aktiv/Warteliste/abgeschlossen, Fortschrittsbalken,
  Wartelisten-Hinweis).
- **Demo/Wert:** Schließt den Kreis: Kauf → Anmeldung → „Meine Kurse“. Zeigt die
  bestehende Wartelisten-Logik im echten Kauf-Kontext (voller Kurs → `waitlisted`).
- **Abhängigkeiten:** Epic 4 (Order muss existieren), nutzt Epic-1-User.
- **ADR:** Kritische Entscheidung — **Beziehung Kauf ↔ Kapazität**: Wird ein Platz **vor**
  der Zahlung reserviert (Race-Risiko bei vollem Kurs) oder **nach** bestätigter Zahlung
  über `Course#enroll` gebucht (dann ggf. trotz Zahlung `waitlisted`)? Empfehlung:
  Enrollment erst **nach** `paid` über `Course#enroll`; bei vollem Kurs landet die bezahlte
  Buchung auf der Warteliste mit klarer Kommunikation (Mockup zeigt: „Zahlung erst bei
  Bestätigung“) — alternativ Refund-Pfad. Diese Entscheidung MUSS der ADR festhalten.

### Epic 6 — Admin-Restyle + Trainer-Dashboard
**Ziel:** Der bestehende Verwaltungs-CRUD wird im violet-Stil neu eingekleidet und um
Preis-Spalte, Umsatz-KPI und Anmelde-/Wartelisten-Zähler ergänzt. Zugriff nur für `admin`.

- **Modelle:** keine neuen; liest `Order`/`OrderItem` für Umsatz-KPIs.
- **Controller:** bestehender `CoursesController` (Admin) bleibt, hinter `require_admin`;
  optional `Admin::DashboardController#index` für die KPI-Startseite.
- **Views:** `admin-dashboard.html`, Restyle der vorhandenen `courses/*`-Views auf die
  Style-Guide-Tokens.
- **Demo/Wert:** Zwei klar getrennte Welten (Lernen vs. Verwalten) im selben Stil.
- **Abhängigkeiten:** Epic 1 (Rollen-Gate), Epic 2 (Preis), Epic 4 (Umsatz-Daten) —
  daher zuletzt; kann aber parallel zu Epic 5 starten (keine geteilten Schreibpfade).
- **ADR:** Admin-Namespace/Gate-Strategie (`require_admin` vs. eigener `Admin::`-Namespace);
  ob die Umsatz-KPI live aggregiert oder über `counter_cache` läuft (N+1/Performance-Demo).

---

## Risiken

1. **Stripe-Keys / Testmodus / CI.** Die Keys liegen in Credentials/ENV und fehlen in CI.
   Der Zahlungs-Code muss test-freundlich sein: Stripe-Aufrufe hinter einem dünnen Wrapper
   (`PaymentGateway`), in Tests gestubbt; `WebhooksController` per Fixture-Payload getestet,
   ohne echten Stripe-Call. Ohne Keys darf weder Boot noch Test-Suite brechen — Guard:
   Checkout-Pfad zeigt eine klare Fehlermeldung statt einer Exception, wenn Keys fehlen.
2. **Auth-Session-Handling.** Rails-8-Auth nutzt signierte Cookies. Achten auf: sichere
   Cookie-Flags, CSRF (bleibt aktiv), `reset_session` bei Login/Logout (Session-Fixation),
   und dass der Session-Cart beim Login nicht ungewollt geteilt wird.
3. **Buchung ↔ Kapazität/Warteliste (Race & Semantik).** Zwei gleichzeitige Käufe auf den
   letzten Platz; Zahlung erfolgt, aber Kurs ist inzwischen voll. Entscheidung in Epic 5
   (Enrollment nach `paid`, Warteliste statt Fehler) ist verbindlich zu dokumentieren und
   mit Tests gegen `Course#full?`/`promote_next_waitlisted` abzusichern. `Course#enroll`
   und `promote_next_waitlisted` **nicht duplizieren** — nur aufrufen.
4. **PII-Ausweitung.** Mit Konten kommt mehr PII (User + Participant). Die bestehende
   PII-Export-Stelle (`CoursesController#participants`) nicht unbeabsichtigt mit
   User-Daten/Order-Daten anreichern; Order-JSON keine Stripe-Rohdaten/E-Mails leaken.
5. **Geld als Float.** Niemals Float-Preise — durchgehend `*_cents`-Integer, ein Helper für
   die Anzeige. Snapshot des Preises in `OrderItem`, damit spätere Preisänderungen alte
   Bestellungen nicht verfälschen.
6. **Doppelter Webhook / Idempotenz.** Stripe sendet Webhooks ggf. mehrfach. `Order` per
   `stripe_session_id` idempotent auf `paid` setzen (kein doppeltes `enroll`).

---

## Empfohlene Bau-Reihenfolge & Parallelität

**Strikt sequenziell (Fundament):**
1. **Epic 1 — Auth + Rollen** (Wurzel, blockiert alles).
2. **Epic 2 — Preis + Kategorie + Marketplace-Übersicht**.
3. **Epic 3 — Kursdetailseite**.
4. **Epic 4 — Cart + Stripe + Order**.
5. **Epic 5 — Buchung ↔ Enrollment + Meine Kurse**.

**Parallelisierbar:**
- **Epic 6 (Admin-Restyle)** kann parallel zu Epic 4/5 laufen — es schreibt keine geteilten
  Pfade, sondern liest vorhandene Daten und kleidet bestehende Views neu ein. Setzt nur
  Epic 1 (Gate) und Epic 2 (Preis-Feld) voraus.
- Innerhalb Epic 2/3 können **Category-Seed + Marketplace-View** und **Detail-View** von
  zwei Strängen gebaut werden, sobald die `Course`-Migration (Preis/Kategorie) steht.

**Reine Frontend-/Seed-Arbeit** (Mockup → ERB-Partials, Style-Guide-Helper) hat keine
Modell-Abhängigkeit und kann jederzeit vorgezogen werden.

---

## Vor dem autonomen Overnight-Build zu bestätigen

1. **Branch/Tag-Strategie:** Marketplace auf eigenem Branch `feature/learner-marketplace`,
   Lehr-Demo-Tags `t1`–`t3` unangetastet — bestätigen?
2. **Buchung ↔ Kapazität (Epic 5):** Enrollment erst **nach** bestätigter Zahlung über
   `Course#enroll`; bezahlte Buchung bei vollem Kurs → Warteliste (kein Auto-Refund).
   Diese Semantik so festlegen?
3. **Stripe in CI:** Zahlungs-Code hinter Wrapper + gestubbt; Suite läuft **ohne** echte
   Keys grün. Bestätigen, dass kein Live-Stripe-Call in CI erwartet wird.
4. **User vs. Participant:** Getrennt halten (`Participant.belongs_to :user, optional`)
   statt verschmelzen — einverstanden?
5. **Cart:** Session-basiert statt DB-`Cart`-Modell — einverstanden?
6. **FAQ/Testimonials:** Hartkodiert/geseedet, kein eigenes Modell — einverstanden?
7. **Geltungsbereich FEATURES.md-Leitplanke:** Bestätigen, dass diese Phase die
   „kein Auth/keine Zahlung“-Regel bewusst und dokumentiert überschreibt.

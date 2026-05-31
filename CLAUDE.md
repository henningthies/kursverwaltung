# Kursverwaltung — Kurs-Marketplace

Rails-App: ein **lernenden-zugewandter Kurs-Marketplace mit echtem E-Commerce** (browsen,
kaufen, „Meine Kurse") **plus** ein **Admin-Bereich** zum Verwalten von Kursen, Terminen und
Anmeldungen. Durchgehende Demo-App für den Rheinwerk-Kurs *Claude Code im Projektalltag*.

> **Historie:** Die App begann als schlanke `Course`/`Session`-Lehr-Demo; diese Progression ist
> als Tags `t1-start` → `t1-end` → `t2-end` → `t3-feature` erhalten und auscheckbar. Der aktuelle
> `main`-Stand baut darauf den Marketplace (Auth + Zahlung) auf. Frühphasen-Kontext:
> `doc/course-build-context.md`; Datenmodell + Epics: `doc/product/learner-marketplace-epics.md`.

## Stack

- Rails 8.1, Ruby 3.4, SQLite (Datei-DB)
- Minitest + Fixtures (kein RSpec, kein FactoryBot)
- Tailwind CSS, Akzent **`violet-600`** — UI-Tokens in `doc/design/ui-style-guide.md`, Vorbild `mockups/`
- Auth: **`has_secure_password`** (kein Devise). Zahlung: **Stripe Checkout** über den `PaymentGateway`-Wrapper
- Deutsche UI-Texte; englische Modell-/Methoden-/Variablennamen

## Domäne

| Modell | Kern-Felder | Beziehungen |
|--------|-------------|-------------|
| `User` | `name`, `email`, `password_digest`, `role` (`ROLES = %w[learner admin]`) | `has_many :orders`, `has_many :participants` |
| `Category` | `name`, `slug` | `has_many :courses` |
| `Course` | `title`, `status` (draft/active/done), `description`, `instructor`, `capacity`, `price_cents` | `belongs_to :category` (optional); `has_many :sessions/:enrollments/:participants` |
| `Session` | `title`, `starts_at` | `belongs_to :course` |
| `Participant` | `name`, `email` *(PII)* | `belongs_to :user` (optional); `has_many :enrollments/:courses` |
| `Enrollment` | `status` (confirmed/waitlisted/cancelled) | `belongs_to :course/:participant` |
| `Order` | `status` (pending/paid/failed), `total_cents`, `stripe_session_id`, `paid_at` | `belongs_to :user`; `has_many :order_items/:courses` |
| `OrderItem` | `price_cents` (Snapshot) | `belongs_to :order/:course` |

Geld immer als Integer-`*_cents` (Helper `price_display`; `price_cents = 0` → „Gratis").

## Zwei Bereiche

- **Lernende / öffentlich:** `CatalogController` (Übersicht `/`, Detail `/kurse/:id`),
  `CartsController` (Session-Warenkorb), `CheckoutsController` (Stripe), `WebhooksController#stripe`,
  `MyCoursesController`, `RegistrationsController` + `UserSessionsController` (Login/Logout).
- **Admin (hinter `require_admin`):** `CoursesController` mit verschachtelten `SessionsController`
  (Termine) / `EnrollmentsController` (CRUD), `Admin::DashboardController` (KPIs).
- Buchung passiert **nach** bestätigter Zahlung über die vorhandene `Course#enroll`-Logik
  (voller Kurs → Warteliste, kein Auto-Refund); Webhook idempotent über `stripe_session_id`.

## Konventionen (verbindlich — vanilla Rails / 37signals)

- **Schlanke Controller**, Standard-Actions, **keine** Service-Objekte/Abstraktions-Gems. Logik in Modellen.
- **Status/Rollen über das `STATUSES`/`ROLES`-Konstanten-Muster** (+ `inclusion`), **nicht** `enum`.
- **Strong Params mit `params.expect(...)`**, nicht `require.permit`. `role` nie massenzuweisbar.
- **Deutsche** Labels/Notices; **englische** Bezeichner im Code.
- **Minitest + Fixtures**; neue Logik/Actions bekommen Tests mit präzisen Assertions.
- **Seeds idempotent** (`destroy_all` vorab, Kinder vor Eltern).
- **Views folgen `doc/design/ui-style-guide.md`**: violet-Akzent, runde Karten, Pill-Badges, kein Blau.

## Ausführen & prüfen

- Tests: `bin/rails test` (grün). DB: `bin/rails db:reset` (idempotent).
- Server: `bin/dev` → `http://localhost:3000`. Demo-Logins (Passwort `geheim123`):
  `admin@example.com` (Admin), `lena@example.com` (Lernende).
- **Stripe:** ohne Keys läuft alles (Gateway gestubbt, Suite grün). Für echten Checkout
  `stripe.secret_key` / `stripe.webhook_secret` in Credentials/ENV setzen
  (siehe `doc/product/warenkorb-stripe-checkout.md`).

## Bewusste Demo-Schwachstellen (NICHT „fixen")

Als Demo-Boden absichtlich drin und kommentiert: **N+1** in Kursübersicht/Katalog/Admin-Dashboard
(Performance-Demo) und der **PII-Export** `GET /courses/:id/participants` (Security-Demo).

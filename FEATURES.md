# Features — Kursverwaltung (Kurs-Marketplace)

Die Kursverwaltung ist ein **Kurs-Marketplace mit echtem E-Commerce** plus ein **Admin-Bereich**
— die durchgehende Demo-App für den Kurs *Claude Code im Projektalltag*. Diese Datei beschreibt
**was die App ist und kann**. Detail-Entscheidungen stehen in den ADRs (`doc/adr/`), das
Datenmodell + die Epics in `doc/product/learner-marketplace-epics.md`, die UI-Ziele in
`mockups/` + `doc/design/ui-style-guide.md`.

## Was die App ist

Zwei Bereiche, eine App, vanilla Rails:

- **Lernende** browsen Kurse, öffnen eine Kursdetailseite, legen Kurse in den Warenkorb,
  bezahlen über Stripe und finden ihre Buchungen unter „Meine Kurse".
- **Admins** verwalten Kurse, Termine und Anmeldungen und sehen ein KPI-Dashboard
  (Umsatz, Anmeldungen, Wartelisten).

## Feature-Landkarte

| Bereich | Features |
|---------|----------|
| **Auth & Rollen** | Registrierung, Login/Logout (`has_secure_password`), Rollen `learner`/`admin`, Gates `require_login` / `require_admin` |
| **Marketplace** | Öffentliche Übersicht mit Kategorie-Filtern, Preisen und Verfügbarkeits-Badges (Gratis / Fast ausgebucht / Ausgebucht) |
| **Kursdetail** | Skillery-Layout: klebrige Preis-Karte, Lehrplan (Termine), „Das bekommst du", Trainer, Testimonials, FAQ |
| **Kauf** | Session-Warenkorb → Stripe Checkout → `Order`/`OrderItem` (Preis-Snapshot); kostenlose Kurse ohne Checkout; idempotenter Webhook |
| **Buchung** | Nach Zahlung Anmeldung über `Course#enroll` (Kapazität/Warteliste); „Meine Kurse" mit Status |
| **Verwaltung** | Course-/Session-/Enrollment-CRUD, Kapazität/Warteliste, KPI-Dashboard |

## Echte Logik (demo-tragend)

- **Kapazität + Warteliste** — `Course#enroll` / `#promote_next_waitlisted`, `Enrollment#cancel`
  (voller Kurs → `waitlisted`; Absage → Nachrücken).
- **Zahlung** — `PaymentGateway` (Stripe Checkout, Webhook, Idempotenz via `stripe_session_id`).
- **Rollen-Autorisierung** — getrennter Lernenden- vs. Admin-Bereich.

## Bewusste Demo-Schwachstellen (NICHT „fixen")

Lehrstoff für die T3-Demos — als solche kommentiert, bleiben absichtlich drin:

- **N+1** in Kursübersicht / Katalog / Admin-Dashboard (Zähler je Zeile) → **Performance-Demo**.
- **PII-Export** `GET /courses/:id/participants` (Name + E-Mail, ungefiltert, geloggt) → **Security-Demo**.

## Konventionen

Vanilla Rails / 37signals: `STATUSES`/`ROLES`-Muster (kein `enum`), `params.expect`, Logik in
Modellen, deutsche UI / englischer Code, Minitest + Fixtures, Geld als Integer-Cents, violet-UI
nach `doc/design/ui-style-guide.md`. Neue Features laufen über die Software-Factory
(`feature-plan` → `feature-build` → `feature-review`).

## Historie — die Lehr-Progression (Tags)

Die App begann als schlanke `Course`/`Session`-Demo und wuchs über drei Termine. Diese Stände
sind als Tags erhalten und für den Kurs auscheckbar:

- `t1-start` — Course + Session, roh.
- `t1-end` — + CLAUDE.md, Termin-Zähler in der Übersicht.
- `t2-end` — + `review`-Skill, MCP, Secrets-Hook, Software-Factory.
- `t3-feature` — + Participant / Enrollment / Kapazität+Warteliste (Feature → PR).

Der aktuelle `main`-Stand baut darauf den Marketplace (Auth + Zahlung) auf. Wer die schlanke
Lehr-Demo zeigen will, checkt das passende Tag aus (`git checkout <tag> && bin/rails db:reset`).

# 0003. Authentifizierung über has_secure_password + Session-Cookie, getrennt von Participant

- **Status:** Accepted
- **Datum:** 2026-05-27
- **Epic:** Learner-Marketplace Epic 1 — Authentifizierung + Rollen
- **Plan:** `doc/product/learner-marketplace-epics.md`

## Kontext

Der Marketplace-Ausbau braucht Konten: Besucher registrieren sich, melden sich an/ab und
sind entweder `learner` (Marketplace + Meine Kurse) oder `admin` (Verwaltung). Die
Verwaltungs-CRUD-Strecke (`CoursesController`, `SessionsController`, `EnrollmentsController`)
muss vor nicht-Admins geschützt werden, ohne den bestehenden vanilla-Rails-Stil zu brechen.

Randbedingungen: Rails 8.1, kein Devise, `STATUSES`-Muster (kein `enum`), `params.expect`,
Logik in Modellen, deutsche UI. Die Suite muss durchgehend grün bleiben.

## Entscheidung

1. **`has_secure_password` + Rollen-Konstante.** `User` trägt `name`, `email` (eindeutig,
   `normalizes` auf lowercase), `password_digest` (bcrypt) und `role`. Rollen über das
   bestehende `STATUSES`-Muster: `ROLES = %w[learner admin].freeze` + `inclusion`-Validierung
   — **kein** `enum`, konsistent mit `Course::STATUSES` und `Enrollment::STATUSES`.

2. **Session-Cookie statt DB-Session-Modell.** Der eingeloggte User wird über
   `session[:user_id]` im signierten, `httponly`-Cookie gehalten. Eine `Authentication`-Concern
   in `ApplicationController` stellt `current_user`, `logged_in?`, `require_login`,
   `require_admin`, `log_in`, `log_out` bereit. `log_in` ruft `reset_session` (gegen
   Session-Fixation) und bewahrt dabei einen vorhandenen Warenkorb (`session[:cart_course_ids]`).

3. **`Participant` bleibt getrennt vom `User`.** `Participant.belongs_to :user, optional: true`
   (nullable FK). Alt-Anmeldungen ohne Konto bleiben gültig; neue Käufe können einen `User`
   referenzieren. User und Participant werden **nicht** verschmolzen.

4. **Sicher per Default, Admin explizit.** Die Concern setzt global `before_action :require_login`.
   Login/Registrierung öffnen sich per `allow_unauthenticated_access`. Die drei vorhandenen
   Verwaltungs-Controller bekommen zusätzlich `before_action :require_admin`. (Epic 2 macht
   den öffentlichen Katalog zur Wurzel; bis dahin ist `/` admin-geschützt.)

## Begründung (warum einfach)

- **Kein Devise** spart ein großes Gem mit eigener DSL/Generatoren; `has_secure_password` ist
  Rails-Bordmittel und in wenigen Zeilen am Bildschirm überblickbar — passend zur Lehr-Demo.
- **Cookie statt DB-Session-Modell** vermeidet eine zusätzliche Tabelle und — entscheidend —
  die **Namenskollision mit dem bestehenden Domänen-`Session`-Modell** (Kurs-Termine). Der
  Rails-8-`authentication`-Generator legt ein `Session`-Modell und einen `SessionsController`
  an, die unsere vorhandenen gleichnamigen Domänen-Klassen überschreiben würden. Ein
  signiertes `user_id`-Cookie deckt den Demo-Bedarf vollständig ab (siehe verworfene Alternative).
- **Getrennte Modelle** halten Auth-Identität (`User`) und Anmelde-Identität (`Participant`)
  sauber auseinander, ohne die T3-PII-Demo (`courses#participants`) zu verändern.

## Verworfene Alternativen

- **Rails-8-`authentication`-Generator (DB-`Session`-Modell).** Verworfen wegen harter
  Namenskollision: Generator-`Session`/`SessionsController` ≠ Domänen-`Session` (Termin)/
  `SessionsController` (nested unter Kursen). Der Generator hat beim Lauf die vorhandenen
  Dateien überschrieben. Statt die getestete Domäne umzubenennen, bleibt das Domänen-`Session`
  unangetastet; Auth nutzt das Cookie. Der Login-Controller heißt darum bewusst
  `UserSessionsController` (Route `resource :session`), nicht `SessionsController`.
- **Devise.** Zu viel verborgene Mechanik für eine Lehr-Demo; widerspricht „klein und lesbar".
- **User und Participant verschmelzen.** Würde Alt-Anmeldungen ohne Konto unmöglich machen
  und die PII-Demo-Stelle verschieben. Getrennt lassen ist additiv und risikoärmer.

## Konsequenzen

- Login/Logout liegen in `UserSessionsController` (nicht `SessionsController`) — eine kleine,
  dokumentierte Abweichung vom Rails-Default, erzwungen durch die Domänen-Namensgebung.
- Die drei Verwaltungs-Controller sind ab sofort admin-only; ihre Tests melden sich als Admin an.
- Passwort-Reset (Mailer) wurde bewusst **weggelassen** — keine Demo trägt ihn; bei Bedarf
  später nachrüstbar.

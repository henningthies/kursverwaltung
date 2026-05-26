# Authentifizierung und Rollen — was es kann

> Produkt-Dokumentation für den Human-in-the-Loop. Beschreibt das Feature aus
> Nutzer-Sicht, ohne Code.

## Wozu

Die App hat jetzt Konten. Besucher können sich **registrieren**, **anmelden** und
**abmelden**. Jedes Konto hat eine Rolle:

- **Lernende (`learner`)** — sehen später Marketplace und „Meine Kurse".
- **Admin (`admin`)** — erreichen die Verwaltung (Kurse, Termine, Anmeldungen anlegen/ändern).

Die Verwaltungs-Strecke ist ab sofort **nur für Admins** erreichbar. Wer nicht angemeldet
ist, wird zur Anmeldung geleitet; Lernende, die eine Verwaltungsseite öffnen, landen auf
der Startseite mit einem Hinweis.

## So benutzt man es

### Registrieren

1. Oben rechts auf „Registrieren" klicken.
2. Name, E-Mail und Passwort eingeben, „Konto erstellen".
3. Man ist sofort angemeldet — als Lernende(r).

### Anmelden / Abmelden

1. „Anmelden" oben rechts → E-Mail und Passwort eingeben.
2. Falsche Daten zeigen „E-Mail oder Passwort ist falsch.".
3. Im Header erscheinen Name + Avatar; „Abmelden" beendet die Sitzung.

## Demo-Konten (nach `bin/rails db:reset`)

| Rolle | E-Mail | Passwort |
|-------|--------|----------|
| Admin | `admin@example.com` | `geheim123` |
| Lernende | `lena@example.com` | `geheim123` |

## Grenzen (bewusst)

- **Kein Passwort-Reset per E-Mail** — keine Demo trägt ihn (bei Bedarf nachrüstbar).
- **Login/Logout liegen technisch im `UserSessionsController`** (nicht `SessionsController`),
  weil `SessionsController` bereits die Kurs-Termine verwaltet — Details im ADR 0003.
- Bis Epic 2 (öffentlicher Katalog) ist die Startseite admin-geschützt.

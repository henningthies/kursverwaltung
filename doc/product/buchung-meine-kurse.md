# Buchung und „Meine Kurse" — was es kann

> Produkt-Dokumentation für den Human-in-the-Loop.

## Wozu

Der Kreis schließt sich: Aus einer **bezahlten** (oder kostenlosen) Bestellung wird automatisch
eine **Anmeldung** zum Kurs. Lernende sehen alle ihre Kurse unter **„Meine Kurse"**.

## Wie die Buchung funktioniert

- Die Anmeldung entsteht **erst nach bestätigter Zahlung** (bzw. sofort bei Gratis-Kursen).
- Sie läuft über die **vorhandene** Kurs-Logik inkl. Kapazität/Warteliste.
- **Voller Kurs:** Auch eine bezahlte Buchung landet auf der **Warteliste** — es gibt keine
  automatische Rückerstattung. Wird ein Platz frei, rückt die Person automatisch nach.
- Mehrfache Stripe-Benachrichtigungen führen **nicht** zu Doppel-Anmeldungen (idempotent).

## „Meine Kurse"

Erreichbar über Header → „Meine Kurse" (nur eingeloggt). Die Seite zeigt:

- **Statistik-Strip:** Anzahl aktiver Kurse, Wartelisten-Einträge, abgeschlossener Kurse.
- **Aktiv:** bestätigte, laufende Kurse mit (Platzhalter-)Fortschrittsbalken.
- **Warteliste:** Kurse mit Wartelisten-Hinweis.
- **Abgeschlossen:** bestätigte Kurse mit Status „done".

## Demo-Startzustand (nach `bin/rails db:reset`)

Die Lernende „Lena Lernerin" (`lena@example.com` / `geheim123`) hat über eine bezahlte
Bestellung „Prompt Engineering meistern" gebucht und ist zusätzlich in „Claude Code im
Projektalltag" angemeldet.

## Grenzen (bewusst)

- Der **Fortschrittsbalken** ist Anzeige-Deko — es gibt kein Lektions-Fortschritts-Modell.
- Bezahlte Buchung auf vollem Kurs → Warteliste statt Rückerstattung (siehe ADR 0007).

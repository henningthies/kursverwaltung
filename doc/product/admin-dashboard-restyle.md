# Verwaltung und Dashboard — was es kann

> Produkt-Dokumentation für den Human-in-the-Loop.

## Wozu

Die Verwaltung (nur für Admins) ist im selben violet-Stil wie der Marketplace neu eingekleidet
und um ein **KPI-Dashboard** ergänzt. Lern- und Verwaltungswelt sind klar getrennt, aber
optisch konsistent.

## So benutzt man es

1. Als Admin anmelden (`admin@example.com` / `geheim123`).
2. Header → „Verwaltung" führt zum Kurs-CRUD (`/courses`).
3. Dort oben rechts „Dashboard" (`/admin/dashboard`) öffnet die KPI-Startseite.
4. „Zur Lernansicht" springt zurück in den Marketplace.

## Was das Dashboard zeigt

- **KPI-Strip:** Aktive Kurse · Bestätigte Anmeldungen · Auf Warteliste · **Umsatz (bezahlt)**.
- **Kurs-Tabelle:** Titel + Leitung, Status-Pill, **Preis**, Anmeldungen (bestätigt / Kapazität,
  plus Wartelisten-Zahl), Termine, „Bearbeiten".

## Zugriff

- Nicht angemeldet → Weiterleitung zur Anmeldung.
- Als Lernende(r) → Weiterleitung zur Startseite mit Hinweis.
- Nur `admin` sieht Verwaltung und Dashboard.

## Hinweise

- Der **Umsatz** summiert nur **bezahlte** Bestellungen (live aus der Datenbank).
- Die Zeilen-Zähler je Kurs sind bewusst **nicht** optimiert — das ist die **N+1-Demo**
  (wie in der Kursübersicht) und wird hier nicht behoben.
- Der bestehende Kurs-/Termin-/Anmelde-CRUD ist unverändert, nur neu eingekleidet.

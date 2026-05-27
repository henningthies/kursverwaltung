# Kursdetailseite — was es kann

> Produkt-Dokumentation für den Human-in-the-Loop.

## Wozu

Jeder aktive Kurs hat jetzt eine **öffentliche Detailseite** im Marketplace-Stil. Sie ist
die zentrale Verkaufsseite: Besucher (ohne Login) sehen alles, was sie für eine
Kauf-Entscheidung brauchen.

## Was die Seite zeigt

- **Kopf:** Kategorie, Titel, Beschreibung, Teilnehmer- und Termin-Zahl, Trainer.
- **Preis-Karte (klebrig):** Preis (oder „Gratis"), Kapazitäts-Hinweis:
  - ausgebucht → „Dieser Kurs ist ausgebucht. Eine Buchung kommt auf die Warteliste."
  - knapp → „Nur noch X von Y Plätzen frei".
  - Buchungs-Buttons: „Jetzt buchen" und (bei bezahlten Kursen) „In den Warenkorb".
    *Die Buttons werden in Epic 4 mit Warenkorb/Bezahlung verbunden.*
- **Lehrplan & Termine:** alle Termine des Kurses als Liste.
- **Das bekommst du:** Nutzen-Liste.
- **Was Teilnehmer sagen:** Testimonials (feststehend).
- **Häufige Fragen:** FAQ (feststehend, aufklappbar).
- **Dein Trainer:** Trainer-Panel.

## So erreicht man sie

1. Im Marketplace `/` auf eine Kurs-Karte klicken → `/kurse/:id`.
2. Entwürfe und abgeschlossene Kurse sind **nicht** öffentlich erreichbar (404).

## Grenzen (bewusst)

- FAQ und Testimonials sind **feststehender Text**, kein verwaltbares Modell (siehe ADR 0005).
- Die Buchungs-Buttons sind in dieser Stufe noch **ohne Funktion** — der Kauf-Flow kommt in Epic 4.

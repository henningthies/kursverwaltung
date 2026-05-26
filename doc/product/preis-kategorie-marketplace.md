# Marketplace, Preise und Kategorien — was es kann

> Produkt-Dokumentation für den Human-in-the-Loop.

## Wozu

Die Startseite ist jetzt ein **öffentlicher Marketplace**: Besucher (ohne Login) sehen alle
**aktiven** Kurse als Karten mit Titel, Kategorie, Preis, Trainer und Teilnehmer-/Termin-Zahl.
Über Filter-Pills lässt sich nach Kategorie eingrenzen.

Kurse haben jetzt einen **Preis** und eine **Kategorie**:

- Preis `0` zeigt das Badge **„Gratis"** (Buchung später ohne Bezahlung).
- Volle Kurse zeigen **„Ausgebucht"**, knappe **„Fast ausgebucht"**.
- **Entwürfe** und abgeschlossene Kurse erscheinen **nicht** im Marketplace — nur in der
  Admin-Verwaltung unter `/courses`.

## So benutzt man es

### Als Besucher
1. Startseite `/` öffnen — alle aktiven Kurse erscheinen als Grid.
2. Filter-Pill (z. B. „KI & Automation") klicken → nur diese Kategorie. „Alle" hebt den Filter auf.

### Als Admin
1. Unter `/courses` (Header → „Verwaltung") einen Kurs anlegen/bearbeiten.
2. **Kategorie** auswählen (oder „Ohne Kategorie").
3. **Preis (in Cent)** eintragen: `12900` = 129,00 €, `0` = gratis.

## Preisanzeige

Preise werden aus Cent berechnet und deutsch formatiert (`12900 → 129,00 €`). `0` → „Gratis".

## Grenzen (bewusst)

- Der Preis wird im Admin in **Cent** eingegeben (kein Euro-Feld) — bewusst schlicht.
- Die Kurs-Karten zählen Teilnehmer/Termine pro Karte ohne Optimierung — das ist die
  **absichtliche N+1-Demo** und wird hier nicht behoben.

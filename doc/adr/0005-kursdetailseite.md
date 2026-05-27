# 0005. Kursdetailseite: FAQ/Testimonials hartkodiert, Buchungs-CTA als eigener Partial-Seam

- **Status:** Accepted
- **Datum:** 2026-05-27
- **Epic:** Learner-Marketplace Epic 3 — Einzel-Kursseite (Detail / Verkauf)
- **Plan:** `doc/product/learner-marketplace-epics.md`

## Kontext

Jeder aktive Kurs braucht eine öffentliche Verkaufsseite im Skillery-Layout: Titel + Meta,
klebrige Preis-Karte mit Kapazitäts-/Wartelisten-Zustand und Buchungs-CTA, Lehrplan
(Termine), Trainer-Panel, Testimonials und FAQ. Die Seite ist read-only und ohne Login
erreichbar; der eigentliche Kauf-Flow folgt erst in Epic 4.

## Entscheidung

1. **FAQ und Testimonials sind hartkodiert** (statisches Markup in den Partials
   `catalog/_faq` und `catalog/_testimonials`), **kein** eigenes Modell. Sie tragen keine
   Demo, die ein Modell rechtfertigt, und bleiben am Bildschirm sofort überblickbar.

2. **Kapazitäts-/Wartelisten-Anzeige nutzt die vorhandene Modell-Logik.** Die Preis-Karte
   liest `Course#full?`, `Course#almost_full?`, `Course#remaining_seats`, `Course#free?` —
   **keine** neue Logik. Ausgebucht → Wartelisten-Hinweis; knapp → „Nur noch X von Y frei".

3. **`CatalogController#show` zeigt nur aktive Kurse** (`Course.published.find`). Entwürfe
   und abgeschlossene Kurse liefern 404 (öffentlich nicht auffindbar).

4. **Der Buchungs-CTA ist ein eigener Partial-Seam (`catalog/_booking_actions`).** In Epic 3
   rendert er die Buttons („Jetzt buchen" / bei Gratis nur „Jetzt buchen", sonst zusätzlich
   „In den Warenkorb") als reine UI. **Epic 4 ersetzt genau diesen Partial** durch echte
   Formulare gegen den Session-Warenkorb und den Checkout — ohne die Detailseite anzufassen.
   So dockt der „In den Warenkorb"-Button sauber an den Session-Cart aus Epic 4 an.

## Begründung (warum einfach)

- **Hartkodiert** spart zwei Modelle, Migrationen, CRUD und Tests, die nichts demonstrieren.
- **Modell-Logik wiederverwenden** statt duplizieren ist die zentrale vanilla-Regel und hält
  die Kapazitäts-Wahrheit an einem Ort (`Course`).
- **Der Partial-Seam** trennt die Verkaufsseite (Epic 3) sauber vom Kauf-Mechanismus (Epic 4):
  ein klar benannter Andockpunkt statt verstreuter Bedingungen.

## Verworfene Alternativen

- **`Faq`-/`Testimonial`-Modelle.** Over-Engineering ohne Demo-Nutzen; verworfen.
- **CTA direkt in `_price_card` einbetten.** Würde Epic 4 zwingen, die Karte umzubauen statt
  einen klar abgegrenzten Partial zu ersetzen; verworfen zugunsten des Seams.
- **Detailseite auch für Entwürfe öffnen (Vorschau).** Würde unveröffentlichte Kurse öffentlich
  machen; verworfen — Vorschau gehört in die Admin-Verwaltung.

## Konsequenzen

- Die Marketplace-Karten verlinken auf `catalog_course_path` (`/kurse/:id`).
- Epic 4 berührt nur `catalog/_booking_actions` (+ neue Cart/Checkout-Controller), nicht die
  Detailseite selbst.

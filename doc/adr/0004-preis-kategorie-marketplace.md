# 0004. Preis als Integer-Cents, Kategorie als eigenes Modell, getrennter Marketplace-Controller

- **Status:** Accepted
- **Datum:** 2026-05-27
- **Epic:** Learner-Marketplace Epic 2 — Preise + Kategorien + Marketplace-Übersicht
- **Plan:** `doc/product/learner-marketplace-epics.md`

## Kontext

Kurse brauchen einen Preis und eine Kategorie, und Besucher brauchen eine öffentliche,
gefilterte Übersicht (Landing). Der bestehende `CoursesController` ist die **Admin**-Verwaltung
(jetzt hinter `require_admin`); die Lern-Sicht muss davon getrennt sein. Geld darf nie als
Float dargestellt oder gespeichert werden.

## Entscheidung

1. **Geld als `price_cents:integer` (Default 0).** Kein `monetize`-Gem, keine Float-Spalte.
   Validierung `numericality: { greater_than_or_equal_to: 0, only_integer: true }`. Anzeige
   über den View-Helper `price_display(price_cents)` (`12900 → "129,00 €"`, `0 → "Gratis"`).
   `Course#free?` (`price_cents.zero?`) trägt die Gratis-Logik im Modell.

2. **`Category` als eigenes Modell** mit `name` (unique) und `slug` (unique, aus dem Namen
   via `parameterize`, `to_param` gibt den Slug). `Course.belongs_to :category, optional: true`
   (nullable FK), `Category.has_many :courses, dependent: :nullify`. Filter über `?category=<slug>`.

3. **Getrennter `CatalogController` (öffentlich)** statt Erweiterung des Admin-Controllers.
   `allow_unauthenticated_access only: [:index]`, eigenes `marketplace`-Layout mit
   lernenden-zugewandtem Header. Wurzelroute `/` zeigt jetzt den Katalog; Admin liegt unter
   `/courses`. Sichtbar sind nur aktive Kurse (`scope :published`); Filter über
   `scope :in_category` (nil = alle).

4. **N+1-Demo bleibt erhalten.** Die Kurs-Karten zählen `confirmed_count` und `sessions.count`
   pro Karte ohne `includes`/`counter_cache` — die bewusste Performance-Demo wandert mit in
   den Marketplace (kommentiert).

## Begründung (warum einfach)

- **Integer-Cents** sind exakt (keine Rundungsfehler) und in jeder DB trivial. Ein Helper
  für die Anzeige reicht — ein Gem wäre Over-Engineering für eine Lehr-Demo.
- **Eigenes `Category`-Modell** (statt String-Feld) ermöglicht eindeutige Slugs für Filter-URLs
  und saubere Pills, bleibt aber ein Zwei-Felder-Modell — am Bildschirm sofort überblickbar.
- **Getrennter Controller** hält Lern- und Verwaltungssicht klar auseinander: der Admin-CRUD
  bleibt unverändert (inkl. seiner Demo-Schwachstellen), die Lern-Sicht ist öffentlich und
  read-only. Beide teilen Modell und Helper, nicht den Controller.

## Verworfene Alternativen

- **`monetize`/`money`-Gem.** Zusätzliche Abhängigkeit und API für einen einzigen Preis-Wert —
  widerspricht „keine Abstraktions-Gems".
- **`price_cents` im Admin-Controller wiederverwenden für die öffentliche Liste.** Würde die
  Trennung Lernen/Verwalten verwässern und das Rollen-Gate (`require_admin`) auf der Landing
  unmöglich machen (die muss öffentlich sein).
- **Kategorie als String-Spalte an `Course`.** Keine eindeutigen Slugs, keine saubere
  Filter-Liste, Tippfehler-anfällig. Verworfen.

## Konsequenzen

- Die Admin-Kursform bekommt Felder für Kategorie (`collection_select`) und Preis (`price_cents`
  in Cent, Label „0 = gratis"). Bewusst kein Euro-Eingabefeld (keine virtuelle Attribut-Logik).
- `price_display` lebt im `ApplicationHelper` und wird ab Epic 3/4 (Detail, Checkout) wieder genutzt.

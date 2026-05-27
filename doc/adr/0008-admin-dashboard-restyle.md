# 0008. Admin-Gate über require_admin + Admin::-Namespace fürs Dashboard; Umsatz live aggregiert

- **Status:** Accepted
- **Datum:** 2026-05-27
- **Epic:** Learner-Marketplace Epic 6 — Admin-Restyle + Trainer-Dashboard
- **Plan:** `doc/product/learner-marketplace-epics.md`

## Kontext

Der bestehende Verwaltungs-CRUD soll im violet-Stil neu eingekleidet und um Preis-Spalte,
Umsatz-KPI und Anmelde-/Wartelisten-Zähler ergänzt werden — Zugriff nur für `admin`. Offene
Fragen: Gate-Strategie (`require_admin` vs. eigener `Admin::`-Namespace) und ob die Umsatz-KPI
live aggregiert oder über `counter_cache` läuft.

## Entscheidung

1. **Hybrides Gate.** Das Rollen-Gate ist `before_action :require_admin` (aus dem
   Authentication-Concern, Epic 1) — bereits auf den bestehenden `CoursesController`,
   `SessionsController`, `EnrollmentsController` angewandt. Diese Controller bleiben **unverändert
   in ihrer Struktur** (kein Umzug in einen Namespace), damit der getestete CRUD und seine
   bewussten Demo-Schwachstellen (N+1, PII-Export) erhalten bleiben.

2. **Nur das neue Dashboard liegt im `Admin::`-Namespace** (`Admin::DashboardController`,
   Route `/admin/dashboard`). Das hält die KPI-Startseite klar als „Verwaltungs-Einstieg"
   erkennbar, ohne den restlichen CRUD umzubauen.

3. **Eigenes `admin`-Layout** mit „Verwaltung"-Badge und „Zur Lernansicht"-Link. Die drei
   CRUD-Controller und das Dashboard nutzen es, sodass Lern- und Verwaltungswelt sichtbar
   getrennt, aber im selben violet-Stil sind.

4. **Umsatz live aggregiert, kein `counter_cache`.** `Order.revenue_cents` ist
   `Order.paid.sum(:total_cents)` — eine einzelne DB-Aggregation pro Seitenaufruf. Die
   Zeilen-Zähler (Anmeldungen/Warteliste/Termine je Kurs) bleiben bewusst ohne `includes`/
   `counter_cache` → die **N+1-Demo** wandert in die Admin-Tabelle.

## Begründung (warum einfach)

- **Bestehenden CRUD nicht umbenennen** vermeidet Churn an getestetem Code und bewahrt die
  Demo-Schwachstellen genau dort, wo der Kurs sie zeigt.
- **Nur das Dashboard namespacen** gibt der neuen KPI-Seite einen klaren Ort, ohne eine große
  Umstrukturierung zu erzwingen — minimaler additiver Schritt.
- **Live-Aggregation** ist eine triviale SQL-Summe; ein `counter_cache` für Umsatz wäre
  zusätzlicher Schreibpfad/Migration ohne Demo-Nutzen. Die N+1-Demo lebt ohnehin in den
  Zeilen-Zählern — Umsatz muss sie nicht zusätzlich tragen.

## Verworfene Alternativen

- **Gesamten CRUD nach `Admin::` verschieben.** Großer Churn (Routen, Tests, View-Pfade) ohne
  Demo-Nutzen; verworfen.
- **`counter_cache`/aggregierte Umsatz-Spalte.** Migration + Schreibpfad-Pflege; verworfen
  zugunsten der einfachen Live-Summe.
- **KPIs im Controller berechnen statt im Modell.** `Order.revenue_cents` lebt im Modell
  (vanilla: Logik in Modellen); der Controller setzt nur Instanzvariablen.

## Konsequenzen

- `/admin/dashboard` ist die KPI-Startseite; `/courses` bleibt der vertraute CRUD (jetzt im
  admin-Layout, mit Preis-Spalte und Dashboard-Link).
- Die Umsatz-KPI zählt nur `paid`-Bestellungen; `pending`/`failed` fließen nicht ein.

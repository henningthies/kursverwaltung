# Mockups — Learner-Marketplace (Skillery-Stil)

Statische HTML-Mockups als **Referenz-Ziele** für den Ausbau der Kursverwaltung zu einer
lernenden-zugewandten Kurs-Plattform mit echtem E-Commerce. Sie sind nicht verdrahtet —
sie zeigen Layout, Komponenten-Vokabular und Copy, an denen sich `feature-build` orientiert.

- **Stil:** violet-600-Akzent, `rounded-xl`-Karten, Pill-Badges, `gray-50`-Seitengrund,
  großzügiger Weißraum, deutsche Texte — gemäß `doc/design/ui-style-guide.md`.
- **Technik:** Tailwind CDN + Inter (nur für die Mockups; die App nutzt ihre vorhandene
  Tailwind-Pipeline). Keine echte Logik, Links springen exemplarisch zwischen den Seiten.
- **Vorbild:** `kursplaner.webp` (Skillery) — übernommen wird das *Komponenten- und
  Layout-Vokabular*, nicht 1:1 das Original.

## Seiten

| Datei | Zielgruppe | Inhalt |
|-------|-----------|--------|
| `marketplace.html` | Besucher / Lernende | Hero mit Suche, Kategorie-Filter-Pills, Kurs-Grid (Karten mit Preis, Bewertung, Kategorie-Pill, Kapazitäts-Badge) |
| `course-detail.html` | Besucher / Lernende | Kursdetail im Skillery-Layout: Titel + Meta, **klebrige Preis-Karte** (Preis, „Jetzt buchen“ / „In den Warenkorb“, Kapazitäts-/Wartelisten-Zustand, „Das bekommst du“), Kursüberblick, Lehrplan/Termine als Akkordeon, Trainer-Panel, Testimonials, FAQ |
| `my-courses.html` | Lernende (eingeloggt) | „Meine Kurse“-Dashboard: Statistik-Strip, Tabs (Aktiv / Warteliste / Abgeschlossen), Kurs-Karten mit Fortschrittsbalken, Wartelisten-Hinweis, Empfehlungen |
| `auth.html` | Besucher | Registrieren + Anmelden (Split-Layout mit Brand-Panel) |
| `checkout.html` | Lernende | Warenkorb, Stripe-Checkout-Übergabe (Testmodus-Hinweis), Bestellübersicht mit Gutschein, USt., Gesamt |
| `admin-dashboard.html` | Admins | Neu eingekleideter Verwaltungseinstieg: KPI-Strip, Kurs-Tabelle mit Status-Pills, Preis-Spalte, Anmelde-/Termin-Zählern |

## Bezug zum Datenmodell

Die Mockups setzen die Modelländerungen aus
`doc/product/learner-marketplace-epics.md` voraus (User mit Rolle learner/admin,
`price_cents` + `Category` an Course, Order/OrderItem, Cart). Die Kapazitäts-/Wartelisten-
Zustände in `course-detail.html` und `my-courses.html` bilden die **bestehende**
`Enrollment`-Logik ab (confirmed / waitlisted) — der Kauf erzeugt die Enrollment.

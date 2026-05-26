# UI-Style-Guide — Kursverwaltung

Verbindliche Look-and-Feel-Referenz für **alle Views**. Jede View-bauende Factory-Stufe
(`feature-build`) und jede UI-Änderung folgt diesen Tokens. Vorbild: das *Skillery*-EdTech-Design
(`kursplaner.webp`) — übernommen werden **Tokens und Komponenten-Vokabular**, nicht das
Landingpage-Layout. Unsere App ist deutsches Admin-CRUD (Kurse/Termine/Anmeldungen).

## Grundhaltung

Modern, freundlich, vertrauenswürdig — EdTech-SaaS. Viel Weißraum, runde Geometrie, feine
Borders statt schwerer Schatten, Icon-akzentuierte Listen. Lieber Luft als Dichte.

## Farben (Tailwind-Skalen)

| Rolle | Token |
|-------|-------|
| **Akzent** (primäre Aktionen, Links, aktive Zustände) | `violet-600`, Hover `violet-700` |
| Akzent-Fläche (ruhige Tönung) | `violet-50` |
| Akzent-Text (Labels/Tags auf hellem Grund) | `violet-700` |
| Seiten-Hintergrund | `gray-50` |
| Karten / Panels | `white` |
| Borders (Hairline) | `gray-200`, Hover `gray-300` |
| Überschriften | `gray-900` |
| Fließtext | `gray-600` |
| Sekundär / gedämpft | `gray-500` |
| Sterne / Bewertung | `amber-400` |

> Der frühere blaue Akzent (`blue-600`) wird auf `violet-600` umgestellt. Keine blauen
> Akzente in neuen Views.

## Typografie

- Überschriften **fett, eng** (`font-bold tracking-tight`, `text-gray-900`).
- Klare Größensprünge: Seitentitel `text-2xl`/`text-3xl`, Abschnittstitel `text-xl`,
  Kartentitel `text-lg font-semibold`.
- Fließtext klein und ruhig: `text-sm text-gray-600`, entspannte Zeilenhöhe.

## Komponenten-Vokabular

**Karte** (dominante Einheit — Listen-Items, Panels):
```erb
class="rounded-xl border border-gray-200 bg-white p-5 hover:border-gray-300 transition"
```

**Primär-Button** (eine pro Kontext):
```erb
class="rounded-lg bg-violet-600 px-4 py-2 text-white font-medium hover:bg-violet-700"
```

**Sekundär-Button** (Abbrechen, Nebenaktion):
```erb
class="rounded-lg border border-gray-300 bg-white px-4 py-2 text-gray-700 hover:bg-gray-50"
```

**Pill / Badge** (Status, Meta-Infos, Tags) — runde Form, getönte Fläche, optional Leading-Icon:
```erb
class="inline-flex items-center gap-1 rounded-full px-3 py-1 text-xs font-medium"
```

**Eyebrow-Label** (kleine Kategorie über einer Überschrift):
```erb
class="text-xs font-semibold uppercase tracking-wide text-violet-700"
```

## Status-Badges (Semantik beibehalten)

`Course#status` und `Enrollment#status` werden als Pills dargestellt:

| Status | Tönung |
|--------|--------|
| `draft` | `bg-gray-100 text-gray-700` |
| `active` / `confirmed` | `bg-green-100 text-green-800` |
| `done` | `bg-violet-100 text-violet-800` |
| `waitlisted` | `bg-amber-100 text-amber-800` |
| `cancelled` | `bg-gray-100 text-gray-500` |

Die Badge-Logik lebt zentral im Helper (`course_status_badge` o. Ä.), nicht inline je View.

## Layout

- Zentrierter Container, großzügige vertikale Abstände (`space-y-*`, `mb-6`+).
- Abschnitt = Eyebrow/Überschrift + Inhalt mit klarem Rhythmus.
- Detail-Seiten dürfen zweispaltig sein (Hauptinhalt + schmales Meta-/Aktions-Panel),
  solange es am Bildschirm in Sekunden überblickbar bleibt (Leitplanke aus `FEATURES.md`).

## Nicht tun

- Keine schweren Schatten, keine Verläufe in Admin-Listen, kein blauer Akzent.
- Keine eigenen Hex-Werte außerhalb dieser Tabelle — nur Tailwind-Skalen.
- Kein Markup-Wildwuchs: wiederkehrende Bausteine als Partials/Helper, nicht kopiert.

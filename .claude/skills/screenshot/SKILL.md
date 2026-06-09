---
name: screenshot
description: >-
  Erstellt mit Playwright einen Screenshot zu einer angegebenen URL. Nutzen,
  sobald jemand einen Screenshot/Bildschirmfoto einer Seite oder URL möchte —
  z. B. "Screenshot von http://localhost:3000", "mach ein Bild von der
  Startseite", "screenshot die Kursübersicht".
---

# Screenshot (Playwright)

Erstellt einen Screenshot einer URL über die Playwright-MCP-Tools. Schlank und ohne
Schnörkel: navigieren, knipsen, Pfad ausgeben.

## Ablauf

1. **URL bestimmen.** Nennt der User eine URL, die nehmen. Ohne URL ist der Default
   die lokale App `http://localhost:3000` (läuft per `bin/dev`). Bei relativem Pfad
   (z. B. „Kursdetail") an die Basis-URL anhängen.

2. **Navigieren** mit `mcp__playwright__browser_navigate` auf die URL.

3. **Screenshot** mit `mcp__playwright__browser_take_screenshot`:
   - `filename`: sprechender Name, z. B. `startseite.png`. Default-Ablage ist der
     Projekt-Root (`/home/henning/rheinwerk/kursverwaltung/`).
   - `type`: `png` (Default).
   - **Ganze Seite** nur wenn gewünscht → `fullPage: true`. Sonst sichtbarer Viewport.
   - Für ein bestimmtes Element `element` + `ref` aus einem vorherigen
     `mcp__playwright__browser_snapshot` setzen.

4. **Ausgeben.** Eine Zeile: gespeicherter Datei-Pfad. Kein Fließtext.

## Hinweise

- Braucht die App eine bestimmte Größe (z. B. Mobile), vorher
  `mcp__playwright__browser_resize` (etwa `390×844`).
- Erfordert die Seite Login, vorher per `browser_navigate` auf `/anmelden` und über
  die Demo-Logins (`admin@example.com` / `lena@example.com`, Passwort `geheim123`)
  einloggen — nur wenn die Zielseite hinter Auth liegt.
- Läuft der Server nicht, kurz melden statt auf einen Fehler-Screenshot zu warten.

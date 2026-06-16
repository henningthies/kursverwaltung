# PRD — <Feature-Titel>

- **Slug:** <slug>  ·  **ADR:** doc/adr/NNNN-<slug>.md  ·  **Mockups:** mockups/<slug>-*.html

## Ziel & Nutzer
<Ein Absatz: wer, was, warum.>

## Scope / Nicht-Scope
- **Drin:** …
- **Bewusst nicht:** …

## User Flows
<Schritt-für-Schritt je Flow, inkl. Zustände leer/voll/Fehler.>

## Datenmodell
<Neue Modelle/Spalten/Beziehungen, Migrationen, STATUSES/ROLES, *_cents.>

## Akzeptanzkriterien
- [ ] <überprüfbar, je eine Zeile>

## Test-Edge-Cases
<Tabelle/Liste: Fall → erwartetes Verhalten. Kapazität, leere Listen, Auth,
Idempotenz, Geld, Validierungsfehler. Das ist die Test-Vorlage für feature-build.>

## Umsetzungsplan (TDD-first)
1. **Test zuerst:** <welche Tests + Fixtures>
2. **Migration/Modell:** …
3. **Controller/Routes:** …
4. **Views:** … (nach mockups/<slug>-*.html + ui-style-guide.md)
5. **Review:** feature-review.

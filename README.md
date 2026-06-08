# Kursverwaltung

Demo-App aus dem Rheinwerk-Online-Kurs *Claude Code im Projektalltag* — ein kleiner
Kurs-Marktplatz auf **Rails 8** (Katalog, Warenkorb mit Stripe-Checkout, „Meine Kurse",
plus Admin-Bereich für Kurse, Termine und Anmeldungen). Bewusst eine ganz normale,
mittelgroße Rails-App, an der sich Claude-Code-Workflows zeigen lassen.

> **Worum es eigentlich geht:** weniger die App selbst als die Frage, wie man Claude Code
> zum *Projektpartner* konfiguriert. Die spannenden Dateien liegen unter `.claude/`
> (Skills, Hooks, Agents) plus die `CLAUDE.md` — die kommen mit dem **Termin-2-Stand** dazu.
> Gedacht zum Abschauen und Übertragen auf das eigene Projekt.

## Lokal starten

Voraussetzung: **Ruby 3.4**.

```bash
bin/setup     # Abhängigkeiten installieren + DB vorbereiten
bin/dev       # Server starten → http://localhost:3000
```

Demo-Logins (Passwort `geheim123`):

- `admin@example.com` — Admin (Kurse, Termine, Anmeldungen verwalten)
- `lena@example.com` — Lernende (browsen, kaufen)

Stripe läuft ohne Keys gestubbt (Suite bleibt grün). Tests: `bin/rails test`.

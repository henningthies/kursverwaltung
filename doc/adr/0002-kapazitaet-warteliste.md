# 0002. Warteliste geordnet nach created_at, kein position-Integer

- **Status:** Accepted
- **Datum:** 2026-05-26
- **Feature:** feature/kapazitaet-warteliste  ·  Plan: `.claude/factory/plans/kapazitaet-warteliste.md`

## Kontext

Die Kursverwaltung bekommt eine Kapazitäts- und Wartelisten-Funktion: Ist ein Kurs voll,
landen neue Anmeldungen im Status `waitlisted`. Wird eine bestätigte Anmeldung storniert,
rückt der nächste wartende Teilnehmer nach. Die Kern-Frage: **Nach welcher Reihenfolge wird
bestimmt, wer als Nächstes nachrückt?**

Demo-Kontext (T3 `01-feature-zu-pr`): Die Promotions-Logik entsteht live, Test-first.
Sie ist bewusst eine Stelle, an der Over-Engineering entstehen könnte (T3 `03-wenn-es-schiefgeht`).
Randbedingungen: vanilla Rails, SQLite, keine extra Gems, lesbar am Bildschirm in Sekunden.

## Entscheidung

Die Warteliste wird durch `ORDER BY created_at ASC` auf der `enrollments`-Tabelle geordnet.
Wer sich zuerst eingetragen hat, rückt als Erster nach. Es wird **keine** eigene
`position:integer`-Spalte eingeführt. Die Methode `Course#promote_next_waitlisted` liest
den ältesten wartenden Eintrag mit:

```ruby
enrollments.waitlisted.oldest_first.first
```

wobei `scope :oldest_first, -> { order(:created_at) }` auf `Enrollment` definiert ist.

## Begründung (warum einfach)

`created_at` ist bereits vorhanden — keine Migration nötig. Die Semantik „wer zuerst
kommt, mahlt zuerst" ist dem Demo-Publikum sofort klar und braucht keine Erklärung.
Die Abfrage ist eine einfache DB-Query ohne zusätzliche Zustandsverwaltung. Ein Fehler
in dieser Logik (z. B. falsches Ordering) ist in Tests mit `assert_equal` präzise
nachweisbar — ideal für die `03-wenn-es-schiefgeht`-Demo.

## Verworfene Alternativen

- **`position:integer`-Spalte mit Neuordnung bei Promotion** — verworfen, weil: erfordert
  eine extra Migration, erfordert einen Reorder-Schritt nach jeder Promotion (`UPDATE`
  mehrerer Zeilen), erhöht die Komplexität des `promote_next_waitlisted`-Codes ohne
  Demo-Mehrwert. Eine manuelle Priorisierung durch den Kursleiter ist kein Ziel dieser App.
  Der Aufwand trägt keine Demo.
- **`Enrollment`-Callbacks (`after_update`)** für die automatische Promotion — verworfen,
  weil implizite Callbacks Business-Logik verstecken. Der Kurs ist Demo-Material; explizite
  Methodenaufrufe (`enrollment.cancel` → `course.promote_next_waitlisted`) sind am
  Bildschirm lesbar und folgen der 37signals-Konvention „Logic in models, not callbacks
  for business logic".

## Konsequenzen

Leichter: Die Implementierung der Promotions-Logik ist 3–5 Zeilen Ruby, nachvollziehbar
in der Live-Demo. Tests können `created_at` über Fixtures steuern um die Reihenfolge
deterministisch zu halten.

Schwerer: Eine nachträgliche manuelle Priorisierung (Platz für VIP-Kunden) wäre nicht
möglich ohne Umbau — das ist für diese Demo-App irrelevant.

Offen: Ob `capacity: nil` als „unbegrenzt" oder als „Kapazität unbekannt / gesperrt"
gilt, ist definiert als unbegrenzt (`full?` → immer `false`). `capacity: 0` ist explizit
durch Validierung ungültig.

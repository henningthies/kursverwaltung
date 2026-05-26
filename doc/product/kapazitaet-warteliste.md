# Kapazität und Warteliste — was es kann

> Produkt-Dokumentation für den Human-in-the-Loop. Beschreibt das Feature aus
> Nutzer-Sicht, ohne Code. Wer die App benutzt und das Ergebnis abnimmt, soll hier
> verstehen, *was* das Feature tut und *wie* man es bedient.

## Wozu

Kurse können jetzt eine Teilnehmer-Obergrenze haben. Ist ein Kurs voll, landen weitere
Anmeldungen automatisch auf der Warteliste — kein manuelles Nachhalten nötig. Sagt jemand
ab, rückt die nächste Person von der Warteliste automatisch nach.

## So benutzt man es

### Kapazität für einen Kurs festlegen

1. Kurs öffnen → „Bearbeiten" klicken.
2. Im Feld „Kapazität" die maximale Teilnehmerzahl eintragen (z. B. 2).
3. Speichern. Bleibt das Feld leer, ist der Kurs unbegrenzt offen.

### Teilnehmer anmelden

1. Kursdetailseite öffnen.
2. Im Abschnitt „Anmeldungen" unten das Formular „Anmelden" ausfüllen: Name und E-Mail.
3. „Anmelden" klicken.
   - Ist noch Platz frei: Anmeldung erscheint sofort in der Liste „Bestätigt".
   - Ist der Kurs voll: Anmeldung landet automatisch in der „Warteliste".

### Teilnehmer abmelden

1. In der Liste „Bestätigt" oder „Warteliste" neben dem Namen auf „Abmelden" klicken.
2. Bestätigen.
   - War die Person bestätigt und steht jemand auf der Warteliste: Die nächste Person
     (nach Anmeldedatum — wer zuerst gewartet hat) rückt automatisch auf „Bestätigt".
   - War die Warteliste leer: Der Platz bleibt frei, kein Fehler.

## Regeln, die sichtbar werden

- **Kurs voll → Warteliste:** Sobald alle Plätze belegt sind, wird jede neue Anmeldung
  als „Warteliste" eingetragen. Die Meldung lautet „Sie stehen auf der Warteliste."
- **Absage → automatisches Nachrücken:** Sagt eine bestätigte Person ab, rückt die
  Person, die am längsten auf der Warteliste wartet, automatisch nach.
- **Reihenfolge der Warteliste:** Anmeldedatum entscheidet — wer sich zuerst eingetragen
  hat, rückt als Erste:r nach.
- **Unbegrenzte Kapazität:** Ist kein Kapazitätswert gesetzt, kann sich unbegrenzt viele
  Teilnehmer anmelden. Es gibt keine Warteliste.
- **Doppel-Anmeldung blockiert:** Dieselbe E-Mail-Adresse kann sich pro Kurs nur einmal
  anmelden. Ein zweiter Versuch wird abgewiesen.
- **Kapazität 0 ist ungültig:** Eine Kapazität von 0 wird beim Speichern abgelehnt.

## Was es (bewusst) nicht tut

- **Keine E-Mail-Benachrichtigung:** Wenn jemand von der Warteliste nachrückt, wird keine
  automatische E-Mail verschickt. Die Kursleiterin oder der Kursleiter muss die Person
  selbst informieren.
- **Keine manuelle Priorisierung:** Die Wartelisten-Reihenfolge ist fest (Anmeldedatum).
  Es gibt keine Möglichkeit, einzelne Personen vorzuziehen.
- **Keine Teilnehmer-Verwaltungsseite:** Teilnehmer sind nur über Kursanmeldungen sichtbar.
  Es gibt keine eigene Liste aller Teilnehmer.
- **Kein Login/Authentifizierung:** Anmeldungen können von jedem ohne Passwort vorgenommen
  werden — die App ist eine Demo-Anwendung ohne Nutzerkonten.

## Abnahme-Check

Kurze Liste, mit der die abnehmende Person das Feature selbst prüfen kann:

- [ ] Kurs „Rails Performance" öffnen: Kapazität 2, 2 bestätigte Anmeldungen (Alice, Bob), 1 Warteliste-Eintrag (Carol) sichtbar.
- [ ] Neuen Teilnehmer mit beliebiger E-Mail anmelden → Meldung „Sie stehen auf der Warteliste" erscheint.
- [ ] Alice bei „Rails Performance" abmelden → Carol wechselt automatisch von „Warteliste" zu „Bestätigt".
- [ ] Einen Kurs ohne Kapazitätslimit öffnen (z. B. „Claude Code im Projektalltag") → beliebig viele Anmeldungen möglich, keine Warteliste.
- [ ] Dieselbe E-Mail-Adresse zweimal für denselben Kurs anmelden → zweite Anmeldung wird abgewiesen.
- [ ] Kurs bearbeiten, Kapazität 0 eintragen → Fehler beim Speichern.

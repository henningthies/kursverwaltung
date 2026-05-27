# Warenkorb und Bezahlung — was es kann

> Produkt-Dokumentation für den Human-in-the-Loop.

## Wozu

Lernende können bezahlte Kurse in einen **Warenkorb** legen und über **Stripe** bezahlen.
Eine erfolgreiche Zahlung erzeugt eine **Bestellung** (`Order`) mit den gekauften Kursen.
Kostenlose Kurse werden ohne Bezahlseite direkt gebucht.

## So benutzt man es

1. Auf einer Kursdetailseite „In den Warenkorb" (oder bei Gratis-Kursen „Jetzt buchen") klicken.
   (Ohne Login wirst du zuerst zur Anmeldung geleitet.)
2. Oben rechts auf das **Warenkorb-Symbol** klicken — es zeigt die Anzahl der Kurse.
3. Im Warenkorb die Bestellübersicht prüfen, Kurse bei Bedarf entfernen.
4. „Jetzt bezahlen" → Weiterleitung zu **Stripe Checkout** (Testmodus). Nach Abschluss
   landest du auf der Bestätigungsseite mit deiner Bestellübersicht.
5. Bei kostenlosen Kursen entfällt Schritt 4 — „Jetzt buchen" bestätigt sofort.

## Wichtig zur Bezahlung

- **Testmodus:** Solange keine echten Stripe-Schlüssel hinterlegt sind, ist keine echte
  Zahlung möglich. Der Checkout zeigt dann eine klare Meldung statt eines Fehlers.
- **Verlässliche Bestätigung:** Die Bestellung wird über einen Stripe-**Webhook** auf
  „bezahlt" gesetzt — auch wenn du den Browser-Tab vorzeitig schließt. Doppelte Benachrichtigungen
  von Stripe ändern nichts (idempotent).
- **Preis-Snapshot:** Der gezahlte Preis wird in der Bestellung festgehalten; spätere
  Preisänderungen am Kurs verändern alte Bestellungen nicht.

## Demo-Schlüssel hinterlegen (optional, für echten Test-Checkout)

In `config/credentials.yml.enc` (oder als ENV):

```
stripe:
  secret_key: sk_test_...
  webhook_secret: whsec_...
```

## Grenzen (bewusst)

- Kein Gutschein-/USt.-Rechner — die Bestellübersicht zeigt Zwischensumme = Gesamt.
- Die **Buchung in „Meine Kurse"** aus einer bezahlten Bestellung kommt in Epic 5.

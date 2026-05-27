# 0006. Session-Warenkorb, Stripe Checkout hinter Wrapper, Order über idempotenten Webhook

- **Status:** Accepted
- **Datum:** 2026-05-27
- **Epic:** Learner-Marketplace Epic 4 — Warenkorb + Stripe-Checkout + Order
- **Plan:** `doc/product/learner-marketplace-epics.md`

## Kontext

Lernende sollen Kurse in einen Warenkorb legen, zur Kasse gehen und über Stripe bezahlen.
Eine erfolgreiche Zahlung erzeugt einen `Order` mit `OrderItem`s im Status `paid`. Der
Zahlungs-Code muss test-freundlich sein: ohne Stripe-Keys darf weder Boot noch Test-Suite
brechen, und kein Live-Stripe-Call in CI.

## Entscheidung

1. **Session-Warenkorb, kein DB-`Cart`-Modell.** Der Warenkorb lebt in
   `session[:cart_course_ids]`. Ein PORO `Cart` kapselt die IDs und liefert Kurse + Summe.
   `CartsController` (show/add/remove) schreibt die IDs zurück in die Session.

2. **Geld als Integer-Cents mit Snapshot.** `Order.total_cents` und `OrderItem.price_cents`
   sind Integer; `Order#add_courses` schreibt den Kurspreis als Snapshot in jedes Item, sodass
   spätere Preisänderungen alte Bestellungen nicht verfälschen.

3. **Stripe Checkout (gehostet) hinter `PaymentGateway`-Wrapper.** Ein dünnes Modul kapselt
   `Stripe::Checkout::Session.create` und `Stripe::Webhook.construct_event`. Keys kommen aus
   Credentials (`stripe.secret_key`) oder ENV. Fehlen sie, wirft der Wrapper `NotConfigured`;
   der Checkout-Pfad fängt das ab und zeigt eine klare Meldung statt einer Exception. In Tests
   wird der Wrapper gestubbt — **kein echter Stripe-Call**.

4. **Order wird über den Webhook auf `paid` gesetzt, idempotent.** `WebhooksController#stripe`
   (öffentlich, ohne CSRF) verifiziert das Event über den Wrapper und ruft `Order#mark_paid!`.
   `mark_paid!` ist idempotent (ein bereits bezahlter Order bleibt unverändert), die
   Zuordnung läuft über die eindeutige `stripe_session_id` (DB-Unique-Index + Validierung).
   Doppelte Webhooks ändern `paid_at` nicht.

5. **Gratis-Bestellungen ohne Checkout.** Ist die Warenkorb-Summe 0, wird der Order sofort
   als `paid` markiert und auf die Bestätigungsseite umgeleitet — kein Stripe nötig.

## Begründung (warum einfach)

- **Session-Cart** vermeidet Aufräum-Logik für verwaiste DB-Carts, die hier keine Demo trägt.
- **Stripe Checkout** (gehostete Seite) statt Payment Intents im eigenen Frontend: weniger
  PCI-Fläche, kein eigenes Karten-JS, weniger Code am Bildschirm.
- **Webhook statt nur Success-Redirect:** der Redirect kann ausbleiben (Tab geschlossen);
  der Webhook ist die verlässliche Quelle der Wahrheit. Idempotenz über `stripe_session_id`
  schützt vor Stripes Mehrfach-Zustellung.
- **Wrapper + Stub** hält Stripe an einer Stelle und die Suite grün ohne Keys.

## Verworfene Alternativen

- **Persistentes `Cart`-Modell.** Mehr Tabellen + Aufräum-Logik ohne Demo-Nutzen.
- **Stripe Payment Intents im eigenen Frontend.** Mehr JS, mehr PCI-Fläche.
- **Order nur über den Success-Redirect bezahlen.** Unzuverlässig, wenn der Redirect ausbleibt.
- **`monetize`-Gem.** Unnötige Abhängigkeit; Integer-Cents reichen.

## Konsequenzen

- Echte Live-Zahlung braucht Stripe-Test-Keys in Credentials/ENV (Boot/Tests laufen ohne).
- Die eigentliche **Buchung (Enrollment)** aus einer bezahlten Bestellung folgt in Epic 5 —
  Epic 4 erzeugt nur den bezahlten `Order`.
- Der Detailseiten-CTA aus Epic 3 ist jetzt mit dem Warenkorb verdrahtet (`_booking_actions`).

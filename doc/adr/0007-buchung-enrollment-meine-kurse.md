# 0007. Enrollment erst nach bestätigter Zahlung; bezahlte Buchung bei vollem Kurs → Warteliste

- **Status:** Accepted
- **Datum:** 2026-05-27
- **Epic:** Learner-Marketplace Epic 5 — Buchung an Enrollment koppeln + „Meine Kurse"
- **Plan:** `doc/product/learner-marketplace-epics.md`

## Kontext

Eine bezahlte (oder kostenlose) Bestellung soll die `Enrollment` erzeugen — über die
**vorhandene** `Course#enroll`-Logik (inkl. Kapazität/Warteliste). Die kritische Frage:
Wird ein Platz **vor** der Zahlung reserviert (Race-Risiko) oder **nach** bestätigter Zahlung
gebucht (dann ggf. trotz Zahlung Warteliste)? Diese Entscheidung muss der ADR festhalten.

## Entscheidung

1. **Enrollment erst NACH `paid`.** `Order#mark_paid!` ruft `book_enrollments!`. Vor der
   bestätigten Zahlung wird **kein** Platz reserviert. Das schließt das Race „zwei Käufe auf
   den letzten Platz, beide reservieren vorab" aus — der Engpass wird durch `Course#enroll`
   beim Buchen aufgelöst.

2. **Bezahlte Buchung auf vollem Kurs → Warteliste, kein Auto-Refund.** `Course#enroll`
   entscheidet wie gehabt: ist der Kurs voll, wird die Anmeldung `waitlisted`. Auch bezahlte
   Buchungen landen so auf der Warteliste; der `Order` bleibt `paid` (keine automatische
   Rückerstattung). „Meine Kurse" kommuniziert den Wartelisten-Status klar. Der Mockup-Hinweis
   „Zahlung erst bei Bestätigung" trägt diese Semantik.

3. **`Course#enroll` und `promote_next_waitlisted` werden NICHT dupliziert** — nur aufgerufen.
   Die Buchungslogik in `Order#book_enrollments!` leitet den `Participant` aus dem `User` ab
   (`Participant.find_or_create_by!(email: user.email)`, an `user` gekoppelt) und ruft je Kurs
   `course.enroll(participant)`.

4. **Idempotent.** `book_enrollments!` überspringt Kurse, in denen der Participant bereits eine
   aktive (nicht stornierte) Anmeldung hat. Zusammen mit dem idempotenten `mark_paid!` führt ein
   doppelter Webhook nicht zu Doppel-Anmeldungen.

5. **„Meine Kurse"** (`MyCoursesController#index`, nur eingeloggt) gruppiert die Anmeldungen der
   Lernenden über `User.has_many :enrollments, through: :participants` in Aktiv / Warteliste /
   Abgeschlossen.

## Begründung (warum einfach)

- **Nach-Zahlung-Buchung** ist die einzige Variante ohne Vorab-Reservierungs-Zustand und ohne
  Refund-Pfad — am wenigsten Code, am wenigsten Sonderfälle. Sie nutzt die vorhandene
  Kapazitäts-/Wartelisten-Wahrheit in `Course` unverändert.
- **Warteliste statt Refund** ist die mildere, demonstrierbare Semantik (zeigt die bestehende
  Wartelisten-Logik im echten Kauf-Kontext) und vermeidet einen kompletten Rückerstattungs-Flow.
- **Participant aus User ableiten** statt User/Participant zu verschmelzen (vgl. ADR 0003) hält
  Alt-Anmeldungen ohne Konto am Leben.

## Verworfene Alternativen

- **Platz vor der Zahlung reservieren.** Race-anfällig (zwei gleichzeitige Käufe), braucht
  einen „reserviert"-Zwischenstatus und ein Timeout-Aufräumen — Over-Engineering ohne Demo.
- **Bezahlte Buchung auf vollem Kurs automatisch erstatten.** Erfordert einen Refund-Pfad
  (Stripe-Refund-API, Order-Status `refunded`), den keine Demo trägt; verworfen zugunsten
  Warteliste.
- **Eigene Buchungslogik im Controller/Service.** Würde `Course#enroll` duplizieren; verboten.

## Konsequenzen

- Der Fortschrittsbalken in „Meine Kurse" ist Anzeige-Deko (kein Lektions-Fortschritts-Modell).
- Bei vollem Kurs zahlt die lernende Person und steht trotzdem auf der Warteliste — das ist
  bewusst so und wird in der UI erklärt.

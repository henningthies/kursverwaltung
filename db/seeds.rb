# Idempotent: vor dem Säen alles entfernen, damit der Demo-Startzustand reproduzierbar ist.
Enrollment.destroy_all
Participant.destroy_all
Course.destroy_all
Category.destroy_all
User.destroy_all

# Demo-Konten: ein Admin (Verwaltung) und eine Lernende (Marketplace).
admin   = User.create!(name: "Henning Thies", email: "admin@example.com",
                       password: "geheim123", role: "admin")
learner = User.create!(name: "Lena Lernerin", email: "lena@example.com",
                       password: "geheim123", role: "learner")

# Kategorien für die Marketplace-Filter-Pills.
ki           = Category.create!(name: "KI & Automation")
development  = Category.create!(name: "Entwicklung")
productivity = Category.create!(name: "Produktivität")

claude = Course.create!(
  title: "Claude Code im Projektalltag",
  status: "active",
  instructor: "Henning Thies",
  category: development,
  price_cents: 12_900,
  description: "Wie KI-Agenten im täglichen Entwicklungs-Workflow konkret helfen — " \
               "von der Projekt-Erkundung über Reviews bis zum fertigen Feature-PR."
)
claude.sessions.create!([
  { title: "Termin 1 — LLM vs. Agent, Projekt erkunden", starts_at: "2026-06-02 18:00" },
  { title: "Termin 2 — Skills, MCP, Hooks",              starts_at: "2026-06-09 18:00" },
  { title: "Termin 3 — Vom Feature zum PR",              starts_at: "2026-06-16 18:00" }
])

prompt = Course.create!(
  title: "Prompt Engineering meistern",
  status: "active",
  instructor: "Daniel Roth",
  category: ki,
  price_cents: 4_900,
  description: "Effektive Prompts für ChatGPT, Claude & Co. schreiben — " \
               "ideal für Einsteiger und Neugierige."
)
prompt.sessions.create!([
  { title: "Grundlagen & Mentale Modelle", starts_at: "2026-06-04 18:00" },
  { title: "Few-Shot, Chain-of-Thought, Tools", starts_at: "2026-06-11 18:00" }
])

# Gratis-Kurs: aktiv und kostenlos → Buchung ohne Checkout (Badge "Gratis").
git = Course.create!(
  title: "Git für Teams",
  status: "active",
  instructor: "Maria Berg",
  category: development,
  price_cents: 0,
  description: "Branching-Modelle, saubere Commits und Konfliktlösung im Team-Alltag."
)
git.sessions.create!([
  { title: "Branching & Merge-Strategien", starts_at: "2026-07-03 18:00" },
  { title: "Rebase, Cherry-Pick, Reflog",  starts_at: "2026-07-10 18:00" }
])

# Voller Kurs mit Warteliste: aktiv, kostenpflichtig, Kapazität 2 → Demo "Ausgebucht".
notion = Course.create!(
  title: "Notion Mastery",
  status: "active",
  instructor: "Julia Klein",
  category: productivity,
  price_cents: 3_900,
  capacity: 2,
  description: "Aufgaben, Notizen und Projekte mit Notion organisieren — Schluss mit dem Chaos."
)
notion.sessions.create!([
  { title: "Datenbanken & Views", starts_at: "2026-06-05 18:00" },
  { title: "Automationen & Templates", starts_at: "2026-06-12 18:00" }
])

# Entwurf bleibt im Marketplace unsichtbar (nur in der Admin-Verwaltung).
Course.create!(
  title: "Rails Performance",
  status: "draft",
  instructor: "Henning Thies",
  category: development,
  price_cents: 8_900,
  capacity: 2,
  description: "N+1-Queries finden, Caching-Strategien und Datenbank-Indizes — messen statt raten."
)

# Teilnehmer (Anmelde-Identität). Lena ist zugleich der Lernenden-User.
lena  = Participant.create!(name: "Lena Lernerin", email: "lena@example.com", user: learner)
alice = Participant.create!(name: "Alice Müller",  email: "alice@example.com")
bob   = Participant.create!(name: "Bob Schmidt",   email: "bob@example.com")
carol = Participant.create!(name: "Carol Weber",   email: "carol@example.com")

# Notion Mastery: Kapazität 2 — voll bestätigt + 1 auf Warteliste (Demo-Startzustand).
notion.enroll(alice)   # confirmed (1/2)
notion.enroll(bob)     # confirmed (2/2 — jetzt voll)
notion.enroll(carol)   # waitlisted (Kurs voll)

# Claude Code: unbegrenzt — Lena ist dabei.
claude.enroll(lena)

# Eine bezahlte Bestellung der Lernenden (Demo-Startzustand für Checkout/Meine Kurse).
paid_order = learner.orders.build(status: "pending")
paid_order.add_courses([prompt])
paid_order.stripe_session_id = "cs_test_seed_paid"
paid_order.save!
paid_order.mark_paid!

puts "Seeds: #{User.count} User, #{Category.count} Kategorien, #{Course.count} Kurse, " \
     "#{Session.count} Termine, #{Participant.count} Teilnehmer, #{Enrollment.count} Anmeldungen, " \
     "#{Order.count} Bestellungen."

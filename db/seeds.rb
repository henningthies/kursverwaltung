# Idempotent: vor dem Säen alles entfernen, damit der Demo-Startzustand reproduzierbar ist.
# Reihenfolge: Kinder vor Eltern. Order.destroy_all räumt OrderItems via dependent: :destroy.
Order.destroy_all
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
  description: "Claude Code wird in diesem Kurs vom Spielzeug zum verlässlichen Werkzeug " \
               "im Entwicklungsalltag. Du lernst, wie KI-Agenten ein fremdes Projekt " \
               "erkunden, Änderungen sicher umsetzen und über Reviews bis zum fertigen " \
               "Feature-PR führen.\n\n" \
               "Wir arbeiten durchgehend an einer echten Rails-App: Du verstehst, wann ein " \
               "Agent statt eines reinen Chats sinnvoll ist, wie CLAUDE.md, Skills, MCP und " \
               "Hooks zusammenspielen und wie du Qualität mit Tests und einem klaren " \
               "Review-Prozess absicherst. Für Entwickler:innen, die Claude Code produktiv " \
               "und mit gutem Gefühl einsetzen wollen."
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
  description: "Gute Ergebnisse mit ChatGPT, Claude & Co. sind kein Zufall, sondern " \
               "Handwerk. In diesem Kurs lernst du, Prompts gezielt zu strukturieren, " \
               "Kontext klug zu setzen und typische Fehler zu vermeiden.\n\n" \
               "Von den mentalen Modellen hinter Sprachmodellen über Few-Shot- und " \
               "Chain-of-Thought-Techniken bis zum Einsatz von Tools baust du dir ein " \
               "wiederverwendbares Repertoire auf, mit dem du Aufgaben aus Schreiben, " \
               "Recherche und Alltag deutlich schneller und verlässlicher löst. Ideal für " \
               "Einsteiger:innen und Neugierige."
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
  description: "Git beherrschen heißt nicht nur committen und pushen, sondern im Team " \
               "souverän zusammenarbeiten. Dieser Kurs zeigt dir Branching-Modelle, saubere " \
               "Commit-Historien und den entspannten Umgang mit Konflikten.\n\n" \
               "Du lernst Rebase, Cherry-Pick und Reflog kennen, verstehst, wann welcher " \
               "Workflow passt, und gewinnst die Sicherheit, auch heikle Situationen ohne " \
               "Datenverlust aufzulösen. Für Teams, die schneller und mit weniger Reibung " \
               "releasen wollen."
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
  description: "Schluss mit verstreuten Notizen und To-do-Listen: In Notion Mastery baust " \
               "du dir ein persönliches System für Aufgaben, Wissen und Projekte, das " \
               "wirklich zu deinem Alltag passt.\n\n" \
               "Du lernst Datenbanken, Views und Relationen sinnvoll einzusetzen, " \
               "wiederkehrende Abläufe mit Templates und Automationen zu vereinfachen und " \
               "dein Setup übersichtlich zu halten, statt dich in Möglichkeiten zu verlieren. " \
               "Für alle, die produktiver und ruhiger arbeiten wollen."
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
  description: "Langsame Rails-Apps haben fast immer dieselben Ursachen — dieser Kurs bringt " \
               "dir bei, sie zu messen statt zu raten. Du spürst N+1-Queries auf, setzt " \
               "Caching-Strategien gezielt ein und verstehst, welche Datenbank-Indizes " \
               "wirklich etwas bringen.\n\n" \
               "Anhand echter Beispiele lernst du, Engpässe zu finden, Änderungen sauber zu " \
               "belegen und Performance dauerhaft im Blick zu behalten. Für Entwickler:innen, " \
               "die ihre App spürbar schneller machen wollen."
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

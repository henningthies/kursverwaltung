# Idempotent: vor dem Säen alles entfernen, damit der Demo-Startzustand reproduzierbar ist.
Course.destroy_all

claude = Course.create!(
  title: "Claude Code im Projektalltag",
  status: "active",
  instructor: "Henning Thies",
  description: "Wie KI-Agenten im täglichen Entwicklungs-Workflow konkret helfen — " \
               "von der Projekt-Erkundung über Reviews bis zum fertigen Feature-PR."
)
claude.sessions.create!([
  { title: "Termin 1 — LLM vs. Agent, Projekt erkunden", starts_at: "2026-06-02 18:00" },
  { title: "Termin 2 — Skills, MCP, Hooks",              starts_at: "2026-06-09 18:00" },
  { title: "Termin 3 — Vom Feature zum PR",              starts_at: "2026-06-16 18:00" }
])

performance = Course.create!(
  title: "Rails Performance",
  status: "draft",
  instructor: "Henning Thies",
  description: "N+1-Queries finden, Caching-Strategien und Datenbank-Indizes — " \
               "messen statt raten."
)
performance.sessions.create!([
  { title: "Profiling-Grundlagen",      starts_at: "2026-07-07 18:00" },
  { title: "Caching & Counter Caches",  starts_at: "2026-07-14 18:00" }
])

git = Course.create!(
  title: "Git für Teams",
  status: "done",
  instructor: "Maria Berg",
  description: "Branching-Modelle, saubere Commits und Konfliktlösung im Team-Alltag."
)
git.sessions.create!([
  { title: "Branching & Merge-Strategien", starts_at: "2026-03-03 18:00" },
  { title: "Rebase, Cherry-Pick, Reflog",  starts_at: "2026-03-10 18:00" }
])

Course.create!(
  title: "SQL Refresher",
  status: "draft",
  instructor: "Maria Berg",
  description: "Joins, Aggregationen und Fensterfunktionen anhand realer Beispiele."
)

puts "Seeds: #{Course.count} Kurse, #{Session.count} Termine angelegt."

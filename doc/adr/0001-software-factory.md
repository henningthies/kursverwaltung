# 0001. Feature-Ausbau über eine Skill-basierte Software-Factory

- **Status:** Accepted
- **Datum:** 2026-05-26
- **Feature:** (Infrastruktur, kein App-Feature)

## Kontext

Die Kursverwaltung wächst Feature für Feature aus `FEATURES.md`. Gesucht war ein
wiederholbarer Weg, der jedes Feature **einfach, getestet und dokumentiert** liefert —
und den Agents auch **autonom** fahren können, nicht nur ein Mensch per Hand.

## Entscheidung

Drei Stufen als **Skills** unter `.claude/skills/` (`feature-plan`, `feature-build`,
`feature-review`), je an einen vorhandenen Sub-Agent verdrahtet (`planner`,
`rails-developer`, `rails-reviewer`) und an den `vanilla-rails`-Skill als Stil-Referenz.
Jedes Feature erzeugt einen ADR (technische Entscheidung) und eine Produkt-Doc (für den
Human-in-the-Loop). Git: Feature-Branch + lokaler Commit, kein automatischer Push/PR.

## Begründung (warum einfach)

Skills statt Slash-Commands, weil ihre `description` als Auslöser dient — ein Agent kann
die Stufen selbst anstoßen. Wiederverwendung der bestehenden Agents statt neuer
Abstraktion. Kein Push/PR automatisch, weil die PR-Erstellung im Kurs eine eigene Demo ist.

## Verworfene Alternativen

- **Slash-Commands** — verworfen, weil nur menschlich auslösbar; widerspricht dem Ziel
  autonomer Agent-Steuerung.
- **Ein einziger Monolith-Command „mach Feature X komplett"** — verworfen, weil die
  Demo-Haltepunkte zwischen Plan / Build / Review verloren gingen.

## Konsequenzen

Feature-ADRs werden ab `0002` fortlaufend nummeriert. Neue Stufen kommen als weitere
Skills hinzu. Die Leitplanke aus `FEATURES.md` bleibt die verbindliche Best-Practice-Basis
jeder Stufe.

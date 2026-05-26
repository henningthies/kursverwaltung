# Software-Factory — Kursverwaltung

Pipeline, um die App **Feature für Feature** aus [`FEATURES.md`](../../FEATURES.md)
auszubauen. Als **Skills** gebaut (nicht Slash-Commands), damit Agents die Stufen auch
**autonom** ansteuern können — die `description` jeder Stufe ist ihr Auslöser.

## Stufen (Skills unter `.claude/skills/`)

| Skill | Stufe | Agent | Erzeugt | Git |
|-------|-------|-------|---------|-----|
| `feature-plan` | 1 Plan | `planner` | Plan-Datei + **ADR (Proposed)** | legt `feature/<slug>` an |
| `feature-build` | 2 Build | `rails-developer` | Code (TDD, grün) + **ADR Accepted** + **Produkt-Doc** | lokaler Commit (kein Push) |
| `feature-review` | 3 Review | `rails-reviewer` | Stil-/Bug-Review gg. Plan + ADR + Doku-Check | nur lesen |

Stil-Referenz für alle Stufen: der globale `vanilla-rails`-Skill.

## Was die Factory garantiert

- **Einfach nach Best Practices.** Jede Stufe ist an die Leitplanke aus `FEATURES.md`
  gebunden (einfachste vanilla-Rails-Lösung, die eine Demo trägt). Der ADR begründet die
  Einfachheit *explizit* und listet die verworfene komplexere Alternative.
- **Tests liegen vor.** `feature-build` arbeitet TDD; das Build-Gate ist grünes `bin/rails test`.
- **Zwei Doku-Ebenen** je Feature:
  - **Technisch:** `doc/adr/NNNN-<slug>.md` — die Kern-Entscheidung (ADR).
  - **Produkt:** `doc/product/<slug>.md` — für den Human-in-the-Loop, ohne Code.

## Ablauf

```
feature-plan  kapazitaet-warteliste   → feature/<slug> + Plan + ADR (Proposed)
feature-build kapazitaet-warteliste   → TDD-Code, grüne Tests, ADR Accepted, Produkt-Doc, Commit
feature-review                        → Review des aktuellen feature-Branches
# Push / PR macht man bewusst selbst (eigene Kurs-Demo)
```

Jede Stufe ist einzeln nutzbar (gute Demo-Haltepunkte), und ein orchestrierender Agent
kann sie nacheinander selbst auslösen.

## Feature-Slugs (aus FEATURES.md)

| Slug | Feature | Trägt Demo |
|------|---------|-----------|
| `level-feld` | Course-Level (low/medium/high), `STATUSES`-Muster | T1 |
| `termin-zaehler` | Anzahl Termine in der Übersicht | T1 |
| `status-workflow` | Geordnete Course-Übergänge draft→active→done | T2/T3 |
| `kursuebersicht-zaehler` | „X Anmeldungen · Y Termine" (N+1-Falle) | T3 Performance |
| `participant-pii-export` | Teilnehmer + Name/E-Mail + JSON-Export (PII) | T3 Security |
| `kapazitaet-warteliste` | Kapazität + Warteliste bei Enrollment | T3 Feature→PR |

`feature-plan` matcht das Argument fuzzy gegen `FEATURES.md` — Slug oder Beschreibung.

## Ablage

- **Pläne:** `.claude/factory/plans/<slug>.md` (Arbeitsdokument, reist auf dem Branch mit).
- **ADRs:** `doc/adr/NNNN-<slug>.md` (fortlaufend nummeriert, ab `0002`; `0001` = Factory selbst).
- **Produkt-Docs:** `doc/product/<slug>.md`.

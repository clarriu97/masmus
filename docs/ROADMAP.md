# Roadmap and project state

The entry point for anyone (human or agent) picking up the project: where it
stands, what was decided and why, and what comes next. Loaded into every
Claude Code session through `CLAUDE.md`. **Keep it current**: the pull request
that finishes a milestone, makes a decision or changes where something lives
updates this file too.

GitHub is the source of truth for tasks: issues, milestones and PRs in
`clarriu97/masmus`. This file summarizes and links; it never duplicates issue
bodies.

```bash
gh issue list --milestone "M0 · Cimientos"      # open work of a milestone
gh issue view <n>                               # full scope of an issue
gh pr list                                      # anything in flight
gh run list --branch master --limit 3           # CI health on master
```

## Product

Más Mus: Mus, the Spanish card game, on the phone. You and a bot partner
against two bot rivals, offline, no accounts, no data leaving the device.
iPhone and Android phones, portrait, Spanish first. Owner: Carlos Larriu
(`clarriu97`).

## Phases and milestones

| Milestone | Status | What it delivers |
|---|---|---|
| **M0 · Cimientos** | **🔜 in progress** | Agent guide, roadmap, skills, secrets out of git, reproducible CI, protected `master`, legacy cleanup, the v1 plan (#4) |
| M1 · Reglas y motor | planned | Rules spec (`docs/RULES.md`) and a deterministic, fully tested engine; turns driven by a controller instead of widgets |
| M2 · Producto y diseño | planned | What players need, validated v1 scope, design system, own Spanish deck and identity |
| M3 · Mesa jugable | planned | The whole match redesigned: start, table, bets, discards, hand count with every hand shown, end of match, resume |
| M4 · Bots con criterio | planned | Bots that play like a decent player: discards, bets by position and score, a coherent partner, personalities |
| M5 · Calidad de lanzamiento | planned | Accessibility, texts, motion, layout matrix, goldens, e2e, release configuration |
| Fase 2 · Publicación | planned | Store accounts, TestFlight/Play, real devices, screenshots, ASO, monetization |
| Post-v1 | backlog | Ideas deferred until after launch |

**Next step:** finish M0 in order (#1 → #4). Work one issue per branch and
PR, following AGENTS.md → Workflow.

## Decisions (newest first)

- **2026-09-25 · Legacy is replaced, not extended.** The prototype (engine in
  `lib/core/game`, screens in `lib/screens`) has rule bugs, string-typed
  actions, unseeded randomness and turn logic inside widgets. New code goes
  into the target layout in AGENTS.md → Architecture; each milestone deletes
  the legacy parts it replaces, together with their tests.
- **2026-09-25 · Test strategy.** Rules are specified in `docs/RULES.md` and
  each rule has a named test; the engine is driven by stacked decks and
  scripted actions (scenario tests) and by thousands of seeded bot-vs-bot
  matches checked for invariants (simulation tests). Bots get decision tests
  and a benchmark against baseline bots. From the first redesigned screen on,
  the UI gets the same net as 1RM: layout matrix, goldens and e2e flows.
- **2026-09-25 · Same way of working as 1RM.** Issues in milestones, one
  branch and PR per issue, squash merge with green checks, project state in
  this file, `continue` skill to resume.

## Where things live

| What | Where |
|---|---|
| App code | this repo; architecture and rules in AGENTS.md |
| Rules of the game | `docs/RULES.md` (M1) |
| CI | `.github/workflows/` |
| Agent skills | `.claude/skills/` (`.agents` symlink), third-party ones pinned in `skills-lock.json` |
| App ids | bundle id / applicationId `com.example.masmus` until #3 |
| Sister project | `clarriu97/1rm-mobile-app`: same owner, same way of working, reference for CI and testing |

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
gh issue list --milestone "M1 · Reglas y motor"   # open work of a milestone
gh issue view <n>                                 # full scope of an issue
gh pr list                                        # anything in flight
gh run list --branch master --limit 3             # CI health on master
```

## Product

Más Mus: Mus, the Spanish card game, on the phone. You and a bot partner
against two bot rivals, offline, no accounts, no data leaving the device.
iPhone and Android phones, portrait, Spanish first. Owner: Carlos Larriu
(`clarriu97`). Who plays it, what they need and the v1 scope:
`docs/PRODUCT.md`.

## Phases and milestones

| Milestone | Status | Issues, in order | What it delivers |
|---|---|---|---|
| M0 · Cimientos | ✅ done | #1 #2 #3 #4 | Agent guide, roadmap, skills, secrets out of git, reproducible CI, protected `master`, legacy cleanup, the v1 plan |
| M1 · Reglas y motor | ✅ done (#11 waits for the owner's review in #49) | #11 #12 #13 #14 #15 #16 #17 | Rules spec (`docs/RULES.md`), a deterministic engine tested against it and thousands of simulated matches, a controller that owns the turns; the current table plays by the correct rules and the legacy engine is gone |
| **M2 · Producto y diseño** | **🔜 next** | #18 #19 #20 #21 | Flows and wireframes of v1, visual direction and design system, own Spanish deck, name, icon and splash |
| M3 · Mesa jugable | planned | #22 … #31 | The whole match redesigned on the new engine: start, table, bets, discards, the count with every hand shown, end of match, exit and resume, settings and help; playtest with Mus players |
| M4 · Bots y señas | planned | #32 … #37 | Bot arena, sensible mus/discards/bets, señas between partners, a partner who plays with you, personalities |
| M5 · Calidad de lanzamiento | planned | #38 #39 #40 #41 | Accessibility, motion and sound, release configuration, e2e in CI with the local gate and the Release workflow |
| Fase 2 · Publicación | planned | #42 #43 #44 #45 | Store accounts and betas, closed beta with Mus players, store listings and privacy, business model |
| Post-v1 | backlog | #46 | Online with friends, catching señas, vacas and regional variants, statistics, tutorial, languages… |

**Order of work:** #11 (rules spec) and #18 (wireframes) first, because both
need the owner's review; while they are reviewed, the engine (#12 → #17).
Then the design system, deck and identity (#19 → #21), the table (M3), the
bots (M4; it can start once #15 and #17 are in if M3 is waiting on a
review), quality (M5) and publication.

**Next step:** the owner's review of the rules defaults (#49) and the
wireframes (#51). Meanwhile, #19: two or three visual directions for the
owner to pick from, and M4 (#32 → #37), which only needs the engine. Work
one issue per branch and PR, following AGENTS.md → Workflow.

**Open questions for the owner** (details in `docs/PRODUCT.md`): señas in v1
or right after; business model; languages at launch; license.

## Decisions (newest first)

- **2026-09-25 · The legacy table on the new engine (#17).** Until the
  redesign, the prototype table draws `MatchController`: it offers only the
  engine's legal moves, shows what each player said from the log, and ends
  every hand with the engine's count. `HeuristicBot` ports the sensible rules
  of the old bot (cut with a good hand, keep kings, aces and pairs, bet by
  strength) with personalities as numbers, never names; the old engine, bot
  and their tests are gone. "La Real" left the match setup: it was never
  implemented. The setup defaults to 8 kings, as the spec says.
- **2026-09-25 · Time lives in the match controller (#16).**
  `MatchController` owns a match: it takes the human's moves (ignoring late
  taps out of turn), lets one bot at a time move after its thinking pause
  (slow 1.8 s, normal 1.1 s, fast 0.45 s) and saves after every move. Time
  comes from an injected `Scheduler`; tests move a `ManualScheduler` by hand
  and never wait. The match store is in memory until #29 puts it on disk,
  but it already goes through JSON.
- **2026-09-25 · The match and its count (#14).** `MatchState` holds only
  the score at the deal, the hand and, at the end, the winner and how
  (count, "no quiero" or órdago); the count is computed from the finished
  hand, never stored, so a saved match can't disagree with it. The count
  gives, per lance, who takes it, whose hand wins, why, and the points of
  the envite apart from those of pares, juego or punto: what the count
  screen (#27) shows. An accepted órdago decides the match before any
  pending lance is counted.
- **2026-09-25 · The hand as a state machine (#13).** `play(state, seat,
  move)` returns a new `HandState`; `legalMoves` is all the UI and the bots
  may offer, and an illegal move throws. Declarations of pares and juego are
  events the engine emits (always true), not moves. The state keeps a public
  log of everything the table sees: the UI draws the current lance from it
  and bots remember from it; hidden cards never go in it. Every state
  survives JSON, which is what saving a match will use.
- **2026-09-25 · Randomness is a value (#12).** The engine carries its random
  source in the match state: a 32-bit mulberry32 generator stored as one
  number, so applying an action stays a pure function, a match replays
  exactly from its seed and a saved match resumes the same shuffles. A test
  pins the sequence against an independent implementation: changing it
  breaks saved matches and regression seeds.
- **2026-09-25 · v1 scope (#4).** One human and three bots, offline, no
  account, Spanish, no ads mid-hand, no coins or bets with value (most Mus
  apps are PEGI 18 for "simulated gambling"). Default rules as the rulebooks
  say: 8 reyes, 40 points, mus corrido on the first hand, no 31 real, no extra
  deje; 4 reyes and 30 points as options. Señas between partners and
  consulting the partner are in v1 (pending the owner's confirmation):
  incoherent señas are the main complaint about the only big offline rival.
  Online play is the most requested thing after that, and the most expensive:
  after v1, with the engine ready for it. Evidence and scope in
  `docs/PRODUCT.md`.
- **2026-09-25 · Correct before pretty.** M1 ends with the current table
  playing on the new engine (#17), so the app follows the rules long before
  the redesign lands.
- **2026-09-25 · Naming.** Code is in English; Mus terms without an English
  equivalent stay in Spanish (mano, postre, envido, órdago, grande, chica,
  pares, juego, punto, señas).
- **2026-09-25 · Cleanup (#3).** Removed what nobody could reach or use: the
  mock setup and table screens, the simulated login, the generated deal sound
  (and `audioplayers`/`path_provider`), and the Linux, macOS, Windows and web
  targets: the app ships on iPhone and Android phones. App id
  `dev.larri.masmus`, following `dev.larri.onerm`. The README's screenshots
  were concept mockups, not the app; they now live in `docs/design/concept/`
  as the original vision, without Git LFS. What the player sees (fake tabs,
  made-up ELO, login button) goes with the redesign (#23).
- **2026-09-25 · CI (#2).** Pull requests run `analyze` (format + analyzer)
  and `test` (unit and widget tests in random order, line coverage in the job
  summary); both are required on `master`, which is protected (up to date,
  linear history, admins included). Release builds (Android app bundle, iOS
  without signing) run after every merge in **Builds** and locally with
  `tool/ci.sh all`, not on pull requests, as in 1RM. Flutter is pinned to
  3.47.5 in the workflows. iOS uses Swift Package Manager only (CocoaPods
  removed) and the UIScene lifecycle. The analyzer is 1RM's strict setup plus
  `unawaited_futures`, `cancel_subscriptions`, `close_sinks` and
  `directives_ordering`. Dependabot opens one grouped PR a week for pub and
  for Actions.
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
| App code | this repo; architecture and rules in AGENTS.md. Engine `lib/game/`, bots `lib/bots/`, match controller `lib/controllers/`, services `lib/services/`; the rest of `lib/` is the legacy UI |
| Product: players, needs, v1 scope, sources | `docs/PRODUCT.md` |
| Rules of the game | `docs/RULES.md` (#11) |
| CI | `.github/workflows/`: `flutter.yml` (PR checks), `builds.yml` (release builds on `master`); `tool/ci.sh` runs the same locally |
| Branch protection | `master`: required `analyze` and `test`; up to date with `master`; linear history; applies to admins; squash merge only, branches deleted on merge |
| Agent skills | `.claude/skills/` (`.agents` symlink), third-party ones pinned in `skills-lock.json` |
| App ids | bundle id / applicationId `dev.larri.masmus`; display name still "Masmus" until #21 |
| Design references | `docs/design/concept/`: the original concept mockups (online, rankings, señas guide). A vision, not the app |
| Visual directions | `docs/design/directions/`: Tapete, Noche and Tanteo on the same table (#19), source `index.html` and one JPG each |
| Sister project | `clarriu97/1rm-mobile-app`: same owner, same way of working, reference for CI and testing |

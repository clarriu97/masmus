# Más Mus — Agent guide

Flutter app (iOS + Android) to play Mus, the Spanish card game, against bots:
you and a bot partner against two bot rivals. Offline, no backend, no accounts.
Goal of phase 1: a first real version (v1) that plays by the rules, with bots
worth playing against and a table anyone can follow, ready for the stores.

**Project state, decisions and what's next: `docs/ROADMAP.md`** (loaded with this file). To resume work ("sigue", "sigue con M1"), follow the `continue` skill. Update the roadmap in the same PR whenever a milestone finishes, a decision is made or something moves.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked. No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

- Don't "improve" adjacent code, comments, or formatting. Match existing style.
- Remove imports/variables/functions that YOUR changes made unused; mention (don't delete) pre-existing dead code.
- Every changed line should trace directly to the task.

## 4. Goal-Driven Execution

Turn tasks into verifiable goals ("fix the bug" → "write a failing test, then make it pass") and loop until verified. For multi-step work, state a brief plan with a verification per step.

---

## Architecture

`lib/core/`, `lib/screens/`, `lib/widgets/` and `lib/navigation/` are the **legacy prototype**: a mutable engine with known rule bugs and a game flow driven from widgets. Milestones M1–M3 replace them; don't extend them. New code goes into the target layout, which follows the official Flutter architecture guide without extra state-management packages:

```
lib/
  main.dart          # composition root: builds services/controllers, injects them
  game/              # rules engine, pure Dart (no Flutter imports)
  bots/              # bot players: pick an action from what their seat can see
  controllers/       # ChangeNotifier per flow: runs a match, schedules bot turns, saves it
  services/          # I/O wrappers (storage, preferences). Abstract class + `forTesting()` fake
  ui/<feature>/      # screens + widgets; listen to controllers via ListenableBuilder
  ui/theme/          # design tokens + ThemeData
  l10n/              # ARB files
```

Rules:
- **The engine is a pure state machine.** Applying an action to a state returns the next state and the events that happened. It never reads the clock or an unseeded `Random`: shuffles take an injected `Random`, so every hand can be replayed exactly in a test.
- **`docs/RULES.md` is the specification** (written in M1). The engine implements that document; a rule change edits the spec and its tests in the same PR. Variants (8 or 4 kings, 30 or 40 points…) are fields of the rules config, not `if`s scattered around.
- Actions and phases are typed (sealed classes / enums), never strings. The UI offers exactly the legal actions the engine returns for the human's seat; it never decides legality itself.
- Bots only see their own seat's view: their cards and the public history. Never other hands or the deck.
- Timing (bots "thinking", pauses so a player can read what happened) lives in controllers behind an injected clock, never in widgets or game logic.
- A match in progress is serializable and survives the app being killed.
- Dependencies are injected through constructors from `main.dart`. No global singletons, no service locators, no static mutable state.
- New dependencies need a clear justification in the PR. Prefer the SDK (e.g. `HapticFeedback` over a vibration plugin).

## UI / UX rules

Played on a phone, in portrait, often one-handed, in sessions that get interrupted (a hand takes a couple of minutes, a match to 40 far longer). Players range from people who have played Mus in bars for decades to people learning it.

- The table answers at a glance: whose turn it is, who is mano, which lance is being played, what each player said in it and what is at stake. No debug text or internal names on screen.
- Your own hand is never covered by controls; controls sit in the thumb zone. Tap targets ≥ 48 dp.
- Nothing the bots do is instant or hidden: every action stays on screen long enough to be read, and the pace is adjustable.
- At the end of a hand every hand is shown, and each lance says who won it, with what, and how many points. The player can check the score.
- Mus vocabulary is used the way players use it (mano, postre, envido, órdago, "no hay mus", medias, duples, la 31…). Beginners get help in the app, not a different vocabulary.
- Every user-visible string goes through `AppLocalizations` (Spanish first). No hardcoded strings in widgets.
- Colors, typography, spacing and radii come from theme tokens. No inline `Color(...)` / `TextStyle(...)` in screens. Fonts are bundled: the game works offline.
- Respect platform conventions: iOS swipe-back works, system text scaling up to 200 % doesn't overflow, and `MediaQuery.disableAnimations` gets a static fallback for any non-trivial motion.
- No fake features: nothing on screen that doesn't work (no placeholder rankings, shops, logins or "coming soon" tabs).

## Skills

Project skills live in `.claude/skills/` (`.agents` is a symlink for other agents). The official `dart-flutter` plugin (enabled in `.claude/settings.json`) adds Flutter/Dart skills and the Dart MCP server.

- Resuming the roadmap → `continue`.
- Tests → `flutter-testing` (read the matching file in `.claude/skills/flutter-testing/references/` first); plugin skills `flutter-add-widget-test`, `flutter-add-integration-test`, `dart-add-unit-test`.
- Motion → `flutter-animations` (read `.claude/skills/flutter-animations/references/<type>.md` first).
- Visual design direction → `frontend-design` (principles only; it is web-oriented — translate to Flutter).
- Dart idioms → `dart-best-practices`. Layout bugs → `flutter-fix-layout-issues`. i18n → `flutter-setup-localization`.

## Testing (paranoid mindset)

1. Every new function, widget, or behavior ships with tests, written before or alongside the code.
2. Edge cases are mandatory: empty, zero, boundaries, ties, every branch.
3. Before modifying code, check existing coverage; add tests first if missing.
4. Bugs: first a test that reproduces it, then the fix.
5. **Rules are tested against the spec.** Every rule in `docs/RULES.md` has a test that names it. Hands are built from explicit cards or a stacked deck, never from a random deal.
6. **Scenario tests** drive the engine the way a match does: a stacked deck and a scripted list of actions, then the expected state, events and score breakdown. Build them with the helpers in `test/game/`; don't reach into engine internals.
7. **Simulation tests** play thousands of seeded bot-vs-bot matches and check invariants after every action: the 40 cards are all distinct and accounted for, a seat to act always has at least one legal action, scores never go down, every match ends. A failing seed becomes a regression test.
8. Bots get unit tests for canonical decisions (e.g. never "no quiero" with an unbeatable hand) and a seeded benchmark against baseline bots whose win rate must not regress.
9. Widget tests for screens, controls, navigation and semantics. Controllers take a fake clock, so no test waits on real time.
10. No `Future.delayed` to hide async timing. Use fakes, explicit pumps, `pumpAndSettle` only when animations settle. Flaky tests get fixed immediately.
11. Test files mirror `lib/` (`lib/game/scoring.dart` → `test/game/scoring_test.dart`). Reuse the services' `forTesting()` fakes; don't invent new mocking patterns.
12. From the first redesigned screen (M3) on: every screen and screen state gets a scenario in the layout matrix (devices × text 100/130/200 % × languages), key screens get goldens, and every user flow gets an end-to-end test in `integration_test/`.
13. Legacy tests that break these rules are brought in line when touched, or deleted together with the legacy code they test.

## Commands

```bash
flutter pub get
dart format .                      # CI runs: dart format --set-exit-if-changed .
flutter analyze
flutter test                       # full suite — a partial pass is a failure
flutter devices
flutter run -d <device-id>         # simulator, emulator or device; keep it running for hot reload
```

When the app is running (via `flutter run` or the Dart MCP server), hot reload after editing UI in `lib/`, and hot restart after changing `main()`, `initState`, or global/static state.

## Workflow

- Work is tracked as GitHub issues in milestones (see `docs/ROADMAP.md` for the current one and the order).
- One branch per issue: `feat/<issue>-<slug>`, `fix/<issue>-<slug>`, `chore/<issue>-<slug>`.
- Conventional commits (`feat:`, `fix:`, `chore:`, `test:`, `docs:`, `build:`, `ci:`, `refactor:`).
- PR body contains `Closes #<issue>`, a summary, and how it was verified (tests + simulator screenshot for UI changes). No co-author trailers and no mention of AI tools in commits or PRs.
- Merge with squash once the required checks are green.
- Never commit secrets: `.env`, keystores, `key.properties` and provisioning profiles stay out of git. Stage files by path; never `git add -A` or `git add .` on a tree you haven't checked.

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
| M1 · Reglas y motor | ✅ done | #11 #12 #13 #14 #15 #16 #17 | Rules spec (`docs/RULES.md`), a deterministic engine tested against it and thousands of simulated matches, a controller that owns the turns; the current table plays by the correct rules and the legacy engine is gone |
| M2 · Producto y diseño | ✅ done | #18 #19 #20 #21 | Flows and wireframes of v1, visual direction and design system, own Spanish deck, name, icon and splash |
| **M3 · Mesa jugable** | **in progress** (#22 → #30 done; the owner's first playtest, #31, asked for #77 #78 #79) | #22 … #31, #77 … #79 | The whole match redesigned on the new engine: start, table, bets, discards, the count with every hand shown, end of match, exit and resume, settings and help; playtest with Mus players |
| M4 · Bots y señas | in progress (#32 #33 #34 done) | #32 … #37 | Bot arena, sensible mus/discards/bets, señas between partners, a partner who plays with you, personalities |
| M5 · Calidad de lanzamiento | planned | #38 #39 #40 #41 | Accessibility, motion and sound, release configuration, e2e in CI with the local gate and the Release workflow |
| Fase 2 · Publicación | planned | #42 #43 #44 #45 | Store accounts and betas, closed beta with Mus players, store listings and privacy, business model |
| Post-v1 | backlog | #46 | Online with friends, catching señas, vacas and regional variants, statistics, tutorial, languages… |

**Order of work:** #11 (rules spec) and #18 (wireframes) first, because both
need the owner's review; while they are reviewed, the engine (#12 → #17).
Then the design system, deck and identity (#19 → #21), the table (M3), the
bots (M4; it can start once #15 and #17 are in if M3 is waiting on a
review), quality (M5) and publication.

**Next step:** the owner's first playtest of the new table (#31) asked for
a table that can be followed: #77 (one thing at a time, slower bots), #78
(who speaks, what you said, what happened in the hand) and #79 (the deck
by the mano and the deal). Then he plays again, and the rest of M4
(#35 → #37) and M5. Work one issue per branch and PR, following
AGENTS.md → Workflow.

**Open questions for the owner** (details in `docs/PRODUCT.md`): señas in v1
or right after; business model; languages at launch; license.

## Decisions (newest first)

- **2026-09-29 · Who cut the mus, all hand long (#95).** «No se ve quién
  corta, y es información básica». Whoever cut keeps a pair of scissors
  on a cream disc (`CutBadge`) beside their avatar, opposite the mano's
  token, and «cortó el mus» under their name for the rest of the hand, or
  the scissors by your cards if you cut. Screen readers hear it.
- **2026-09-29 · Nobody pays to see (#93).** The owner saw El Farolero bet
  at grande with nothing and then accept his raise. Answering, a bot now
  discounts its read by 0.1 more when the rivals raised over its own
  envite, and never accepts below a read of 0.3, or 0.4 after such a
  raise, whatever the odds of the pot; below that it refuses or, a
  bluffer, sometimes raises again. The arena holds: 65.2 % (60.9–69.2)
  against `HeuristicBot`. The tests of #75, lost on the way, are back.
- **2026-09-29 · A match of one juego, or the best of three or five
  (#88).** The owner asked for it after his second playtest; vacas left
  the list of things out of v1.
  - **Rule**: R-FIN-5. Each juego starts from zero, with the mano after
    the last one and mus corrido.
  - **Where it is chosen**: «Juegos» (Uno, De 3, De 5) in Nueva partida
    and in Ajustes, one by default.
  - **Engine**: `Rules.games`. `MatchState` is one juego: `isOver` and
    `winner` are the juego's, `games` the juegos won before it,
    `matchWinner` who has won enough, and `nextGame()` deals the next
    one.
  - **At the table**: the juegos under the target («juegos 1–0»).
  - **End of a juego**: whoever won it, how the match stands, and
    «Siguiente juego» until the match is won. Only then «Revancha».
  - **Saving**: a match between juegos is kept, and one saved before
    juegos existed reads as one juego.
- **2026-09-29 · The mano carries a token; the deck sits in the corner
  (#87).** The deck beside a bot didn't say whether that bot or the next
  was mano, and «mano» in small print wasn't enough.
  - **Token**: the mano now carries a token, a cream disc with an «M» in
    the colours of the deck (`ManoToken`), like a dealer's button at
    poker. It sits on the avatar of a bot mano, or by your cards, doesn't
    step back with its seat, and moves with the mano. The word «mano»
    left the seats.
  - **Deck**: it sits on the table itself, in the corner between the
    postre, who deals, and the mano; the deal flies from there.
  - **Mus corrido**: during the mus of the first hand a strip under the
    row of the hand says «Mus corrido: quien corte será mano». The middle
    of the table says who deals while dealing («REPARTE · La
    Temeraria»), and who becomes mano when it moves («MANO · El
    Prudente»), held 1.8 s like a cut.
- **2026-09-29 · Who has the floor, from across the room (#86).** In his
  second playtest the owner still couldn't tell who speaks, who starts
  after the deal or when his turn comes. Now whoever has the floor (whose
  turn it is or, while the table shows what just happened, whoever just
  said it) stands out: every other seat steps back to 40 % (their bubbles
  don't, so what was said stays readable), and a brass arrow in the middle
  of the table points at them. On your turn your cards are framed in brass
  and the phone gives a medium haptic tap, once, when it comes.
- **2026-09-29 · An accepted órdago scores the whole game (#84).** The
  owner lost a match to an órdago and the end said «Nosotros 0 · Ellos 0»:
  the órdago decided the match without scoring anything. Now its lance
  carries the tantos that take the winner to the target (R-FIN-3), so the
  count adds up and the end reads, say, «21 · 40».
- **2026-09-29 · The deck by the mano, and the deal (#79).** As at a real
  table, the deck sits by the mano, on the side of the postre who deals:
  left of your cards when you are mano, and beside the cards of a bot
  mano. Cards are dealt from it, one after another from the mano on: all
  sixteen at the start of every hand (`Deal.hand`) and, after the
  discards, the ones each player asked for. Each card flies 350 ms, 110 ms
  after the one before (about 2 s for a whole hand). The timing lives in
  `MatchController` (`dealing`): nobody moves, and it is nobody's turn,
  until they land. While the discards go on, each player holds only the
  cards it kept. A saved match resumes with its cards already dealt. With
  reduced motion the cards are there at once. The fade of new cards is
  gone: the deal replaces it.
- **2026-09-29 · Who speaks and what happened, at a glance (#78).**
  - The bot whose turn it is is edged in brass, and its bubble is three
    dots lighting up in turn (still with reduced motion); screen readers
    hear «pensando».
  - A word just said pops into its bubble; rebuilding the table doesn't
    pop it again, only a new word.
  - By your cards: «Te toca», in brass, when it is your turn, and
    otherwise what you last said. «Mano» is a plain chip now, so brass
    means only whose turn it is.
  - In the middle of the table, the lance being played and what is bet
    («GRANDE 2», «¿Pares?», «¿Mus?», «descartes»), and while the table
    holds the close of a lance, how it went («en paso», «Nosotros +1»),
    edged in brass.
  - «Lo que va de mano», from the top bar: everything said so far, step by
    step, as a conversation («El Prudente: Envido 2», «→ querido 2»,
    «La Temeraria pasa a ser mano»).
- **2026-09-29 · The table tells the hand one thing at a time (#77).**
  Playing the new table, the owner still couldn't follow who speaks, who
  cut the mus or what happened before his turn, and the bots were too fast
  to follow even paying attention. One move can bring many things (the last
  paso closes the chica, everyone declares pares, pares close sin disputa,
  everyone declares juego…) and the table drew them all at once. Now
  `MatchController` shows the table one event of the log at a time
  (`shown`): the move at once, then each thing it brought after the one
  before has been held long enough to read it: 1 s a word or a
  declaration, 1.8 s a «no hay mus» and the close of a lance or of the
  hand, 0.7 s the start of a lance. While the cut is held, the middle of
  the table says «MUS · cortado»: in mus corrido whoever cuts becomes
  mano and speaks first in the grande, so their bubble soon gives way to
  their dots. Nobody moves and nothing can be tapped meanwhile, and the
  count and the end of the match wait for it. `TableView.of(…, shown:)`
  reads the table at that point of the log: the steps, what each one said,
  what is bet, the score and who is mano. Declarations of pares and juego
  start a step of their own, so they show one by one as a conversation,
  also when everyone or nobody has. The bots think longer: 3.2 s slow,
  2.2 s normal, 1.2 s fast, and the holds scale with the pace (×1.4, ×1,
  ×0.6).
- **2026-09-29 · Envites have an end (#75).** In the owner's first real
  match the bots raised each other to 40 in the first hand: `StrategicBot`
  answered every raise with the same read of its hand, so two strong hands
  raised by 2 forever. Now every envite of the rivals in the lance lowers
  its read by 0.12, and a team says at most two envites in a lance (the
  envite and one raise); after that it accepts, refuses or goes to órdago.
  Simulated matches check it after every move; the arena is unchanged
  (63.4 % against `HeuristicBot`).
- **2026-09-28 · Identity (#21).** The app is called «Más Mus» on the home
  screen of both platforms and in the task switcher. Its icon is two cream
  cards on the felt, an oros in front and a copas behind, drawn with the
  deck's own art by `test/goldens/branding_test.dart`. The PNGs it writes
  in `assets/branding/` are goldens too, so the icon can't change unseen:
  the full icon, the adaptive foreground, the monochrome for Android 13 and
  the two native splashes. `flutter_launcher_icons` and
  `flutter_native_splash` turn them into platform assets. After running
  them, keep `ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS =
  YES` in the Xcode project, which the icon tool breaks, and leave
  `Info.plist` as it was, which the splash tool rewrites. The app opens
  straight on the start screen.
- **2026-09-28 · How to play (#30).** «Cómo se juega», from the start screen
  and from the table's «?», tells the rules of this file for playing, in
  the table's vocabulary: the basics, the cards, mano and postre, mus and
  discards, the four lances with examples the engine agrees with, bets and
  the count. «Reparto limpio» says the deck is shuffled at random, that the
  bots see only their own cards and what is said, and that every card can
  be checked at the end of the hand. It ends with a glossary.
- **2026-09-28 · Settings (part of #30).** «Ajustes», from the start
  screen, keeps:
  - the rules new matches start with (8 or 4 reyes, a 40 or 30);
  - the bots' pace (lento, normal, rápido);
  - whether the table says what your hand is worth.
  Every change is saved at once to `settings.json`, through `JsonFile`, the
  same safe write the match uses: a temporary file renamed over the real
  one, writes queued, unreadable files set aside. A damaged file, or one
  from a newer version, gives the defaults. Sound and vibration come with
  #39.
- **2026-09-28 · Saving and resuming a match (#29).**
  - **What is saved**: after every move the match in progress is saved to
    `match.json` in the app's support directory (`path_provider`), with who
    plays each bot seat (`SavedMatch`) and a `schemaVersion`.
  - **How**: through a temporary file renamed over the real one, one write
    after another; a match that is over is cleared.
  - **Unreadable files**: a damaged file, or one from a newer version, is
    renamed aside, never overwritten, and the start screen says so.
  - **Resuming**: with a match saved, the start shows «Partida en curso»
    (score, rules, hand, partner) and «Continuar» resumes it with the same
    bots in the same seats. Starting another one asks first, and only
    confirming drops the saved one.
  An e2e plays, throws the app away, opens it again from disk and finds the
  same cards in your hand.
- **2026-09-28 · End of match and rematch (#28).** The last count ends in
  «Ver el final»; a match won by the points of a «no quiero», which has no
  count, goes there at once. `EndView` says who won, the final score in
  amarracos and how the match went («14 manos · con un órdago»), then
  «Revancha» (the same bots in the same seats and the same rules, a new
  deal) or «Volver al inicio». The matrix and the goldens cover a match won
  in the count and one lost to an órdago.
- **2026-09-28 · The app plays at the new table.** «Empezar partida» opens
  `TablePage`: your partner across the table and two rivals picked at
  random among the other personalities (the same seed, the same ones), all
  `StrategicBot`s. The prototype's table and everything only it used are
  gone: `GameScreen`, `MusTable`, its controls and round summary, the old
  theme and the `vibration` plugin (haptics come back with
  `HapticFeedback` in #39).
- **2026-09-28 · The count (#27).** At the end of a hand the table gives way
  to `CountView`:
  - the four hands face up, from the mano on, each with its owner;
  - a line per lance, as the engine counted it: who takes it and with what
    («El Calculador, con R-C-7-6», «Tú, con 31»), why (en paso, querido 2,
    no quiero already counted, sin disputa, órdago, not counted once the
    match is won) with what each hand of the winning pair adds («la 31 3 +
    juego 2»), and its tantos;
  - the score before and after, and who won the match if someone did;
  - «Ver el reparto»: every card thrown away, by whom, and that the 40 add
    up.
  «Siguiente mano» deals the next one. A test plays 40 hands with bots and
  checks that the tantos shown always add up to the engine's total.
- **2026-09-28 · Discards at the table (#26).** While you discard, a tap
  marks a card to throw away (it rises, edged in brass) and another tap
  unmarks it; «Descartar» says how many and can't be pressed with none.
  Each player's bubble says how many it asked for during the discards, and
  «pidió N» stays under its name for the rest of the hand, as a table
  remembers it. Cards come in with a short fade and rise, keyed by card, so
  only the new ones move; with reduced motion they are there at once.
- **2026-09-28 · Your moves at the table (#25).** The table offers exactly
  the engine's legal moves, in the thumb zone:
  - at the mus, mus or no hay mus;
  - opening a lance, paso, envido and órdago, with the amount chosen on the
    table (2, 5, 10 or any other in a sheet);
  - answering, no quiero (with what refusing gives), quiero, raise by any
    amount and órdago; against an órdago, only quiero or no quiero.
  Above the answers, who bet what («La Temeraria envida 5 a la chica»); a
  partner's no quiero that leaves the answer to you reads «Tú decides». The
  órdago only goes off when held for about 0.8 s, its fill showing it; a tap
  shows how, above the button, and screen readers throw it with a long
  press. On short screens the three bots sit in a row, the bet is read in
  the row of the hand and your cards size to the screen's height. An e2e
  plays a whole hand from a stacked deck with the real bots and clock.
- **2026-09-28 · The new table (#24).** `TableScreen` (`lib/ui/table/`)
  draws a match from `MatchController` through `TableView`, a pure reading
  of the engine's state and log from your seat. It shows:
  - the score with amarracos;
  - the row of the hand (mus and the four lances, or the punto), with how
    each went (en paso, querido 2, Nosotros +1, de Ellos, no se juega) or
    what is going on (te toca, envite 5, corrido, descartes);
  - each bot with its name, partner or rival, mano or postre, four cards
    face down and what it just said, which stays until someone speaks in
    the next step; the one whose turn it is is edged in brass;
  - what is bet in the middle;
  - your cards, big, with what they are worth and whether you are mano.
  One live region tells screen readers the lance, whose turn it is and what
  is on the table. The table is a dense board: its text grows up to 130 %
  and the seats scale down to fit short screens; the layout matrix runs it
  in three moments of a hand. The app keeps opening the prototype table
  until the new one can be played: your moves (#25), the discards (#26) and
  the count (#27).
- **2026-09-28 · Start and new match (#23).** The app opens on a Tapete
  start screen (`lib/ui/start/`) with one action, «Nueva partida», and a
  fan of la 31; the new match screen picks the partner among the four bots,
  each with a line on how it plays, and the rules (8 or 4 reyes, a 40 or a
  30), all at their defaults so one tap starts. It opens the prototype
  table until #24. Only what works is on screen: «Continuar» a saved match
  comes with #29, «Cómo se juega», «Ajustes» and the rules' defaults with
  #30, the señas switch with #35. The splash, the fake login, the tabs
  (ranking, shop, social, profile), the made-up ELO, "multijugador
  próximamente" and the table colors that did nothing are gone. Bot
  personalities are an `enum` of numbers; their names and lines are texts
  (`lib/l10n/localized_names.dart`). The layout matrix
  (`test/ui/layout_matrix_test.dart`) starts with these two screens: 8
  devices × 3 text sizes × bold, with Flutter's accessibility guidelines at
  100 %.
- **2026-09-28 · Our own deck, drawn in code (#20).** `PlayingCardView`
  paints the 40 faces and the back from vector art in `lib/ui/cards/` (SVG
  path data read by a small `svgPath`), instead of files generated by a
  script: the same rule, edit the source and never the pixels, without
  assets or an SVG package, sharp at any size. Suits by shape as well as
  color: a coin, a cup, a sword and a club, outlined in the card's ink so
  oros reads on the cream. The number in Young Serif at two corners; pips
  from 1 to 7 laid out as in the classic deck (a test keeps them clear of
  each other and inside the art); the sota is a page in a feathered cap,
  the caballo a horse's head, the rey a crown. Below 64 wide, as in the
  count, only the number and the suit. A card marked to throw away rises
  and is edged in brass; screen readers hear «Rey de oros» or «Carta boca
  abajo». It replaces the prototype's card at the table.
- **2026-09-28 · The UI safety net before the first screen (#22).** It went
  ahead of the deck, which needs goldens. Texts in ARB (template
  `lib/l10n/app_es.arb`, generated `AppLocalizations`). Test helpers in
  `test/helpers/`: real devices from iPhone SE to Pro Max and Android
  compact to tablet, `buildTestApp` for screens and `buildTestComponent`
  for pieces. Goldens on macOS with 1RM's tolerant comparator
  (`test/goldens/`, tag `golden`, job `goldens` required on `master`); the
  first ones, the Tapete components on iPhone SE and Pro, caught "Órdago"
  wrapping on the SE. E2E skeleton in `integration_test/` with one flow from
  opening the app to the table, run by `tool/ci.sh e2e-ios small|large` and
  `e2e-android` and by `tool/ci.sh all`; running them in CI, the local gate
  and the Release workflow are #41. The layout matrix is born with the first screen (#23) on
  these helpers, and the storage and relaunch helpers with #29.
- **2026-09-28 · The Tapete design system (#19).** Tokens in
  `lib/ui/theme/`: the felt and its inks, brass for whose turn it is (as a
  fill or an edge, never as text), maroon for the órdago, the card's cream,
  inks and suit colors, spacing, radii, shadows (only cards and bubbles
  lift) and motion. Young Serif for the score, Alegreya Sans with lining,
  tabular figures for everything else, bundled with their OFL licenses:
  `google_fonts`, which downloaded fonts at run time, is gone, and the
  legacy screens use the bundled faces until they are replaced. Components
  in `lib/ui/widgets/`: `ActionButton` in three kinds that can't be
  mistaken (cream primary, outlined secondary, maroon órdago; 56 tall),
  `LanceChip`, `TableChip`, `SpeechBubble`, `ScoreBoard` with amarracos and
  `Felt`. Tests check AA contrast for every text on its ground and fail on
  literal colors or text styles in `lib/ui/` outside the theme. Oros on the
  cream card stays under 3:1, so the deck (#20) outlines its pips.
- **2026-09-28 · Visual direction: Tapete (#19).** The owner picked it out of
  three directions drawn on the same table (`docs/design/directions/`):
  green felt with grain, cream cards of the classic Spanish deck with its
  real numbers (12 the king, 11 the caballo, 10 the sota) and suits in their
  usual colors, the score in amarracos (a big stone is 5 tantos), cream
  buttons like chips and the órdago in maroon. Young Serif for the score,
  Alegreya Sans for everything else, bundled. From Tanteo it keeps the
  legibility rules: big cards, big numbers, AA contrast. The tokens, fonts
  and components come in #19; the deck (#20) and the icon (#21) follow it.
- **2026-09-28 · The redesign goes first.** Playing the prototype table on
  his iPhone, the owner couldn't follow the game: who speaks, whose turn it
  is, when the mus is cut, who bets, what happened before his turn; buttons
  that look alike, animations that fail, cards he dislikes. So M2 and M3 go
  before the rest of M4, and his points are done criteria of #24, #25 and
  #20. He tests the app for real once the new table is ready (#31).
- **2026-09-25 · A bot that estimates (#33, #34).** `StrategicBot` decides
  from estimates instead of rules of thumb. `Knowledge`
  (`lib/bots/estimate.dart`) deals the hands its seat can't see at random
  from the unseen cards, each again until it agrees with what that player
  declared at pares and juego, and scores a table by its points en paso
  (ours minus theirs if nobody bet). Mus: cut with a positive advantage, the
  mano a little sooner. Discards: the 15 ways are tried on the same 60 deals
  and the best three on 400 more, so that near ties don't flip. Bets: the
  chance of winning the lance against the break-even of the stake (tantos of
  pares and juego included), discounted by 0.12 when a rival has bet; the
  first to answer is more careful if the partner still can; the órdago only
  near the end or when the match is lost anyway, and it is accepted when the
  chance beats that of winning the match by refusing. On 500 matches it
  beats `HeuristicBot` 63.4 % (59.1–67.5) and `RandomBot` 81.4 %; a test
  fails if its lower bound against `HeuristicBot` drops to 50 %, and the CI
  summary now reports that match-up. It plays every bot seat at the table,
  with the personalities' boldness and bluffing. Not used yet: how many
  cards each player asked for.
- **2026-09-25 · The bot arena (#32).** Bots are measured, not judged by
  eye: `playArena` plays every deal twice with the teams swapped (duplicate
  format, so the cards' luck cancels out) and reports the win rate with its
  95 % Wilson interval, plus style per hand (envites, órdagos, mus cut, bets
  without the best hand). Baseline on 500 matches: `HeuristicBot` (El
  Calculador) beats `RandomBot` 74.6 % (70.6–78.2); identical bots 49.8 %.
  A test fails if the heuristic bot's lower bound against random falls
  below 60 %; every CI run adds the report to the `test` job summary. The
  bots of M4 have to beat `HeuristicBot` in the arena to replace it.
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
- **2026-09-25 · Rules (#11).** `docs/RULES.md` is the spec the engine
  implements: every rule has an id its test names, and the examples and whole
  hands in it are test cases. Defaults as the rulebooks say (8 reyes, 40
  points, mus corrido on the first hand, no 31 real, no deje); 4 reyes and 30
  points as options. All four hands are shown at the count, not only the ones
  that decide it (transparency, #27). Señas get their own section with #35.
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
| App code | this repo; architecture and rules in AGENTS.md. Engine `lib/game/`, bots `lib/bots/`, match controller `lib/controllers/`, services `lib/services/`, UI `lib/ui/`, texts `lib/l10n/` |
| Product: players, needs, v1 scope, sources | `docs/PRODUCT.md` |
| Rules of the game | `docs/RULES.md`: rule ids `R-…`, examples `E-…`, whole hands `S-…` |
| CI | `.github/workflows/`: `flutter.yml` (PR checks: `analyze`, `test`, `goldens` on macOS), `builds.yml` (release builds on `master`); `tool/ci.sh` runs the same locally |
| Branch protection | `master`: required `analyze`, `test` and `goldens`; up to date with `master`; linear history; applies to admins; squash merge only, branches deleted on merge |
| Agent skills | `.claude/skills/` (`.agents` symlink), third-party ones pinned in `skills-lock.json` |
| App ids | bundle id / applicationId `dev.larri.masmus`; display name «Más Mus» |
| Icon and splash | `test/goldens/branding_test.dart` → `assets/branding/` → `dart run flutter_launcher_icons` and `dart run flutter_native_splash:create` |
| Design references | `docs/design/concept/`: the original concept mockups (online, rankings, señas guide). A vision, not the app |
| Wireframes of v1 | `docs/design/wireframes/index.html` (source) and one PNG per state, rendered by `tool/render_wireframes.sh`; edit the HTML and re-run, never the PNGs |
| Deck | `lib/ui/cards/`: suit and figure art (`card_art.dart`), pip layouts, `PlayingCardView`; goldens `deck.png`, `deck_compact.png`, `card_states.png` |
| Settings | `settings.json` next to the saved match (`SettingsController.open`) |
| Saved match | `match.json` in the app's support directory (`MatchStore.open`); unreadable ones renamed `match.unreadable-<time>.json` beside it |
| Texts | `lib/l10n/app_es.arb` (Spanish, the template); `AppLocalizations` is generated next to it |
| Goldens | `test/goldens/golden_test.dart`, PNGs in `test/goldens/goldens/`; regenerate on macOS and review the diff |
| Screens | `lib/ui/<feature>/`: `start/` (start and new match), `table/` (the table and `TableView`); layout matrix `test/ui/layout_matrix_test.dart`, table fixtures `test/helpers/table.dart` |
| E2E flows | `integration_test/app_test.dart` (single entry point) and `integration_test/flows/` |
| Design system | `lib/ui/theme/` (Tapete tokens and `ThemeData`), shared components in `lib/ui/widgets/` (golden: `test/goldens/goldens/components.*.png`), fonts in `assets/fonts/` with their OFL licenses (registered in `main.dart` for the licenses page) |
| Visual directions | `docs/design/directions/`: Tapete (chosen), Noche and Tanteo on the same table (#19), source `index.html` and one JPG each |
| Sister project | `clarriu97/1rm-mobile-app`: same owner, same way of working, reference for CI and testing |

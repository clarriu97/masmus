import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:masmus/bots/heuristic_bot.dart';
import 'package:masmus/bots/random_bot.dart';
import 'package:masmus/controllers/match_controller.dart';
import 'package:masmus/game/hand_state.dart';
import 'package:masmus/game/match.dart';
import 'package:masmus/game/move.dart';
import 'package:masmus/game/rules.dart';
import 'package:masmus/services/match_store.dart';
import 'package:masmus/services/scheduler.dart';
import 'package:masmus/services/sounds.dart';
import 'package:masmus/ui/table/table_screen.dart';

import '../game/scenario.dart';

/// Who sits where in the tables of the tests: you in seat 0.
const tableBots = {
  1: Personality.prudente,
  2: Personality.calculador,
  3: Personality.temeraria,
};

final _schedulers = Expando<ManualScheduler>();

/// Moves the clock of a [tableController] until the table has been shown
/// everything the last move brought, stopping before any bot moves.
void catchUp(MatchController controller) {
  final scheduler = _schedulers[controller]!;
  while (controller.catchingUp) {
    scheduler.advance(const Duration(milliseconds: 100));
  }
}

/// A controller for a match dealt from [hands] and played up to [moves].
/// Its bots never move by themselves: nobody advances the scheduler but
/// [catchUp].
MatchController tableController({
  required Map<int, String> hands,
  int mano = 0,
  bool musCorrido = false,
  List<int> score = const [0, 0],
  List<(int, Move)> moves = const [],
  bool finish = false,
  Scheduler? scheduler,
  Rules rules = const Rules(),
  List<int> games = const [0, 0],
}) {
  var match = MatchState(
    rules: rules,
    score: score,
    games: games,
    handNumber: 1,
    hand: dealt(hands, mano: mano, musCorrido: musCorrido),
  );
  for (final (seat, move) in moves) {
    match = match.play(seat, move);
  }
  while (finish && match.hand.phase is! HandOver) {
    match = match.play(match.hand.turn!, const Paso());
  }
  final clock = scheduler ?? ManualScheduler();
  final controller = MatchController(
    match: match,
    bots: {for (final seat in tableBots.keys) seat: RandomBot(Random(seat))},
    seats: tableBots,
    scheduler: clock,
    store: MatchStore.inMemory(),
  );
  if (clock is ManualScheduler) {
    _schedulers[controller] = clock;
  }
  return controller;
}

Widget tableScreen(
  MatchController controller, {
  VoidCallback? onExit,
  VoidCallback? onRematch,
  bool haptics = true,
  Sounds? sounds,
}) => TableScreen(
  key: ObjectKey(controller),
  controller: controller,
  bots: tableBots,
  onExit: onExit ?? () {},
  onRematch: onRematch ?? () {},
  haptics: haptics,
  sounds: sounds,
);

const _discardHands = {0: 'R 7 5 4', 1: 'S C 7 6', 2: '4 5 6 1', 3: 'R 5 1 4'};

/// Everyone passes in every lance of [mano]'s hand.
List<(int, Move)> passes(int mano) => [
  for (var i = 0; i < 4; i++) ((mano + i) % 4, const Paso()),
];

/// Hands at their count, from the whole hands of docs/RULES.md.
final Map<String, MatchController Function()> countMoments = {
  // S-7: grande and chica en paso, nobody has pares, juego querido with
  // la 31 against 32.
  'count_juego': () => tableController(
    hands: const {0: 'R C 7 4', 1: 'R C 7 5', 2: 'R C 7 6', 3: 'S 6 5 4'},
    moves: [
      (0, const NoHayMus()),
      ...passes(0),
      ...passes(0),
      (0, const Envido(2)),
      (1, const Quiero()),
    ],
    finish: true,
  ),
  // Pares refused: the pair that bet takes them; juego sin disputa.
  'count_pares': () => tableController(
    hands: const {0: 'R R 5 4', 1: 'C C S S', 2: '7 7 7 1', 3: '6 5 4 1'},
    score: const [12, 20],
    moves: [
      (0, const NoHayMus()),
      ...passes(0),
      ...passes(0),
      (0, const Envido(2)),
      (1, const NoQuiero()),
    ],
    finish: true,
  ),
  // S-10: at 38 to 36 the chica querida wins the match; the lances after
  // it are not counted.
  'count_won': () => tableController(
    hands: const {0: '1 4 5 6', 1: 'R R C C', 2: '1 5 6 7', 3: 'R C S 7'},
    score: const [38, 36],
    moves: [
      (0, const NoHayMus()),
      ...passes(0),
      (0, const Envido(2)),
      (1, const Quiero()),
    ],
    finish: true,
  ),
};

/// The chica querida at 38 to 36 wins the juego (S-10).
MatchController _chicaWins({Rules rules = const Rules()}) => tableController(
  hands: const {0: '1 4 5 6', 1: 'R R C C', 2: '1 5 6 7', 3: 'R C S 7'},
  score: const [38, 36],
  rules: rules,
  moves: [
    (0, const NoHayMus()),
    ...passes(0),
    (0, const Envido(2)),
    (1, const Quiero()),
  ],
  finish: true,
);

/// Juegos that are over: a match won in the count, one lost to an órdago,
/// and the first juego of three, won.
final Map<String, MatchController Function()> endMoments = {
  'end_won': countMoments['count_won']!,
  'end_game': () => _chicaWins(rules: const Rules(games: 3)),
  'end_lost': () => tableController(
    hands: const {0: '4 5 6 7', 1: 'R R R R', 2: 'S C 6 5', 3: '4 5 1 7'},
    mano: 1,
    score: const [21, 17],
    moves: [(1, const NoHayMus()), (1, const Ordago()), (2, const Quiero())],
  ),
};

/// Moments of a hand the table must show well.
final Map<String, MatchController Function()> tableMoments = {
  // First hand: the mus goes round; you are mano.
  'mus': () => tableController(
    hands: const {0: 'R R 5 2', 1: 'S C 7 6', 2: '4 5 6 7', 3: '4 5 1 7'},
    musCorrido: true,
  ),
  // Everyone asked for mus: your turn to throw cards away.
  'discard': () => tableController(
    hands: _discardHands,
    moves: [
      for (final seat in [0, 1, 2, 3]) (seat, const Mus()),
    ],
  ),
  // The grande after you cut the mus: your turn to open it.
  'grande_open': () => tableController(
    hands: const {0: 'R R 7 7', 1: 'S C 7 6', 2: '4 5 6 1', 3: 'R 5 1 4'},
    moves: [(0, const NoHayMus())],
  ),
  // The grande after the mus was cut, with a bet waiting for your partner.
  'grande_envite': () => tableController(
    hands: const {0: 'R R 7 7', 1: 'S C 7 6', 2: '4 5 6 1', 3: 'R 5 1 4'},
    mano: 1,
    score: const [12, 20],
    moves: [(1, const NoHayMus()), (1, const Envido(2))],
  ),
  // A rival's órdago your partner left to you.
  'partner_decides': () => tableController(
    hands: const {0: 'R R 7 7', 1: 'S C 7 6', 2: '4 5 6 1', 3: 'R 5 1 4'},
    mano: 1,
    score: const [30, 34],
    moves: [(1, const NoHayMus()), (1, const Ordago()), (2, const NoQuiero())],
  ),
  // The chica after a grande refused, your turn to answer an envite.
  'chica_answer': () => tableController(
    hands: const {0: 'R R 7 7', 1: '1 1 4 5', 2: 'S C 6 5', 3: 'R 5 1 4'},
    mano: 3,
    score: const [12, 21],
    moves: [
      (3, const NoHayMus()),
      (3, const Paso()),
      (0, const Envido(2)),
      (1, const NoQuiero()),
      (3, const NoQuiero()),
      (3, const Envido(5)),
    ],
  ),
};

/// A match saved at its 12th hand, 23 to 31, with El Calculador as partner.
SavedMatch savedMatch() => SavedMatch(
  match: MatchState(
    rules: const Rules(),
    score: const [23, 31],
    handNumber: 12,
    hand: dealt(const {0: 'R R 7 7', 1: 'S C 7 6', 2: '4 5 6 1', 3: 'R 5 1 4'}),
  ),
  bots: tableBots,
);

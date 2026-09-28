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
import 'package:masmus/ui/table/table_screen.dart';

import '../game/scenario.dart';

/// Who sits where in the tables of the tests: you in seat 0.
const tableBots = {
  1: Personality.prudente,
  2: Personality.calculador,
  3: Personality.temeraria,
};

/// A controller for a match dealt from [hands] and played up to [moves].
/// Its bots never move by themselves: nobody advances the scheduler.
MatchController tableController({
  required Map<int, String> hands,
  int mano = 0,
  bool musCorrido = false,
  List<int> score = const [0, 0],
  List<(int, Move)> moves = const [],
  bool finish = false,
  Scheduler? scheduler,
}) {
  var match = MatchState(
    rules: const Rules(),
    score: score,
    handNumber: 1,
    hand: dealt(hands, mano: mano, musCorrido: musCorrido),
  );
  for (final (seat, move) in moves) {
    match = match.play(seat, move);
  }
  while (finish && match.hand.phase is! HandOver) {
    match = match.play(match.hand.turn!, const Paso());
  }
  return MatchController(
    match: match,
    bots: {for (final seat in tableBots.keys) seat: RandomBot(Random(seat))},
    scheduler: scheduler ?? ManualScheduler(),
    store: MatchStore.inMemory(),
  );
}

Widget tableScreen(MatchController controller, {VoidCallback? onExit}) =>
    TableScreen(
      controller: controller,
      bots: tableBots,
      onExit: onExit ?? () {},
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

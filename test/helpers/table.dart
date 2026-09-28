import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:masmus/bots/heuristic_bot.dart';
import 'package:masmus/bots/random_bot.dart';
import 'package:masmus/controllers/match_controller.dart';
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
  return MatchController(
    match: match,
    bots: {for (final seat in tableBots.keys) seat: RandomBot(Random(seat))},
    scheduler: ManualScheduler(),
    store: MatchStore.inMemory(),
  );
}

Widget tableScreen(MatchController controller, {VoidCallback? onExit}) =>
    TableScreen(
      controller: controller,
      bots: tableBots,
      onExit: onExit ?? () {},
    );

/// Moments of a hand the table must show well.
final Map<String, MatchController Function()> tableMoments = {
  // First hand: the mus goes round; you are mano.
  'mus': () => tableController(
    hands: const {0: 'R R 5 2', 1: 'S C 7 6', 2: '4 5 6 7', 3: '4 5 1 7'},
    musCorrido: true,
  ),
  // The grande after the mus was cut, with a bet waiting for your partner.
  'grande_envite': () => tableController(
    hands: const {0: 'R R 7 7', 1: 'S C 7 6', 2: '4 5 6 1', 3: 'R 5 1 4'},
    mano: 1,
    score: const [12, 20],
    moves: [(1, const NoHayMus()), (1, const Envido(2))],
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

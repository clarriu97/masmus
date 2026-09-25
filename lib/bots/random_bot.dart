import 'dart:math';

import '../game/move.dart';
import 'bot.dart';

/// Picks any legal move at random: the baseline other bots are measured
/// against, and the player of the simulation tests.
final class RandomBot implements Bot {
  RandomBot(this._random);

  final Random _random;

  @override
  Move choose(SeatView view) {
    final kinds = view.legal.toList()..sort((a, b) => a.index - b.index);
    return switch (kinds[_random.nextInt(kinds.length)]) {
      MoveKind.mus => const Mus(),
      MoveKind.noHayMus => const NoHayMus(),
      MoveKind.discard => Discard(
        ([
          ...view.cards,
        ]..shuffle(_random)).take(1 + _random.nextInt(4)).toList(),
      ),
      MoveKind.paso => const Paso(),
      MoveKind.envido => Envido(minEnvido + _random.nextInt(9)),
      MoveKind.quiero => const Quiero(),
      MoveKind.noQuiero => const NoQuiero(),
      MoveKind.ordago => const Ordago(),
    };
  }
}

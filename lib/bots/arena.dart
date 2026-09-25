import 'dart:math';

import '../game/event.dart';
import '../game/hand_state.dart';
import '../game/hand_value.dart';
import '../game/match.dart';
import '../game/rules.dart';
import '../game/table.dart';
import 'bot.dart';

typedef BotFactory = Bot Function(Random random);

/// How a team played over the arena's matches.
final class Style {
  var hands = 0;
  var envites = 0;
  var ordagos = 0;
  var cuts = 0;

  /// Envites and órdagos without the best hand at the table for that lance.
  var bluffs = 0;

  double perHand(int count) => hands == 0 ? 0 : count / hands;
}

final class ArenaResult {
  ArenaResult({
    required this.matches,
    required this.winsA,
    required this.a,
    required this.b,
  });

  final int matches;
  final int winsA;
  final Style a;
  final Style b;

  double get winRateA => winsA / matches;

  /// 95 % Wilson score interval of [winRateA].
  (double, double) get interval => wilson(winsA, matches);
}

/// The 95 % Wilson score interval for [wins] out of [total].
(double, double) wilson(int wins, int total) {
  const z = 1.96;
  final p = wins / total;
  final denominator = 1 + z * z / total;
  final center = (p + z * z / (2 * total)) / denominator;
  final margin =
      z * sqrt(p * (1 - p) / total + z * z / (4 * total * total)) / denominator;
  return (max(0, center - margin), min(1, center + margin));
}

/// Plays [pairs] × 2 matches between team A (bots from [a]) and team B
/// ([b]). Each seed is played twice with the same deal and the teams swapped
/// between seats 0/2 and 1/3, so the luck of the cards cancels out.
ArenaResult playArena({
  required BotFactory a,
  required BotFactory b,
  required int pairs,
  int seed = 0,
  Rules rules = const Rules(),
}) {
  var winsA = 0;
  final styleA = Style();
  final styleB = Style();
  for (var i = 0; i < pairs; i++) {
    for (final aSeatsEven in [true, false]) {
      final matchSeed = seed + i;
      final random = Random(matchSeed * 2 + (aSeatsEven ? 0 : 1));
      final aTeam = aSeatsEven ? 0 : 1;
      final bots = [
        for (final seat in seats) teamOf(seat) == aTeam ? a(random) : b(random),
      ];
      final winner = _play(
        MatchState.start(seed: matchSeed, rules: rules),
        bots,
        onHand: (hand) {
          for (final team in [0, 1]) {
            _record(team == aTeam ? styleA : styleB, hand, team);
          }
        },
      );
      if (winner == aTeam) {
        winsA++;
      }
    }
  }
  return ArenaResult(matches: pairs * 2, winsA: winsA, a: styleA, b: styleB);
}

int _play(
  MatchState start,
  List<Bot> bots, {
  required void Function(HandState hand) onHand,
}) {
  var match = start;
  while (true) {
    if (match.isOver) {
      onHand(match.hand);
      return match.winner!;
    }
    if (match.isCounted) {
      onHand(match.hand);
      match = match.nextHand();
      continue;
    }
    final seat = match.hand.turn!;
    match = match.play(seat, bots[seat].choose(SeatView.of(match, seat)));
  }
}

void _record(Style style, HandState hand, int team) {
  style.hands++;
  Lance? lance;
  for (final event in hand.log) {
    switch (event) {
      case LanceStarted(lance: final started):
        lance = started;
      case NoHayMusSaid(:final seat) when teamOf(seat) == team:
        style.cuts++;
      case EnvidoSaid(:final seat) when teamOf(seat) == team:
        style.envites++;
        if (!_hasBest(hand, lance!, team)) {
          style.bluffs++;
        }
      case OrdagoSaid(:final seat) when teamOf(seat) == team:
        style.ordagos++;
        if (!_hasBest(hand, lance!, team)) {
          style.bluffs++;
        }
      default:
        break;
    }
  }
}

/// Whether [team] holds the best hand at the table for [lance], ties going
/// to whoever speaks first (R-LAN-7).
bool _hasBest(HandState hand, Lance lance, int team) {
  int? best;
  for (final seat in speakingOrder(hand.mano)) {
    final value = hand.valueOf(seat);
    final plays = switch (lance) {
      Lance.pares => value.hasPares,
      Lance.juego => value.hasJuego,
      _ => true,
    };
    if (plays &&
        (best == null || compareHands(lance, value, hand.valueOf(best)) > 0)) {
      best = seat;
    }
  }
  return best != null && teamOf(best) == team;
}

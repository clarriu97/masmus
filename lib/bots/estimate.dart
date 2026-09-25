import 'dart:math';

import '../game/cards.dart';
import '../game/event.dart';
import '../game/hand_value.dart';
import '../game/rules.dart';
import '../game/table.dart';
import 'bot.dart';

/// What a seat can work out about the other hands from what it sees: the
/// cards that aren't in its hand, and who has said they have pares or juego
/// this hand. Estimates deal the other hands at random from the unseen cards,
/// keeping only deals that agree with those declarations.
final class Knowledge {
  Knowledge.of(SeatView view)
    : seat = view.seat,
      mano = view.mano,
      rules = view.rules,
      cards = view.cards,
      unseen = [
        for (final card in spanishDeck)
          if (!view.cards.contains(card)) card,
      ],
      declared = {
        for (final event in view.log.whereType<Declared>())
          (event.seat, event.lance): event.has,
      };

  final int seat;
  final int mano;
  final Rules rules;
  final List<PlayingCard> cards;
  final List<PlayingCard> unseen;
  final Map<(int, Lance), bool> declared;

  int get team => teamOf(seat);

  /// Hands for the three other seats from the unseen cards, each dealt again
  /// until it agrees with that seat's declarations (after [tries] deals it is
  /// kept anyway).
  Map<int, List<PlayingCard>> sampleOthers(Random random, {int tries = 100}) {
    final left = [...unseen];
    return {
      for (final other in seats)
        if (other != seat) other: _deal(other, left, random, tries),
    };
  }

  List<PlayingCard> _deal(
    int other,
    List<PlayingCard> left,
    Random random,
    int tries,
  ) {
    for (var attempt = 0; attempt < tries; attempt++) {
      left.shuffle(random);
      if (_agrees(other, HandValue(left.sublist(0, 4), rules))) {
        break;
      }
    }
    final hand = left.sublist(0, 4);
    left.removeRange(0, 4);
    return hand;
  }

  Map<int, HandValue> _table(Random random, HandValue mine) => {
    for (final MapEntry(key: other, value: hand) in sampleOthers(
      random,
    ).entries)
      other: HandValue(hand, rules),
    seat: mine,
  };

  bool _agrees(int other, HandValue value) =>
      (declared[(other, Lance.pares)] ?? value.hasPares) == value.hasPares &&
      (declared[(other, Lance.juego)] ?? value.hasJuego) == value.hasJuego;

  /// How often this seat's team wins [lance] with [mine], over [samples]
  /// deals of the other hands. Only players who can play the lance count.
  double winChance(Lance lance, Random random, {int samples = 60}) {
    final hand = HandValue(cards, rules);
    var wins = 0;
    for (var i = 0; i < samples; i++) {
      if (bestTeam(lance, _table(random, hand), mano) == team) {
        wins++;
      }
    }
    return wins / samples;
  }

  /// [advantage] after throwing away all but [keep] and drawing. Each of
  /// [deals] is an order of the unseen cards: the other hands first, then
  /// the draw, so that every discard is judged on the same deals.
  double advantageAfterDrawing(
    List<PlayingCard> keep,
    List<List<PlayingCard>> deals,
  ) {
    final others = [
      for (final other in seats)
        if (other != seat) other,
    ];
    var total = 0;
    for (final deal in deals) {
      final table = {
        for (final (i, other) in others.indexed)
          other: HandValue(deal.sublist(i * 4, i * 4 + 4), rules),
        seat: HandValue([
          ...keep,
          ...deal.skip(others.length * 4).take(4 - keep.length),
        ], rules),
      };
      total += _pointsAhead(table);
    }
    return total / deals.length;
  }

  /// This seat's team's points minus the rivals' if every lance went en
  /// paso: a measure of how good its hand is, averaged over [samples] deals.
  double advantage(Random random, {int samples = 40}) {
    final hand = HandValue(cards, rules);
    var total = 0;
    for (var i = 0; i < samples; i++) {
      total += _pointsAhead(_table(random, hand));
    }
    return total / samples;
  }

  int _pointsAhead(Map<int, HandValue> table) {
    final points = enPasoPoints(table, mano);
    return points[team] - points[1 - team];
  }
}

/// The team with the best hand for [lance] among the seats that can play it,
/// ties going to whoever speaks first (R-LAN-7); null when nobody can.
int? bestTeam(Lance lance, Map<int, HandValue> table, int mano) {
  int? best;
  for (final seat in speakingOrder(mano)) {
    final value = table[seat]!;
    final plays = switch (lance) {
      Lance.pares => value.hasPares,
      Lance.juego => value.hasJuego,
      _ => true,
    };
    if (plays &&
        (best == null || compareHands(lance, value, table[best]!) > 0)) {
      best = seat;
    }
  }
  return best == null ? null : teamOf(best);
}

/// What each team would score if nobody bet (R-REC-2 to R-REC-5).
List<int> enPasoPoints(Map<int, HandValue> table, int mano) {
  final points = [0, 0];
  for (final lance in [Lance.grande, Lance.chica]) {
    points[bestTeam(lance, table, mano)!]++;
  }
  final pares = bestTeam(Lance.pares, table, mano);
  if (pares != null) {
    points[pares] += _teamTantos(table, pares, (value) => value.paresTantos);
  }
  final juego = bestTeam(Lance.juego, table, mano);
  if (juego != null) {
    points[juego] += _teamTantos(table, juego, (value) => value.juegoTantos);
  } else {
    points[bestTeam(Lance.punto, table, mano)!]++;
  }
  return points;
}

int _teamTantos(
  Map<int, HandValue> table,
  int team,
  int Function(HandValue) tantos,
) => table.entries
    .where((entry) => teamOf(entry.key) == team)
    .fold(0, (sum, entry) => sum + tantos(entry.value));

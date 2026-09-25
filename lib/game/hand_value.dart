import 'cards.dart';
import 'rules.dart';

enum Lance { grande, chica, pares, juego, punto }

enum ParesKind { none, par, medias, duples }

/// Juego totals from best to worst (R-LAN-5).
const juegoOrder = [31, 32, 40, 37, 36, 35, 34, 33];

/// What a four-card hand is worth in every lance, with the variant's kings
/// already applied (R-BAR-2).
final class HandValue {
  factory HandValue(List<PlayingCard> cards, Rules rules) {
    assert(cards.length == 4);
    final ranks = [for (final card in cards) effectiveRank(card, rules.kings)]
      ..sort((a, b) => b - a);
    final (pares, paresRanks) = _pares(ranks);
    final points = ranks.fold(0, (sum, rank) => sum + (rank >= 10 ? 10 : rank));
    return HandValue._(List.unmodifiable(ranks), pares, paresRanks, points);
  }

  HandValue._(this.ranks, this.pares, this.paresRanks, this.points);

  /// Ranks from highest to lowest (R-BAR-3).
  final List<int> ranks;

  final ParesKind pares;

  /// The ranks that form the pares, highest first: one for par and medias,
  /// two for duples.
  final List<int> paresRanks;

  /// Sum for juego and punto (R-BAR-4).
  final int points;

  bool get hasPares => pares != ParesKind.none;

  bool get hasJuego => points >= 31;

  /// Points this hand scores for its pair when the pair wins pares (R-REC-3).
  int get paresTantos => switch (pares) {
    ParesKind.none => 0,
    ParesKind.par => 1,
    ParesKind.medias => 2,
    ParesKind.duples => 3,
  };

  /// Points this hand scores for its pair when the pair wins juego (R-REC-4).
  int get juegoTantos => !hasJuego ? 0 : (points == 31 ? 3 : 2);

  @override
  bool operator ==(Object other) =>
      other is HandValue &&
      other.pares == pares &&
      other.points == points &&
      _compareLists(other.ranks, ranks) == 0 &&
      _compareLists(other.paresRanks, paresRanks) == 0;

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(ranks), pares, Object.hashAll(paresRanks));
}

/// Positive when [a] wins [lance] against [b], negative when [b] wins, zero
/// on a tie, which the caller breaks by position (R-LAN-7).
int compareHands(Lance lance, HandValue a, HandValue b) => switch (lance) {
  Lance.grande => _compareLists(a.ranks, b.ranks),
  Lance.chica => _compareLists(
    b.ranks.reversed.toList(),
    a.ranks.reversed.toList(),
  ),
  Lance.pares =>
    a.pares != b.pares
        ? a.pares.index - b.pares.index
        : _compareLists(a.paresRanks, b.paresRanks),
  Lance.juego => _juegoStrength(b.points) - _juegoStrength(a.points),
  Lance.punto => a.points - b.points,
};

/// The rank a card counts as in the variant (R-BAR-2): with eight kings a 3
/// is a rey and a 2 an as.
int effectiveRank(PlayingCard card, Kings kings) => switch (card.number) {
  3 when kings == Kings.eight => 12,
  2 when kings == Kings.eight => 1,
  final number => number,
};

(ParesKind, List<int>) _pares(List<int> ranks) {
  final counts = <int, int>{};
  for (final rank in ranks) {
    counts[rank] = (counts[rank] ?? 0) + 1;
  }
  final groups = counts.entries.where((e) => e.value >= 2).toList()
    ..sort((a, b) => a.value != b.value ? b.value - a.value : b.key - a.key);
  return switch (groups) {
    [] => (ParesKind.none, const []),
    [final four] when four.value == 4 => (
      ParesKind.duples,
      [four.key, four.key],
    ),
    [final high, final low] => (ParesKind.duples, [high.key, low.key]),
    [final three] when three.value == 3 => (ParesKind.medias, [three.key]),
    [final pair] => (ParesKind.par, [pair.key]),
    _ => throw StateError('Impossible four-card hand: $ranks'),
  };
}

/// Lower is better; every total without juego ranks below every juego.
int _juegoStrength(int points) {
  final index = juegoOrder.indexOf(points);
  return index < 0 ? juegoOrder.length : index;
}

int _compareLists(List<int> a, List<int> b) {
  for (var i = 0; i < a.length && i < b.length; i++) {
    if (a[i] != b[i]) {
      return a[i] - b[i];
    }
  }
  return a.length - b.length;
}

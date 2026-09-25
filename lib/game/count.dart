import 'hand_state.dart';
import 'hand_value.dart';
import 'outcome.dart';
import 'table.dart';

/// How one lance adds up at the end of the hand (R-REC-2 to R-REC-5), as the
/// count screen shows it.
final class LanceCount {
  const LanceCount(
    this.outcome, {
    this.team,
    this.seat,
    this.stake = 0,
    this.paidAtOnce = 0,
    this.combinations = 0,
    this.counted = true,
  });

  final LanceOutcome outcome;

  /// The team that takes the lance; null when nobody played it.
  final int? team;

  /// Whose hand wins it, when a hand decides it.
  final int? seat;

  /// Points of the envite added at the count (1 for grande or chica en paso).
  final int stake;

  /// Points of a "no quiero", already taken during the hand.
  final int paidAtOnce;

  /// Points for pares, juego or punto of the winning team.
  final int combinations;

  /// False when the match was already won before this lance was counted
  /// (R-REC-6).
  final bool counted;

  int get points => counted ? stake + combinations : 0;

  LanceCount notCounted() => LanceCount(
    outcome,
    team: team,
    seat: seat,
    stake: stake,
    paidAtOnce: paidAtOnce,
    combinations: combinations,
    counted: false,
  );
}

/// The count of a finished hand (R-REC-1): lance by lance, from the score
/// [before] it (which already includes the points of any "no quiero").
final class HandCount {
  const HandCount({
    required this.lances,
    required this.before,
    required this.after,
    this.winner,
  });

  final List<LanceCount> lances;
  final List<int> before;
  final List<int> after;

  /// The team that won the match in this count, if any.
  final int? winner;
}

/// Counts a finished [hand] starting from the score [before], stopping at the
/// first team to reach [target] (R-REC-6). An accepted órdago decides the
/// match on its own (R-FIN-3).
HandCount countHand(HandState hand, List<int> before, int target) {
  assert(hand.phase is HandOver);
  final lances = [for (final outcome in hand.outcomes) _count(hand, outcome)];
  final ordago = lances.where((c) => c.outcome is OrdagoQuerido).firstOrNull;
  if (ordago != null) {
    return HandCount(
      lances: [
        for (final lance in lances)
          lance == ordago ? lance : lance.notCounted(),
      ],
      before: before,
      after: before,
      winner: ordago.team,
    );
  }
  final after = [...before];
  final counted = <LanceCount>[];
  int? winner;
  for (final lance in lances) {
    if (winner != null) {
      counted.add(lance.notCounted());
      continue;
    }
    counted.add(lance);
    final team = lance.team;
    if (team != null) {
      after[team] += lance.points;
      if (after[team] >= target) {
        winner = team;
      }
    }
  }
  return HandCount(
    lances: counted,
    before: before,
    after: after,
    winner: winner,
  );
}

LanceCount _count(HandState hand, LanceOutcome outcome) {
  final lance = outcome.lance;
  int combinations(int team) => switch (lance) {
    Lance.pares =>
      _teamSeats(hand, lance, team)
          .map((seat) => hand.valueOf(seat).paresTantos)
          .fold(0, (sum, points) => sum + points),
    Lance.juego =>
      _teamSeats(hand, lance, team)
          .map((seat) => hand.valueOf(seat).juegoTantos)
          .fold(0, (sum, points) => sum + points),
    Lance.punto => 1,
    Lance.grande || Lance.chica => 0,
  };
  final enPasoPoint = lance == Lance.grande || lance == Lance.chica ? 1 : 0;
  switch (outcome) {
    case NotPlayed():
      return LanceCount(outcome);
    case SinDisputa(:final team):
      return LanceCount(
        outcome,
        team: team,
        seat: _best(hand, lance, _teamSeats(hand, lance, team)),
        combinations: combinations(team),
      );
    case EnPaso() || Querido() || OrdagoQuerido():
      final seat = _best(hand, lance, _eligible(hand, lance))!;
      final team = teamOf(seat);
      return LanceCount(
        outcome,
        team: team,
        seat: seat,
        stake: switch (outcome) {
          Querido(:final stake) => stake,
          OrdagoQuerido() => 0,
          _ => enPasoPoint,
        },
        combinations: outcome is OrdagoQuerido ? 0 : combinations(team),
      );
    case NoQuerido(:final team, :final points):
      return LanceCount(
        outcome,
        team: team,
        seat: lance == Lance.grande || lance == Lance.chica
            ? null
            : _best(hand, lance, _teamSeats(hand, lance, team)),
        paidAtOnce: points,
        combinations: combinations(team),
      );
  }
}

/// The players who could play [lance], in speaking order.
List<int> _eligible(HandState hand, Lance lance) => [
  for (final seat in speakingOrder(hand.mano))
    if (switch (lance) {
      Lance.pares => hand.valueOf(seat).hasPares,
      Lance.juego => hand.valueOf(seat).hasJuego,
      _ => true,
    })
      seat,
];

List<int> _teamSeats(HandState hand, Lance lance, int team) => [
  for (final seat in _eligible(hand, lance))
    if (teamOf(seat) == team) seat,
];

/// The best hand among [candidates] (in speaking order): ties go to the one
/// who speaks first (R-LAN-7).
int? _best(HandState hand, Lance lance, List<int> candidates) {
  int? best;
  for (final seat in candidates) {
    if (best == null ||
        compareHands(lance, hand.valueOf(seat), hand.valueOf(best)) > 0) {
      best = seat;
    }
  }
  return best;
}

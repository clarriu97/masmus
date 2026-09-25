import 'count.dart';
import 'deck.dart';
import 'game_random.dart';
import 'hand_state.dart';
import 'move.dart';
import 'outcome.dart';
import 'play.dart' as hands;
import 'rules.dart';
import 'table.dart';

/// How the match was won.
enum MatchEnd {
  /// A team reached the target in the count (R-REC-6).
  count,

  /// The points of a "no quiero" took a team there mid-hand (R-FIN-2).
  noQuiero,

  /// An accepted órdago (R-FIN-3).
  ordago,
}

/// A match to [Rules.target] points: the score, the hand being played and,
/// once it ends, the winner. Immutable and serializable like [HandState].
final class MatchState {
  const MatchState({
    required this.rules,
    required this.score,
    required this.handNumber,
    required this.hand,
    this.winner,
    this.end,
  });

  /// The first hand: the mano is drawn from [seed] unless given (R-ORD-4),
  /// and it is played with mus corrido (R-MUS-5).
  factory MatchState.start({
    required int seed,
    Rules rules = const Rules(),
    int? mano,
  }) {
    var random = GameRandom(seed);
    var first = mano;
    if (first == null) {
      final (drawn, next) = random.nextInt(4);
      first = drawn;
      random = next;
    }
    final (deck, afterShuffle) = shuffledDeck(random);
    return MatchState(
      rules: rules,
      score: const [0, 0],
      handNumber: 1,
      hand: HandState.deal(
        rules: rules,
        mano: first,
        deck: deck,
        random: afterShuffle,
        musCorrido: true,
      ),
    );
  }

  factory MatchState.fromJson(Map<String, Object?> json) => MatchState(
    rules: Rules.fromJson(json['rules']! as Map<String, Object?>),
    score: List.unmodifiable((json['score']! as List<Object?>).cast<int>()),
    handNumber: json['handNumber']! as int,
    hand: HandState.fromJson(json['hand']! as Map<String, Object?>),
    winner: json['winner'] as int?,
    end: switch (json['end']) {
      final String end => MatchEnd.values.byName(end),
      _ => null,
    },
  );

  final Rules rules;

  /// Each team's points when the current hand was dealt.
  final List<int> score;

  final int handNumber;
  final HandState hand;
  final int? winner;
  final MatchEnd? end;

  bool get isOver => winner != null;

  /// The hand is counted and the match goes on: waiting for [nextHand].
  bool get isCounted => hand.phase is HandOver && !isOver;

  /// The count of the current hand once it is over. Not there when a "no
  /// quiero" ended the match mid-hand.
  HandCount? get count => hand.phase is HandOver
      ? countHand(hand, _withPointsNow, rules.target)
      : null;

  /// The score as the table shows it right now.
  List<int> get scoreNow => count?.after ?? _withPointsNow;

  List<int> get _withPointsNow => [
    for (final team in [0, 1]) score[team] + hand.pointsNow[team],
  ];

  Set<MoveKind> legalMoves(int seat) =>
      isOver ? const {} : hands.legalMoves(hand, seat);

  bool isLegal(int seat, Move move) =>
      !isOver && hands.isLegal(hand, seat, move);

  MatchState play(int seat, Move move) {
    if (isOver) {
      throw StateError('The match is over');
    }
    final next = MatchState(
      rules: rules,
      score: score,
      handNumber: handNumber,
      hand: hands.play(hand, seat, move),
    );
    final now = next._withPointsNow;
    for (final team in [0, 1]) {
      if (now[team] >= rules.target) {
        return next._won(team, MatchEnd.noQuiero);
      }
    }
    final count = next.count;
    if (count?.winner case final team?) {
      final ordago = next.hand.outcomes.lastOrNull is OrdagoQuerido;
      return next._won(team, ordago ? MatchEnd.ordago : MatchEnd.count);
    }
    return next;
  }

  /// Deals the next hand after a count, with the next mano (R-FIN-4,
  /// R-ORD-3).
  MatchState nextHand() {
    if (!isCounted) {
      throw StateError('The hand is not counted yet');
    }
    final (deck, random) = shuffledDeck(hand.random);
    return MatchState(
      rules: rules,
      score: List.unmodifiable(scoreNow),
      handNumber: handNumber + 1,
      hand: HandState.deal(
        rules: rules,
        mano: nextSeat(hand.mano),
        deck: deck,
        random: random,
      ),
    );
  }

  MatchState _won(int team, MatchEnd end) => MatchState(
    rules: rules,
    score: score,
    handNumber: handNumber,
    hand: hand,
    winner: team,
    end: end,
  );

  Map<String, Object?> toJson() => {
    'rules': rules.toJson(),
    'score': score,
    'handNumber': handNumber,
    'hand': hand.toJson(),
    'winner': winner,
    'end': end?.name,
  };
}

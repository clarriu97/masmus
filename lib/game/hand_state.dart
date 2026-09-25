import 'cards.dart';
import 'event.dart';
import 'game_random.dart';
import 'hand_value.dart';
import 'outcome.dart';
import 'rules.dart';
import 'table.dart';

/// One hand, from the deal until its last lance closes. Immutable: moves
/// produce a new state (`play` in play.dart), and every state can be saved as
/// JSON and restored.
final class HandState {
  const HandState({
    required this.rules,
    required this.mano,
    required this.musCorrido,
    required this.hands,
    required this.stock,
    required this.discards,
    required this.random,
    required this.phase,
    required this.outcomes,
    required this.log,
  });

  /// Deals four cards to each seat from the top of [deck], in speaking order
  /// from the [mano] (R-MUS-1). [musCorrido] for the first hand of a game
  /// (R-MUS-5).
  factory HandState.deal({
    required Rules rules,
    required int mano,
    required List<PlayingCard> deck,
    required GameRandom random,
    bool musCorrido = false,
  }) {
    assert(deck.length == 40 && deck.toSet().length == 40);
    final hands = List<List<PlayingCard>>.filled(4, const []);
    final order = speakingOrder(mano);
    for (var i = 0; i < 4; i++) {
      hands[order[i]] = List.unmodifiable(deck.sublist(i * 4, i * 4 + 4));
    }
    return HandState(
      rules: rules,
      mano: mano,
      musCorrido: musCorrido,
      hands: List.unmodifiable(hands),
      stock: List.unmodifiable(deck.sublist(16)),
      discards: const [],
      random: random,
      phase: MusTurn(mano, said: 0),
      outcomes: const [],
      log: const [],
    );
  }

  factory HandState.fromJson(Map<String, Object?> json) {
    List<PlayingCard> cards(Object? codes) => List.unmodifiable([
      for (final code in codes! as List<Object?>)
        PlayingCard.parse(code! as String),
    ]);
    return HandState(
      rules: Rules.fromJson(json['rules']! as Map<String, Object?>),
      mano: json['mano']! as int,
      musCorrido: json['musCorrido']! as bool,
      hands: List.unmodifiable([
        for (final hand in json['hands']! as List<Object?>) cards(hand),
      ]),
      stock: cards(json['stock']),
      discards: cards(json['discards']),
      random: GameRandom(json['random']! as int),
      phase: HandPhase.fromJson(json['phase']! as Map<String, Object?>),
      outcomes: List.unmodifiable([
        for (final outcome in json['outcomes']! as List<Object?>)
          LanceOutcome.fromJson(outcome! as Map<String, Object?>),
      ]),
      log: List.unmodifiable([
        for (final event in json['log']! as List<Object?>)
          GameEvent.fromJson(event! as Map<String, Object?>),
      ]),
    );
  }

  final Rules rules;

  /// Speaks first. Only moves during mus corrido.
  final int mano;
  final bool musCorrido;

  /// The four cards of each seat.
  final List<List<PlayingCard>> hands;
  final List<PlayingCard> stock;
  final List<PlayingCard> discards;
  final GameRandom random;
  final HandPhase phase;

  /// The lances closed so far, in order.
  final List<LanceOutcome> outcomes;

  /// Everything the table has seen happen, in order.
  final List<GameEvent> log;

  HandValue valueOf(int seat) => HandValue(hands[seat], rules);

  /// The seat that has to move, or null once the hand is over.
  int? get turn => switch (phase) {
    MusTurn(:final seat) ||
    DiscardTurn(:final seat) ||
    LanceTurn(:final seat) => seat,
    HandOver() => null,
  };

  /// Points each team took at once with a "no quiero" (R-ENV-6).
  List<int> get pointsNow => [
    for (final team in [0, 1])
      outcomes
          .whereType<NoQuerido>()
          .where((o) => o.team == team)
          .fold(0, (sum, o) => sum + o.points),
  ];

  HandState copyWith({
    int? mano,
    List<List<PlayingCard>>? hands,
    List<PlayingCard>? stock,
    List<PlayingCard>? discards,
    GameRandom? random,
    HandPhase? phase,
    List<LanceOutcome>? outcomes,
    List<GameEvent>? log,
  }) => HandState(
    rules: rules,
    mano: mano ?? this.mano,
    musCorrido: musCorrido,
    hands: hands == null
        ? this.hands
        : List.unmodifiable([
            for (final hand in hands) List<PlayingCard>.unmodifiable(hand),
          ]),
    stock: stock == null ? this.stock : List.unmodifiable(stock),
    discards: discards == null ? this.discards : List.unmodifiable(discards),
    random: random ?? this.random,
    phase: phase ?? this.phase,
    outcomes: outcomes == null ? this.outcomes : List.unmodifiable(outcomes),
    log: log == null ? this.log : List.unmodifiable(log),
  );

  Map<String, Object?> toJson() => {
    'rules': rules.toJson(),
    'mano': mano,
    'musCorrido': musCorrido,
    'hands': [
      for (final hand in hands) [for (final card in hand) card.code],
    ],
    'stock': [for (final card in stock) card.code],
    'discards': [for (final card in discards) card.code],
    'random': random.state,
    'phase': phase.toJson(),
    'outcomes': [for (final outcome in outcomes) outcome.toJson()],
    'log': [for (final event in log) event.toJson()],
  };
}

sealed class HandPhase {
  const HandPhase();

  factory HandPhase.fromJson(Map<String, Object?> json) {
    final seat = json['seat'] as int?;
    return switch (json['type']) {
      'mus' => MusTurn(seat!, said: json['said']! as int),
      'discard' => DiscardTurn(
        seat!,
        chosen: {
          for (final MapEntry(:key, :value)
              in (json['chosen']! as Map<String, Object?>).entries)
            int.parse(key): List<PlayingCard>.unmodifiable([
              for (final code in value! as List<Object?>)
                PlayingCard.parse(code! as String),
            ]),
        },
      ),
      'lance' => LanceTurn(
        Lance.values.byName(json['lance']! as String),
        seat: seat!,
        eligible: List.unmodifiable(
          (json['eligible']! as List<Object?>).cast<int>(),
        ),
        envite: json['envite'] == null
            ? null
            : Envite.fromJson(json['envite']! as Map<String, Object?>),
      ),
      'over' => const HandOver(),
      final type => throw FormatException('Unknown phase', type),
    };
  }

  Map<String, Object?> toJson();
}

/// [seat] says mus or no hay mus; [said] players already said mus this round.
final class MusTurn extends HandPhase {
  const MusTurn(this.seat, {required this.said});

  final int seat;
  final int said;

  @override
  Map<String, Object?> toJson() => {'type': 'mus', 'seat': seat, 'said': said};
}

/// [seat] picks their discards; [chosen] holds those already picked, served
/// once all four have chosen (R-MUS-3).
final class DiscardTurn extends HandPhase {
  const DiscardTurn(this.seat, {required this.chosen});

  final int seat;
  final Map<int, List<PlayingCard>> chosen;

  @override
  Map<String, Object?> toJson() => {
    'type': 'discard',
    'seat': seat,
    'chosen': {
      for (final MapEntry(:key, :value) in chosen.entries)
        '$key': [for (final card in value) card.code],
    },
  };
}

/// [seat] speaks in [lance]. [eligible] are the players who can play it, in
/// speaking order; [envite] is the bet waiting for an answer, if any.
final class LanceTurn extends HandPhase {
  const LanceTurn(
    this.lance, {
    required this.seat,
    required this.eligible,
    this.envite,
  });

  final Lance lance;
  final int seat;
  final List<int> eligible;
  final Envite? envite;

  @override
  Map<String, Object?> toJson() => {
    'type': 'lance',
    'lance': lance.name,
    'seat': seat,
    'eligible': eligible,
    'envite': envite?.toJson(),
  };
}

/// The bet on the table in a lance (R-ENV-3 to R-ENV-7).
final class Envite {
  const Envite({
    required this.bettor,
    required this.stake,
    required this.accepted,
    required this.ordago,
    required this.responders,
  });

  factory Envite.fromJson(Map<String, Object?> json) => Envite(
    bettor: json['bettor']! as int,
    stake: json['stake']! as int,
    accepted: json['accepted']! as int,
    ordago: json['ordago']! as bool,
    responders: List.unmodifiable(
      (json['responders']! as List<Object?>).cast<int>(),
    ),
  );

  /// Who made the last envite.
  final int bettor;

  /// What the lance is worth if the envite is accepted.
  final int stake;

  /// What was already accepted before it: a "no quiero" pays this, or 1 if
  /// nothing was (R-ENV-6).
  final int accepted;

  final bool ordago;

  /// The rivals still to answer, in order; the first one is speaking.
  final List<int> responders;

  int get noQuieroPoints => accepted == 0 ? 1 : accepted;

  Map<String, Object?> toJson() => {
    'bettor': bettor,
    'stake': stake,
    'accepted': accepted,
    'ordago': ordago,
    'responders': responders,
  };
}

/// No more lances to play: waiting for the count.
final class HandOver extends HandPhase {
  const HandOver();

  @override
  Map<String, Object?> toJson() => {'type': 'over'};
}

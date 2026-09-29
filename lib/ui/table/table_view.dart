import '../../game/cards.dart';
import '../../game/event.dart';
import '../../game/hand_state.dart';
import '../../game/hand_value.dart';
import '../../game/match.dart';
import '../../game/outcome.dart';
import '../../game/table.dart';

/// The steps of a hand, in the row at the top of the table. [juego] becomes
/// the punto when nobody has juego.
enum TableStep { mus, grande, chica, pares, juego, punto }

enum StepProgress { pending, current, done }

/// What is bet in the lance being played: [stake] tantos, or an órdago.
typedef Bet = ({int stake, bool ordago});

/// One step in that row: where it is and, when it is over, how it went.
final class StepView {
  const StepView(
    this.step,
    this.state, {
    this.outcome,
    this.envite,
    this.cut = false,
    this.corrido = false,
    this.discarding = false,
    this.declaring = false,
  });

  final TableStep step;
  final StepProgress state;

  /// How a lance went, once it is [StepProgress.done].
  final LanceOutcome? outcome;

  /// What is bet in the lance being played.
  final Bet? envite;

  /// Someone said "no hay mus".
  final bool cut;

  /// First hand: the mus goes round until someone cuts it (R-MUS-5).
  final bool corrido;

  final bool discarding;

  /// The players are saying whether they have pares or juego.
  final bool declaring;
}

/// What the table shows of a match from [you]r seat, worked out from the
/// engine's state and its log: the score, who is mano and postre, whose
/// turn it is, where the hand is, what each player just said and what is
/// on the table. With [shown], as it was once the first [shown] events of
/// the log had happened: while the table catches up, or while the cards
/// are [dealing], it is nobody's turn yet.
final class TableView {
  factory TableView.of(
    MatchState match, {
    required int you,
    int? shown,
    bool dealing = false,
  }) {
    final hand = match.hand;
    final log = shown == null ? hand.log : hand.log.sublist(0, shown);
    final live = log.length == hand.log.length;
    final score = live
        ? match.scoreNow
        : [
            for (final team in [0, 1])
              match.score[team] +
                  log
                      .whereType<LanceClosed>()
                      .map((closed) => closed.outcome)
                      .whereType<NoQuerido>()
                      .where((outcome) => outcome.team == team)
                      .fold<int>(0, (sum, outcome) => sum + outcome.points),
          ];
    final us = teamOf(you);
    return TableView._(
      you: you,
      us: score[us],
      them: score[1 - us],
      target: match.rules.target,
      mano: _manoAt(hand, log),
      turn: live && !dealing ? hand.turn : null,
      steps: _steps(hand, log),
      said: {
        for (final MapEntry(:key, :value) in _said(log).entries)
          key: log[value],
      },
      saidAt: _said(log),
      asked: {
        for (final event in log.whereType<Discarded>()) event.seat: event.count,
      },
      thrown: _thrown(log),
      bet: _bet(log),
      latest: live ? null : log.lastOrNull,
      stake: switch (hand.phase) {
        LanceTurn(:final envite?) when live => envite,
        _ => null,
      },
      cards: switch (hand.phase) {
        DiscardTurn(:final chosen) when chosen[you] != null => [
          for (final card in hand.hands[you])
            if (!chosen[you]!.contains(card)) card,
        ],
        _ => hand.hands[you],
      },
      value: HandValue(hand.hands[you], match.rules),
    );
  }

  const TableView._({
    required this.you,
    required this.us,
    required this.them,
    required this.target,
    required this.mano,
    required this.turn,
    required this.steps,
    required this.said,
    required this.saidAt,
    required this.asked,
    required this.thrown,
    required this.bet,
    required this.latest,
    required this.stake,
    required this.cards,
    required this.value,
  });

  final int you;
  final int us;
  final int them;
  final int target;
  final int mano;

  /// The seat that speaks last (R-ORD-2).
  int get postre => (mano + 3) % 4;

  final int? turn;
  bool get yourTurn => turn == you;

  final List<StepView> steps;

  /// The last thing each seat said in the step being played, or in the one
  /// just over while nobody has spoken in the new one.
  final Map<int, GameEvent> said;

  /// Where in the log each of [said] was said: a new word, a new place.
  final Map<int, int> saidAt;

  /// While the table catches up, what it is showing now.
  final GameEvent? latest;

  /// How many cards each seat asked for in the last discards of the hand.
  final Map<int, int> asked;

  /// How many cards each seat has thrown away in the discards going on,
  /// before the new ones are dealt.
  final Map<int, int> thrown;

  /// Whether it is your turn to throw cards away.
  bool get youDiscard => yourTurn && _discarding;

  /// What is bet in the lance being played.
  final Bet? bet;

  /// The bet waiting for an answer, once the table has caught up.
  final Envite? stake;

  final List<PlayingCard> cards;
  final HandValue value;

  bool get _discarding => steps.first.discarding;

  /// The step being played, if any.
  StepView? get current =>
      steps.where((step) => step.state == StepProgress.current).firstOrNull;

  bool partnerOf(int seat) => teamOf(seat) == teamOf(you) && seat != you;
}

List<StepView> _steps(HandState hand, List<GameEvent> log) {
  final closed = <Lance, LanceOutcome>{};
  Lance? current;
  var declaring = false;
  for (final event in log) {
    declaring = event is Declared;
    switch (event) {
      case LanceStarted(:final lance) || Declared(:final lance):
        current = lance;
      case LanceClosed(:final outcome):
        closed[outcome.lance] = outcome;
        current = null;
      default:
        break;
    }
  }
  final cut = log.any((event) => event is NoHayMusSaid);
  final inMus = !cut && !log.any((event) => event is LanceStarted);
  final punto = current == Lance.punto || closed.containsKey(Lance.punto);
  final bet = _bet(log);
  StepView lance(TableStep step, Lance lance) {
    final outcome = closed[lance];
    if (outcome != null) {
      return StepView(step, StepProgress.done, outcome: outcome);
    }
    return current == lance
        ? StepView(
            step,
            StepProgress.current,
            envite: bet,
            declaring: declaring,
          )
        : StepView(step, StepProgress.pending);
  }

  return [
    StepView(
      TableStep.mus,
      inMus ? StepProgress.current : StepProgress.done,
      cut: cut,
      corrido: hand.musCorrido && inMus,
      discarding: _discarding(log),
    ),
    lance(TableStep.grande, Lance.grande),
    lance(TableStep.chica, Lance.chica),
    lance(TableStep.pares, Lance.pares),
    punto
        ? lance(TableStep.punto, Lance.punto)
        : lance(TableStep.juego, Lance.juego),
  ];
}

/// What is bet in the lance open at the end of [log].
Bet? _bet(List<GameEvent> log) {
  Bet? bet;
  for (final event in log) {
    bet = switch (event) {
      EnvidoSaid(:final stake) => (stake: stake, ordago: false),
      OrdagoSaid() => (stake: bet?.stake ?? 0, ordago: true),
      LanceStarted() || LanceClosed() => null,
      _ => bet,
    };
  }
  return bet;
}

Map<int, int> _thrown(List<GameEvent> log) {
  final start = log.lastIndexWhere((event) => event is! Discarded) + 1;
  final round = log.sublist(start).whereType<Discarded>().toList();
  return round.length == 4
      ? const {}
      : {for (final discard in round) discard.seat: discard.count};
}

/// Everyone asked for mus and not all of them have thrown their cards yet.
bool _discarding(List<GameEvent> log) {
  var mus = 0;
  var discarded = 0;
  for (final event in log) {
    switch (event) {
      case MusSaid():
        if (discarded == 4) {
          mus = 0;
          discarded = 0;
        }
        mus++;
      case Discarded():
        discarded++;
      default:
        break;
    }
  }
  return mus == 4 && discarded < 4;
}

/// Who is mano at the end of [log]. During mus corrido it moves, and the
/// first to speak in the hand was the mano it was dealt with.
int _manoAt(HandState hand, List<GameEvent> log) {
  if (!hand.log.any((event) => event is ManoMoved)) {
    return hand.mano;
  }
  if (log.whereType<ManoMoved>().lastOrNull case final moved?) {
    return moved.seat;
  }
  return switch (hand.log.first) {
    MusSaid(:final seat) || NoHayMusSaid(:final seat) => seat,
    _ => hand.mano,
  };
}

bool _spoken(GameEvent event) => switch (event) {
  MusSaid() ||
  NoHayMusSaid() ||
  Discarded() ||
  Declared() ||
  PasoSaid() ||
  EnvidoSaid() ||
  QuieroSaid() ||
  NoQuieroSaid() ||
  OrdagoSaid() => true,
  _ => false,
};

/// Where each step starts in the log: a lance, a round of mus, a round of
/// discards.
List<int> _stepStarts(List<GameEvent> log) => [
  0,
  for (var i = 1; i < log.length; i++)
    if (switch ((log[i - 1], log[i])) {
      (_, LanceStarted()) => true,
      (LanceClosed(), Declared()) => true,
      (Discarded(), MusSaid() || NoHayMusSaid()) => true,
      (Reshuffled(), MusSaid() || NoHayMusSaid()) => true,
      (MusSaid(), Discarded()) => true,
      _ => false,
    })
      i,
];

/// Where in [log] each seat last spoke in the step being played, or in
/// the one just over while nobody has spoken in the new one.
Map<int, int> _said(List<GameEvent> log) {
  final starts = _stepStarts(log);
  for (var s = starts.length - 1; s >= 0; s--) {
    final end = s + 1 < starts.length ? starts[s + 1] : log.length;
    final said = <int, int>{
      for (var i = starts[s]; i < end; i++)
        if (_spoken(log[i])) _seatOf(log[i]): i,
    };
    if (said.isNotEmpty) {
      return said;
    }
  }
  return const {};
}

int _seatOf(GameEvent event) => switch (event) {
  MusSaid(:final seat) ||
  NoHayMusSaid(:final seat) ||
  Discarded(:final seat) ||
  Declared(:final seat) ||
  PasoSaid(:final seat) ||
  EnvidoSaid(:final seat) ||
  QuieroSaid(:final seat) ||
  NoQuieroSaid(:final seat) ||
  OrdagoSaid(:final seat) => seat,
  _ => throw ArgumentError.value(event, 'event', 'Nobody says it'),
};

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
  });

  final TableStep step;
  final StepProgress state;

  /// How a lance went, once it is [StepProgress.done].
  final LanceOutcome? outcome;

  /// The bet waiting for an answer in the lance being played.
  final Envite? envite;

  /// Someone said "no hay mus".
  final bool cut;

  /// First hand: the mus goes round until someone cuts it (R-MUS-5).
  final bool corrido;

  final bool discarding;
}

/// What the table shows of a match from [you]r seat, worked out from the
/// engine's state and its log: the score, who is mano and postre, whose
/// turn it is, where the hand is, what each player just said and what is
/// on the table.
final class TableView {
  factory TableView.of(MatchState match, {required int you}) {
    final hand = match.hand;
    final score = match.scoreNow;
    final us = teamOf(you);
    return TableView._(
      you: you,
      us: score[us],
      them: score[1 - us],
      target: match.rules.target,
      mano: hand.mano,
      turn: hand.turn,
      steps: _steps(hand),
      said: _said(hand.log),
      stake: switch (hand.phase) {
        LanceTurn(:final envite?) => envite,
        _ => null,
      },
      cards: hand.hands[you],
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

  /// The bet on the table in the lance being played.
  final Envite? stake;

  final List<PlayingCard> cards;
  final HandValue value;

  bool partnerOf(int seat) => teamOf(seat) == teamOf(you) && seat != you;
}

List<StepView> _steps(HandState hand) {
  final phase = hand.phase;
  final log = hand.log;
  final inMus = phase is MusTurn || phase is DiscardTurn;
  final punto = log.any(
    (event) => event is LanceStarted && event.lance == Lance.punto,
  );
  StepView lance(TableStep step, Lance lance) {
    final outcome = hand.outcomes.where((o) => o.lance == lance).firstOrNull;
    if (outcome != null) {
      return StepView(step, StepProgress.done, outcome: outcome);
    }
    return switch (phase) {
      LanceTurn(lance: final playing, :final envite) when playing == lance =>
        StepView(step, StepProgress.current, envite: envite),
      _ => StepView(step, StepProgress.pending),
    };
  }

  return [
    StepView(
      TableStep.mus,
      inMus ? StepProgress.current : StepProgress.done,
      cut: log.any((event) => event is NoHayMusSaid),
      corrido: hand.musCorrido && inMus,
      discarding: phase is DiscardTurn,
    ),
    lance(TableStep.grande, Lance.grande),
    lance(TableStep.chica, Lance.chica),
    lance(TableStep.pares, Lance.pares),
    punto
        ? lance(TableStep.punto, Lance.punto)
        : lance(TableStep.juego, Lance.juego),
  ];
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
      (Discarded(), MusSaid() || NoHayMusSaid()) => true,
      (Reshuffled(), MusSaid() || NoHayMusSaid()) => true,
      (MusSaid(), Discarded()) => true,
      _ => false,
    })
      i,
];

Map<int, GameEvent> _said(List<GameEvent> log) {
  final starts = _stepStarts(log);
  for (var s = starts.length - 1; s >= 0; s--) {
    final end = s + 1 < starts.length ? starts[s + 1] : log.length;
    final said = <int, GameEvent>{
      for (final event in log.sublist(starts[s], end))
        if (_spoken(event)) _seatOf(event): event,
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

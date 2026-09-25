import '../game/cards.dart';
import '../game/event.dart';
import '../game/hand_state.dart';
import '../game/hand_value.dart';
import '../game/match.dart';
import '../game/move.dart';
import '../game/rules.dart';

/// What one seat can see of the match: its own cards and what is public.
/// Bots decide from this alone; they never get the other hands or the deck.
final class SeatView {
  SeatView.of(MatchState match, this.seat)
    : rules = match.rules,
      cards = match.hand.hands[seat],
      legal = match.legalMoves(seat),
      log = match.hand.log,
      score = match.scoreNow,
      mano = match.hand.mano,
      lance = switch (match.hand.phase) {
        LanceTurn(:final lance) => lance,
        _ => null,
      },
      envite = switch (match.hand.phase) {
        LanceTurn(:final envite) => envite,
        _ => null,
      };

  final int seat;
  final Rules rules;
  final List<PlayingCard> cards;
  final Set<MoveKind> legal;
  final List<GameEvent> log;
  final List<int> score;
  final int mano;

  /// The lance being played, if any.
  final Lance? lance;

  /// The bet waiting for an answer in it, if any.
  final Envite? envite;
}

/// A player the app controls.
abstract interface class Bot {
  /// One of the moves [view] allows.
  Move choose(SeatView view);
}

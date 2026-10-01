import '../game/cards.dart';
import '../game/event.dart';
import '../game/hand_state.dart';
import '../game/hand_value.dart';
import '../game/match.dart';
import '../game/move.dart';
import '../game/rules.dart';
import '../game/senas.dart';

/// What one seat can see of the match: its own cards and what is public.
/// Bots decide from this alone; they never get the other hands or the deck.
final class SeatView {
  SeatView.of(MatchState match, int seat)
    : this._(match, seat, legal: match.legalMoves(seat));

  SeatView._(MatchState match, this.seat, {required this.legal})
    : rules = match.rules,
      cards = match.hand.hands[seat],
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
      },
      partnerSenas = senasMade(match.hand)
          ? senasOf(match.hand, (seat + 2) % 4)
          : null,
      senaMoment = moment(match.hand);

  /// What [advisor] can see, asked what it would do in its partner's place:
  /// its own cards and what is public, with the partner's moves.
  SeatView.advising(MatchState match, int advisor)
    : this._(match, advisor, legal: match.legalMoves((advisor + 2) % 4));

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

  /// The señas the partner has made, once señas are made this hand.
  final List<Sena>? partnerSenas;

  /// How far the hand is, for the señas that wait.
  final SenaMoment senaMoment;
}

/// A player the app controls.
abstract interface class Bot {
  /// One of the moves [view] allows.
  Move choose(SeatView view);
}

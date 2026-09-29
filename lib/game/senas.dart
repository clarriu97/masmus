import 'event.dart';
import 'hand_state.dart';
import 'hand_value.dart';

/// The señas partners make to each other (R-SEN-1), in the order they are
/// made: la 31 before the pares (R-SEN-2).
enum Sena {
  treintaYUna,
  duples,
  dosReyes,
  mediasReyes,
  dosAses,
  mediasAses,
  medias,
  treinta,
  ciego,
}

/// Every seña [seat] has made to its partner so far with the cards it
/// holds now: true and complete (R-SEN-2), from the moment it has seen
/// them and never during mus corrido (R-SEN-3), medias once the grande
/// has closed and treinta once the punto is played (R-SEN-4). None when
/// the match is played without señas (R-SEN-5).
List<Sena> senasOf(HandState hand, int seat) =>
    senasMade(hand) ? senasFor(hand.valueOf(seat), moment(hand)) : const [];

/// Whether señas are made at this point of the hand: the match is played
/// with them and mus corrido, if any, has been cut (R-SEN-3, R-SEN-5).
bool senasMade(HandState hand) =>
    hand.rules.senas &&
    (!hand.musCorrido || hand.log.any((event) => event is NoHayMusSaid));

/// How far the hand is, for the señas that wait (R-SEN-4).
typedef SenaMoment = ({bool grandeClosed, bool punto});

SenaMoment moment(HandState hand) => (
  grandeClosed: hand.outcomes.any((outcome) => outcome.lance == Lance.grande),
  punto: hand.log.any(
    (event) => event is LanceStarted && event.lance == Lance.punto,
  ),
);

/// The señas a hand worth [value] makes by [at].
List<Sena> senasFor(HandValue value, SenaMoment at) {
  final kings = value.ranks.where((rank) => rank == 12).length;
  final aces = value.ranks.where((rank) => rank == 1).length;
  if (!value.hasPares && !value.hasJuego && value.points != 30) {
    return const [Sena.ciego];
  }
  return [
    if (value.points == 31) Sena.treintaYUna,
    if (value.pares == ParesKind.duples)
      Sena.duples
    else ...[
      if (kings == 2) Sena.dosReyes,
      if (kings == 3) Sena.mediasReyes,
      if (aces == 2) Sena.dosAses,
      if (aces == 3) Sena.mediasAses,
      if (value.pares == ParesKind.medias &&
          kings < 3 &&
          aces < 3 &&
          at.grandeClosed)
        Sena.medias,
    ],
    if (value.points == 30 && at.punto) Sena.treinta,
  ];
}

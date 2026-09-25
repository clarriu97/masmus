import 'cards.dart';

/// The smallest envite, and the smallest raise (R-ENV-1, R-ENV-3).
const minEnvido = 2;

enum MoveKind { mus, noHayMus, discard, paso, envido, quiero, noQuiero, ordago }

/// What a player can do when it is their turn.
sealed class Move {
  const Move();

  MoveKind get kind;
}

final class Mus extends Move {
  const Mus();

  @override
  MoveKind get kind => MoveKind.mus;
}

final class NoHayMus extends Move {
  const NoHayMus();

  @override
  MoveKind get kind => MoveKind.noHayMus;
}

/// Puts aside 1 to 4 of the player's cards to get new ones (R-MUS-3).
final class Discard extends Move {
  const Discard(this.cards);

  final List<PlayingCard> cards;

  @override
  MoveKind get kind => MoveKind.discard;
}

final class Paso extends Move {
  const Paso();

  @override
  MoveKind get kind => MoveKind.paso;
}

/// Puts [amount] more on the table: the first envite of a lance, or a raise
/// ("X más") when answering one.
final class Envido extends Move {
  const Envido(this.amount) : assert(amount >= minEnvido);

  final int amount;

  @override
  MoveKind get kind => MoveKind.envido;
}

final class Quiero extends Move {
  const Quiero();

  @override
  MoveKind get kind => MoveKind.quiero;
}

final class NoQuiero extends Move {
  const NoQuiero();

  @override
  MoveKind get kind => MoveKind.noQuiero;
}

final class Ordago extends Move {
  const Ordago();

  @override
  MoveKind get kind => MoveKind.ordago;
}

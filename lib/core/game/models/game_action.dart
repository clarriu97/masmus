import '../logic/mus_game.dart';

enum ActionType { paso, envido, quiero, noQuiero, ordago, mus, noHayMus }

class GameAction {
  const GameAction({
    required this.playerIndex,
    required this.phase,
    required this.type,
    this.amount = 0,
  });

  final int playerIndex;
  final GamePhase phase;
  final ActionType type;
  final int amount;

  @override
  String toString() {
    return 'GameAction(player: $playerIndex, phase: $phase, type: $type, amount: $amount)';
  }
}

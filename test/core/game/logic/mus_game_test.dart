import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/core/game/logic/mus_game.dart';
import 'package:masmus/core/game/models/player.dart';

void main() {
  late MusGame game;
  late List<Player> players;

  setUp(() {
    players = [
      Player(id: '1', name: 'P1'),
      Player(id: '2', name: 'P2'),
      Player(id: '3', name: 'P3'),
      Player(id: '4', name: 'P4'),
    ];
    game = MusGame(players: players);
  });

  test('Initialization deals cards and starts at Mus phase', () {
    expect(game.currentPhase, equals(GamePhase.mus));
    expect(game.manoIndex, equals(0));
    expect(game.currentTurn, equals(0));

    for (final p in players) {
      expect(p.hand.length, equals(4));
    }
  });

  test('Everyone says Mus -> Transitions to Discard', () {
    // P0 says Mus
    expect(game.playerSaysMus(0), isTrue);
    expect(game.currentTurn, equals(1));
    expect(game.currentPhase, equals(GamePhase.mus));

    // P1 says Mus
    expect(game.playerSaysMus(1), isTrue);
    expect(game.currentTurn, equals(2));

    // P2 says Mus
    expect(game.playerSaysMus(2), isTrue);
    expect(game.currentTurn, equals(3));

    // P3 (Postre) says Mus
    expect(game.playerSaysMus(3), isTrue);

    // Should transition to Discard
    expect(game.currentPhase, equals(GamePhase.discard));
    // Turn should be back to mano (0)
    expect(game.currentTurn, equals(0));
  });

  test('Cut Mus -> Transitions to Grande', () {
    // P0 says Mus
    game.playerSaysMus(0);

    // P1 cuts Mus
    expect(game.playerCutsMus(1), isTrue);

    // Should transition to Grande immediately
    expect(game.currentPhase, equals(GamePhase.grande));
    // Turn should be back to mano (0) for betting
    expect(game.currentTurn, equals(0));
  });

  test('Discard flow works', () {
    // fast forward to discard
    game.playerSaysMus(0);
    game.playerSaysMus(1);
    game.playerSaysMus(2);
    game.playerSaysMus(3);

    expect(game.currentPhase, equals(GamePhase.discard));

    // P0 discards 1 card
    final cardToDiscard = players[0].hand.first;
    game.playerDiscards(0, [cardToDiscard]);

    // P0 have 4 cards again
    expect(players[0].hand.length, equals(4));
    expect(players[0].hand.contains(cardToDiscard), isFalse);

    // Turn advanced to 1
    expect(game.currentTurn, equals(1));
  });

  test('Discard cycle finishes -> Back to Mus', () {
    // All Mus
    for (int i = 0; i < 4; i++) {
      game.playerSaysMus(i);
    }

    // Everyone discards
    for (int i = 0; i < 4; i++) {
      expect(game.currentTurn, equals(i));
      game.playerDiscards(i, []); // Discard nothing, just pass
    }

    // Should be back to Mus check
    expect(game.currentPhase, equals(GamePhase.mus));
    expect(game.currentTurn, equals(0));
    // Wants mus should be reset
    expect(game.wantsMus.every((e) => e == false), isTrue);
  });
}

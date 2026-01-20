import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/core/game/logic/mus_game.dart';
import 'package:masmus/core/game/models/card.dart';
import 'package:masmus/core/game/models/player.dart';

void main() {
  group('MusGame Integration Tests', () {
    late MusGame game;
    late List<Player> players;

    setUp(() {
      players = List.generate(4, (i) => Player(id: '$i', name: 'P$i'));
      game = MusGame(players: players);
      game.manoIndex = 3;
      game.restartHand(); // This will increment manoIndex to 0 and call _startNewHand
    });

    test('Initial State is Mus Phase', () {
      expect(game.currentPhase, GamePhase.musDeclaration);
      expect(game.currentTurn, game.manoIndex);
    });

    test('Everyone says Mus -> Discard Phase', () {
      // P0 (Mano), P1, P2, P3 say mus
      expect(game.playerSaysMus(0), true);
      expect(game.playerSaysMus(1), true);
      expect(game.playerSaysMus(2), true);
      // Last one triggers phase change
      expect(game.playerSaysMus(3), true);

      expect(game.currentPhase, GamePhase.discard);
      expect(game.currentTurn, game.manoIndex); // Back to mano for discard
    });

    test('Cut Mus -> Starts Grande', () {
      expect(game.playerCutsMus(0), true);
      expect(game.currentPhase, GamePhase.grande);
    });

    test('Betting Flow - Envido / Quiero', () {
      game.playerCutsMus(0); // Start Grande (Mano 0)

      // P0 Passes
      game.playerAction(0, 'PASO');
      // P1 Bets Envido (2)
      game.playerAction(1, 'ENVIDO');

      expect(game.currentBet, 2);
      expect(game.currentBetType, BetType.envido);

      // Turn should jump to rival team (Team 0), closest to mano (P0) -> P0
      expect(game.currentTurn, 0);

      // P0 Accepts
      game.playerAction(0, 'QUIERO');

      // Phase ends -> Chica
      expect(game.currentPhase, GamePhase.chica);
      // Check pending bet
      expect(game.pendingBets[GamePhase.grande], 2);
    });

    test('Betting Flow - Envido / No Quiero', () {
      game.playerCutsMus(0);
      game.playerAction(0, 'ENVIDO'); // P0 bets 2

      // P1 Rejects -> Turn jumps to P3
      game.playerAction(1, 'NO QUIERO');
      expect(game.currentTurn, 3);

      // P3 Rejects -> Rejected
      game.playerAction(3, 'NO QUIERO');

      // P0 Team wins 1 point immediately
      expect(game.teamScores[0], 1);

      // Next phase
      expect(game.currentPhase, GamePhase.chica);
    });

    test('Scoring - Manual verification', () {
      // Setup specific hands
      // P0: 4 Kings (Duples, Juego 40)
      // P1: 4 Aces (Par, Juego 34)
      // P2: 4 Kings
      // P3: 4 Aces
      final kings = [
        const MusCard(suit: Suit.oros, faceValue: 12),
        const MusCard(suit: Suit.copas, faceValue: 12),
        const MusCard(suit: Suit.espadas, faceValue: 12),
        const MusCard(suit: Suit.bastos, faceValue: 12),
      ];
      final aces = [
        const MusCard(suit: Suit.oros, faceValue: 10),
        const MusCard(suit: Suit.copas, faceValue: 10),
        const MusCard(suit: Suit.espadas, faceValue: 10),
        const MusCard(suit: Suit.bastos, faceValue: 10),
      ];

      game = MusGame(players: players);
      game.manoIndex = 3;
      game.restartHand(); // mano 0

      // Now overwrite hands
      players[0].clearHand();
      players[0].receiveCards(kings);
      players[1].clearHand();
      players[1].receiveCards(aces);
      players[2].clearHand();
      players[2].receiveCards(kings);
      players[3].clearHand();
      players[3].receiveCards(aces);

      game.evaluateHands();

      // Force Cut Mus
      game.playerCutsMus(0);

      // Pass everyone until scoring
      // Grande: P0 (Kings) vs P1 (Aces) -> P0 wins. All pass -> 1 pt for P0.
      game.playerAction(0, 'PASO');
      game.playerAction(1, 'PASO');
      game.playerAction(2, 'PASO');
      game.playerAction(3, 'PASO');

      // Chica: P1 (Aces) vs P0 (Kings) -> P1 wins. All pass -> 1 pt for P1.
      game.playerAction(0, 'PASO');
      game.playerAction(1, 'PASO');
      game.playerAction(2, 'PASO');
      game.playerAction(3, 'PASO');

      // Chica ends -> starts Pares Declaration
      for (int i = 0; i < 4; i++) {
        game.performDeclarationStep();
      }
      expect(game.currentPhase, GamePhase.pares);

      // Pares: P0 (Duples K), P1 (Duples A). P0 Wins.
      game.playerAction(0, 'PASO');
      game.playerAction(1, 'PASO');
      game.playerAction(2, 'PASO');
      game.playerAction(3, 'PASO');

      // Pares ends -> starts Juego Declaration
      for (int i = 0; i < 4; i++) {
        game.performDeclarationStep();
      }
      expect(game.currentPhase, GamePhase.juego);

      // Juego: P0 (40), P1 (34). P0 Wins.
      game.playerAction(0, 'PASO');
      game.playerAction(1, 'PASO');
      game.playerAction(2, 'PASO');
      game.playerAction(3, 'PASO');

      // Scoring happened automatically after last pass
      expect(game.currentPhase, GamePhase.scoring);

      expect(game.teamScores[0], 11);
      expect(game.teamScores[1], 1);
    });

    test('Pares - Only one team has it -> Skip betting', () {
      // P0 has pares, others don't.
      players[0].clearHand();
      players[0].receiveCards([
        const MusCard(suit: Suit.oros, faceValue: 12),
        const MusCard(suit: Suit.copas, faceValue: 12),
        const MusCard(suit: Suit.espadas, faceValue: 1),
        const MusCard(suit: Suit.bastos, faceValue: 2),
      ]);
      // Others have no combinations
      for (int i = 1; i < 4; i++) {
        players[i].clearHand();
        players[i].receiveCards([
          const MusCard(suit: Suit.oros, faceValue: 1),
          const MusCard(suit: Suit.copas, faceValue: 2),
          const MusCard(suit: Suit.espadas, faceValue: 3),
          const MusCard(suit: Suit.bastos, faceValue: 4),
        ]);
      }
      game.evaluateHands();

      // Move to Pares Declaration via Chica
      game.currentPhase = GamePhase.chica;
      for (int i = 0; i < 4; i++) {
        game.playerAction(i, 'PASO');
      }

      // Now in Pares Declaration
      expect(game.currentPhase, GamePhase.paresDeclaration);
      for (int i = 0; i < 4; i++) {
        game.performDeclarationStep();
      }

      // Should skip Pares betting (since only one team has it) and go to Juego Declaration
      // Since no one has Juego, it will further skip to Punto or Scoring depending on currentPhase logic
      // Actually, after paresDeclaration if skipped it goes to _checkJuegoPhase
      expect(game.currentPhase, GamePhase.punto);
    });

    test('Juego - Only one team has it -> Skip betting', () {
      // P0 has Juego (31), others have Punto.
      players[0].clearHand();
      players[0].receiveCards([
        const MusCard(suit: Suit.oros, faceValue: 12),
        const MusCard(suit: Suit.copas, faceValue: 12),
        const MusCard(suit: Suit.espadas, faceValue: 12),
        const MusCard(suit: Suit.bastos, faceValue: 1),
      ]);
      // Others have no juego
      for (int i = 1; i < 4; i++) {
        players[i].clearHand();
        players[i].receiveCards([
          const MusCard(suit: Suit.oros, faceValue: 1),
          const MusCard(suit: Suit.copas, faceValue: 2),
          const MusCard(suit: Suit.espadas, faceValue: 3),
          const MusCard(suit: Suit.bastos, faceValue: 4),
        ]);
      }
      game.evaluateHands();

      // Start from Chica to ensure clean transition to Pares then Juego
      game.currentPhase = GamePhase.chica;
      game.currentTurn = 0; // Mano
      for (int i = 0; i < 4; i++) {
        game.playerAction(i, 'PASO');
      }

      // Now it should be in Pares Declaration
      expect(game.currentPhase, GamePhase.paresDeclaration);
      for (int i = 0; i < 4; i++) {
        game.performDeclarationStep();
      }

      // Now it should have skipped Pares (no one has it) and be in Juego Declaration
      expect(game.currentPhase, GamePhase.juegoDeclaration);
      for (int i = 0; i < 4; i++) {
        game.performDeclarationStep();
      }

      // Should skip Juego betting and go to scoring
      expect(game.currentPhase, GamePhase.scoring);
    });
  });
}

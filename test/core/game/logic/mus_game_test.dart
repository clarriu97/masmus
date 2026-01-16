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
    });

    test('Initial State is Mus Phase', () {
      expect(game.currentPhase, GamePhase.mus);
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
      game.playerCutsMus(0); // Start Grande

      // P0 Passes
      game.playerAction(0, 'PASO');
      // P1 Bets Envido (2)
      game.playerAction(1, 'ENVIDO');

      expect(game.currentBet, 2);
      expect(game.currentBetType, BetType.envido);

      // Turn should move to P2 (Partner of P0 decides? Or P0?)
      // Betting usually goes to the team. P2 is team 0.
      expect(game.currentTurn, 2);

      // P2 Accepts
      game.playerAction(2, 'QUIERO');

      // Phase ends -> Chica
      expect(game.currentPhase, GamePhase.chica);
      // Check pending bet
      expect(game.pendingBets[GamePhase.grande], 2);
    });

    test('Betting Flow - Envido / No Quiero', () {
      game.playerCutsMus(0);
      game.playerAction(0, 'ENVIDO'); // P0 bets 2

      // P1 Rejects
      game.playerAction(1, 'NO QUIERO');

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

      game = MusGame(players: players); // Init first (which deals random)

      // Now overwrite hands
      players[0].clearHand();
      players[0].receiveCards(kings);
      players[1].clearHand();
      players[1].receiveCards(aces);
      players[2].clearHand();
      players[2].receiveCards(kings);
      players[3].clearHand();
      players[3].receiveCards(aces);

      game.evaluateHands(); // Re-evaluate logic with new hands

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
      // All pass -> P0 wins Duples (3) + P2 Duples (3) = 6 pts? (+1 en paso?).
      // Rule: If passed, points are pending check. Winner gets combination points (6). No 'en paso' point for Pares/Juego.
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
      // Winner (P0) gets 2 pts (40). P2 gets 2 pts. Total 4.
      // Pass
      game.playerAction(0, 'PASO');
      game.playerAction(1, 'PASO');
      game.playerAction(2, 'PASO');
      game.playerAction(3, 'PASO');

      // Scoring happened automatically after last pass
      expect(game.currentPhase, GamePhase.scoring);

      // Check Scores
      // Team 0: Grande (1) + Pares (3+3=6) + Juego (2+2=4) = 11 pts.
      // Team 1: Chica (1) + Pares (0) + Juego (0) = 1 point.

      expect(game.teamScores[0], 11);
      expect(game.teamScores[1], 1);
    });
  });
}

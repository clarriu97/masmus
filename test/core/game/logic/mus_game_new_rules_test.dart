import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/core/game/logic/mus_game.dart';
import 'package:masmus/core/game/models/card.dart';
import 'package:masmus/core/game/models/player.dart';

void main() {
  group('MusGame New Rules Tests', () {
    late MusGame game;
    late List<Player> players;

    setUp(() {
      players = List.generate(4, (i) => Player(id: '$i', name: 'P$i'));
      game = MusGame(players: players, initialMano: 0);
      // initialMano 0 means P0 is mano.
    });

    test('Explicit Mus Declaration Phase', () {
      expect(game.currentPhase, GamePhase.musDeclaration);
      expect(game.manoIndex, 0);
      expect(game.currentTurn, 0);

      // P0 says MUS
      game.playerSaysMus(0);
      expect(game.currentTurn, 1);
      expect(game.declarations[0], 'MUS');

      // P1 says MUS
      game.playerSaysMus(1);
      expect(game.currentTurn, 2);

      // P2 says MUS
      game.playerSaysMus(2);
      expect(game.currentTurn, 3);

      // P3 says MUS -> Discard Phase
      game.playerSaysMus(3);
      expect(game.currentPhase, GamePhase.discard);
      expect(game.currentTurn, game.manoIndex);
    });

    test('Cutting Mus explicitly', () {
      game.playerSaysMus(0);
      game.playerSaysMus(1);
      // P2 cuts Mus
      game.playerCutsMus(2);

      expect(game.currentPhase, GamePhase.grande);
      expect(game.declarations[2], 'NO HAY MUS');
    });

    test('Unicidad de Acción and Salto de Turno', () {
      game.playerCutsMus(0); // Grande
      expect(game.currentPhase, GamePhase.grande);
      expect(game.currentTurn, 0);

      // P0 bets -> Turn should jump to Team 1 (P1 or P3). Closest to mano (0) is P1.
      game.playerAction(0, 'ENVIDO');
      expect(game.currentTurn, 1);
      expect(game.speakerIndex, 0);

      // P1 re-bets -> Turn should jump to Team 0 (P0 or P2). Closest to mano (0) is P0.
      game.playerAction(1, 'ENVIDO', amount: 2);
      expect(game.currentTurn, 0);
      expect(game.speakerIndex, 1);
    });

    test('No Quiero Resolution - Immediate Point and Closure', () {
      game.playerCutsMus(0); // Grande
      game.playerAction(0, 'ENVIDO'); // P0 bets 2

      // P1 says No Quiero -> Turn to P3
      game.playerAction(1, 'NO QUIERO');
      expect(game.currentTurn, 3);

      final initialScore0 = game.teamScores[0];

      // P3 says No Quiero -> Rejected
      game.playerAction(3, 'NO QUIERO');

      // P0 team should get 1 point immediately
      expect(game.teamScores[0], initialScore0! + 1);

      // Phase should change to Chica
      expect(game.currentPhase, GamePhase.chica);

      // Phase should be marked as rejected
      expect(game.rejectedPhases.contains(GamePhase.grande), isTrue);
    });

    test('Pares Conditional Betting - Both teams must have it', () {
      // P0 has pares AND Juego
      players[0].clearHand();
      players[0].receiveCards([
        const MusCard(suit: Suit.oros, faceValue: 12),
        const MusCard(suit: Suit.copas, faceValue: 12),
        const MusCard(suit: Suit.espadas, faceValue: 12),
        const MusCard(suit: Suit.bastos, faceValue: 1),
      ]);
      // Team 1 has NO pares
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

      // Skip to Pares Declaration
      game.currentPhase = GamePhase.paresDeclaration;
      game.currentTurn = 0;

      // P0 says SÍ, others say NO
      game.performDeclarationStep(); // P0 SÍ
      game.performDeclarationStep(); // P1 NO
      game.performDeclarationStep(); // P2 NO (Teammate)
      game.performDeclarationStep(); // P3 NO

      // Should skip Pares betting and go to Juego Declaration (since only one team has it)
      expect(game.currentPhase, GamePhase.juegoDeclaration);
    });

    test('Juego Conditional Betting - Both teams must have it', () {
      // P0 has Juego (31), others don't.
      players[0].clearHand();
      players[0].receiveCards([
        const MusCard(suit: Suit.oros, faceValue: 12),
        const MusCard(suit: Suit.copas, faceValue: 12),
        const MusCard(suit: Suit.espadas, faceValue: 12),
        const MusCard(suit: Suit.bastos, faceValue: 1),
      ]);
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

      game.currentPhase = GamePhase.juegoDeclaration;
      game.currentTurn = 0;

      game.performDeclarationStep(); // P0 SÍ
      game.performDeclarationStep(); // P1 NO
      game.performDeclarationStep(); // P2 NO
      game.performDeclarationStep(); // P3 NO

      // Should skip Juego betting and go to scoring (no one else has Juego)
      expect(game.currentPhase, GamePhase.scoring);
    });

    test(
      'Deferred response to partner (PASO or NO QUIERO when bet exists)',
      () {
        game.playerCutsMus(0); // Grande
        game.playerAction(0, 'ENVIDO');

        expect(game.currentTurn, 1);

        // P1 says NO QUIERO -> turn jumps to P3 (partner)
        game.playerAction(1, 'NO QUIERO');
        expect(game.currentTurn, 3);

        // P3 says Quiero
        game.playerAction(3, 'QUIERO');
        expect(game.currentPhase, GamePhase.chica);
      },
    );

    test('No Quiero by BOTH partners -> Reject', () {
      game.playerCutsMus(0);
      game.playerAction(0, 'ENVIDO');

      game.playerAction(1, 'NO QUIERO');
      expect(game.currentTurn, 3);

      final initialScore0 = game.teamScores[0];
      game.playerAction(3, 'NO QUIERO');

      expect(game.teamScores[0], initialScore0! + 1);
      expect(game.currentPhase, GamePhase.chica);
    });
  });
}

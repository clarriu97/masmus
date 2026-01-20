import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/core/game/logic/ai_logic.dart';
import 'package:masmus/core/game/logic/hand_evaluator.dart';
import 'package:masmus/core/game/logic/mus_game.dart';
import 'package:masmus/core/game/models/ai_profile.dart';
import 'package:masmus/core/game/models/card.dart';
import 'package:masmus/core/game/models/game_config.dart';
import 'package:masmus/core/game/models/player.dart';

void main() {
  group('AiLogic Tests', () {
    late Player aiPlayer;
    late AiProfile aggressiveProfile;
    late AiProfile conservativeProfile;

    setUp(() {
      aggressiveProfile = const AiProfile(
        name: 'Aggro',
        boldness: 0.9,
        bluffing: 0.8,
      );
      conservativeProfile = const AiProfile(
        name: 'Safe',
        boldness: 0.1,
        bluffing: 0.1,
      );
      aiPlayer = Player(id: 'ai', name: 'AI', aiProfile: aggressiveProfile);
    });

    test('shouldAcceptMus - Cuts mus with 31', () {
      final hand31 = [
        const MusCard(suit: Suit.oros, faceValue: 1),
        const MusCard(suit: Suit.copas, faceValue: 12),
        const MusCard(suit: Suit.espadas, faceValue: 12),
        const MusCard(suit: Suit.bastos, faceValue: 12),
      ];

      aiPlayer.receiveCards(hand31);
      final ev = HandEvaluator.evaluate(hand31, const GameConfig());

      final cut = AiLogic.shouldAcceptMus(aiPlayer, ev);
      expect(cut, false); // false means Cut Mus
    });

    test('shouldAcceptMus - Cuts as Mano with Kings', () {
      final hand = [
        const MusCard(suit: Suit.oros, faceValue: 12),
        const MusCard(suit: Suit.copas, faceValue: 12),
        const MusCard(suit: Suit.espadas, faceValue: 4),
        const MusCard(suit: Suit.bastos, faceValue: 5),
      ];
      aiPlayer.receiveCards(hand);
      final ev = HandEvaluator.evaluate(
        hand,
        const GameConfig(eightKings: true),
      );

      final cut = AiLogic.shouldAcceptMus(aiPlayer, ev, isMano: true);
      expect(cut, false); // Mano with Kings cuts
    });

    test('getCardsToDiscard - Discards 4th card with 3 Kings', () {
      final hand = [
        const MusCard(suit: Suit.oros, faceValue: 12),
        const MusCard(suit: Suit.copas, faceValue: 12),
        const MusCard(suit: Suit.espadas, faceValue: 12),
        const MusCard(suit: Suit.bastos, faceValue: 5),
      ];
      aiPlayer.receiveCards(hand);
      final ev = HandEvaluator.evaluate(
        hand,
        const GameConfig(eightKings: true),
      );

      final toDiscard = AiLogic.getCardsToDiscard(aiPlayer, ev);
      expect(toDiscard.length, 1);
      expect(toDiscard.first.faceValue, 5);
    });

    test('evaluateBet - El Farolero bluffs in Grande as Mano', () {
      final hand = [
        const MusCard(suit: Suit.oros, faceValue: 4),
        const MusCard(suit: Suit.copas, faceValue: 5),
        const MusCard(suit: Suit.espadas, faceValue: 6),
        const MusCard(suit: Suit.bastos, faceValue: 7),
      ];
      final farolero = Player(
        id: 'f',
        name: 'Faro',
        aiProfile: const AiProfile(
          name: 'El Farolero',
          boldness: 0.9,
          bluffing: 0.9,
        ),
      );
      farolero.receiveCards(hand);
      final ev = HandEvaluator.evaluate(hand, const GameConfig());

      // Try multiple times since it's 80%
      int envidos = 0;
      for (int i = 0; i < 20; i++) {
        final decision = AiLogic.makeBettingDecision(
          player: farolero,
          ev: ev,
          phase: GamePhase.grande,
          currentBet: 0,
          isPartnerWinning: false,
          isMano: true,
          isPostre: false,
          history: [],
        );
        if (decision.type == BettingType.envido) {
          envidos++;
        }
      }
      expect(envidos, greaterThan(10));
    });

    test('getCardsToDiscard - Keeps Kings and Aces', () {
      final hand = [
        const MusCard(suit: Suit.oros, faceValue: 1),
        const MusCard(suit: Suit.copas, faceValue: 12),
        const MusCard(suit: Suit.espadas, faceValue: 4),
        const MusCard(suit: Suit.bastos, faceValue: 5),
      ];
      aiPlayer.receiveCards(hand);
      final ev = HandEvaluator.evaluate(hand, const GameConfig());

      final toDiscard = AiLogic.getCardsToDiscard(aiPlayer, ev);
      expect(toDiscard.length, 2);
      expect(toDiscard.map((c) => c.faceValue), containsAll([4, 5]));
    });

    test('evaluateBet - Aggressive player Envido on good hand', () {
      final hand = [
        const MusCard(suit: Suit.oros, faceValue: 1),
        const MusCard(suit: Suit.copas, faceValue: 12),
        const MusCard(suit: Suit.espadas, faceValue: 12),
        const MusCard(suit: Suit.bastos, faceValue: 12),
      ];
      aiPlayer = Player(id: 'ai', name: 'AI', aiProfile: aggressiveProfile);
      aiPlayer.receiveCards(hand);
      final ev = HandEvaluator.evaluate(hand, const GameConfig());

      final decision = AiLogic.makeBettingDecision(
        player: aiPlayer,
        ev: ev,
        phase: GamePhase.juego,
        currentBet: 0,
        isPartnerWinning: false,
        isMano: true,
        isPostre: false,
        history: [],
      );

      expect(decision.type, anyOf(BettingType.envido, BettingType.ordago));
    });

    test('evaluateBet - Conservative player folds on bad hand vs bet', () {
      final hand = [
        const MusCard(suit: Suit.oros, faceValue: 4),
        const MusCard(suit: Suit.copas, faceValue: 5),
        const MusCard(suit: Suit.espadas, faceValue: 6),
        const MusCard(suit: Suit.bastos, faceValue: 7),
      ];
      aiPlayer = Player(id: 'ai', name: 'AI', aiProfile: conservativeProfile);
      aiPlayer.receiveCards(hand);
      final ev = HandEvaluator.evaluate(hand, const GameConfig());

      final decision = AiLogic.makeBettingDecision(
        player: aiPlayer,
        ev: ev,
        phase: GamePhase.grande,
        currentBet: 5,
        isPartnerWinning: false,
        isMano: false,
        isPostre: false,
        history: [],
      );

      expect(decision.type, BettingType.noQuiero);
    });
  });
}

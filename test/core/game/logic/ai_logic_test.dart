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
      expect(cut, true);
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
      );

      expect(decision.type, BettingType.noQuiero);
    });
  });
}

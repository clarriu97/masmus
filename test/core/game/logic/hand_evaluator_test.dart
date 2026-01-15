import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/core/game/logic/hand_evaluator.dart';
import 'package:masmus/core/game/models/card.dart';
import 'package:masmus/core/game/models/game_config.dart';

void main() {
  const config = GameConfig(); // Default: 4 kings

  // Helpers
  MusCard c(int value, [Suit suit = Suit.oros]) =>
      MusCard(faceValue: value, suit: suit);

  group('HandEvaluator - Grande', () {
    test('Should prioritize higher ranks', () {
      final handA = [c(12), c(12), c(7), c(6)]; // REY, REY, 7, 6
      final handB = [c(12), c(12), c(7), c(5)]; // REY, REY, 7, 5

      final ranksA = HandEvaluator.evaluate(handA, config).sortedRanks;
      final ranksB = HandEvaluator.evaluate(handB, config).sortedRanks;

      expect(HandEvaluator.compareGrande(ranksA, ranksB), greaterThan(0));
    });

    test('Should handle equalities', () {
      final handA = [c(10), c(5), c(4), c(1)];
      final handB = [c(10), c(5), c(4), c(1)];

      final ranksA = HandEvaluator.evaluate(handA, config).sortedRanks;
      final ranksB = HandEvaluator.evaluate(handB, config).sortedRanks;

      expect(HandEvaluator.compareGrande(ranksA, ranksB), equals(0));
    });
  });

  group('HandEvaluator - Chica', () {
    test('Should prioritize lower ranks (inverse of Grande)', () {
      final handA = [c(1), c(1), c(4), c(5)]; // AS, AS, 4, 5
      final handB = [c(1), c(1), c(4), c(6)]; // AS, AS, 4, 6

      // A (5) es menor que B (6) en la carta más alta decisiva -> A Gana chica

      final ranksA = HandEvaluator.evaluate(handA, config).sortedRanks;
      final ranksB = HandEvaluator.evaluate(handB, config).sortedRanks;

      expect(HandEvaluator.compareChica(ranksA, ranksB), greaterThan(0));
    });
  });

  group('HandEvaluator - Pares', () {
    test('Detects Duples', () {
      final hand = [c(12), c(12), c(5), c(5)];
      final result = HandEvaluator.evaluate(hand, config);
      expect(result.paresType, equals(ParesType.duples));
    });

    test('Detects Medias', () {
      final hand = [c(12), c(12), c(12), c(5)];
      final result = HandEvaluator.evaluate(hand, config);
      expect(result.paresType, equals(ParesType.medias));
    });

    test('Detects Par', () {
      final hand = [c(12), c(12), c(6), c(5)];
      final result = HandEvaluator.evaluate(hand, config);
      expect(result.paresType, equals(ParesType.par));
    });

    test('Detects None', () {
      final hand = [c(12), c(11), c(6), c(5)];
      final result = HandEvaluator.evaluate(hand, config);
      expect(result.paresType, equals(ParesType.none));
    });

    test('Compare Duples: Higher pair wins', () {
      // K K 5 5 vs Q Q J J
      final handA = [c(12), c(12), c(5), c(5)];
      final handB = [c(11), c(11), c(10), c(10)];

      final resA = HandEvaluator.evaluate(handA, config);
      final resB = HandEvaluator.evaluate(handB, config);

      expect(
        HandEvaluator.compareParesLogic(
          resA.sortedRanks,
          resB.sortedRanks,
          ParesType.duples,
        ),
        greaterThan(0),
      );
    });
  });

  group('HandEvaluator - Juego', () {
    test('Calculates sum correctly', () {
      // 10 (Sota) + 11 (Caballo) + 12 (Rey) + 1 (As) = 10+10+10+1 = 31
      final hand = [c(10), c(11), c(12), c(1)];
      final result = HandEvaluator.evaluate(hand, config);
      expect(result.pointSum, equals(31));
      expect(result.hasJuego, isTrue);
    });

    test('Calculates Point (no juego)', () {
      // 7 + 6 + 5 + 4 = 22
      final hand = [c(7), c(6), c(5), c(4)];
      final result = HandEvaluator.evaluate(hand, config);
      expect(result.pointSum, equals(22));
      expect(result.hasJuego, isFalse);
    });

    test('31 beats 32', () {
      final hand31 = [c(10), c(10), c(10), c(1)]; // 31
      final hand32 = [c(10), c(10), c(10), c(2)]; // 32

      final res31 = HandEvaluator.evaluate(hand31, config);
      final res32 = HandEvaluator.evaluate(hand32, config);

      expect(
        HandEvaluator.compareJuego(res31.pointSum, res32.pointSum, config),
        greaterThan(0),
      );
    });

    test('32 beats 40', () {
      final hand32 = [c(10), c(10), c(10), c(2)]; // 32
      final hand40 = [c(10), c(10), c(10), c(10)]; // 40

      final res32 = HandEvaluator.evaluate(hand32, config);
      final res40 = HandEvaluator.evaluate(hand40, config);

      expect(
        HandEvaluator.compareJuego(res32.pointSum, res40.pointSum, config),
        greaterThan(0),
      );
    });

    test('40 beats 37', () {
      final hand40 = [c(10), c(10), c(10), c(10)]; // 40
      final hand37 = [c(10), c(10), c(10), c(7)]; // 37

      final res40 = HandEvaluator.evaluate(hand40, config);
      final res37 = HandEvaluator.evaluate(hand37, config);

      expect(
        HandEvaluator.compareJuego(res40.pointSum, res37.pointSum, config),
        greaterThan(0),
      );
    });
  });

  group('HandEvaluator - 8 Kings', () {
    test('3 counts as King (12) and 2 counts as Ace (1)', () {
      const config8 = GameConfig(eightKings: true);

      // 3 (Rey) + 3 (Rey) + 2 (As) + 7 = 10 + 10 + 1 + 7 = 28. (No juego)
      // Rank comparison: 3(12) vs K(12).

      final hand = [c(3), c(3), c(2), c(7)];
      final result = HandEvaluator.evaluate(hand, config8);

      expect(
        result.sortedRanks,
        containsAllInOrder([12, 12, 7, 1]),
      ); // 3->12, 3->12, 7->7, 2->1
      expect(result.paresType, equals(ParesType.par)); // Dos reyes
    });
  });
}

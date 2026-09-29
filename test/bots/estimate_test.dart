import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/bots/bot.dart';
import 'package:masmus/bots/estimate.dart';
import 'package:masmus/game/deck.dart';
import 'package:masmus/game/game_random.dart';
import 'package:masmus/game/hand_state.dart';
import 'package:masmus/game/hand_value.dart';
import 'package:masmus/game/match.dart';
import 'package:masmus/game/move.dart';
import 'package:masmus/game/rules.dart';
import 'package:masmus/game/table.dart';

import '../game/scenario.dart';

Knowledge _knowledge(
  Map<int, String> hands, {
  List<(int, Move)> moves = const [],
  int mano = 0,
}) {
  var match = MatchState(
    rules: const Rules(),
    score: const [0, 0],
    handNumber: 1,
    hand: dealt(hands, mano: mano),
  );
  for (final (seat, move) in moves) {
    match = match.play(seat, move);
  }
  return Knowledge.of(SeatView.of(match, 0));
}

double _grande(String hand) => _knowledge({
  0: hand,
  1: '4 5 6 7',
  2: '4 5 6 7',
  3: '4 5 6 7',
}).winChance(Lance.grande, Random(0), samples: 400);

void main() {
  test('deals the other hands from the cards this seat has not seen', () {
    final knowledge = _knowledge({
      0: 'R R 5 4',
      1: '1 4 5 6',
      2: '6 7 S C',
      3: 'C C 7 6',
    });
    final random = Random(0);
    for (var i = 0; i < 200; i++) {
      final others = knowledge.sampleOthers(random);
      final dealt = [for (final hand in others.values) ...hand];
      expect(others.keys, unorderedEquals([1, 2, 3]));
      expect(dealt.toSet(), hasLength(12));
      expect(dealt, everyElement(isNot(isIn(knowledge.cards))));
    }
  });

  test('deals hands that agree with what each seat declared', () {
    final knowledge = _knowledge(
      {0: 'R R 5 4', 1: '1 4 5 6', 2: '6 7 S C', 3: 'C C 7 6'},
      moves: [
        (0, const NoHayMus()),
        for (final seat in [0, 1, 2, 3, 0, 1, 2, 3]) (seat, const Paso()),
      ],
    );
    expect(knowledge.declared, {
      (0, Lance.pares): true,
      (1, Lance.pares): false,
      (2, Lance.pares): false,
      (3, Lance.pares): true,
    });
    final random = Random(0);
    for (var i = 0; i < 200; i++) {
      final others = knowledge.sampleOthers(random);
      expect(HandValue(others[1]!, const Rules()).hasPares, isFalse);
      expect(HandValue(others[2]!, const Rules()).hasPares, isFalse);
      expect(HandValue(others[3]!, const Rules()).hasPares, isTrue);
    }
  });

  test('four kings always win the grande for the mano', () {
    expect(_grande('R R R R'), 1);
  });

  test('better hands win the grande more often', () {
    expect(_grande('R C 7 5'), greaterThan(_grande('4 5 6 7') + 0.1));
  });

  test(
    'the advantage en paso is large with four kings and negative with nothing',
    () {
      double advantage(String hand) => _knowledge({
        0: hand,
        1: '1 1 6 S',
        2: '1 1 6 S',
        3: 'C C 6 S',
      }).advantage(Random(0), samples: 400);
      expect(advantage('R R R R'), greaterThan(2));
      expect(advantage('4 5 6 7'), lessThan(0));
    },
  );

  group('whoever cut the mus', () {
    const hands = {0: 'R C 6 5', 1: '4 5 6 7', 2: '4 5 6 1', 3: 'S 7 6 4'};

    double worthCuttingRate(Knowledge knowledge, int seat) {
      final random = Random(1);
      var worth = 0;
      for (var i = 0; i < 400; i++) {
        final hand = knowledge.sampleOthers(random)[seat]!;
        if (worthCutting(HandValue(hand, const Rules()))) {
          worth++;
        }
      }
      return worth / 400;
    }

    test('is dealt a hand worth cutting with far more often than someone '
        'who asked for mus', () {
      final cut = _knowledge(
        hands,
        moves: [(0, const Mus()), (1, const NoHayMus())],
      );
      expect(cut.cutter, 1);
      expect(cut.rivalCut, isTrue);
      final cutter = worthCuttingRate(cut, 1);
      final other = worthCuttingRate(cut, 3);
      expect(cutter, greaterThan(other + 0.3), reason: '$cutter vs $other');
    });

    test('the mano cuts looser, so its cut says less', () {
      final byMano = _knowledge(hands, mano: 1, moves: [(1, const NoHayMus())]);
      final bySecond = _knowledge(
        hands,
        moves: [(0, const Mus()), (1, const NoHayMus())],
      );
      expect(
        worthCuttingRate(byMano, 1),
        lessThan(worthCuttingRate(bySecond, 1)),
      );
    });

    test('a rival who cut makes the grande harder to win; a partner who cut '
        'makes it easier', () {
      double grande(List<(int, Move)> moves) => _knowledge(
        hands,
        moves: moves,
      ).winChance(Lance.grande, Random(0), samples: 400);
      final rival = grande([(0, const Mus()), (1, const NoHayMus())]);
      final partner = grande([
        (0, const Mus()),
        (1, const Mus()),
        (2, const NoHayMus()),
      ]);
      final nobody = _knowledge(
        hands,
      ).winChance(Lance.grande, Random(0), samples: 400);
      expect(rival, lessThan(nobody));
      expect(partner, greaterThan(rival));
      expect(
        _knowledge(hands, moves: [(0, const NoHayMus())]).rivalCut,
        isFalse,
      );
    });
  });

  group('the partner\'s señas', () {
    const hands = {0: 'C 6 5 4', 1: '4 5 6 7', 2: 'R R 7 S', 3: '4 5 6 1'};

    test('its hand is dealt among those that make the same señas', () {
      final knowledge = _knowledge(hands);
      final random = Random(2);
      for (var i = 0; i < 200; i++) {
        final partner = HandValue(
          knowledge.sampleOthers(random)[2]!,
          const Rules(),
        );
        expect(partner.ranks.where((rank) => rank == 12), hasLength(2));
      }
    });

    test('it wins the grande more often with a partner who told dos reyes', () {
      final reading = _knowledge(
        hands,
      ).winChance(Lance.grande, Random(0), samples: 400);
      final blind = Knowledge.of(
        SeatView.of(
          MatchState(
            rules: const Rules(),
            score: const [0, 0],
            handNumber: 1,
            hand: dealt(hands),
          ),
          0,
        ),
        senas: false,
      ).winChance(Lance.grande, Random(0), samples: 400);
      expect(reading, greaterThan(blind + 0.15), reason: '$reading vs $blind');
    });
  });

  test('reading the partner\'s señas makes the estimates measurably closer '
      'to what happens, at grande and chica', () {
    for (final lance in [Lance.grande, Lance.chica]) {
      var reading = 0.0;
      var blind = 0.0;
      for (var seed = 0; seed < 300; seed++) {
        final (deck, random) = shuffledDeck(GameRandom(seed));
        final hand = HandState.deal(
          rules: const Rules(),
          mano: 0,
          deck: deck,
          random: random,
        );
        final view = SeatView.of(
          MatchState(
            rules: const Rules(),
            score: const [0, 0],
            handNumber: 2,
            hand: hand,
          ),
          0,
        );
        final won =
            bestTeam(lance, {
                  for (final seat in seats) seat: hand.valueOf(seat),
                }, 0) ==
                0
            ? 1.0
            : 0.0;
        double error(Knowledge knowledge) => pow(
          knowledge.winChance(lance, Random(seed), samples: 120) - won,
          2,
        ).toDouble();
        reading += error(Knowledge.of(view));
        blind += error(Knowledge.of(view, senas: false));
      }
      expect(
        reading,
        lessThan(blind * 0.9),
        reason: '$lance: $reading vs $blind',
      );
    }
  });
}

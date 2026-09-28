import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/bots/bot.dart';
import 'package:masmus/bots/estimate.dart';
import 'package:masmus/game/hand_value.dart';
import 'package:masmus/game/match.dart';
import 'package:masmus/game/move.dart';
import 'package:masmus/game/rules.dart';

import '../game/scenario.dart';

Knowledge _knowledge(
  Map<int, String> hands, {
  List<(int, Move)> moves = const [],
}) {
  var match = MatchState(
    rules: const Rules(),
    score: const [0, 0],
    handNumber: 1,
    hand: dealt(hands),
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
}

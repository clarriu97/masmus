import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/game/cards.dart';
import 'package:masmus/game/hand_value.dart';
import 'package:masmus/game/rules.dart';

import 'helpers.dart';

/// The hand comparisons of docs/RULES.md §11. `kings: null` means the result
/// is the same with 8 and with 4 kings; `winner` is 1 for A, -1 for B, 0 for
/// a tie.
const _examples = [
  (
    id: 'E-1',
    kings: null,
    a: 'R R 7 1',
    b: 'R C C C',
    lance: Lance.grande,
    winner: 1,
  ),
  (
    id: 'E-2',
    kings: Kings.eight,
    a: '3 R 7 1',
    b: 'R R 7 1',
    lance: Lance.grande,
    winner: 0,
  ),
  (
    id: 'E-3',
    kings: Kings.four,
    a: '3 R 7 1',
    b: 'R R 7 1',
    lance: Lance.grande,
    winner: -1,
  ),
  (
    id: 'E-4',
    kings: null,
    a: '7 1 1 1',
    b: '6 5 4 1',
    lance: Lance.chica,
    winner: 1,
  ),
  (
    id: 'E-5',
    kings: null,
    a: 'R 1 1 1',
    b: '4 1 1 1',
    lance: Lance.chica,
    winner: -1,
  ),
  (
    id: 'E-6',
    kings: Kings.eight,
    a: '2 1 4 5',
    b: '1 1 4 5',
    lance: Lance.chica,
    winner: 0,
  ),
  (
    id: 'E-7',
    kings: null,
    a: 'R R 7 1',
    b: 'C C S S',
    lance: Lance.pares,
    winner: -1,
  ),
  (
    id: 'E-8',
    kings: null,
    a: '7 7 7 1',
    b: 'R R C 1',
    lance: Lance.pares,
    winner: 1,
  ),
  (
    id: 'E-9',
    kings: null,
    a: 'R R 1 1',
    b: 'C C S S',
    lance: Lance.pares,
    winner: 1,
  ),
  (
    id: 'E-10',
    kings: null,
    a: 'R R R R',
    b: 'R R C C',
    lance: Lance.pares,
    winner: 1,
  ),
  (
    id: 'E-11',
    kings: null,
    a: '5 5 R 1',
    b: '5 5 C 1',
    lance: Lance.pares,
    winner: 0,
  ),
  (
    id: 'E-12',
    kings: Kings.eight,
    a: '3 3 7 1',
    b: 'R R 7 1',
    lance: Lance.pares,
    winner: 0,
  ),
  (
    id: 'E-13',
    kings: null,
    a: 'R C 7 4',
    b: 'R R R S',
    lance: Lance.juego,
    winner: 1,
  ),
  (
    id: 'E-14',
    kings: null,
    a: 'R R 7 5',
    b: 'R R R S',
    lance: Lance.juego,
    winner: 1,
  ),
  (
    id: 'E-15',
    kings: null,
    a: 'R R R 7',
    b: 'R R 7 6',
    lance: Lance.juego,
    winner: 1,
  ),
  (
    id: 'E-18',
    kings: Kings.four,
    a: 'R R 7 3',
    b: 'R R 5 4',
    lance: Lance.punto,
    winner: 1,
  ),
];

int _sign(int n) => n.sign;

/// The hand with every 3 turned into a rey and every 2 into an as of the
/// same suit: what 8 kings means.
List<PlayingCard> _foldKings(List<PlayingCard> cards) => [
  for (final card in cards)
    switch (card.number) {
      3 => PlayingCard(card.suit, 12),
      2 => PlayingCard(card.suit, 1),
      _ => card,
    },
];

void main() {
  group('examples of docs/RULES.md §11', () {
    for (final e in _examples) {
      for (final kings in e.kings == null ? Kings.values : [e.kings!]) {
        test(
          '${e.id} · ${e.lance.name}: ${e.a} vs ${e.b} (${kings.name} kings)',
          () {
            final a = value(e.a, kings: kings);
            final b = value(e.b, kings: kings);
            expect(_sign(compareHands(e.lance, a, b)), e.winner);
            expect(_sign(compareHands(e.lance, b, a)), -e.winner);
          },
        );
      }
    }

    test('E-16 · with 8 kings, R R 3 1 adds up to 31: juego', () {
      final hand = value('R R 3 1');
      expect(hand.points, 31);
      expect(hand.hasJuego, isTrue);
    });

    test(
      'E-17 · with 4 kings, R R 3 1 adds up to 24: no juego, it goes to punto',
      () {
        final hand = value('R R 3 1', kings: Kings.four);
        expect(hand.points, 24);
        expect(hand.hasJuego, isFalse);
      },
    );
  });

  group('R-BAR-2 · kings', () {
    test('with 8 kings a 3 is a rey and a 2 an as in every lance', () {
      const rules = Rules();
      for (final cards in allHands()) {
        if (!cards.any((c) => c.number == 2 || c.number == 3)) {
          continue;
        }
        expect(
          HandValue(cards, rules),
          HandValue(_foldKings(cards), rules),
          reason: '$cards',
        );
      }
    });

    test('with 4 kings every card is itself', () {
      final hand = value('3 3 2 7', kings: Kings.four);
      expect(hand.ranks, [7, 3, 3, 2]);
      expect(hand.pares, ParesKind.par);
      expect(hand.paresRanks, [3]);
      expect(hand.points, 15);
    });
  });

  test('R-BAR-3 · ranks are ordered rey, caballo, sota, 7 … as', () {
    expect(value('1 S R 7').ranks, [12, 10, 7, 1]);
    expect(value('C 4 S 5').ranks, [11, 10, 5, 4]);
  });

  group('R-BAR-4 · points', () {
    test('sota, caballo and rey are worth 10, the rest their number', () {
      expect(value('S C R 7').points, 37);
      expect(value('1 4 5 6').points, 16);
    });

    test('with 8 kings the 3 is worth 10 and the 2 is worth 1', () {
      expect(value('3 3 2 2').points, 22);
      expect(value('3 3 2 2', kings: Kings.four).points, 10);
    });
  });

  group('R-LAN-4 · pares', () {
    test('par, medias and duples', () {
      expect(value('7 7 5 1').pares, ParesKind.par);
      expect(value('7 7 7 1').pares, ParesKind.medias);
      expect(value('7 7 5 5').pares, ParesKind.duples);
      expect(value('7 7 7 7').pares, ParesKind.duples);
      expect(value('7 6 5 1').pares, ParesKind.none);
    });

    test('hasPares is true for par, medias and duples only', () {
      expect(value('7 7 5 1').hasPares, isTrue);
      expect(value('7 7 7 1').hasPares, isTrue);
      expect(value('7 7 5 5').hasPares, isTrue);
      expect(value('7 6 5 1').hasPares, isFalse);
    });

    test('keep the ranks that form them, highest first', () {
      expect(value('5 R 5 1').paresRanks, [5]);
      expect(value('S S S 4').paresRanks, [10]);
      expect(value('5 5 C C').paresRanks, [11, 5]);
      expect(value('R R R R').paresRanks, [12, 12]);
      expect(value('7 6 5 1').paresRanks, isEmpty);
    });

    test('duples beat medias, which beat par, which beats nothing', () {
      final order = ['7 6 5 1', 'R R C 1', '1 1 1 4', '4 4 1 1'];
      for (var i = 0; i < order.length; i++) {
        for (var j = i + 1; j < order.length; j++) {
          expect(
            compareHands(Lance.pares, value(order[j]), value(order[i])),
            greaterThan(0),
            reason: '${order[j]} > ${order[i]}',
          );
        }
      }
    });

    test('count as combinatorics says, with 8 and with 4 kings', () {
      final expected = {
        Kings.eight: {
          ParesKind.duples: 3486,
          ParesKind.medias: 4448,
          ParesKind.par: 43776,
          ParesKind.none: 39680,
        },
        Kings.four: {
          ParesKind.duples: 1630,
          ParesKind.medias: 1440,
          ParesKind.par: 34560,
          ParesKind.none: 53760,
        },
      };
      for (final kings in Kings.values) {
        final counts = {for (final kind in ParesKind.values) kind: 0};
        final rules = Rules(kings: kings);
        for (final cards in allHands()) {
          final kind = HandValue(cards, rules).pares;
          counts[kind] = counts[kind]! + 1;
        }
        expect(counts, expected[kings], reason: kings.name);
      }
    });

    test('R-REC-3 · worth 1, 2 and 3 points', () {
      expect(value('7 6 5 1').paresTantos, 0);
      expect(value('7 7 5 1').paresTantos, 1);
      expect(value('7 7 7 1').paresTantos, 2);
      expect(value('7 7 5 5').paresTantos, 3);
    });
  });

  group('R-LAN-5 · juego', () {
    test('is 31 or more', () {
      expect(value('R C S 1').points, 31);
      expect(value('R C S 1').hasJuego, isTrue);
      expect(value('R C 7 3', kings: Kings.four).points, 30);
      expect(value('R C 7 3', kings: Kings.four).hasJuego, isFalse);
    });

    test('ranks 31, 32, 40, 37, 36, 35, 34, 33', () {
      final hands = {
        31: 'R C 7 4',
        32: 'R C 7 5',
        40: 'R C S R',
        37: 'R C S 7',
        36: 'R C S 6',
        35: 'R C S 5',
        34: 'R C S 4',
        33: 'R C 7 6',
      };
      for (var i = 0; i < juegoOrder.length - 1; i++) {
        final better = value(hands[juegoOrder[i]]!);
        final worse = value(hands[juegoOrder[i + 1]]!);
        expect(better.points, juegoOrder[i]);
        expect(compareHands(Lance.juego, better, worse), greaterThan(0));
      }
    });

    test('38 and 39 cannot be made, and every hand of 31 or more is juego', () {
      for (final kings in Kings.values) {
        final rules = Rules(kings: kings);
        for (final cards in allHands()) {
          final hand = HandValue(cards, rules);
          expect(hand.points, isNot(anyOf(38, 39)));
          expect(hand.hasJuego, hand.points >= 31);
          expect(hand.points, inInclusiveRange(4, 40));
        }
      }
    });

    test('40 is four cards worth 10: 495 hands with 4 kings, 1,820 with 8', () {
      for (final (kings, expected) in [
        (Kings.four, 495),
        (Kings.eight, 1820),
      ]) {
        final rules = Rules(kings: kings);
        final count = allHands()
            .where((cards) => HandValue(cards, rules).points == 40)
            .length;
        expect(count, expected, reason: kings.name);
      }
    });

    test('R-REC-4 · 31 is worth 3 points, any other juego 2', () {
      expect(value('R C 7 4').juegoTantos, 3);
      expect(value('R C 7 5').juegoTantos, 2);
      expect(value('R C S R').juegoTantos, 2);
      expect(value('R 7 5 1').juegoTantos, 0);
    });
  });

  test('R-LAN-6 · punto: the highest sum wins, 30 at most', () {
    expect(
      compareHands(Lance.punto, value('R 7 7 5'), value('R 7 7 4')),
      greaterThan(0),
    );
    var highest = 0;
    for (final cards in allHands()) {
      final hand = HandValue(cards, const Rules(kings: Kings.four));
      if (!hand.hasJuego) {
        highest = max(highest, hand.points);
      }
    }
    expect(highest, 30);
  });

  group('R-LAN-2 and R-LAN-3 · grande and chica look at every card', () {
    test('grande goes down to the fourth card', () {
      expect(
        compareHands(Lance.grande, value('R C 7 5'), value('R C 7 4')),
        greaterThan(0),
      );
    });

    test('chica goes up to the fourth card', () {
      expect(
        compareHands(Lance.chica, value('1 4 5 6'), value('1 4 5 7')),
        greaterThan(0),
      );
    });

    test('equal values have equal hash codes', () {
      final a = HandValue(cards('Ro Cc 7e 1b'), const Rules());
      final b = HandValue(cards('Rb 3o Co 7c'), const Rules());
      expect(a, isNot(b));
      expect(a, HandValue(cards('Rc Ce 7o 1c'), const Rules()));
      expect(
        a.hashCode,
        HandValue(cards('Rc Ce 7o 1c'), const Rules()).hashCode,
      );
    });

    test('suits never matter', () {
      expect(
        HandValue(cards('Ro Cc 7e 1b'), const Rules()),
        HandValue(cards('Rb Co 7c 1e'), const Rules()),
      );
    });
  });

  group('comparisons over random hands', () {
    final rng = Random(2026);
    final hands = allHands().toList();
    List<HandValue> pick(int n, Rules rules, bool Function(HandValue) keep) {
      final picked = <HandValue>[];
      while (picked.length < n) {
        final hand = HandValue(hands[rng.nextInt(hands.length)], rules);
        if (keep(hand)) {
          picked.add(hand);
        }
      }
      return picked;
    }

    for (final kings in Kings.values) {
      final rules = Rules(kings: kings);
      for (final lance in Lance.values) {
        test(
          '${lance.name} is antisymmetric and transitive (${kings.name} kings)',
          () {
            final keep = switch (lance) {
              Lance.juego => (HandValue h) => h.hasJuego,
              Lance.punto => (HandValue h) => !h.hasJuego,
              _ => (HandValue h) => true,
            };
            final sample = pick(3000, rules, keep);
            for (var i = 0; i + 2 < sample.length; i += 3) {
              final [a, b, c] = sample.sublist(i, i + 3);
              expect(
                _sign(compareHands(lance, a, b)),
                -_sign(compareHands(lance, b, a)),
              );
              if (compareHands(lance, a, b) >= 0 &&
                  compareHands(lance, b, c) >= 0) {
                expect(compareHands(lance, a, c), greaterThanOrEqualTo(0));
              }
              expect(compareHands(lance, a, a), 0);
            }
          },
        );
      }
    }
  });
}

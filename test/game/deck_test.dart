import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/game/cards.dart';
import 'package:masmus/game/deck.dart';
import 'package:masmus/game/game_random.dart';

import 'helpers.dart';

void main() {
  test('a shuffled deck has the 40 cards once, the same for the same seed', () {
    final (deck, _) = shuffledDeck(const GameRandom(1));
    final (again, _) = shuffledDeck(const GameRandom(1));
    final (other, _) = shuffledDeck(const GameRandom(2));
    expect(deck.toSet(), spanishDeck.toSet());
    expect(deck, again);
    expect(deck, isNot(other));
  });

  group('R-MUS-4 · serving cards', () {
    test('comes from the top of the stock', () {
      final served = serve(
        2,
        stock: cards('Ro 7e 1b Sc'),
        discards: cards('4o'),
        random: const GameRandom(1),
      );
      expect(served.cards, cards('Ro 7e'));
      expect(served.stock, cards('1b Sc'));
      expect(served.discards, cards('4o'));
      expect(served.random.state, const GameRandom(1).state);
    });

    test('empties the stock exactly without touching the discards', () {
      final served = serve(
        2,
        stock: cards('Ro 7e'),
        discards: cards('4o 5o'),
        random: const GameRandom(1),
      );
      expect(served.cards, cards('Ro 7e'));
      expect(served.stock, isEmpty);
      expect(served.discards, cards('4o 5o'));
    });

    test('when the stock runs short, gives what is left and the rest from '
        'the shuffled discards', () {
      final discards = cards('4o 5o 6o 7o 1c');
      final served = serve(
        3,
        stock: cards('Ro'),
        discards: discards,
        random: const GameRandom(5),
      );
      expect(served.cards.first, PlayingCard.parse('Ro'));
      expect(served.cards, hasLength(3));
      expect(served.discards, isEmpty);
      expect(served.stock, hasLength(3));
      expect(
        {...served.cards.skip(1), ...served.stock},
        discards.toSet(),
        reason: 'the new stock is made of the discards',
      );
      expect(served.random.state, isNot(const GameRandom(5).state));
    });

    test('with an empty stock, everything comes from the discards', () {
      final served = serve(
        4,
        stock: const [],
        discards: cards('4o 5o 6o 7o 1c'),
        random: const GameRandom(5),
      );
      expect(served.cards, hasLength(4));
      expect(served.stock, hasLength(1));
      expect(served.discards, isEmpty);
    });

    test('never loses or duplicates a card over many rounds of mus', () {
      var (stock, random) = shuffledDeck(const GameRandom(314));
      var discards = <PlayingCard>[];
      final hands = <List<PlayingCard>>[];
      for (var seat = 0; seat < 4; seat++) {
        hands.add(stock.sublist(0, 4));
        stock = stock.sublist(4);
      }
      for (var round = 0; round < 60; round++) {
        for (final hand in hands) {
          final (count, next) = random.nextInt(4);
          random = next;
          discards = [...discards, ...hand.sublist(0, count + 1)];
          hand.removeRange(0, count + 1);
        }
        for (final hand in hands) {
          final served = serve(
            4 - hand.length,
            stock: stock,
            discards: discards,
            random: random,
          );
          hand.addAll(served.cards);
          stock = served.stock;
          discards = served.discards;
          random = served.random;
        }
        final everything = [...hands.expand((h) => h), ...stock, ...discards];
        expect(everything, hasLength(40), reason: 'round $round');
        expect(everything.toSet(), spanishDeck.toSet(), reason: 'round $round');
        expect(hands.every((h) => h.length == 4), isTrue);
      }
    });
  });
}

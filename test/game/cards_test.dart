import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/game/cards.dart';

void main() {
  group('R-BAR-1 · the Spanish deck', () {
    test('has 40 distinct cards', () {
      expect(spanishDeck, hasLength(40));
      expect(spanishDeck.toSet(), hasLength(40));
    });

    test('has 1 to 7, sota, caballo and rey in each of the four suits', () {
      for (final suit in Suit.values) {
        expect(spanishDeck.where((c) => c.suit == suit).map((c) => c.number), [
          1,
          2,
          3,
          4,
          5,
          6,
          7,
          10,
          11,
          12,
        ]);
      }
    });

    test('cannot be changed', () {
      expect(
        () => spanishDeck.add(const PlayingCard(Suit.oros, 1)),
        throwsUnsupportedError,
      );
    });
  });

  group('card codes', () {
    test('read the notation of the spec', () {
      expect(PlayingCard.parse('Ro'), const PlayingCard(Suit.oros, 12));
      expect(PlayingCard.parse('Cc'), const PlayingCard(Suit.copas, 11));
      expect(PlayingCard.parse('Sb'), const PlayingCard(Suit.bastos, 10));
      expect(PlayingCard.parse('7e'), const PlayingCard(Suit.espadas, 7));
      expect(PlayingCard.parse('1b'), const PlayingCard(Suit.bastos, 1));
    });

    test('round-trip for every card', () {
      for (final card in spanishDeck) {
        expect(PlayingCard.parse(card.code), card);
        expect(card.toString(), card.code);
      }
    });

    test('are unique', () {
      expect(spanishDeck.map((c) => c.code).toSet(), hasLength(40));
    });

    test('reject anything that is not a card', () {
      for (final bad in ['', 'R', 'Rx', '8o', '9c', '0e', 'Roo', 'ro', 'oR']) {
        expect(
          () => PlayingCard.parse(bad),
          throwsFormatException,
          reason: bad,
        );
      }
    });
  });

  test('cards are equal by suit and number', () {
    expect(const PlayingCard(Suit.copas, 5), equals(PlayingCard.parse('5c')));
    expect(
      const PlayingCard(Suit.copas, 5).hashCode,
      PlayingCard.parse('5c').hashCode,
    );
    expect(
      const PlayingCard(Suit.copas, 5),
      isNot(const PlayingCard(Suit.oros, 5)),
    );
  });
}

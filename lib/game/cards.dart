enum Suit { oros, copas, espadas, bastos }

/// The numbers of the Spanish deck: 1–7, sota (10), caballo (11), rey (12).
const cardNumbers = [1, 2, 3, 4, 5, 6, 7, 10, 11, 12];

const _numberCodes = {
  1: '1',
  2: '2',
  3: '3',
  4: '4',
  5: '5',
  6: '6',
  7: '7',
  10: 'S',
  11: 'C',
  12: 'R',
};

const _suitCodes = {
  Suit.oros: 'o',
  Suit.copas: 'c',
  Suit.espadas: 'e',
  Suit.bastos: 'b',
};

/// A card of the 40-card Spanish deck (R-BAR-1), written as a two-letter
/// code: number (`1`–`7`, `S`, `C`, `R`) and suit (`o`, `c`, `e`, `b`), so
/// `Ro` is the rey de oros and `7e` the siete de espadas.
final class PlayingCard {
  const PlayingCard(this.suit, this.number)
    : assert(number >= 1 && number <= 12 && (number <= 7 || number >= 10));

  factory PlayingCard.parse(String code) {
    if (code.length == 2) {
      final number = _numberCodes.entries
          .where((e) => e.value == code[0])
          .map((e) => e.key)
          .firstOrNull;
      final suit = _suitCodes.entries
          .where((e) => e.value == code[1])
          .map((e) => e.key)
          .firstOrNull;
      if (number != null && suit != null) {
        return PlayingCard(suit, number);
      }
    }
    throw FormatException('Not a card code', code);
  }

  final Suit suit;
  final int number;

  String get code => '${_numberCodes[number]}${_suitCodes[suit]}';

  @override
  bool operator ==(Object other) =>
      other is PlayingCard && other.suit == suit && other.number == number;

  @override
  int get hashCode => Object.hash(suit, number);

  @override
  String toString() => code;
}

final List<PlayingCard> spanishDeck = List.unmodifiable([
  for (final suit in Suit.values)
    for (final number in cardNumbers) PlayingCard(suit, number),
]);

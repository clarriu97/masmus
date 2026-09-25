import 'package:masmus/game/cards.dart';
import 'package:masmus/game/hand_value.dart';
import 'package:masmus/game/rules.dart';

/// Cards from their codes: `cards('Ro Rc 7e 1b')`.
List<PlayingCard> cards(String codes) => [
  for (final code in codes.split(' ')) PlayingCard.parse(code),
];

/// A hand written by numbers only, as the examples in docs/RULES.md are
/// (`'R R 7 1'`); a repeated number takes the next suit.
List<PlayingCard> hand(String numbers) {
  final seen = <String, int>{};
  return [
    for (final number in numbers.split(' '))
      PlayingCard.parse(
        '$number${'oceb'[seen.update(number, (n) => n + 1, ifAbsent: () => 0)]}',
      ),
  ];
}

HandValue value(String numbers, {Kings kings = Kings.eight}) =>
    HandValue(hand(numbers), Rules(kings: kings));

/// Every four-card hand of the deck (91,390).
Iterable<List<PlayingCard>> allHands() sync* {
  const n = 40;
  for (var a = 0; a < n; a++) {
    for (var b = a + 1; b < n; b++) {
      for (var c = b + 1; c < n; c++) {
        for (var d = c + 1; d < n; d++) {
          yield [
            spanishDeck[a],
            spanishDeck[b],
            spanishDeck[c],
            spanishDeck[d],
          ];
        }
      }
    }
  }
}

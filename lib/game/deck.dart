import 'cards.dart';
import 'game_random.dart';

/// Cards handed to a player, and what is left of the stock and the discards.
typedef Served = ({
  List<PlayingCard> cards,
  List<PlayingCard> stock,
  List<PlayingCard> discards,
  GameRandom random,
});

(List<PlayingCard>, GameRandom) shuffledDeck(GameRandom random) =>
    random.shuffle(spanishDeck);

/// Serves [count] cards from the top of [stock]. When it runs short, the
/// player gets what is left and the rest comes from a new stock made of all
/// the [discards], shuffled (R-MUS-4).
Served serve(
  int count, {
  required List<PlayingCard> stock,
  required List<PlayingCard> discards,
  required GameRandom random,
}) {
  if (count <= stock.length) {
    return (
      cards: stock.sublist(0, count),
      stock: stock.sublist(count),
      discards: discards,
      random: random,
    );
  }
  final missing = count - stock.length;
  assert(missing <= discards.length, 'Not enough cards out of the hands');
  final (reshuffled, next) = random.shuffle(discards);
  return (
    cards: [...stock, ...reshuffled.take(missing)],
    stock: reshuffled.sublist(missing),
    discards: const [],
    random: next,
  );
}

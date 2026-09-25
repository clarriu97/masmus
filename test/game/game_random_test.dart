import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/game/game_random.dart';

List<int> draws(GameRandom random, int max, int count) {
  final values = <int>[];
  var source = random;
  for (var i = 0; i < count; i++) {
    final (value, next) = source.nextInt(max);
    values.add(value);
    source = next;
  }
  return values;
}

void main() {
  test('matches the reference mulberry32 sequence', () {
    // Values from an independent implementation of mulberry32. Saved matches
    // and regression seeds depend on this sequence never changing.
    expect(draws(const GameRandom(42), 40, 12), [
      24, 17, 34, 26, 6, 21, 10, 24, 34, 18, 9, 35, //
    ]);
    expect(draws(const GameRandom(0), 40, 12), [
      10, 0, 8, 5, 18, 21, 24, 25, 18, 23, 9, 3, //
    ]);
  });

  test('the same seed gives the same numbers', () {
    expect(
      draws(const GameRandom(7), 40, 100),
      draws(const GameRandom(7), 40, 100),
    );
  });

  test('different seeds give different numbers', () {
    expect(
      draws(const GameRandom(7), 40, 20),
      isNot(draws(const GameRandom(8), 40, 20)),
    );
  });

  test('a seed beyond 32 bits is folded into 32 bits', () {
    expect(const GameRandom(0x100000005).state, 5);
    expect(const GameRandom(-1).state, 0xFFFFFFFF);
  });

  test('nextInt stays in range and reaches every value', () {
    for (final max in [1, 2, 7, 40]) {
      final values = draws(const GameRandom(123), max, 2000);
      expect(values.every((v) => v >= 0 && v < max), isTrue, reason: '$max');
      expect(values.toSet(), hasLength(max), reason: '$max');
    }
  });

  test('shuffle keeps every item once and is reproducible', () {
    final items = List.generate(40, (i) => i);
    final (once, _) = const GameRandom(99).shuffle(items);
    final (twice, _) = const GameRandom(99).shuffle(items);
    expect(once, twice);
    expect(once.toSet(), items.toSet());
    expect(once, isNot(items));
    expect(items, List.generate(40, (i) => i), reason: 'input untouched');
  });

  test('shuffle leaves the first card in place about 1 time in 40', () {
    final items = List.generate(40, (i) => i);
    var random = const GameRandom(2026);
    var stayed = 0;
    const rounds = 8000;
    for (var i = 0; i < rounds; i++) {
      final (shuffled, next) = random.shuffle(items);
      random = next;
      if (shuffled.first == 0) {
        stayed++;
      }
    }
    expect(stayed, inInclusiveRange(140, 260));
  });
}

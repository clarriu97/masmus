const _mask = 0xFFFFFFFF;

int _mul32(int a, int b) => (a * b) & _mask;

/// A deterministic random source kept as a plain value (mulberry32), so the
/// engine stays pure: every shuffle returns the next source, a match can be
/// replayed from its seed and saved as a single number.
final class GameRandom {
  const GameRandom(int seed) : state = seed & _mask;

  final int state;

  /// A number in `[0, max)` and the source to use next.
  (int, GameRandom) nextInt(int max) {
    assert(max > 0);
    final next = (state + 0x6D2B79F5) & _mask;
    var t = _mul32(next ^ (next >> 15), next | 1);
    t = ((t + _mul32(t ^ (t >> 7), t | 61)) & _mask) ^ t;
    final value = t ^ (t >> 14);
    return ((value * max) >> 32, GameRandom(next));
  }

  /// A shuffled copy of [items] (Fisher–Yates) and the source to use next.
  (List<T>, GameRandom) shuffle<T>(List<T> items) {
    final result = [...items];
    var random = this;
    for (var i = result.length - 1; i > 0; i--) {
      final (j, next) = random.nextInt(i + 1);
      random = next;
      final swap = result[i];
      result[i] = result[j];
      result[j] = swap;
    }
    return (result, random);
  }
}

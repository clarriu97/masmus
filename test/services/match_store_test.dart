import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/game/match.dart';
import 'package:masmus/game/move.dart';
import 'package:masmus/services/match_store.dart';

void main() {
  test('keeps the last match saved, as it was, until cleared', () async {
    final store = MatchStore.inMemory();
    expect(await store.load(), isNull);

    final first = MatchState.start(seed: 1, mano: 0);
    await store.save(first);
    final second = first.play(0, const Mus());
    await store.save(second);
    expect((await store.load())!.toJson(), second.toJson());

    await store.clear();
    expect(await store.load(), isNull);
  });
}

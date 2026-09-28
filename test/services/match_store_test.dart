import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/bots/heuristic_bot.dart';
import 'package:masmus/game/match.dart';
import 'package:masmus/game/move.dart';
import 'package:masmus/services/match_store.dart';

const _bots = {
  1: Personality.prudente,
  2: Personality.calculador,
  3: Personality.temeraria,
};

SavedMatch _saved([List<Move> moves = const []]) {
  var match = MatchState.start(seed: 1, mano: 0);
  for (final move in moves) {
    match = match.play(match.hand.turn!, move);
  }
  return SavedMatch(match: match, bots: _bots);
}

void _expectSame(SavedMatch? actual, SavedMatch expected) {
  expect(actual, isNotNull);
  expect(actual!.match.toJson(), expected.match.toJson());
  expect(actual.bots, expected.bots);
}

void main() {
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('match_store_test_');
  });

  tearDown(() => directory.delete(recursive: true));

  File file() => File('${directory.path}/match.json');

  test(
    'in memory: keeps the last match saved, as it was, until cleared',
    () async {
      final store = MatchStore.inMemory();
      expect(store.saved, isNull);
      await store.save(_saved());
      final later = _saved([const Mus()]);
      await store.save(later);
      _expectSame(store.saved, later);
      await store.clear();
      expect(store.saved, isNull);
    },
  );

  test('on disk: a match saved is there when the app opens again', () async {
    final store = await MatchStore.open(directory);
    expect(store.saved, isNull);
    expect(store.setAside, isFalse);
    final saved = _saved([const Mus(), const Mus()]);
    await store.save(saved);

    final reopened = await MatchStore.open(directory);
    _expectSame(reopened.saved, saved);
    expect(file().readAsStringSync(), contains('"schemaVersion":1'));
    expect(File('${file().path}.tmp').existsSync(), isFalse);
  });

  test('saves quickly one after another keep the last', () async {
    final store = await MatchStore.open(directory);
    final last = _saved([const Mus(), const Mus(), const Mus()]);
    await Future.wait([
      store.save(_saved()),
      store.save(_saved([const Mus()])),
      store.save(last),
    ]);
    _expectSame((await MatchStore.open(directory)).saved, last);
  });

  test('clearing removes it for good', () async {
    final store = await MatchStore.open(directory);
    await store.save(_saved());
    await store.clear();
    expect(store.saved, isNull);
    expect(file().existsSync(), isFalse);
    expect((await MatchStore.open(directory)).saved, isNull);
  });

  for (final (what, contents) in [
    ('a damaged file', '{"schemaVersion": 1, "match": {'),
    ('a file from a newer version', '{"schemaVersion": 99}'),
    ('something that is not a match', '{"schemaVersion": 1, "match": 3}'),
  ]) {
    test('$what is set aside, kept and never overwritten', () async {
      file().writeAsStringSync(contents);
      final store = await MatchStore.open(directory);
      expect(store.saved, isNull);
      expect(store.setAside, isTrue);
      final aside = directory
          .listSync()
          .whereType<File>()
          .where((f) => f.path.contains('match.unreadable-'))
          .single;
      expect(aside.readAsStringSync(), contents);

      await store.save(_saved());
      expect(aside.readAsStringSync(), contents);
      expect((await MatchStore.open(directory)).setAside, isFalse);
    });
  }
}

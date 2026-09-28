import 'dart:convert';
import 'dart:io';

import '../bots/heuristic_bot.dart';
import '../game/match.dart';

/// A match in progress and who plays each bot seat: what is saved after
/// every move and resumed when the app opens again.
final class SavedMatch {
  const SavedMatch({required this.match, required this.bots});

  factory SavedMatch.fromJson(Map<String, Object?> json) => SavedMatch(
    match: MatchState.fromJson(json['match']! as Map<String, Object?>),
    bots: {
      for (final MapEntry(:key, :value)
          in (json['bots']! as Map<String, Object?>).entries)
        int.parse(key): Personality.values.byName(value! as String),
    },
  );

  final MatchState match;
  final Map<int, Personality> bots;

  Map<String, Object?> toJson() => {
    'match': match.toJson(),
    'bots': {
      for (final MapEntry(:key, :value) in bots.entries) '$key': value.name,
    },
  };
}

/// Keeps the match in progress. [saved] is what was on disk when the app
/// opened, then whatever was saved since.
abstract interface class MatchStore {
  /// In memory, going through JSON as the file does. For tests.
  factory MatchStore.inMemory([SavedMatch? saved]) = _InMemoryMatchStore;

  /// The file in [directory]. One it can't read (damaged, or written by a
  /// newer version) is copied aside, never overwritten, and [setAside] says
  /// so.
  static Future<MatchStore> open(Directory directory) =>
      _FileMatchStore.open(File('${directory.path}/match.json'));

  /// Version written with the match. Bump it with every change to the
  /// format, with a migration from the previous one.
  static const schemaVersion = 1;

  SavedMatch? get saved;

  /// A saved match couldn't be read when opening.
  bool get setAside;

  Future<void> save(SavedMatch match);

  Future<void> clear();
}

final class _InMemoryMatchStore implements MatchStore {
  _InMemoryMatchStore([SavedMatch? saved])
    : _json = saved == null ? null : jsonEncode(saved.toJson());

  String? _json;

  @override
  SavedMatch? get saved => switch (_json) {
    final json? => SavedMatch.fromJson(
      jsonDecode(json) as Map<String, Object?>,
    ),
    null => null,
  };

  @override
  bool get setAside => false;

  @override
  Future<void> save(SavedMatch match) async =>
      _json = jsonEncode(match.toJson());

  @override
  Future<void> clear() async => _json = null;
}

final class _FileMatchStore implements MatchStore {
  _FileMatchStore(this._file, this.saved, {required this.setAside});

  static Future<MatchStore> open(File file) async {
    if (!await file.exists()) {
      return _FileMatchStore(file, null, setAside: false);
    }
    try {
      final json =
          jsonDecode(await file.readAsString()) as Map<String, Object?>;
      if (json['schemaVersion'] != MatchStore.schemaVersion) {
        throw FormatException('Unknown schema', json['schemaVersion']);
      }
      return _FileMatchStore(file, SavedMatch.fromJson(json), setAside: false);
    } on Object {
      final stamp = DateTime.now().millisecondsSinceEpoch;
      await file.rename('${file.parent.path}/match.unreadable-$stamp.json');
      return _FileMatchStore(file, null, setAside: true);
    }
  }

  final File _file;

  @override
  SavedMatch? saved;

  @override
  final bool setAside;

  File get _temp => File('${_file.path}.tmp');

  /// Writes and deletes one after another, in the order they were asked.
  Future<void> _last = Future.value();

  Future<void> _queue(Future<void> Function() write) =>
      _last = _last.then((_) => write());

  /// Writes a temporary file and renames it over the real one, so a write
  /// cut short never leaves half a match.
  @override
  Future<void> save(SavedMatch match) {
    saved = match;
    final json = jsonEncode({
      'schemaVersion': MatchStore.schemaVersion,
      ...match.toJson(),
    });
    return _queue(() async {
      await _temp.writeAsString(json, flush: true);
      await _temp.rename(_file.path);
    });
  }

  @override
  Future<void> clear() {
    saved = null;
    return _queue(() async {
      if (await _file.exists()) {
        await _file.delete();
      }
    });
  }
}

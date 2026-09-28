import '../bots/heuristic_bot.dart';
import '../game/match.dart';
import 'json_file.dart';

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

/// Keeps the match in progress. [saved] is what was in the file when the
/// app opened, then whatever was saved since.
final class MatchStore {
  MatchStore._(this._file, this.saved, {required this.setAside});

  /// In memory, going through JSON as the file does. For tests.
  factory MatchStore.inMemory([SavedMatch? saved]) =>
      MatchStore._(JsonFile.inMemory(), saved, setAside: false);

  /// Reads [file]. One it can't read (damaged, or written by a newer
  /// version) is set aside, never overwritten, and [setAside] says so.
  static Future<MatchStore> open(JsonFile file) async {
    try {
      final json = await file.read();
      if (json == null) {
        return MatchStore._(file, null, setAside: false);
      }
      if (json['schemaVersion'] != schemaVersion) {
        throw FormatException('Unknown schema', json['schemaVersion']);
      }
      return MatchStore._(file, SavedMatch.fromJson(json), setAside: false);
    } on Object {
      await file.setAside();
      return MatchStore._(file, null, setAside: true);
    }
  }

  /// Version written with the match. Bump it with every change to the
  /// format, with a migration from the previous one.
  static const schemaVersion = 1;

  final JsonFile _file;

  SavedMatch? saved;

  /// A saved match couldn't be read when opening.
  final bool setAside;

  Future<void> save(SavedMatch match) {
    saved = match;
    return _file.write({'schemaVersion': schemaVersion, ...match.toJson()});
  }

  Future<void> clear() {
    saved = null;
    return _file.delete();
  }
}

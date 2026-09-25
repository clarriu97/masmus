import 'dart:convert';

import '../game/match.dart';

/// Keeps the match in progress, saved after every move. In memory for now;
/// on disk, so a match survives the app being killed, with #29.
abstract interface class MatchStore {
  factory MatchStore.inMemory() = _InMemoryMatchStore;

  Future<MatchState?> load();

  Future<void> save(MatchState match);

  Future<void> clear();
}

/// Stores the JSON, not the object, so saving works the way it will on disk.
final class _InMemoryMatchStore implements MatchStore {
  String? _json;

  @override
  Future<MatchState?> load() async => switch (_json) {
    final json? => MatchState.fromJson(
      jsonDecode(json) as Map<String, Object?>,
    ),
    null => null,
  };

  @override
  Future<void> save(MatchState match) async =>
      _json = jsonEncode(match.toJson());

  @override
  Future<void> clear() async => _json = null;
}

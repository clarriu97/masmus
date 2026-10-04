import 'dart:async';

import 'package:flutter/foundation.dart';

import '../game/rules.dart';
import '../services/json_file.dart';
import 'match_controller.dart';

/// What the player chose in Ajustes.
final class Settings {
  const Settings({
    this.rules = const Rules(),
    this.pace = Pace.normal,
    this.handHelp = true,
    this.haptics = true,
  });

  factory Settings.fromJson(Map<String, Object?> json) => Settings(
    rules: Rules.fromJson(json['rules']! as Map<String, Object?>),
    pace: Pace.values.byName(json['pace']! as String),
    handHelp: json['handHelp']! as bool,
    haptics: json['haptics'] as bool? ?? true,
  );

  /// Version written with the settings. Bump it with every change to the
  /// format, with a migration from the previous one.
  static const schemaVersion = 1;

  /// The rules a new match starts with.
  final Rules rules;

  /// How long the bots take to move.
  final Pace pace;

  /// Whether the table says what your hand is worth.
  final bool handHelp;

  /// Whether the phone vibrates when your turn comes. Saved before it
  /// existed, it is on.
  final bool haptics;

  Settings copyWith({
    Rules? rules,
    Pace? pace,
    bool? handHelp,
    bool? haptics,
  }) => Settings(
    rules: rules ?? this.rules,
    pace: pace ?? this.pace,
    handHelp: handHelp ?? this.handHelp,
    haptics: haptics ?? this.haptics,
  );

  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'rules': rules.toJson(),
    'pace': pace.name,
    'handHelp': handHelp,
    'haptics': haptics,
  };
}

/// Keeps the settings and saves every change. A file it can't read is set
/// aside and the defaults are used.
final class SettingsController extends ChangeNotifier {
  SettingsController._(this._file, this._settings);

  factory SettingsController.inMemory([Settings settings = const Settings()]) =>
      SettingsController._(JsonFile.inMemory(), settings);

  static Future<SettingsController> open(JsonFile file) async {
    try {
      final json = await file.read();
      if (json != null && json['schemaVersion'] != Settings.schemaVersion) {
        throw FormatException('Unknown schema', json['schemaVersion']);
      }
      return SettingsController._(
        file,
        json == null ? const Settings() : Settings.fromJson(json),
      );
    } on Object {
      await file.setAside();
      return SettingsController._(file, const Settings());
    }
  }

  final JsonFile _file;
  Settings _settings;

  Settings get settings => _settings;

  set settings(Settings settings) {
    _settings = settings;
    unawaited(_saved = _file.write(settings.toJson()));
    notifyListeners();
  }

  Future<void> _saved = Future.value();

  /// Completes once the last change is written.
  Future<void> get saved => _saved;
}

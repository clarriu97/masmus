import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/controllers/match_controller.dart';
import 'package:masmus/controllers/settings_controller.dart';
import 'package:masmus/game/rules.dart';
import 'package:masmus/services/json_file.dart';

void main() {
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('settings_test_');
  });

  tearDown(() => directory.delete(recursive: true));

  JsonFile file() => JsonFile.at(File('${directory.path}/settings.json'));

  test('the defaults: the rulebooks\' rules, normal pace, hand help, '
      'vibration and sound on', () async {
    final settings = (await SettingsController.open(file())).settings;
    expect(settings.rules.kings, Kings.eight);
    expect(settings.rules.target, 40);
    expect(settings.pace, Pace.normal);
    expect(settings.handHelp, isTrue);
    expect(settings.haptics, isTrue);
    expect(settings.sound, isTrue);
  });

  test('every change is kept and there when the app opens again', () async {
    final controller = await SettingsController.open(file());
    var notified = 0;
    controller.addListener(() => notified++);
    controller.settings = const Settings(
      rules: Rules(kings: Kings.four, target: 30),
      pace: Pace.slow,
      handHelp: false,
      haptics: false,
      sound: false,
    );
    expect(notified, 1);
    await controller.saved;

    final reopened = (await SettingsController.open(file())).settings;
    expect(reopened.rules.kings, Kings.four);
    expect(reopened.rules.target, 30);
    expect(reopened.pace, Pace.slow);
    expect(reopened.handHelp, isFalse);
    expect(reopened.haptics, isFalse);
    expect(reopened.sound, isFalse);
  });

  test('settings saved before vibration and sound could be turned off keep '
      'them on', () async {
    File('${directory.path}/settings.json').writeAsStringSync(
      '{"schemaVersion": 1, "rules": ${_rules()}, "pace": "slow", '
      '"handHelp": false}',
    );
    final settings = (await SettingsController.open(file())).settings;
    expect(settings.pace, Pace.slow);
    expect(settings.haptics, isTrue);
    expect(settings.sound, isTrue);
  });

  for (final (what, contents) in [
    ('a damaged file', '{"schemaVersion": 1, "rules": '),
    ('a file from a newer version', '{"schemaVersion": 7}'),
  ]) {
    test('$what gives the defaults and is kept aside', () async {
      File('${directory.path}/settings.json').writeAsStringSync(contents);
      final settings = (await SettingsController.open(file())).settings;
      expect(settings.pace, Pace.normal);
      expect(
        directory.listSync().map((entry) => entry.path),
        contains(contains('settings.unreadable-')),
      );
    });
  }
}

String _rules() => jsonEncode(const Rules().toJson());

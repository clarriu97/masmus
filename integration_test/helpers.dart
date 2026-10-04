import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:masmus/controllers/match_controller.dart';
import 'package:masmus/controllers/settings_controller.dart';
import 'package:masmus/main.dart';
import 'package:masmus/services/json_file.dart';
import 'package:masmus/services/links.dart';
import 'package:masmus/services/match_store.dart';
import 'package:masmus/services/sounds.dart';

void setUpE2E() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
}

/// Starts the app the way `main()` does, with [store], or one in memory.
Future<void> launchApp(WidgetTester tester, {MatchStore? store}) async {
  await tester.pumpWidget(
    MasmusApp(
      links: Links(),
      store: store ?? MatchStore.inMemory(),
      settings: SettingsController.inMemory(const Settings(pace: Pace.fast)),
      sounds: Sounds(),
    ),
  );
  await tester.pumpAndSettle();
}

/// Kills and reopens the app: throws the whole widget tree away and opens
/// the match store in [directory] again, as `main()` does.
Future<void> relaunchApp(WidgetTester tester, Directory directory) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  // Lets the last write already in flight land, as it would on a phone.
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 300)),
  );
  final store = (await tester.runAsync(
    () => MatchStore.open(JsonFile.at(File('${directory.path}/match.json'))),
  ))!;
  await launchApp(tester, store: store);
}

/// Waits for [finder] to show (or, with [gone], to disappear), pumping frames
/// in real time: bots think and pause on a real clock.
Future<void> waitFor(
  WidgetTester tester,
  Finder finder, {
  bool gone = false,
  Duration timeout = const Duration(seconds: 20),
}) async {
  final end = DateTime.now().add(timeout);
  while (finder.evaluate().isEmpty != gone) {
    if (DateTime.now().isAfter(end)) {
      throw TestFailure('${gone ? 'Still showing' : 'Never showed'}: $finder');
    }
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Pumps frames in real time until [done] holds.
Future<void> waitUntil(
  WidgetTester tester,
  bool Function() done, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final end = DateTime.now().add(timeout);
  while (!done()) {
    if (DateTime.now().isAfter(end)) {
      throw TestFailure('Timed out waiting');
    }
    await tester.pump(const Duration(milliseconds: 100));
  }
}

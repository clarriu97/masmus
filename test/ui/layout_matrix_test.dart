// Every screen, in every relevant state, on every supported screen size,
// system text size and bold text. A RenderFlex overflow or any layout
// exception fails the test. At 100 % text, the accessibility guidelines must
// pass too.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/controllers/settings_controller.dart';
import 'package:masmus/services/match_store.dart';
import 'package:masmus/ui/settings/settings_screen.dart';
import 'package:masmus/ui/start/new_match_screen.dart';
import 'package:masmus/ui/start/start_screen.dart';
import 'package:masmus/ui/table/end_view.dart';

import '../helpers/devices.dart';
import '../helpers/table.dart';
import '../helpers/test_app.dart';

final Map<String, Widget Function()> _screens = {
  'start': () => StartScreen(
    store: MatchStore.inMemory(),
    settings: SettingsController.inMemory(),
    table: (partner, rules) => const SizedBox(),
    resume: (_) => const SizedBox(),
  ),
  'start with a match saved': () => StartScreen(
    store: MatchStore.inMemory(savedMatch()),
    settings: SettingsController.inMemory(),
    table: (partner, rules) => const SizedBox(),
    resume: (_) => const SizedBox(),
  ),
  'new match': () => NewMatchScreen(onStart: (partner, rules) {}),
  'settings': () => SettingsScreen(settings: SettingsController.inMemory()),
  for (final MapEntry(key: moment, value: controller) in tableMoments.entries)
    'table at $moment': () => tableScreen(controller()),
  for (final MapEntry(key: moment, value: controller) in countMoments.entries)
    'the $moment': () => tableScreen(controller()),
  for (final MapEntry(key: moment, value: controller) in endMoments.entries)
    'the $moment': () => EndView(
      match: controller().match,
      you: 0,
      onRematch: () {},
      onHome: () {},
    ),
};

void main() {
  for (final device in testDevices) {
    for (final scale in testTextScales) {
      for (final bold in [false, true]) {
        for (final MapEntry(key: name, value: screen) in _screens.entries) {
          final variant = '${(scale * 100).round()} %${bold ? ', bold' : ''}';
          testWidgets('$name on $device at $variant', (tester) async {
            device.apply(tester, textScale: scale);
            tester.platformDispatcher.accessibilityFeaturesTestValue =
                FakeAccessibilityFeatures(boldText: bold);
            await tester.pumpWidget(
              buildTestApp(screen(), platform: device.platform),
            );
            await tester.pumpAndSettle();
            if (scale == 1 && !bold) {
              await expectLater(
                tester,
                meetsGuideline(androidTapTargetGuideline),
              );
              await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
              await expectLater(
                tester,
                meetsGuideline(labeledTapTargetGuideline),
              );
              await expectLater(tester, meetsGuideline(textContrastGuideline));
            }
          });
        }
      }
    }
  }
}

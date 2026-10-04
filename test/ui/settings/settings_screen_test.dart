import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/controllers/match_controller.dart';
import 'package:masmus/controllers/settings_controller.dart';
import 'package:masmus/game/rules.dart';
import 'package:masmus/ui/settings/settings_screen.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('changing the defaults, the pace, the help, the vibration and '
      'the sound '
      'keeps each at once', (tester) async {
    final settings = SettingsController.inMemory();
    await tester.pumpWidget(buildTestApp(SettingsScreen(settings: settings)));
    expect(find.text('Ajustes'), findsOneWidget);
    expect(find.text('REGLAS POR DEFECTO'), findsOneWidget);
    expect(find.text('RITMO DE LOS BOTS'), findsOneWidget);

    await tester.tap(find.text('4 reyes'));
    await tester.tap(find.text('A 30'));
    await tester.tap(find.text('De 5'));
    await tester.ensureVisible(find.text('Sin señas'));
    await tester.tap(find.text('Sin señas'));
    await tester.tap(find.text('Rápido'));
    await tester.pump();
    await tester.tap(find.byType(Switch).first);
    for (final toggle in [1, 2]) {
      await tester.ensureVisible(find.byType(Switch).at(toggle));
      await tester.tap(find.byType(Switch).at(toggle));
    }
    await tester.pump();

    final chosen = settings.settings;
    expect(chosen.rules.kings, Kings.four);
    expect(chosen.rules.target, 30);
    expect(chosen.rules.games, 5);
    expect(chosen.rules.senas, isFalse);
    expect(
      chosen.rules.kings,
      Kings.four,
      reason: 'each change keeps the rest',
    );
    expect(chosen.pace, Pace.fast);
    expect(chosen.handHelp, isFalse);
    expect(chosen.haptics, isFalse);
    expect(chosen.sound, isFalse);
  });

  testWidgets('it shows what is chosen now', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        SettingsScreen(
          settings: SettingsController.inMemory(
            const Settings(
              pace: Pace.slow,
              handHelp: false,
              haptics: false,
              sound: false,
            ),
          ),
        ),
      ),
    );
    final pace = tester.widget<SegmentedButton<Pace>>(
      find.byType(SegmentedButton<Pace>),
    );
    expect(pace.selected, {Pace.slow});
    for (final toggle in tester.widgetList<Switch>(find.byType(Switch))) {
      expect(toggle.value, isFalse);
    }
  });
}

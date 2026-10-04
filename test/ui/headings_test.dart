import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/controllers/settings_controller.dart';
import 'package:masmus/services/match_store.dart';
import 'package:masmus/ui/help/how_to_play_screen.dart';
import 'package:masmus/ui/settings/settings_screen.dart';
import 'package:masmus/ui/start/new_match_screen.dart';
import 'package:masmus/ui/start/start_screen.dart';
import 'package:masmus/ui/table/end_view.dart';

import '../helpers/table.dart';
import '../helpers/test_app.dart';

/// Each screen and the headings a screen reader can jump between, read in
/// their own case even when drawn in capitals.
final Map<String, (Widget Function(), List<String>)> _screens = {
  'start': (
    () => StartScreen(
      store: MatchStore.inMemory(savedMatch()),
      settings: SettingsController.inMemory(),
      table: (partner, rules, rivals) => const SizedBox(),
      resume: (_) => const SizedBox(),
    ),
    ['Más Mus', 'Partida en curso'],
  ),
  'new match': (
    () => NewMatchScreen(onStart: (partner, rules, rivals) {}),
    ['Nueva partida', 'Tu compañero', 'Rivales'],
  ),
  'settings': (
    () => SettingsScreen(settings: SettingsController.inMemory()),
    ['Ajustes', 'Reglas por defecto', 'Ritmo de los bots'],
  ),
  'how to play': (() => const HowToPlayScreen(), ['Cómo se juega']),
  'count': (() => tableScreen(countMoments['count_juego']!()), ['Recuento']),
  'end': (
    () => EndView(
      match: endMoments['end_lost']!().match,
      you: 0,
      onRematch: () {},
      onHome: () {},
      onNextGame: () {},
    ),
    ['Ganan ellos'],
  ),
};

void main() {
  for (final MapEntry(key: name, value: (screen, headings))
      in _screens.entries) {
    testWidgets('the headings of $name', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildTestApp(screen()));
      await tester.pumpAndSettle();
      for (final heading in headings) {
        expect(
          tester.getSemantics(find.bySemanticsLabel(heading).first),
          isSemantics(label: heading, isHeader: true),
        );
      }
      handle.dispose();
    });
  }
}

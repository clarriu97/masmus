import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/bots/heuristic_bot.dart';
import 'package:masmus/controllers/settings_controller.dart';
import 'package:masmus/game/rules.dart';
import 'package:masmus/services/match_store.dart';
import 'package:masmus/ui/help/how_to_play_screen.dart';
import 'package:masmus/ui/settings/settings_screen.dart';
import 'package:masmus/ui/start/new_match_screen.dart';
import 'package:masmus/ui/start/start_screen.dart';

import '../../helpers/table.dart';
import '../../helpers/test_app.dart';

Finder _button(String label) =>
    find.ancestor(of: find.text(label), matching: find.byType(FilledButton));

void main() {
  late MatchStore store;
  late SettingsController settings;
  late (Personality, Rules)? started;
  late SavedMatch? resumed;

  Future<void> pump(WidgetTester tester, {SavedMatch? saved}) async {
    store = MatchStore.inMemory(saved);
    settings = SettingsController.inMemory(
      const Settings(rules: Rules(kings: Kings.four)),
    );
    started = null;
    resumed = null;
    await tester.pumpWidget(
      buildTestApp(
        StartScreen(
          store: store,
          settings: settings,
          table: (partner, rules, rivals) {
            started = (partner, rules);
            return const Text('mesa');
          },
          resume: (saved) {
            resumed = saved;
            return const Text('mesa guardada');
          },
        ),
      ),
    );
  }

  testWidgets('without a saved match: what the game is and «Nueva partida»', (
    tester,
  ) async {
    await pump(tester);
    expect(find.text('Más Mus'), findsOneWidget);
    expect(find.text('Tú y tu compañero contra dos rivales'), findsOneWidget);
    expect(find.text('PARTIDA EN CURSO'), findsNothing);
    expect(find.byType(FilledButton), findsOneWidget);
  });

  testWidgets('a new match is set up and then played at the table, which '
      'takes the place of the setup', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Nueva partida'));
    await tester.pumpAndSettle();
    expect(find.byType(NewMatchScreen), findsOneWidget);

    await tester.tap(find.text('Empezar partida'));
    await tester.pumpAndSettle();
    expect(find.text('mesa'), findsOneWidget);
    expect(started?.$1, Personality.calculador);
    expect(started?.$2.kings, Kings.four, reason: 'the default of Ajustes');

    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    expect(find.byType(StartScreen), findsOneWidget);
  });

  testWidgets('a saved match shows first: score, rules, hand and partner, '
      'and «Continuar» resumes it', (tester) async {
    await pump(tester, saved: savedMatch());
    expect(find.text('PARTIDA EN CURSO'), findsOneWidget);
    expect(find.text('Nosotros 23 · Ellos 31'), findsOneWidget);
    expect(
      find.text('8 reyes · a 40 · mano 12 · con El Calculador'),
      findsOneWidget,
    );
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('mesa guardada'), findsOneWidget);
    expect(resumed?.match.handNumber, 12);
  });

  testWidgets('starting another match over a saved one asks first; '
      'cancelling keeps it', (tester) async {
    await pump(tester, saved: savedMatch());
    await tester.tap(find.text('Nueva partida'));
    await tester.pumpAndSettle();
    await tester.tap(_button('Empezar partida'));
    await tester.pumpAndSettle();
    expect(find.text('¿Empezar otra partida?'), findsOneWidget);
    expect(find.text('La partida en curso se pierde.'), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(started, isNull);
    expect(store.saved, isNotNull);
  });

  testWidgets('confirming drops the saved match and starts the new one', (
    tester,
  ) async {
    await pump(tester, saved: savedMatch());
    await tester.tap(find.text('Nueva partida'));
    await tester.pumpAndSettle();
    await tester.tap(_button('Empezar partida'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Empezar otra'));
    await tester.pumpAndSettle();
    expect(started, isNotNull);
    expect(store.saved, isNull);
    expect(find.text('mesa'), findsOneWidget);
  });

  testWidgets('back from the table, the start shows what is saved now', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(find.text('Nueva partida'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Empezar partida'));
    await tester.pumpAndSettle();
    await store.save(savedMatch());
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    expect(find.text('PARTIDA EN CURSO'), findsOneWidget);
  });

  testWidgets('«Ajustes» opens the settings', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Ajustes'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  testWidgets('«Cómo se juega» opens how to play', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Cómo se juega'));
    await tester.pumpAndSettle();
    expect(find.byType(HowToPlayScreen), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/bots/heuristic_bot.dart';
import 'package:masmus/game/rules.dart';
import 'package:masmus/ui/start/new_match_screen.dart';
import 'package:masmus/ui/start/start_screen.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('says what the game is, and nothing that does not work', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(StartScreen(table: (partner, rules) => const Text('mesa'))),
    );
    expect(find.text('Más Mus'), findsOneWidget);
    expect(find.text('Tú y tu compañero contra dos rivales'), findsOneWidget);
    expect(find.byType(TextButton), findsNothing);
    expect(find.byType(FilledButton), findsOneWidget);
  });

  testWidgets('a new match is set up and then played at the table, which '
      'takes the place of the setup', (tester) async {
    (Personality, Rules)? started;
    await tester.pumpWidget(
      buildTestApp(
        StartScreen(
          table: (partner, rules) {
            started = (partner, rules);
            return const Text('mesa');
          },
        ),
      ),
    );
    await tester.tap(find.text('Nueva partida'));
    await tester.pumpAndSettle();
    expect(find.byType(NewMatchScreen), findsOneWidget);

    await tester.tap(find.text('Empezar partida'));
    await tester.pumpAndSettle();
    expect(find.text('mesa'), findsOneWidget);
    expect(started?.$1, Personality.calculador);
    expect(started?.$2.kings, Kings.eight);
    expect(started?.$2.target, 40);

    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    expect(find.byType(StartScreen), findsOneWidget);
  });
}

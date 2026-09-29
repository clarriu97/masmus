import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/bots/heuristic_bot.dart';
import 'package:masmus/game/rules.dart';
import 'package:masmus/ui/start/new_match_screen.dart';
import 'package:masmus/ui/widgets/choice_tile.dart';

import '../../helpers/test_app.dart';

void main() {
  late (Personality, Rules)? started;

  Future<void> pump(WidgetTester tester) async {
    started = null;
    await tester.pumpWidget(
      buildTestApp(
        NewMatchScreen(onStart: (partner, rules) => started = (partner, rules)),
      ),
    );
  }

  ChoiceTile tile(WidgetTester tester, String name) => tester.widget(
    find.ancestor(of: find.text(name), matching: find.byType(ChoiceTile)),
  );

  testWidgets('one tap starts with the defaults: El Calculador, 8 reyes, '
      'a 40', (tester) async {
    await pump(tester);
    expect(tile(tester, 'El Calculador').selected, isTrue);
    for (final other in ['El Prudente', 'La Temeraria', 'El Farolero']) {
      expect(tile(tester, other).selected, isFalse);
    }
    await tester.tap(find.text('Empezar partida'));
    expect(started?.$1, Personality.calculador);
    expect(started?.$2.kings, Kings.eight);
    expect(started?.$2.target, 40);
    expect(started?.$2.games, 1, reason: 'one juego');
    expect(started?.$2.senas, isTrue, reason: 'with señas');
  });

  testWidgets('each partner says how it plays', (tester) async {
    await pump(tester);
    for (final line in [
      'Envida con buena mano; casi no farolea',
      'Quiere casi todo; le gusta el órdago',
      'Juega las probabilidades',
      'Envida sin nada cuando puede',
    ]) {
      expect(find.text(line), findsOneWidget);
    }
  });

  testWidgets('the partner and the rules can be changed', (tester) async {
    await pump(tester);
    await tester.tap(find.text('La Temeraria'));
    await tester.tap(find.text('4 reyes'));
    await tester.tap(find.text('A 30'));
    await tester.ensureVisible(find.text('De 3'));
    await tester.tap(find.text('De 3'));
    await tester.ensureVisible(find.text('Sin señas'));
    await tester.tap(find.text('Sin señas'));
    await tester.pump();
    expect(tile(tester, 'La Temeraria').selected, isTrue);
    expect(tile(tester, 'El Calculador').selected, isFalse);

    await tester.tap(find.text('Empezar partida'));
    expect(started?.$1, Personality.temeraria);
    expect(started?.$2.kings, Kings.four);
    expect(started?.$2.target, 30);
    expect(started?.$2.games, 3);
    expect(started?.$2.senas, isFalse);
  });

  testWidgets('screen readers hear which partner is chosen', (tester) async {
    await pump(tester);
    expect(
      tester.getSemantics(
        find.ancestor(
          of: find.text('El Calculador'),
          matching: find.byType(ChoiceTile),
        ),
      ),
      matchesSemantics(
        label: 'El Calculador\nJuega las probabilidades',
        isButton: true,
        hasTapAction: true,
        hasFocusAction: true,
        isFocusable: true,
        hasSelectedState: true,
        isSelected: true,
      ),
    );
  });

  testWidgets('with large text the partners go one to a row', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    await pump(tester);
    final prudente = tester.getTopLeft(find.text('El Prudente'));
    final temeraria = tester.getTopLeft(find.text('La Temeraria'));
    expect(temeraria.dx, prudente.dx);
    expect(temeraria.dy, greaterThan(prudente.dy));
  });
}

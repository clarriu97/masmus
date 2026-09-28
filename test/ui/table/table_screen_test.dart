import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/game/move.dart';
import 'package:masmus/ui/cards/playing_card_view.dart';
import 'package:masmus/ui/table/seat.dart';
import 'package:masmus/ui/widgets/lance_chip.dart';

import '../../helpers/table.dart';
import '../../helpers/test_app.dart';

Seat _seat(WidgetTester tester, String name) => tester.widget(
  find.ancestor(of: find.text(name), matching: find.byType(Seat)),
);

void main() {
  testWidgets('each bot sits where it plays, and your cards are face up', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp(tableScreen(tableMoments['mus']!())));
    expect(find.text('El Calculador'), findsOneWidget);
    expect(_seat(tester, 'El Calculador').role, 'compañero');
    expect(_seat(tester, 'El Prudente').role, 'rival');
    expect(_seat(tester, 'La Temeraria').role, 'rival · postre');
    final cards = tester.widgetList<PlayingCardView>(
      find.byType(PlayingCardView),
    );
    expect(cards.where((card) => card.faceUp), hasLength(4));
    expect(cards.where((card) => !card.faceUp), hasLength(12));
  });

  testWidgets('the row of the hand, what your hand is worth and that you '
      'are mano', (tester) async {
    await tester.pumpWidget(buildTestApp(tableScreen(tableMoments['mus']!())));
    for (final step in ['Mus', 'Grande', 'Chica', 'Pares', 'Juego']) {
      expect(find.widgetWithText(LanceChip, step), findsOneWidget);
    }
    expect(find.text('corrido'), findsOneWidget);
    expect(find.text('Mano'), findsOneWidget);
    expect(find.text('Par de reyes'), findsOneWidget);
    expect(find.text('Punto 26'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Mus. Te toca. En la mesa: Nada'),
      findsOneWidget,
    );
  });

  testWidgets('a bet shows by its bettor and on the table, and the bot '
      'whose turn it is is marked', (tester) async {
    await tester.pumpWidget(
      buildTestApp(tableScreen(tableMoments['grande_envite']!())),
    );
    expect(_seat(tester, 'El Prudente').said, 'Envido 2');
    expect(_seat(tester, 'El Calculador').thinking, isTrue);
    expect(_seat(tester, 'El Prudente').thinking, isFalse);
    expect(find.text('envite 2'), findsOneWidget);
    expect(find.text('Turno de El Calculador'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Grande. Turno de El Calculador. En la mesa: 2'),
      findsOneWidget,
    );
  });

  testWidgets('a lance over keeps its result in the row', (tester) async {
    await tester.pumpWidget(
      buildTestApp(tableScreen(tableMoments['chica_answer']!())),
    );
    expect(find.text('Nosotros +1'), findsOneWidget);
    expect(find.text('envite 5'), findsOneWidget);
    expect(_seat(tester, 'La Temeraria').said, 'Envido 5');
  });

  testWidgets('the table follows the match as it is played', (tester) async {
    final controller = tableMoments['mus']!();
    await tester.pumpWidget(buildTestApp(tableScreen(controller)));
    controller.play(const NoHayMus());
    await tester.pump();
    expect(find.text('cortado'), findsOneWidget);
    expect(find.text('te toca'), findsOneWidget);
  });

  testWidgets('Salir leaves the table', (tester) async {
    var left = false;
    await tester.pumpWidget(
      buildTestApp(
        tableScreen(tableMoments['mus']!(), onExit: () => left = true),
      ),
    );
    await tester.tap(find.text('Salir'));
    expect(left, isTrue);
  });

  testWidgets('a screen reader hears each bot with what it said', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(tableScreen(tableMoments['grande_envite']!())),
    );
    expect(
      find.bySemanticsLabel('El Prudente. rival · mano. Envido 2'),
      findsOneWidget,
    );
  });
}

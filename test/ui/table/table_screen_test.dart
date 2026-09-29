import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/controllers/match_controller.dart';
import 'package:masmus/game/event.dart';
import 'package:masmus/game/move.dart';
import 'package:masmus/services/scheduler.dart';
import 'package:masmus/ui/cards/deck_view.dart';
import 'package:masmus/ui/cards/playing_card_view.dart';
import 'package:masmus/ui/table/count_view.dart';
import 'package:masmus/ui/table/hand_history.dart';
import 'package:masmus/ui/table/seat.dart';
import 'package:masmus/ui/widgets/lance_chip.dart';
import 'package:masmus/ui/widgets/speech_bubble.dart';
import 'package:masmus/ui/widgets/table_chip.dart';

import '../../helpers/devices.dart';
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
      find.byWidgetPredicate(
        (widget) =>
            widget is PlayingCardView &&
            find
                .ancestor(
                  of: find.byWidget(widget),
                  matching: find.byType(DeckView),
                )
                .evaluate()
                .isEmpty,
      ),
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
    expect(find.widgetWithText(LanceChip, 'corrido'), findsOneWidget);
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
    catchUp(controller);
    await tester.pump();
    expect(find.text('cortado'), findsOneWidget);
    expect(find.text('te toca'), findsOneWidget);
  });

  testWidgets('the count waits until the table has shown how the hand '
      'ended', (tester) async {
    final controller = tableController(
      hands: const {0: 'R 6 5 4', 1: 'S 7 6 1', 2: '4 5 6 7', 3: '4 5 1 7'},
      mano: 1,
      moves: [
        (1, const NoHayMus()),
        ...passes(1),
        ...passes(1),
        ...passes(1).take(3),
      ],
    );
    await tester.pumpWidget(buildTestApp(tableScreen(controller)));
    controller.play(const Paso());
    await tester.pump();
    expect(find.byType(CountView), findsNothing);
    expect(find.text('Paso'), findsWidgets);

    catchUp(controller);
    await tester.pump();
    expect(find.byType(CountView), findsOneWidget);
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

  testWidgets('the bot whose turn it is shows three dots, and a screen '
      'reader hears it is thinking', (tester) async {
    await tester.pumpWidget(
      buildTestApp(tableScreen(tableMoments['grande_envite']!())),
    );
    expect(
      find.descendant(
        of: find.ancestor(
          of: find.text('El Calculador'),
          matching: find.byType(Seat),
        ),
        matching: find.byType(ThinkingBubble),
      ),
      findsOneWidget,
    );
    expect(find.byType(ThinkingBubble), findsOneWidget);
    expect(
      find.bySemanticsLabel('El Calculador. compañero. pensando'),
      findsOneWidget,
    );
  });

  testWidgets('on your turn it says so by your cards; once you speak, what '
      'you said stays there', (tester) async {
    final controller = tableMoments['mus']!();
    await tester.pumpWidget(buildTestApp(tableScreen(controller)));
    expect(find.widgetWithText(TableChip, 'Te toca'), findsOneWidget);
    controller.play(const Mus());
    await tester.pump();
    expect(find.widgetWithText(TableChip, 'Te toca'), findsNothing);
    expect(find.widgetWithText(SpeechBubble, 'Mus'), findsOneWidget);
  });

  testWidgets('the middle of the table shows the lance and what is bet, and '
      'how a lance went while the table holds it', (tester) async {
    testDevices[2].apply(tester);
    await tester.pumpWidget(
      buildTestApp(tableScreen(tableMoments['grande_envite']!())),
    );
    expect(find.text('GRANDE'), findsOneWidget);
    expect(find.text('2'), findsWidgets);

    final scheduler = ManualScheduler();
    final controller = tableController(
      hands: const {0: 'R 6 5 4', 1: 'S 7 6 1', 2: '4 5 6 7', 3: '4 5 1 7'},
      mano: 1,
      moves: [(1, const NoHayMus()), ...passes(1).take(3)],
      scheduler: scheduler,
    );
    await tester.pumpWidget(buildTestApp(tableScreen(controller)));
    controller.play(const Paso());
    scheduler.advance(Pace.normal.hold(const PasoSaid(0)));
    await tester.pump();
    expect(find.text('GRANDE'), findsOneWidget);
    expect(find.text('en paso'), findsWidgets);
    catchUp(controller);
    await tester.pump();
    expect(find.text('CHICA'), findsOneWidget);
  });

  testWidgets('what has happened in the hand, as a conversation, a tap away', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(tableScreen(tableMoments['chica_answer']!())),
    );
    await tester.tap(find.byTooltip('Lo que va de mano'));
    await tester.pumpAndSettle();
    final sheet = find.byType(HandHistory);
    for (final line in [
      'La Temeraria: No hay mus',
      'La Temeraria: Paso',
      'Tú: Envido 2',
      'El Prudente: Decide su compañero',
      'La Temeraria: No quiero',
      '→ Nosotros +1',
      'La Temeraria: Envido 5',
    ]) {
      expect(
        find.descendant(of: sheet, matching: find.text(line)),
        findsOneWidget,
        reason: line,
      );
    }
    for (final step in ['Mus', 'Grande', 'Chica']) {
      expect(find.descendant(of: sheet, matching: find.text(step)), findsOne);
    }
  });

  testWidgets('the deck sits by the mano, on the side of the postre', (
    tester,
  ) async {
    Iterable<Element> shownDecks() => find
        .byType(DeckView)
        .evaluate()
        .where(
          (deck) =>
              deck.findAncestorWidgetOfExactType<Visibility>()?.visible ?? true,
        );

    await tester.pumpWidget(buildTestApp(tableScreen(tableMoments['mus']!())));
    expect(shownDecks(), hasLength(1));
    expect(
      find.ancestor(
        of: find.byWidget(shownDecks().single.widget),
        matching: find.byType(Seat),
      ),
      findsNothing,
      reason: 'you are mano: the deck is by your cards',
    );

    await tester.pumpWidget(
      buildTestApp(tableScreen(tableMoments['grande_envite']!())),
    );
    expect(shownDecks(), hasLength(1));
    expect(_seat(tester, 'El Prudente').deck, AxisDirection.left);
    expect(_seat(tester, 'El Calculador').deck, isNull);
  });
}

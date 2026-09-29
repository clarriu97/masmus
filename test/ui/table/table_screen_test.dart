import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:masmus/ui/theme/app_theme.dart';
import 'package:masmus/ui/widgets/cut_badge.dart';
import 'package:masmus/ui/widgets/lance_chip.dart';
import 'package:masmus/ui/widgets/mano_token.dart';
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
    expect(find.byType(ManoToken), findsOneWidget);
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
    expect(find.byType(ManoToken), findsOneWidget);
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
      find.bySemanticsLabel('El Prudente. rival. mano. cortó el mus. Envido 2'),
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
      find.bySemanticsLabel('El Calculador. compañero. Seña: Ciego. pensando'),
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

  testWidgets('the mano carries its token, and the deck sits on the table '
      'between the postre and the mano', (tester) async {
    testDevices[2].apply(tester);
    await tester.pumpWidget(buildTestApp(tableScreen(tableMoments['mus']!())));
    await tester.pump();
    expect(find.byType(ManoToken), findsOneWidget);
    expect(
      find.ancestor(of: find.byType(ManoToken), matching: find.byType(Seat)),
      findsNothing,
      reason: 'you are mano: the token is by your cards',
    );
    expect(find.text('Mus corrido: quien corte será mano'), findsOneWidget);

    await tester.pumpWidget(
      buildTestApp(tableScreen(tableMoments['grande_envite']!())),
    );
    await tester.pump();
    expect(_seat(tester, 'El Prudente').mano, isTrue);
    expect(_seat(tester, 'El Calculador').mano, isFalse);
    expect(find.byType(ManoToken), findsOneWidget);
    expect(find.text('Mus corrido: quien corte será mano'), findsNothing);
    final deck = tester.getCenter(find.byType(DeckView));
    final mano = tester.getCenter(
      find
          .descendant(
            of: find.ancestor(
              of: find.text('El Prudente'),
              matching: find.byType(Seat),
            ),
            matching: find.byType(PlayingCardView),
          )
          .first,
    );
    final yours = tester.getCenter(
      find
          .byWidgetPredicate(
            (widget) => widget is PlayingCardView && widget.faceUp,
          )
          .first,
    );
    expect(deck.dy, inExclusiveRange(mano.dy, yours.dy));
    expect(
      find.bySemanticsLabel(RegExp('^El Prudente. rival. mano')),
      findsOneWidget,
    );
  });

  testWidgets('who cut the mus says so, and the middle of the table says it '
      'is cut, longer than a word', (tester) async {
    testDevices[2].apply(tester);
    final controller = tableMoments['mus']!();
    await tester.pumpWidget(buildTestApp(tableScreen(controller)));
    controller.play(const NoHayMus());
    await tester.pump();
    expect(find.widgetWithText(SpeechBubble, 'No hay mus'), findsOneWidget);
    expect(find.text('MUS'), findsOneWidget);
    expect(find.text('cortado'), findsWidgets);
    expect(
      Pace.normal.hold(const NoHayMusSaid(0)),
      Pace.normal.hold(const HandEnded()),
    );
    catchUp(controller);
    await tester.pump();
    expect(find.text('GRANDE'), findsOneWidget);
  });

  testWidgets('whoever has the floor stands out: the others step back and '
      'the arrow in the middle points at them', (tester) async {
    testDevices[2].apply(tester);
    await tester.pumpWidget(
      buildTestApp(tableScreen(tableMoments['grande_envite']!())),
    );
    await tester.pumpAndSettle();
    expect(_seat(tester, 'El Calculador').dimmed, isFalse);
    expect(_seat(tester, 'El Prudente').dimmed, isTrue);
    expect(_seat(tester, 'La Temeraria').dimmed, isTrue);
    final arrow = tester.widget<AnimatedRotation>(
      find.ancestor(
        of: find.byIcon(Icons.arrow_upward),
        matching: find.byType(AnimatedRotation),
      ),
    );
    expect(arrow.turns, 0, reason: 'your partner, across the table');
  });

  testWidgets('while a word is shown, it is its speaker who has the floor', (
    tester,
  ) async {
    testDevices[2].apply(tester);
    final controller = tableMoments['mus']!();
    await tester.pumpWidget(buildTestApp(tableScreen(controller)));
    controller.play(const NoHayMus());
    await tester.pumpAndSettle();
    for (final name in ['El Prudente', 'El Calculador', 'La Temeraria']) {
      expect(_seat(tester, name).dimmed, isTrue, reason: name);
    }
    final arrow = tester.widget<AnimatedRotation>(
      find.byType(AnimatedRotation),
    );
    expect(arrow.turns, 0.5, reason: 'you, just below');
  });

  testWidgets('your turn frames your cards in brass and the phone vibrates', (
    tester,
  ) async {
    final haptics = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          haptics.add(call.arguments as String);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    final controller = tableMoments['mus']!();
    await tester.pumpWidget(buildTestApp(tableScreen(controller)));
    expect(haptics, ['HapticFeedbackType.mediumImpact']);
    bool framed() => tester
        .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
        .any(
          (box) =>
              (box.decoration as BoxDecoration?)?.border ==
              Border.all(color: AppColors.turn, width: 2),
        );
    expect(framed(), isTrue);
    controller.play(const Mus());
    await tester.pump();
    expect(framed(), isFalse);
    expect(haptics, hasLength(1), reason: 'only when your turn comes');
  });

  testWidgets('who cut the mus keeps the scissors and «cortó el mus» for the '
      'rest of the hand', (tester) async {
    await tester.pumpWidget(
      buildTestApp(tableScreen(tableMoments['chica_answer']!())),
    );
    expect(_seat(tester, 'La Temeraria').cut, isTrue);
    expect(_seat(tester, 'El Prudente').cut, isFalse);
    expect(find.byType(CutBadge), findsOneWidget);
    expect(find.text('cortó el mus'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('La Temeraria.*cortó el mus')),
      findsOneWidget,
    );

    final controller = tableMoments['mus']!();
    await tester.pumpWidget(buildTestApp(tableScreen(controller)));
    expect(find.byType(CutBadge), findsNothing);
    controller.play(const NoHayMus());
    await tester.pump();
    expect(find.byType(CutBadge), findsOneWidget, reason: 'at once, by you');
    catchUp(controller);
    await tester.pump();
    expect(find.byType(CutBadge), findsOneWidget);
    expect(find.bySemanticsLabel('Cortaste el mus'), findsOneWidget);
  });

  testWidgets('your partner\'s señas show on its seat, and yours by your '
      'cards; none during mus corrido', (tester) async {
    await tester.pumpWidget(
      buildTestApp(tableScreen(tableMoments['grande_envite']!())),
    );
    expect(_seat(tester, 'El Calculador').senas, 'Seña: Ciego');
    expect(_seat(tester, 'El Prudente').senas, isNull, reason: 'a rival');
    expect(find.text('Tu seña: Duples'), findsOneWidget);

    await tester.pumpWidget(buildTestApp(tableScreen(tableMoments['mus']!())));
    expect(_seat(tester, 'El Calculador').senas, isNull);
    expect(find.textContaining('Tu seña'), findsNothing);
  });
}

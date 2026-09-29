import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/bots/heuristic_bot.dart';
import 'package:masmus/game/match.dart';
import 'package:masmus/game/move.dart';
import 'package:masmus/game/rules.dart';
import 'package:masmus/services/scheduler.dart';
import 'package:masmus/ui/table/count_view.dart';
import 'package:masmus/ui/table/end_view.dart';
import 'package:masmus/ui/table/seat.dart';
import 'package:masmus/ui/table/table_page.dart';
import 'package:masmus/ui/table/table_screen.dart';

import '../../helpers/table.dart';
import '../../helpers/test_app.dart';

Widget _end(
  MatchState match, {
  VoidCallback? onRematch,
  VoidCallback? onHome,
  VoidCallback? onNextGame,
}) => buildTestApp(
  EndView(
    match: match,
    you: 0,
    onRematch: onRematch ?? () {},
    onHome: onHome ?? () {},
    onNextGame: onNextGame ?? () {},
  ),
);

void main() {
  testWidgets('a match won in the count: who won, the final score and how '
      'it went', (tester) async {
    await tester.pumpWidget(_end(endMoments['end_won']!().match));
    expect(find.text('¡Ganáis la partida!'), findsOneWidget);
    expect(find.text('40'), findsOneWidget);
    expect(find.text('37'), findsOneWidget);
    expect(find.text('Una mano · a los tantos'), findsOneWidget);
  });

  testWidgets('a match lost to an órdago says so', (tester) async {
    await tester.pumpWidget(_end(endMoments['end_lost']!().match));
    expect(find.text('Ganan ellos'), findsOneWidget);
    expect(find.text('Una mano · con un órdago'), findsOneWidget);
  });

  testWidgets('a rematch, or back to the start', (tester) async {
    var rematch = 0;
    var home = 0;
    await tester.pumpWidget(
      _end(
        endMoments['end_won']!().match,
        onRematch: () => rematch++,
        onHome: () => home++,
      ),
    );
    await tester.tap(find.text('Revancha'));
    await tester.tap(find.text('Volver al inicio'));
    expect((rematch, home), (1, 1));
  });

  testWidgets('the last count leads to the end of the match', (tester) async {
    await tester.pumpWidget(
      buildTestApp(tableScreen(endMoments['end_won']!())),
    );
    expect(find.byType(CountView), findsOneWidget);
    await tester.tap(find.text('Ver el final'));
    await tester.pump();
    expect(find.byType(EndView), findsOneWidget);
  });

  testWidgets('the rematch keeps the bots and the rules and deals again', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        TablePage(
          partner: Personality.prudente,
          rules: const Rules(target: 30),
          seed: 5,
          scheduler: ManualScheduler(),
        ),
      ),
    );
    final bots = [
      for (final seat in tester.widgetList<Seat>(find.byType(Seat))) seat.name,
    ];
    final first = tester.widget<TableScreen>(find.byType(TableScreen));
    first.onRematch();
    await tester.pump();
    final second = tester.widget<TableScreen>(find.byType(TableScreen));
    expect(second.controller, isNot(same(first.controller)));
    expect(second.controller.match.rules.target, 30);
    expect(second.controller.match.scoreNow, [0, 0]);
    expect([
      for (final seat in tester.widgetList<Seat>(find.byType(Seat))) seat.name,
    ], bots);
  });

  testWidgets('a juego won in a match of three: how the match stands, and '
      'the next juego instead of a rematch', (tester) async {
    var next = false;
    await tester.pumpWidget(
      _end(endMoments['end_game']!().match, onNextGame: () => next = true),
    );
    expect(find.text('Juego para vosotros'), findsOneWidget);
    expect(
      find.text('Juegos: Nosotros 1 · Ellos 0 · al mejor de 3'),
      findsOneWidget,
    );
    expect(find.text('Revancha'), findsNothing);
    await tester.tap(find.text('Siguiente juego'));
    expect(next, isTrue);
  });

  testWidgets('the juego that wins a match of three ends it', (tester) async {
    final match = tableController(
      hands: const {0: '1 4 5 6', 1: 'R R C C', 2: '1 5 6 7', 3: 'R C S 7'},
      score: const [38, 36],
      rules: const Rules(games: 3),
      games: const [1, 1],
      moves: [
        (0, const NoHayMus()),
        ...passes(0),
        (0, const Envido(2)),
        (1, const Quiero()),
      ],
      finish: true,
    ).match;
    await tester.pumpWidget(_end(match));
    expect(find.text('¡Ganáis la partida!'), findsOneWidget);
    expect(
      find.text('Juegos: Nosotros 2 · Ellos 1 · al mejor de 3'),
      findsOneWidget,
    );
    expect(find.text('Revancha'), findsOneWidget);
  });

  testWidgets('«Siguiente juego» at the table deals the next juego from zero', (
    tester,
  ) async {
    final scheduler = ManualScheduler();
    final controller = tableController(
      hands: const {0: '1 4 5 6', 1: 'R R C C', 2: '1 5 6 7', 3: 'R C S 7'},
      score: const [38, 36],
      rules: const Rules(games: 3),
      moves: [
        (0, const NoHayMus()),
        ...passes(0),
        (0, const Envido(2)),
        (1, const Quiero()),
      ],
      finish: true,
      scheduler: scheduler,
    );
    await tester.pumpWidget(buildTestApp(tableScreen(controller)));
    await tester.tap(find.text('Ver el final'));
    await tester.pump();
    await tester.tap(find.text('Siguiente juego'));
    await tester.pump();
    expect(controller.match.games, [1, 0]);
    expect(controller.match.score, [0, 0]);
    expect(controller.dealing, isNotNull);
    expect(find.byType(TableScreen), findsOneWidget);
    expect(find.text('juegos 1–0'), findsOneWidget);
    expect(find.text('Mus corrido: quien corte será mano'), findsOneWidget);
  });
}

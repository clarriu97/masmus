import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/bots/heuristic_bot.dart';
import 'package:masmus/game/match.dart';
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
}) => buildTestApp(
  EndView(
    match: match,
    you: 0,
    onRematch: onRematch ?? () {},
    onHome: onHome ?? () {},
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
}

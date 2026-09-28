import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/ui/widgets/score_board.dart';

import '../../helpers/test_app.dart';

Finder _stones({required bool big}) =>
    find.byWidgetPredicate((widget) => widget is Stone && widget.big == big);

void main() {
  for (final (points, big, small) in [
    (0, 0, 0),
    (4, 0, 4),
    (5, 1, 0),
    (12, 2, 2),
    (39, 7, 4),
    (40, 8, 0),
  ]) {
    testWidgets('$points tantos are $big amarracos and $small stones', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp(Amarracos(points)));
      expect(_stones(big: true), findsNWidgets(big));
      expect(_stones(big: false), findsNWidgets(small));
    });
  }

  testWidgets('each team shows its name in capitals, figures and stones', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        const ScoreBoard(
          usLabel: 'Nosotros',
          us: 12,
          themLabel: 'Ellos',
          them: 20,
        ),
      ),
    );
    expect(find.text('NOSOTROS'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('ELLOS'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);
    expect(_stones(big: true), findsNWidgets(2 + 4));
    expect(_stones(big: false), findsNWidgets(2));
  });

  testWidgets('a screen reader hears each team with its tantos', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        const ScoreBoard(
          usLabel: 'Nosotros',
          us: 12,
          themLabel: 'Ellos',
          them: 20,
        ),
      ),
    );
    expect(find.bySemanticsLabel('NOSOTROS\n12'), findsOneWidget);
    expect(find.bySemanticsLabel('ELLOS\n20'), findsOneWidget);
  });
}

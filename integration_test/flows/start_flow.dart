import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/widgets/mus_table.dart';

import '../helpers.dart';

void startFlows() {
  testWidgets('from opening the app to the table of a new match', (
    tester,
  ) async {
    await launchApp(tester);
    expect(find.text('Más Mus'), findsOneWidget);
    await tester.tap(find.text('Nueva partida'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Empezar partida'));
    await waitFor(tester, find.byType(MusTable));
  });
}

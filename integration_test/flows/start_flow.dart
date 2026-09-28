import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/widgets/mus_table.dart';

import '../helpers.dart';

void startFlows() {
  testWidgets('from opening the app to the table of a new match', (
    tester,
  ) async {
    await launchApp(tester);
    await tester.tap(find.text('Explorar como invitado'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('JUGAR'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('El Calculador'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Comenzar Partida'));
    await waitFor(tester, find.byType(MusTable));
  });
}

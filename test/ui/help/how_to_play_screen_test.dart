import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/ui/help/how_to_play_screen.dart';

import '../../helpers/table.dart';
import '../../helpers/test_app.dart';

void main() {
  testWidgets('tells the rules for playing, why the deal is fair and what '
      'the words mean', (tester) async {
    await tester.pumpWidget(buildTestApp(const HowToPlayScreen()));
    for (final title in [
      'Cómo se juega',
      'Lo básico',
      'Las cartas',
      'Mano y postre',
      'Mus o no hay mus',
      'Los cuatro lances',
      'Envidar',
      'El recuento',
      'Reparto limpio',
      'Glosario',
    ]) {
      await tester.scrollUntilVisible(find.text(title), 200);
      expect(find.text(title), findsOneWidget);
    }
    for (final term in ['Mano', 'Órdago', 'La 31', 'Amarracos']) {
      await tester.scrollUntilVisible(find.text(term), 200);
      expect(find.text(term), findsOneWidget);
    }
  });

  testWidgets('the examples are the ones the engine agrees with', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp(const HowToPlayScreen()));
    await tester.scrollUntilVisible(find.textContaining('R-R-7-4'), 200);
    expect(find.textContaining('R-R-7-4 gana a R-C-C-C'), findsOneWidget);
    expect(find.textContaining('1-1-4-5 gana a 1-4-5-6'), findsOneWidget);
  });

  testWidgets('the table opens it from «?»', (tester) async {
    await tester.pumpWidget(buildTestApp(tableScreen(tableMoments['mus']!())));
    await tester.tap(find.byTooltip('Cómo se juega'));
    await tester.pumpAndSettle();
    expect(find.byType(HowToPlayScreen), findsOneWidget);
    await tester.tap(find.text('Volver'));
    await tester.pumpAndSettle();
    expect(find.byType(HowToPlayScreen), findsNothing);
  });
}

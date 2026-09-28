import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/main.dart';

void main() {
  testWidgets('the app opens on the start screen, in Spanish', (tester) async {
    await tester.pumpWidget(const MasmusApp());
    expect(find.text('Más Mus'), findsOneWidget);

    await tester.tap(find.text('Nueva partida'));
    await tester.pumpAndSettle();
    expect(find.text('TU COMPAÑERO'), findsOneWidget);
    expect(find.text('Empezar partida'), findsOneWidget);
  });
}

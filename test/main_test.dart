import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/controllers/settings_controller.dart';
import 'package:masmus/main.dart';
import 'package:masmus/services/match_store.dart';

void main() {
  testWidgets('the app opens on the start screen, in Spanish', (tester) async {
    await tester.pumpWidget(
      MasmusApp(
        store: MatchStore.inMemory(),
        settings: SettingsController.inMemory(),
      ),
    );
    expect(find.text('Más Mus'), findsOneWidget);

    await tester.tap(find.text('Nueva partida'));
    await tester.pumpAndSettle();
    expect(find.text('TU COMPAÑERO'), findsOneWidget);
    expect(find.text('Empezar partida'), findsOneWidget);
  });
}

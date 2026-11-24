import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/ui/table/table_screen.dart';
import 'package:masmus/ui/widgets/speech_bubble.dart';

import '../helpers.dart';

void startFlows() {
  testWidgets('from opening the app to the table of a new match, whose '
      'cards are dealt before anyone speaks', (tester) async {
    await launchApp(tester);
    expect(find.text('Más Mus'), findsOneWidget);
    await tester.tap(find.text('Nueva partida'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Empezar partida'));
    await waitFor(tester, find.byType(TableScreen));
    final controller = tester
        .widget<TableScreen>(find.byType(TableScreen))
        .controller;
    final someoneSpeaks = find.byWidgetPredicate(
      (widget) =>
          widget is ThinkingBubble ||
          (widget is Text && widget.data == 'Te toca'),
    );
    await waitUntil(tester, () {
      final speaking = someoneSpeaks.evaluate().isNotEmpty;
      expect(
        speaking && controller.dealing != null,
        isFalse,
        reason: 'someone speaks while the cards are being dealt',
      );
      return speaking;
    });
  });
}

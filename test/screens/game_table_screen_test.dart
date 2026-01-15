import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/screens/game/game_table_screen.dart';

void main() {
  group('GameTableScreen Widget Tests', () {
    testWidgets('displays app bar with game info', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameTableScreen()));

      expect(find.text('PARTIDA DE MUS'), findsOneWidget);
      expect(find.text('CHICO 1 - 12/40'), findsOneWidget);
    });

    testWidgets('displays action buttons', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameTableScreen()));

      expect(find.text('MUS'), findsOneWidget);
      expect(find.text('PASO'), findsOneWidget);
      expect(find.text('ENVIDO'), findsOneWidget);
      expect(find.text('ÓRDAGO'), findsOneWidget);
    });

    testWidgets('displays player cards', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameTableScreen()));

      // Should display 4 cards for the player
      final Finder cards = find.byWidgetPredicate(
        (Widget widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration! as BoxDecoration).borderRadius ==
                BorderRadius.circular(8),
      );

      expect(cards.evaluate().length, greaterThanOrEqualTo(4));
    });

    testWidgets('displays turn indicator', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameTableScreen()));

      expect(find.text('TU TURNO'), findsOneWidget);
    });

    testWidgets('displays game phase', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameTableScreen()));

      expect(find.text('Grande / Pares'), findsOneWidget);
    });

    testWidgets('has game table container', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameTableScreen()));

      // Find container with gradient decoration
      final Finder tableContainer = find.byWidgetPredicate(
        (Widget widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration! as BoxDecoration).gradient != null,
      );

      expect(tableContainer, findsWidgets);
    });
  });
}

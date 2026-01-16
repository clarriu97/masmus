import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/screens/home/home_screen.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    testWidgets('displays header with user info', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      expect(find.text('MASMUS'), findsOneWidget);
      expect(find.text('JUGADOR'), findsOneWidget);
    });

    testWidgets('displays stats cards', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      expect(find.text('TU NIVEL'), findsOneWidget);
      expect(find.text('1,450'), findsOneWidget);
    });

    testWidgets('displays quick match card', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      expect(find.text('Un Jugador'), findsOneWidget);
      expect(find.text('JUGAR'), findsOneWidget);
    });

    testWidgets('displays online match card', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Multijugador Online'), findsOneWidget);
      expect(find.text('PRÓXIMAMENTE'), findsOneWidget); // Only Online card now
    });

    // Tournaments section removed

    // News section removed

    testWidgets('is scrollable', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('has settings icon', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    });
  });
}

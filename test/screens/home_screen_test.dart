import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/screens/home/home_screen.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    testWidgets('displays header with user info', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      expect(find.text('MASMUS'), findsOneWidget);
      expect(find.text('MIEMBRO ORO · CLUB MASMUS'), findsOneWidget);
    });

    testWidgets('displays stats cards', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      expect(find.text('TU NIVEL DE JUEGO'), findsOneWidget);
      expect(find.text('1,450'), findsOneWidget);
      expect(find.text('GLOBAL RANKING'), findsOneWidget);
      expect(find.text('#420'), findsOneWidget);
    });

    testWidgets('displays quick match card', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      expect(find.text('Partida Rápida'), findsOneWidget);
      expect(find.text('JUGAR'), findsOneWidget);
    });

    testWidgets('displays private match card', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      expect(find.text('Partida Privada'), findsOneWidget);
      expect(find.text('INVITAR'), findsOneWidget);
    });

    testWidgets('displays tournaments card', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      expect(find.text('Torneos Elite'), findsOneWidget);
      expect(find.text('EVENTO ACTIVO'), findsOneWidget);
      expect(find.text('ENTRAR'), findsOneWidget);
    });

    testWidgets('displays news section', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      expect(find.text('NOVEDADES Y CLUB'), findsOneWidget);
      expect(find.text('Ver todo'), findsOneWidget);
    });

    testWidgets('is scrollable', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('has notification and settings icons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    });
  });
}

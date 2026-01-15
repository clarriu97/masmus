import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/screens/game/game_setup_screen.dart';

void main() {
  group('GameSetupScreen Widget Tests', () {
    testWidgets('displays app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameSetupScreen()));

      expect(find.text('Configurar Partida'), findsOneWidget);
    });

    testWidgets('displays game type selector', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameSetupScreen()));

      expect(find.text('8 Reyes (Estándar)'), findsOneWidget);
      expect(find.text('4 Reyes (Vasco)'), findsOneWidget);
    });

    testWidgets('displays rules section', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameSetupScreen()));

      expect(find.text('REGLAS DE LA VARIANTE'), findsOneWidget);
      expect(find.text('La Real'), findsOneWidget);
      expect(find.text('Órdago Automático'), findsOneWidget);
    });

    testWidgets('displays signals guide card', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameSetupScreen()));

      expect(find.text('Guía de Señas'), findsOneWidget);
      expect(find.text('Aprender Señas'), findsOneWidget);
    });

    testWidgets('displays table selector section', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameSetupScreen()));

      expect(find.text('MESA Y BARAJA'), findsOneWidget);
      expect(find.text('Verde Clásico'), findsOneWidget);
      expect(find.text('Granate Real'), findsOneWidget);
      expect(find.text('Azul Casino'), findsOneWidget);
    });

    testWidgets('displays start button', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameSetupScreen()));

      expect(find.text('Comenzar Partida'), findsOneWidget);
    });

    testWidgets('can toggle La Real rule', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameSetupScreen()));

      final Finder checkbox = find.byType(Checkbox);
      expect(checkbox, findsOneWidget);

      // Verify initial state
      Checkbox checkboxWidget = tester.widget(checkbox);
      expect(checkboxWidget.value, true);

      // Tap to toggle
      await tester.tap(checkbox);
      await tester.pump();

      // Verify state changed
      checkboxWidget = tester.widget(checkbox);
      expect(checkboxWidget.value, false);
    });

    testWidgets('can toggle Órdago Automático', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameSetupScreen()));

      final Finder switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      // Verify initial state
      Switch switchWidget = tester.widget(switchFinder);
      expect(switchWidget.value, false);

      // Tap to toggle
      await tester.tap(switchFinder);
      await tester.pump();

      // Verify state changed
      switchWidget = tester.widget(switchFinder);
      expect(switchWidget.value, true);
    });
  });
}

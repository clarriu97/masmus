import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/screens/splash/splash_screen.dart';

void main() {
  group('SplashScreen Widget Tests', () {
    testWidgets('displays MASMUS title', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

      expect(find.text('MASMUS'), findsOneWidget);
    });

    testWidgets('displays subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

      expect(find.text('El juego de cartas tradicional'), findsOneWidget);
    });

    testWidgets('displays guest button', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

      expect(find.text('Explorar como invitado'), findsOneWidget);
    });

    testWidgets('displays login button', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

      expect(find.text('Iniciar sesión'), findsOneWidget);
    });

    testWidgets('has gradient background', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

      final Container container = tester.widget(find.byType(Container).first);
      expect(container.decoration, isA<BoxDecoration>());
      final BoxDecoration decoration = container.decoration! as BoxDecoration;
      expect(decoration.gradient, isA<LinearGradient>());
    });
  });
}

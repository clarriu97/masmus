import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/core/theme/app_colors.dart';
import 'package:masmus/widgets/buttons/action_button.dart';

void main() {
  group('ActionButton Widget Tests', () {
    testWidgets('displays text correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionButton(text: 'TEST', onPressed: () {}),
          ),
        ),
      );

      expect(find.text('TEST'), findsOneWidget);
    });

    testWidgets('displays icon when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionButton(
              text: 'TEST',
              icon: Icons.star,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('red type has correct colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionButton(text: 'TEST', onPressed: () {}),
          ),
        ),
      );

      final ElevatedButton button = tester.widget(find.byType(ElevatedButton));
      final ButtonStyle? style = button.style;

      expect(style?.backgroundColor?.resolve({}), AppColors.accentRed);
    });

    testWidgets('gold type has correct colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionButton(
              text: 'TEST',
              type: ActionButtonType.gold,
              onPressed: () {},
            ),
          ),
        ),
      );

      final ElevatedButton button = tester.widget(find.byType(ElevatedButton));
      final ButtonStyle? style = button.style;

      expect(style?.backgroundColor?.resolve({}), AppColors.accentGold);
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionButton(
              text: 'TEST',
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ActionButton));
      await tester.pump();

      expect(pressed, true);
    });

    testWidgets('respects width parameter', (WidgetTester tester) async {
      const double testWidth = 200;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionButton(
              text: 'TEST',
              width: testWidth,
              onPressed: () {},
            ),
          ),
        ),
      );

      final SizedBox sizedBox = tester.widget(find.byType(SizedBox).first);
      expect(sizedBox.width, testWidth);
    });

    testWidgets('handles long text without overflow', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100,
              child: ActionButton(
                text: 'VERY LONG BUTTON TEXT',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      // Should not throw overflow exception
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('is disabled when onPressed is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ActionButton(text: 'TEST')),
        ),
      );

      final ElevatedButton button = tester.widget(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });
  });
}

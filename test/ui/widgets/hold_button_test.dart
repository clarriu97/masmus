import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/ui/widgets/hold_button.dart';

import '../../helpers/test_app.dart';

void main() {
  var held = 0;

  Future<void> pump(WidgetTester tester) async {
    held = 0;
    await tester.pumpWidget(
      buildTestComponent(
        SizedBox(
          width: 140,
          child: HoldButton(
            label: 'Órdago',
            detail: 'mantén',
            hint: 'Mantén pulsado',
            onHeld: () => held++,
          ),
        ),
      ),
    );
  }

  Future<void> frames(WidgetTester tester, int count) async {
    for (var i = 0; i < count; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('goes off once held long enough, not before', (tester) async {
    await pump(tester);
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(HoldButton)),
    );
    await frames(tester, 6);
    expect(held, 0);
    await frames(tester, 4);
    expect(held, 1);
    await gesture.up();
    await tester.pump();
    expect(held, 1);
  });

  testWidgets('a tap only shows how to throw it', (tester) async {
    await pump(tester);
    await tester.tap(find.byType(HoldButton));
    await tester.pump();
    expect(held, 0);
    expect(find.text('Mantén pulsado'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('screen readers throw it with a long press', (tester) async {
    await pump(tester);
    expect(
      tester.getSemantics(find.byType(HoldButton)),
      matchesSemantics(
        label: 'Órdago',
        hint: 'mantén',
        isButton: true,
        hasLongPressAction: true,
      ),
    );
    tester.semantics.longPress(find.semantics.byLabel('Órdago'));
    expect(held, 1);
  });
}

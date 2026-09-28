import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/ui/theme/app_theme.dart';
import 'package:masmus/ui/widgets/action_button.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('shows the label and the detail under it', (tester) async {
    await tester.pumpWidget(
      buildTestComponent(
        ActionButton(
          label: 'Envido',
          detail: '2',
          kind: ActionKind.primary,
          onPressed: () {},
        ),
      ),
    );
    expect(find.text('Envido'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(
      tester.getSemantics(find.byType(ActionButton)),
      matchesSemantics(
        label: 'Envido\n2',
        isButton: true,
        hasTapAction: true,
        hasFocusAction: true,
        isEnabled: true,
        hasEnabledState: true,
        isFocusable: true,
      ),
    );
  });

  testWidgets('a tap plays it', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      buildTestComponent(ActionButton(label: 'Paso', onPressed: () => taps++)),
    );
    await tester.tap(find.text('Paso'));
    expect(taps, 1);
  });

  testWidgets('without a callback it is disabled', (tester) async {
    await tester.pumpWidget(
      buildTestComponent(
        const ActionButton(label: 'Descartar', onPressed: null),
      ),
    );
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).enabled,
      isFalse,
    );
  });

  testWidgets('each kind wears its own style and fits a thumb', (tester) async {
    const styles = {
      ActionKind.primary: 'primary',
      ActionKind.secondary: 'secondary',
      ActionKind.ordago: 'ordago',
    };
    for (final kind in styles.keys) {
      await tester.pumpWidget(
        buildTestComponent(
          ActionButton(label: 'x', kind: kind, onPressed: () {}),
        ),
      );
      final style = tester
          .widget<FilledButton>(find.byType(FilledButton))
          .style;
      expect(style, switch (kind) {
        ActionKind.primary => AppTheme.primaryButton,
        ActionKind.secondary => AppTheme.secondaryButton,
        ActionKind.ordago => AppTheme.ordagoButton,
      }, reason: styles[kind]);
      final size = tester.getSize(find.byType(FilledButton));
      expect(size.height, greaterThanOrEqualTo(kActionHeight));
      expect(size.width, greaterThanOrEqualTo(kMinTapTarget));
    }
  });
}

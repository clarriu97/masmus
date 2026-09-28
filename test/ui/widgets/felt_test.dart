import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/ui/widgets/felt.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('lays the felt and its grain under what is on it', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        const Felt(
          child: SizedBox(width: 300, height: 400, child: Text('mesa')),
        ),
      ),
    );
    expect(find.text('mesa'), findsOneWidget);
    final decoration =
        tester
                .widget<DecoratedBox>(
                  find
                      .descendant(
                        of: find.byType(Felt),
                        matching: find.byType(DecoratedBox),
                      )
                      .first,
                )
                .decoration
            as BoxDecoration;
    expect(decoration.gradient, isA<RadialGradient>());
    expect(
      find.descendant(
        of: find.byType(Felt),
        matching: find.byType(CustomPaint),
      ),
      findsWidgets,
    );
  });
}

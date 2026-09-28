import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/ui/theme/app_theme.dart';
import 'package:masmus/ui/widgets/speech_bubble.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('says it in dark ink on a cream bubble', (tester) async {
    await tester.pumpWidget(
      buildTestComponent(const SpeechBubble('No hay mus')),
    );
    expect(
      tester.widget<Text>(find.text('No hay mus')).style?.color,
      AppColors.onBubble,
    );
    final decoration =
        tester.widget<DecoratedBox>(find.byType(DecoratedBox).last).decoration
            as BoxDecoration;
    expect(decoration.color, AppColors.bubble);
  });
}

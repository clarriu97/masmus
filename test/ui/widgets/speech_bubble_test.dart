import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
      tester
          .renderObject<RenderParagraph>(find.text('No hay mus'))
          .text
          .style
          ?.color,
      AppColors.onBubble,
    );
    final decoration =
        tester.widget<DecoratedBox>(find.byType(DecoratedBox).last).decoration
            as BoxDecoration;
    expect(decoration.color, AppColors.bubble);
  });

  testWidgets('thinking: three dots that light up in turn, then stay still', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestComponent(const ThinkingBubble()));
    List<double> dots() => [
      for (final opacity in tester.widgetList<Opacity>(find.byType(Opacity)))
        opacity.opacity,
    ];
    expect(dots(), hasLength(3));
    expect(dots().where((opacity) => opacity == 1), hasLength(1));
    await tester.pump(ThinkingBubble.beat ~/ 2);
    expect(dots().indexOf(1), 1);
    await tester.pumpAndSettle();
    expect(dots(), [1, 1, 1]);
  });

  testWidgets('with reduced motion the dots are still', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    await tester.pumpWidget(buildTestComponent(const ThinkingBubble()));
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('what is said pops in once, and again only when said anew', (
    tester,
  ) async {
    var key = 1;
    late StateSetter rebuild;
    await tester.pumpWidget(
      buildTestComponent(
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return PopIn(key: ValueKey(key), child: const Text('Paso'));
          },
        ),
      ),
    );
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pumpAndSettle();
    rebuild(() {});
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
    rebuild(() => key = 2);
    await tester.pump();
    expect(tester.hasRunningAnimations, isTrue);
  });
}

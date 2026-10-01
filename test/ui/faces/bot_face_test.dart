import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/bots/heuristic_bot.dart';
import 'package:masmus/game/senas.dart';
import 'package:masmus/ui/faces/bot_face.dart';
import 'package:masmus/ui/faces/face_painter.dart';

import '../../helpers/test_app.dart';

FacePose _pose(WidgetTester tester) =>
    (tester
                .widget<CustomPaint>(
                  find.descendant(
                    of: find.byType(BotFace),
                    matching: find.byType(CustomPaint),
                  ),
                )
                .painter!
            as FacePainter)
        .pose;

void main() {
  late StateSetter rebuild;
  var senas = <Sena>[];
  Object? spoke;
  var thinking = false;

  Future<void> pump(WidgetTester tester) async {
    senas = [];
    spoke = null;
    thinking = false;
    await tester.pumpWidget(
      buildTestComponent(
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return BotFace(
              personality: Personality.calculador,
              senas: senas,
              spoke: spoke,
              thinking: thinking,
            );
          },
        ),
      ),
    );
  }

  testWidgets('at rest it blinks now and then, on its own', (tester) async {
    await pump(tester);
    expect(_pose(tester).blink, 0);
    var blinked = false;
    for (var i = 0; i < 200 && !blinked; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      blinked = _pose(tester).blink == 1;
    }
    expect(blinked, isTrue);
  });

  testWidgets('new señas are acted out one after another, then it rests', (
    tester,
  ) async {
    await pump(tester);
    rebuild(() => senas = [Sena.treintaYUna, Sena.dosReyes]);
    await tester.pump();
    expect(_pose(tester).sena, Sena.treintaYUna);
    await tester.pump(BotFace.senaHold);
    expect(_pose(tester).sena, Sena.dosReyes);
    await tester.pump(BotFace.senaHold);
    expect(_pose(tester).sena, isNull);
  });

  testWidgets('it looks up while it thinks and moves its mouth when it '
      'speaks', (tester) async {
    await pump(tester);
    rebuild(() => thinking = true);
    await tester.pump();
    expect(_pose(tester).gaze.dy, lessThan(0));
    rebuild(() {
      thinking = false;
      spoke = 1;
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(_pose(tester).talking, greaterThan(0));
    await tester.pumpAndSettle();
    expect(_pose(tester).talking, 0);
  });

  testWidgets('with reduced motion it stays still', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    await pump(tester);
    rebuild(() => senas = [Sena.duples]);
    await tester.pump(const Duration(seconds: 6));
    expect(_pose(tester).blink, 0);
    expect(_pose(tester).sena, isNull);
    expect(tester.hasRunningAnimations, isFalse);
  });
}

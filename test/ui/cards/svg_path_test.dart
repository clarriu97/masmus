import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/ui/cards/svg_path.dart';

void main() {
  test('absolute lines draw the box they say', () {
    expect(
      svgPath('M10 10 H90 V90 H10 Z').getBounds(),
      const Rect.fromLTRB(10, 10, 90, 90),
    );
  });

  test('relative commands move from the current point', () {
    expect(
      svgPath('m10 10 h80 v80 h-80 z').getBounds(),
      const Rect.fromLTRB(10, 10, 90, 90),
    );
  });

  test('numbers after a moveto are lines', () {
    expect(
      svgPath('M0 0 10 0 10 10').getBounds(),
      const Rect.fromLTRB(0, 0, 10, 10),
    );
  });

  test('curves pass through the points their formulas give', () {
    Offset middle(String data) {
      final metric = svgPath(data).computeMetrics().single;
      return metric.getTangentForOffset(metric.length / 2)!.position;
    }

    final cubic = middle('M0 0 C0 100 100 100 100 0');
    expect(cubic.dx, closeTo(50, 0.01));
    expect(cubic.dy, closeTo(75, 0.01));
    final quadratic = middle('M0 0 Q50 100 100 0');
    expect(quadratic.dx, closeTo(50, 0.01));
    expect(quadratic.dy, closeTo(50, 0.01));
  });

  test('reads signs and leading dots without spaces', () {
    expect(
      svgPath('M0 0 L.5-5').getBounds(),
      const Rect.fromLTRB(0, -5, 0.5, 0),
    );
  });

  test('refuses commands it does not know, and data cut short', () {
    expect(() => svgPath('M0 0 A5 5 0 0 1 10 10'), throwsFormatException);
    expect(() => svgPath('M0 0 L10'), throwsFormatException);
  });
}

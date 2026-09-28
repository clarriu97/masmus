import 'dart:math';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/ui/cards/pip_layout.dart';
import 'package:masmus/ui/cards/playing_card_view.dart';

/// The art area of a card 100 wide, in the card's proportions.
const _card = Size(100, 100 / PlayingCardView.aspectRatio);
final _area = Size(artArea.width * _card.width, artArea.height * _card.height);

Offset _px(Offset fraction) =>
    Offset(fraction.dx * _area.width, fraction.dy * _area.height);

void main() {
  for (var number = 1; number <= 7; number++) {
    group('the $number', () {
      final layout = pipLayout(number);
      final size = layout.size * _area.width;

      test('has $number pips', () {
        expect(layout.centers, hasLength(number));
      });

      test('keeps every pip clear of the others', () {
        for (var i = 0; i < number; i++) {
          for (var j = i + 1; j < number; j++) {
            final distance =
                (_px(layout.centers[i]) - _px(layout.centers[j])).distance;
            expect(distance, greaterThanOrEqualTo(size), reason: '$i and $j');
          }
        }
      });

      test('keeps every pip inside the art', () {
        for (final center in layout.centers.map(_px)) {
          expect(center.dx - size / 2, greaterThanOrEqualTo(0));
          expect(center.dx + size / 2, lessThanOrEqualTo(_area.width));
          expect(center.dy - size / 2, greaterThanOrEqualTo(0));
          expect(center.dy + size / 2, lessThanOrEqualTo(_area.height));
        }
      });

      test('is the same seen in a mirror', () {
        for (final center in layout.centers) {
          expect(
            layout.centers.any(
              (other) =>
                  (other.dx - (1 - center.dx)).abs() < 1e-9 &&
                  other.dy == center.dy,
            ),
            isTrue,
            reason: '$center',
          );
        }
      });
    });
  }

  test('figures keep their emblem clear of their pip', () {
    final emblem = figureEmblem.size * _area.width;
    final pip = figurePip.size * _area.width;
    final gap =
        _px(figurePip.center).dy -
        _px(figureEmblem.center).dy -
        (emblem + pip) / 2;
    expect(gap, greaterThan(0));
    expect(
      max(_px(figureEmblem.center).dy - emblem / 2, 0),
      greaterThanOrEqualTo(0),
    );
    expect(_px(figurePip.center).dy + pip / 2, lessThanOrEqualTo(_area.height));
  });

  test('only 1 to 7 have pips', () {
    expect(() => pipLayout(10), throwsArgumentError);
  });
}

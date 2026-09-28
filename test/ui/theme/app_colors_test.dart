import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/ui/theme/app_colors.dart';

double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

double contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  group('contrast helper', () {
    test('black on white is 21:1', () {
      expect(contrast(Colors.black, Colors.white), closeTo(21, 0.01));
    });

    test('same color is 1:1', () {
      expect(contrast(AppColors.felt, AppColors.felt), closeTo(1, 0.001));
    });
  });

  group('text meets WCAG AA (4.5:1)', () {
    const felts = {
      'felt': AppColors.felt,
      'feltLight': AppColors.feltLight,
      'feltDark': AppColors.feltDark,
    };
    for (final background in felts.entries) {
      for (final (name, foreground) in const [
        ('ink', AppColors.ink),
        ('inkSecondary', AppColors.inkSecondary),
      ]) {
        test('$name on ${background.key}', () {
          expect(
            contrast(foreground, background.value),
            greaterThanOrEqualTo(4.5),
          );
        });
      }
    }

    test('ink on a chip', () {
      expect(
        contrast(
          AppColors.ink,
          Color.alphaBlend(AppColors.chip, AppColors.felt),
        ),
        greaterThanOrEqualTo(4.5),
      );
    });

    const pairs = {
      'onPrimary on primary': (AppColors.onPrimary, AppColors.primary),
      'onOrdago on ordago': (AppColors.onOrdago, AppColors.ordago),
      'onTurn on turn': (AppColors.onTurn, AppColors.turn),
      'onBubble on bubble': (AppColors.onBubble, AppColors.bubble),
      'onAvatar on avatar': (AppColors.onAvatar, AppColors.avatar),
      'cardInk on card': (AppColors.cardInk, AppColors.card),
      'cardInkSecondary on card': (AppColors.cardInkSecondary, AppColors.card),
    };
    for (final MapEntry(key: name, value: (foreground, background))
        in pairs.entries) {
      test(name, () {
        expect(contrast(foreground, background), greaterThanOrEqualTo(4.5));
      });
    }
  });

  test('the brass of the turn stands out from the felt (3:1)', () {
    for (final felt in const [
      AppColors.felt,
      AppColors.feltLight,
      AppColors.feltDark,
    ]) {
      expect(contrast(AppColors.turn, felt), greaterThanOrEqualTo(3));
    }
  });

  test('the felt goes from light under the lamp to dark at the edges', () {
    expect(
      _luminance(AppColors.feltLight),
      greaterThan(_luminance(AppColors.felt)),
    );
    expect(
      _luminance(AppColors.felt),
      greaterThan(_luminance(AppColors.feltDark)),
    );
  });
}

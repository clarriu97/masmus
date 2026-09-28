import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/ui/theme/app_theme.dart';

void main() {
  final text = AppTheme.textTheme;

  group('typography', () {
    final display = {
      'displayLarge': text.displayLarge,
      'displayMedium': text.displayMedium,
      'displaySmall': text.displaySmall,
      'headlineSmall': text.headlineSmall,
    };
    final ui = {
      'titleLarge': text.titleLarge,
      'titleMedium': text.titleMedium,
      'titleSmall': text.titleSmall,
      'bodyLarge': text.bodyLarge,
      'bodyMedium': text.bodyMedium,
      'bodySmall': text.bodySmall,
      'labelLarge': text.labelLarge,
      'labelMedium': text.labelMedium,
      'labelSmall': text.labelSmall,
    };

    for (final MapEntry(key: name, value: style) in display.entries) {
      test('$name uses Young Serif, which only has a regular weight', () {
        expect(style!.fontFamily, AppTheme.displayFont);
        expect(style.fontWeight, FontWeight.w400);
      });
    }

    for (final MapEntry(key: name, value: style) in ui.entries) {
      test('$name uses Alegreya Sans with lining, tabular figures', () {
        expect(style!.fontFamily, AppTheme.uiFont);
        expect(
          style.fontFeatures,
          containsAll(const [
            FontFeature.liningFigures(),
            FontFeature.tabularFigures(),
          ]),
        );
      });
    }

    test('nothing is smaller than 12', () {
      for (final style in [...display.values, ...ui.values]) {
        expect(style!.fontSize, greaterThanOrEqualTo(12));
      }
    });
  });

  group('action buttons', () {
    final styles = {
      'primary': AppTheme.primaryButton,
      'secondary': AppTheme.secondaryButton,
      'ordago': AppTheme.ordagoButton,
    };

    test('each kind has its own fill', () {
      final fills = {
        for (final style in styles.values)
          style.backgroundColor!.resolve(const {}),
      };
      expect(fills, hasLength(styles.length));
    });

    for (final MapEntry(key: name, value: style) in styles.entries) {
      test('$name is a stadium at least $kActionHeight tall', () {
        final size = style.minimumSize!.resolve(const {})!;
        expect(size.height, kActionHeight);
        expect(size.width, greaterThanOrEqualTo(kMinTapTarget));
        expect(style.shape!.resolve(const {}), isA<StadiumBorder>());
      });

      test('$name fades when disabled', () {
        final enabled = style.backgroundColor!.resolve(const {})!;
        final disabled = style.backgroundColor!.resolve(const {
          WidgetState.disabled,
        })!;
        expect(disabled.a, lessThan(enabled.a));
      });
    }
  });

  test('bottom sheets are dark felt with a handle', () {
    final sheet = AppTheme.tapete.bottomSheetTheme;
    expect(sheet.modalBackgroundColor, AppColors.feltDark);
    expect(sheet.showDragHandle, isTrue);
  });
}

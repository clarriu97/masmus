import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_tokens.dart';

export 'app_colors.dart';
export 'app_tokens.dart';

class AppTheme {
  AppTheme._();

  static const String displayFont = 'YoungSerif';
  static const String uiFont = 'AlegreyaSans';

  static TextStyle _display(double size) => TextStyle(
    fontFamily: displayFont,
    fontSize: size,
    fontWeight: FontWeight.w400,
    height: 1.1,
    color: AppColors.ink,
  );

  /// Lining, tabular figures: Alegreya Sans defaults to old-style ones, and
  /// scores and stakes must line up.
  static TextStyle _ui(
    double size,
    FontWeight weight, {
    Color color = AppColors.ink,
    double? height,
    double letterSpacing = 0,
  }) => TextStyle(
    fontFamily: uiFont,
    fontSize: size,
    fontWeight: weight,
    height: height,
    letterSpacing: letterSpacing,
    color: color,
    fontFeatures: const [
      FontFeature.liningFigures(),
      FontFeature.tabularFigures(),
    ],
  );

  static final TextTheme textTheme = TextTheme(
    displayLarge: _display(44),
    displayMedium: _display(32),
    // The score.
    displaySmall: _display(26),
    headlineSmall: _display(22),
    titleLarge: _ui(20, FontWeight.w800),
    titleMedium: _ui(17, FontWeight.w700),
    titleSmall: _ui(15, FontWeight.w700),
    bodyLarge: _ui(17, FontWeight.w400, height: 1.4),
    bodyMedium: _ui(15, FontWeight.w400, height: 1.4),
    bodySmall: _ui(13, FontWeight.w500, color: AppColors.inkSecondary),
    labelLarge: _ui(17, FontWeight.w800, letterSpacing: 0.2),
    // Overlines, in capitals: NOSOTROS, ELLOS.
    labelMedium: _ui(
      13,
      FontWeight.w700,
      color: AppColors.inkSecondary,
      letterSpacing: 1.4,
    ),
    labelSmall: _ui(12, FontWeight.w600, color: AppColors.inkSecondary),
  );

  /// The small line under an action's label: the amount of an envite,
  /// "mantén" on the órdago. It takes the button's color.
  static const TextStyle actionDetail = TextStyle(
    fontFamily: uiFont,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.1,
    fontFeatures: [FontFeature.liningFigures()],
  );

  /// The number in a card's corner; the card sets its size.
  static const TextStyle cardIndex = TextStyle(
    fontFamily: displayFont,
    fontWeight: FontWeight.w400,
    height: 1,
    color: AppColors.cardInk,
  );

  static ButtonStyle _action(Color background, Color foreground, Color edge) =>
      ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(
          Size(kMinTapTarget, kActionHeight),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        ),
        shape: const WidgetStatePropertyAll(StadiumBorder()),
        side: WidgetStatePropertyAll(BorderSide(color: edge, width: 1.5)),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? background.withValues(alpha: background.a * 0.4)
              : background,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? foreground.withValues(alpha: 0.5)
              : foreground,
        ),
        overlayColor: WidgetStatePropertyAll(
          foreground.withValues(alpha: 0.12),
        ),
        textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
      );

  static final ButtonStyle primaryButton = _action(
    AppColors.primary,
    AppColors.onPrimary,
    AppColors.primary,
  );
  static final ButtonStyle secondaryButton = _action(
    AppColors.chip,
    AppColors.ink,
    AppColors.lineStrong,
  );
  static final ButtonStyle ordagoButton = _action(
    AppColors.ordago,
    AppColors.onOrdago,
    AppColors.ordago,
  );

  static ThemeData get tapete => ThemeData(
    brightness: Brightness.dark,
    fontFamily: uiFont,
    scaffoldBackgroundColor: AppColors.felt,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.turn,
      onSecondary: AppColors.onTurn,
      error: AppColors.ordago,
      onError: AppColors.onOrdago,
      surface: AppColors.felt,
      onSurface: AppColors.ink,
      onSurfaceVariant: AppColors.inkSecondary,
      surfaceContainerHighest: AppColors.feltLight,
      outline: AppColors.lineStrong,
      outlineVariant: AppColors.line,
    ),
    textTheme: textTheme,
    iconTheme: const IconThemeData(color: AppColors.ink),
    dividerColor: AppColors.line,
    filledButtonTheme: FilledButtonThemeData(style: primaryButton),
    outlinedButtonTheme: OutlinedButtonThemeData(style: secondaryButton),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.ink,
        minimumSize: const Size(kMinTapTarget, kMinTapTarget),
        textStyle: textTheme.titleSmall,
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(
          Size(kMinTapTarget, kMinTapTarget),
        ),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.none,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.onPrimary
              : AppColors.ink,
        ),
        side: const WidgetStatePropertyAll(
          BorderSide(color: AppColors.lineStrong, width: 1.5),
        ),
        textStyle: WidgetStatePropertyAll(textTheme.titleSmall),
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.bubble,
        borderRadius: BorderRadius.circular(AppRadii.md),
        boxShadow: AppShadows.raised,
      ),
      textStyle: textTheme.titleSmall?.copyWith(color: AppColors.onBubble),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      showDuration: const Duration(seconds: 2),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.feltDark,
      modalBackgroundColor: AppColors.feltDark,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: AppColors.lineStrong,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
    ),
  );
}

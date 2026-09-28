import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Jerarquía tipográfica con las fuentes empaquetadas: Young Serif para
/// títulos y Alegreya Sans para el cuerpo
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _display({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double letterSpacing = 0,
  }) => TextStyle(
    fontFamily: 'YoungSerif',
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
  );

  static TextStyle _body({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double letterSpacing = 0,
    double? height,
  }) => TextStyle(
    fontFamily: 'AlegreyaSans',
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );

  // Display - Títulos principales
  static TextStyle get display => _display(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle get displayMedium => _display(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  // Headline - Títulos de sección
  static TextStyle get headline => _display(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static TextStyle get headlineMedium => _display(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  // Title - Títulos de cards
  static TextStyle get title => _body(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  static TextStyle get titleMedium => _body(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.1,
  );

  static TextStyle get titleSmall => _body(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body - Texto de cuerpo
  static TextStyle get body => _body(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static TextStyle get bodyBold => _body(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle get bodyMedium => _body(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static TextStyle get bodySmall => _body(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    height: 1.4,
  );

  // Caption - Textos pequeños
  static TextStyle get caption => _body(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.3,
  );

  static TextStyle get captionSmall => _body(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
    letterSpacing: 0.3,
  );

  // Button - Estilos para botones
  static TextStyle get button => _body(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );

  static TextStyle get buttonSmall => _body(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
  );

  // Label - Labels y badges
  static TextStyle get label => _body(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.8,
  );

  static TextStyle get labelSmall => _body(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.8,
  );
}

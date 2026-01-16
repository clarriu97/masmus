import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Jerarquía tipográfica con Lora (serif) para títulos e Inter (sans-serif) para cuerpo
class AppTextStyles {
  AppTextStyles._();

  static bool useGoogleFonts = true;

  static TextStyle _fontLora({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double letterSpacing = 0,
  }) {
    if (!useGoogleFonts) {
      return TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        fontFamily: 'serif',
      );
    }
    return GoogleFonts.lora(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle _fontInter({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double letterSpacing = 0,
    double? height,
  }) {
    if (!useGoogleFonts) {
      return TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
        fontFamily: 'sans-serif',
      );
    }
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  // Display - Títulos principales
  static TextStyle get display => _fontLora(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle get displayMedium => _fontLora(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  // Headline - Títulos de sección
  static TextStyle get headline => _fontLora(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static TextStyle get headlineMedium => _fontLora(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  // Title - Títulos de cards
  static TextStyle get title => _fontInter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  static TextStyle get titleMedium => _fontInter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.1,
  );

  static TextStyle get titleSmall => _fontInter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body - Texto de cuerpo
  static TextStyle get body => _fontInter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static TextStyle get bodyBold => _fontInter(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle get bodyMedium => _fontInter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static TextStyle get bodySmall => _fontInter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    height: 1.4,
  );

  // Caption - Textos pequeños
  static TextStyle get caption => _fontInter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.3,
  );

  static TextStyle get captionSmall => _fontInter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
    letterSpacing: 0.3,
  );

  // Button - Estilos para botones
  static TextStyle get button => _fontInter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );

  static TextStyle get buttonSmall => _fontInter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
  );

  // Label - Labels y badges
  static TextStyle get label => _fontInter(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.8,
  );

  static TextStyle get labelSmall => _fontInter(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.8,
  );
}

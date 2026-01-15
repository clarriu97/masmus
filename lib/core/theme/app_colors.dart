import 'package:flutter/material.dart';

/// Paleta de colores extraída fielmente de las capturas de pantalla
class AppColors {
  AppColors._();

  // Colores Principales
  static const Color primaryGreen = Color(0xFF2D5A4A);
  static const Color primaryGreenLight = Color(0xFF3A6B59);
  static const Color primaryGreenDark = Color(0xFF1F4037);

  static const Color accentGold = Color(0xFFD4A944);
  static const Color accentRed = Color(0xFFB83C3C);
  static const Color accentRedDark = Color(0xFF6B2C2C);
  static const Color accentBlue = Color(0xFF2C3E6B);

  // Colores de Fondo
  static const Color backgroundDark = Color(0xFF1A1D23);
  static const Color backgroundCard = Color(0xFF242830);
  static const Color backgroundElevated = Color(0xFF2A2F3A);

  // Colores de Texto
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8BCC4);
  static const Color textTertiary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF4B5563);

  // Colores Semánticos
  static const Color success = Color(0xFF4A9B7F);
  static const Color error = Color(0xFFB83C3C);
  static const Color warning = Color(0xFFD4A944);
  static const Color info = Color(0xFF4A7C9B);

  // Colores de Mesa y Baraja
  static const Color tableGreenClassic = Color(0xFF2D5A4A);
  static const Color tableGranate = Color(0xFF6B2C2C);
  static const Color tableBlue = Color(0xFF2C3E6B);

  // Colores de UI
  static const Color divider = Color(0xFF3A3F4A);
  static const Color border = Color(0xFF3A3F4A);
  static const Color overlay = Color(0x80000000);

  // Gradientes
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2D5A4A), Color(0xFF1F4037)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD4A944), Color(0xFFB8923A)],
  );

  static const LinearGradient redGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB83C3C), Color(0xFF8B2C2C)],
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/core/theme/app_colors.dart';

void main() {
  group('AppColors', () {
    test('primary colors are defined correctly', () {
      expect(AppColors.primaryGreen, const Color(0xFF2D5A4A));
      expect(AppColors.primaryGreenLight, const Color(0xFF3A6B59));
      expect(AppColors.primaryGreenDark, const Color(0xFF1F4037));
    });

    test('accent colors are defined correctly', () {
      expect(AppColors.accentGold, const Color(0xFFD4A944));
      expect(AppColors.accentRed, const Color(0xFFB83C3C));
      expect(AppColors.accentRedDark, const Color(0xFF6B2C2C));
      expect(AppColors.accentBlue, const Color(0xFF2C3E6B));
    });

    test('background colors are defined correctly', () {
      expect(AppColors.backgroundDark, const Color(0xFF1A1D23));
      expect(AppColors.backgroundCard, const Color(0xFF242830));
      expect(AppColors.backgroundElevated, const Color(0xFF2A2F3A));
    });

    test('text colors are defined correctly', () {
      expect(AppColors.textPrimary, const Color(0xFFFFFFFF));
      expect(AppColors.textSecondary, const Color(0xFFB8BCC4));
      expect(AppColors.textTertiary, const Color(0xFF6B7280));
      expect(AppColors.textDisabled, const Color(0xFF4B5563));
    });

    test('semantic colors are defined correctly', () {
      expect(AppColors.success, const Color(0xFF4A9B7F));
      expect(AppColors.error, const Color(0xFFB83C3C));
      expect(AppColors.warning, const Color(0xFFD4A944));
      expect(AppColors.info, const Color(0xFF4A7C9B));
    });

    test('gradients are defined', () {
      expect(AppColors.cardGradient, isA<LinearGradient>());
      expect(AppColors.goldGradient, isA<LinearGradient>());
      expect(AppColors.redGradient, isA<LinearGradient>());
    });
  });
}

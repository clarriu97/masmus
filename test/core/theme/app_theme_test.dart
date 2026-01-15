import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/core/theme/app_colors.dart';

void main() {
  group('AppTheme', () {
    test('darkTheme color scheme has correct primary colors', () {
      expect(AppColors.primaryGreen, const Color(0xFF2D5A4A));
      expect(AppColors.accentGold, const Color(0xFFD4A944));
      expect(AppColors.accentRed, const Color(0xFFB83C3C));
    });

    test('darkTheme has correct background colors', () {
      expect(AppColors.backgroundDark, const Color(0xFF1A1D23));
      expect(AppColors.backgroundCard, const Color(0xFF242830));
    });

    test('darkTheme has correct semantic colors', () {
      expect(AppColors.success, const Color(0xFF4A9B7F));
      expect(AppColors.error, const Color(0xFFB83C3C));
      expect(AppColors.warning, const Color(0xFFD4A944));
    });
  });
}

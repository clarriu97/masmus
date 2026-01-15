import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Pantalla social (placeholder)
class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Social', style: AppTextStyles.headline)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.group, size: 80, color: AppColors.accentGold),
            const SizedBox(height: 24),
            Text('Social', style: AppTextStyles.title),
            const SizedBox(height: 8),
            Text('Próximamente', style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Pantalla de perfil (placeholder)
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Perfil', style: AppTextStyles.headline)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 80, color: AppColors.accentGold),
            const SizedBox(height: 24),
            Text('Perfil', style: AppTextStyles.title),
            const SizedBox(height: 8),
            Text('Próximamente', style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }
}

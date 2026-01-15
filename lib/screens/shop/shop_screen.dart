import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Pantalla de tienda (placeholder)
class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tienda', style: AppTextStyles.headline)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_bag,
              size: 80,
              color: AppColors.accentGold,
            ),
            const SizedBox(height: 24),
            Text('Tienda', style: AppTextStyles.title),
            const SizedBox(height: 8),
            Text('Próximamente', style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }
}

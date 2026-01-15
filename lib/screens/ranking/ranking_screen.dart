import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Pantalla de ranking (placeholder)
class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ranking', style: AppTextStyles.headline)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.emoji_events,
              size: 80,
              color: AppColors.accentGold,
            ),
            const SizedBox(height: 24),
            Text('Ranking', style: AppTextStyles.title),
            const SizedBox(height: 8),
            Text('Próximamente', style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }
}

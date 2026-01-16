import 'package:flutter/material.dart';

import '../core/game/logic/mus_game.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import 'buttons/primary_button.dart';

class RoundSummary extends StatelessWidget {
  const RoundSummary({
    required this.scoreDetails,
    required this.onContinue,
    super.key,
  });

  final Map<GamePhase, String> scoreDetails;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(200),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.accentGold),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Resumen de la Mano',
                style: AppTextStyles.displayMedium.copyWith(
                  color: AppColors.accentGold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildPhaseRow('Grande', GamePhase.grande),
              _buildPhaseRow('Chica', GamePhase.chica),
              _buildPhaseRow('Pares', GamePhase.pares),
              _buildPhaseRow('Juego/Punto', GamePhase.juego),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Continuar',
                onPressed: onContinue,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseRow(String label, GamePhase phase) {
    // Check if we have detail for Juego or Punto
    String? detail = scoreDetails[phase];
    if (phase == GamePhase.juego && detail == null) {
      detail = scoreDetails[GamePhase.punto];
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.bodyBold.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              detail ?? 'Pasado',
              style: AppTextStyles.body.copyWith(
                color: detail != null ? Colors.white : Colors.white38,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

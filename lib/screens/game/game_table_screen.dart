import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/buttons/action_button.dart';

/// Pantalla de mesa de juego
class GameTableScreen extends StatelessWidget {
  const GameTableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          children: [
            Text(
              'PARTIDA DE MUS',
              style: AppTextStyles.headlineMedium.copyWith(fontSize: 18),
            ),
            Text(
              'CHICO 1 - 12/40',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.accentGold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Mesa de juego
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.cardGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Jugador superior
                  Positioned(
                    top: 40,
                    left: 0,
                    right: 0,
                    child: _buildPlayerAvatar('Javier', true),
                  ),

                  // Jugador izquierdo
                  Positioned(
                    left: 20,
                    top: 0,
                    bottom: 0,
                    child: Center(child: _buildPlayerAvatar('Elena', false)),
                  ),

                  // Jugador derecho
                  Positioned(
                    right: 20,
                    top: 0,
                    bottom: 0,
                    child: Center(child: _buildPlayerAvatar('Carlos', false)),
                  ),

                  // Indicadores de equipo
                  Positioned(
                    top: 120,
                    left: 0,
                    right: 0,
                    child: _buildTeamIndicators(),
                  ),

                  // Carta central (placeholder)
                  Center(
                    child: Container(
                      width: 80,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'M',
                          style: AppTextStyles.display.copyWith(
                            color: AppColors.textTertiary.withValues(
                              alpha: 0.3,
                            ),
                            fontSize: 48,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botones de acción
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: ActionButton(
                    text: 'MUS',
                    onPressed: () {},
                    type: ActionButtonType.gold,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ActionButton(
                    text: 'PASO',
                    onPressed: () {},
                    type: ActionButtonType.gold,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ActionButton(
                    text: 'ENVIDO',
                    onPressed: () {},
                    type: ActionButtonType.gold,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ActionButton(text: 'ÓRDAGO', onPressed: () {}),
                ),
              ],
            ),
          ),

          // Cartas del jugador
          Container(
            height: 140,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  width: 70,
                  height: 110,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primaryGreenLight,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          index == 3 ? '11' : '${index + 1}',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.accentGold,
                          ),
                        ),
                      ),
                      Icon(
                        index == 3 ? Icons.close : Icons.circle,
                        color: AppColors.accentGold,
                        size: 28,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          index == 3 ? '11' : '${index + 1}',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.accentGold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),

          // Info inferior
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.accentRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                Text('TU TURNO', style: AppTextStyles.caption),
                Row(
                  children: [
                    Text('Grande / Pares', style: AppTextStyles.caption),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentGold,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '31',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.backgroundDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerAvatar(String name, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive
                  ? AppColors.accentGold
                  : AppColors.primaryGreenLight,
              width: 2,
            ),
            color: AppColors.backgroundCard,
          ),
          child: Stack(
            children: [
              const Center(
                child: Icon(
                  Icons.person,
                  color: AppColors.textSecondary,
                  size: 32,
                ),
              ),
              if (isActive)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppColors.accentRed,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'P',
                        style: AppTextStyles.labelSmall.copyWith(fontSize: 8),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.backgroundDark.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(name, style: AppTextStyles.caption),
              if (isActive) ...[
                const SizedBox(width: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.accentRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeamIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTeamDots('ELLOS', 3),
        const SizedBox(width: 40),
        _buildTeamDots('NOS', 2),
      ],
    );
  }

  Widget _buildTeamDots(String label, int count) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.captionSmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: List.generate(count, (index) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: const BoxDecoration(
                color: AppColors.textPrimary,
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ],
    );
  }
}

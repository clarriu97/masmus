import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/buttons/secondary_button.dart';
import '../../widgets/cards/game_card.dart';
import '../../widgets/cards/info_card.dart';
import '../partner_selection_screen.dart';

/// Pantalla principal de MASMUS
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),

              const SizedBox(height: 24),

              // Stats Cards
              _buildStatsSection(),

              const SizedBox(height: 24),

              // Un Jugador (Bots)
              _buildSinglePlayerCard(context),

              // Online (Coming Soon)
              _buildOnlineCard(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accentGold, width: 2),
              color: AppColors.backgroundCard,
            ),
            child: const Icon(Icons.person, color: AppColors.textSecondary),
          ),

          const SizedBox(width: 12),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MASMUS', style: AppTextStyles.title),
                Text(
                  'JUGADOR',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentGold,
                  ),
                ),
              ],
            ),
          ),

          // Settings Icon only
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: InfoCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TU NIVEL',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          '1,450',
                          style: AppTextStyles.display.copyWith(fontSize: 28),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            'ELO',
                            style: AppTextStyles.caption.copyWith(fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSinglePlayerCard(BuildContext context) {
    return GameCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person, color: AppColors.accentGold, size: 28),
              const SizedBox(width: 12),
              Text('Un Jugador', style: AppTextStyles.title),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            'Juega contra bots y mejora tu estrategia.\nPartida local.',
            style: AppTextStyles.body,
          ),

          const SizedBox(height: 20),

          PrimaryButton(
            text: 'JUGAR',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PartnerSelectionScreen(),
                ),
              );
            },
            width: double.infinity,
            icon: Icons.play_arrow,
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineCard() {
    return GameCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.public, color: AppColors.textTertiary, size: 28),
              const SizedBox(width: 12),
              Text(
                'Multijugador Online',
                style: AppTextStyles.title.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            'Próximamente...\nCompite contra jugadores de todo el mundo.',
            style: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
          ),

          const SizedBox(height: 20),

          SecondaryButton(
            text: 'PRÓXIMAMENTE',
            onPressed: () {},
            width: double.infinity,
            icon: Icons.lock_clock,
          ),
        ],
      ),
    );
  }
}


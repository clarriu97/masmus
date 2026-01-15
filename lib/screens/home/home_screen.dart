import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/buttons/action_button.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/buttons/secondary_button.dart';
import '../../widgets/cards/game_card.dart';
import '../../widgets/cards/info_card.dart';

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

              // Partida Rápida
              _buildQuickMatchCard(context),

              // Partida Privada
              _buildPrivateMatchCard(),

              // Torneos Elite
              _buildTournamentsCard(),

              const SizedBox(height: 24),

              // Novedades y Club
              _buildNewsSection(),

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
                  'MIEMBRO ORO · CLUB MASMUS',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentGold,
                  ),
                ),
              ],
            ),
          ),

          // Icons
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
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
                    'TU NIVEL DE JUEGO',
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
                            'ELO PTS',
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

          const SizedBox(width: 12),

          Expanded(
            child: InfoCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GLOBAL RANKING',
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
                          '#420',
                          style: AppTextStyles.display.copyWith(fontSize: 28),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            'Top 5%',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.success,
                              fontSize: 10,
                            ),
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

  Widget _buildQuickMatchCard(BuildContext context) {
    return GameCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flash_on, color: AppColors.accentGold, size: 28),
              const SizedBox(width: 12),
              Text('Partida Rápida', style: AppTextStyles.title),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            'Matchmaking instantáneo\ncon jugadores de tu nivel.',
            style: AppTextStyles.body,
          ),

          const SizedBox(height: 20),

          PrimaryButton(
            text: 'JUGAR',
            onPressed: () {
              Navigator.of(context).pushNamed('/game-setup');
            },
            width: double.infinity,
            icon: Icons.play_arrow,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivateMatchCard() {
    return GameCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.group, color: AppColors.accentGold, size: 28),
              const SizedBox(width: 12),
              Text('Partida Privada', style: AppTextStyles.title),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            'Crea una mesa para jugar\ncon tus amigos del club.',
            style: AppTextStyles.body,
          ),

          const SizedBox(height: 20),

          SecondaryButton(
            text: 'INVITAR',
            onPressed: () {},
            width: double.infinity,
            icon: Icons.person_add,
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentsCard() {
    return GameCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.emoji_events,
                color: AppColors.accentGold,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Torneos Elite', style: AppTextStyles.title),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentRed,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('EVENTO ACTIVO', style: AppTextStyles.labelSmall),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            'Compite por premios en\nmetálico y gloria nacional.',
            style: AppTextStyles.body,
          ),

          const SizedBox(height: 20),

          ActionButton(
            text: 'ENTRAR',
            onPressed: () {},
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildNewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'NOVEDADES Y CLUB',
                style: AppTextStyles.caption.copyWith(letterSpacing: 1.2),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Ver todo',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentGold,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 180,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildNewsCard(
                'NUEVO DISEÑO',
                'Baraja \'Iberia Clásica\' ya disponible en la tienda',
                Icons.style,
              ),
              _buildNewsCard(
                'PRÓXIMAMENTE',
                'Torneo Nacional ¡Ilustres! - Inscripciones abiertas',
                Icons.calendar_today,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNewsCard(String badge, String text, IconData icon) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      child: InfoCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentGold,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                badge,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.backgroundDark,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Icon(icon, color: AppColors.textSecondary, size: 32),

            const Spacer(),

            Text(
              text,
              style: AppTextStyles.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

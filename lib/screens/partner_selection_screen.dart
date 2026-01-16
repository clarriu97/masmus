import 'package:flutter/material.dart';
import '../core/game/data/partner_presets.dart';
import '../core/game/models/ai_profile.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import 'game_config_screen.dart';

class PartnerSelectionScreen extends StatelessWidget {
  const PartnerSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Elige a tu Compañero', style: AppTextStyles.displayMedium),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: PartnerPresets.partners.length,
        itemBuilder: (context, index) {
          final partner = PartnerPresets.partners[index];
          return _PartnerCard(
            partner: partner,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      GameConfigScreen(partnerProfile: partner),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PartnerCard extends StatelessWidget {
  const _PartnerCard({required this.partner, required this.onTap});

  final AiProfile partner;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primaryGreen,
                  child: Text(
                    partner.name[0],
                    style: AppTextStyles.headline.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(partner.name, style: AppTextStyles.title),
                      const SizedBox(height: 8),
                      _StatRow(label: 'Osadía', value: partner.boldness),
                      const SizedBox(height: 4),
                      _StatRow(label: 'Farol', value: partner.bluffing),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.accentGold,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 60, child: Text(label, style: AppTextStyles.caption)),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: AppColors.backgroundElevated,
              valueColor: AlwaysStoppedAnimation<Color>(
                // Gradiente visual manual según valor
                value > 0.7
                    ? AppColors.accentRed
                    : value > 0.4
                    ? AppColors.accentGold
                    : AppColors.primaryGreen,
              ),
              minHeight: 6,
            ),
          ),
        ),
      ],
    );
  }
}

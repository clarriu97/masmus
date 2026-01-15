import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/buttons/action_button.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/cards/game_card.dart';
import '../../widgets/cards/info_card.dart';
import '../../widgets/inputs/custom_toggle.dart';
import '../../widgets/inputs/segmented_control.dart';

/// Pantalla de configuración de partida
class GameSetupScreen extends StatefulWidget {
  const GameSetupScreen({super.key});

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  int _selectedGameType = 0;
  bool _laRealEnabled = true;
  bool _ordagoAutomaticoEnabled = false;
  int _selectedTable = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Configurar Partida', style: AppTextStyles.headline),
        actions: [
          IconButton(icon: const Icon(Icons.help_outline), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Tipo de juego
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SegmentedControl(
                  options: const ['8 Reyes (Estándar)', '4 Reyes (Vasco)'],
                  selectedIndex: _selectedGameType,
                  onChanged: (index) {
                    setState(() {
                      _selectedGameType = index;
                    });
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Reglas de la variante
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'REGLAS DE LA VARIANTE',
                  style: AppTextStyles.caption.copyWith(letterSpacing: 1.2),
                ),
              ),

              const SizedBox(height: 12),

              _buildRuleItem(
                'La Real',
                'Combinación de Tres Sietes y Sota.',
                _laRealEnabled,
                (value) {
                  setState(() {
                    _laRealEnabled = value;
                  });
                },
                hasCheckbox: true,
              ),

              _buildRuleItem(
                'Órdago Automático',
                'Finalizar al primer órdago aceptado.',
                _ordagoAutomaticoEnabled,
                (value) {
                  setState(() {
                    _ordagoAutomaticoEnabled = value;
                  });
                },
              ),

              _buildScoreLimit(),

              const SizedBox(height: 16),

              // Guía de Señas
              _buildSignalsGuide(),

              const SizedBox(height: 24),

              // Mesa y Baraja
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'MESA Y BARAJA',
                  style: AppTextStyles.caption.copyWith(letterSpacing: 1.2),
                ),
              ),

              const SizedBox(height: 12),

              _buildTableSelector(),

              const SizedBox(height: 24),

              // Botón comenzar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PrimaryButton(
                  text: 'Comenzar Partida',
                  onPressed: () {
                    Navigator.of(context).pushNamed('/game-table');
                  },
                  width: double.infinity,
                  icon: Icons.play_arrow,
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRuleItem(
    String title,
    String description,
    bool value,
    ValueChanged<bool> onChanged, {
    bool hasCheckbox = false,
  }) {
    return InfoCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (hasCheckbox)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Checkbox(
                value: value,
                onChanged: (val) => onChanged(val ?? false),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleMedium),
                const SizedBox(height: 4),
                Text(description, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          if (!hasCheckbox) CustomToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildScoreLimit() {
    return InfoCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryGreenDark,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.bar_chart,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Puntaje de Amaracos', style: AppTextStyles.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Límite para ganar la partida.',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '40',
            style: AppTextStyles.title.copyWith(color: AppColors.accentGold),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildSignalsGuide() {
    return GameCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Guía de Señas', style: AppTextStyles.title),
          const SizedBox(height: 8),
          Text(
            'Domina el arte de la comunicación silenciosa\nen la mesa.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 16),
          ActionButton(
            text: 'Aprender Señas',
            onPressed: () {},
            type: ActionButtonType.gold,
            icon: Icons.visibility,
          ),
        ],
      ),
    );
  }

  Widget _buildTableSelector() {
    return SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildTableOption('Verde Clásico', AppColors.tableGreenClassic, 0),
          _buildTableOption('Granate Real', AppColors.tableGranate, 1),
          _buildTableOption('Azul Casino', AppColors.tableBlue, 2),
        ],
      ),
    );
  }

  Widget _buildTableOption(String name, Color color, int index) {
    final isSelected = _selectedTable == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTable = index;
        });
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              height: 90,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.textPrimary
                      : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/game/models/ai_profile.dart';
import '../../core/game/models/game_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/buttons/primary_button.dart';
import 'game_screen.dart';

class GameConfigScreen extends StatefulWidget {
  const GameConfigScreen({required this.partnerProfile, super.key});

  final AiProfile partnerProfile;

  @override
  State<GameConfigScreen> createState() => _GameConfigScreenState();
}

class _GameConfigScreenState extends State<GameConfigScreen> {
  // Config state
  bool _eightKings = false; // 4 Reyes default
  bool _laReal = false;
  bool _autoOrdago = false;
  int _maxPoints = 40;

  // Visual selection (not functional yet for logic, just visual)
  int _selectedDeckIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurar Partida', style: AppTextStyles.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 8 Reyes Selection
              _buildKingsSelector(),

              const SizedBox(height: 32),

              Text(
                'REGLAS DE LA VARIANTE',
                style: AppTextStyles.caption.copyWith(letterSpacing: 1.2),
              ),
              const SizedBox(height: 16),

              // La Real
              _buildSwitchTile(
                title: 'La Real',
                subtitle: 'Combinación de Tres Sietes y Sota.',
                value: _laReal,
                onChanged: (v) => setState(() => _laReal = v),
              ),

              const SizedBox(height: 16),

              // Órdago Automático
              _buildSwitchTile(
                title: 'Órdago Automático',
                subtitle: 'Finalizar al primer órdago aceptado.',
                value: _autoOrdago,
                onChanged: (v) => setState(() => _autoOrdago = v),
              ),

              const SizedBox(height: 16),

              // Max Points
              _buildPointsSelector(),

              const SizedBox(height: 32),

              Text(
                'MESA Y BARAJA',
                style: AppTextStyles.caption.copyWith(letterSpacing: 1.2),
              ),
              const SizedBox(height: 16),

              // Deck/Table Selector (Visual Placeholder)
              _buildDeckSelector(),

              const SizedBox(height: 48),

              // Start Button
              PrimaryButton(
                text: 'Comenzar Partida',
                onPressed: _startGame,
                width: double.infinity,
                icon: Icons.play_circle_filled,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKingsSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _eightKings = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _eightKings
                      ? AppColors.primaryGreen.withAlpha(100)
                      : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(11),
                  ),
                ),
                child: Center(
                  child: Text(
                    '8 Reyes (Estándar)',
                    style: TextStyle(
                      color: _eightKings
                          ? AppColors.primaryGreen
                          : AppColors.textSecondary,
                      fontWeight: _eightKings
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.border),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _eightKings = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: !_eightKings
                      ? AppColors.primaryGreen.withAlpha(100)
                      : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(11),
                  ),
                ),
                child: Center(
                  child: Text(
                    '4 Reyes (Vasco)',
                    style: TextStyle(
                      color: !_eightKings
                          ? AppColors.primaryGreen
                          : AppColors.textSecondary,
                      fontWeight: !_eightKings
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyBold),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primaryGreen.withAlpha(100),
            activeThumbColor: AppColors.primaryGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildPointsSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Puntaje de Amarracos', style: AppTextStyles.bodyBold),
              Text(
                'Límite para ganar la partida.',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          DropdownButton<int>(
            value: _maxPoints,
            dropdownColor: AppColors.surfaceLight,
            style: AppTextStyles.bodyBold.copyWith(color: AppColors.textMain),
            underline: Container(),
            icon: const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
            items: [30, 40].map((int value) {
              return DropdownMenuItem<int>(value: value, child: Text('$value'));
            }).toList(),
            onChanged: (int? newValue) {
              if (newValue != null) {
                setState(() => _maxPoints = newValue);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDeckSelector() {
    return Row(
      children: [
        _buildColorOption(0, AppColors.primaryGreen, 'Verde Clásico'),
        const SizedBox(width: 12),
        _buildColorOption(1, const Color(0xFF8B2E2E), 'Granate Real'),
        const SizedBox(width: 12),
        _buildColorOption(2, const Color(0xFF2E3B8B), 'Azul Casino'),
      ],
    );
  }

  Widget _buildColorOption(int index, Color color, String label) {
    final isSelected = _selectedDeckIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDeckIndex = index),
        child: Column(
          children: [
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(color: Colors.white, width: 2)
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isSelected ? AppColors.textMain : AppColors.textTertiary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _startGame() {
    final config = GameConfig(
      eightKings: _eightKings,
      real31: _laReal,
      maxPoints: _maxPoints,
      autoOrdago: _autoOrdago,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            GameScreen(partnerProfile: widget.partnerProfile, config: config),
      ),
    );
  }
}

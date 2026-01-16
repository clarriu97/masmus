import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class GameControls extends StatelessWidget {
  const GameControls({
    required this.onAction,
    super.key,
    this.canMus = false,
    this.canCut = false,
    this.canPass = false,
    this.canEnvido = false,
    this.canOrdago = false,
    this.canQuiero = false,
    this.canNoQuiero = false,
  });

  final Function(String action) onAction;
  final bool canMus;
  final bool canCut;
  final bool canPass;
  final bool canEnvido;
  final bool canOrdago;
  final bool canQuiero;
  final bool canNoQuiero;

  @override
  Widget build(BuildContext context) {
    // Mus Phase
    if (canMus || canCut) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _GameButton(
            label: 'MUS',
            color: AppColors.primaryGreen,
            onPressed: canMus ? () => onAction('MUS') : null,
          ),
          _GameButton(
            label: 'NO HAY MUS',
            color: AppColors.accentRed,
            onPressed: canCut ? () => onAction('NO HAY MUS') : null,
          ),
        ],
      );
    }

    // Response Phase (Quiero / No Quiero)
    if (canQuiero || canNoQuiero) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _GameButton(
            label: 'QUIERO',
            color: AppColors.primaryGreen,
            onPressed: canQuiero ? () => onAction('QUIERO') : null,
          ),
          _GameButton(
            label: 'NO QUIERO',
            color: AppColors.accentRed,
            onPressed: canNoQuiero ? () => onAction('NO QUIERO') : null,
          ),
          // Can also raise in response? Usually yes.
          if (canEnvido)
            _GameButton(
              label: 'ENVIDO',
              color: AppColors.accentGold,
              onPressed: () => onAction('ENVIDO'),
            ),
          if (canOrdago)
            _GameButton(
              label: 'ÓRDAGO',
              color: AppColors.accentRedDark,
              onPressed: () => onAction('ORDAGO'),
            ),
        ],
      );
    }

    // Betting Phase (Paso / Envido / Ordago)
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        _GameButton(
          label: 'PASO',
          color: AppColors.textDisabled,
          onPressed: canPass ? () => onAction('PASO') : null,
        ),
        _GameButton(
          label: 'ENVIDO',
          color: AppColors.accentGold,
          onPressed: canEnvido ? () => onAction('ENVIDO') : null,
        ),
        _GameButton(
          label: 'ÓRDAGO',
          color: AppColors.accentRedDark,
          onPressed: canOrdago ? () => onAction('ORDAGO') : null,
        ),
      ],
    );
  }
}

class _GameButton extends StatelessWidget {
  const _GameButton({required this.label, required this.color, this.onPressed});

  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

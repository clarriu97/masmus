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

  final Function(String action, {int? amount}) onAction;
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
            color: AppColors.accentGold, // Changed color for contrast
            textColor: Colors.black,
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
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 12,
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
          if (canEnvido) ...[
            _GameButton(
              label: 'ENVIDO (2)',
              color: AppColors.primaryGreenLight,
              onPressed: () => onAction('ENVIDO', amount: 2),
            ),
            _GameButton(
              label: 'ENVIDAR...',
              color: AppColors.primaryGreenDark,
              onPressed: () => _showBetOptions(context),
            ),
          ],
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
        if (canEnvido) ...[
          _GameButton(
            label: 'ENVIDO (2)',
            color: AppColors.primaryGreenLight,
            onPressed: () => onAction('ENVIDO', amount: 2),
          ),
          _GameButton(
            label: 'ENVIDAR...',
            color: AppColors.primaryGreenDark,
            onPressed: () => _showBetOptions(context),
          ),
        ],
        _GameButton(
          label: 'ÓRDAGO',
          color: AppColors.accentRedDark,
          onPressed: canOrdago ? () => onAction('ORDAGO') : null,
        ),
      ],
    );
  }

  void _showBetOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '¿Cuánto quieres envidar?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [5, 10, 20, 30].map((amount) {
                  return _GameButton(
                    label: '$amount',
                    color: AppColors.primaryGreenLight,
                    onPressed: () {
                      Navigator.pop(context);
                      onAction('ENVIDO', amount: amount);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GameButton extends StatelessWidget {
  const _GameButton({
    required this.label,
    required this.color,
    this.onPressed,
    this.textColor = Colors.white,
  });

  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

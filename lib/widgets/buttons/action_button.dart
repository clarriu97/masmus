import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum ActionButtonType { red, gold }

/// Botón de acción con variantes rojo y amarillo/oro
class ActionButton extends StatelessWidget {
  const ActionButton({
    required this.text,
    super.key,
    this.onPressed,
    this.type = ActionButtonType.red,
    this.icon,
    this.width,
  });

  final String text;
  final VoidCallback? onPressed;
  final ActionButtonType type;
  final IconData? icon;
  final double? width;

  Color get backgroundColor {
    switch (type) {
      case ActionButtonType.red:
        return AppColors.accentRed;
      case ActionButtonType.gold:
        return AppColors.accentGold;
    }
  }

  Color get textColor {
    switch (type) {
      case ActionButtonType.red:
        return AppColors.textPrimary;
      case ActionButtonType.gold:
        return AppColors.backgroundDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.2),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: textColor),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                text,
                style: AppTextStyles.buttonSmall.copyWith(color: textColor),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

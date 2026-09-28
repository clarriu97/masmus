import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum ActionKind { primary, secondary, ordago }

/// One of the player's moves: its label, an optional detail under it and a
/// look that tells the kinds apart at a glance.
class ActionButton extends StatelessWidget {
  const ActionButton({
    required this.label,
    required this.onPressed,
    this.detail,
    this.kind = ActionKind.secondary,
    super.key,
  });

  final String label;
  final String? detail;
  final ActionKind kind;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final detail = this.detail;
    return FilledButton(
      style: switch (kind) {
        ActionKind.primary => AppTheme.primaryButton,
        ActionKind.secondary => AppTheme.secondaryButton,
        ActionKind.ordago => AppTheme.ordagoButton,
      },
      onPressed: onPressed,
      child: detail == null
          ? Text(label, textAlign: TextAlign.center)
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, textAlign: TextAlign.center),
                Text(detail, style: AppTheme.actionDetail),
              ],
            ),
    );
  }
}

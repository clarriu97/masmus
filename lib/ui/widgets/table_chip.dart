import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A short fact on the table: "Mano", "Duples R-7", "Juego 34".
/// [highlighted] ones are in brass, like whose turn it is.
class TableChip extends StatelessWidget {
  const TableChip(this.label, {this.highlighted = false, super.key});

  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: ShapeDecoration(
      shape: const StadiumBorder(),
      color: highlighted ? AppColors.turn : AppColors.chip,
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: highlighted ? AppColors.onTurn : AppColors.ink,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}

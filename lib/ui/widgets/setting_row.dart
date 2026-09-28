import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A setting's name and its options, side by side while they fit.
class SettingRow extends StatelessWidget {
  const SettingRow({required this.label, required this.control, super.key});

  final String label;
  final Widget control;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.spaceBetween,
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: AppSpacing.md,
    runSpacing: AppSpacing.sm,
    children: [
      Text(label, style: Theme.of(context).textTheme.titleMedium),
      control,
    ],
  );
}

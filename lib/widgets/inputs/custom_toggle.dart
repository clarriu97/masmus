import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Toggle switch personalizado con estilo de MASMUS
class CustomToggle extends StatelessWidget {
  const CustomToggle({required this.value, super.key, this.onChanged});
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeTrackColor: AppColors.success,
      inactiveThumbColor: AppColors.textPrimary,
      inactiveTrackColor: AppColors.border,
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// What a player said, next to their seat: "No hay mus", "Envido 2", "Paso".
class SpeechBubble extends StatelessWidget {
  const SpeechBubble(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColors.bubble,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      boxShadow: AppShadows.raised,
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 2,
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.onBubble,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}

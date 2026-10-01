import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// One of a few options to pick from, with a line that explains it. The
/// chosen one is edged in brass.
class ChoiceTile extends StatelessWidget {
  const ChoiceTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.leading,
    super.key,
  });

  /// A picture beside the words, such as a bot's face.
  final Widget? leading;

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.md),
      side: selected
          ? const BorderSide(color: AppColors.turn, width: 2)
          : const BorderSide(color: AppColors.line, width: 1.5),
    );
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.chip : AppColors.none,
        shape: shape,
        child: InkWell(
          customBorder: shape,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: kMinTapTarget),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                spacing: AppSpacing.sm,
                children: [
                  ?leading,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      spacing: AppSpacing.xs,
                      children: [
                        Text(title, style: text.titleMedium),
                        Text(subtitle, style: text.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

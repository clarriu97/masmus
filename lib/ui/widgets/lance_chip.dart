import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum LanceChipState { pending, current, done }

/// A lance in the row at the top of the table: done ones say how they went,
/// the one being played is in brass, the rest wait.
class LanceChip extends StatelessWidget {
  const LanceChip({
    required this.lance,
    required this.state,
    this.status,
    super.key,
  });

  final String lance;
  final String? status;
  final LanceChipState state;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final ink = switch (state) {
      LanceChipState.current => AppColors.onTurn,
      LanceChipState.done => AppColors.ink,
      LanceChipState.pending => AppColors.inkSecondary,
    };
    final status = this.status;
    return MergeSemantics(
      child: Semantics(
        selected: state == LanceChipState.current,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: switch (state) {
              LanceChipState.current => AppColors.turn,
              LanceChipState.done => AppColors.chip,
              LanceChipState.pending => null,
            },
            border: state == LanceChipState.pending
                ? Border.all(color: AppColors.line, width: 1.5)
                : null,
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xs,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Line(
                  lance,
                  text.titleSmall?.copyWith(
                    color: ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (status != null)
                  _Line(status, text.labelSmall?.copyWith(color: ink)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One line that shrinks a little rather than break a word when the row is
/// narrow.
class _Line extends StatelessWidget {
  const _Line(this.text, this.style);

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    child: Text(text, style: style, maxLines: 1),
  );
}

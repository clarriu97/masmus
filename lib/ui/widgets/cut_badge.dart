import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Who cut the mus: a pair of scissors on a cream disc, kept by that
/// player for the rest of the hand.
class CutBadge extends StatelessWidget {
  const CutBadge({this.size = 30, super.key});

  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const ShapeDecoration(
        shape: CircleBorder(
          side: BorderSide(color: AppColors.cardInk, width: 2),
        ),
        color: AppColors.card,
        shadows: AppShadows.raised,
      ),
      child: Icon(
        Icons.content_cut,
        size: size * 0.55,
        color: AppColors.cardInk,
      ),
    ),
  );
}

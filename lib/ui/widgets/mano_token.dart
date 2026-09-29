import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The token of the mano, the player who speaks first: a cream disc with
/// an «M», like the dealer's button at a poker table, in the colours of the deck. It sits on the
/// mano's seat and moves with the mano.
class ManoToken extends StatelessWidget {
  const ManoToken({this.size = 30, super.key});

  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const ShapeDecoration(
        shape: CircleBorder(
          side: BorderSide(color: AppColors.cardBack, width: 3),
        ),
        color: AppColors.card,
        shadows: AppShadows.raised,
      ),
      child: Text(
        'M',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.cardBack,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
        textScaler: TextScaler.noScaling,
      ),
    ),
  );
}

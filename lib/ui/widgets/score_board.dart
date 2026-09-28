import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The score the way a Mus table keeps it: each team's tantos in figures,
/// and under them in stones.
class ScoreBoard extends StatelessWidget {
  const ScoreBoard({
    required this.usLabel,
    required this.us,
    required this.themLabel,
    required this.them,
    super.key,
  });

  final String usLabel;
  final int us;
  final String themLabel;
  final int them;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: AppSpacing.xl,
    children: [
      _Team(label: usLabel, points: us),
      const SizedBox.square(
        dimension: 4,
        child: DecoratedBox(
          decoration: ShapeDecoration(
            shape: CircleBorder(),
            color: AppColors.inkSecondary,
          ),
        ),
      ),
      _Team(label: themLabel, points: them),
    ],
  );
}

class _Team extends StatelessWidget {
  const _Team({required this.label, required this.points});

  final String label;
  final int points;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return MergeSemantics(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.xs,
        children: [
          Text(label.toUpperCase(), style: text.labelMedium),
          Text('$points', style: text.displaySmall),
          ExcludeSemantics(child: Amarracos(points)),
        ],
      ),
    );
  }
}

/// [points] in stones: an amarraco (a big one) for every five tantos and a
/// small stone for each one left.
class Amarracos extends StatelessWidget {
  const Amarracos(this.points, {super.key});

  final int points;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 3,
    children: [
      for (var i = 0; i < points ~/ 5; i++) const Stone(big: true),
      for (var i = 0; i < points % 5; i++) const Stone(big: false),
    ],
  );
}

class Stone extends StatelessWidget {
  const Stone({required this.big, super.key});

  final bool big;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: big ? 11 : 6,
    child: const DecoratedBox(
      decoration: ShapeDecoration(
        shape: CircleBorder(),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.6, 1],
          colors: [AppColors.stone, AppColors.stoneShade],
        ),
      ),
    ),
  );
}

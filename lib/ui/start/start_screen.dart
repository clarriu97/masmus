import 'package:flutter/material.dart';

import '../../bots/heuristic_bot.dart';
import '../../game/cards.dart';
import '../../game/rules.dart';
import '../../l10n/app_localizations.dart';
import '../cards/playing_card_view.dart';
import '../theme/app_theme.dart';
import '../widgets/action_button.dart';
import '../widgets/felt.dart';
import 'new_match_screen.dart';

/// Where the app opens: what the game is and a way into a new match.
class StartScreen extends StatelessWidget {
  const StartScreen({required this.table, super.key});

  /// The table a new match is played on.
  final Widget Function(Personality partner, Rules rules) table;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: Felt(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xxl,
              AppSpacing.xl,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.startTitle, style: text.displayMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.startSubtitle,
                  style: text.bodyLarge?.copyWith(
                    color: AppColors.inkSecondary,
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: FittedBox(child: ExcludeSemantics(child: _Fan())),
                  ),
                ),
                ActionButton(
                  label: l10n.newMatch,
                  kind: ActionKind.primary,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => NewMatchScreen(
                        onStart: (partner, rules) =>
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute<void>(
                                builder: (_) => table(partner, rules),
                              ),
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// La 31 fanned out: rey, caballo, siete and cuatro.
class _Fan extends StatelessWidget {
  const _Fan();

  static final _cards = [
    for (final code in ['Ro', 'Cc', '7e', '4b']) PlayingCard.parse(code),
  ];

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 300,
    height: 190,
    child: Stack(
      alignment: Alignment.bottomCenter,
      children: [
        for (final (i, card) in _cards.indexed)
          Positioned(
            bottom: 10,
            left: 32 + i * 46.0,
            child: Transform.rotate(
              angle: (i - 1.5) * 0.14,
              alignment: Alignment.bottomCenter,
              child: PlayingCardView(card, width: 92),
            ),
          ),
      ],
    ),
  );
}

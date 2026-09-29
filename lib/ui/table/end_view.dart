import 'package:flutter/material.dart';

import '../../game/match.dart';
import '../../game/table.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/action_button.dart';
import '../widgets/felt.dart';
import '../widgets/score_board.dart';

/// The end of a juego: who won it, its final score and how it went, and
/// in a match of several juegos how the match stands. Then the next juego
/// or, once the match is won, a rematch or back to the start.
class EndView extends StatelessWidget {
  const EndView({
    required this.match,
    required this.you,
    required this.onRematch,
    required this.onHome,
    required this.onNextGame,
    super.key,
  });

  final MatchState match;
  final int you;
  final VoidCallback onRematch;
  final VoidCallback onHome;
  final VoidCallback onNextGame;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final us = teamOf(you);
    final score = match.scoreNow;
    final games = match.gamesNow;
    final over = match.isMatchOver;
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
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      spacing: AppSpacing.xl,
                      children: [
                        Text(
                          !over
                              ? l10n.endGameWon(
                                  match.winner == us ? 'us' : 'them',
                                )
                              : match.matchWinner == us
                              ? l10n.endWon
                              : l10n.endLost,
                          textAlign: TextAlign.center,
                          style: text.displayMedium?.copyWith(
                            color: match.winner == us && over
                                ? AppColors.turn
                                : AppColors.ink,
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: ScoreBoard(
                            usLabel: l10n.teamUs,
                            us: score[us],
                            themLabel: l10n.teamThem,
                            them: score[1 - us],
                          ),
                        ),
                        Text(
                          l10n.endSummary(match.handNumber, match.end!.name),
                          textAlign: TextAlign.center,
                          style: text.bodyLarge?.copyWith(
                            color: AppColors.inkSecondary,
                          ),
                        ),
                        if (match.rules.games > 1)
                          Text(
                            l10n.endGames(
                              games[us],
                              games[1 - us],
                              match.rules.games,
                            ),
                            textAlign: TextAlign.center,
                            style: text.titleMedium,
                          ),
                      ],
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.sm,
                  children: [
                    if (over) ...[
                      ActionButton(
                        label: l10n.endRematch,
                        kind: ActionKind.primary,
                        onPressed: onRematch,
                      ),
                      ActionButton(label: l10n.endHome, onPressed: onHome),
                    ] else
                      ActionButton(
                        label: l10n.endNextGame,
                        kind: ActionKind.primary,
                        onPressed: onNextGame,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

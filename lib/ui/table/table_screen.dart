import 'dart:math';

import 'package:flutter/material.dart';

import '../../bots/heuristic_bot.dart';
import '../../controllers/match_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/localized_names.dart';
import '../cards/playing_card_view.dart';
import '../theme/app_theme.dart';
import '../widgets/felt.dart';
import '../widgets/lance_chip.dart';
import '../widgets/score_board.dart';
import '../widgets/table_chip.dart';
import 'seat.dart';
import 'table_actions.dart';
import 'table_texts.dart';
import 'table_view.dart';

/// The match being played, seen from your seat: the score, where the hand
/// is and how each lance went, who is mano and whose turn it is, what each
/// player just said and what is on the table, and your cards.
class TableScreen extends StatelessWidget {
  const TableScreen({
    required this.controller,
    required this.bots,
    required this.onExit,
    super.key,
  });

  final MatchController controller;

  /// Who plays every seat but yours.
  final Map<int, Personality> bots;

  final VoidCallback onExit;

  /// The table is a board, dense by nature: its text grows with the
  /// system's up to this much, and the cards are already large.
  static const maxTextScale = 1.3;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final l10n = AppLocalizations.of(context);
      final view = TableView.of(controller.match, you: controller.humanSeat!);
      return MediaQuery.withClampedTextScaling(
        maxScaleFactor: maxTextScale,
        child: Scaffold(
          body: Felt(
            child: SafeArea(
              child: Column(
                children: [
                  _TopBar(view: view, onExit: onExit),
                  _Steps(view: view),
                  Expanded(
                    child: _Seats(view: view, bots: bots),
                  ),
                  _YourHand(view: view),
                  _Status(view: view, bots: bots),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      AppSpacing.sm,
                    ),
                    child: view.yourTurn && controller.humanMoves.isNotEmpty
                        ? TableActions(
                            key: ValueKey(controller.match.hand.phase),
                            moves: controller.humanMoves,
                            view: view,
                            bettor: switch (view.stake?.bettor) {
                              final bettor? when bots.containsKey(bettor) =>
                                l10n.personalityName(bots[bettor]!),
                              _ => null,
                            },
                            onMove: controller.play,
                          )
                        : _TurnBar(view: view, bots: bots),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.view, required this.onExit});

  final TableView view;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: onExit,
            icon: const Icon(Icons.close),
            label: Text(l10n.tableExit),
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: ScoreBoard(
                usLabel: l10n.teamUs,
                us: view.us,
                themLabel: l10n.teamThem,
                them: view.them,
                dense: true,
              ),
            ),
          ),
          Text(
            l10n.tableTarget(view.target),
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

/// The mus and the four lances, each with how it went.
class _Steps extends StatelessWidget {
  const _Steps({required this.view});

  final TableView view;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.xs,
          children: [
            for (final step in view.steps)
              Expanded(
                child: LanceChip(
                  lance: l10n.stepLabel(step),
                  status: l10n.stepStatus(step, view),
                  state: switch (step.state) {
                    StepProgress.pending => LanceChipState.pending,
                    StepProgress.current => LanceChipState.current,
                    StepProgress.done => LanceChipState.done,
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Your partner across the table, the rivals at the sides and what is bet
/// in the middle. On a short screen the three sit in a row, and the bet is
/// read in the row of the hand; scaled down if it still doesn't fit.
class _Seats extends StatelessWidget {
  const _Seats({required this.view, required this.bots});

  static const compactBelow = 260.0;

  final TableView view;
  final Map<int, Personality> bots;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget seatOf(int seat) => Seat(
      name: l10n.personalityName(bots[seat]!),
      role: l10n.seatRole(view, seat),
      thinking: view.turn == seat,
      said: switch (view.said[seat]) {
        final event? => l10n.said(event, view),
        null => null,
      },
    );
    final you = view.you;
    return LayoutBuilder(
      builder: (context, constraints) => FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: constraints.maxWidth,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.md,
            ),
            child: constraints.maxHeight < compactBelow
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final seat in [you + 3, you + 2, you + 1])
                        Expanded(child: seatOf(seat % 4)),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: AppSpacing.md,
                    children: [
                      seatOf((you + 2) % 4),
                      Row(
                        children: [
                          Expanded(child: seatOf((you + 3) % 4)),
                          _Stake(view: view),
                          Expanded(child: seatOf((you + 1) % 4)),
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

/// What is bet in the lance being played.
class _Stake extends StatelessWidget {
  const _Stake({required this.view});

  final TableView view;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final stake = view.stake;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.line, width: 1.5),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.tableStake, style: text.labelSmall),
            Text(
              switch (stake) {
                null => '—',
                _ when stake.ordago => l10n.stepOrdago,
                _ => '${stake.stake}',
              },
              style: text.displaySmall,
              semanticsLabel: stake == null ? l10n.tableStakeNone : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Your cards, big, with what they are worth above them.
class _YourHand extends StatelessWidget {
  const _YourHand({required this.view});

  final TableView view;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        spacing: AppSpacing.sm,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              spacing: AppSpacing.sm,
              children: [
                if (view.mano == view.you)
                  TableChip(l10n.tableMano, highlighted: true),
                for (final help in l10n.handHelp(view.value)) TableChip(help),
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final byHeight =
                  MediaQuery.sizeOf(context).height *
                  0.155 *
                  PlayingCardView.aspectRatio;
              final width = [
                (constraints.maxWidth - 3 * AppSpacing.sm) / 4,
                byHeight,
                88.0,
              ].reduce(min);
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: AppSpacing.sm,
                children: [
                  for (final card in view.cards)
                    PlayingCardView(card, width: width),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// What the table is at, for screen readers: the lance, whose turn it is
/// and what is bet. Announced whenever it changes.
class _Status extends StatelessWidget {
  const _Status({required this.view, required this.bots});

  final TableView view;
  final Map<int, Personality> bots;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = view.steps.firstWhere(
      (step) => step.state == StepProgress.current,
      orElse: () => view.steps.last,
    );
    final stake = view.stake;
    return Semantics(
      liveRegion: true,
      label: [
        l10n.stepLabel(current),
        ?_turnText(l10n, view, bots),
        l10n.tableStakeIs(switch (stake) {
          null => l10n.tableStakeNone,
          _ when stake.ordago => l10n.stepOrdago,
          _ => '${stake.stake}',
        }),
      ].join('. '),
      child: const SizedBox.shrink(),
    );
  }
}

String? _turnText(
  AppLocalizations l10n,
  TableView view,
  Map<int, Personality> bots,
) => switch (view.turn) {
  null => null,
  _ when view.yourTurn => l10n.tableYourTurn,
  final turn => l10n.tableTurnOf(l10n.personalityName(bots[turn]!)),
};

/// Whose turn it is, while it isn't yours.
class _TurnBar extends StatelessWidget {
  const _TurnBar({required this.view, required this.bots});

  final TableView view;
  final Map<int, Personality> bots;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      constraints: const BoxConstraints(minHeight: kActionHeight),
      alignment: Alignment.center,
      decoration: const ShapeDecoration(
        shape: StadiumBorder(
          side: BorderSide(color: AppColors.line, width: 1.5),
        ),
      ),
      child: Text(
        _turnText(AppLocalizations.of(context), view, bots) ?? '',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    ),
  );
}

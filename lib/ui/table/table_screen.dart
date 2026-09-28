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
                  _TurnBar(view: view, bots: bots),
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
/// in the middle; scaled down to fit when the screen is short.
class _Seats extends StatelessWidget {
  const _Seats({required this.view, required this.bots});

  final TableView view;
  final Map<int, Personality> bots;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget seat(int seat) => Seat(
      name: l10n.personalityName(bots[seat]!),
      role: l10n.seatRole(view, seat),
      thinking: view.turn == seat,
      said: switch (view.said[seat]) {
        final event? => l10n.said(event),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: AppSpacing.md,
              children: [
                seat((you + 2) % 4),
                Row(
                  children: [
                    Expanded(child: seat((you + 3) % 4)),
                    _Stake(view: view),
                    Expanded(child: seat((you + 1) % 4)),
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
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              if (view.mano == view.you)
                TableChip(l10n.tableMano, highlighted: true),
              for (final help in l10n.handHelp(view.value)) TableChip(help),
            ],
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = ((constraints.maxWidth - 3 * AppSpacing.sm) / 4)
                  .clamp(0.0, 88.0);
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

/// Whose turn it is, and what the table is at, for screen readers too.
class _TurnBar extends StatelessWidget {
  const _TurnBar({required this.view, required this.bots});

  final TableView view;
  final Map<int, Personality> bots;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final turn = view.turn;
    final label = switch (turn) {
      null => null,
      _ when view.yourTurn => l10n.tableYourTurn,
      _ => l10n.tableTurnOf(l10n.personalityName(bots[turn]!)),
    };
    final current = view.steps.firstWhere(
      (step) => step.state == StepProgress.current,
      orElse: () => view.steps.last,
    );
    final stake = view.stake;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Semantics(
        liveRegion: true,
        label: [
          l10n.stepLabel(current),
          ?label,
          l10n.tableStakeIs(switch (stake) {
            null => l10n.tableStakeNone,
            _ when stake.ordago => l10n.stepOrdago,
            _ => '${stake.stake}',
          }),
        ].join('. '),
        child: ExcludeSemantics(
          child: Container(
            constraints: const BoxConstraints(minHeight: kActionHeight),
            alignment: Alignment.center,
            decoration: ShapeDecoration(
              shape: const StadiumBorder(
                side: BorderSide(color: AppColors.line, width: 1.5),
              ),
              color: view.yourTurn ? AppColors.turn : AppColors.none,
            ),
            child: Text(
              label ?? '',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: view.yourTurn ? AppColors.onTurn : AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../game/cards.dart';
import '../../game/count.dart';
import '../../game/event.dart';
import '../../game/hand_state.dart';
import '../../game/hand_value.dart';
import '../../game/match.dart';
import '../../game/outcome.dart';
import '../../game/table.dart';
import '../../l10n/app_localizations.dart';
import '../cards/playing_card_view.dart';
import '../theme/app_theme.dart';
import '../widgets/action_button.dart';
import '../widgets/felt.dart';
import 'table_texts.dart';

/// The end of a hand: the four hands face up and, lance by lance, who takes
/// it, with what, why and how many tantos, exactly as the engine counted
/// them; the score before and after; and every card thrown away, for anyone
/// who wants to check the deal.
class CountView extends StatelessWidget {
  const CountView({
    required this.match,
    required this.you,
    required this.names,
    required this.onNext,
    required this.onExit,
    super.key,
  });

  final MatchState match;
  final int you;

  /// Who sits in each seat, yours included.
  final Map<int, String> names;

  final VoidCallback onNext;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final count = match.count!;
    final hand = match.hand;
    final us = teamOf(you);
    String team(int team) => team == us ? 'us' : 'them';
    final winner = count.winner;
    return Scaffold(
      body: Felt(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: AppSpacing.md,
                    children: [
                      Text(l10n.countTitle, style: text.displayMedium),
                      _Hands(hand: hand, you: you, names: names),
                      _Lances(
                        hand: hand,
                        count: count,
                        names: names,
                        team: team,
                      ),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        spacing: AppSpacing.md,
                        children: [
                          for (final side in [us, 1 - us])
                            Text(
                              l10n.countScore(
                                team(side),
                                count.before[side],
                                count.after[side],
                              ),
                              style: text.titleMedium,
                            ),
                        ],
                      ),
                      if (winner != null)
                        Text(
                          l10n.countWon(team(winner)),
                          textAlign: TextAlign.center,
                          style: text.headlineSmall?.copyWith(
                            color: AppColors.turn,
                          ),
                        ),
                      Center(
                        child: TextButton(
                          onPressed: () => _showDeal(context),
                          child: Text(l10n.countDeal),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: ActionButton(
                  label: match.isOver ? l10n.tableExit : l10n.countNextHand,
                  kind: ActionKind.primary,
                  onPressed: match.isOver ? onExit : onNext,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeal(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _Deal(hand: match.hand, names: names),
  );
}

/// The four hands face up, from the mano on.
class _Hands extends StatelessWidget {
  const _Hands({required this.hand, required this.you, required this.names});

  final HandState hand;
  final int you;
  final Map<int, String> names;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final order = speakingOrder(hand.mano);
    Widget panel(int seat) {
      final role = seat == you
          ? (seat == hand.mano ? l10n.tableMano : null)
          : l10n.roleSeat(
              teamOf(seat) == teamOf(you) ? 'partner' : 'rival',
              seat == hand.mano ? 'mano' : 'none',
            );
      return DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.line, width: 1.5),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.xs,
            children: [
              Wrap(
                spacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(names[seat]!, style: text.titleSmall),
                  if (role != null) Text(role, style: text.labelSmall),
                ],
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  spacing: AppSpacing.xs,
                  children: [
                    for (final card in hand.hands[seat])
                      PlayingCardView(card, width: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      spacing: AppSpacing.sm,
      children: [
        for (var i = 0; i < 4; i += 2)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.sm,
              children: [
                Expanded(child: panel(order[i])),
                Expanded(child: panel(order[i + 1])),
              ],
            ),
          ),
      ],
    );
  }
}

/// One line per lance, in the order they are counted.
class _Lances extends StatelessWidget {
  const _Lances({
    required this.hand,
    required this.count,
    required this.names,
    required this.team,
  });

  final HandState hand;
  final HandCount count;
  final Map<int, String> names;
  final String Function(int team) team;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.line, width: 1.5),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        children: [
          for (final (i, lance) in count.lances.indexed) ...[
            if (i > 0) const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: AppSpacing.md,
                      children: [
                        Text(
                          l10n.stepName(lance.outcome.lance.name),
                          style: text.titleSmall,
                        ),
                        Text(switch (lance) {
                          LanceCount(:final team?, :final points)
                              when points > 0 =>
                            l10n.countPoints(this.team(team), points),
                          _ => '—',
                        }, style: text.titleSmall),
                      ],
                    ),
                  ),
                  Text(
                    l10n.countWho(lance, hand, names, team),
                    style: text.bodyMedium,
                  ),
                  Text(l10n.countWhy(lance, hand), style: text.bodySmall),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Every card thrown away in the hand, by whom when it can be told, and
/// that the 40 are all there.
class _Deal extends StatelessWidget {
  const _Deal({required this.hand, required this.names});

  final HandState hand;
  final Map<int, String> names;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final discarded = hand.log.whereType<Discarded>().toList();
    final reshuffled = hand.log.any((event) => event is Reshuffled);
    final groups = <(String, List<PlayingCard>)>[];
    if (!reshuffled) {
      var next = 0;
      for (final event in discarded) {
        groups.add((
          l10n.dealDiscards(names[event.seat]!),
          hand.discards.sublist(next, next += event.count),
        ));
      }
    } else if (hand.discards.isNotEmpty) {
      groups.add((l10n.dealAllDiscards, hand.discards));
    }
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          0,
          AppSpacing.xl,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.md,
          children: [
            Text(l10n.dealTitle, style: text.headlineSmall),
            if (discarded.isEmpty)
              Text(l10n.dealNoDiscards, style: text.bodyMedium),
            for (final (title, cards) in groups) ...[
              Text(title, style: text.titleSmall),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final card in cards) PlayingCardView(card, width: 40),
                ],
              ),
            ],
            Text(
              l10n.dealTotal(16, hand.discards.length, hand.stock.length),
              style: text.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// The ranks of a hand as the count writes them: «R-R-7-7».
String rankCodes(Iterable<int> ranks) => [
  for (final rank in ranks)
    switch (rank) {
      12 => 'R',
      11 => 'C',
      10 => 'S',
      final number => '$number',
    },
].join('-');

extension CountTexts on AppLocalizations {
  /// Who takes a lance and with what.
  String countWho(
    LanceCount lance,
    HandState hand,
    Map<int, String> names,
    String Function(int team) teamName,
  ) {
    final seat = lance.seat;
    if (seat != null) {
      final value = hand.valueOf(seat);
      return countWinner(names[seat]!, switch (lance.outcome.lance) {
        Lance.grande => rankCodes(value.ranks),
        Lance.chica => rankCodes(value.ranks.reversed),
        Lance.pares => _lowerFirst(handHelp(value).first),
        Lance.juego => '${value.points}',
        Lance.punto => countPunto(value.points),
      });
    }
    return switch (lance) {
      LanceCount(team: final winner?) => countByNoQuiero(teamName(winner)),
      _ => countNobody(lance.outcome.lance.name),
    };
  }

  /// Why a lance counts, and what each hand of the winning pair adds.
  String countWhy(LanceCount lance, HandState hand) {
    if (!lance.counted) {
      return countNotCounted;
    }
    final why = switch (lance.outcome) {
      EnPaso() => countEnPaso,
      Querido(:final stake) => countQuerido(stake),
      NoQuerido(:final points) => countNoQuerido(points),
      SinDisputa() => countSinDisputa,
      OrdagoQuerido() => countOrdago,
      NotPlayed() => null,
    };
    final team = lance.team;
    final parts = team == null || lance.combinations == 0
        ? const <String>[]
        : [
            for (final seat in speakingOrder(hand.mano))
              if (teamOf(seat) == team)
                ?_part(lance.outcome.lance, hand.valueOf(seat)),
          ];
    return [?why, if (parts.isNotEmpty) parts.join(' + ')].join(' · ');
  }

  String? _part(Lance lance, HandValue value) => switch (lance) {
    Lance.pares when value.hasPares => countPart(
      value.pares.name,
      value.paresTantos,
    ),
    Lance.juego when value.hasJuego => countPart(
      value.points == 31 ? 'juego31' : 'juego',
      value.juegoTantos,
    ),
    _ => null,
  };
}

String _lowerFirst(String text) =>
    text.isEmpty ? text : text[0].toLowerCase() + text.substring(1);

import 'package:flutter/material.dart';

import '../../game/cards.dart';
import '../../game/hand_state.dart';
import '../../game/move.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/action_button.dart';
import '../widgets/hold_button.dart';
import 'table_view.dart';

/// Your moves when it is your turn: exactly the legal ones, in the thumb
/// zone. The amount of an envite is chosen here, without leaving the
/// table; above the answers, who bet what, and on «no quiero» what
/// refusing gives.
class TableActions extends StatefulWidget {
  const TableActions({
    required this.moves,
    required this.view,
    required this.bettor,
    required this.onMove,
    this.marked = const [],
    super.key,
  });

  final Set<MoveKind> moves;
  final TableView view;

  /// Who made the bet waiting for your answer, if there is one.
  final String? bettor;

  /// The cards you have marked to throw away.
  final List<PlayingCard> marked;

  final ValueChanged<Move> onMove;

  @override
  State<TableActions> createState() => _TableActionsState();
}

class _TableActionsState extends State<TableActions> {
  var _amount = minEnvido;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final moves = widget.moves;
    final play = widget.onMove;
    Widget row(List<Widget> buttons) => Row(
      spacing: AppSpacing.sm,
      children: [for (final button in buttons) Expanded(child: button)],
    );
    if (moves.contains(MoveKind.discard)) {
      final marked = widget.marked;
      return row([
        ActionButton(
          label: l10n.actionDiscard,
          detail: l10n.actionDiscardCount(marked.length),
          kind: ActionKind.primary,
          onPressed: marked.isEmpty ? null : () => play(Discard(marked)),
        ),
      ]);
    }
    if (moves.contains(MoveKind.mus)) {
      return row([
        ActionButton(label: l10n.actionMus, onPressed: () => play(const Mus())),
        ActionButton(
          label: l10n.actionNoHayMus,
          kind: ActionKind.primary,
          onPressed: () => play(const NoHayMus()),
        ),
      ]);
    }
    final ordago = moves.contains(MoveKind.ordago)
        ? HoldButton(
            label: l10n.actionOrdago,
            detail: l10n.actionHold,
            hint: l10n.actionHoldHint,
            onHeld: () => play(const Ordago()),
          )
        : null;
    final envite = widget.view.stake;
    if (moves.contains(MoveKind.paso)) {
      return Column(
        spacing: AppSpacing.sm,
        children: [
          row([
            ActionButton(
              label: l10n.actionPaso,
              onPressed: () => play(const Paso()),
            ),
            ActionButton(
              label: l10n.actionEnvido,
              detail: '$_amount',
              kind: ActionKind.primary,
              onPressed: () => play(Envido(_amount)),
            ),
            ?ordago,
          ]),
          if (moves.contains(MoveKind.envido))
            _Amounts(
              amount: _amount,
              onChanged: (amount) => setState(() => _amount = amount),
            ),
        ],
      );
    }
    if (moves.contains(MoveKind.quiero) && envite != null) {
      return Column(
        spacing: AppSpacing.sm,
        children: [
          _EnviteSaid(envite: envite, bettor: widget.bettor, view: widget.view),
          row([
            ActionButton(
              label: l10n.actionNoQuiero,
              detail: l10n.enviteIfNot('them', envite.noQuieroPoints),
              onPressed: () => play(const NoQuiero()),
            ),
            ActionButton(
              label: l10n.actionQuiero,
              kind: ActionKind.primary,
              onPressed: () => play(const Quiero()),
            ),
          ]),
          if (moves.contains(MoveKind.envido) || ordago != null)
            row([
              if (moves.contains(MoveKind.envido))
                ActionButton(
                  label: l10n.actionRaise,
                  detail: l10n.actionRaiseAny,
                  onPressed: () async {
                    final amount = await chooseAmount(context, _amount);
                    if (amount != null) {
                      play(Envido(amount));
                    }
                  },
                ),
              ?ordago,
            ]),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}

/// What was bet, and by whom.
class _EnviteSaid extends StatelessWidget {
  const _EnviteSaid({
    required this.envite,
    required this.bettor,
    required this.view,
  });

  final Envite envite;
  final String? bettor;
  final TableView view;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final lance = view.steps
        .firstWhere((step) => step.state == StepProgress.current)
        .step;
    return Text(
      l10n.enviteBy(
        bettor ?? '',
        envite.ordago ? 'yes' : 'no',
        envite.stake,
        lance.name,
      ),
      textAlign: TextAlign.center,
      style: text.titleSmall,
    );
  }
}

/// How much to bet: 2, 5, 10 or any other amount.
class _Amounts extends StatelessWidget {
  const _Amounts({required this.amount, required this.onChanged});

  static const _quick = [2, 5, 10];

  final int amount;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final other = !_quick.contains(amount);
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<int>(
        showSelectedIcon: false,
        segments: [
          for (final quick in _quick)
            ButtonSegment(value: quick, label: Text('$quick')),
          ButtonSegment(
            value: 0,
            label: Text(other ? '$amount' : l10n.actionOtherAmount),
          ),
        ],
        selected: {other ? 0 : amount},
        onSelectionChanged: (selected) async {
          final choice = selected.single;
          if (choice != 0) {
            onChanged(choice);
            return;
          }
          final chosen = await chooseAmount(context, amount);
          if (chosen != null) {
            onChanged(chosen);
          }
        },
      ),
    );
  }
}

/// Asks for any amount to bet, starting at [initial].
Future<int?> chooseAmount(BuildContext context, int initial) =>
    showModalBottomSheet<int>(
      context: context,
      builder: (_) => _AmountSheet(initial: initial),
    );

/// Any amount to bet, from the minimum up.
class _AmountSheet extends StatefulWidget {
  const _AmountSheet({required this.initial});

  static const _most = 40;

  final int initial;

  @override
  State<_AmountSheet> createState() => _AmountSheetState();
}

class _AmountSheetState extends State<_AmountSheet> {
  late var _amount = widget.initial;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          0,
          AppSpacing.xl,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.lg,
          children: [
            Text(l10n.amountTitle, style: text.headlineSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: AppSpacing.xl,
              children: [
                IconButton(
                  tooltip: l10n.amountLess,
                  onPressed: _amount > minEnvido
                      ? () => setState(() => _amount--)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                Text('$_amount', style: text.displayMedium),
                IconButton(
                  tooltip: l10n.amountMore,
                  onPressed: _amount < _AmountSheet._most
                      ? () => setState(() => _amount++)
                      : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: ActionButton(
                label: l10n.amountConfirm(_amount),
                kind: ActionKind.primary,
                onPressed: () => Navigator.of(context).pop(_amount),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../game/event.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'table_texts.dart';
import 'table_view.dart';

/// Everything said in the hand so far, step by step, as a conversation:
/// who said what, and how each lance went.
class HandHistory extends StatelessWidget {
  const HandHistory({
    required this.log,
    required this.view,
    required this.names,
    super.key,
  });

  /// What the table has shown of the hand.
  final List<GameEvent> log;
  final TableView view;

  /// Who sits in each seat, yours included.
  final Map<int, String> names;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final groups = <(String, List<(String, bool)>)>[];
    void line(String said, {bool result = false}) {
      if (groups.isEmpty) {
        groups.add((l10n.stepName('mus'), []));
      }
      groups.last.$2.add((said, result));
    }

    void step(String name) {
      if (groups.lastOrNull?.$1 != name) {
        groups.add((name, []));
      }
    }

    for (final event in log) {
      switch (event) {
        case LanceStarted(:final lance) || Declared(:final lance):
          step(l10n.stepName(lance.name));
          if (event is Declared) {
            line(l10n.historyLine(names[event.seat]!, l10n.said(event, view)));
          }
        case LanceClosed(:final outcome):
          line(
            l10n.stepStatus(
                  StepView(
                    TableStep.values.byName(outcome.lance.name),
                    StepProgress.done,
                    outcome: outcome,
                  ),
                  view,
                ) ??
                '',
            result: true,
          );
        case ManoMoved(:final seat):
          line(l10n.historyManoMoved(names[seat]!), result: true);
        case Reshuffled():
          line(l10n.historyReshuffled, result: true);
        case MusSaid(:final seat) ||
            NoHayMusSaid(:final seat) ||
            Discarded(:final seat) ||
            PasoSaid(:final seat) ||
            EnvidoSaid(:final seat) ||
            QuieroSaid(:final seat) ||
            NoQuieroSaid(:final seat) ||
            OrdagoSaid(:final seat):
          line(l10n.historyLine(names[seat]!, l10n.said(event, view)));
        default:
          break;
      }
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
          spacing: AppSpacing.sm,
          children: [
            Text(l10n.historyTitle, style: text.headlineSmall),
            if (groups.isEmpty) Text(l10n.historyEmpty, style: text.bodyMedium),
            for (final (name, lines) in groups) ...[
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(name, style: text.titleSmall),
              ),
              for (final (said, result) in lines)
                Text(
                  result ? '→ $said' : said,
                  style: result ? text.bodySmall : text.bodyMedium,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../bots/heuristic_bot.dart';
import '../../controllers/settings_controller.dart';
import '../../game/cards.dart';
import '../../game/rules.dart';
import '../../game/table.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/localized_names.dart';
import '../../services/match_store.dart';
import '../cards/playing_card_view.dart';
import '../help/how_to_play_screen.dart';
import '../settings/settings_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/action_button.dart';
import '../widgets/felt.dart';
import 'new_match_screen.dart';

/// Where the app opens: what the game is, the match in progress if there is
/// one, and a way into a new match.
class StartScreen extends StatefulWidget {
  const StartScreen({
    required this.store,
    required this.settings,
    required this.table,
    required this.resume,
    super.key,
  });

  final MatchStore store;
  final SettingsController settings;

  /// The table a new match is played on; [rivals] null for any two.
  final Widget Function(
    Personality partner,
    Rules rules,
    List<Personality>? rivals,
  )
  table;

  /// The table a saved match is resumed on.
  final Widget Function(SavedMatch saved) resume;

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  /// Opens [page] and, back from it, shows what is saved now.
  Future<void> _open(NavigatorState navigator, Route<void> page) async {
    await navigator.push(page);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _newMatch() => _open(
    Navigator.of(context),
    MaterialPageRoute(
      builder: (context) => NewMatchScreen(
        rules: widget.settings.settings.rules,
        onStart: (partner, rules, rivals) async {
          final navigator = Navigator.of(context);
          if (widget.store.saved != null && !await _confirmNew(context)) {
            return;
          }
          await widget.store.clear();
          await navigator.pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => widget.table(partner, rules, rivals),
            ),
          );
          if (mounted) {
            setState(() {});
          }
        },
      ),
    ),
  );

  Future<bool> _confirmNew(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.confirmNewTitle),
            content: Text(l10n.confirmNewBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.confirmNewCancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.confirmNewOk),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final saved = widget.store.saved;
    return Scaffold(
      body: Felt(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.xxl,
                      AppSpacing.xl,
                      AppSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: AppSpacing.sm,
                      children: [
                        Semantics(
                          header: true,
                          child: Text(
                            l10n.startTitle,
                            style: text.displayMedium,
                          ),
                        ),
                        Text(
                          l10n.startSubtitle,
                          style: text.bodyLarge?.copyWith(
                            color: AppColors.inkSecondary,
                          ),
                        ),
                        if (widget.store.setAside)
                          Text(l10n.savedSetAside, style: text.bodySmall),
                        const Expanded(
                          child: Center(
                            child: FittedBox(
                              child: ExcludeSemantics(child: _Fan()),
                            ),
                          ),
                        ),
                        if (saved != null)
                          _Saved(
                            saved: saved,
                            onContinue: () => _open(
                              Navigator.of(context),
                              MaterialPageRoute(
                                builder: (_) => widget.resume(saved),
                              ),
                            ),
                          ),
                        ActionButton(
                          label: l10n.newMatch,
                          kind: saved == null
                              ? ActionKind.primary
                              : ActionKind.secondary,
                          onPressed: _newMatch,
                        ),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: AppSpacing.lg,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const HowToPlayScreen(),
                                ),
                              ),
                              child: Text(l10n.howTitle),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      SettingsScreen(settings: widget.settings),
                                ),
                              ),
                              child: Text(l10n.settingsTitle),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The match in progress: its score, rules, hand and your partner, and the
/// way back to it.
class _Saved extends StatelessWidget {
  const _Saved({required this.saved, required this.onContinue});

  final SavedMatch saved;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final match = saved.match;
    final score = match.scoreNow;
    final partner = saved.bots[2];
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lineStrong, width: 1.5),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.xs,
          children: [
            Semantics(
              header: true,
              child: Text(
                l10n.savedTitle.toUpperCase(),
                semanticsLabel: l10n.savedTitle,
                style: text.labelMedium,
              ),
            ),
            Text(
              l10n.savedScore(score[teamOf(0)], score[1 - teamOf(0)]),
              style: text.titleMedium,
            ),
            Text(
              l10n.savedDetails(
                match.rules.kings.name,
                match.rules.target,
                match.handNumber,
                partner == null ? '' : l10n.personalityName(partner),
              ),
              style: text.bodySmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            ActionButton(
              label: l10n.savedContinue,
              kind: ActionKind.primary,
              onPressed: onContinue,
            ),
          ],
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

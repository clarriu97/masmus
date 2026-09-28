import 'package:flutter/material.dart';

import '../../bots/heuristic_bot.dart';
import '../../game/rules.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/localized_names.dart';
import '../theme/app_theme.dart';
import '../widgets/action_button.dart';
import '../widgets/choice_tile.dart';
import '../widgets/felt.dart';

/// Setting up a match: the partner and the rules. Everything starts at its
/// default, so one tap is enough to play.
class NewMatchScreen extends StatefulWidget {
  const NewMatchScreen({required this.onStart, super.key});

  final void Function(Personality partner, Rules rules) onStart;

  @override
  State<NewMatchScreen> createState() => _NewMatchScreenState();
}

class _NewMatchScreenState extends State<NewMatchScreen> {
  var _partner = Personality.calculador;
  var _rules = const Rules();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: Felt(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back),
                    label: Text(l10n.back),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(l10n.newMatch, style: text.displayMedium),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        l10n.newMatchPartner.toUpperCase(),
                        style: text.labelMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _Partners(
                        selected: _partner,
                        onSelected: (partner) =>
                            setState(() => _partner = partner),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _Rule(
                        label: l10n.newMatchKings,
                        control: SegmentedButton<Kings>(
                          showSelectedIcon: false,
                          segments: [
                            ButtonSegment(
                              value: Kings.eight,
                              label: Text(l10n.kingsCount(8)),
                            ),
                            ButtonSegment(
                              value: Kings.four,
                              label: Text(l10n.kingsCount(4)),
                            ),
                          ],
                          selected: {_rules.kings},
                          onSelectionChanged: (kings) => setState(
                            () => _rules = Rules(
                              kings: kings.single,
                              target: _rules.target,
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: AppSpacing.xl),
                      _Rule(
                        label: l10n.newMatchTarget,
                        control: SegmentedButton<int>(
                          showSelectedIcon: false,
                          segments: [
                            for (final target in const [40, 30])
                              ButtonSegment(
                                value: target,
                                label: Text(l10n.targetPoints(target)),
                              ),
                          ],
                          selected: {_rules.target},
                          onSelectionChanged: (target) => setState(
                            () => _rules = Rules(
                              kings: _rules.kings,
                              target: target.single,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.sm,
                  AppSpacing.xl,
                  AppSpacing.lg,
                ),
                child: ActionButton(
                  label: l10n.newMatchStart,
                  kind: ActionKind.primary,
                  onPressed: () => widget.onStart(_partner, _rules),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The four bots to pick a partner from: two to a row, one when the text is
/// large.
class _Partners extends StatelessWidget {
  const _Partners({required this.selected, required this.onSelected});

  final Personality selected;
  final ValueChanged<Personality> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final large = MediaQuery.textScalerOf(context).scale(1) > 1.4;
    Widget tile(Personality personality) => ChoiceTile(
      title: l10n.personalityName(personality),
      subtitle: l10n.personalityStyle(personality),
      selected: personality == selected,
      onTap: () => onSelected(personality),
    );
    const bots = Personality.values;
    if (large) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.sm,
        children: [for (final bot in bots) tile(bot)],
      );
    }
    return Column(
      spacing: AppSpacing.sm,
      children: [
        for (var i = 0; i < bots.length; i += 2)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.sm,
              children: [
                Expanded(child: tile(bots[i])),
                Expanded(child: tile(bots[i + 1])),
              ],
            ),
          ),
      ],
    );
  }
}

/// A rule's name and its options, side by side while they fit.
class _Rule extends StatelessWidget {
  const _Rule({required this.label, required this.control});

  final String label;
  final Widget control;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.spaceBetween,
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: AppSpacing.md,
    runSpacing: AppSpacing.sm,
    children: [
      Text(label, style: Theme.of(context).textTheme.titleMedium),
      control,
    ],
  );
}

import 'package:flutter/material.dart';

import '../../bots/heuristic_bot.dart';
import '../../game/rules.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/localized_names.dart';
import '../faces/face.dart';
import '../theme/app_theme.dart';
import '../widgets/action_button.dart';
import '../widgets/choice_tile.dart';
import '../widgets/felt.dart';
import '../widgets/setting_row.dart';

/// Setting up a match: the partner, the rivals and the rules. Everything
/// starts at its default (rivals at random), so one tap is enough to play.
class NewMatchScreen extends StatefulWidget {
  const NewMatchScreen({
    required this.onStart,
    this.rules = const Rules(),
    super.key,
  });

  /// [rivals] are the two bots across from you, or null for any two of the
  /// others at random.
  final void Function(
    Personality partner,
    Rules rules,
    List<Personality>? rivals,
  )
  onStart;

  /// The rules it starts with: the defaults from Ajustes.
  final Rules rules;

  @override
  State<NewMatchScreen> createState() => _NewMatchScreenState();
}

class _NewMatchScreenState extends State<NewMatchScreen> {
  var _partner = Personality.calculador;
  List<Personality>? _rivals;
  late var _rules = widget.rules;

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
                        onSelected: (partner) => setState(() {
                          _partner = partner;
                          if (_rivals?.contains(partner) ?? false) {
                            _rivals = null;
                          }
                        }),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        l10n.newMatchRivals.toUpperCase(),
                        style: text.labelMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _Rivals(
                        partner: _partner,
                        selected: _rivals,
                        onSelected: (rivals) =>
                            setState(() => _rivals = rivals),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      SettingRow(
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
                            () => _rules = _rules.copyWith(kings: kings.single),
                          ),
                        ),
                      ),
                      const Divider(height: AppSpacing.xl),
                      SettingRow(
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
                            () =>
                                _rules = _rules.copyWith(target: target.single),
                          ),
                        ),
                      ),
                      const Divider(height: AppSpacing.xl),
                      SettingRow(
                        label: l10n.newMatchGames,
                        control: SegmentedButton<int>(
                          showSelectedIcon: false,
                          segments: [
                            for (final games in const [1, 3, 5])
                              ButtonSegment(
                                value: games,
                                label: Text(l10n.gamesCount(games)),
                              ),
                          ],
                          selected: {_rules.games},
                          onSelectionChanged: (games) => setState(
                            () => _rules = _rules.copyWith(games: games.single),
                          ),
                        ),
                      ),
                      const Divider(height: AppSpacing.xl),
                      SettingRow(
                        label: l10n.newMatchSenas,
                        control: SegmentedButton<bool>(
                          showSelectedIcon: false,
                          segments: [
                            ButtonSegment(
                              value: true,
                              label: Text(l10n.senasOn),
                            ),
                            ButtonSegment(
                              value: false,
                              label: Text(l10n.senasOff),
                            ),
                          ],
                          selected: {_rules.senas},
                          onSelectionChanged: (senas) => setState(
                            () => _rules = _rules.copyWith(senas: senas.single),
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
                  onPressed: () => widget.onStart(_partner, _rules, _rivals),
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
      leading: Face(personality),
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

/// The two rivals: any two of the other bots at random, or a pair chosen.
class _Rivals extends StatelessWidget {
  const _Rivals({
    required this.partner,
    required this.selected,
    required this.onSelected,
  });

  final Personality partner;
  final List<Personality>? selected;
  final ValueChanged<List<Personality>?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final others = [
      for (final bot in Personality.values)
        if (bot != partner) bot,
    ];
    final pairs = [
      for (var i = 0; i < others.length; i++)
        for (var j = i + 1; j < others.length; j++) [others[i], others[j]],
    ];
    bool chosen(List<Personality> pair) =>
        selected != null && pair.every(selected!.contains);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.sm,
      children: [
        ChoiceTile(
          title: l10n.rivalsRandom,
          subtitle: l10n.rivalsRandomDetail,
          selected: selected == null,
          onTap: () => onSelected(null),
        ),
        for (final pair in pairs)
          ChoiceTile(
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [for (final bot in pair) Face(bot)],
            ),
            title: l10n.rivalsPair(
              l10n.personalityName(pair[0]),
              l10n.personalityName(pair[1]),
            ),
            subtitle: l10n.rivalsPairDetail(
              l10n.personalityStyle(pair[0]),
              l10n.personalityStyle(pair[1]),
            ),
            selected: chosen(pair),
            onTap: () => onSelected(pair),
          ),
      ],
    );
  }
}

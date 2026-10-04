import 'package:flutter/material.dart';

import '../../controllers/match_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../game/rules.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/felt.dart';
import '../widgets/setting_row.dart';

/// The rules new matches start with, how fast the bots play and whether
/// the table helps with your hand. Every change is kept at once.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({required this.settings, super.key});

  final SettingsController settings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: Felt(
        child: SafeArea(
          child: ListenableBuilder(
            listenable: settings,
            builder: (context, _) {
              final current = settings.settings;
              final rules = current.rules;
              void change(Settings Function(Settings) edit) =>
                  settings.settings = edit(settings.settings);
              Widget heading(String title) => Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xl),
                child: Semantics(
                  header: true,
                  child: Text(
                    title.toUpperCase(),
                    semanticsLabel: title,
                    style: text.labelMedium,
                  ),
                ),
              );
              return Column(
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
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        0,
                        AppSpacing.xl,
                        AppSpacing.xl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: AppSpacing.md,
                        children: [
                          Semantics(
                            header: true,
                            child: Text(
                              l10n.settingsTitle,
                              style: text.displayMedium,
                            ),
                          ),
                          heading(l10n.settingsRules),
                          SettingRow(
                            label: l10n.newMatchKings,
                            control: SegmentedButton<Kings>(
                              showSelectedIcon: false,
                              segments: [
                                for (final (kings, count) in const [
                                  (Kings.eight, 8),
                                  (Kings.four, 4),
                                ])
                                  ButtonSegment(
                                    value: kings,
                                    label: Text(l10n.kingsCount(count)),
                                  ),
                              ],
                              selected: {rules.kings},
                              onSelectionChanged: (kings) => change(
                                (now) => now.copyWith(
                                  rules: now.rules.copyWith(
                                    kings: kings.single,
                                  ),
                                ),
                              ),
                            ),
                          ),
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
                              selected: {rules.target},
                              onSelectionChanged: (target) => change(
                                (now) => now.copyWith(
                                  rules: now.rules.copyWith(
                                    target: target.single,
                                  ),
                                ),
                              ),
                            ),
                          ),
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
                              selected: {rules.games},
                              onSelectionChanged: (games) => change(
                                (now) => now.copyWith(
                                  rules: now.rules.copyWith(
                                    games: games.single,
                                  ),
                                ),
                              ),
                            ),
                          ),
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
                              selected: {rules.senas},
                              onSelectionChanged: (senas) => change(
                                (now) => now.copyWith(
                                  rules: now.rules.copyWith(
                                    senas: senas.single,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          heading(l10n.settingsPace),
                          SegmentedButton<Pace>(
                            showSelectedIcon: false,
                            segments: [
                              for (final pace in Pace.values)
                                ButtonSegment(
                                  value: pace,
                                  label: Text(l10n.paceName(pace.name)),
                                ),
                            ],
                            selected: {current.pace},
                            onSelectionChanged: (pace) => change(
                              (now) => now.copyWith(pace: pace.single),
                            ),
                          ),
                          heading(l10n.settingsHelp),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              l10n.settingsHelpDetail,
                              style: text.bodyLarge,
                            ),
                            value: current.handHelp,
                            onChanged: (on) =>
                                change((now) => now.copyWith(handHelp: on)),
                          ),
                          heading(l10n.settingsHaptics),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              l10n.settingsHapticsDetail,
                              style: text.bodyLarge,
                            ),
                            value: current.haptics,
                            onChanged: (on) =>
                                change((now) => now.copyWith(haptics: on)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

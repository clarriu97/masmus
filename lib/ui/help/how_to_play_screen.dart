import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/felt.dart';

/// The rules of docs/RULES.md told for playing, with examples; why the deal
/// is fair; and a glossary.
class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final sections = [
      (l10n.howBasicsTitle, [l10n.howBasics]),
      (l10n.howCardsTitle, [l10n.howCards]),
      (l10n.howTurnsTitle, [l10n.howTurns]),
      (l10n.howMusTitle, [l10n.howMus]),
      (
        l10n.howLancesTitle,
        [l10n.howGrande, l10n.howChica, l10n.howPares, l10n.howJuego],
      ),
      (l10n.howBetsTitle, [l10n.howBets]),
      (l10n.howCountTitle, [l10n.howCount]),
      (l10n.howFairTitle, [l10n.howFair]),
    ];
    final glossary = [
      (l10n.glossaryTerm0, l10n.glossaryMeaning0),
      (l10n.glossaryTerm1, l10n.glossaryMeaning1),
      (l10n.glossaryTerm2, l10n.glossaryMeaning2),
      (l10n.glossaryTerm3, l10n.glossaryMeaning3),
      (l10n.glossaryTerm4, l10n.glossaryMeaning4),
      (l10n.glossaryTerm5, l10n.glossaryMeaning5),
      (l10n.glossaryTerm6, l10n.glossaryMeaning6),
      (l10n.glossaryTerm7, l10n.glossaryMeaning7),
      (l10n.glossaryTerm8, l10n.glossaryMeaning8),
      (l10n.glossaryTerm9, l10n.glossaryMeaning9),
      (l10n.glossaryTerm10, l10n.glossaryMeaning10),
      (l10n.glossaryTerm11, l10n.glossaryMeaning11),
      (l10n.glossaryTerm12, l10n.glossaryMeaning12),
    ];
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
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    0,
                    AppSpacing.xl,
                    AppSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: AppSpacing.md,
                    children: [
                      Text(l10n.howTitle, style: text.displayMedium),
                      for (final (title, paragraphs) in sections) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.md),
                          child: Text(title, style: text.headlineSmall),
                        ),
                        for (final paragraph in paragraphs)
                          Text(paragraph, style: text.bodyLarge),
                      ],
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.md),
                        child: Text(
                          l10n.glossaryTitle,
                          style: text.headlineSmall,
                        ),
                      ),
                      for (final (term, meaning) in glossary)
                        MergeSemantics(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(term, style: text.titleMedium),
                              Text(meaning, style: text.bodyMedium),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

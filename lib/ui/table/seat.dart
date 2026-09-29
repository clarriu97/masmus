import 'package:flutter/material.dart';

import '../../game/cards.dart';
import '../../l10n/app_localizations.dart';
import '../cards/deck_view.dart';
import '../cards/playing_card_view.dart';
import '../theme/app_theme.dart';
import '../widgets/cut_badge.dart';
import '../widgets/mano_token.dart';
import '../widgets/speech_bubble.dart';

/// A bot at the table: who it is, its four cards face down and what it just
/// said, which pops up as it says it. While it is thinking, it is edged in
/// brass and its bubble is three dots.
class Seat extends StatelessWidget {
  const Seat({
    required this.name,
    required this.role,
    required this.thinking,
    this.said,
    this.saidAt,
    this.asked,
    this.cards = 4,
    this.mano = false,
    this.cut = false,
    this.senas,
    this.cardsKey,
    this.dimmed = false,
    super.key,
  });

  /// Someone else has the floor: this seat steps back.
  final bool dimmed;

  /// How many cards it holds on the table: fewer while it discards or
  /// while they are dealt.
  final int cards;

  /// It speaks first: it carries the [ManoToken].
  final bool mano;

  /// It cut the mus this hand: it keeps the [CutBadge].
  final bool cut;

  /// The señas it made to you, in words, if it is your partner.
  final String? senas;

  /// Where its cards are, for the deal to fly to.
  final Key? cardsKey;

  final String name;
  final String role;
  final bool thinking;
  final String? said;

  /// Where in the hand it was said: a new place, a new word.
  final int? saidAt;

  /// How many cards it asked for in the last discards, in words.
  final String? asked;

  static const _back = PlayingCard(Suit.oros, 1);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final said = this.said;
    final thinking = this.thinking ? l10n.seatThinking : null;
    return Semantics(
      container: true,
      label: [
        name,
        role,
        if (mano) l10n.tableMano.toLowerCase(),
        if (cut) l10n.seatCut,
        ?senas,
        ?asked,
        ?thinking ?? said,
      ].join('. '),
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.topCenter,
              children: [
                AnimatedOpacity(
                  opacity: dimmed ? 0.4 : 1,
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : AppMotion.short,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DecoratedBox(
                        decoration: ShapeDecoration(
                          shape: CircleBorder(
                            side: thinking != null
                                ? const BorderSide(
                                    color: AppColors.turn,
                                    width: 3,
                                  )
                                : BorderSide.none,
                          ),
                          color: AppColors.avatar,
                        ),
                        child: SizedBox.square(
                          dimension: 46,
                          child: Center(
                            child: Text(
                              name.split(' ').last.characters.first,
                              style: text.headlineSmall?.copyWith(
                                color: AppColors.onAvatar,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        name,
                        style: text.titleSmall,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        role,
                        style: text.labelSmall,
                        textAlign: TextAlign.center,
                      ),
                      if (cut)
                        Text(
                          l10n.seatCut,
                          style: text.labelSmall,
                          textAlign: TextAlign.center,
                        ),
                      if (senas case final senas?)
                        PopIn(
                          key: ValueKey(senas),
                          child: Text(
                            senas,
                            style: text.labelMedium?.copyWith(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      if (asked case final asked?)
                        Text(
                          asked,
                          style: text.labelSmall,
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        key: cardsKey,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 0; i < 4; i++)
                            Align(
                              widthFactor: i == 3 ? 1 : 0.55,
                              child: Visibility.maintain(
                                visible: i < cards,
                                child: const PlayingCardView(
                                  _back,
                                  width: DeckView.cardWidth,
                                  faceUp: false,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (cut)
                  Transform.translate(
                    offset: const Offset(-26, 22),
                    child: const PopIn(child: CutBadge()),
                  ),
                if (mano)
                  Transform.translate(
                    offset: const Offset(26, 22),
                    child: const PopIn(child: ManoToken()),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (thinking != null)
              const ThinkingBubble()
            else
              Visibility.maintain(
                visible: said != null,
                child: PopIn(
                  key: ValueKey(saidAt),
                  child: SpeechBubble(said ?? ' '),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
